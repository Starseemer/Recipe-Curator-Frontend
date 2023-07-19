import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';
import 'molecules/recipe_create_card.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const User());
  }
}

class _UserState extends State<User> {
  dynamic currentUserData;
  dynamic newUserData;
  bool isSubmiting = false;
  Color textColor = Colors.white;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  getUserData() async {
    http.Response response = await http.get(
      Uri.http('localhost:8000', '/user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        "Authorization": MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        currentUserData = jsonDecode(response.body);
        print(currentUserData);
        _nameController.text = currentUserData["user"]['name'];
        _surnameController.text = currentUserData["user"]['surname'];
      });
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  updateUser() async {
    http.Response response = await http.put(
      Uri.http('localhost:8000', '/user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        "Authorization": MyCookieManager().getCookie(),
      },
      body: jsonEncode(<String, dynamic>{
        'name': _nameController.text,
        'surname': _surnameController.text,
        'oldPassword': _oldPasswordController.text,
        'newPassword': _newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated'),
        ),
      );
      getUserData();
      _newPasswordController.clear();
      _oldPasswordController.clear();
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Color.fromARGB(182, 176, 190, 215),
              ),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            hintText: 'Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _surnameController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            hintText: 'Surname',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Surname';
                            }
                            return null;
                          },
                          maxLines: 1,
                        ),
                        TextFormField(
                          controller: _oldPasswordController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            hintText: 'Old Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          maxLines: 1,
                        ),
                        TextFormField(
                          controller: _newPasswordController,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            hintText: 'New Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          maxLines: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: isSubmiting ? null : updateUser,
                            child: Text("Submit"),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ));
  }
}
