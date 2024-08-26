import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/checkform/view.dart';
import 'package:verifyme/pages/editform/view.dart';

class MainfloatButton extends StatelessWidget {
  const MainfloatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
          shape: BoxShape.circle),
      child: PopupMenuButton<int>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: const EdgeInsets.all(18.0),
        offset: const Offset(0, -150),
        color: Theme.of(context).colorScheme.onSecondary,
        onSelected: (value) async {
          if (value == 1) {
            var result = await BarcodeScanner.scan();
            if (result.rawContent.isNotEmpty) {
              Get.to(() => TOTPFormPage(totpUrl: result.rawContent));
            }
          } else if (value == 2) {
            Get.to(() => const EditForm(
                  accountName: "",
                  secret: "",
                  algorithm: "SHA-1",
                  length: "6",
                ));
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
    );
  }
}
