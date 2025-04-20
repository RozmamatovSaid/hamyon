import 'package:flutter/material.dart';
import 'package:hamyon/controllers/wallet_controller.dart';
import 'package:hamyon/datacourse/local_datacourse.dart';
import 'package:hamyon/views/widgets/manage_wallet_dialog.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _balanceController = TextEditingController();
  final _localDatacourse = LocalDatacourse();
  final _walletController = WalletController();

  double _costs = 0.0;
  bool _isLoading = false;
  String _balance = "0";
  String _percentage = "0.0";
  String _currentMonth = "";
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentMonth = _monthName(DateTime.now().month);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getLocalDatabase();
    await _walletController.getWallets();
    _calculateCosts();
    if (mounted) setState(() {});
  }

  Future<void> _getLocalDatabase() async {
    final getedData = await _localDatacourse.getBalance();
    if (mounted) {
      setState(() {
        _balance = getedData.toString();
      });
    }
  }

  void _calculateCosts() {
    _costs = _walletController.wallets.fold(0, (sum, e) => sum + e.cost);
    double balanceValue = double.tryParse(_balance) ?? 0;
    double percentValue = _costs > 0 ? ((_costs / balanceValue) * 100) : 0;
    _percentage = percentValue.toStringAsFixed(1);
  }

  Future<void> _setBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      double amount = double.tryParse(_balanceController.text) ?? 0;
      await _localDatacourse.saveBalance(amount);
      await _getLocalDatabase();
      _calculateCosts();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  void _showBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hisobni yangilash'),
          content: TextFormField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Hisob miqdori",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.account_balance_wallet),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text("Bekor qilish"),
            ),
            FilledButton(
              onPressed: _isLoading ? null : _setBalance,
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text("Saqlash"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _manageWallet([dynamic wallet]) async {
    try {
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ManageWalletDialog(eskiWallet: wallet),
      );

      if (result == true) {
        _calculateCosts();
        setState(() {});
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _manageWallet,
        autofocus: true,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      appBar: AppBar(
        title: Text(_monthName(_currentDate.month)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            print(DateTime.now());
            final now = DateTime.now();
            final previousMonth = DateTime(now.year, now.month - 1);
            setState(() {
              _currentMonth = _monthName(previousMonth.month);
            });
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final now = DateTime.now();
              final nextMonth = DateTime(now.year, now.month + 1);
              setState(() {
                _currentMonth = _monthName(nextMonth.month);
              });
            },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Umumiy Xarajatlar
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  const Text(
                    "Umumiy xarajatlar",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${NumberFormat("#,###").format(_costs)} so`m",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Balans bo'limi
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 600,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _showBalanceDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "${NumberFormat("#,###").format(double.parse(_balance))} so`m",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$_percentage %",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  (double.tryParse(_percentage) ?? 0) < 1.0
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (double.tryParse(_percentage) ?? 0) / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Amaliyotlar ro'yxati
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 450,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amaliyotlar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          _walletController.wallets.isEmpty
                              ? const Center(
                                child: Text(
                                  "Amaliyotlar mavjud emas",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemBuilder: (contex, index) {
                                  final wallet =
                                      _walletController.wallets[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Dismissible(
                                      key: Key(wallet.id.toString()),
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (direction) async {
                                        return await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("O'chirish"),
                                              content: Text(
                                                "${wallet.title} ni o'chirishni xohlaysizmi?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  child: const Text("Yo'q"),
                                                ),
                                                FilledButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(true),
                                                  child: const Text("Ha"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onDismissed: (direction) {
                                        _walletController.deleteWallet(
                                          wallet.id,
                                        );
                                        _initializeData();
                                        setState(() {
                                          _calculateCosts();
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${wallet.title} o'chirildi",
                                            ),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            action: SnackBarAction(
                                              label: 'Bekor qilish',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                setState(() {
                                                  _calculateCosts();
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          onTap: () => _manageWallet(wallet),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                          leading: CircleAvatar(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                            child: Text(
                                              wallet.title[0].toUpperCase(),
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            wallet.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            _formatDate(wallet.date),
                                          ),
                                          trailing: Text(
                                            "${NumberFormat("#,###").format(wallet.cost)} so'm",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 12),
                                itemCount: _walletController.wallets.length,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${_monthName(date.month)}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avgust',
      'sentabr',
      'oktabr',
      'noyabr',
      'dekabr',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }
}
