class ItemModel {
  final String? departmentCode;
  final String? rate1;
  final String? rate2;
  final String? gStcode;
  final String? openPrice;
  final String? shortName;
  final String? unit;
  final String code;
  final String? name;
  final String? qtyInDecimal;
  final String? barcode;
  final String? hsnCode;
  final String? isHot;
  final String? hasKotMessage;
  final String? kotgroup;
  final String? qrcode;
  final String? displayinselection;
  final dynamic imageUrl;
  final String? isStocked;

  ItemModel({
    required this.departmentCode,
    required this.rate1,
    required this.rate2,
    required this.gStcode,
    required this.openPrice,
    required this.shortName,
    required this.unit,
    required this.code,
    required this.name,
    required this.qtyInDecimal,
    required this.barcode,
    required this.hsnCode,
    required this.isHot,
    required this.hasKotMessage,
    required this.kotgroup,
    required this.qrcode,
    required this.displayinselection,
    required this.imageUrl,
    required this.isStocked,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        departmentCode: json["departmentCode"],
        rate1: json["rate1"],
        rate2: json["rate2"],
        gStcode: json["gSTCODE"],
        openPrice: json["openPrice"],
        shortName: json["shortName"],
        unit: json["unit"],
        code: json["code"],
        name: json["name"],
        qtyInDecimal: json["qtyInDecimal"],
        barcode: json["barcode"],
        hsnCode: json["hsnCode"],
        isHot: json["isHot"],
        hasKotMessage: json["hasKotMessage"],
        kotgroup: json["kotgroup"],
        qrcode: json["qrcode"],
        displayinselection: json["displayinselection"],
        imageUrl: json["imageUrl"],
        isStocked: json["isStocked"],
      );
}
