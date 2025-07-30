import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:verifyme/constants/app.dart';
import 'package:verifyme/pages/settings/view.dart';
import 'package:verifyme/utils/generate/controller.dart';
import 'package:verifyme/utils/notify.dart';
import 'package:file_picker/file_picker.dart';
import 'package:verifyme/l10n/generated/localizations.dart';
import 'package:verifyme/pages/main/widgets/otp_list_item.dart';
import 'package:verifyme/pages/main/widgets/add_options_bottom_sheet.dart';
import 'package:verifyme/pages/main/widgets/confirm_dialog.dart';

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
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
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
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
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
                        return OtpListItem(
                          index: index,
                          item: controller.totpList[index],
                          controller: controller,
                          onDelete: () => _showDeleteDialog(context, index),
                        );
                      },
                      childCount: controller.totpList.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddOptions(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 6,
        icon: const Icon(Icons.add),
        label: Text(loc.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onConfirm: () => importList(context),
          title: AppLocalizations.of(context).import_warning,
        );
      },
    );
  }

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

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddOptionsBottomSheet(
          onImport: () => _showImportDialog(context),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onConfirm: () => controller.delete(index),
          title: AppLocalizations.of(context).are_you_sure,
        );
      },
    );
  }
}
