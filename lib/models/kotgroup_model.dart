class KotGroupModel {
  final String code;
  String name;
  dynamic description;

  KotGroupModel({
    required this.code,
    required this.name,
    required this.description,
  });

  // Factory method to create an instance of KotGroupModel from JSON
  factory KotGroupModel.fromJson(Map<String, dynamic> json) => KotGroupModel(
        code: json["Code"],
        name: json["Name"],
        description: json["Description"],
      );

  // Method to convert an instance of KotGroupModel to JSON
  Map<String, dynamic> toJson() => {
        "Code": code,
        "Name": name,
        "Description": description,
      };
}
