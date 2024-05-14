import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestInformation{

  String? rideRequestId;
  String? userName;
  String? userPhone;
  LatLng? sourceLatLng;
  LatLng? destinationLatLng;
  String? sourceAddress;
  String? destinationAddress;
 String? healthStatus;
  String? carModel;
  String? carNumber;

  RideRequestInformation({
    this.rideRequestId,
    this.userName,
    this.userPhone,
    this.sourceLatLng,
    this.destinationLatLng,
    this.sourceAddress,
    this.destinationAddress,
    this.healthStatus,
this.carModel,this.carNumber

  });

}