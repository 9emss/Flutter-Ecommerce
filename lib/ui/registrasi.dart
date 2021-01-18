import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_ecommerce/config/config.dart';
import 'package:my_ecommerce/custom/prefProfile.dart';
import 'package:my_ecommerce/ui/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Registrasi extends StatefulWidget {
  final String email;
  final String token;
  Registrasi({this.email, this.token});

  @override
  _RegistrasiState createState() => _RegistrasiState();
}

class _RegistrasiState extends State<Registrasi> {
  TextEditingController namaLengkap = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  final _key = GlobalKey<FormState>();

  check() {
    if (_key.currentState.validate()) {
      simpan();
    }
  }

  simpan() async {
    final response = await http.post(NetworkUrl.daftar(), body: {
      "email": widget.email,
      "password": password.text,
      "token": widget.token,
      "namaLengkap": namaLengkap.text,
      "phone": phone.text,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    String id = data['id'];
    String nama = data['namaLengkap'];
    String hp = data['phone'];
    String emailUsers = data['email'];
    String passwordUsers = data['password'];
    String createdDate = data['createdDate'];
    String level = data['level'];
    if (value == 1) {
      print(message);
      setState(() {
        savePref(id, emailUsers, passwordUsers, nama, hp, createdDate, level);
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Menu()));
    } else {
      print(message);
    }
  }

  savePref(
    String id,
    String email,
    String password,
    String namaLengkap,
    String phone,
    String createdDate,
    String level,
  ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString(Pref.id, id);
      pref.setString(Pref.email, email);
      pref.setString(Pref.password, password);
      pref.setString(Pref.namaLengkap, namaLengkap);
      pref.setString(Pref.phone, phone);
      pref.setString(Pref.createdDate, createdDate);
      pref.setString(Pref.level, level);
      pref.setBool(Pref.login, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: namaLengkap,
                validator: (e) {
                  if (e.isEmpty)
                    return "Silahkan masukan nama lengkap anda";
                  else
                    null;
                },
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  hintText: "Nama Lengkap",
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                controller: phone,
                validator: (e) {
                  if (e.isEmpty)
                    return "Silahkan masukan nomor ponsel";
                  else
                    null;
                },
                decoration: InputDecoration(
                  labelText: "Nomor ponsel",
                  hintText: "Nomor Ponsel",
                ),
              ),
              TextFormField(
                controller: password,
                obscureText: _secureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    onPressed: showHide,
                    icon: Icon(
                        _secureText ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                validator: (e) {
                  if (e.isEmpty)
                    return "Password kurang kuat";
                  else
                    null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              InkWell(
                onTap: check,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.red,
                        Colors.purple[200],
                        Colors.orange,
                      ],
                    ),
                  ),
                  child: Text(
                    "Submit",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
