import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/address_tile.dart';
import '../../../shared/components/app_empty_state.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../controller/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.controller});

  final HistoryController? controller;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HistoryController();
    _controller.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de consultas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Observer(
        builder: (_) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (_controller.isEmpty) {
            return const Center(
              child: AppEmptyState(
                icon: Icons.history,
                title: 'Histórico vazio',
                message: 'Os endereços consultados aparecerão aqui.',
              ),
            );
          }
          final addresses = _controller.addresses.toList();
          return ListView.separated(
            padding: const EdgeInsets.all(AppMetrics.spacingMd),
            itemCount: addresses.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppMetrics.spacingSm),
            itemBuilder: (_, index) => AddressTile(address: addresses[index]),
          );
        },
      ),
    );
  }
}
