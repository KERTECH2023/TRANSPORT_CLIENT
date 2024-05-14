import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? id;
  String? name;
  String? email;
  String? phone;
  String? photoUrl;
  String? carColor;
  String? carModel;
  String? carNumber;
  String? carType;
  String? lastTripId;
  String? totalEarnings;
  String? cstatus;
  String? dateNaissance;
  String? address;
  String? cnicNo;
  String? gender;
  String? licence;
  String? postalCode;
  

  UserModel({this.id,this.name,this.email,this.phone,this.carColor,
    this.carModel,
    this.carNumber,
    this.carType,
    this.lastTripId,
    this.totalEarnings,
    this.cstatus,
    this.dateNaissance,
    this.address,
    this.cnicNo,
    this.gender,
    this.licence,
    this.postalCode,
    this.photoUrl});

  UserModel.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    name = (snapshot.value as dynamic)["name"];
    email = (snapshot.value as dynamic)["email"];
    phone = (snapshot.value as dynamic)["phone"];
    photoUrl =(snapshot.value as dynamic)['imageUrl'];
    carColor =(snapshot.value as dynamic)['carColor'];
    carModel =(snapshot.value as dynamic)['carModel'];
    carNumber =(snapshot.value as dynamic)['carNumber'];
    carType =(snapshot.value as dynamic)['carType'];
    lastTripId =(snapshot.value as dynamic)['lastTripId'];
    totalEarnings =(snapshot.value as dynamic)['totalEarnings'];
    cstatus =(snapshot.value as dynamic)['Cstatus'];
    dateNaissance =(snapshot.value as dynamic)['DateNaissance'];
    address =(snapshot.value as dynamic)['address'];
    cnicNo =(snapshot.value as dynamic)['cnicNo'];
    gender =(snapshot.value as dynamic)['gender'];
    licence =(snapshot.value as dynamic)['licence'];
    postalCode =(snapshot.value as dynamic)['postalCode'];
    photoUrl =(snapshot.value as dynamic)['imageUrl'];
  }

}