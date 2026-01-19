import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String? ogrenciNo;
  String? ad;

  bool get isLoggedIn => ogrenciNo != null;

  void setUser({
    required String? ogrenciNo,
    required String ad,
  }) {
    this.ogrenciNo = ogrenciNo;
    this.ad = ad;
    notifyListeners();
  }

  void logout() {
    ogrenciNo = null;
    ad = null;
    notifyListeners();
  }
}
