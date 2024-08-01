import 'package:flutter/cupertino.dart';
import 'package:users_app/models/active_nearby_available_drivers.dart';

class GeoFireAssistant extends ChangeNotifier {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList =
      [];

  static void deleteOfflineDriverFromList(String driverId) {
    int index = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverId);
    activeNearbyAvailableDriversList.removeAt(index);
  }

  static void updateActiveNearbyAvailableDriverLocation(
      ActiveNearbyAvailableDrivers driverWhoMoves) {
    int index = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverWhoMoves.driverId);

    activeNearbyAvailableDriversList[index].locationLatitude =
        driverWhoMoves.locationLatitude;
    activeNearbyAvailableDriversList[index].locationLongitude =
        driverWhoMoves.locationLongitude;
  }
}
//
// class GeoFireAssistant extends ChangeNotifier {
//   List<ActiveNearbyAvailableDrivers> _activeNearbyAvailableDriversList = [];
//
//   List<ActiveNearbyAvailableDrivers> get activeNearbyAvailableDriversList =>
//       _activeNearbyAvailableDriversList;
//
//   void deleteOfflineDriverFromList(String driverId) {
//     _activeNearbyAvailableDriversList
//         .removeWhere((element) => element.driverId == driverId);
//     notifyListeners();
//   }
//
//   void updateActiveNearbyAvailableDriverLocation(
//       ActiveNearbyAvailableDrivers driverWhoMoves) {
//     int index = _activeNearbyAvailableDriversList
//         .indexWhere((element) => element.driverId == driverWhoMoves.driverId);
//
//     if (index != -1) {
//       _activeNearbyAvailableDriversList[index].locationLatitude =
//           driverWhoMoves.locationLatitude;
//       _activeNearbyAvailableDriversList[index].locationLongitude =
//           driverWhoMoves.locationLongitude;
//       notifyListeners();
//     }
//   }
// }
