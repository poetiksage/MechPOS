import 'package:flutter/gestures.dart'; // IMPORTANT for PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:mech_pos/models/menu_category.dart';
import 'package:mech_pos/models/menu_item.dart';

class MenuSection extends StatefulWidget {
  final String title;
  final List<MenuCategory> categories;
  final Function(MenuItem) onAdd;

  const MenuSection({
    super.key,
    required this.title,
    required this.categories,
    required this.onAdd,
  });

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  int selectedCategory = 0;
  final ScrollController _categoryScrollController = ScrollController();

  void _scrollToCategory(int index) {
    const itemWidth = 120.0; // approximate width of one category chip
    final offset = itemWidth * index;

    _categoryScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.categories[selectedCategory];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Horizontal scrollable categories (fixed)
          SizedBox(
            height: 40,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                },
              ),
              child: ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.categories.length,
                itemBuilder: (_, index) {
                  final isSelected = index == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategory = index);
                      _scrollToCategory(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          widget.categories[index].categoryName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Items of selected category (vertical scroll)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cat.items.length,
            itemBuilder: (_, index) {
              final item = cat.items[index];
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text("€${item.price.toStringAsFixed(2)}"),
                  trailing: ElevatedButton(
                    onPressed: () => widget.onAdd(item),
                    child: const Text("Add"),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
