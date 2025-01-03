import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';


class KassaPage extends StatefulWidget {
  @override
  Kassa createState() => Kassa();
}
class Kassa extends State<KassaPage> {
  int? selectedRowId;
  List<Map<String, dynamic>> transactionData = [];
  List<Map<String, dynamic>> _valutaList = [];
  bool _isLoading = true;

  String? sortColumn; // Tracks the column to sort
  bool isAscending = true; // Tracks sorting order

  @override
  void initState() {
    super.initState();
    fetchTransactionsAndValutas();
  }

  Future<void> fetchTransactionsAndValutas() async {
    try {
      final transactionData = await ApiService.fetchTransactions();
      final valutas = await ApiService.fetchValutas();

      if (mounted) {
        setState(() {
          this.transactionData = transactionData;
          _valutaList = valutas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      }
    }
  }

  List<Map<String, dynamic>> calculateTransactionData() {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var valuta in _valutaList) {
      final currency = valuta['valuta'];
      groupedData[currency] = {
        'pokupka_total': 0.0,
        'pokupka_value': 0.0,
        'sold_total': 0.0,
        'sold_value': 0.0,
      };
    }

    for (var transaction in transactionData) {
      final currency = transaction['currency'];
      final quantity = double.tryParse(transaction['quantity'].toString()) ?? 0.0;
      final total = double.tryParse(transaction['total'].toString()) ?? 0.0;

      if (transaction['transaction_type'] == 'buy') {
        groupedData[currency]!['pokupka_total'] += quantity;
        groupedData[currency]!['pokupka_value'] += total;
      } else if (transaction['transaction_type'] == 'sell') {
        groupedData[currency]!['sold_total'] += quantity;
        groupedData[currency]!['sold_value'] += total;
      }
    }

    List<Map<String, dynamic>> formattedData = [];

    groupedData.forEach((currency, data) {
      final pokupka_avg = data['pokupka_total'] > 0
          ? data['pokupka_value'] / data['pokupka_total']
          : 0.0;
      final sold_avg = data['sold_total'] > 0
          ? data['sold_value'] / data['sold_total']
          : 0.0;
      final profit = sold_avg > pokupka_avg
          ? (sold_avg - pokupka_avg) * data['sold_total']
          : 0.0;

      formattedData.add({
        'valuta': currency,
        'pokupka_total': data['pokupka_value'],
        'pokupka_avg': pokupka_avg,
        'sold_total': data['sold_value'],
        'sold_avg': sold_avg,
        'profit': profit,
      });
    });

    // Apply sorting
    if (sortColumn != null) {
      formattedData.sort((a, b) {
        final aValue = a[sortColumn];
        final bValue = b[sortColumn];

        if (aValue is String && bValue is String) {
          return isAscending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return isAscending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }
        return 0;
      });
    }

    return formattedData;
  }

  void sortTable(String column) {
    setState(() {
      if (sortColumn == column) {
        isAscending = !isAscending; // Toggle sorting order
      } else {
        sortColumn = column; // Set new column to sort
        isAscending = true; // Default to ascending
      }
    });
  }
  final List<Map<String, String>> headers = [
  {'key': 'pokupka_total', 'label': 'Purchase Total'},
  {'key': 'pokupka_avg', 'label': 'Purchase Avg'},
  {'key': 'sold_total', 'label': 'Sold Total'},
  {'key': 'sold_avg', 'label': 'Sold Avg'},
  {'key': 'profit', 'label': 'Profit'},
];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('KASSA')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredTransactionData = calculateTransactionData();

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('KASSA'))),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 850,
          child: CustomScrollView(
            slivers: [
              // Sticky Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => sortTable('valuta'),
                        child: Container(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 100,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Valuta',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Icon(
                                isAscending && sortColumn == 'valuta'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // for (final header in [
                      //   'pokupka_total',
                      //   'pokupka_avg',
                      //   'sold_total',
                      //   'sold_avg',
                      //   'profit'
                      // ])
                      for (var header in headers)
                      GestureDetector(
                        onTap: () => sortTable(header['key']!),
                        child: Container(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 150,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(header['label']!, style: TextStyle(fontWeight: FontWeight.bold)),
                              Icon(
                                isAscending && sortColumn == header['key']
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              // Table Rows
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = filteredTransactionData[index];
                    return Row(
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8.0),
                          color: selectedRowId == index
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.transparent,
                          child: Text(data['valuta'] ?? ''),
                        ),
                        for (final key in [
                          'pokupka_total',
                          'pokupka_avg',
                          'sold_total',
                          'sold_avg',
                          'profit'
                        ])
                          Container(
                            width: 150,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(8.0),
                            color: selectedRowId == index
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                            child: Text(data[key]?.toStringAsFixed(2) ?? ''),
                          ),
                      ],
                    );
                  },
                  childCount: filteredTransactionData.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}   



