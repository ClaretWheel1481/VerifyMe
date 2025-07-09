import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:verifyme/constants/app.dart';
import 'package:verifyme/pages/checkform/view.dart';
import 'package:verifyme/pages/settings/view.dart';
import 'package:verifyme/utils/generate/controller.dart';
import 'package:verifyme/pages/editform/view.dart';
import 'package:verifyme/utils/notify.dart';
import 'package:file_picker/file_picker.dart';
import 'package:verifyme/l10n/generated/localizations.dart';
import 'package:verifyme/pages/main/scan_qr_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.title});

  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GenerateController controller = Get.put(GenerateController());
  final GenerateController totpController = Get.find();
  final _isBlurred = false.obs;
  int _selectedIndex = 0;

  static late final List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _MainContent(title: widget.title),
      const Settings(),
    ];
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.paused" ||
          msg == "AppLifecycleState.inactive") {
        _isBlurred.value = true;
      } else if (msg == "AppLifecycleState.resumed") {
        _isBlurred.value = false;
      }
      return null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: widget.title,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: AppLocalizations.of(context).settings,
              ),
            ],
          ),
        ),
        Obx(() => _isBlurred.value
            ? Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}

class _MainContent extends StatefulWidget {
  final String title;
  const _MainContent({this.title = AppConstants.appName});

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  final GenerateController controller = Get.find();
  final GenerateController totpController = Get.find();
  final FocusNode _focusNode = FocusNode();

  // 导入列表
  Future<void> importList(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        totpController.totpList.assignAll(
          jsonList.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        totpController.saveList();
        totpController.onInit();
        showNotification(loc.import_successfully);
      } else {
        showNotification(loc.file_selection_cancelled);
      }
    } catch (e) {
      showNotification(loc.failed_to_import);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  expandedHeight: 180.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
                    collapseMode: CollapseMode.pin,
                    title: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(widget.title),
                    ),
                  ),
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
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withAlpha(60),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Slidable(
                            key: ValueKey(index),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Get.to(() => EditForm(
                                          accountName: accountName,
                                          secret: secret,
                                          algorithm: algorithm,
                                          length: length.toString(),
                                          mode: mode,
                                          isEdit: true,
                                        ));
                                  },
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  icon: Icons.edit,
                                  label: loc.edit,
                                ),
                                SlidableAction(
                                  onPressed: (context) =>
                                      _showDeleteDialog(context, index),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  icon: Icons.delete,
                                  label: loc.delete,
                                ),
                              ],
                            ),
                            child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: code));
                                  showNotification(loc.code_has_been_copied);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  child: ListTile(
                                    leading: mode == "TOTP"
                                        ? Obx(() {
                                            return CircularProgressIndicator(
                                              year2023: false,
                                              value: controller.progress.value,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            );
                                          })
                                        : Container(
                                            margin: const EdgeInsets.all(12.2),
                                            child: const Icon(Icons.lock),
                                          ),
                                    title: Text(
                                      accountName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                    trailing: mode == "HOTP"
                                        ? IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              controller.totpList[index]
                                                  ['counter']++;
                                              controller.saveList();
                                              controller.refreshList();
                                              showNotification(loc.added);
                                            },
                                          )
                                        : null,
                                  ),
                                )),
                          ),
                        );
                      },
                      childCount: controller.totpList.length,
                    ),
                  ),
                ),
              ],
            ),
            // 移除 _isBlurred 的 Obx 模糊层
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: PopupMenuButton<int>(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          padding: const EdgeInsets.all(18.0),
          offset: const Offset(0, -200),
          shadowColor: Colors.black38,
          elevation: 10,
          color: Theme.of(context).colorScheme.secondaryContainer,
          onSelected: (value) async {
            if (value == 1) {
              final qrCode = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ScanQrPage(),
                ),
              );
              if (qrCode != null &&
                  qrCode is String &&
                  qrCode.isNotEmpty &&
                  context.mounted) {
                Get.to(() => CheckFormPage(resultUrl: qrCode));
              }
            } else if (value == 2) {
              if (context.mounted) {
                Get.to(() => const EditForm(
                      accountName: "",
                      secret: "",
                      algorithm: "SHA-1",
                      length: "6",
                      mode: "TOTP",
                      isEdit: false,
                    ));
              }
            } else if (value == 3) {
              importList(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(loc.scan_qr_code),
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: const Icon(Icons.input),
                title: Text(loc.enter_manually),
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: ListTile(
                leading: const Icon(Icons.download),
                title: Text(loc.import_json),
              ),
            ),
          ],
          icon: Icon(Icons.add,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.confirm),
          content: Text(loc.are_you_sure),
          actions: <Widget>[
            TextButton(
              child: Text(loc.cancel),
              onPressed: () {
                Get.back();
              },
            ),
            ElevatedButton(
              onPressed: () {
                controller.delete(index);
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary),
              ),
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
  }
}
