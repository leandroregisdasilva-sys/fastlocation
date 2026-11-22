import 'package:mobx/mobx.dart';

import '../../home/model/address_model.dart';
import '../../home/repositories/home_local_repository.dart';

part 'history_controller.g.dart';

class HistoryController = HistoryControllerBase with _$HistoryController;

abstract class HistoryControllerBase with Store {
  HistoryControllerBase({HomeLocalRepository? localRepository})
      : _localRepository = localRepository ?? HomeLocalRepository();

  final HomeLocalRepository _localRepository;

  @observable
  bool isLoading = false;

  @observable
  ObservableList<AddressModel> addresses = ObservableList<AddressModel>();

  @computed
  bool get isEmpty => addresses.isEmpty;

  @action
  void loadHistory() {
    isLoading = true;
    addresses = ObservableList<AddressModel>.of(_localRepository.getHistory());
    isLoading = false;
  }
}
