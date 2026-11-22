import 'package:fastlocation/src/modules/home/model/address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = <String, dynamic>{
    'cep': '01001-000',
    'logradouro': 'Praça da Sé',
    'complemento': 'lado ímpar',
    'bairro': 'Sé',
    'localidade': 'São Paulo',
    'uf': 'SP',
    'ibge': '3550308',
    'ddd': '11',
  };

  test('converte o retorno da API ViaCEP em modelo', () {
    final address = AddressModel.fromJson(json);

    expect(address.cep, '01001-000');
    expect(address.cepDigits, '01001000');
    expect(address.logradouro, 'Praça da Sé');
    expect(address.localidade, 'São Paulo');
    expect(address.uf, 'SP');
    expect(address.toJson(), json);
  });

  test('trata campos ausentes como texto vazio', () {
    final address = AddressModel.fromJson(const <String, dynamic>{
      'cep': '89010-000',
      'localidade': 'Blumenau',
      'uf': 'SC',
    });

    expect(address.logradouro, isEmpty);
    expect(address.streetLabel, 'Logradouro não informado');
    expect(address.districtAndCity, 'Blumenau - SC');
  });

  test('monta os textos de exibição e o endereço completo', () {
    final address = AddressModel.fromJson(json);

    expect(address.streetLabel, 'Praça da Sé (lado ímpar)');
    expect(address.districtAndCity, 'Sé, São Paulo - SP');
    expect(
      address.fullAddress,
      'Praça da Sé, Sé, São Paulo - SP, 01001-000, Brasil',
    );
  });
}
