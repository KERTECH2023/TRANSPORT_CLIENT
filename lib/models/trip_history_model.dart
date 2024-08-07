import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel{
  String? time;
  String? sourceAddress;
  String? destinationAddress;
  String? carNumber;
  String? carModel;
  String? driverName;
  String? fareAmount;
  String? status;
  String? driverPhoto;

  TripHistoryModel({
    this.time,
    this.sourceAddress,
    this.destinationAddress,
    this.carNumber,
    this.carModel,
    this.driverName,
    this.fareAmount,
    this.status,
    this.driverPhoto,
  });

  TripHistoryModel.fromSnapshot(DataSnapshot snapshot){
    time = (snapshot.value as Map)["time"].toString();
    sourceAddress = (snapshot.value as Map)["sourceAddress"].toString();
    destinationAddress = (snapshot.value as Map)["destinationAddress"].toString();
   carNumber = (snapshot.value as Map)["CarNumber"].toString();
  carModel = (snapshot.value as Map)["carModel"].toString();
    driverName = (snapshot.value as Map)["driverName"].toString();
    fareAmount = (snapshot.value as Map)["fareAmount"].toString();
    status = (snapshot.value as Map)["status"].toString();
        driverPhoto = (snapshot.value as Map)["driverPhoto"].toString();

  }


}