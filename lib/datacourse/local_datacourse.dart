import 'package:shared_preferences/shared_preferences.dart';

class LocalDatacourse {
  final _keyName = "balance";

  Future<void> saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyName, balance);
  }

  Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyName) ?? 0.0;
  }

  Future<void> removeBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
  }
}
