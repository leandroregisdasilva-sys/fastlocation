import 'package:fastlocation/src/modules/home/model/address_model.dart';
import 'package:fastlocation/src/modules/home/repositories/home_local_repository.dart';
import 'package:fastlocation/src/modules/home/repositories/home_repository.dart';
import 'package:fastlocation/src/modules/home/service/route_service.dart';

AddressModel buildAddress({
  String cep = '01001-000',
  String logradouro = 'Praça da Sé',
  String complemento = 'lado ímpar',
  String bairro = 'Sé',
  String localidade = 'São Paulo',
  String uf = 'SP',
}) {
  return AddressModel(
    cep: cep,
    logradouro: logradouro,
    complemento: complemento,
    bairro: bairro,
    localidade: localidade,
    uf: uf,
    ibge: '3550308',
    ddd: '11',
  );
}

class FakeHomeRepository implements HomeRepository {
  AddressModel? cepResult;
  List<AddressModel> streetResult = <AddressModel>[];
  Object? error;
  int cepCalls = 0;
  int streetCalls = 0;
  String? lastCep;
  String? lastUf;
  String? lastCity;
  String? lastStreet;

  @override
  Future<AddressModel?> fetchAddressByCep(String cep) async {
    cepCalls++;
    lastCep = cep;
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return cepResult;
  }

  @override
  Future<List<AddressModel>> fetchAddressesByStreet({
    required String uf,
    required String city,
    required String street,
  }) async {
    streetCalls++;
    lastUf = uf;
    lastCity = city;
    lastStreet = street;
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return streetResult;
  }
}

class FakeHomeLocalRepository implements HomeLocalRepository {
  final List<AddressModel> items = <AddressModel>[];

  @override
  AddressModel? findByCep(String cepDigits) {
    for (final address in items) {
      if (address.cepDigits == cepDigits) {
        return address;
      }
    }
    return null;
  }

  @override
  Future<void> saveAddress(AddressModel address) async {
    items.removeWhere((item) => item.cepDigits == address.cepDigits);
    items.add(address);
  }

  @override
  List<AddressModel> getHistory() => items.reversed.toList();

  @override
  AddressModel? getLastAddress() => items.isEmpty ? null : items.last;
}

class FakeRouteService implements RouteService {
  AddressModel? openedAddress;
  Object? error;

  @override
  Future<void> openRouteTo(AddressModel address) async {
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    openedAddress = address;
  }
}
