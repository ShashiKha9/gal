import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/master_settings_screens/offer_coupon_masters/edit_offer_coupon.dart';
import 'package:provider/provider.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class OfferCouponMaster extends StatefulWidget {
  const OfferCouponMaster({super.key});

  @override
  State<OfferCouponMaster> createState() => _OfferCouponMasterState();
}

class _OfferCouponMasterState extends State<OfferCouponMaster> {
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
        onSearch: (p0) {},
        isMenu: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<SyncProvider>(
              builder: (context, syncProvider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: syncProvider.offerList.length,
                  itemBuilder: (context, index) {
                    final offer = syncProvider.offerList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        leading: const Icon(
                          Icons.local_offer,
                          color: AppColors.blue,
                        ),
                        title: Text(
                          offer.couponCode ?? 'no code',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.note ?? 'Unnamed',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              'Discount: ${offer.discountInPercent ?? 'no data'}%',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              'Max discount: Rs. ${offer.maxDiscount ?? 'no data'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              'Min. order Amt: Rs. ${offer.minBillAmount ?? 'no data'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              'Valid until: ${offer.validity ?? 'no data'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCouponPage(
                                couponCode: offer.couponCode ?? '',
                                note: offer.note ?? '',
                                discountInPercent:
                                    offer.discountInPercent ?? '',
                                maxDiscount: offer.maxDiscount ?? '',
                                minBillAmount: offer.minBillAmount ?? '',
                                validity: offer.validity ?? '',
                                couponIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
