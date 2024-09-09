import 'dart:convert';
import 'dart:developer';
import 'package:galaxy_mini/repositories/base_repository.dart';
import 'package:galaxy_mini/utils/api_urls.dart';

class CustomerRepository extends BaseRepository{

    Future postCustomer({required Map<String, dynamic> data}) async {
    final response = await postHttp(
      useToken: true,
      data: data,
      api: ApiUrls.postAddCustomerApi,
    );

    log(response.body, name: 'response addLeadApi');
    return json.decode(response.body);
  }
}