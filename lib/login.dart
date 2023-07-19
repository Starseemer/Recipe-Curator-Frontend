import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const Login());
  }
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/signup');
            },
            child: const Text(
              'Sign up',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        // TRY THIS: Try changing the color of the AppBar. What happens?
        // backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Color.fromARGB(182, 176, 190, 215),
            ),
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isSubmitting = true;
                                  });
                                  // TRY THIS: Try changing the color of the button.
                                  // What happens?
                                  // style: Theme.of(context).elevatedButtonTheme.style,
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Logging in...'),
                                    ),
                                  );
                                  http.Response response = await http.post(
                                      Uri.http('localhost:8000', '/login'),
                                      headers: {
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                        "Access-Control-Allow-Origin": "*",
                                        'Accept': '*/*'
                                      },
                                      body: jsonEncode(<String, String>{
                                        'email': _usernameController.text,
                                        'password': _passwordController.text,
                                      }));
                                  if (response.statusCode != 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Login failed. Please try again.'),
                                      ),
                                    );
                                    setState(() {
                                      _isSubmitting = false;
                                    });
                                    return;
                                  }
                                  final data = jsonDecode(response.body);
                                  print(data);
                                  MyCookieManager().setCookie(data['token']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Login successful!'),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed('/home');
                                }
                              },
                        child: Text("Submit"),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
