import 'package:http/http.dart';

class ApiClient {

  final Client _client = Client();

  static String service = 'http://weezi.biz:8085/';

  ApiClient._();

  ApiClient._internal();

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  static Client client = _instance._client;

}
