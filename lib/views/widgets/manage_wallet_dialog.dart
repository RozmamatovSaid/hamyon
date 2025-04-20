import 'package:flutter/material.dart';
import 'package:hamyon/controllers/wallet_controller.dart';
import 'package:hamyon/models/wallet_model.dart';
import 'package:intl/intl.dart'; // Sana formatini chiroyli ko'rsatish uchun

class ManageWalletDialog extends StatefulWidget {
  final WalletModel? eskiWallet;
  const ManageWalletDialog({super.key, this.eskiWallet});

  @override
  State<ManageWalletDialog> createState() => _ManageWalletDialogState();
}

class _ManageWalletDialogState extends State<ManageWalletDialog> {
  final walletController = WalletController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.eskiWallet != null) {
      _nameController.text = widget.eskiWallet!.title;
      _amountController.text = widget.eskiWallet!.cost.toString();
      _selectedDate = widget.eskiWallet!.date;
      _dateController.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(_selectedDate!);
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(_selectedDate!);
    }
  }

  void showCalendar() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (time != null) {
        final DateTime fullDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _selectedDate = fullDateTime;
          _dateController.text = DateFormat(
            'yyyy-MM-dd HH:mm',
          ).format(fullDateTime);
        });
      }
    }
  }

  void save() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        final title = _nameController.text;
        final date = _selectedDate!;
        final cost = double.parse(_amountController.text);

        if (widget.eskiWallet == null) {
          await walletController.addWallet(
            title: title,
            date: date,
            cost: cost,
          );
        } else {
          final updatedWallet = widget.eskiWallet!.copyWith(
            title: title,
            date: date,
            cost: cost,
          );
          await walletController.editWallet(updatedWallet);
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e, s) {
      print(e);
      print(s);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xatolik yuz berdi: $e"),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.eskiWallet == null
            ? "Xarajat qo`shish"
            : "Xarajatni o`zgartirish",
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Xarajat nomi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Iltimos xarajat nomini kiriting";
                  }

                  if (value.length < 6) {
                    return "Iltimos batajsil xarajatni kiriting";
                  }

                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Xarajat miqdori",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Iltimos xarajat miqdorini kiriting";
                  }

                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return "Miqdor noldan katta bo'lishi kerak";
                    }
                  } catch (e) {
                    return "Iltimos to'g'ri raqam kiriting";
                  }

                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                onTap: showCalendar,
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Xarajat kuni",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Iltimos xarajat kunini tanlang";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading
                  ? null // Yuklash paytida o'chirilgan
                  : () => Navigator.pop(context),
          child: Text("Bekor Qilish"),
        ),
        FilledButton(
          onPressed: _isLoading ? null : save,
          child:
              _isLoading
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text("Saqlash"),
        ),
      ],
    );
  }
}
