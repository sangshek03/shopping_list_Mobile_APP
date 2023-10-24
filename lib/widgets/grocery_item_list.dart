import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/models/category.dart';
// import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/add_item.dart';
import 'package:http/http.dart' as http;

class GroceryListItem extends StatefulWidget {
  const GroceryListItem({super.key});

  @override
  State<GroceryListItem> createState() => _GroceryListItemState();
}

class _GroceryListItemState extends State<GroceryListItem> {
  List<GroceryItem> grocery = [];
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'fir-5a202-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if (response.body == 'null') {
      setState(() {
        isloading = false;
      });
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    List<GroceryItem> tempData = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => item.value['category'] == element.value.title)
          .value;

      tempData.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }

    setState(() {
      grocery = tempData;
      isloading = false;
    });
  }

  void onAddItem() async {
    final item = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const AddNewItem(),
      ),
    );

    if (item == null) return;

    setState(() {
      grocery.add(item);
      isloading = false;
    });
  }

  void onDismiss(GroceryItem item) {
    final url = Uri.https('fir-5a202-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    http.delete(url);

    setState(() {
      grocery.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
        itemCount: grocery.length, //must added line
        itemBuilder: (cxt, idx) => Dismissible(
              background: Container(
                color: Colors.red,
              ),
              key: ValueKey(grocery[idx].id),
              onDismissed: (direction) {
                onDismiss(grocery[idx]);
              },
              child: ListTile(
                title: Text(grocery[idx].name),
                leading: Container(
                  height: 24,
                  width: 24,
                  color: grocery[idx].category.color,
                ),
                trailing: Text(grocery[idx].quantity.toString()),
              ),
            ));

    if (grocery.isEmpty) {
      content = const Center(
        child: Text(
          'No Item in Added Yet.',
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    if (isloading) {
      content = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Item List'),
        actions: [
          IconButton(onPressed: onAddItem, icon: const Icon(Icons.add))
        ],
      ),
      body: content,
    );
  }
}
