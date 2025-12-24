import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mech_pos/models/cart_item.dart';
import 'package:mech_pos/models/menu_category.dart';
import 'package:mech_pos/models/menu_item.dart';
import 'package:mech_pos/models/printer_info.dart';
import 'package:mech_pos/models/restaurant_info.dart';
import 'package:mech_pos/services/printer_prefs.dart';
import 'package:mech_pos/services/printer_service.dart';
import 'package:mech_pos/services/restaurant_service.dart';
import 'package:mech_pos/widgets/cart_section.dart';
import 'package:mech_pos/widgets/menu_section.dart';
import 'package:mech_pos/widgets/printer_selection_dialog.dart';

// Load JSON menu file
Future<List<MenuCategory>> loadMenu(String path) async {
  final String response = await rootBundle.loadString(path);
  final data = jsonDecode(response);

  return (data['categories'] as List)
      .map((cat) => MenuCategory.fromJson(cat))
      .toList();
}

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  List<MenuCategory> drinksMenu = [];
  List<MenuCategory> foodMenu = [];
  final List<CartItem> cart = [];

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  // Load food and drinks menu from assets
  void _loadMenus() async {
    final food = await loadMenu('assets/foodMenu.json');
    final drinks = await loadMenu('assets/drinksMenu.json');

    if (!mounted) return;

    setState(() {
      foodMenu = food;
      drinksMenu = drinks;
    });
  }

  // Add item to cart
  void _addToCart(MenuItem item) {
    final existing = cart.firstWhere(
      (c) => c.item.name == item.name,
      orElse: () => CartItem(item: item, quantity: 0),
    );

    setState(() {
      if (existing.quantity == 0) {
        cart.add(CartItem(item: item, quantity: 1));
      } else {
        existing.quantity++;
      }
    });
  }

  // Update quantity or remove item
  void _updateQuantity(int index, int qty) {
    setState(() {
      if (qty > 0) {
        cart[index].quantity = qty;
      } else {
        cart.removeAt(index);
      }
    });
  }

  // Remove from cart
  void _removeFromCart(int index) {
    setState(() => cart.removeAt(index));
  }

  // Helper to calculate totals
  Map<String, double> _calculateTotals() {
    final subtotal = cart.fold(0.0, (sum, c) => sum + c.total);
    final tax = subtotal * 0.07;
    final total = subtotal + tax;

    return {"subtotal": subtotal, "tax": tax, "total": total};
  }

  // Print to a specific printer
  void _printToPrinter(PrinterInfo printer) async {
    final totals = _calculateTotals();
    final subtotal = totals["subtotal"]!;
    final tax = totals["tax"]!;
    final total = totals["total"]!;

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Printing...")));

    try {
      // Fetch restaurant info just before printing
      final RestaurantInfo restaurant =
          await RestaurantService.fetchRestaurantInfo();

      final didPrint = await PrinterService.printRestaurantBill(
        ip: printer.ip,
        port: printer.port,
        items: cart,
        subtotal: subtotal,
        tax: tax,
        total: total,
        restaurant: restaurant,
      );

      if (!mounted) return;

      if (didPrint) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Bill printed")));
        setState(() => cart.clear());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Printing failed")));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch restaurant info")),
      );
    }
  }

  // Generate bill → auto print or select printer
  void _generateBill() async {
    if (cart.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add items first')));
      return;
    }

    // Step 1: Try saved printer
    final savedPrinter = await PrinterPrefs.getSavedPrinter();

    if (!mounted) return;

    if (savedPrinter != null) {
      _printToPrinter(savedPrinter);
      return;
    }

    // Step 2: No saved printer → open selection popup
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => PrinterSelectionDialog(
        onSelect: (PrinterInfo printer) async {
          Navigator.pop(context);

          // Save the printer
          await PrinterPrefs.savePrinter(printer);

          if (!mounted) return;
          _printToPrinter(printer);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MenuSection(
              title: 'Drinks Menu',
              categories: drinksMenu,
              onAdd: _addToCart,
            ),

            const Divider(),

            MenuSection(
              title: 'Food Menu',
              categories: foodMenu,
              onAdd: _addToCart,
            ),

            const Divider(),

            if (cart.isNotEmpty) ...[
              CartSection(
                cart: cart,
                onGenerateBill: _generateBill,
                onUpdateQuantity: _updateQuantity,
                onRemove: _removeFromCart,
              ),
              const SizedBox(height: 60),
            ],
          ],
        ),
      ),
    );
  }
}
