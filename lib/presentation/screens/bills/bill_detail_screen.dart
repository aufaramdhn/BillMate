import 'package:flutter/material.dart';

import '../../blocs/bills/bills_bloc.dart';

class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({
    super.key,
    required this.bloc,
    required this.billId,
  });

  final BillsBloc bloc;
  final String billId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bloc,
      builder: (context, _) {
        final bill = bloc.findById(billId);
        if (bill == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Tagihan')),
            body: const Center(child: Text('Tagihan tidak ditemukan.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Detail Tagihan')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _detailItem('Judul', bill.title),
              _detailItem('Kategori', bill.category.name),
              _detailItem('Nominal', 'Rp${bill.amount.toStringAsFixed(0)}'),
              _detailItem('Jatuh Tempo', _formatDate(bill.dueDate)),
              _detailItem('Status', bill.isPaid ? 'Lunas' : 'Belum Lunas'),
              _detailItem('Recurring', bill.isRecurring ? 'Ya' : 'Tidak'),
              if (bill.recurrenceInterval != null)
                _detailItem('Interval', bill.recurrenceInterval!.name),
              if (bill.notes != null && bill.notes!.isNotEmpty)
                _detailItem('Catatan', bill.notes!),
              const SizedBox(height: 24),
              if (!bill.isPaid)
                FilledButton(
                  onPressed: () async {
                    await bloc.markAsPaid(bill.id);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tagihan ditandai lunas.')),
                    );
                  },
                  child: const Text('Tandai Lunas'),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await bloc.deleteBill(bill.id);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Hapus Tagihan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
