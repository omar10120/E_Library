class AuthorModel {
  final String id;
  final String fName;
  final String lName;
  final String city;
  final String country;
  final String address;

  AuthorModel({
    required this.id,
    required this.fName,
    required this.lName,
    required this.city,
    required this.country,
    required this.address,
  });

  factory AuthorModel.fromMap(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'],
      fName: json['fName'],
      lName: json['lName'],
      city: json['city'],
      country: json['country'],
      address: json['address'],
    );
  }
}
