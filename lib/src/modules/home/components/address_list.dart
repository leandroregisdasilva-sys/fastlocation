import 'package:flutter/material.dart';

import '../../../shared/components/address_tile.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

class AddressList extends StatelessWidget {
  const AddressList({
    super.key,
    required this.addresses,
    required this.onSelect,
  });

  final List<AddressModel> addresses;
  final ValueChanged<AddressModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppMetrics.spacingSm),
      itemBuilder: (_, index) {
        final address = addresses[index];
        return AddressTile(address: address, onTap: () => onSelect(address));
      },
    );
  }
}
