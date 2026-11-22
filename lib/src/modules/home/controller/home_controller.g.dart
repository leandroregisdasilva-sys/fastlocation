// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  Computed<bool>? _$hasLastAddressComputed;

  @override
  bool get hasLastAddress =>
      (_$hasLastAddressComputed ??= Computed<bool>(() => super.hasLastAddress,
              name: 'HomeControllerBase.hasLastAddress'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: 'HomeControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$hasSearchedAtom =
      Atom(name: 'HomeControllerBase.hasSearched', context: context);

  @override
  bool get hasSearched {
    _$hasSearchedAtom.reportRead();
    return super.hasSearched;
  }

  @override
  set hasSearched(bool value) {
    _$hasSearchedAtom.reportWrite(value, super.hasSearched, () {
      super.hasSearched = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'HomeControllerBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$lastAddressAtom =
      Atom(name: 'HomeControllerBase.lastAddress', context: context);

  @override
  AddressModel? get lastAddress {
    _$lastAddressAtom.reportRead();
    return super.lastAddress;
  }

  @override
  set lastAddress(AddressModel? value) {
    _$lastAddressAtom.reportWrite(value, super.lastAddress, () {
      super.lastAddress = value;
    });
  }

  late final _$addressesAtom =
      Atom(name: 'HomeControllerBase.addresses', context: context);

  @override
  ObservableList<AddressModel> get addresses {
    _$addressesAtom.reportRead();
    return super.addresses;
  }

  @override
  set addresses(ObservableList<AddressModel> value) {
    _$addressesAtom.reportWrite(value, super.addresses, () {
      super.addresses = value;
    });
  }

  late final _$searchByCepAsyncAction =
      AsyncAction('HomeControllerBase.searchByCep', context: context);

  @override
  Future<void> searchByCep(String cep) {
    return _$searchByCepAsyncAction.run(() => super.searchByCep(cep));
  }

  late final _$searchByAddressAsyncAction =
      AsyncAction('HomeControllerBase.searchByAddress', context: context);

  @override
  Future<void> searchByAddress(
      {required String uf, required String city, required String street}) {
    return _$searchByAddressAsyncAction
        .run(() => super.searchByAddress(uf: uf, city: city, street: street));
  }

  late final _$selectAddressAsyncAction =
      AsyncAction('HomeControllerBase.selectAddress', context: context);

  @override
  Future<void> selectAddress(AddressModel address) {
    return _$selectAddressAsyncAction.run(() => super.selectAddress(address));
  }

  late final _$traceRouteAsyncAction =
      AsyncAction('HomeControllerBase.traceRoute', context: context);

  @override
  Future<void> traceRoute() {
    return _$traceRouteAsyncAction.run(() => super.traceRoute());
  }

  late final _$HomeControllerBaseActionController =
      ActionController(name: 'HomeControllerBase', context: context);

  @override
  void loadLastAddress() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
        name: 'HomeControllerBase.loadLastAddress');
    try {
      return super.loadLastAddress();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
        name: 'HomeControllerBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
hasSearched: ${hasSearched},
errorMessage: ${errorMessage},
lastAddress: ${lastAddress},
addresses: ${addresses},
hasLastAddress: ${hasLastAddress}
    ''';
  }
}
