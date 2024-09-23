
class KotGroupModel {
    final String code;
    String name;
    dynamic description;

    KotGroupModel({
        required this.code,
        required this.name,
        required this.description,
    });

    factory KotGroupModel.fromJson(Map<String, dynamic> json) => KotGroupModel(
        code: json["Code"],
        name: json["Name"],
        description: json["Description"],
    );
}
