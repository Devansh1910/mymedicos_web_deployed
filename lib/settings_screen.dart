import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'locale_notifier.dart';
import 'text_size_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) {
                return SwitchListTile(
                  title: const Text('Dark Theme'),
                  value: themeNotifier.currentTheme == ThemeData.dark(),
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                );
              },
            ),
            Consumer<LocaleNotifier>(
              builder: (context, localeNotifier, child) {
                return DropdownButton<String>(
                  value: localeNotifier.currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      localeNotifier.changeLocale(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  ],
                );
              },
            ),
            Consumer<TextSizeNotifier>(
              builder: (context, textSizeNotifier, child) {
                return Slider(
                  value: textSizeNotifier.textScaleFactor,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: textSizeNotifier.textScaleFactor.toStringAsFixed(1),
                  onChanged: (value) {
                    textSizeNotifier.setTextScaleFactor(value);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
