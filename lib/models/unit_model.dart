class UnitModel {
  final String? code;
  final dynamic remarks;
  final String? unit;
  final String? status;

  UnitModel({
    required this.code,
    required this.remarks,
    required this.unit,
    required this.status,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
        code: json["code"],
        remarks: json["remarks"],
        unit: json["unit"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "remarks": remarks,
        "unit": unit,
        "status": status,
      };
}
