class CustomerModel {
  final String? code;
  final String? customerCode;
  final String? name;
  final String? email;
  final String? mobile1;
  final String? mobile2;
  final String? landline;
  final String? address;
  final String? birthdate;
  final String? gstNo;
  final String? note;
  final DateTime addDate;
  final DateTime updateDate;
  final String? isActive;
  final String? isPremium;
  final String? createdBy;
  final String? companyId;

  CustomerModel({
    required this.code,
    required this.customerCode,
    required this.name,
    required this.email,
    required this.mobile1,
    required this.mobile2,
    required this.landline,
    required this.address,
    required this.birthdate,
    required this.gstNo,
    required this.note,
    required this.addDate,
    required this.updateDate,
    required this.isActive,
    required this.isPremium,
    required this.createdBy,
    required this.companyId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        code: json["code"],
        customerCode: json["customerCode"],
        name: json["name"],
        email: json["email"],
        mobile1: json["mobile1"],
        mobile2: json["mobile2"],
        landline: json["landline"],
        address: json["address"],
        birthdate: json["birthdate"],
        gstNo: json["gstNo"],
        note: json["note"],
        addDate: DateTime.parse(json["addDate"]),
        updateDate: DateTime.parse(json["updateDate"]),
        isActive: json["isActive"],
        isPremium: json["isPremium"],
        createdBy: json["createdBy"],
        companyId: json["company_id"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "customerCode": customerCode,
        "name": name,
        "email": email,
        "mobile1": mobile1,
        "mobile2": mobile2,
        "landline": landline,
        "address": address,
        "birthdate": birthdate,
        "gstNo": gstNo,
        "note": note,
        "addDate": addDate.toIso8601String(),
        "updateDate": updateDate.toIso8601String(),
        "isActive": isActive,
        "isPremium": isPremium,
        "createdBy": createdBy,
        "company_id": companyId, // Ensure consistency in key naming
      };
}
