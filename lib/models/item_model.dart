class ItemModel {
  final String? departmentCode;
  final String? rate1;
  final String? rate2;
  final String? gStcode;
  final String? openPrice;
  final String? shortName;
  final String? unit;
  final String? code;
  final String? name;
  final String? qtyInDecimal;
  final String? barcode;
  final String? hsnCode;
  final String? isHot;
  final String? hasKotMessage;
  final String? kotgroup;
  final String? qrcode;
  final String? displayinselection;
  final String? imageUrl;
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

  // Method to convert ItemModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      "departmentCode": departmentCode,
      "rate1": rate1,
      "rate2": rate2,
      "gSTCODE": gStcode,
      "openPrice": openPrice,
      "shortName": shortName,
      "unit": unit,
      "code": code,
      "name": name,
      "qtyInDecimal": qtyInDecimal,
      "barcode": barcode,
      "hsnCode": hsnCode,
      "isHot": isHot,
      "hasKotMessage": hasKotMessage,
      "kotgroup": kotgroup,
      "qrcode": qrcode,
      "displayinselection": displayinselection,
      "imageUrl": imageUrl,
      "isStocked": isStocked,
    };
  }

  // New copyWith method to return a copy of the object with modified fields
  ItemModel copyWith({
    String? departmentCode,
    String? rate1,
    String? rate2,
    String? gStcode,
    String? openPrice,
    String? shortName,
    String? unit,
    String? code,
    String? name,
    String? qtyInDecimal,
    String? barcode,
    String? hsnCode,
    String? isHot,
    String? hasKotMessage,
    String? kotgroup,
    String? qrcode,
    String? displayinselection,
    String? imageUrl,
    String? isStocked,
  }) {
    return ItemModel(
      departmentCode: departmentCode ?? this.departmentCode,
      rate1: rate1 ?? this.rate1,
      rate2: rate2 ?? this.rate2,
      gStcode: gStcode ?? this.gStcode,
      openPrice: openPrice ?? this.openPrice,
      shortName: shortName ?? this.shortName,
      unit: unit ?? this.unit,
      code: code ?? this.code,
      name: name ?? this.name, // Allows updating 'name'
      qtyInDecimal: qtyInDecimal ?? this.qtyInDecimal,
      barcode: barcode ?? this.barcode,
      hsnCode: hsnCode ?? this.hsnCode,
      isHot: isHot ?? this.isHot, // Allows updating 'isHot'
      hasKotMessage: hasKotMessage ?? this.hasKotMessage,
      kotgroup: kotgroup ?? this.kotgroup,
      qrcode: qrcode ?? this.qrcode,
      displayinselection: displayinselection ?? this.displayinselection,
      imageUrl: imageUrl ?? this.imageUrl,
      isStocked: isStocked ?? this.isStocked,
    );
  }
}
