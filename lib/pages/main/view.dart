import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/main/widgets.dart';
import 'package:verifyme/pages/settings/view.dart';
import 'package:verifyme/utils/generate/controller.dart';
import 'package:verifyme/pages/editform/view.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.title});

  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GenerateController controller = Get.put(GenerateController());
  final FocusNode _focusNode = FocusNode();
  final _isBlurred = false.obs;

  @override
  void initState() {
    super.initState();
    // 检测App是否最小化
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.paused" ||
          msg == "AppLifecycleState.inactive") {
        setState(() {
          _isBlurred.value = true;
        });
      } else if (msg == "AppLifecycleState.resumed") {
        setState(() {
          _isBlurred.value = false;
        });
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_focusNode);
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  centerTitle: false,
                  expandedHeight: 200.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
                    collapseMode: CollapseMode.pin,
                    title: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(widget.title),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Get.to(() => const Settings());
                      },
                    ),
                  ],
                ),
                Obx(
                  () => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final accountName =
                            controller.totpList[index]['accountName']!;
                        final secret = controller.totpList[index]['secret']!;
                        final algorithm =
                            controller.totpList[index]['algorithm']!;
                        final length = controller.totpList[index]['length']!;
                        final mode = controller.totpList[index]['mode']!;
                        final counter =
                            controller.totpList[index]['counter'] ?? 0;
                        final code = mode == "TOTP"
                            ? controller.generate(
                                secret, algorithm, length, mode)
                            : controller.generate(
                                secret, algorithm, length, mode,
                                counter: counter);
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 14.0),
                            padding: const EdgeInsets.only(top: 2.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Code has been copied to the clipboard'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: mode == "TOTP"
                                    ? Obx(() {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: controller.progress.value,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                            Text(
                                              '${controller.remainingSeconds.value}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                    : const Icon(Icons.lock),
                                title: Text(
                                  accountName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  code,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (mode == "HOTP")
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          controller.totpList[index]
                                              ['counter']++;
                                          controller.saveList();
                                          controller.refreshList();
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Get.to(() => EditForm(
                                              accountName: accountName,
                                              secret: secret,
                                              algorithm: algorithm,
                                              length: length.toString(),
                                              mode: mode,
                                              isEdit: true,
                                            ));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _showDeleteDialog(context, index),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      },
                      childCount: controller.totpList.length,
                    ),
                  ),
                ),
              ],
            ),
            Obx(() {
              return _isBlurred.value
                  ? BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withValues(alpha: 0.3),
                      ),
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
      floatingActionButton: const MainfloatButton(),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                controller.delete(index);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
