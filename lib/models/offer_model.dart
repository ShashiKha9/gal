class OfferModel {
  final String offerCouponId;
  final String? uid;
  String? couponCode;
  String? note;
  String? discountInPercent;
  String? maxDiscount;
  String? minBillAmount;
  String? validity;
  final DateTime addDate;
  final DateTime createdOn;
  final String? createdBy;
  final String? companyId;

  OfferModel({
    required this.offerCouponId,
    required this.uid,
    required this.couponCode,
    required this.note,
    required this.discountInPercent,
    required this.maxDiscount,
    required this.minBillAmount,
    required this.validity,
    required this.addDate,
    required this.createdOn,
    required this.createdBy,
    required this.companyId,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        offerCouponId: json["offerCoupon_id"],
        uid: json["uid"],
        couponCode: json["couponCode"],
        note: json["note"],
        discountInPercent: json["discountInPercent"],
        maxDiscount: json["maxDiscount"],
        minBillAmount: json["minBillAmount"],
        validity: json["validity"],
        addDate: DateTime.parse(json["addDate"]),
        createdOn: DateTime.parse(json["created_on"]),
        createdBy: json["created_by"],
        companyId: json["company_id"],
      );

  Map<String, dynamic> toJson() => {
        "offerCoupon_id": offerCouponId,
        "uid": uid,
        "couponCode": couponCode,
        "note": note,
        "discountInPercent": discountInPercent,
        "maxDiscount": maxDiscount,
        "minBillAmount": minBillAmount,
        "validity": validity,
        "addDate": addDate.toIso8601String(), // Convert DateTime to String
        "created_on": createdOn.toIso8601String(), // Convert DateTime to String
        "created_by": createdBy,
        "company_id": companyId,
      };
}
