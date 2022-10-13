import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAME";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEKEY";

  // save data
  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveDisplayName(String getDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayNameKey, getDisplayName);
  }

  Future<bool> saveUserProfileUrl(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfilePicKey, getUserProfile);
  }

  // get data
  Future<dynamic> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getString(userNameKey));
  }

  Future<dynamic> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getString(userEmailKey));
  }

  Future<dynamic> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getString(userIdKey));
  }

  Future<dynamic> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getString(displayNameKey));
  }

  Future<dynamic> getProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getString(userProfilePicKey));
  }
}
