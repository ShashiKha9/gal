class TableMasterModel {
  final String code;
  final String? rate;
  String? name;
  final String? group;
  final String? status;
  final String? createdBy;
  final String? companyId;

  TableMasterModel({
    required this.code,
    required this.rate,
    required this.name,
    required this.group,
    required this.status,
    required this.createdBy,
    required this.companyId,
  });

  factory TableMasterModel.fromJson(Map<String, dynamic> json) =>
      TableMasterModel(
        code: json["code"],
        rate: json["rate"],
        name: json["name"],
        group: json["group"],
        status: json["status"],
        createdBy: json["created_by"],
        companyId: json["company_id"],
      );
  Map<String, dynamic> toJson() => {
        "code": code,
        "rate": rate,
        "name": name,
        "group": group,
        "status": status,
        "created_by": createdBy,
        "company_id": companyId,
      };
}
