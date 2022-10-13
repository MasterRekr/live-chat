import 'package:flutter/material.dart';
import 'package:live_chat_messenger/services/basic_helper.dart';
import 'package:live_chat_messenger/screens/signin.dart';
import 'package:live_chat_messenger/screens/signin_email.dart';
import 'package:live_chat_messenger/services/auth.dart';

class SignUpFields {
  late String username;
  late String name;
  late String email;
  late String password;
}

class SignUpEmail extends StatefulWidget {
  const SignUpEmail({Key? key}) : super(key: key);

  @override
  State<SignUpEmail> createState() => _SignUpEmailState();
}

class _SignUpEmailState extends State<SignUpEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final SignUpFields _signUpFields = SignUpFields();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Chat"),
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                    (route) => false);
              },
              icon: Icon(Icons.adaptive.arrow_back_rounded)),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (BasicHelper.isNullOrEmpty(value)) {
                              return 'Enter name';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            _signUpFields.name = val!.trim();
                          },
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (BasicHelper.isNullOrEmpty(value)) {
                              return 'Enter email';
                            }
                            if (BasicHelper.isEmailValid(value!)) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            _signUpFields.email = val!.trim();
                          },
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (value) {
                            if (BasicHelper.isNullOrEmpty(value)) {
                              return 'Enter password';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            _signUpFields.password = val!.trim();
                          },
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                      ],
                    )),
              ),
              ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          await AuthMethods().signUpWithEmail(
                              context, _formKey, _signUpFields);
                          setState(() {
                            isLoading = false;
                          });
                        },
                  child: Text('Sign up')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInEmail()),
                            (route) => false);
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.blue),
                      ))
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
