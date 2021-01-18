import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get_mac/get_mac.dart';
import 'package:intl/intl.dart';
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/model/categoryProductModel.dart';
import 'package:my_ecommerce/model/productModel.dart';
import 'package:my_ecommerce/ui/produk/addProduk.dart';
import 'package:http/http.dart' as http;
import 'package:my_ecommerce/ui/produk/productCart.dart';
import 'package:my_ecommerce/ui/produk/productDetail.dart';
import 'package:my_ecommerce/ui/produk/searchProduct.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

final harga = NumberFormat("#,##0", 'en_US');

class _HomeState extends State<Home> {
  var loading = false;
  var filter = false;
  String deviceID;
  String _macAddress = "Unknown";

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  List<ProductModel> list = [];
  List<CategoryProductModel> listCategory = [];

  getProductWithCategory() async {
    setState(() {
      loading = true;
    });
    listCategory.clear();
    final response = await http.get(NetworkUrl.getProductCategory());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          listCategory.add(CategoryProductModel.froJson(i));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProduct());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          list.add(ProductModel.fromJson(i));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

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
    });
    getTotalCart();
  }

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.id}');
    setState(() {
      deviceID = androidInfo.id;
    });
  }

  var loadingCart = false;
  var totalCart = "0";
  getTotalCart() async {
    setState(() {
      loadingCart = true;
    });

    final response = await http.get(NetworkUrl.getTotalCart(_macAddress));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      String total = data['total'];
      setState(() {
        loadingCart = false;
        totalCart = total;
      });
    } else {
      setState(() {
        loadingCart = false;
      });
    }
  }

  //menambahkan favorute
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

  // ignore: missing_return
  Future<Void> onRefsresh() async {
    getProduct();
    // getTotalCart();
    initPlatformSatate();
    getProductWithCategory();
    setState(() {
      filter = false;
    });
  }

  int index = 0;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getProduct();
    getProductWithCategory();
    // getTotalCart();
    getDeviceInfo();
    initPlatformSatate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.shopping_cart,
                ),
                totalCart == "0"
                    ? SizedBox()
                    : Positioned(
                        top: -4,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                          child: Text(
                            "$totalCart",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductCart(
                    method: getTotalCart,
                  ),
                ),
              );
            },
          ),
        ],
        title: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchProduct()));
          },
          child: Container(
            alignment: Alignment.center,
            height: 50,
            padding: EdgeInsets.all(4),
            child: TextField(
              style: TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: "Search...",
                fillColor: Colors.white,
                filled: true,
                enabled: false,
                contentPadding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    style: BorderStyle.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProduct(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue,
          ),
          child: Text(
            "Add Product",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  //Kategori produk
                  Container(
                    padding: EdgeInsets.all(6),
                    height: 50,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: listCategory.length,
                      itemBuilder: (context, i) {
                        final a = listCategory[i];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              filter = true;
                              index = i;
                              print(filter);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(right: 6, left: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300],
                            ),
                            child: Text(
                              a.categoryName,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  //Produk
                  filter
                      ? listCategory[index].product.length == 0
                          ? Container(
                              height: 100,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Sorry Product on This Category not available",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  )
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: listCategory[index].product.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemBuilder: (context, i) {
                                final a = listCategory[index].product[i];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProductDetail(
                                                a, getTotalCart)));
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
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: list.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemBuilder: (context, i) {
                            final a = list[i];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetail(a, getTotalCart)));
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
                        ),
                ],
              ),
              onRefresh: onRefsresh,
            ),
    );
  }
}
