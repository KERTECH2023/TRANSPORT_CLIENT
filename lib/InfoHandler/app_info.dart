import 'package:flutter/widgets.dart';
import 'package:users_app/models/trip_history_model.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickupLocation, userDropOffLocation;
  int? countTotalTrips;
  List<String> historyTripsKeyList = [];
  List<TripHistoryModel> historyInformationList = [];
  String riderequeststatus = '';
  TripHistoryModel? lastTripHistoryInformationModel;
  DirectionDetailsInfo? lastTripDirectionDetailsInformation;

  // Initialize countTotalTrips in the constructor
  AppInfo({this.countTotalTrips});

  void updatePickupLocationAddress(Directions userPickupAddress) {
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

  void updateriderequeststatus(String riderequeststatus) {
    this.riderequeststatus = riderequeststatus;
    notifyListeners();
  }

  // Will be used in the later part of the app through provider
  void updateTotalTrips(int totalTripsCount) {
    countTotalTrips = totalTripsCount;
    notifyListeners();
  }

  void updateTotalTripsList(List<String> rideRequestKeyList) {
    historyTripsKeyList = rideRequestKeyList;
    notifyListeners();
  }

  void updateLastHistoryInformation(
      TripHistoryModel lastTripHistoryInformation,
      DirectionDetailsInfo lastTripDirectionDetailsInfo) {
    lastTripHistoryInformationModel = lastTripHistoryInformation;
    lastTripDirectionDetailsInformation = lastTripDirectionDetailsInfo;

    notifyListeners();
  }

  void updateTotalHistoryInformation(
      TripHistoryModel eachTripHistoryInformation) {
    historyInformationList.add(eachTripHistoryInformation);
    notifyListeners();
  }
}