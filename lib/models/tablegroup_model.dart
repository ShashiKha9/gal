class TableGroupModel {
    final String code;
    final String name;
    final String status;

    TableGroupModel({
        required this.code,
        required this.name,
        required this.status,
    });

    factory TableGroupModel.fromJson(Map<String, dynamic> json) => TableGroupModel(
      code: json["code"],
      name: json["name"],
      status: json["status"],
    );

}
