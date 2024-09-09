import 'dart:developer';

import 'package:flutter/material.dart';

class AddNewCustomer extends StatefulWidget {
  const AddNewCustomer({super.key});

  @override
  _AddNewCustomerState createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alternateMobileController = TextEditingController();
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

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      // Handle save logic here
      log('Customer Saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile No.'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _alternateMobileController,
                decoration: const InputDecoration(labelText: 'Alternate Mobile No.'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _landlineController,
                decoration: const InputDecoration(labelText: 'Landline No.'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(labelText: 'Address 2'),
              ),
              TextFormField(
                controller: _birthdateController,
                decoration: const InputDecoration(labelText: 'Birthdate'),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(labelText: 'GST No.'),
              ),
              const SizedBox(height: 16.0),
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
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              TextFormField(
                controller: _extra1Controller,
                decoration: const InputDecoration(labelText: 'Extra 1'),
              ),
              TextFormField(
                controller: _extra2Controller,
                decoration: const InputDecoration(labelText: 'Extra 2'),
              ),
              TextFormField(
                controller: _extra3Controller,
                decoration: const InputDecoration(labelText: 'Extra 3'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel action
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saveCustomer,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
