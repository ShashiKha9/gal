import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:galaxy_mini/utils/api_urls.dart';
import 'package:galaxy_mini/repositories/base_repository.dart';

class SyncRepository extends BaseRepository {
  // getItem - updated to handle exceptions
  Future<Map<String, dynamic>> getItem() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getItemApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load item data');
      }
    } catch (e) {
      log(e.toString(), name: 'getItemError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  // getDepartment - updated to handle exceptions
  Future<Map<String, dynamic>> getDepartment() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getDepartmentApi,
        useToken: true,
      );
      // log(response.body, name: 'getDepartment');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load department data');
      }
    } catch (e) {
      log(e.toString(), name: 'getDepartmentError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getTableGroup() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getTableGroupApi,
        useToken: true,
      );
      // log(response.body, name: 'getDepartment');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load table group data');
      }
    } catch (e) {
      log(e.toString(), name: 'getTableGroupError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getTableMaster() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getTableMasterApi,
        useToken: true,
      );
      // log(response.body, name: 'getDepartment');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load table master data');
      }
    } catch (e) {
      log(e.toString(), name: 'getTableMasterError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getKotGroup() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getKotGroupApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load kot group data');
      }
    } catch (e) {
      log(e.toString(), name: 'getKotGroupError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getTax() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getTaxApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load tax data');
      }
    } catch (e) {
      log(e.toString(), name: 'getTaxError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getcustomer() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getCustomerApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load tax data');
      }
    } catch (e) {
      log(e.toString(), name: 'getcustomerError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getpayment() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getPaymentApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load payment data');
      }
    } catch (e) {
      log(e.toString(), name: 'getpaymentError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getoffer() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getOfferApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load offer coupon data');
      }
    } catch (e) {
      log(e.toString(), name: 'getofferError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getkotmessage() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getkotmessageApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load kot message data');
      }
    } catch (e) {
      log(e.toString(), name: 'getkotmessageError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<Map<String, dynamic>> getUnit() async {
    try {
      final response = await getHttp(
        api: ApiUrls.getUnitApi,
        useToken: true,
      );
      // log(response.body, name: 'getItem');

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw const HttpException('Failed to load unit data');
      }
    } catch (e) {
      log(e.toString(), name: 'getUnitError');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }
}
