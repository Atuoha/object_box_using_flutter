import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/receipt.dart';

class OrderDataTable extends StatefulWidget {
  const OrderDataTable(
      {super.key, required this.onSort, required this.receipts});

  final void Function(int column, bool ascending) onSort;
  final List<Receipt> receipts;

  @override
  State<OrderDataTable> createState() => _OrderDataTableState();
}

class _OrderDataTableState extends State<OrderDataTable> {
  bool sortAscending = true;
  int sortColumnIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            columns: [
              DataColumn(
                label: const Text('ID'),
                onSort: _onDataColumnSort,
              ),
              DataColumn(
                label: const Text('Customer'),
                onSort: _onDataColumnSort,
              ),
              const DataColumn(
                label: Text('Company'),
              ),
              DataColumn(
                label: const Text('Price'),
                onSort: _onDataColumnSort,
              ),
              const DataColumn(
                label: Icon(CupertinoIcons.delete),
              ),
            ],
            rows: widget.receipts
                .map(
                  (receipt) => DataRow(
                    cells: [
                      DataCell(Text(receipt.id.toString())),
                      DataCell(Text(receipt.customer.target!.name), onTap: () {
                        // Todo: implement this
                      }),
                      DataCell(Text(receipt.customer.target!.company)),
                      DataCell(Text('\$${receipt.amount}')),
                      DataCell(const Icon(CupertinoIcons.delete), onTap: () {
                        // Todo: implement this
                      }),
                    ],
                  ),
                )
                .toList()),
      ),
    );
  }

  void _onDataColumnSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
    widget.onSort(columnIndex, ascending);
  }
}
