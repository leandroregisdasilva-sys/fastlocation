import 'package:dio/dio.dart';

import '../../../http/http_config.dart';
import '../../../shared/exceptions/app_exception.dart';
import '../model/address_model.dart';

class HomeRepository {
  HomeRepository({Dio? dio}) : _dio = dio ?? HttpConfig.dio;

  final Dio _dio;

  Future<AddressModel?> fetchAddressByCep(String cep) async {
    try {
      final response = await _dio.get<dynamic>('/$cep/json/');
      final data = response.data;
      if (data is! Map || _hasError(data)) {
        return null;
      }
      return AddressModel.fromJson(Map<String, dynamic>.from(data));
    } on DioError catch (error) {
      throw _mapError(error);
    }
  }

  Future<List<AddressModel>> fetchAddressesByStreet({
    required String uf,
    required String city,
    required String street,
  }) async {
    final segments = <String>[uf, city, street].map(Uri.encodeComponent);
    try {
      final response = await _dio.get<dynamic>('/${segments.join('/')}/json/');
      final data = response.data;
      if (data is! List) {
        return <AddressModel>[];
      }
      return data
          .whereType<Map>()
          .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioError catch (error) {
      throw _mapError(error);
    }
  }

  bool _hasError(Map<dynamic, dynamic> data) {
    final error = data['erro'];
    return error == true || error == 'true';
  }

  AppException _mapError(DioError error) {
    final type = error.type;
    if (type == DioErrorType.connectTimeout ||
        type == DioErrorType.sendTimeout ||
        type == DioErrorType.receiveTimeout) {
      return const AppException(
        'A consulta demorou demais. Verifique a conexão e tente novamente.',
      );
    }
    if (type == DioErrorType.response) {
      if (error.response?.statusCode == 400) {
        return const AppException(
          'Os dados informados são inválidos para a consulta.',
        );
      }
      return const AppException(
        'O serviço de consulta está indisponível no momento.',
      );
    }
    if (type == DioErrorType.cancel) {
      return const AppException('A consulta foi cancelada.');
    }
    return const AppException(
      'Sem conexão com a internet. Verifique a rede e tente novamente.',
    );
  }
}
