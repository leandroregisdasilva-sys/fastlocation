import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_loading.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../components/address_list.dart';
import '../components/empty_search.dart';
import '../components/last_address_card.dart';
import '../components/search_form.dart';
import '../controller/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});

  final HomeController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final ReactionDisposer _errorReactionDisposer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomeController();
    _errorReactionDisposer = reaction<String?>(
      (_) => _controller.errorMessage,
      _showError,
    );
    _controller.loadLastAddress();
  }

  @override
  void dispose() {
    _errorReactionDisposer();
    super.dispose();
  }

  void _showError(String? message) {
    if (message == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    _controller.clearError();
  }

  void _openSearch() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SearchForm(
            onSearchByCep: (cep) {
              Navigator.of(sheetContext).pop();
              _controller.searchByCep(cep);
            },
            onSearchByAddress: ({
              required String uf,
              required String city,
              required String street,
            }) {
              Navigator.of(sheetContext).pop();
              _controller.searchByAddress(uf: uf, city: city, street: street);
            },
          ),
        );
      },
    );
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).pushNamed(AppRoutes.history);
    _controller.loadLastAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastLocation'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Histórico de consultas',
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          final addresses = _controller.addresses.toList();
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(AppMetrics.spacingMd),
                children: [
                  LastAddressCard(
                    address: _controller.lastAddress,
                    onTraceRoute: _controller.traceRoute,
                  ),
                  const SizedBox(height: AppMetrics.spacingLg),
                  const Text(
                    'Endereços consultados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.spacingSm),
                  if (addresses.isEmpty)
                    EmptySearch(hasSearched: _controller.hasSearched)
                  else ...[
                    if (addresses.length > 1)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppMetrics.spacingSm),
                        child: Text(
                          'Toque no endereço correto para selecioná-lo.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    AddressList(
                      addresses: addresses,
                      onSelect: _controller.selectAddress,
                    ),
                  ],
                ],
              ),
              if (_controller.isLoading) const AppLoading(),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.spacingMd),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Histórico',
                  icon: Icons.history,
                  outlined: true,
                  onPressed: _openHistory,
                ),
              ),
              const SizedBox(width: AppMetrics.spacingMd),
              Expanded(
                child: AppButton(
                  label: 'Nova consulta',
                  icon: Icons.search,
                  onPressed: _openSearch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
