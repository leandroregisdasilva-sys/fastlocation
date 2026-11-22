import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../shared/exceptions/app_exception.dart';
import '../model/address_model.dart';

class RouteService {
  Future<void> openRouteTo(AddressModel address) async {
    final destination = await _findCoordinates(address);
    final maps = await MapLauncher.installedMaps;
    if (maps.isEmpty) {
      throw const AppException(
        'Nenhum aplicativo de mapas foi encontrado no dispositivo.',
      );
    }

    await maps.first.showDirections(
      destination: destination,
      destinationTitle: address.fullAddress,
    );
  }

  static const String notFoundMessage =
      'Não foi possível localizar o endereço no mapa.';

  Future<Coords> _findCoordinates(AddressModel address) async {
    List<Location> locations = <Location>[];
    try {
      locations = await locationFromAddress(address.fullAddress);
    } catch (_) {
      throw const AppException(notFoundMessage);
    }
    if (locations.isEmpty) {
      throw const AppException(notFoundMessage);
    }
    return Coords(locations.first.latitude, locations.first.longitude);
  }
}
