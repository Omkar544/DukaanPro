import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'dart:convert';
import 'package:web/web.dart' as web; 
import 'package:fl_chart/fl_chart.dart'; 

import '../../database/db_helper.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final DBHelper _dbHelper = DBHelper();
  bool _isLoading = true;
  bool _isExporting = false;
  
  double _sales = 0.0;
  double _expenses = 0.0;
  double _netProfit = 0.0;

  // Real-time calculated state variables mapping live warehouse entries
  Map<String, double> _productQuantityMap = {}; 
  Map<String, double> _productRevenueMap = {};  
  List<FlSpot> _timelineSpots = [];

  @override
  void initState() {
    super.initState();
    _loadLiveWorkspaceData();
  }

  // --- 🔄 100% DYNAMIC WORKSPACE EXTRACTION AND CHART REDISTRIBUTION ---
  void _loadLiveWorkspaceData() async {
    setState(() => _isLoading = true);

    final summary = await _dbHelper.getTodaySummary();
    final transactions = await _dbHelper.getTodayTransactions();
    final itemizedBillingLogs = await _dbHelper.getTodaySalesItems();
    final expenseLogs = await _dbHelper.getTodayExpenses();

    Map<String, double> aggregatedQuantities = {};
    Map<String, double> aggregatedRevenues = {};
    List<FlSpot> computedSpots = [];
    
    double totalComputedSales = 0.0;
    double totalComputedExpenses = 0.0;

    // A. Parse overall transaction progression lines (X: Bill Count #, Y: Total Ticket Amount)
    if (transactions.isNotEmpty) {
      for (int i = 0; i < transactions.length; i++) {
        double amt = double.tryParse(transactions[i]['totalAmount']?.toString() ?? '0.0') ?? 0.0;
        totalComputedSales += amt;
        computedSpots.add(FlSpot((i + 1).toDouble(), amt));
      }
    }

    // B. FIXED: Iterates item by item to aggregate units over identical names dynamically
    if (itemizedBillingLogs.isNotEmpty) {
      for (var itemRow in itemizedBillingLogs) {
        String product = itemRow['product']?.toString() ?? 'General Stock';
        double qty = double.tryParse(itemRow['quantity']?.toString() ?? '0.0') ?? 0.0;
        double lineTotal = double.tryParse(itemRow['total']?.toString() ?? '0.0') ?? 0.0;

        aggregatedQuantities[product] = (aggregatedQuantities[product] ?? 0.0) + qty;
        aggregatedRevenues[product] = (aggregatedRevenues[product] ?? 0.0) + lineTotal;
      }
    }

    for (var record in expenseLogs) {
      totalComputedExpenses += double.tryParse(record['amount']?.toString() ?? '0.0') ?? 0.0;
    }

    setState(() {
      _sales = totalComputedSales == 0 ? (summary['sales'] ?? 0.0) : totalComputedSales;
      _expenses = totalComputedExpenses == 0 ? (summary['expenses'] ?? 0.0) : totalComputedExpenses;
      _netProfit = _sales - _expenses;
      _productQuantityMap = aggregatedQuantities;
      _productRevenueMap = aggregatedRevenues;
      _timelineSpots = computedSpots;
      _isLoading = false;
    });
  }

  // --- 📊 DYNAMIC SPREADSHEET LEDGER CONSOLIDATION EXPORT ---
  void _exportConsolidatedReport() async {
    if (_productQuantityMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No item registers detected today to pull an export sheet!"), backgroundColor: Colors.amber),
      );
      return;
    }

    setState(() => _isExporting = true);
    String csvData = "";

    try {
      csvData = "DUKAANPRO WORKSPACE - SMART CONSOLIDATED SALES REPORT\n";
      csvData += "Generated Date,${DateTime.now().toString().substring(0, 10)}\n\n";
      
      csvData += "DAILY FINANCIAL OVERVIEW METRICS\n";
      csvData += "Total Customer Sales Gross,₹${_sales.toStringAsFixed(2)}\n";
      csvData += "Wholesale & Operating Expenses,₹${_expenses.toStringAsFixed(2)}\n";
      csvData += "Net Take-Home Revenue Profit,₹${_netProfit.toStringAsFixed(2)}\n\n";

      csvData += "CONSOLIDATED PRODUCT STOCK DISPATCH DATA LOG\n";
      csvData += "Product Item Description,Aggregated Total Quantity Sold,Accumulated Total Income (INR)\n";

      // Dynamically outputs merged values directly into clean lines
      _productQuantityMap.forEach((productName, totalQty) {
        double revenue = _productRevenueMap[productName] ?? 0.0;
        csvData += "$productName,${totalQty.toStringAsFixed(1)},₹${revenue.toStringAsFixed(2)}\n";
      });

      if (kIsWeb) {
        final bytes = utf8.encode(csvData);
        final base64Content = base64Encode(bytes);
        final downloadUrl = "data:text/csv;base64,$base64Content";
        
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = downloadUrl;
        anchor.setAttribute("download", "DukaanPro_Live_Consolidated_Report_${DateTime.now().toString().substring(0, 10)}.csv");
        
        web.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dynamic sheet exported! Running totals consolidated cleanly."), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export operation failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasData = _productQuantityMap.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("BI Intelligence & Operational Reports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF6A5ACD),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Force Database Sync",
            onPressed: _loadLiveWorkspaceData,
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A5ACD)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 💳 HIGH-IMPACT METRICS KPI CARDS ---
                  Row(
                    children: [
                      Expanded(child: _buildKPICard("Gross Sales", "₹${_sales.toStringAsFixed(2)}", Colors.green, Icons.arrow_upward_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard("Expenses", "₹${_expenses.toStringAsFixed(2)}", Colors.redAccent, Icons.arrow_downward_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard("Net P&L", "₹${_netProfit.toStringAsFixed(2)}", const Color(0xFF6A5ACD), Icons.account_balance_wallet_rounded)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- 📊 FLEX CHART PANEL DISPLAYING CLEAN ALIGNMENTS ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 750;
                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: _buildChartContainer("Revenue Stream Comparison (Bar Chart)", SizedBox(height: 250, child: _buildBarChart())),
                          ),
                          if (isWide) const SizedBox(width: 16),
                          if (!isWide) const SizedBox(height: 16),
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: _buildChartContainer(
                              "Item Quantity Breakdown (Pie Chart)", 
                              SizedBox(
                                height: 250, 
                                child: hasData 
                                    ? _buildPieChart() 
                                    : const Center(child: Text("No items sold today. Create bills first!", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- 📈 LINE CHART ---
                  _buildChartContainer(
                    "Live Sales Velocity Path (Line Chart)", 
                    SizedBox(
                      height: 240, 
                      child: _timelineSpots.isNotEmpty
                          ? _buildLineChart()
                          : const Center(child: Text("Waiting for incoming checkout ledger lines...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportConsolidatedReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A5ACD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _isExporting 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.analytics_rounded, size: 22),
                        label: Text(_isExporting ? "Consolidating Dynamic Books..." : "Export Live Consolidated CSV"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChartContainer(String title, Widget chartWidget) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Divider(height: 20),
            const SizedBox(height: 14),
            chartWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String label, String value, Color themeColor, IconData representationIcon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: themeColor, width: 5)), color: Colors.white),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: themeColor.withOpacity(0.1), child: Icon(representationIcon, color: themeColor, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    double maxVal = _sales > _expenses ? _sales : _expenses;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxVal == 0 ? 100 : maxVal * 1.25,
        barTouchData: BarTouchData(enabled: true),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              reservedSize: 45,
              getTitlesWidget: (val, meta) => SideTitleWidget(
                axisSide: AxisSide.left,
                child: Text('₹${val.toInt()}', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            )
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val == 0) return const SideTitleWidget(axisSide: AxisSide.bottom, child: Text('Sales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green)));
                if (val == 1) return const SideTitleWidget(axisSide: AxisSide.bottom, child: Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.redAccent)));
                return const SizedBox();
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: _sales, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: _expenses, color: Colors.redAccent, width: 40, borderRadius: BorderRadius.circular(4))]),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    List<PieChartSectionData> sections = [];
    List<Color> colorPalette = [Colors.amber, Colors.blueAccent, Colors.deepPurple, Colors.teal, Colors.orangeAccent];
    int colorIndex = 0;

    _productQuantityMap.forEach((product, totalQty) {
      String displayName = product.length > 11 ? "${product.substring(0, 9)}..." : product;
      sections.add(
        PieChartSectionData(
          value: totalQty,
          title: '$displayName\n(${totalQty.toStringAsFixed(0)} Units)',
          color: colorPalette[colorIndex % colorPalette.length],
          radius: 55,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9, height: 1.2),
        ),
      );
      colorIndex++;
    });

    return PieChart(PieChartData(sectionsSpace: 3, centerSpaceRadius: 35, sections: sections));
  }

  Widget _buildLineChart() {
    double dynamicMaxY = _sales > 100 ? _sales * 1.2 : 100.0;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: true, horizontalInterval: 200, verticalInterval: 1),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        minX: 0.8, 
        maxX: _timelineSpots.length.toDouble() + 0.2, 
        minY: 0, 
        maxY: dynamicMaxY,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (val, meta) => SideTitleWidget(
                axisSide: AxisSide.left,
                child: Text('₹${val.toInt()}', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1.0, 
              getTitlesWidget: (val, meta) {
                if (val <= 0 || val > _timelineSpots.length) return const SizedBox();
                return SideTitleWidget(
                  axisSide: AxisSide.bottom,
                  child: Text('Bill ${val.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _timelineSpots,
            isCurved: false, 
            color: const Color(0xFF6A5ACD),
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF6A5ACD).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}