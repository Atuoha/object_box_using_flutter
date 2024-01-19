import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../components/order_data_table.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var faker = Faker();

  @override
  void initState() {
    setNewPerson();
    super.initState();
  }

  void setNewPerson() {
    if (kDebugMode) {
      print(faker.person.name());
    }
  }

  void addNewData() {
    if (kDebugMode) {
      print('${faker.randomGenerator.integer(1000, min: 10)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exploring ObjectBox'),
        actions: [
          IconButton(
            onPressed: () => setNewPerson(),
            icon: const Icon(
              CupertinoIcons.person_add,
            ),
          ),
          IconButton(
            onPressed: () => addNewData(),
            icon: const Icon(
              CupertinoIcons.money_dollar,
            ),
          )
        ],
      ),
      body: OrderDataTable(
        onSort: (int column, bool ascending) {
          // Todo: implement this
        },
      ),
    );
  }
}
