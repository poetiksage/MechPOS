import 'package:flutter/material.dart';
import 'package:mech_pos/models/printer_info.dart';
import 'package:mech_pos/services/printer_discovery.dart';

class PrinterSelectionDialog extends StatefulWidget {
  final Function(PrinterInfo) onSelect;

  const PrinterSelectionDialog({super.key, required this.onSelect});

  @override
  State<PrinterSelectionDialog> createState() => _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState extends State<PrinterSelectionDialog> {
  List<PrinterInfo> printers = [];
  bool scanning = false;
  String manualIp = "";
  int manualPort = 9100;

  void scanPrinters() async {
    setState(() => scanning = true);

    final subnet = await PrinterDiscovery.getSubnet();
    final result = await PrinterDiscovery.scanPrinters(subnet: subnet);

    setState(() {
      printers = result;
      scanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Printer"),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: scanning ? null : scanPrinters,
              icon: scanning ? const SizedBox.shrink() : const Icon(Icons.wifi),
              label: Text(scanning ? "Scanning..." : "Scan Network"),
            ),
            const SizedBox(height: 12),

            // discovered printers
            if (printers.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.separated(
                  itemCount: printers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final p = printers[index];
                    return ListTile(
                      leading: const Icon(Icons.print),
                      title: Text(p.ip),
                      subtitle: Text("Port: ${p.port}"),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSelect(p);
                      },
                    );
                  },
                ),
              )
            else if (!scanning)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No printers found yet. Try scanning or enter IP manually.",
                ),
              ),

            const Divider(),

            // manual entry
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Manual entry",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: "IP address",
                hintText: "192.168.0.196",
              ),
              onChanged: (v) => manualIp = v.trim(),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "Port",
                hintText: "9100",
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final p = int.tryParse(v.trim());
                if (p != null) manualPort = p;
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (manualIp.isNotEmpty) {
                        final p = PrinterInfo(manualIp, manualPort);
                        Navigator.pop(context);
                        widget.onSelect(p);
                      }
                    },
                    child: const Text("Use this printer"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
