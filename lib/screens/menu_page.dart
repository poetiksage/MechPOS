import 'package:flutter/material.dart';
import 'package:mech_pos/services/api_client.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> menu = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      final data = await ApiClient.get("menu/full.php");

      if (data["status"] == true) {
        final rawMenu = data["data"]["menu"];

        setState(() {
          // FORCE menu into a List ALWAYS
          if (rawMenu is List) {
            menu = rawMenu;
          } else if (rawMenu is Map) {
            menu = rawMenu.values.toList();
          } else {
            menu = [];
          }

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

  Future<void> addItem(int categoryId) async {
    String name = "";
    String price = "";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add to $categoryId"),
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

  Future<void> _addCategory() async {
    String name = "";
    String type = "food"; // default

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Category Name"),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: "Category Type"),
              items: const [
                DropdownMenuItem(value: "food", child: Text("Food")),
                DropdownMenuItem(value: "drinks", child: Text("Drinks")),
              ],
              onChanged: (v) {
                if (v != null) type = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (name.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Category name is required")),
                );
                return;
              }

              try {
                await ApiClient.post("menu/add_category.php", {
                  "name": name.trim(),
                  "type": type,
                });

                if (!mounted) return;

                Navigator.pop(dialogContext);
                fetchMenu();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Category added successfully")),
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

  Future<void> _editCategory(
    int id,
    String currentName,
    String currentType,
  ) async {
    String name = currentName;
    String type = currentType;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: currentName),
              decoration: const InputDecoration(labelText: "Category Name"),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: "Category Type"),
              items: const [
                DropdownMenuItem(value: "food", child: Text("Food")),
                DropdownMenuItem(value: "drinks", child: Text("Drinks")),
              ],
              onChanged: (v) {
                if (v != null) type = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (name.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Category name is required")),
                );
                return;
              }

              try {
                await ApiClient.put("menu/update_category.php", {
                  "id": id,
                  "name": name.trim(),
                  "type": type,
                });

                if (!mounted) return;

                Navigator.pop(dialogContext);
                fetchMenu();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Category updated")),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Category"),
        content: const Text(
          "This category will be deleted permanently.\n\n"
          "You cannot delete a category that has menu items.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiClient.delete("menu/delete_category.php", {"id": id});

      if (!mounted) return;

      fetchMenu();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Category deleted")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildCategory(Map<String, dynamic> category) {
    final int categoryId = category["id"];
    final String categoryName = category["name"];
    final String categoryType = category["type"] ?? "food";

    final List items = category["items"] is List
        ? category["items"]
        : (category["items"] as Map).values.toList();

    return Card(
      elevation: 3,
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () =>
                  _editCategory(categoryId, categoryName, categoryType),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteCategory(categoryId),
            ),
          ],
        ),
        children: [
          ...items.map<Widget>((item) {
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
              onPressed: () => addItem(categoryId),
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
          : menu.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: menu.map((category) {
                return buildCategory(category);
              }).toList(),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No menu found",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start by adding a category and menu items",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Category"),
              onPressed: _addCategory,
            ),
          ],
        ),
      ),
    );
  }
}
