import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/model/productModel.dart';
import 'package:my_ecommerce/ui/menu/home.dart';
import 'package:my_ecommerce/ui/produk/productDetail.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  var loading = false;
  List<ProductModel> listSearch = [];
  List<ProductModel> list = [];

  //variable controller
  TextEditingController searchController = TextEditingController();

  //method untuk mengambil data produk
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

  //method untuk mencari data produk
  onSearch(String text) async {
    listSearch.clear();
    if (text.isEmpty) {
      setState(() {});
    }

    list.forEach((a) {
      if (a.namaProduk.toLowerCase().contains(text)) listSearch.add(a);
    });

    setState(() {});
  }

  //auto set data produk ketika di refresh
  // ignore: missing_return
  Future<Void> onRefsresh() async {
    getProduct();
  }

  int index = 0;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {},
          ),
        ],
        title: Container(
          alignment: Alignment.center,
          height: 50,
          padding: EdgeInsets.all(4),
          child: TextField(
            controller: searchController,
            onChanged: onSearch,
            autofocus: true,
            style: TextStyle(
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: "Search...",
              fillColor: Colors.white,
              filled: true,
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
      body: Container(
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : searchController.text.isNotEmpty || listSearch.length != 0
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: listSearch.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, i) {
                      final a = listSearch[i];
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: Image.network(
                                  "http://192.168.1.6/gemss-code/product/${a.cover}",
                                  fit: BoxFit.cover,
                                  height: 150,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          "Please Search your item product",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}
