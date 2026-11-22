import 'package:mobx/mobx.dart';

import '../../../shared/exceptions/app_exception.dart';
import '../model/address_model.dart';
import '../service/home_service.dart';
import '../service/route_service.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  HomeControllerBase({HomeService? service, RouteService? routeService})
      : _service = service ?? HomeService(),
        _routeService = routeService ?? RouteService();

  static const String unexpectedError =
      'Não foi possível concluir a operação. Tente novamente.';

  final HomeService _service;
  final RouteService _routeService;

  @observable
  bool isLoading = false;

  @observable
  bool hasSearched = false;

  @observable
  String? errorMessage;

  @observable
  AddressModel? lastAddress;

  @observable
  ObservableList<AddressModel> addresses = ObservableList<AddressModel>();

  @computed
  bool get hasLastAddress => lastAddress != null;

  @action
  void loadLastAddress() {
    lastAddress = _service.getLastAddress();
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<void> searchByCep(String cep) async {
    isLoading = true;
    errorMessage = null;
    try {
      final address = await _service.searchByCep(cep);
      hasSearched = true;
      if (address == null) {
        addresses = ObservableList<AddressModel>();
      } else {
        addresses = ObservableList<AddressModel>.of(<AddressModel>[address]);
        lastAddress = address;
      }
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = unexpectedError;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await _service.searchByAddress(
        uf: uf,
        city: city,
        street: street,
      );
      hasSearched = true;
      addresses = ObservableList<AddressModel>.of(result);
      if (result.length == 1) {
        lastAddress = result.first;
      }
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = unexpectedError;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> selectAddress(AddressModel address) async {
    try {
      await _service.registerConsultation(address);
      lastAddress = address;
    } catch (_) {
      errorMessage = unexpectedError;
    }
  }

  @action
  Future<void> traceRoute() async {
    final address = lastAddress;
    if (address == null) {
      errorMessage = 'Consulte um endereço antes de traçar a rota.';
      return;
    }

    isLoading = true;
    errorMessage = null;
    try {
      await _routeService.openRouteTo(address);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = unexpectedError;
    } finally {
      isLoading = false;
    }
  }
}
