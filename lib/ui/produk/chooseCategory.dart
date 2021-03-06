import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/model/categoryProductModel.dart';

class ChooseCategoryProduct extends StatefulWidget {
  ChooseCategoryProduct({Key key}) : super(key: key);

  @override
  _ChooseCategoryProductState createState() => _ChooseCategoryProductState();
}

class _ChooseCategoryProductState extends State<ChooseCategoryProduct> {
  var loading = false;
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

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getProductWithCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pilih Kategori",
        ),
        elevation: 1,
      ),
      body: Container(
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: listCategory.length,
                itemBuilder: (context, i) {
                  final a = listCategory[i];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, a);
                    },
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(a.categoryName),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Divider(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
