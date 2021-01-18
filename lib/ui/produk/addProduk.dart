import 'dart:convert';
import 'dart:io';
import 'package:my_ecommerce/model/categoryProductModel.dart';
import 'package:my_ecommerce/ui/produk/chooseCategory.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddProduct extends StatefulWidget {
  AddProduct({Key key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  File image;

  final picker = ImagePicker();

  //Method untuk mengambil gamabar dari galery
  Future galery() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      image = File(pickedFile.path);
    });
  }

  //controller textfield
  TextEditingController namaController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  CategoryProductModel model;

  //Method untuk memilih kategori produk
  pilihCategory() async {
    model = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChooseCategoryProduct(),
        ));

    setState(() {
      categoryController = TextEditingController(
        text: model.categoryName,
      );
    });
  }

  //Method upload data ke DB
  save() async {
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

    try {
      var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
      var lenght = await image.length();
      var url = Uri.parse("http://192.168.1.6/gemss-code/api/addProduct.php");
      var request = http.MultipartRequest("POST", url);
      var multiPartFile = http.MultipartFile(
        "image",
        stream,
        lenght,
        filename: path.basename(image.path),
      );

      request.fields['namaProduk'] = namaController.text;
      request.fields['hargaProduk'] = hargaController.text;
      request.fields['deskripsiProduk'] = deskripsiController.text;
      request.fields['idCategory'] = model.id;
      request.files.add(multiPartFile);

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        final data = jsonDecode(value);
        int valueGet = data['value'];
        String message = data['message'];
        if (valueGet == 1) {
          Navigator.pop(context);
          print(message);
        } else {
          Navigator.pop(context);
          print(message);
        }
      });

      if (response.statusCode > 2) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Produk"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            InkWell(
              onTap: () {
                pilihCategory();
              },
              child: TextField(
                enabled: false,
                controller: categoryController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Kategori Produk",
                ),
              ),
            ),
            TextField(
              controller: namaController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Nama Produk",
              ),
            ),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Harga Produk",
              ),
            ),
            TextField(
              controller: deskripsiController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Deskripsi Produk",
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: galery,
              child: image == null
                  ? Image.asset(
                      "././assets/img/placeholder.png",
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      image,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: save,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.pink[200],
                          Colors.purple[200],
                          Colors.orange,
                          Colors.red
                        ])),
                child: Text(
                  "Simpan Produk",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
