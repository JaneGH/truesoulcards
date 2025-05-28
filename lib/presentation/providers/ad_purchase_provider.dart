import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'ad_provider.dart';

final purchaseControllerProvider = Provider((ref) {
  return PurchaseController(ref);
});

class PurchaseController {
  final Ref ref;
  final _productId = dotenv.env['ADS_PRODUCT_ID'] ?? 'remove_ads';

  PurchaseController(this.ref) {
    _listenToPurchaseUpdates();
  }

  void _listenToPurchaseUpdates() {
    InAppPurchase.instance.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          if (purchase.productID == _productId) {
             await ref.read(adsDisabledProvider.notifier).disableAds();
          }

          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        }
      }
    });
  }


  Future<void> buyRemoveAds() async {
    final isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) return;

    final productDetailsResponse =
    await InAppPurchase.instance.queryProductDetails({_productId});
    if (productDetailsResponse.notFoundIDs.isNotEmpty) {
      if (kDebugMode) {
        print('Product not found');
      }
      return;
    }

    final productDetails = productDetailsResponse.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }
}