import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:my_ecommerce/ui/produk/productDetailAPI.dart';

class DynamicLinkServices {
  Future handleDynamicLink(BuildContext context) async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    handleDeeplink(context, data);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleDeeplink(context, dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print("LINK FAILED : ${e.message}");
    });
  }

  void handleDeeplink(BuildContext context, PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deepLink: $deepLink');

      var post = deepLink.pathSegments.contains("getProductDetail.php");
      if (post) {
        var idProduct = deepLink.queryParameters['idProduct'];
        print(idProduct);
        if (idProduct != null) {
          Route route = MaterialPageRoute(
              builder: (context) => ProductDetailAPI(idProduct));

          Navigator.push(context, route);
        }
      }
    }
  }

  Future<Uri> createdShareLink(String idProduct) async {
    DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://gemsscode.page.link',
      link: Uri.parse(
          'http://192.168.1.6/gemss-code/api/getProductDetail.php?idProduct=$idProduct'),
      androidParameters: AndroidParameters(
        packageName: 'com.android.gemsscode.ecommerce',
      ),
    );

    final link = await parameters.buildUrl();
    final ShortDynamicLink short = await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    return short.shortUrl;
  }
}
