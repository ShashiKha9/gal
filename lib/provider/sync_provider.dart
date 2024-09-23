import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/scaffold_message.dart';
import 'package:galaxy_mini/models/Item_model.dart';
import 'package:galaxy_mini/models/customer_model.dart';
import 'package:galaxy_mini/models/department_model.dart';
import 'package:galaxy_mini/models/kotgroup_model.dart';
import 'package:galaxy_mini/models/kotmessage_model.dart';
import 'package:galaxy_mini/models/offer_model.dart';
import 'package:galaxy_mini/models/payment_model.dart';
import 'package:galaxy_mini/models/table_model.dart';
import 'package:galaxy_mini/models/tablegroup_model.dart';
import 'package:galaxy_mini/models/tax_model.dart';
import 'package:galaxy_mini/repositories/sync_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncProvider extends ChangeNotifier {
  final syncRepo = SyncRepository();

  List<ItemModel> itemList = [];
  List<DepartmentModel> departmentList = [];
  List<TableGroupModel> tablegroupList = [];
  List<TableMasterModel> tablemasterList = [];
  List<KotGroupModel> kotgroupList = [];
  List<TaxModel> taxList = [];
  List<CustomerModel> customerList = [];
  List<PaymentModel> paymentList = [];
  List<OfferModel> offerList = [];
  List<KotMessageModel> kotmessageList = [];

  // Map to group items by department code
  Map<String, List<ItemModel>> itemsByDepartment = {};
  Map<String, List<TableMasterModel>> tablesByGroup = {};

  // Fetch items and organize them by department code
  Future<void> getItemsAll() async {
    try {
      final response = await syncRepo.getItem();
      log(response.toString(), name: 'response getItemsAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        log('Valid Status Code 200', name: 'Status Code Check');
        if (response['body'] != null && response['body'] is List) {
          itemList = List<ItemModel>.from(
            response['body'].map((e) => ItemModel.fromJson(e)),
          );
          log(itemList.toString(), name: 'Updated itemList');
          _organizeItemsByDepartment(); // Organize items after fetching
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getItemsAll', stackTrace: s);
    }
  }

  // Method to update the itemList and notify listeners
  void updateItemList(List<ItemModel> newList) {
    itemList = newList;
    _organizeItemsByDepartment(); // Ensure items are organized after the update
    notifyListeners();
  }

  // Fetch departments
  Future<void> getDepartmentsAll() async {
    try {
      final response = await syncRepo.getDepartment();
      log(response.toString(), name: 'response getDepartmentsAll');
      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        departmentList = List<DepartmentModel>.from(
          response["body"].map((e) => DepartmentModel.fromJson(e)),
        );
        notifyListeners();
      }
    } on SocketException catch (e) {
      scaffoldMessage(message: '$e');
    } catch (e, s) {
      log(e.toString(), name: 'error getDepartmentsAll', stackTrace: s);
    }
  }

  // Organize items by department code
  void _organizeItemsByDepartment() {
    itemsByDepartment.clear(); // Clear any previous data

    for (var item in itemList) {
      final departmentCode = item.departmentCode;

      if (departmentCode != null) {
        if (!itemsByDepartment.containsKey(departmentCode)) {
          itemsByDepartment[departmentCode] = [];
        }

        itemsByDepartment[departmentCode]?.add(item);
      }
    }
  }

  Future<void> getTableGroupAll() async {
    try {
      final response = await syncRepo.getTableGroup();
      log(response.toString(), name: 'response getTableGroupAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        log('Valid Status Code 200', name: 'Status Code Check');
        if (response['body'] != null && response['body'] is List) {
          tablegroupList = List<TableGroupModel>.from(
            response['body'].map((e) => TableGroupModel.fromJson(e)),
          );
          notifyListeners(); // Notify that table groups have been fetched
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getTableGroupAll', stackTrace: s);
    }
  }

  // Fetch all table masters from the API
  Future<void> getTableMasterAll() async {
    try {
      final response = await syncRepo.getTableMaster();
      log(response.toString(), name: 'response getTableMasterAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        log('Valid Status Code 200', name: 'Status Code Check');
        if (response['body'] != null && response['body'] is List) {
          tablemasterList = List<TableMasterModel>.from(
            response['body'].map((e) => TableMasterModel.fromJson(e)),
          );
          notifyListeners(); // Notify that table master data has been fetched
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getTableMasterAll', stackTrace: s);
    }
  }

  // Organize tables by group after fetching both groups and tables
  void organizeTablesByGroup() {
    tablesByGroup.clear(); // Clear previous data

    // Ensure each group code has an entry in the map
    for (var group in tablegroupList) {
      tablesByGroup[group.code] = []; // Initialize with an empty list

      // Add tables whose group matches the group code
      for (var table in tablemasterList) {
        if (table.group == group.code) {
          tablesByGroup[group.code]?.add(table);
        }
      }
    }

    notifyListeners(); // Notify the UI of changes
  }

  Future<void> getKotGroupAll() async {
    try {
      final response = await syncRepo.getKotGroup();
      log(response.toString(), name: 'response getKotGroupAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        log('Valid Status Code 200', name: 'Status Code Check');
        if (response['body'] != null && response['body'] is List) {
          kotgroupList = List<KotGroupModel>.from(
            response['body'].map((e) => KotGroupModel.fromJson(e)),
          );
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getKotGroupAll', stackTrace: s);
    }
  }

  Future<void> getTaxAll() async {
    try {
      final response = await syncRepo.getTax();
      log(response.toString(), name: 'response getTaxAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        if (response['body'] != null && response['body'] is List) {
          taxList = List<TaxModel>.from(
            response['body'].map((e) => TaxModel.fromJson(e)),
          );
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error TaxModelAll', stackTrace: s);
    }
  }

  Future<void> getCustomerAll() async {
    try {
      final response = await syncRepo.getcustomer();
      log(response.toString(), name: 'response getCustomerAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        if (response['body'] != null && response['body'] is List) {
          customerList = List<CustomerModel>.from(
            response['body'].map((e) => CustomerModel.fromJson(e)),
          );
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getCustomerAll', stackTrace: s);
    }
  }

  Future<void> getPaymentAll() async {
    try {
      final response = await syncRepo.getpayment();
      log(response.toString(), name: 'response getPaymentAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        if (response['body'] != null && response['body'] is List) {
          paymentList = List<PaymentModel>.from(
            response['body'].map((e) => PaymentModel.fromJson(e)),
          );
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getPaymentAll', stackTrace: s);
    }
  }

  Future<void> getOfferAll() async {
    try {
      final response = await syncRepo.getoffer();
      log(response.toString(), name: 'response getOfferAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        if (response['body'] != null && response['body'] is List) {
          offerList = List<OfferModel>.from(
            response['body'].map((e) => OfferModel.fromJson(e)),
          );
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getOfferAll', stackTrace: s);
    }
  }

  Future<void> getKotMessageAll() async {
    try {
      final response = await syncRepo.getkotmessage();
      log(response.toString(), name: 'response getKotMessageAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        if (response['body'] != null && response['body'] is List) {
          kotmessageList = List<KotMessageModel>.from(
            response['body'].map((e) => KotMessageModel.fromJson(e)),
          );
          notifyListeners();
        } else {
          log('Body is null or not a list', name: 'Body Issue');
        }
      } else {
        log('Invalid Status Code: $statusCode', name: 'Invalid Status Code');
      }
    } catch (e, s) {
      log(e.toString(), name: 'error getKotMessageAll', stackTrace: s);
    }
  }

// Save the reordered department list in SharedPreferences
  Future<void> saveDepartmentsOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> departmentOrder = departmentList.map((d) => d.code).toList();
    if (departmentOrder.isNotEmpty) {
      await prefs.setStringList('departments_order', departmentOrder);
    }
  }

// Load the reordered department list from SharedPreferences
  Future<void> loadDepartmentsOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? departmentOrder = prefs.getStringList('departments_order');
    if (departmentOrder != null && departmentOrder.isNotEmpty) {
      departmentList.sort((a, b) {
        int indexA = departmentOrder.indexOf(a.code);
        int indexB = departmentOrder.indexOf(b.code);
        return indexA.compareTo(indexB);
      });
    }

    notifyListeners(); // Notify listeners to update the UI with the new order
  }

  Future<void> saveItemsOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> orderedItemNames = itemList.map((item) => item.name!).toList();
    await prefs.setStringList('items_order', orderedItemNames);
  }

  // Method to load the saved order
  Future<void> loadItemsOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? orderedItemNames = prefs.getStringList('items_order');

    if (orderedItemNames != null) {
      itemList.sort((a, b) => orderedItemNames
          .indexOf(a.name!)
          .compareTo(orderedItemNames.indexOf(b.name!)));
    }

    notifyListeners(); // Ensure that UI updates after loading the order
  }

  void updateDepartmentName(String code, String newName) {
    final department = departmentList.firstWhere((d) => d.code == code);
    department.description = newName;
    notifyListeners(); // Notify listeners to update UI
  }

  void updateTableName(String code, String newName) {
    final table = tablemasterList.firstWhere((t) => t.code == code);
    table.name = newName;
    notifyListeners(); // Notify listeners to update UI
  }

  void updateKotmessage(String code, String newmessage) {
    final kotmessage = kotmessageList.firstWhere((k) => k.code == code);
    kotmessage.description = newmessage;
    notifyListeners(); // Notify listeners to update UI
  }

void updateTableGroup(String groupCode, String newName, String description) {
  // Ensure you find the correct group
  final groupIndex = tablegroupList.indexWhere((g) => g.code == groupCode);
  if (groupIndex != -1) {
    tablegroupList[groupIndex].name = newName; // Update the name
    notifyListeners(); // Notify listeners to refresh the UI
  }
}

  void addKotMessage(String description) {
    final newKotMessage = KotMessageModel(
      code: 'KOT-${kotmessageList.length + 1}', // Generate a new code
      description: description,
      isSynced: false, // Set to false or adjust based on your logic
      addDate: DateTime.now(),
      updateDate: DateTime.now(),
    );

    kotmessageList.add(newKotMessage);
    notifyListeners(); // Notify listeners to update UI
  }

  void updateKotGroup(String code, String newName, String newDescription) {
    final kotGroup = kotgroupList.firstWhere((k) => k.code == code);
    kotGroup.name = newName;
    kotGroup.description = newDescription;
    notifyListeners(); // Notify listeners to update UI
  }

  void updateModeType(String id, String newType) {
    final mode = paymentList.firstWhere((t) => t.id == id);
    mode.type = newType;
    notifyListeners(); // Notify listeners to update UI
  }

  void updateOffer(
      String offerCouponId,
      String newCouponCode,
      String newNote,
      String newDiscountInPercent,
      String newMaxDiscount,
      String newMinBillAmount,
      String newValidity) {
    final coupon =
        offerList.firstWhere((t) => t.offerCouponId == offerCouponId);

    coupon.couponCode = newCouponCode;
    coupon.note = newNote;
    coupon.discountInPercent = newDiscountInPercent;
    coupon.maxDiscount = newMaxDiscount;
    coupon.minBillAmount = newMinBillAmount;
    coupon.validity = newValidity;

    notifyListeners(); // Notify listeners to update UI
  }

  Future<void> fetchAndOrganizeTables() async {
    await getTableGroupAll(); // Fetch the table groups
    await getTableMasterAll(); // Fetch the table masters

    // Once both groups and tables are fetched, organize the tables by group
    organizeTablesByGroup();
  }
}
