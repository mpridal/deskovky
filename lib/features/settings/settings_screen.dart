import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/layout/empty_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => EmptyScreen(title: AppLocalizations.of(context).navSettings);
}
