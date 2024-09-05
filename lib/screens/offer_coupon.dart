import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart';

// Example Option Pages
class Offercoupon extends StatefulWidget {
  const Offercoupon({super.key});

  @override
  State<Offercoupon> createState() => _OffercouponState();
}

class _OffercouponState extends State<Offercoupon> {
  late SyncProvider _syncProvider; // List to store table names

  @override
  void initState() {
    super.initState();
    _syncProvider = Provider.of<SyncProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: 'Offer Coupon Master', onSearch: (String ) {  },),
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
                    // onTap: () => _onItemTap(item),
                    child: Container(
                      padding: const EdgeInsets.all(
                          16.0), // Added padding for better spacing inside the box
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            12.0), // Softer corners for a modern look
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
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align text to the start for a cleaner layout
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.couponCode ?? 'no code',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ), // Space between name and description
                          Text(
                            offer.note ?? 'Unnamed',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ), // Space between name and description
                          Text(
                            'Discount: ${offer.discountInPercent ?? 'no data'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Max discount Rs. ${offer.maxDiscount ?? 'no data'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Min order should be Rs. ${offer.minBillAmount ?? 'no data'}',
                            textAlign: TextAlign.left, // Align text to the left
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Valid upto ${offer.validity ?? 'no data'}',
                            textAlign: TextAlign.left, // Align text to the left
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
