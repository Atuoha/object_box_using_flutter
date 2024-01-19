import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderDataTable extends StatefulWidget {
  const OrderDataTable({super.key, required this.onSort});

  final void Function(int column, bool ascending) onSort;

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
              label: const Text('No'),
              onSort: _onDataColumnSort,
            ),
            DataColumn(
              label: const Text('Customer'),
              onSort: _onDataColumnSort,
            ),
            DataColumn(
              label: const Text('Price'),
              onSort: _onDataColumnSort,
            ),
            const DataColumn(
              label: Icon(CupertinoIcons.delete),
            ),
          ],
          rows: [
            DataRow(
              cells: [
                const DataCell(Text('ID')),
                DataCell(const Text('CUSTOMER NAME'), onTap: () {
                  // Todo: implement this
                }),
                const DataCell(Text('\$PRICE')),
                DataCell(const Icon(CupertinoIcons.delete), onTap: () {
                  // Todo: implement this
                }),
              ],
            )
          ],
        ),
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
