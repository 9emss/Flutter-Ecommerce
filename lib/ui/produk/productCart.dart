import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/custom/prefProfile.dart';
import 'package:my_ecommerce/model/productCartModel.dart';
import 'package:my_ecommerce/repository/checkoutRepository.dart';
import 'package:my_ecommerce/ui/login.dart';
import 'package:my_ecommerce/ui/menu/home.dart';
import 'package:get_mac/get_mac.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCart extends StatefulWidget {
  final VoidCallback method;

  ProductCart({this.method});

  @override
  _ProductCartState createState() => _ProductCartState();
}

class _ProductCartState extends State<ProductCart> {
  var loading = false;
  var checkData = false;
  String unikID = "Unknown";
  String idUsers;
  bool login = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  List<ProductCartModel> list = [];

  Future<void> initPlatformSatate() async {
    String macAddress;
    SharedPreferences pref = await SharedPreferences.getInstance();

    try {
      macAddress = await GetMac.macAddress;
    } on PlatformException {
      macAddress = 'Failed to get Mac Address';
    }

    if (!mounted) return;

    setState(() {
      login = pref.getBool(Pref.login) ?? false;
      idUsers = pref.getString(Pref.id);
      unikID = macAddress;
      print("MAC : " + unikID);
    });
    _fetchData();
  }

  // getDeviceInfo() async {
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   print('Running on ${androidInfo.id}');
  //   setState(() {
  //     // unikID = androidInfo.id;
  //   });

  //   _fetchData();
  // }

  _fetchData() async {
    setState(() {
      loading = true;
    });
    list.clear();

    final response = await http.get(NetworkUrl.getProductCart(unikID));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          checkData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          for (Map i in data) {
            list.add(ProductCartModel.fromJson(i));
          }
          loading = false;
          checkData = true;
        });
      }

      _getSumAmountCart();
    } else {
      setState(() {
        loading = false;
        checkData = false;
      });
    }
  }

  var totalPrice = "0";
  _getSumAmountCart() async {
    setState(() {
      loading = true;
    });

    final response = await http.get(NetworkUrl.getSumAmountCart(unikID));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      String total = data['total'];
      setState(() {
        loading = false;
        totalPrice = total;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  _addQuantity(ProductCartModel model, String tipe) async {
    await http.post(
      NetworkUrl.updateQuantity(),
      body: {
        "idProduct": model.id,
        "unikID": unikID,
        "tipe": tipe,
      },
    );
    setState(() {
      widget.method();
      _fetchData();
    });
  }

  CheckoutRepository checkoutRepository = CheckoutRepository();
  loginTrue() async {
    await checkoutRepository.checkout(idUsers, unikID, () {
      setState(() {
        widget.method();
      });
    }, context);
  }

  loginFalse() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implem\ent initState
    super.initState();
    initPlatformSatate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Cart"),
        elevation: 1,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : checkData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: list.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, i) {
                            final a = list[i];
                            return Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          a.namaProduk,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Price : Rp. ${harga.format(a.hargaProduk)}",
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Divider(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        _addQuantity(a, "tambah");
                                      },
                                    ),
                                  ),
                                  Container(
                                    child: Text(a.qty),
                                  ),
                                  Container(
                                    child: IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        _addQuantity(a, "kurang");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      totalPrice == "0"
                          ? SizedBox()
                          : Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    "Total Price : Rp. ${harga.format(int.parse(totalPrice))}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      login ? loginTrue() : loginFalse();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.blue,
                                      ),
                                      child: Text(
                                        "Checkout",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "You don't have Product on Cart",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
