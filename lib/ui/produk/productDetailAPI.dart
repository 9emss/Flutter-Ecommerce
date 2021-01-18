import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/model/productModel.dart';
import 'package:my_ecommerce/ui/menu/home.dart';
import 'package:flutter/services.dart';
import 'package:get_mac/get_mac.dart';

class ProductDetailAPI extends StatefulWidget {
  final String idProduct;
  ProductDetailAPI(this.idProduct);

  @override
  _ProductDetailAPIState createState() => _ProductDetailAPIState();
}

class _ProductDetailAPIState extends State<ProductDetailAPI> {
  String deviceID;
  String _macAddress = "Unknown";
  ProductModel model;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  getProductDetail() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Processing"),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 4,
                ),
                Text("Loading...")
              ],
            ),
          ),
        );
      },
    );

    var loading = false;
    final response =
        await http.get(NetworkUrl.getProductDetail(widget.idProduct));
    if (response.statusCode == 200) {
      if (response.bodyBytes == 2) {
        setState(() {
          loading = false;
        });
      } else {
        Navigator.pop(context);
        final data = jsonDecode(response.body);
        setState(() {
          for (Map i in data) {
            model = ProductModel.fromJson(i);
          }
          print(model);
        });
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> initPlatformState() async {
    String macAddress;

    try {
      macAddress = await GetMac.macAddress;
    } on PlatformException {
      macAddress = "Failed to get MAC Address";
    }

    if (!mounted) return;

    setState(() {
      _macAddress = macAddress;
    });
    getProductDetail();
  }

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.id}');
    setState(() {
      deviceID = androidInfo.id;
    });
  }

  addCart() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Processing"),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 4,
                ),
                Text("Loading...")
              ],
            ),
          ),
        );
      },
    );

    final response = await http.post(
      NetworkUrl.addCart(),
      body: {
        "unikID": _macAddress,
        "idProduct": model.id,
      },
    );
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];

    if (value == 1) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Information"),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text("Ok"),
              )
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Warning!"),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Ok"),
              )
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getDeviceInfo();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${model.namaProduk}"),
      ),
      body: Container(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Image.network(
                    "http://192.168.1.6/gemss-code/product/${model.cover}",
                    fit: BoxFit.cover,
                    height: 150,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${model.namaProduk}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Divider(
                      color: Colors.grey[300],
                    ),
                  ),
                  Text(
                    "${model.deskripsiProduk}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Rp. ${harga.format(model.hargaProduk)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    addCart();
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green[400],
                    ),
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
