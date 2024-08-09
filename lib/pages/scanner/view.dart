import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'controller.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final QRCodeController qrCodeController = Get.put(QRCodeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                if (barcode.rawValue != null) {
                  qrCodeController.setQRCode(barcode.rawValue!);
                }
              },
            ),
          ),
          // 二维码扫描结果显示
          Obx(() => Text(
                'Result: ${qrCodeController.qrCode.value}',
                style: TextStyle(fontSize: 20),
              )),
        ],
      ),
    );
  }
}
