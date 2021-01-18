import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/config/dynamicLinkCustom.dart';
import 'package:my_ecommerce/model/productModel.dart';
import 'package:my_ecommerce/ui/menu/home.dart';
import 'package:flutter/services.dart';
import 'package:get_mac/get_mac.dart';

class ProductDetail extends StatefulWidget {
  final ProductModel model;
  final VoidCallback reload;
  ProductDetail(this.model, this.reload);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String deviceID;
  String _macAddress = "Unknown";

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

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
        "idProduct": widget.model.id,
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
                    widget.reload();
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

  DynamicLinkServices dynamicLinkServices = DynamicLinkServices();
  var url;
  createLink(idProduct) async {
    url = await dynamicLinkServices.createdShareLink(idProduct);
    print(url);
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
        title: Text("${widget.model.namaProduk}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              createLink(widget.model.id);
            },
          ),
        ],
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
                    "http://192.168.1.6/gemss-code/product/${widget.model.cover}",
                    fit: BoxFit.cover,
                    height: 150,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${widget.model.namaProduk}",
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
                    "${widget.model.deskripsiProduk}",
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
                    "Rp. ${harga.format(widget.model.hargaProduk)}",
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
