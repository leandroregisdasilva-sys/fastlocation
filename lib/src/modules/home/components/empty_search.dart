import 'package:flutter/material.dart';

import '../../../shared/components/app_empty_state.dart';

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key, required this.hasSearched});

  final bool hasSearched;

  @override
  Widget build(BuildContext context) {
    if (hasSearched) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: 'Nenhum endereço encontrado',
        message: 'Confira os dados informados e faça uma nova consulta.',
      );
    }
    return const AppEmptyState(
      icon: Icons.travel_explore,
      title: 'Nenhuma consulta realizada',
      message: 'Toque em "Nova consulta" para buscar por CEP ou por endereço.',
    );
  }
}
