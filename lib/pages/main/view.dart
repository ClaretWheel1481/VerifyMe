import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/checkform/view.dart';
import 'package:verifyme/pages/inputform/view.dart';
import 'package:verifyme/pages/settings/view.dart';
import 'package:verifyme/utils/totp/controller.dart';
import 'package:verifyme/pages/editform/view.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.title});

  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TOTPController totpController = Get.put(TOTPController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
          displacement: 50,
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 180.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
                  collapseMode: CollapseMode.parallax,
                  title: Text(widget.title),
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
              Obx(() {
                if (totpController.totpList.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "Press button to add the data",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final accountName =
                            totpController.totpList[index]['accountName']!;
                        final secret =
                            totpController.totpList[index]['secret']!;
                        final algorithm =
                            totpController.totpList[index]['algorithm']!;
                        final totp =
                            totpController.generateTOTP(secret, algorithm);
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 14.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSecondary,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Obx(() {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: totpController.progress.value,
                                  ),
                                  Text(
                                    '${totpController.remainingSeconds.value}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            title: Text(
                              totp,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            subtitle: Text(
                              accountName,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Get.to(() => EditForm(
                                          index: index,
                                          accountName: accountName,
                                          secret: secret,
                                          algorithm: algorithm,
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
                        );
                      },
                      childCount: totpController.totpList.length,
                    ),
                  );
                }
              }),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              shape: BoxShape.circle),
          child: PopupMenuButton<int>(
            padding: const EdgeInsets.all(16.0),
            offset: const Offset(0, -150),
            color: Theme.of(context).colorScheme.onSecondary,
            onSelected: (value) async {
              if (value == 1) {
                var result = await BarcodeScanner.scan();
                if (result.rawContent.isNotEmpty) {
                  Get.to(() => TOTPFormPage(totpUrl: result.rawContent));
                }
              } else if (value == 2) {
                Get.to(() => const TOTPInputForm());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.qr_code_scanner),
                  title: Text('Scan'),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.input),
                  title: Text('Manual Input'),
                ),
              ),
            ],
            icon: const Icon(Icons.add),
          ),
        ));
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this TOTP?'),
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
                totpController.deleteTOTP(index);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
