import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'add_item.dart';
import 'item_details.dart';

class ProductListScreen extends StatefulWidget {
  final Item item;

  ProductListScreen({required this.item});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Item> _itemList;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');
    if (itemListJson != null) {
      final List<dynamic> decoded = jsonDecode(itemListJson);
      setState(() {
        _itemList = decoded.map((json) => Item.fromJson(json)).toList();
      });
    } else {
      _itemList = [];
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = jsonEncode(_itemList.map((item) => item.toJson()).toList());
    prefs.setString('itemList', itemListJson);
  }

  void _updateItemInList(Item updatedItem) {
    setState(() {
      final index = _itemList.indexWhere((item) => item.title == updatedItem.title);
      if (index != -1) {
        _itemList[index] = updatedItem;
      }
      _saveItems();
    });
  }

  void _deleteItemFromList(Item itemToDelete) {
    setState(() {
      _itemList.removeWhere((item) => item.title == itemToDelete.title);
      _saveItems();
    });
  }

  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          onAddItem: (String itemName, double itemPrice, int quantity) {
            setState(() {
              bool itemExists = false;
              for (var existingItem in widget.item.items) {
                if (existingItem.name == itemName) {
                  existingItem.quantity += quantity;
                  itemExists = true;
                  break;
                }
              }
              if (!itemExists) {
                widget.item.items.add(
                  ItemDetail(
                    name: itemName,
                    quantity: quantity,
                    isChecked: false,
                    price: itemPrice,
                  ),
                );
              }
              _updateItemInList(widget.item);
            });
          },
          budget: widget.item.budget,
        ),
      ),
    );
  }

  void _navigateToEditItemScreen(int index, ItemDetail product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          onAddItem: (String newName, double newPrice, int newQuantity) {
            setState(() {
              widget.item.items[index] = ItemDetail(
                name: newName,
                price: newPrice,
                quantity: newQuantity,
                isChecked: product.isChecked,
              );
              _updateItemInList(widget.item);
            });
          },
          initialName: product.name,
          initialPrice: product.price,
          initialQuantity: product.quantity,
          budget: widget.item.budget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text('${widget.item.title}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: _navigateToAddItemScreen,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: widget.item.items.length,
                itemBuilder: (context, index) {
                  final product = widget.item.items[index];
                  return Dismissible(
                    key: Key(product.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        widget.item.items.removeAt(index);
                        _updateItemInList(widget.item);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${product.name} deleted")),
                      );
                    },
                    background: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: product.isChecked ? Colors.grey.shade200 : Colors.white,
                      child: ListTile(
                        leading: Checkbox(
                          value: product.isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              product.isChecked = value!;
                              _updateItemInList(widget.item);
                            });
                          },
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: product.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ₱${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                            Text(
                              'Cost: ₱${(product.price * product.quantity).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Qty: ${product.quantity}',
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                _navigateToEditItemScreen(index, product);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
