import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../analytics_dashboard/presentation/screens/dashboard_screen.dart';
import '../../../audit_trail/presentation/screens/audit_trail_screen.dart';
import '../../../customer_master/presentation/screens/customer_list_screen.dart';
import '../../../dispatch_packing/presentation/screens/dispatch_challan_list_screen.dart';
import '../../../dispatch_packing/presentation/screens/packing_list_screen.dart';
import '../../../job_card_master/presentation/screens/job_card_list_screen.dart';
import '../../../material_inventory/presentation/screens/job_reconciliation_screen.dart';
import '../../../material_inventory/presentation/screens/roll_list_screen.dart';
import '../../../order_intake/presentation/screens/order_list_screen.dart';
import '../../../product_master/presentation/screens/product_list_screen.dart';
import '../../../production/presentation/screens/production_pipeline_screen.dart';
import '../../../qc_management/presentation/screens/qc_dashboard_screen.dart';
import '../../../reports/presentation/screens/executive_reports_screen.dart';
import '../../../rm_ledger/presentation/screens/rm_ledger_screen.dart';
import '../../../shade_card_master/presentation/screens/shade_card_list_screen.dart';
import '../../../tooling_master/presentation/screens/die_list_screen.dart';
import '../../../tooling_master/presentation/screens/plate_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    ExecutiveReportsScreen(),
    OrderListScreen(),
    CustomerListScreen(),
    ProductListScreen(),
    JobCardListScreen(),
    PlateListScreen(),
    DieListScreen(),
    ProductionPipelineScreen(),
    RmLedgerScreen(),
    ShadeCardListScreen(),
    RollListScreen(),
    JobReconciliationScreen(),
    QCDashboardScreen(),
    PackingListScreen(),
    DispatchChallanListScreen(),
    AuditTrailScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: AppTheme.sidebarBg,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        backgroundColor: AppTheme.sidebarBg,
                        indicatorColor: AppTheme.primary,
                        selectedIconTheme: const IconThemeData(color: Colors.white, size: 22),
                        unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8), size: 20),
                        selectedLabelTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        unselectedLabelTextStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        labelType: NavigationRailLabelType.all,
                        leading: Column(
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withAlpha(100),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'FLEXORA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.analytics_outlined),
                            selectedIcon: Icon(Icons.analytics),
                            label: Text('Reports BI'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.receipt_long_outlined),
                            selectedIcon: Icon(Icons.receipt_long),
                            label: Text('Orders/PO'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.people_outline),
                            selectedIcon: Icon(Icons.people),
                            label: Text('Customers'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.inventory_2_outlined),
                            selectedIcon: Icon(Icons.inventory_2),
                            label: Text('Products/SKU'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.assignment_outlined),
                            selectedIcon: Icon(Icons.assignment),
                            label: Text('Job Cards'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.layers_outlined),
                            selectedIcon: Icon(Icons.layers),
                            label: Text('Plates'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.cut_outlined),
                            selectedIcon: Icon(Icons.cut),
                            label: Text('Dies/Punches'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.precision_manufacturing_outlined),
                            selectedIcon: Icon(Icons.precision_manufacturing),
                            label: Text('Production'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.swap_horizontal_circle_outlined),
                            selectedIcon: Icon(Icons.swap_horizontal_circle),
                            label: Text('RM Issue Ledger'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.palette_outlined),
                            selectedIcon: Icon(Icons.palette),
                            label: Text('Shade Cards'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.storage_outlined),
                            selectedIcon: Icon(Icons.storage),
                            label: Text('Stores Rolls'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.analytics_outlined),
                            selectedIcon: Icon(Icons.analytics),
                            label: Text('Reconciliation'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.fact_check_outlined),
                            selectedIcon: Icon(Icons.fact_check),
                            label: Text('QC & ISO'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.inventory_outlined),
                            selectedIcon: Icon(Icons.inventory),
                            label: Text('Packing Lists'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.local_shipping_outlined),
                            selectedIcon: Icon(Icons.local_shipping),
                            label: Text('Dispatch'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.history_outlined),
                            selectedIcon: Icon(Icons.history),
                            label: Text('Audit Trail'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.border),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
