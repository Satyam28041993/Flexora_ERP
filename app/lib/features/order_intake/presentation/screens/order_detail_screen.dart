import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/iso_control_header.dart';
import '../../data/models/order_model.dart';
import '../../logic/order_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(orderRepositoryProvider);

    return FutureBuilder<OrderModel?>(
      future: repo.getOrder(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final order = snapshot.data;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Purchase Order Detail')),
            body: const Center(child: Text('Purchase Order not found.')),
          );
        }

        final dateFormat = DateFormat('dd-MM-yyyy');

        return Scaffold(
          appBar: AppBar(
            title: Text('PO: ${order.poNumber}'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const ISOControlHeader(
                docTitle: 'PURCHASE ORDER INTAKE RECORD',
                docNo: 'PGPL/ORD/F-01',
                department: 'Sales & Commercial',
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.poNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary)),
                              Text('PO Date: ${dateFormat.format(order.poDate)}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentEmerald.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.accentEmerald),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentEmerald, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Customer / Buyer:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text('GSTIN: ${order.customerGstNo}', style: const TextStyle(fontSize: 12)),
                                Text('Address: ${order.shippingAddress}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Vendor / Converter:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const Text('Prakruti Graphics Pvt. Ltd.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const Text('Bhoidapada, Vasai East, Palghar 401208', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                Text('Payment Terms: ${order.paymentTermsDays} Days Credit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (order.attachmentFileName != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Attached PO Document:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                      Text(order.attachmentFileName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Viewing ${order.attachmentFileName}')),
                                  );
                                },
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('View Document'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Line Items Breakdown Table
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PO Itemized Breakdown (Multiple Labels)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      const Divider(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Sr. No.')),
                            DataColumn(label: Text('Label Name / Item Description')),
                            DataColumn(label: Text('HSN Code')),
                            DataColumn(label: Text('Qty (Pcs)')),
                            DataColumn(label: Text('Unit Rate (Rs.)')),
                            DataColumn(label: Text('Total Amount (Rs.)')),
                          ],
                          rows: order.lineItems.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item.itemNo.toString())),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if (item.labelDescription.isNotEmpty)
                                        Text(item.labelDescription, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ),
                                DataCell(Text(item.hsnCode)),
                                DataCell(Text(item.quantityPcs.toInt().toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text('₹${item.unitRateRs.toStringAsFixed(2)}')),
                                DataCell(Text('₹${item.lineAmountRs.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Financial Summary Table
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Financial Summary Breakdown (Rs.)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      const Divider(height: 20),
                      _buildRow('Taxable Subtotal', '₹${order.taxableSubtotal.toStringAsFixed(2)}'),
                      if (order.oneTimePunchCost > 0)
                        _buildRow('One-Time Punch / Development Cost', '₹${order.oneTimePunchCost.toStringAsFixed(2)}'),
                      if (order.freightCharges > 0)
                        _buildRow('Freight & Packing Charges', '₹${order.freightCharges.toStringAsFixed(2)}'),
                      _buildRow('CGST (9%)', '₹${order.cgstAmount.toStringAsFixed(2)}'),
                      _buildRow('SGST (9%)', '₹${order.sgstAmount.toStringAsFixed(2)}'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GRAND TOTAL PAYABLE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('₹${order.grandTotalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.accentEmerald)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (order.specialNotes != null && order.specialNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PO Special Terms & Instructions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(height: 4),
                        Text(order.specialNotes!, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
