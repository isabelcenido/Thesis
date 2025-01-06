import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dummyItems.dart';
import 'searchBarIn.dart';
import 'package:intl/intl.dart';

class AddItemScreen extends StatefulWidget {
  final Function(String, double, int) onAddItem;
  final String? initialName;
  final double? initialPrice;
  final int? initialQuantity;
  final double budget;
  final Item? selectedItem;

  AddItemScreen({
    required this.onAddItem,
    this.initialName,
    this.initialPrice,
    this.initialQuantity,
    required this.budget,
    this.selectedItem,
  });

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  late TextEditingController _productController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();

    _productController = TextEditingController(text: widget.initialName ?? '');
    _priceController = TextEditingController(text: widget.initialPrice != null
        ? NumberFormat("#,##0.00").format(widget.initialPrice)
        : '');
    _quantityController = TextEditingController(text: widget.initialQuantity?.toString() ?? '');

    if (widget.selectedItem != null) {
      _productController.text = widget.selectedItem!.item_name!;
      _priceController.text = widget.selectedItem!.item_price.toString();
      _quantityController.text = '1';
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning!"),
          content: Text("Adding this item would exceed your set budget.\n\nWould you like to continue?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Yes", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: Colors.black,
                elevation: 6,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            TextButton(
              onPressed: () {
                double price = double.parse(_priceController.text.replaceAll(',', ''));
                int quantity = int.parse(_quantityController.text);
                widget.onAddItem(_productController.text, price, quantity);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("No", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: Colors.black,
                elevation: 6,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5BB7A6),
        title: Text(widget.initialName != null ? 'Edit Item' : 'Add New Item',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selectedItem = await Navigator.push<Item>(
                context,
                MaterialPageRoute(
                  builder: (context) => const Searchbar(),
                ),
              );
              if (selectedItem != null) {
                setState(() {
                  _productController.text = selectedItem.item_name!;
                  _priceController.text = selectedItem.item_price.toString();
                  _quantityController.text = '1';
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: EdgeInsets.all(19.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _productController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (₱)',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,6}(\.\d{0,2})?')),
                      ],
                      onChanged: (value) {
                        if (value.length > 8) return;
                        if (value.isNotEmpty) {
                          String newValue = value.replaceAll(',', '');
                          double parsedValue = double.tryParse(newValue) ?? 0;
                          if (!newValue.contains('.')) {
                            _priceController.value = TextEditingValue(
                              text: NumberFormat("#,##0").format(parsedValue),
                              selection: TextSelection.collapsed(
                                offset: NumberFormat("#,##0").format(parsedValue).length,
                              ),
                            );
                          } else {
                            _priceController.value = TextEditingValue(
                              text: newValue,
                              selection: TextSelection.collapsed(offset: newValue.length),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_productController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty) {
                      double price = double.parse(_priceController.text.replaceAll(',', ''));
                      int quantity = int.parse(_quantityController.text);
                      double total = price * quantity;

                      if (total > widget.budget) {
                        _showWarningDialog();
                      } else {
                        widget.onAddItem(_productController.text, price, quantity);
                        Navigator.pop(context);
                      }
                    }
                  },
                    child: Text(
                      widget.initialName != null ? 'Save Changes' : 'Add Item',
                      style: TextStyle(color: Colors.white),
                    ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}