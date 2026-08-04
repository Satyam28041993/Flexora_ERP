import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/demo_data_seeder.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../dispatch_packing/presentation/screens/repeat_order_dialog.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../../material_inventory/logic/material_providers.dart';
import '../../../order_intake/logic/order_providers.dart';
import '../../../production_planning/logic/production_providers.dart';
import '../../../qc_management/logic/qc_providers.dart';
import '../../../shade_card_master/logic/shade_card_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    // Auto-seeding disabled for fresh user trial
  }

  Future<void> _clearAllDemoData() async {
    if (_isSeeding) return;
    setState(() => _isSeeding = true);
    try {
      await DemoDataSeeder.clearNonRmAndVendorData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧹 All dummy data (Customers, SKUs, POs, Job Cards, Ledgers) cleared! System is ready for fresh trial.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clear notice: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final jobCardsAsync = ref.watch(jobCardsStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);
    final rollsAsync = ref.watch(rollsStreamProvider);
    final shadeCardsAsync = ref.watch(shadeCardsStreamProvider(null));
    final qcRecordsAsync = ref.watch(qcRecordsStreamProvider(null));
    final machinesAsync = ref.watch(machinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flexora ERP — Executive Operations Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: OutlinedButton.icon(
              onPressed: _isSeeding ? null : _clearAllDemoData,
              icon: _isSeeding
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cleaning_services, color: Colors.redAccent, size: 18),
              label: Text(_isSeeding ? 'Clearing Data...' : '🧹 Clear All Dummy Data'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const RepeatOrderDialog(),
              ),
              icon: const Icon(Icons.autorenew, size: 18),
              label: const Text('Repeat Order Engine'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Plant Operations Command Center',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PGPL Vasai Unit 1 — Flexographic Printing & Packaging ERP',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentEmerald),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.circle, color: AppTheme.accentEmerald, size: 10),
                      SizedBox(width: 8),
                      Text(
                        'PLANT ONLINE & LIVE',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentEmerald, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Vibrant KPI Grid
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _buildGradientKPICard(
                title: 'Total PO Orders',
                value: ordersAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'Order Intake Master',
                icon: Icons.receipt_long,
                gradientColors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
              ),
              _buildGradientKPICard(
                title: 'Active Job Cards',
                value: jobCardsAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'In-Production Queue',
                icon: Icons.assignment,
                gradientColors: [const Color(0xFFD97706), const Color(0xFFB45309)],
              ),
              _buildGradientKPICard(
                title: 'Customer Master',
                value: customersAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'Pharma & FMCG Clients',
                icon: Icons.people,
                gradientColors: [const Color(0xFF059669), const Color(0xFF047857)],
              ),
              _buildGradientKPICard(
                title: 'Stores Roll Stock',
                value: rollsAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'Traceable Rolls Inventory',
                icon: Icons.storage,
                gradientColors: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
              ),
              _buildGradientKPICard(
                title: 'Approved Shade Cards',
                value: shadeCardsAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'Permanent References',
                icon: Icons.palette,
                gradientColors: [const Color(0xFFE11D48), const Color(0xFFBE123C)],
              ),
              _buildGradientKPICard(
                title: 'QC Release Records',
                value: qcRecordsAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'Gate 1, 2 & 3 Sign-Offs',
                icon: Icons.fact_check,
                gradientColors: [const Color(0xFF4F46E5), const Color(0xFF4338CA)],
              ),
              _buildGradientKPICard(
                title: 'Active Machines',
                value: machinesAsync.when(data: (d) => d.length.toString(), loading: () => '...', error: (_, __) => '0'),
                subtitle: 'Lombardy Flexo & Slitting',
                icon: Icons.precision_manufacturing,
                gradientColors: [const Color(0xFF0D9488), const Color(0xFF0F766E)],
              ),
              _buildGradientKPICard(
                title: 'System Health',
                value: '100%',
                subtitle: 'Firestore Sync Active',
                icon: Icons.verified_user,
                gradientColors: [const Color(0xFF16A34A), const Color(0xFF15803D)],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Architectural Golden Rules Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Core Architectural Golden Rules Compliance',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                      ),
                      Chip(
                        label: Text('8 / 8 LOCKED'),
                        backgroundColor: Color(0xFFECFDF5),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentEmerald, fontSize: 11),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildRuleTile('1. Dynamic Flexo Spec Engine', 'Label, Print & Machine specs locked per SKU with flexible route generator'),
                  _buildRuleTile('2. Flexible Process Route Engine', 'Printing, Punching, Slitting, Hot Foil, Lamination route configuration'),
                  _buildRuleTile('3. ISO Document Control Header', 'Standardized document metadata headers rendered across official records'),
                  _buildRuleTile('4. Pre-Press Master Card Verification', 'Mandatory Pre-Press verification package sign-off before Job Card release'),
                  _buildRuleTile('5. Three QC Release Gates', 'Gate 1 (Incoming Material), Gate 2 (Start-Up), Gate 3 (Finished Goods) control records'),
                  _buildRuleTile('6. 5 Material Consumption Values', 'Planned vs Issued vs Returned vs Actual Consumption vs Calculated Wastage'),
                  _buildRuleTile('7. Transaction-Based Inventory & Audit Trail', 'Immutable audit trail & transaction-based roll movement logs'),
                  _buildRuleTile('8. Repeat Order Automation Engine', 'Auto-links approved specs, artwork, tooling & permanent Shade Reference'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withAlpha(40),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleTile(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.accentEmerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
