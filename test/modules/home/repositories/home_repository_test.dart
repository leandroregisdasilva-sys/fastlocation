import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fastlocation/src/modules/home/repositories/home_repository.dart';
import 'package:fastlocation/src/shared/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;
  String? requestedPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    requestedPath = options.path;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

HomeRepository buildRepository(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://viacep.com.br/ws'));
  dio.httpClientAdapter = adapter;
  return HomeRepository(dio: dio);
}

void main() {
  test('consulta endereço por CEP', () async {
    final adapter = FakeHttpAdapter(
      '{"cep":"01001-000","logradouro":"Praça da Sé","complemento":"lado ímpar",'
      '"bairro":"Sé","localidade":"São Paulo","uf":"SP","ibge":"3550308","ddd":"11"}',
    );

    final address = await buildRepository(adapter).fetchAddressByCep('01001000');

    expect(adapter.requestedPath, '/01001000/json/');
    expect(address?.logradouro, 'Praça da Sé');
    expect(address?.uf, 'SP');
  });

  test('retorna nulo quando a API informa CEP inexistente', () async {
    final adapter = FakeHttpAdapter('{"erro": true}');

    final address = await buildRepository(adapter).fetchAddressByCep('99999999');

    expect(address, isNull);
  });

  test('retorna nulo quando a API informa erro em formato de texto', () async {
    final adapter = FakeHttpAdapter('{"erro": "true"}');

    final address = await buildRepository(adapter).fetchAddressByCep('99999999');

    expect(address, isNull);
  });

  test('consulta CEPs por endereço completo ou parcial', () async {
    final adapter = FakeHttpAdapter(
      '[{"cep":"90420-010","logradouro":"Rua Domingos José de Almeida",'
      '"complemento":"","bairro":"Rio Branco","localidade":"Porto Alegre","uf":"RS"},'
      '{"cep":"91040-000","logradouro":"Rua Domingos Rubbo","complemento":"",'
      '"bairro":"Cristo Redentor","localidade":"Porto Alegre","uf":"RS"}]',
    );

    final addresses = await buildRepository(adapter).fetchAddressesByStreet(
      uf: 'RS',
      city: 'Porto Alegre',
      street: 'Domingos',
    );

    expect(adapter.requestedPath, '/RS/Porto%20Alegre/Domingos/json/');
    expect(addresses, hasLength(2));
    expect(addresses.first.cep, '90420-010');
  });

  test('retorna lista vazia quando nenhum endereço é encontrado', () async {
    final adapter = FakeHttpAdapter('[]');

    final addresses = await buildRepository(adapter).fetchAddressesByStreet(
      uf: 'SC',
      city: 'Blumenau',
      street: 'Inexistente',
    );

    expect(addresses, isEmpty);
  });

  test('converte resposta 400 em mensagem para o usuário', () async {
    final adapter = FakeHttpAdapter('{}', statusCode: 400);

    await expectLater(
      buildRepository(adapter).fetchAddressByCep('123'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Os dados informados são inválidos para a consulta.',
        ),
      ),
    );
  });
}
