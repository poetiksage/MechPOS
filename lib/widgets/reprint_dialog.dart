import 'package:flutter/material.dart';
import 'package:mech_pos/models/printer_info.dart';
import 'package:mech_pos/services/printer_prefs.dart';
import 'package:mech_pos/services/reprint_service.dart';
import 'package:mech_pos/widgets/printer_selection_dialog.dart';

class ReprintDialog extends StatefulWidget {
  const ReprintDialog({super.key});

  @override
  State<ReprintDialog> createState() => _ReprintDialogState();
}

class _ReprintDialogState extends State<ReprintDialog> {
  final TextEditingController _orderIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _reprint() async {
    final orderId = _orderIdController.text.trim();

    if (orderId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: get saved printer
      PrinterInfo? printer = await PrinterPrefs.getSavedPrinter();

      if (printer == null) {
        if (!mounted) return;

        // Ask user to select printer
        printer = await showDialog<PrinterInfo>(
          context: context,
          builder: (_) => PrinterSelectionDialog(
            onSelect: (p) {
              Navigator.pop(context, p);
            },
          ),
        );

        if (printer == null) {
          setState(() => _isLoading = false);
          return;
        }

        await PrinterPrefs.savePrinter(printer);
      }

      // Step 2: reprint
      final success = await ReprintService.reprintOrder(
        orderId: orderId,
        printer: printer,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Receipt reprinted' : 'Reprint failed',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reprint failed')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reprint Receipt'),
      content: TextField(
        controller: _orderIdController,
        decoration: const InputDecoration(
          labelText: 'Order ID',
          hintText: 'e.g. ORD-20240215-123045',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _reprint,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Reprint'),
        ),
      ],
    );
  }
}
