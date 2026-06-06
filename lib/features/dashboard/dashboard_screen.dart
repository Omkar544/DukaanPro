import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper _dbHelper = DBHelper();
  Map<String, dynamic>? _shopProfile;

  @override
  void initState() {
    super.initState();
    _loadShopProfile();
  }

  // Fetches live onboarding configurations (Store Name, Logo Index, etc.)
  void _loadShopProfile() async {
    final profile = await _dbHelper.getShopDetails();
    setState(() => _shopProfile = profile);
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruct selected icon data dynamically from saved code points
    IconData shopLogoIcon = Icons.storefront_rounded;
    if (_shopProfile?['logoPath'] != null) {
      try {
        int codePoint = int.parse(_shopProfile!['logoPath']);
        shopLogoIcon = IconData(codePoint, fontFamily: 'MaterialIcons');
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "DukaanPro Workspace",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6A5ACD)),
            onPressed: () {
              _loadShopProfile();
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _dbHelper.getTodaySummary(),
        builder: (context, snapshot) {
          double sales = snapshot.data?['sales'] ?? 0.0;
          double expenses = snapshot.data?['expenses'] ?? 0.0;
          double netProfitLoss = sales - expenses;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 🏪 DYNAMIC SHOP PROFILE BRANDING HEADER ---
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20), // Fixed line
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(
                          0xFF6A5ACD,
                        ).withOpacity(0.1),
                        child: Icon(
                          shopLogoIcon,
                          size: 32,
                          color: const Color(0xFF6A5ACD),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _shopProfile?['shopName'] ??
                                  "Mahalaxmi Kirana Stores",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "📍 ${_shopProfile?['address'] ?? 'Jaysingpur'} | 📞 ${_shopProfile?['phone'] ?? '9876543210'}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 📊 FINANCIAL P&L SUMMARY CARDS ---
                const Text(
                  "Today's Profit & Loss Ledger",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        "Total Customer Sales",
                        "₹${sales.toStringAsFixed(2)}",
                        Colors.green,
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        "Wholesale & Expenses",
                        "₹${expenses.toStringAsFixed(2)}",
                        Colors.red,
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  netProfitLoss >= 0 ? "Net Profit Margin" : "Net Loss Deficit",
                  "₹${netProfitLoss.toStringAsFixed(2)}",
                  netProfitLoss >= 0
                      ? const Color(0xFF6A5ACD)
                      : Colors.redAccent,
                  netProfitLoss >= 0
                      ? Icons.account_balance_wallet
                      : Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 35),

                // --- ⚙️ QUICK MANAGEMENT OPERATIONS GRID ---
                const Text(
                  "Quick Management Operations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildNavTile(
                      context,
                      "Itemized Billing",
                      Icons.receipt_long,
                      Colors.amber.shade700,
                      '/customer-entry',
                    ),
                    _buildNavTile(
                      context,
                      "Wholesale Buy",
                      Icons.inventory_2_outlined,
                      Colors.teal,
                      '/expense',
                    ),
                    _buildNavTile(
                      context,
                      "P&L Audit Reports",
                      Icons.picture_as_pdf,
                      Colors.redAccent,
                      '/reports',
                    ),
                    _buildNavTile(
                      context,
                      "App Settings",
                      Icons.settings_applications,
                      Colors.blueGrey,
                      '/settings',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String money,
    Color accent,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 18, color: accent.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            money,
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route).then((_) {
        _loadShopProfile();
        setState(() {});
      }),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 26,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
