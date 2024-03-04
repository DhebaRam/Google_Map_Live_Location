class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

}

class User {
  String? name;
  Location? location;
  User({
    required this.name,
    required this.location,
  });
}
