import 'dart:convert';
import 'dart:ffi';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/model/productModel.dart';
import 'package:my_ecommerce/ui/menu/home.dart';
import 'package:my_ecommerce/ui/produk/productDetail.dart';
import 'package:get_mac/get_mac.dart';
import 'package:flutter/services.dart';

class Favorite extends StatefulWidget {
  Favorite({Key key}) : super(key: key);

  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  var loading = false;
  var checkData = false;
  String deviceID;
  String _macAddress = "Unknown";

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  List<ProductModel> list = [];

  Future<void> initPlatformSatate() async {
    String macAddress;

    try {
      macAddress = await GetMac.macAddress;
    } on PlatformException {
      macAddress = 'Failed to get Mac Address';
    }

    if (!mounted) return;

    setState(() {
      _macAddress = macAddress;
      print("MAC : " + _macAddress);
    });
    getProduct();
  }

  // ignore: missing_return
  Future<Void> onRefresh() async {
    getDeviceInfo();
    initPlatformSatate();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getDeviceInfo();
    initPlatformSatate();
  }

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.id}');
    setState(() {
      deviceID = androidInfo.id;
    });
    //getProduct();
  }

  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(NetworkUrl.getProductFavoriteWithoutLogin(_macAddress));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          checkData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          for (Map i in data) {
            list.add(ProductModel.fromJson(i));
          }
          loading = false;
          checkData = true;
        });
      }
    } else {
      setState(() {
        loading = false;
        checkData = false;
      });
    }
  }

  // ignore: unused_field
  final GlobalKey _keyRefresh = new GlobalKey<RefreshIndicatorState>();

  //menambahkan favorite
  void addFavorite(ProductModel model) async {
    setState(() {
      loading = false;
    });

    final response =
        await http.post(NetworkUrl.addFavoriteWithoutLogin(), body: {
      "deviceInfo": _macAddress,
      "idProduct": model.id,
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      getProduct();
      print(message);
      setState(() {
        loading = false;
      });
    } else {
      print(message);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : checkData
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: list.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          itemBuilder: (context, i) {
                            final a = list[i];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetail(a, getProduct)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey[300],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: Stack(
                                        children: <Widget>[
                                          Image.network(
                                            "http://192.168.1.6/gemss-code/product/${a.cover}",
                                            fit: BoxFit.cover,
                                            height: 150,
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.favorite_border,
                                                ),
                                                onPressed: () {
                                                  addFavorite(a);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      "${a.namaProduk}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "Rp. ${harga.format(a.hargaProduk)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.amber,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Kamu tidak punya produk favorit lagi",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
