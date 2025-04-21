import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifyme/pages/checkform/view.dart';
import 'package:verifyme/pages/settings/view.dart';
import 'package:verifyme/utils/generate/controller.dart';
import 'package:verifyme/pages/editform/view.dart';
import 'package:verifyme/utils/notify.dart';
import 'package:file_picker/file_picker.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.title});

  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GetStorage _box = GetStorage();
  final GenerateController controller = Get.put(GenerateController());
  final GenerateController totpController = Get.find();
  final FocusNode _focusNode = FocusNode();
  final _isBlurred = false.obs;

  late String _languageCode;

  @override
  void initState() {
    super.initState();

    // 翻译页面
    _languageCode = _box.read('languageCode') ?? 'en';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18nLoaded();
  }

  Future<void> _i18nLoaded() async {
    await FlutterI18n.refresh(context, Locale(_languageCode));
    if (mounted) setState(() {});
  }

  // 导入List
  Future<void> importList() async {
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
        showNotification(FlutterI18n.translate(context, "import_successfully"));
      } else {
        showNotification(
            FlutterI18n.translate(context, "file_selection_cancelled"));
      }
    } catch (e) {
      showNotification(FlutterI18n.translate(context, "failed_to_import"));
    }
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
                                  label: FlutterI18n.translate(context, "edit"),
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
                                  label:
                                      FlutterI18n.translate(context, "delete"),
                                ),
                              ],
                            ),
                            child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: code));
                                  showNotification(
                                    FlutterI18n.translate(
                                        context, "code_has_been_copied"),
                                  );
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
                                              showNotification(
                                                  FlutterI18n.translate(
                                                      context, "added"));
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
      floatingActionButton: _isBlurred.value
          ? null
          : Container(
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                padding: const EdgeInsets.all(18.0),
                offset: const Offset(0, -200),
                shadowColor: Colors.black38,
                elevation: 10,
                color: Theme.of(context).colorScheme.secondaryContainer,
                onSelected: (value) async {
                  if (value == 1) {
                    var result = await BarcodeScanner.scan();
                    if (result.rawContent.isNotEmpty && mounted) {
                      Get.to(() => CheckFormPage(resultUrl: result.rawContent));
                    }
                  } else if (value == 2) {
                    if (mounted) {
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
                    importList();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.qr_code_scanner),
                      title:
                          Text(FlutterI18n.translate(context, "scan_qr_code")),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.input),
                      title: Text(
                          FlutterI18n.translate(context, "enter_manually")),
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: ListTile(
                      leading: Icon(Icons.download),
                      title:
                          Text(FlutterI18n.translate(context, "import_json")),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FlutterI18n.translate(context, "confirm")),
          content: Text(FlutterI18n.translate(context, "are_you_sure")),
          actions: <Widget>[
            TextButton(
              child: Text(FlutterI18n.translate(context, "cancel")),
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
              child: Text(FlutterI18n.translate(context, "delete")),
            ),
          ],
        );
      },
    );
  }
}
