import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/customer_model.dart';
import 'customer_form_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.companyName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Code: ${customer.customerCode}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                      ),
                      Chip(
                        label: Text(customer.status.toUpperCase()),
                        backgroundColor: customer.status == CustomerStatus.active
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        labelStyle: TextStyle(
                          color: customer.status == CustomerStatus.active
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customer.companyName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (customer.gstNo != null) ...[
                    const SizedBox(height: 8),
                    Text('GST No: ${customer.gstNo}', style: const TextStyle(fontSize: 14)),
                  ],
                  if (customer.panNo != null) ...[
                    const SizedBox(height: 4),
                    Text('PAN No: ${customer.panNo}', style: const TextStyle(fontSize: 14)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'Primary Contact Person',
            icon: Icons.person,
            children: [
              _buildDetailRow('Name', customer.primaryContact.name),
              if (customer.primaryContact.designation.isNotEmpty)
                _buildDetailRow('Designation', customer.primaryContact.designation),
              _buildDetailRow('Phone', customer.primaryContact.phone),
              if (customer.primaryContact.email.isNotEmpty)
                _buildDetailRow('Email', customer.primaryContact.email),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'Billing Address',
            icon: Icons.location_on,
            children: [
              Text(customer.billingAddress.fullAddress, style: const TextStyle(fontSize: 14)),
            ],
          ),
          if (customer.specialInstructions != null ||
              customer.packingRequirements != null ||
              customer.qcRequirements != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Customer Requirements & Instructions',
              icon: Icons.assignment_outlined,
              children: [
                if (customer.specialInstructions != null)
                  _buildDetailRow('Special Instructions', customer.specialInstructions!),
                if (customer.packingRequirements != null)
                  _buildDetailRow('Packing Requirements', customer.packingRequirements!),
                if (customer.qcRequirements != null)
                  _buildDetailRow('QC Requirements', customer.qcRequirements!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
