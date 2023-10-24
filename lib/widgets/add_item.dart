import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddNewItem extends StatefulWidget {
  const AddNewItem({super.key});

  @override
  State<AddNewItem> createState() {
    return _AddItemState();
  }
}

class _AddItemState extends State<AddNewItem> {
  final _formKey = GlobalKey<FormState>();
  var _groceryName = '';
  var _groceryQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  bool isSending = false;

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.https(
          'fir-5a202-default-rtdb.firebaseio.com', 'shopping-list.json');

      setState(() {
        isSending = true;
      });

      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(
          {
            'name': _groceryName,
            'quantity': _groceryQuantity,
            'category': _selectedCategory.title
          },
        ),
      );

      final responseData = jsonDecode(response.body);

      // if widget is still avaible or not.
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(GroceryItem(
          id: responseData['name'],
          name: _groceryName,
          quantity: _groceryQuantity,
          category: _selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Title')),
                validator: (value) {
                  if (value == null || value.trim().length <= 1) {
                    return 'Must Enter Valid Entry';
                  }
                  _groceryName = value;
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      decoration:
                          const InputDecoration(label: Text('Quantity')),
                      validator: (value) {
                        if (value == null ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must Add Valid Positive Numbers';
                        }
                        _groceryQuantity = int.parse(value);
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: isSending ? null : _onSave,
                    child: isSending
                        ? const SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
