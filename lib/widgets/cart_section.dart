import 'package:flutter/material.dart';
import 'package:mech_pos/models/cart_item.dart';

class CartSection extends StatelessWidget {
  final List<CartItem> cart;
  final VoidCallback onGenerateBill;
  final void Function(int, int) onUpdateQuantity;
  final void Function(int) onRemove;

  const CartSection({
    super.key,
    required this.cart,
    required this.onGenerateBill,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.total);

  double get tax => subtotal * 0.07;

  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cart',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 360,
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (_, index) {
                final cartItem = cart[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cartItem.item.name,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '₹${cartItem.item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Qty: ${cartItem.quantity}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '₹${cartItem.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () =>
                                  onUpdateQuantity(index, cartItem.quantity - 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () =>
                                  onUpdateQuantity(index, cartItem.quantity + 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              onPressed: () => onRemove(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _row('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                _row('Tax (7%)', '₹${tax.toStringAsFixed(2)}'),
                const Divider(),
                _row(
                  'Total',
                  '₹${total.toStringAsFixed(2)}',
                  bold: true,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onGenerateBill,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Generate Bill',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
