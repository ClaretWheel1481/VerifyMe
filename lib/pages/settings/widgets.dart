import 'package:flutter/material.dart';
import 'package:verifyme/constants/app.dart';

AboutDialog buildAboutDialog() {
  return const AboutDialog(
    applicationVersion: appVersion,
    applicationName: 'VerifyMe',
    applicationLegalese: "Copyright© 2025 Lance Huang",
  );
}
