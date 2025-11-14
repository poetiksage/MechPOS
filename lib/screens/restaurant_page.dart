import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mech_pos/models/cart_item.dart';
import 'package:mech_pos/models/menu_category.dart';
import 'package:mech_pos/models/menu_item.dart';
import 'package:mech_pos/widgets/cart_section.dart';
import 'package:mech_pos/widgets/menu_section.dart';

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
  late List<MenuCategory> drinksMenu;
  late List<MenuCategory> foodMenu;
  final List<CartItem> cart = [];

  @override
  void initState() {
    super.initState();
    loadMenus();
  }

  void loadMenus() async {
    foodMenu = await loadMenu('assets/foodMenu.json');
    drinksMenu = await loadMenu('assets/drinksMenu.json');

    setState(() {});
  }

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

  void _updateQuantity(int index, int qty) {
    setState(() {
      if (qty > 0) {
        cart[index].quantity = qty;
      } else {
        cart.removeAt(index);
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() => cart.removeAt(index));
  }

  void _generateBill() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add items first')));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bill Generated'),
        content: const Text('Bill printed successfully'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => cart.clear());
            },
            child: const Text('OK'),
          ),
        ],
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
            if (cart.isNotEmpty)
              CartSection(
                cart: cart,
                onGenerateBill: _generateBill,
                onUpdateQuantity: _updateQuantity,
                onRemove: _removeFromCart,
              ),
          ],
        ),
      ),
    );
  }
}
