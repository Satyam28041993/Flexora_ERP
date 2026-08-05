import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../analytics_dashboard/presentation/screens/dashboard_screen.dart';
import '../../../audit_trail/presentation/screens/audit_trail_screen.dart';
import '../../../customer_master/presentation/screens/customer_feedback_capa_screen.dart';
import '../../../customer_master/presentation/screens/customer_list_screen.dart';
import '../../../dispatch_packing/presentation/screens/dispatch_challan_list_screen.dart';
import '../../../dispatch_packing/presentation/screens/packing_list_screen.dart';
import '../../../job_card_master/presentation/screens/job_card_list_screen.dart';
import '../../../material_inventory/presentation/screens/job_reconciliation_screen.dart';
import '../../../material_inventory/presentation/screens/roll_list_screen.dart';
import '../../../material_inventory/presentation/screens/supplier_registration_screen.dart';
import '../../../order_intake/presentation/screens/order_list_screen.dart';
import '../../../product_master/presentation/screens/product_list_screen.dart';
import '../../../production/presentation/screens/production_pipeline_screen.dart';
import '../../../production_planning/presentation/screens/production_schedule_screen.dart';
import '../../../qc_management/presentation/screens/qc_calibration_screen.dart';
import '../../../qc_management/presentation/screens/qc_dashboard_screen.dart';
import '../../../reports/presentation/screens/executive_reports_screen.dart';
import '../../../rm_ledger/presentation/screens/rm_ledger_screen.dart';
import '../../../shade_card_master/presentation/screens/shade_card_list_screen.dart';
import '../../../tooling_master/presentation/screens/die_list_screen.dart';
import '../../../tooling_master/presentation/screens/maintenance_logs_screen.dart';
import '../../../tooling_master/presentation/screens/plate_list_screen.dart';
import '../screens/employee_training_screen.dart';

/// A single navigable destination in the sidebar.
@immutable
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function() builder;
}

/// A collapsible group of related destinations.
@immutable
class NavGroup {
  const NavGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;

  /// Accent used for the group header and the active-item highlight, so each
  /// area of the factory is visually distinguishable at a glance.
  final Color color;
  final List<NavItem> items;
}

/// Sidebar structure, ordered to follow the real shop-floor flow recorded in
/// `New Order Detail and Status Tracking.xlsx`:
/// Order -> Pre-Press -> Materials -> Production -> QC -> Dispatch.
class AppNavigation {
  AppNavigation._();

  static const List<NavGroup> groups = [
    NavGroup(
      title: 'Overview',
      icon: Icons.dashboard_outlined,
      color: AppTheme.primary,
      items: [
        NavItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          builder: DashboardScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Sales & Orders',
      icon: Icons.storefront_outlined,
      color: AppTheme.accentBlue,
      items: [
        NavItem(
          label: 'Orders / PO',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          builder: OrderListScreen.new,
        ),
        NavItem(
          label: 'Customers',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          builder: CustomerListScreen.new,
        ),
        NavItem(
          label: 'Products / SKU',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          builder: ProductListScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Pre-Press & Tooling',
      icon: Icons.design_services_outlined,
      color: AppTheme.accentTeal,
      items: [
        NavItem(
          label: 'Job Cards',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          builder: JobCardListScreen.new,
        ),
        NavItem(
          label: 'Plates',
          icon: Icons.layers_outlined,
          selectedIcon: Icons.layers,
          builder: PlateListScreen.new,
        ),
        NavItem(
          label: 'Dies / Punches',
          icon: Icons.cut_outlined,
          selectedIcon: Icons.cut,
          builder: DieListScreen.new,
        ),
        NavItem(
          label: 'Shade Cards',
          icon: Icons.palette_outlined,
          selectedIcon: Icons.palette,
          builder: ShadeCardListScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Materials & Stores',
      icon: Icons.warehouse_outlined,
      color: AppTheme.accentPurple,
      items: [
        // Named to make the distinction obvious: this screen tracks individual
        // physical rolls by Roll ID, whereas RM Stock & Ledger below tracks
        // material-wise quantities (supplier / material / GSM / width).
        NavItem(
          label: 'RM Stock & Ledger',
          icon: Icons.swap_horizontal_circle_outlined,
          selectedIcon: Icons.swap_horizontal_circle,
          builder: RmLedgerScreen.new,
        ),
        NavItem(
          label: 'Roll Inventory (Roll-wise)',
          icon: Icons.storage_outlined,
          selectedIcon: Icons.storage,
          builder: RollListScreen.new,
        ),
        NavItem(
          label: 'Reconciliation',
          icon: Icons.rule_outlined,
          selectedIcon: Icons.rule,
          builder: JobReconciliationScreen.new,
        ),
        // Relocated out of Reports -> ISO Master Center, where it was unfindable.
        NavItem(
          label: 'Suppliers',
          icon: Icons.local_shipping_outlined,
          selectedIcon: Icons.local_shipping,
          builder: SupplierRegistrationScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Production',
      icon: Icons.precision_manufacturing_outlined,
      color: AppTheme.accentAmber,
      items: [
        NavItem(
          label: 'Production Pipeline',
          icon: Icons.precision_manufacturing_outlined,
          selectedIcon: Icons.precision_manufacturing,
          builder: ProductionPipelineScreen.new,
        ),
        // Previously unreachable: this is the only screen that captures
        // operator run data (Total RMT Run, setup/running waste, downtime).
        NavItem(
          label: 'Machine Queue & Logs',
          icon: Icons.queue_outlined,
          selectedIcon: Icons.queue,
          builder: ProductionScheduleScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Quality (QC & ISO)',
      icon: Icons.verified_outlined,
      color: AppTheme.accentIndigo,
      items: [
        NavItem(
          label: 'QC Dashboard',
          icon: Icons.fact_check_outlined,
          selectedIcon: Icons.fact_check,
          builder: QCDashboardScreen.new,
        ),
        // Both relocated out of Reports -> ISO Master Center.
        NavItem(
          label: 'Calibration',
          icon: Icons.straighten_outlined,
          selectedIcon: Icons.straighten,
          builder: QcCalibrationScreen.new,
        ),
        NavItem(
          label: 'Feedback & CAPA',
          icon: Icons.rate_review_outlined,
          selectedIcon: Icons.rate_review,
          builder: CustomerFeedbackCapaScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Dispatch',
      icon: Icons.local_shipping_outlined,
      color: AppTheme.accentEmerald,
      items: [
        NavItem(
          label: 'Packing Lists',
          icon: Icons.inventory_outlined,
          selectedIcon: Icons.inventory,
          builder: PackingListScreen.new,
        ),
        NavItem(
          label: 'Dispatch Challans',
          icon: Icons.local_shipping_outlined,
          selectedIcon: Icons.local_shipping,
          builder: DispatchChallanListScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Maintenance & HR',
      icon: Icons.build_circle_outlined,
      color: AppTheme.accentRose,
      items: [
        // Both relocated out of Reports -> ISO Master Center.
        NavItem(
          label: 'Maintenance Logs',
          icon: Icons.build_circle_outlined,
          selectedIcon: Icons.build_circle,
          builder: MaintenanceLogsScreen.new,
        ),
        NavItem(
          label: 'Employee Training',
          icon: Icons.school_outlined,
          selectedIcon: Icons.school,
          builder: EmployeeTrainingScreen.new,
        ),
      ],
    ),
    NavGroup(
      title: 'Reports & Audit',
      icon: Icons.analytics_outlined,
      color: AppTheme.textSecondary,
      items: [
        NavItem(
          label: 'Executive Reports',
          icon: Icons.analytics_outlined,
          selectedIcon: Icons.analytics,
          builder: ExecutiveReportsScreen.new,
        ),
        NavItem(
          label: 'Audit Trail',
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          builder: AuditTrailScreen.new,
        ),
      ],
    ),
  ];

  /// Flattened destinations, in sidebar order. The selected index used by the
  /// shell indexes into this list.
  static List<NavItem> get flatItems =>
      [for (final g in groups) ...g.items];

  /// Group index that owns [flatIndex].
  static int groupIndexOf(int flatIndex) {
    var i = 0;
    for (var g = 0; g < groups.length; g++) {
      final next = i + groups[g].items.length;
      if (flatIndex < next) return g;
      i = next;
    }
    return 0;
  }

  /// Flat index of the first item in [groupIndex].
  static int firstFlatIndexOf(int groupIndex) {
    var i = 0;
    for (var g = 0; g < groupIndex; g++) {
      i += groups[g].items.length;
    }
    return i;
  }
}
