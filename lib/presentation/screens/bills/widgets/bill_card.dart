import 'package:flutter/material.dart';

import '../../../../domain/entities/bill_entity.dart';

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onMarkPaid,
    this.onDelete,
  });

  final BillEntity bill;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dueDateText = _dateLabel(bill.dueDate);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      bill.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    label: Text(bill.isPaid ? 'Lunas' : 'Belum Lunas'),
                    backgroundColor: bill.isPaid
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Kategori: ${bill.category.name}'),
              const SizedBox(height: 4),
              Text('Nominal: Rp${bill.amount.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              Text('Jatuh tempo: $dueDateText'),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  if (!bill.isPaid)
                    ElevatedButton(
                      onPressed: onMarkPaid,
                      child: const Text('Tandai Lunas'),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Hapus',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
