import 'package:firebase_auth/firebase_auth.dart';
import 'package:live_chat_messenger/services/basic_helper.dart';
import 'package:live_chat_messenger/services/sharedpref_helper.dart';
import 'package:live_chat_messenger/screens/signin_email.dart';
import 'package:live_chat_messenger/screens/signup_email.dart';
import 'package:live_chat_messenger/services/database.dart';
import 'package:live_chat_messenger/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future _saveUserDataInSharedPreferenceHelper(User? user,
      {String? displayName}) async {
    await SharedPreferenceHelper().saveUserEmail(user!.email.toString());
    await SharedPreferenceHelper().saveUserId(user.uid.toString());
    await SharedPreferenceHelper()
        .saveUserName(user.email!.replaceAll("@gmail.com", ""));
    await SharedPreferenceHelper()
        .saveDisplayName(user.displayName ?? displayName!);
    await SharedPreferenceHelper().saveUserProfileUrl(user.photoURL.toString());
    return;
  }

// email/password sign-up
  Future signUpWithEmail(BuildContext context, GlobalKey<FormState> formKey,
      SignUpFields signUpFields) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
              email: signUpFields.email, password: signUpFields.password);
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(signUpFields.name);
        await _saveUserDataInSharedPreferenceHelper(userCredential.user,
            displayName: signUpFields.name);

        Map<String, dynamic> userInfoMap = {
          "email": userCredential.user!.email,
          "username": userCredential.user!.email!.replaceAll("@gmail.com", ""),
          "name": signUpFields.name,
          "imgUrl": userCredential.user!.photoURL
        };

        DatabaseMethods()
            .addUserInfoToDB(userCredential.user!.uid, userInfoMap)
            .then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (route) => false);
        });
      }
    } on FirebaseAuthException catch (error) {
      BasicHelper.showSnackBar(
          context,
          error.message ?? 'Something went wrong.Try again',
          BasicHelper.snackBarError);
    } catch (error) {
      BasicHelper.showSnackBar(
          context, 'Something went wrong.Try agin', BasicHelper.snackBarError);
    }
    return;
  }

// email/password sign-in
  Future signInWithEmail(BuildContext context, GlobalKey<FormState> formKey,
      SignInFields signInFields) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: signInFields.email, password: signInFields.password);
      if (userCredential.user != null) {
        await _saveUserDataInSharedPreferenceHelper(userCredential.user);
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Home()), (route) => false);
      }
    } on FirebaseAuthException catch (error) {
      BasicHelper.showSnackBar(
          context,
          error.message ?? 'Something went wrong.Try again',
          BasicHelper.snackBarError);
    } catch (error) {
      BasicHelper.showSnackBar(
          context, 'Something went wrong.Try agin', BasicHelper.snackBarError);
    }
    return;
  }

// google sign-in
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;

    if (result != null) {
      SharedPreferenceHelper().saveUserEmail(userDetails!.email.toString());
      SharedPreferenceHelper().saveUserId(userDetails.uid.toString());
      SharedPreferenceHelper()
          .saveUserName(userDetails.email!.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper()
          .saveDisplayName(userDetails.displayName.toString());
      SharedPreferenceHelper()
          .saveUserProfileUrl(userDetails.photoURL.toString());

      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email!.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL
      };

      DatabaseMethods()
          .addUserInfoToDB(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Home()), (route) => false);
      });
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}
