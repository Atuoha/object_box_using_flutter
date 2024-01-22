import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:object_box/objectbox.g.dart';
import 'package:object_box/widgets/are_you_dialog.dart';
import 'package:object_box/widgets/toast_info.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import '../components/order_data_table.dart';
import 'package:path/path.dart' as path;
import '../constants/enums/status.dart';
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
  late Box<Receipt> box;

  @override
  void initState() {
    setNewCustomer();
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      store = Store(
        getObjectBoxModel(),
        directory: path.join(dir.path, 'objectbox'),
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
        box = store.box<Receipt>();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    store.close();
  }

  // set new customer
  void setNewCustomer() {
    customer = Customer(
      name: faker.person.name(),
      company: faker.company.name(),
    );

    if (kDebugMode) {
      print(faker.person.name());
      print(faker.company.name());
    }
  }

  // add  receipt
  void addNewData() {
    int amount = faker.randomGenerator.integer(1000, min: 10);
    receipt = Receipt(amount: amount);
    receipt.customer.target = customer;
    box.put(receipt);

    if (kDebugMode) {
      print('${faker.randomGenerator.integer(1000, min: 10)}');
      print(customer.name);
      print(customer.company);
    }
  }

  // delete  receipt dialog
  void handleRemoveReceiptDialog(int id) {
    areYouSureDialog(
      title: 'Remove Receipt',
      content: 'Are you sure you want to remove this receipt?',
      context: context,
      action: handleRemoveReceipt,
      isIdInvolved: true,
      id: id,
    );
  }

  // delete  receipt
  void handleRemoveReceipt(int id) {
    box.remove(id);
    Navigator.of(context).pop();
    toastInfo(
      msg: 'Receipt removed successfully',
      status: Status.success,
    );
  }

  // delete all receipts dialog
  void handleRemoveAllReceiptsDialog() {
    areYouSureDialog(
      title: 'Remove Receipts',
      content: 'Are you sure you want to remove all receipts?',
      context: context,
      action: handleRemoveAllReceipts,
    );
  }

  // delete all receipts
  void handleRemoveAllReceipts() {
    box.removeAll();
    Navigator.of(context).pop();
    toastInfo(
      msg: 'All receipts removed successfully',
      status: Status.success,
    );
  }

  void handleRemoveAllCustomerReceipts(List<int> ids) {
    box.removeMany(ids);
    Navigator.of(context).pop();
    toastInfo(
      msg: 'All Customer receipts removed successfully',
      status: Status.success,
    );
  }

  // show customer orders
  Future showCustomerOrders(Receipt receipt) {
    final List<Receipt> customerReceipts = receipt.customer.target!.orders
        .map(
          (receipt) => Receipt(
            amount: receipt.amount,
            id: receipt.id,
          ),
        )
        .toList();

    final List<int> ids =
        customerReceipts.map((receipt) => receipt.id).toList();

    print(ids);

    return showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All receipts by ${receipt.customer.target!.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => handleRemoveAllCustomerReceipts(ids),
                    icon: const Icon(
                      CupertinoIcons.delete,
                    ),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: customerReceipts.length,
                  itemBuilder: (context, index) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      child: const Icon(
                        CupertinoIcons.money_dollar_circle,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('\$${customerReceipts[index].amount}'),
                    subtitle: Text('Receipt id: ${customerReceipts[index].id}'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exploring ObjectBox'),
        actions: [
          IconButton(
            onPressed: () => setNewCustomer(),
            icon: const Icon(
              CupertinoIcons.person_add,
            ),
          ),
          IconButton(
            onPressed: () => addNewData(),
            icon: const Icon(
              CupertinoIcons.money_dollar,
            ),
          ),
          IconButton(
            onPressed: () => handleRemoveAllReceiptsDialog(),
            icon: const Icon(
              CupertinoIcons.delete,
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

          if (receipts.isEmpty) {
            return const Center(
              child: Text(
                'The receipt list is empty!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return OrderDataTable(
            onSort: (int columnIndex, bool ascending) {
              final newQueryBuilder = box.query();

              // sort field
              final field = columnIndex == 0 ? Receipt_.id : Receipt_.amount;

              // order
              newQueryBuilder.order(
                field,
                flags: ascending ? 0 : Order.descending,
              );

              // set stream
              setState(() {
                stream = newQueryBuilder
                    .watch(
                      triggerImmediately: true,
                    )
                    .map(
                      (query) => query.find(),
                    );
              });
            },
            receipts: receipts,
            handleRemoveReceiptDialog: handleRemoveReceiptDialog,
            showCustomerOrders: showCustomerOrders,
          );
        },
      ),
    );
  }
}
