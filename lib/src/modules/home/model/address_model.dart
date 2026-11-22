import 'package:hive/hive.dart';

part 'address_model.g.dart';

@HiveType(typeId: 0)
class AddressModel {
  const AddressModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ibge,
    required this.ddd,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      cep: _text(json['cep']),
      logradouro: _text(json['logradouro']),
      complemento: _text(json['complemento']),
      bairro: _text(json['bairro']),
      localidade: _text(json['localidade']),
      uf: _text(json['uf']),
      ibge: _text(json['ibge']),
      ddd: _text(json['ddd']),
    );
  }

  @HiveField(0)
  final String cep;

  @HiveField(1)
  final String logradouro;

  @HiveField(2)
  final String complemento;

  @HiveField(3)
  final String bairro;

  @HiveField(4)
  final String localidade;

  @HiveField(5)
  final String uf;

  @HiveField(6)
  final String ibge;

  @HiveField(7)
  final String ddd;

  String get cepDigits => cep.replaceAll(RegExp(r'\D'), '');

  String get streetLabel {
    if (logradouro.isEmpty) {
      return 'Logradouro não informado';
    }
    if (complemento.isEmpty) {
      return logradouro;
    }
    return '$logradouro ($complemento)';
  }

  String get cityAndState => '$localidade - $uf';

  String get districtAndCity {
    if (bairro.isEmpty) {
      return cityAndState;
    }
    return '$bairro, $cityAndState';
  }

  String get fullAddress {
    final parts = <String>[logradouro, bairro, cityAndState, cep, 'Brasil'];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cep': cep,
      'logradouro': logradouro,
      'complemento': complemento,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'ibge': ibge,
      'ddd': ddd,
    };
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';
}
