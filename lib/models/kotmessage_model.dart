
class KotMessageModel {
    final String code;
    String? description;
    final dynamic isSynced;
    final dynamic addDate;
    final dynamic updateDate;

    KotMessageModel({
        required this.code,
        required this.description,
        required this.isSynced,
        required this.addDate,
        required this.updateDate,
    });

    factory KotMessageModel.fromJson(Map<String, dynamic> json) => KotMessageModel(
        code: json["code"],
        description: json["description"],
        isSynced: json["isSynced"],
        addDate: json["addDate"],
        updateDate: json["updateDate"],
    );
}
