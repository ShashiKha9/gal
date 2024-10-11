import 'dart:convert';
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
import 'package:galaxy_mini/models/unit_model.dart';
import 'package:galaxy_mini/repositories/sync_repository.dart';
import 'package:galaxy_mini/screens/auth/login.dart';
import 'package:galaxy_mini/utils/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncProvider extends ChangeNotifier {
  final syncRepo = SyncRepository();
  final mySharedPreferences = MySharedPreferences.instance;
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
  List<UnitModel> unitList = [];

  // Map to group items by department code
  Map<String, List<ItemModel>> itemsByDepartment = {};
  Map<String, List<TableMasterModel>> tablesByGroup = {};

  // Fetch items and organize them by department code
  // Fetch items and save to SharedPreferences
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
          _organizeItemsByDepartment();
          await saveItemsByDepartmentToPrefs(itemsByDepartment);

          notifyListeners();

          // Save the updated itemList to SharedPreferences
          await saveItemListToPrefs(itemList);
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
  // void updateItemList(List<ItemModel> newList) {
  //   itemList = newList;
  //   _organizeItemsByDepartment(); // Ensure items are organized after the update
  //   notifyListeners();
  // }

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
        // Save the updated itemList to SharedPreferences
        await _saveDepartmentListToPrefs(departmentList);
      }
    } on SocketException catch (e) {
      scaffoldMessage(message: '$e');
    } catch (e, s) {
      log(e.toString(), name: 'error getDepartmentsAll', stackTrace: s);
    }
  }

  // Method to save departmentList to SharedPreferences
  Future<void> _saveDepartmentListToPrefs(
      List<DepartmentModel> departments) async {
    List<String> jsonList =
        departments.map((dept) => jsonEncode(dept.toJson())).toList();
    await mySharedPreferences.setStringList('departmentList', jsonList);
  }

  // Method to load departmentList from SharedPreferences
  Future<void> loadDepartmentListFromPrefs() async {
    List<String>? jsonList =
        await mySharedPreferences.getStringList('departmentList');
    if (jsonList != null) {
      departmentList = jsonList
          .map((jsonItem) => DepartmentModel.fromJson(jsonDecode(jsonItem)))
          .toList();
      log(departmentList.toString(), name: 'departmentlist');
      notifyListeners(); // Notify listeners if departmentList is updated
    }
  }

  Future<void> saveItemsByDepartmentToPrefs(
      Map<String, List<ItemModel>> itemsByDept) async {
    Map<String, List<String>> serializedMap = {};

    itemsByDept.forEach((departmentCode, items) {
      serializedMap[departmentCode] =
          items.map((item) => jsonEncode(item.toJson())).toList();
    });

    String jsonString = jsonEncode(serializedMap);
    await mySharedPreferences.setStringValue('itemsByDepartment', jsonString);
  }

  Future<void> loadItemsByDepartmentFromPrefs() async {
    String? jsonString =
        await mySharedPreferences.getStringValue('itemsByDepartment');

    if (jsonString != null) {
      Map<String, dynamic> decodedMap = jsonDecode(jsonString);
      itemsByDepartment.clear();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      log("SharedPreferences instance loaded");

      decodedMap.forEach((departmentCode, items) {
        List<ItemModel> itemList = List<ItemModel>.from(
          (items as List).map((jsonItem) {
            ItemModel item = ItemModel.fromJson(jsonDecode(jsonItem));
            String itemCode = item.code ?? 'unknown_item';

            // Retrieve the edited name from SharedPreferences
            String? editedName = prefs.getString('name_$itemCode');

            // Retrieve the edited rate1 from SharedPreferences and cast it as a String?
            String? editedRate1 = prefs.getString('rate1_$itemCode');

            // Fallback to item's original rate1 if the editedRate1 is null or invalid
            String? rate1 = editedRate1 != null && editedRate1.isNotEmpty
                ? num.tryParse(editedRate1)?.toString() ?? item.rate1
                : item.rate1;

            // Use the copyWith method to create a new item with the updated name and rate1
            if (editedName != null && editedName.isNotEmpty) {
              item = item.copyWith(name: editedName, rate1: rate1);
            } else {
              // Only update rate1 if the name isn't edited
              item = item.copyWith(rate1: rate1);
            }

            return item;
          }),
        );
        itemsByDepartment[departmentCode] = itemList;
      });

      notifyListeners();
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
          organizeTablesByGroup();
          await _saveTableGroupListToPrefs(tablegroupList);
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

  Future<void> _saveTableGroupListToPrefs(
      List<TableGroupModel> tableGroup) async {
    List<String> jsonList = tableGroup
        .map((tablegroup) => jsonEncode(tablegroup.toJson()))
        .toList();
    await mySharedPreferences.setStringList('tableGroup', jsonList);
  }

  Future<void> loadTableGroupListFromPrefs() async {
    List<String>? jsonList =
        await mySharedPreferences.getStringList('tableGroup');
    if (jsonList != null) {
      tablegroupList = jsonList
          .map((jsonItem) => TableGroupModel.fromJson(jsonDecode(jsonItem)))
          .toList();
      log(tablegroupList.toString(), name: 'TableGroupList');
      notifyListeners(); // Notify listeners if departmentList is updated
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
          organizeTablesByGroup();
          await _saveTableMasterListToPrefs(tablemasterList);
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

  Future<void> _saveTableMasterListToPrefs(
      List<TableMasterModel> tableGroup) async {
    List<String> jsonList = tableGroup
        .map((tablemaster) => jsonEncode(tablemaster.toJson()))
        .toList();
    await mySharedPreferences.setStringList('tableMaster', jsonList);
  }

  Future<void> loadTableMasterListFromPrefs() async {
    List<String>? jsonList =
        await mySharedPreferences.getStringList('tableMaster');
    if (jsonList != null) {
      tablemasterList = jsonList
          .map((jsonItem) => TableMasterModel.fromJson(jsonDecode(jsonItem)))
          .toList();
      log(tablegroupList.toString(), name: 'TableMasterList');
      notifyListeners(); // Notify listeners if departmentList is updated
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
          await saveKotGroupOrder(kotgroupList);
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

  Future<void> saveKotGroupOrder(List<KotGroupModel> items) async {
    List<String> jsonList =
        items.map((item) => jsonEncode(item.toJson())).toList();

    await mySharedPreferences.setStringList('kot_group', jsonList);
  }

  // Method to load the saved order
  Future<void> loadKotGroupOrder() async {
    List<String>? jsonList =
        await mySharedPreferences.getStringList('kot_group');

    if (jsonList != null) {
      kotgroupList = jsonList
          .map((jsonItem) => KotGroupModel.fromJson(jsonDecode(jsonItem)))
          .toList();
      notifyListeners(); // Notify listeners if itemList is updated
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
          await saveTaxAll(taxList);
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

  Future<void> saveTaxAll(List<TaxModel> taxAll) async {
    List<String> jsonList =
        taxAll.map((item) => jsonEncode(item.toJson())).toList();

    await mySharedPreferences.setStringList('taxAll', jsonList);
  }

  Future<void> loadTaxAll() async {
    List<String>? jsonList = await mySharedPreferences.getStringList('taxAll');

    if (jsonList != null) {
      taxList = jsonList
          .map((jsonItem) => TaxModel.fromJson(jsonDecode(jsonItem)))
          .toList();
      notifyListeners();
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

          // Save the updated customerList to SharedPreferences
          await saveCustomerListToPrefs(customerList);
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

  // Method to save customerList to SharedPreferences
  Future<void> saveCustomerListToPrefs(List<CustomerModel> customers) async {
    // Convert customer list to a list of JSON strings
    List<String> jsonList =
        customers.map((customer) => jsonEncode(customer.toJson())).toList();

    // Save the list of JSON strings to SharedPreferences
    await mySharedPreferences.setStringList('customerList', jsonList);
  }

// Method to load customerList from SharedPreferences
  Future<void> loadCustomerListFromPrefs() async {
    // Retrieve the list of JSON strings from SharedPreferences
    List<String>? jsonList =
        await mySharedPreferences.getStringList('customerList');

    if (jsonList != null) {
      // Convert JSON strings back to CustomerModel objects
      customerList = jsonList
          .map((jsonCustomer) =>
              CustomerModel.fromJson(jsonDecode(jsonCustomer)))
          .toList();
      notifyListeners(); // Notify listeners to update the UI
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
          await savePaymetListToPrefs(paymentList);
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

  // Method to save customerList to SharedPreferences
  Future<void> savePaymetListToPrefs(List<PaymentModel> payment) async {
    // Convert customer list to a list of JSON strings
    List<String> jsonList =
        payment.map((payment) => jsonEncode(payment.toJson())).toList();

    // Save the list of JSON strings to SharedPreferences
    await mySharedPreferences.setStringList('paymentList', jsonList);
  }

// Method to load customerList from SharedPreferences
  Future<void> loadPaymentListFromPrefs() async {
    // Retrieve the list of JSON strings from SharedPreferences
    List<String>? jsonList =
        await mySharedPreferences.getStringList('paymentList');

    if (jsonList != null) {
      // Convert JSON strings back to CustomerModel objects
      paymentList = jsonList
          .map((jsonPayment) => PaymentModel.fromJson(jsonDecode(jsonPayment)))
          .toList();
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Save the selected payment index to SharedPreferences
  Future<void> saveSelectedPaymentIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedPaymentIndex', index);
  }

  // Load the selected payment index from SharedPreferences
  Future<int> loadSelectedPaymentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedPaymentIndex') ?? -1;
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
          await saveOfferListToPrefs(offerList);
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

  // Method to save customerList to SharedPreferences
  Future<void> saveOfferListToPrefs(List<OfferModel> offer) async {
    // Convert customer list to a list of JSON strings
    List<String> jsonList =
        offer.map((offer) => jsonEncode(offer.toJson())).toList();

    // Save the list of JSON strings to SharedPreferences
    await mySharedPreferences.setStringList('offerList', jsonList);
  }

// Method to load customerList from SharedPreferences
  Future<void> loadOfferListFromPrefs() async {
    // Retrieve the list of JSON strings from SharedPreferences
    List<String>? jsonList =
        await mySharedPreferences.getStringList('offerList');

    if (jsonList != null) {
      // Convert JSON strings back to CustomerModel objects
      offerList = jsonList
          .map((jsonOffer) => OfferModel.fromJson(jsonDecode(jsonOffer)))
          .toList();
      notifyListeners(); // Notify listeners to update the UI
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
          await saveKotMessageListToPrefs(kotmessageList);
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

  Future<void> getUnitsAll() async {
    try {
      final response = await syncRepo.getUnit();
      log(response.toString(), name: 'response getUnitsAll');

      final statusCode = int.tryParse(response['status_code'].toString());
      if (statusCode == 200) {
        log('Valid Status Code 200', name: 'Status Code Check');
        if (response['body'] != null && response['body'] is List) {
          unitList = List<UnitModel>.from(
            response['body'].map((e) => UnitModel.fromJson(e)),
          );
          log(unitList.toString(), name: 'Updated unitList');
          await saveUnitAll(unitList);
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

  Future<void> saveUnitAll(List<UnitModel> unitListAll) async {
    List<String> jsonList =
        unitListAll.map((unitAll) => jsonEncode(unitAll.toJson())).toList();
    await mySharedPreferences.setStringList('UnitAll', jsonList);
  }

  Future<void> loadUnitAll() async {
    List<String>? unitAll = await mySharedPreferences.getStringList('UnitAll');
    if (unitAll != null) {
      unitList = unitAll
          .map((unitList) => UnitModel.fromJson(jsonDecode(unitList)))
          .toList();
      notifyListeners();
    }
  }

  // Method to save customerList to SharedPreferences
  Future<void> saveKotMessageListToPrefs(
      List<KotMessageModel> kotmessage) async {
    // Convert customer list to a list of JSON strings
    List<String> jsonList =
        kotmessage.map((kotmsg) => jsonEncode(kotmsg.toJson())).toList();

    // Save the list of JSON strings to SharedPreferences
    await mySharedPreferences.setStringList('kotMessageList', jsonList);
  }

// Method to load customerList from SharedPreferences
  Future<void> loadKotMessageListFromPrefs() async {
    // Retrieve the list of JSON strings from SharedPreferences
    List<String>? jsonList =
        await mySharedPreferences.getStringList('kotMessageList');

    if (jsonList != null) {
      // Convert JSON strings back to CustomerModel objects
      kotmessageList = jsonList
          .map((jsonkotMessage) =>
              KotMessageModel.fromJson(jsonDecode(jsonkotMessage)))
          .toList();
      notifyListeners(); // Notify listeners to update the UI
    }
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
    await loadTableGroupListFromPrefs();
    await loadTableMasterListFromPrefs();
    // await getTableGroupAll(); // Fetch the table groups
    // await getTableMasterAll(); // Fetch the table masters

    // Once both groups and tables are fetched, organize the tables by group
    organizeTablesByGroup();
  }

  // Method to save itemList to SharedPreferences
  Future<void> saveItemListToPrefs(List<ItemModel> items) async {
    List<String> jsonList =
        items.map((item) => jsonEncode(item.toJson())).toList();
    List<String> orderedItemNames = items.map((item) => item.name!).toList();
    await mySharedPreferences.setStringList('itemList', jsonList);
    await mySharedPreferences.setStringList('items_order', orderedItemNames);
  }

// Method to load itemList from SharedPreferences
  Future<void> loadItemListFromPrefs() async {
    List<String>? jsonList =
        await mySharedPreferences.getStringList('itemList');
    List<String>? orderedItemNames =
        await mySharedPreferences.getStringList('items_order');

    if (jsonList != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      log("SharedPreferences instance loaded");

      // Map jsonList to ItemModel and apply edits from SharedPreferences
      itemList = jsonList.map((jsonItem) {
        ItemModel item = ItemModel.fromJson(jsonDecode(jsonItem));
        String itemCode = item.code ?? 'unknown_item';

        // Retrieve the edited name and rate1 from SharedPreferences, if available
        String? editedName = prefs.getString('name_$itemCode');
        String? editedRate1 = prefs.getString('rate1_$itemCode');

        // Handle the isHot field - convert String 'true'/'false' to a boolean
        bool isHot = prefs.getBool('is_hot_item_$itemCode') ??
            (item.isHot?.toLowerCase() == 'true');

        // Apply the edited values only if they exist, else use original values
        String? rate1 = editedRate1 != null && editedRate1.isNotEmpty
            ? num.tryParse(editedRate1)?.toString() ?? item.rate1
            : item.rate1;

        // Use the edited name if available; otherwise, keep the original name
        String? name = editedName != null && editedName.isNotEmpty
            ? editedName
            : item.name;

        // Update the item using copyWith for the name, rate1, and isHot
        item = item.copyWith(name: name, rate1: rate1, isHot: isHot.toString());

        // Return the item regardless of edits, but filter by isHot later
        return item;
      }).toList();

      // Filter the itemList to only include hot items
      itemList = itemList
          .where((item) => item.isHot?.toLowerCase() == 'true')
          .toList();

      notifyListeners(); // Notify listeners if itemList is updated
    }

    if (orderedItemNames != null) {
      itemList.sort((a, b) => orderedItemNames
          .indexOf(a.name!)
          .compareTo(orderedItemNames.indexOf(b.name!)));
      notifyListeners();
    }
  }

  // Add the logout method to clear SharedPreferences and notify listeners
  Future<void> logout(BuildContext context) async {
    try {
      // Clear the SharedPreferences
      // await mySharedPreferences.removeAll();

      // // Clear the local itemList as well
      // itemList = [];
      // customerList = [];
      // offerList = [];
      // paymentList = [];
      // kotgroupList = [];
      // kotmessageList = [];
      // departmentList = [];
      // tablemasterList = [];
      // tablegroupList = [];

      // Notify listeners to update UI
      notifyListeners();

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      log('Logout error: $e');
    }
  }
}
