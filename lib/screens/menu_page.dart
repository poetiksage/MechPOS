import 'package:flutter/material.dart';
import 'package:mech_pos/services/api_client.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Map<String, dynamic> menu = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      final data = await ApiClient.get("menu/full.php");

      // debugPrint("MENU API RESPONSE: $data");

      if (data["status"] == true) {
        setState(() {
          menu = data["data"]["menu"] ?? {};
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> addItem(String categoryName, int categoryId) async {
    String name = "";
    String price = "";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add to $categoryName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Item Name"),
              onChanged: (v) => name = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
              onChanged: (v) => price = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiClient.post("menu/add.php", {
                  "name": name,
                  "price": price,
                  "category_id": categoryId,
                });

                if (!mounted) return;
                Navigator.pop(context);
                fetchMenu();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item added successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> editItem(dynamic item) async {
    final nameController = TextEditingController(text: item["name"]);
    final priceController = TextEditingController(
      text: item["price"].toString(),
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                debugPrint("EDIT ITEM ID: ${item["id"]}");
                debugPrint("NEW NAME: ${nameController.text}");
                debugPrint("NEW PRICE: ${priceController.text}");

                final response = await ApiClient.put("menu/update.php", {
                  "id": item["id"],
                  "name": nameController.text.trim(),
                  "price": priceController.text.trim(),
                });

                debugPrint("UPDATE RESPONSE: $response");

                if (!mounted) return;

                Navigator.pop(context);
                fetchMenu();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Item updated")));
              } catch (e) {
                debugPrint("EDIT ERROR: $e");

                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    nameController.dispose();
    priceController.dispose();
  }

  Future<void> deleteItem(int id) async {
    try {
      await ApiClient.delete("menu/delete.php", {"id": id});

      fetchMenu();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Item deleted successfully')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildCategory(String categoryName, dynamic categoryData) {
    return Card(
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          categoryName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        children: [
          ...categoryData["items"].map<Widget>((item) {
            return ListTile(
              title: Text(item["name"]),
              subtitle: Text("₹${item["price"]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editItem(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(item["id"]),
                  ),
                ],
              ),
            );
          }).toList(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
              onPressed: () => addItem(categoryName, categoryData["id"]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: menu.keys.map((categoryName) {
                return buildCategory(categoryName, menu[categoryName]);
              }).toList(),
            ),
    );
  }
}
