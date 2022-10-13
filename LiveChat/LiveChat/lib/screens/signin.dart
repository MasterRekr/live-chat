import 'package:live_chat_messenger/screens/signin_email.dart';
import 'package:live_chat_messenger/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({
    Key? key,
  }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topRight,
                    colors: [
                  Color.fromRGBO(0, 27, 105, 1),
                  Color.fromRGBO(0, 210, 255, 1)
                ])),
            child: Column(children: [
              SizedBox(height: 80),
              Container(
                height: 200.0,
                width: 200.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/AppIconTransparent.png'),
                        fit: BoxFit.fill),
                    shape: BoxShape.circle),
              ),
              SizedBox(height: 50),
              Text('WELCOME BACK', style: GoogleFonts.bebasNeue(fontSize: 62)),
              SizedBox(height: 20),
              Text('Let\'s get you signed in!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                      onTap: () {
                        AuthMethods().signInWithGoogle(context);
                      },
                      child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(
                            'Sign In with google',
                            style: TextStyle(fontSize: 20),
                          ))))),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInEmail()),
                                  (route) => false);
                      },
                      child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(
                            'Sign In with email',
                            style: TextStyle(fontSize: 20),
                          ))))),
            ])),
      ),
    );
  }
}
