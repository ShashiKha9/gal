class TaxModel {
  final String? code;
  final String? name;
  final String cGst;
  final String iGst;
  final String sgst;
  final String rate;

  TaxModel({
    required this.code,
    required this.name,
    required this.cGst,
    required this.iGst,
    required this.sgst,
    required this.rate,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) => TaxModel(
        code: json["code"],
        name: json["name"],
        cGst: json["cGST"],
        iGst: json["iGST"],
        sgst: json["sgst"],
        rate: json["rate"],
      );
  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "cGST": cGst,
        "iGST": iGst,
        "sgst": sgst,
        "rate": rate,
      };
}
