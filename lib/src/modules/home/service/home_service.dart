import '../../../shared/exceptions/app_exception.dart';
import '../model/address_model.dart';
import '../repositories/home_local_repository.dart';
import '../repositories/home_repository.dart';

class HomeService {
  HomeService({
    HomeRepository? repository,
    HomeLocalRepository? localRepository,
  })  : _repository = repository ?? HomeRepository(),
        _localRepository = localRepository ?? HomeLocalRepository();

  static const int cepLength = 8;
  static const int minimumTextLength = 3;

  final HomeRepository _repository;
  final HomeLocalRepository _localRepository;

  Future<AddressModel?> searchByCep(String cep) async {
    final cepDigits = normalizeCep(cep);
    if (cepDigits.length != cepLength) {
      throw const AppException('Informe um CEP com 8 dígitos.');
    }

    final storedAddress = _localRepository.findByCep(cepDigits);
    if (storedAddress != null) {
      await _localRepository.saveAddress(storedAddress);
      return storedAddress;
    }

    final address = await _repository.fetchAddressByCep(cepDigits);
    if (address != null) {
      await _localRepository.saveAddress(address);
    }
    return address;
  }

  Future<List<AddressModel>> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    final normalizedUf = uf.trim().toUpperCase();
    final normalizedCity = city.trim();
    final normalizedStreet = street.trim();

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(normalizedUf)) {
      throw const AppException('Selecione a UF do endereço.');
    }
    if (normalizedCity.length < minimumTextLength) {
      throw const AppException('Informe a cidade com pelo menos 3 letras.');
    }
    if (normalizedStreet.length < minimumTextLength) {
      throw const AppException(
        'Informe o logradouro com pelo menos 3 letras.',
      );
    }

    final addresses = await _repository.fetchAddressesByStreet(
      uf: normalizedUf,
      city: normalizedCity,
      street: normalizedStreet,
    );
    if (addresses.length == 1) {
      await _localRepository.saveAddress(addresses.first);
    }
    return addresses;
  }

  Future<void> registerConsultation(AddressModel address) {
    return _localRepository.saveAddress(address);
  }

  AddressModel? getLastAddress() => _localRepository.getLastAddress();

  List<AddressModel> getHistory() => _localRepository.getHistory();

  String normalizeCep(String cep) => cep.replaceAll(RegExp(r'\D'), '');
}
