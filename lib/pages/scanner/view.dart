import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/checkform/view.dart';
import 'package:verifyme/pages/inputform/view.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: MobileScanner(
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                if (barcode.rawValue != null) {
                  Get.back();
                  Get.to(() => TOTPFormPage(totpUrl: barcode.rawValue!));
                }
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
                child: ElevatedButton(
              onPressed: () => Get.off(() => const TOTPInputForm()),
              child: const Text('Manual Input'),
            )),
          ),
        ],
      ),
    );
  }
}
