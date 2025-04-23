import 'package:flutter/material.dart';
import 'package:hamyon/controllers/wallet_controller.dart';
import 'package:hamyon/models/wallet_model.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

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

        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr("error_occurred").replaceFirst("{}", "$e")),
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.eskiWallet == null ? tr("add_expense") : tr("edit_expense"),
          ),
          DropdownButton<Locale>(
            value: context.locale,
            icon: Icon(Icons.language),
            underline: SizedBox(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) context.setLocale(newLocale);
            },
            items: [
              DropdownMenuItem(value: Locale('uz'), child: Text('UZ')),
              DropdownMenuItem(value: Locale('ru'), child: Text('RU')),
              DropdownMenuItem(value: Locale('en'), child: Text('EN')),
            ],
          ),
        ],
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
                  labelText: tr("expense_name"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return tr("enter_expense_name");
                  if (value.length < 6) return tr("enter_expense_name_detail");
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr("expense_amount"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return tr("enter_expense_amount");
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) return tr("amount_must_be_positive");
                  } catch (_) {
                    return tr("enter_valid_number");
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
                  labelText: tr("expense_date"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return tr("select_expense_date");
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(tr("cancel")),
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
                  : Text(tr("save")),
        ),
      ],
    );
  }
}
