import 'package:flutter/material.dart';
import 'package:mech_pos/models/printer_info.dart';
import 'package:mech_pos/services/printer_prefs.dart';
import 'package:mech_pos/widgets/printer_selection_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PrinterInfo? savedPrinter;

  @override
  void initState() {
    super.initState();
    _loadPrinter();
  }

  void _loadPrinter() async {
    savedPrinter = await PrinterPrefs.getSavedPrinter();
    if (!mounted) return;
    setState(() {});
  }

  void _changePrinter() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return PrinterSelectionDialog(
          onSelect: (printer) async {
            Navigator.of(dialogContext).pop();

            await PrinterPrefs.savePrinter(printer);

            if (!mounted) return;
            setState(() {
              savedPrinter = printer;
            });
          },
        );
      },
    );
  }

  void _clearPrinter() async {
    await PrinterPrefs.clear();

    if (!mounted) return;
    setState(() {
      savedPrinter = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Printer removed")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Printer Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.print),
              title: Text(
                savedPrinter == null
                    ? "No printer selected"
                    : "Printer: ${savedPrinter!.ip}:${savedPrinter!.port}",
              ),
              subtitle: const Text("Configured receipt printer"),
              trailing: ElevatedButton(
                onPressed: _changePrinter,
                child: Text(savedPrinter == null ? "Select" : "Change"),
              ),
            ),

            if (savedPrinter != null)
              Center(
                child: TextButton(
                  onPressed: _clearPrinter,
                  child: const Text(
                    "Remove saved printer",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),

            const Divider(height: 40),

            const Text(
              "App Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text("More settings coming soon"),
          ],
        ),
      ),
    );
  }
}
