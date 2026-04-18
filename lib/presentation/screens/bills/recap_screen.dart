import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'package:billmate/blocs/bills_recap/bills_recap_bloc.dart';
import 'package:billmate/blocs/bills_recap/bills_recap_state.dart';
import 'package:billmate/components/empty_state.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<BillsRecapBloc>();
      bloc.loadCurrentMonthRecap();

      final now = DateTime.now();
      final startYear = now.year - 1;
      final startMonth = now.month;
      bloc.loadRecapHistory(
        startYear: startYear,
        startMonth: startMonth,
        endYear: now.year,
        endMonth: now.month,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Tagihan'),
        centerTitle: true,
      ),
      body: Consumer<BillsRecapBloc>(
        builder: (context, bloc, _) {
          return ListenableBuilder(
            listenable: bloc.state,
            builder: (context, _) {
              if (bloc.state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bloc.state.error != null) {
                return Center(
                  child: Text(
                    'Error: ${bloc.state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final currentRecap = bloc.state.currentMonthRecap;
              if (currentRecap == null) {
                return const EmptyState(
                  title: 'No Data',
                  description: 'Tidak ada data rekap untuk bulan ini',
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthSummary(currentRecap),
                    const SizedBox(height: 24),
                    _buildTrendChart(bloc.state.recapHistory),
                    const SizedBox(height: 24),
                    _buildCategoryChart(currentRecap),
                    const SizedBox(height: 24),
                    _buildDetailTable(currentRecap),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSummary(BillRecapMonth recap) {
    final monthName = _getMonthName(recap.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$monthName ${recap.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total',
                amount: recap.totalAmount,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Sudah Bayar',
                amount: recap.paidAmount,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Belum Bayar',
                amount: recap.unpaidAmount,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<BillRecapMonth> history) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = history.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.totalAmount,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tren 12 Bulan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              spots: spots,
              isCurved: true,
              isShowingMainGrid: true,
              isShowingDotIndicators: true,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
              titlesData: const FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _bottomTitleWidgets,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt() % 3) {
      case 0:
        text = 'M-11';
        break;
      case 1:
        text = 'M-5';
        break;
      default:
        text = 'M';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget _buildCategoryChart(BillRecapMonth recap) {
    if (recap.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.cyan,
    ];

    final sections = recap.categoryBreakdown.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: category.totalAmount,
        title: '${category.category.name}\nRp${category.totalAmount.toStringAsFixed(0)}',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 80,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Breakdown Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTable(BillRecapMonth recap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recap.categoryBreakdown.entries.map((entry) {
          final category = entry.value;
          final percentage = recap.totalAmount > 0
              ? (category.totalAmount / recap.totalAmount * 100).toStringAsFixed(1)
              : '0';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.category.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: Rp${category.totalAmount.toStringAsFixed(0)}'),
                    Text('(${category.count} tagihan)'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bayar: Rp${category.paidAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      'Belum: Rp${category.unpaidAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getMonthName(int month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return names[month - 1];
  }
}
