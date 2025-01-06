import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'pillar_chart.dart';
import 'app_localizations.dart';

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

  // Initialize groupedData from _valutaList
  for (var valuta in _valutaList) {
    final currency = valuta['valuta'];
    groupedData[currency] = {
      'pokupka_total': 0.0,
      'pokupka_value': 0.0,
      'sold_total': 0.0,
      'sold_value': 0.0,
    };
  }

  // Process transactionData
  for (var transaction in transactionData) {
    final currency = transaction['currency'];
    final quantity = double.tryParse(transaction['quantity'].toString()) ?? 0.0;
    final total = double.tryParse(transaction['total'].toString()) ?? 0.0;

    // Ensure the currency exists in groupedData
    groupedData.putIfAbsent(currency, () => {
      'pokupka_total': 0.0,
      'pokupka_value': 0.0,
      'sold_total': 0.0,
      'sold_value': 0.0,
    });

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
        return isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
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



double calculateBoughtSoldDifference() {
  double boughtTotal = 0.0;
  double soldTotal = 0.0;

  for (var data in calculateTransactionData()) {
    boughtTotal += data['pokupka_total'] ?? 0.0;
    soldTotal += data['sold_total'] ?? 0.0;
  }

  return soldTotal - boughtTotal;
}


@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'cash')),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Opacity(
            opacity: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  final filteredTransactionData = calculateTransactionData();

  // Calculate total profit
  double totalProfit = 0.0;
  for (var data in filteredTransactionData) {
    totalProfit += data['profit'] ?? 0.0;
  }

String appBarTitle = AppLocalizations.of(context, 'cash');

// Initialize the list dynamically
final List<Map<String, String>> headers = [];

if (appBarTitle == 'Касса') {
  // Add items specifically for 'Касса'
  headers.add({'key': 'pokupka_total', 'label': 'Общее покупок'});
  headers.add({'key': 'pokupka_avg', 'label': 'Среднее покупок'});
  headers.add({'key': 'sold_total', 'label': 'Общее продано'});
  headers.add({'key': 'sold_avg', 'label': 'Среднее продано'});
  headers.add({'key': 'profit', 'label': 'Прибыль'});
} else {
  // Add items for the other case
  headers.add({'key': 'pokupka_total', 'label': 'Purchase Total'});
  headers.add({'key': 'pokupka_avg', 'label': 'Purchase Avg'});
  headers.add({'key': 'sold_total', 'label': 'Sold Total'});
  headers.add({'key': 'sold_avg', 'label': 'Sold Avg'});
  headers.add({'key': 'profit', 'label': 'Profit'});
}

  return Scaffold(
    appBar: AppBar(
      title: Text(
        appBarTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
          setState(() {
            selectedRowId = null;
          });
        },
      ),
      actions: [
        Opacity(
          opacity: 0,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {},
          ),
        ),
      ],
    ),
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
                            Text(AppLocalizations.of(context, 'currency'),
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
                              Text(header['label']!,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
bottomNavigationBar: BottomAppBar(
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Left section: Bought - Sold difference
          Row(
            children: [
              Text(
                AppLocalizations.of(context, 'soms'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
  '${calculateBoughtSoldDifference().toStringAsFixed(2)}',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: calculateBoughtSoldDifference() >= 0 ? Colors.blue : Colors.red,
  ),
)
            ],
          ),
          
          // Right section: Total Profit and statistics button
          Row(
            children: [
              SizedBox(width: 16), // Add spacing between sections
              Text(
                AppLocalizations.of(context, 'profitTot'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${totalProfit.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(width: 16), // Add spacing between sections
              IconButton(
                icon: Icon(Icons.bar_chart),
                onPressed: () {
                  // Navigate to the statistics page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatisticsPage(transactionData: transactionData)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
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



