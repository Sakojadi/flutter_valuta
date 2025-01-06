import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'app_localizations.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class StatisticsPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactionData;
  StatisticsPage({required this.transactionData});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> valutaList = [];
  String selectedType = "BOUGHT"; // Default to "BOUGHT"

  @override
  void initState() {
    super.initState();
    fetchValutas();
  }

  // Fetching the list of valutas
  Future<void> fetchValutas() async {
    try {
      final valutas = await ApiService.fetchValutas();
      setState(() {
        valutaList = valutas;
      });
    } catch (e) {
      print('Error fetching valutas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group transactions by currency and calculate the total quantity for both bought and sold
    Map<String, double> boughtQuantities = {};
    Map<String, double> soldQuantities = {};

    // Process transactions to calculate bought and sold quantities
    for (var transaction in widget.transactionData) {
      final currency = transaction['currency'];
      final quantity = double.tryParse(transaction['quantity'].toString()) ?? 0.0;
      final transactionType = transaction['transaction_type']; // 'buy' or 'sell'

      if (transactionType == 'buy') {
        boughtQuantities[currency] = (boughtQuantities[currency] ?? 0.0) + quantity;
      } else if (transactionType == 'sell') {
        soldQuantities[currency] = (soldQuantities[currency] ?? 0.0) + quantity;
      }
    }

    // Combine all currencies from valutaList to ensure we have all of them displayed
    Set<String> allCurrencies = {};
    for (var valuta in valutaList) {
      allCurrencies.add(valuta['valuta']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'curStat')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16), // Adjusted spacing
              _buildCurrencyChart(
                selectedType == "BOUGHT" ? boughtQuantities : soldQuantities, 
                selectedType, 
                allCurrencies
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomBarButton(
              label: AppLocalizations.of(context, 'bought'),
              isSelected: selectedType == "BOUGHT",
              onPressed: () {
                setState(() {
                  selectedType = "BOUGHT";
                });
              },
              color: Colors.red, // Green for "Bought"
            ),
            _buildBottomBarButton(
              label: AppLocalizations.of(context, 'sold'),
              isSelected: selectedType == "SOLD",
              onPressed: () {
                setState(() {
                  selectedType = "SOLD";
                });
              },
              color: Colors.green, // Red for "Sold"
            ),
          ],
        ),
      ),
    );
  }

  // Helper for BottomAppBar Buttons with color change and white text
  Widget _buildBottomBarButton({required String label, required bool isSelected, required VoidCallback onPressed, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isSelected ? color : Colors.black, // Solid color instead of gradient
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        child: Text(
          label, 
          style: TextStyle(fontSize: 16, color: Colors.white), // White text
        ),
      ),
    );
  }
Widget _buildCurrencyChart(Map<String, double> quantities, String type, Set<String> allCurrencies) {
  final List<ChartData> chartData = allCurrencies.map((currency) {
    return ChartData(
      currency,
      quantities[currency] ?? 0.0,
    );
  }).toList();

  // Fixed Y-axis range
  const int maxY = 100000;
  const int interval = 10000; // Increment of 10000
  final List<int> yLabels = List.generate((maxY ~/ interval) + 1, (index) => index * interval);

  return Container(
    height: MediaQuery.of(context).size.height * 0.7, // Chart height
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sticky Y-axis with precise alignment
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: yLabels.reversed.map((label) {
            return Container(
              height: (MediaQuery.of(context).size.height * 0.7 - 32) / yLabels.length,
              alignment: Alignment.bottomRight, // Align to bottom for tighter spacing
              child: Text(
                label.toString(),
                style: TextStyle(fontSize: 12, color: Colors.white), // Smaller font for tighter spacing
              ),
            );
          }).toList(),
        ),
        SizedBox(width: 8), // Spacing between Y-axis and chart
        // Scrollable Chart
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: allCurrencies.length * 100.0, // Adjust width based on the number of currencies
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  isVisible: true,
                  labelRotation: 45,
                  labelPlacement: LabelPlacement.onTicks,
                  labelIntersectAction: AxisLabelIntersectAction.wrap,
                  labelStyle: TextStyle(fontSize: 14),
                  // Dynamic color for the labels
                  axisLabelFormatter: (AxisLabelRenderDetails args) {
                    final ChartData data = chartData[args.value as int];
                    final isExceeding = data.y > maxY;
                    return ChartAxisLabel(
                      data.x,
                      TextStyle(
                        color: isExceeding ? Colors.red : Colors.white, // Red for exceeding values
                        fontSize: 12,
                      ),
                    );
                  },
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false, // Hide Y-axis as we provide custom labels
                  minimum: 0,
                  maximum: maxY.toDouble(),
                  interval: interval.toDouble(),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.top, // Places the legend on top
                  alignment: ChartAlignment.center, // Center-align the legend
                  textStyle: TextStyle(
                    fontSize: 14, // Adjust font size
                    color: Colors.white, // Change text color
                  ),
                  iconWidth: 12, // Customize icon width
                  iconHeight: 12, // Customize icon height
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                onLegendItemRender: (LegendRenderArgs args) {
                  // Change icon color based on the legend name
                  if (args.text == "BOUGHT") {
                    args.color = Colors.red; // Red icon for "BOUGHT"
                  } else if (args.text == "SOLD") {
                    args.color = Colors.green; // Green icon for "SOLD"
                  }
                },
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    name: type, 
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    // Pillar color based on type
                    pointColorMapper: (ChartData data, _) {
                      return type == "BOUGHT" ? Colors.red : Colors.green;
                    },
                    width: 0.6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
