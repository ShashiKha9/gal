class PaymentModel {
  final String? id;
  String type;
  bool isDefault;
  final String? status;
  final DateTime createdDate;
  final String? createdBy;
  final dynamic updatedDate;
  final dynamic updatedBy;

  PaymentModel({
    required this.id,
    required this.type,
    this.isDefault = false,
    required this.status,
    required this.createdDate,
    required this.createdBy,
    required this.updatedDate,
    required this.updatedBy,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json["id"],
        type: json["type"],
        status: json["status"],
        createdDate: DateTime.parse(json["created_date"]),
        createdBy: json["created_by"],
        updatedDate: json["updated_date"],
        updatedBy: json["updated_by"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "status": status,
        "created_date": createdDate.toIso8601String(),
        "created_by": createdBy,
        "updated_date": updatedDate,
        "updated_by": updatedBy,
      };
}
