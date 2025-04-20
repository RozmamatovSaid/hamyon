import 'package:hamyon/models/wallet_model.dart';
import 'package:hamyon/services/local_database.dart';

class WalletController {
  WalletController._();

  static final _private = WalletController._();

  factory WalletController() {
    return _private;
  }

  final _localDatabase = LocalDatabase();
  List<WalletModel> wallets = [];

  Future<void> getWallets() async {
    try {
      wallets = await _localDatabase.get();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addWallet({
    required String title,
    required DateTime date,
    required double cost,
  }) async {
    try {
      final newWallet = WalletModel(
        id: -1,
        title: title,
        date: date,
        cost: cost,
      );
      final id = await _localDatabase.insert(newWallet);

      wallets.add(newWallet.copyWith(id: id));
      print(id);
    } catch (e) {
      print(e);
    }
  }

  Future<void> editWallet(WalletModel wallet) async {
    try {
      await _localDatabase.update(wallet);
      final currentIndex = wallets.indexWhere((t) => t.id == wallet.id);
      wallets[currentIndex] = wallet;
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet(int id) async {
    try {
      await _localDatabase.delete(id);
      wallets.removeWhere((t) => t.id == id);
    } catch (e) {
      print(e);
    }
  }
}
