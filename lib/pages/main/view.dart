import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/scanner/view.dart';
import 'package:verifyme/pages/settings/view.dart';
import 'package:verifyme/pages/utils/totp/controller.dart';

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
                    Get.to(
                      () => const Settings(),
                      transition: Transition.cupertino,
                    );
                  },
                ),
              ],
            ),
            Obx(() {
              if (totpController.totpList.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Press button to add the first data.",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
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
                      final secret = totpController.totpList[index]['secret']!;
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
                            return CircularProgressIndicator(
                              value: totpController.progress.value,
                            );
                          }),
                          title: Text(
                            totp,
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          subtitle: Text(
                            accountName,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteDialog(context, index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          setState(() {
            Get.to(
              () => const Scanner(),
              transition: Transition.cupertino,
            );
          })
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
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
