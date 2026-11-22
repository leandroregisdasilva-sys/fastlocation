import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/metrics/app_metrics.dart';

typedef AddressSearchCallback = void Function({
  required String uf,
  required String city,
  required String street,
});

class SearchForm extends StatefulWidget {
  const SearchForm({
    super.key,
    required this.onSearchByCep,
    required this.onSearchByAddress,
  });

  static const List<String> states = <String>[
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  final ValueChanged<String> onSearchByCep;
  final AddressSearchCallback onSearchByAddress;

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  bool _searchByCep = true;
  String? _uf;
  bool _ufMissing = false;

  @override
  void dispose() {
    _cepController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _changeMode(bool searchByCep) {
    setState(() {
      _searchByCep = searchByCep;
      _ufMissing = false;
    });
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_searchByCep) {
      if (isValid) {
        widget.onSearchByCep(_cepController.text);
      }
      return;
    }

    final uf = _uf;
    setState(() => _ufMissing = uf == null);
    if (!isValid || uf == null) {
      return;
    }
    widget.onSearchByAddress(
      uf: uf,
      city: _cityController.text,
      street: _streetController.text,
    );
  }

  String? _validateCep(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return 'Informe os 8 dígitos do CEP';
    }
    return null;
  }

  String? _validateText(String? value) {
    if ((value ?? '').trim().length < 3) {
      return 'Informe pelo menos 3 letras';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppMetrics.spacingLg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova consulta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.spacingMd),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    key: const Key('modeCep'),
                    label: const Center(child: Text('Por CEP')),
                    selected: _searchByCep,
                    onSelected: (_) => _changeMode(true),
                  ),
                ),
                const SizedBox(width: AppMetrics.spacingSm),
                Expanded(
                  child: ChoiceChip(
                    key: const Key('modeAddress'),
                    label: const Center(child: Text('Por endereço')),
                    selected: !_searchByCep,
                    onSelected: (_) => _changeMode(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppMetrics.spacingMd),
            if (_searchByCep) _buildCepField() else ..._buildAddressFields(),
            const SizedBox(height: AppMetrics.spacingLg),
            AppButton(
              key: const Key('submitSearch'),
              label: 'Consultar',
              icon: Icons.search,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCepField() {
    return TextFormField(
      key: const Key('cepField'),
      controller: _cepController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.search,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: const InputDecoration(
        labelText: 'CEP',
        hintText: 'Somente números',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pin_drop_outlined),
      ),
      validator: _validateCep,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  List<Widget> _buildAddressFields() {
    return [
      InputDecorator(
        decoration: InputDecoration(
          labelText: 'UF',
          border: const OutlineInputBorder(),
          errorText: _ufMissing ? 'Selecione a UF' : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppMetrics.spacingMd,
            vertical: AppMetrics.spacingXs,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: const Key('ufField'),
            value: _uf,
            isExpanded: true,
            hint: const Text('Selecione'),
            items: SearchForm.states
                .map(
                  (state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() {
              _uf = value;
              _ufMissing = false;
            }),
          ),
        ),
      ),
      const SizedBox(height: AppMetrics.spacingMd),
      TextFormField(
        key: const Key('cityField'),
        controller: _cityController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Cidade',
          border: OutlineInputBorder(),
        ),
        validator: _validateText,
      ),
      const SizedBox(height: AppMetrics.spacingMd),
      TextFormField(
        key: const Key('streetField'),
        controller: _streetController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          labelText: 'Logradouro (completo ou parte do nome)',
          border: OutlineInputBorder(),
        ),
        validator: _validateText,
        onFieldSubmitted: (_) => _submit(),
      ),
    ];
  }
}
