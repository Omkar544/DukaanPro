import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../database/db_helper.dart';

class PDFStatementGenerator {
  static Future<String> generateDailyReport() async {
    final db = DBHelper();
    final shop = await db.getShopDetails();
    final sales = await db.getTodayTransactions();
    final expenses = await db.getTodayExpenses();
    
    final pdf = pw.Document();
    
    // Aggregation Logic lines
    double totalSales = sales.fold(0.0, (sum, item) => sum + (item['totalAmount'] as double));
    double totalExpenses = expenses.fold(0.0, (sum, item) => sum + (item['amount'] as double));
    double netProfitLoss = totalSales - totalExpenses;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            cross pw.CrossAxisAlignment.start,
            children: [
              // Header branding setup
              pw.Text(shop?['shopName'] ?? "DukaanPro Store", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text("Owner: ${shop?['ownerName'] ?? 'N/A'} | Contact: ${shop?['phone'] ?? 'N/A'}"),
              pw.Text("Address: ${shop?['address'] ?? 'N/A'}"),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              
              pw.Text("Daily Operational Statement Ledger", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              // Financial Summary Table Structure
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Operational Vector Metric', 'Value Parameters (₹)'],
                  <String>['Gross Customer Account Sales', totalSales.toStringAsFixed(2)],
                  <String>['Total Operational Procurement Costs', totalExpenses.toStringAsFixed(2)],
                  <String>[netProfitLoss >= 0 ? 'Net Net Profit Margins' : 'Net Cash Deficit Loss', netProfitLoss.toStringAsFixed(2)],
                ],
              ),
              
              pw.SizedBox(height: 30),
              pw.Text("Generated securely via DukaanPro internal auditing systems.", style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10))
            ],
          );
        },
      ),
    );

    final outputDir = await getExternalStorageDirectory();
    final file = File("${outputDir!.path}/DukaanPro_AuditStatement.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}