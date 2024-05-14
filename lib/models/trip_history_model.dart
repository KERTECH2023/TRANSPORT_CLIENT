import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel{
  String? time;
  String? sourceAddress;
  String? destinationAddress;
  String? fareAmount;
  String? status;
  String? carModel;
  String? carNumber;
  String? driverName;
  TripHistoryModel({
    this.time,
    this.sourceAddress,
    this.destinationAddress,
    this.fareAmount,
this.driverName,
    this.status,
    this.carModel,
    this.carNumber,   
  });

  TripHistoryModel.fromSnapshot(DataSnapshot snapshot){
    time = (snapshot.value as Map)["time"].toString();
    sourceAddress = (snapshot.value as Map)["sourceAddress"].toString();
    destinationAddress = (snapshot.value as Map)["destinationAddress"].toString();
    fareAmount = (snapshot.value as Map)["fareAmount"].toString();
    status = (snapshot.value as Map)["status"].toString();
    carModel = (snapshot.value as Map)["carModel"].toString();
    carNumber = (snapshot.value as Map)["carNumber"].toString();
    driverName = (snapshot.value as Map)["driverName"].toString();

  }


}