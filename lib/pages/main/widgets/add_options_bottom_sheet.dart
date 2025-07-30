import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/l10n/generated/localizations.dart';
import 'package:verifyme/pages/checkform/view.dart';
import 'package:verifyme/pages/editform/view.dart';
import 'package:verifyme/pages/main/scan_qr_page.dart';

class AddOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onImport;

  const AddOptionsBottomSheet({
    super.key,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  Navigator.pop(context);
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
                },
                child: ListTile(
                  leading: Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(loc.scan_qr_code),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const EditForm(
                        accountName: "",
                        secret: "",
                        algorithm: "SHA-1",
                        length: "6",
                        mode: "TOTP",
                        isEdit: false,
                      ));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.input,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(loc.enter_manually),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  onImport();
                },
                child: ListTile(
                  leading: Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(loc.import_json),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
