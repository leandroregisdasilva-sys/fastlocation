import 'package:flutter/material.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

class LastAddressCard extends StatelessWidget {
  const LastAddressCard({
    super.key,
    required this.address,
    required this.onTraceRoute,
  });

  final AddressModel? address;
  final VoidCallback onTraceRoute;

  @override
  Widget build(BuildContext context) {
    final lastAddress = address;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppMetrics.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_toggle_off,
                color: AppColors.onPrimary,
                size: AppMetrics.iconSm,
              ),
              SizedBox(width: AppMetrics.spacingSm),
              Text(
                'Último endereço consultado',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppMetrics.spacingMd),
          if (lastAddress == null)
            const Text(
              'Nenhum endereço consultado ainda.',
              style: TextStyle(color: AppColors.onPrimary),
            )
          else ...[
            Text(
              lastAddress.streetLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.spacingXs),
            Text(
              lastAddress.districtAndCity,
              style: const TextStyle(color: AppColors.onPrimary),
            ),
            const SizedBox(height: AppMetrics.spacingXs),
            Text(
              'CEP ${lastAddress.cep}',
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppMetrics.spacingMd),
            SizedBox(
              width: double.infinity,
              height: AppMetrics.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: onTraceRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppMetrics.radius),
                  ),
                ),
                icon: const Icon(Icons.directions),
                label: const Text('Traçar rota'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
