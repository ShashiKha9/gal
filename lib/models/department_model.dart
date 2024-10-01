class DepartmentModel {
  final String code;
  String description;
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

  // Method to convert DepartmentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'remark': remark,
    };
  }
}
