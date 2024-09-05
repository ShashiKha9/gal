class DepartmentModel {
  final String code;
  final String? description;
  final dynamic remark;

  DepartmentModel({
    required this.code,
    required this.description,
    required this.remark,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        code: json["code"] ?? "",
        description: json["description"] ?? "",
        remark: json["remark"],
      );
}
