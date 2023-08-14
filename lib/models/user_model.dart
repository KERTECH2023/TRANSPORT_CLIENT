import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? id;
  String? name;
  String? email;
  String? phone;
  String? healthStatus;

  UserModel({this.id,this.name,this.email,this.phone,this.healthStatus});

  UserModel.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    name = (snapshot.value as dynamic)["name"];
    email = (snapshot.value as dynamic)["email"];
    phone = (snapshot.value as dynamic)["phone"];
    healthStatus =(snapshot.value as dynamic)['Healthstatus'];
  }

}