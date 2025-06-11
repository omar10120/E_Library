class PublisherModel {
  final String id;
  final String pName;
  final String city;

  PublisherModel({
    required this.id,
    required this.pName,
    required this.city,
  });

  factory PublisherModel.fromMap(Map<String, dynamic> json) {
    return PublisherModel(
      id: json['id'],
      pName: json['pName'],
      city: json['city'],
    );
  }
}
