import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/scanner/view.dart';
import 'package:verifyme/pages/totpform/controller.dart';

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
            ),
            Obx(() => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final accountName =
                          totpController.totpList[index]['accountName']!;
                      final secret = totpController.totpList[index]['secret']!;
                      final totp = totpController.generateTOTP(secret);
                      return ListTile(
                        title: Text(
                          totp,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(accountName),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _showDeleteDialog(context, index),
                        ),
                      );
                    },
                    childCount: totpController.totpList.length,
                  ),
                )),
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
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this TOTP?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                totpController.deleteTOTP(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
