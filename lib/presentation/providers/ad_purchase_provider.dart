import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'ad_provider.dart';

final purchaseControllerProvider = Provider<PurchaseController>((ref) {
  return PurchaseController(ref);
});

class PurchaseController {
  final Ref ref;
  final String _productId;

  PurchaseController(this.ref)
    : _productId = dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '' {
    if (_productId.isEmpty) {
      throw Exception(
        "Product ID 'ADMOB_APP_ID_ANDROID' not found in the environment.",
      );
    }
    _listenToPurchaseUpdates();
  }

  void _listenToPurchaseUpdates() {
    InAppPurchase.instance.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        try {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            if (purchase.productID == _productId) {
              await ref.read(adsDisabledProvider.notifier).disableAds();
            }
            if (purchase.pendingCompletePurchase) {
              await InAppPurchase.instance.completePurchase(purchase);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error processing purchase: $e");
          }
        }
      }
    });
  }

  Future<void> buyRemoveAds() async {
    try {
      final isAvailable = await InAppPurchase.instance.isAvailable();
      if (!isAvailable) {
        if (kDebugMode) {
          print('In-app purchases are not available.');
        }
        return;
      }

      if (_productId.isEmpty) {
        throw Exception('Product ID is empty.');
      }

      final productDetailsResponse = await InAppPurchase.instance
          .queryProductDetails({_productId});
      if (productDetailsResponse.notFoundIDs.contains(_productId)) {
        throw Exception('Product not found in store: $_productId');
      }

      final productDetails = productDetailsResponse.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initiating purchase: $e');
      }
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await InAppPurchase.instance.restorePurchases();
      if (kDebugMode) {
        print('Restore purchases initiated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring purchases: $e');
      }
    }
  }
}
