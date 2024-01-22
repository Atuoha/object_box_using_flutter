import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:object_box/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import '../components/order_data_table.dart';
import 'package:path/path.dart';

import '../model/receipt.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var faker = Faker();
  late Store store;
  bool isStoreInitialized = false;
  late Customer customer;
  late Receipt receipt;
  Stream<List<Receipt>>? stream;

  @override
  void initState() {
    setNewPerson();
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      store = Store(
        getObjectBoxModel(),
        directory: join(dir.path, 'objectbox'),
      );
      setState(() {
        stream = store
            .box<Receipt>()
            .query()
            .watch(
              triggerImmediately: true,
            )
            .map(
              (query) => query.find(),
            );
        isStoreInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    store.close();
  }

  void setNewPerson() {
    customer = Customer(
      name: faker.person.name(),
      company: faker.company.name(),
    );

    if (kDebugMode) {
      print(faker.person.name());
      print(faker.company.name());
    }
  }

  void addNewData() {
    int amount = faker.randomGenerator.integer(1000, min: 10);
    receipt = Receipt(amount: amount);
    receipt.customer.target = customer;
    final box = store.box<Receipt>();
    box.put(receipt);

    if (kDebugMode) {
      print('${faker.randomGenerator.integer(1000, min: 10)}');
      print(customer.name);
      print(customer.company);
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
      body: StreamBuilder<List<Receipt>>(
        stream: stream,
        builder: (context, snapshot) {
          final List<Receipt> receipts = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'An error occurred!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return snapshot.hasData
              ? OrderDataTable(
                  onSort: (int column, bool ascending) {
                    // Todo: implement this
                  },
                  receipts: receipts,
                )
              : const Center(
                  child: Text(
                    'The receipt list is empty!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
        },
      ),
    );
  }
}
