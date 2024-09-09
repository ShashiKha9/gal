import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/edit_offer_coupon.dart';
import 'package:provider/provider.dart';

class Offercoupon extends StatefulWidget {
  const Offercoupon({super.key});

  @override
  State<Offercoupon> createState() => _OffercouponState();
}

class _OffercouponState extends State<Offercoupon> {
  late SyncProvider _syncProvider;

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Offer Coupon Master',
        onSearch: (String) {},
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Consumer<SyncProvider>(builder: (context, syncProvider, child) {
              log(syncProvider.offerList.length.toString(),
                  name: 'Consumer length');
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Number of items per row
                  crossAxisSpacing: 16.0, // Increased spacing for better UI
                  mainAxisSpacing: 16.0, // Increased spacing for better UI
                  childAspectRatio:
                      2.3, // Adjusted aspect ratio for larger boxes
                ),
                itemCount: syncProvider.offerList.length,
                itemBuilder: (context, index) {
                  final offer = syncProvider.offerList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCouponPage(
                            couponCode: offer.couponCode ?? '',
                            note: offer.note ?? '',
                            discountInPercent: offer.discountInPercent ?? '',
                            maxDiscount: offer.maxDiscount ?? '',
                            minBillAmount: offer.minBillAmount ?? '',
                            validity: offer.validity ?? '',
                            couponIndex:
                                index, // Pass the index of the coupon here
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12.0), // Softer corners
                        border: Border.all(
                          color: const Color(0xFFC41E3A),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align text to the start
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.couponCode ?? 'no code',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            offer.note ?? 'Unnamed',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Discount: ${offer.discountInPercent ?? 'no data'}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Max discount Rs. ${offer.maxDiscount ?? 'no data'}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Min order should be Rs. ${offer.minBillAmount ?? 'no data'}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Valid upto ${offer.validity ?? 'no data'}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
