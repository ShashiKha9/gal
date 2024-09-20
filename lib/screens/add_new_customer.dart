import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/customer_provider.dart';

class AddNewCustomer extends StatefulWidget {
  const AddNewCustomer({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  _AddNewCustomerState createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alternateMobileController =
      TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _extra1Controller = TextEditingController();
  final TextEditingController _extra2Controller = TextEditingController();
  final TextEditingController _extra3Controller = TextEditingController();

  bool isPremiumMember = false;
  bool isBlocklistedMember = false;

  final customerProvider = CustomerProvider();

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      log('Customer Saved');
    }
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: widget.isEdit ? "Edit Customer" : "Add New Customer",
        isMenu: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextfield(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              AppTextfield(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              AppTextfield(
                controller: _mobileController,
                labelText: 'Mobile No.',
                keyBoardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  } else if (value.length < 10) {
                    return 'Mobile number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              AppTextfield(
                controller: _alternateMobileController,
                labelText: 'Alternate Mobile No.',
                keyBoardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  } else if (value.length < 10) {
                    return 'Mobile number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              AppTextfield(
                controller: _landlineController,
                labelText: 'Landline No.',
                keyBoardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  } else if (value.length < 10) {
                    return 'Mobile number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              AppTextfield(
                controller: _addressController,
                labelText: 'Address',
              ),
              AppTextfield(
                controller: _address2Controller,
                labelText: 'Address 2',
              ),
              AppTextfield(
                controller: _birthdateController,
                labelText: 'Birthdate',
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _selectBirthdate();
                },
              ),
              AppTextfield(
                controller: _gstController,
                labelText: 'GST No.',
              ),
              Row(
                children: [
                  Checkbox(
                    value: isPremiumMember,
                    onChanged: (bool? value) {
                      setState(() {
                        isPremiumMember = value ?? false;
                      });
                    },
                  ),
                  const Text('Premium Member'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isBlocklistedMember,
                    onChanged: (bool? value) {
                      setState(() {
                        isBlocklistedMember = value ?? false;
                      });
                    },
                  ),
                  const Text('Blocklisted Member'),
                ],
              ),
              AppTextfield(
                controller: _noteController,
                labelText: 'Note',
              ),
              AppTextfield(
                controller: _extra1Controller,
                labelText: 'Extra 1',
              ),
              AppTextfield(
                controller: _extra2Controller,
                labelText: 'Extra 2',
              ),
              AppTextfield(
                controller: _extra3Controller,
                labelText: 'Extra 3',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saveCustomer,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ]
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: e,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
