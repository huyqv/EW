import 'package:http/http.dart';

class ApiClient {

  static final ApiClient _instance = ApiClient._internal();

  ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  final Client _client = Client();

  static String service = 'http://weezi.biz:8085/';

  static Client client = _instance._client;
}
