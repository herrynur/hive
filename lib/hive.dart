import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyHive extends StatefulWidget {
  const MyHive({Key? key}) : super(key: key);

  @override
  State<MyHive> createState() => _MyHiveState();
}

class _MyHiveState extends State<MyHive> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _cekitems = [];
  final _shoppingBox = Hive.box('nodeDB');
  bool ada = false;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final value = _shoppingBox.get(key);
      return {
        "key": key,
        "nodeid": value["nodeid"],
        "sisapakan": value['sisapakan'],
        "time": value['time']
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  void _checkItem(String cek) {
    final data = _shoppingBox.keys.map((key) {
      final value = _shoppingBox.get(key);
      return {
        "nodeid": value["nodeid"],
      };
    }).toList();

    setState(() {
      _cekitems = data.reversed.toList();
    });
    for (int a = 0; a < _cekitems.length; a++) {
      print(_cekitems[a].values.single);
      if (cek == _cekitems[a].values.single) {
        ada = true;
      } else {
        ada = false;
      }
    }
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _refreshItems();
  }

  Map<String, dynamic> _readItem(int key) {
    final item = _shoppingBox.get(key);
    return item;
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems();
  }

  // Delete a single item
  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An item has been deleted')));
  }

  final TextEditingController _nodeController = TextEditingController();
  final TextEditingController _sisaController = TextEditingController();

  void _showForm(BuildContext ctx, int? itemKey) {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['nodeid'] == itemKey);
      _nodeController.text = existingItem['nodeid'];
      _sisaController.text = existingItem['sisapakan'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nodeController,
                    decoration: const InputDecoration(hintText: 'Node Id'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _sisaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Sisa Pakan'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Save new item
                      _checkItem(_nodeController.text);
                      print(ada);
                      if (ada == false) {
                        print("masuk false");
                        _shoppingBox.put(int.parse(_nodeController.text), {
                          "nodeid": _nodeController.text.trim(),
                          "sisapakan": _sisaController.text.trim(),
                          "time": DateTime.now()
                        });
                        _refreshItems();
                      } else if (ada == true) {
                        print("masuk true");
                        _shoppingBox.put(int.parse(_nodeController.text), {
                          "nodeid": _nodeController.text.trim(),
                          "sisapakan": _sisaController.text.trim(),
                          "time": DateTime.now()
                        });
                        _refreshItems();
                      }
                      //  if (ada == false) {
                      //   print("masuk false");
                      //   _createItem({
                      //     "nodeid": _nodeController.text,
                      //     "sisapakan": _sisaController.text,
                      //     "time": DateTime.now()
                      //   });
                      // }
                      // else if (ada == true) {
                      //   print("masuk true");
                      //   _updateItem(int.parse(_nodeController.text), {
                      //     'nodeid': _nodeController.text.trim(),
                      //     'sisapakan': _sisaController.text.trim(),
                      //     "time": DateTime.now()
                      //   });
                      // }
                      _nodeController.text = '';
                      _sisaController.text = '';

                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: Text('Create New'),
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              // the list of items
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final currentItem = _items[index];
                return Card(
                  color: Colors.orange.shade100,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                      title: Text("Node :  ${currentItem['nodeid']}"),
                      subtitle: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(5),
                            child: Text(
                                "Sisa Pakan : ${currentItem['sisapakan'].toString()} gr"),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(5),
                            child: Text(
                                "Time : ${currentItem['time'].toString()} "),
                          )
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteItem(currentItem['key']),
                          ),
                        ],
                      )),
                );
              }),
      // Add new item button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
