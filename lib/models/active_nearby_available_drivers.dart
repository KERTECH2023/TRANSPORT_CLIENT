class ActiveNearbyAvailableDrivers
{
  String? driverId;
  double? locationLatitude;
  double? locationLongitude;
   String? id;
  String? name;
  Map<String, dynamic>? carDetails;
  double? ratings;


  ActiveNearbyAvailableDrivers({
    this.driverId,
    this.locationLatitude,
    this.locationLongitude,
    this.id, this.name, this.carDetails, this.ratings
  });


}