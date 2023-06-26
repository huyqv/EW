import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../data/api_client.dart';

class BaseVM with ChangeNotifier {

  var isShowProgress = false;

  var requestDispatch = false;

  Map<String, String> _getHeaders(
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  ) {
    Map<String, String> fHeaders = {
      "Content-Type": "application/json",
      'Accept': '*/*',
    };
    if (headers != null) fHeaders.addAll(headers);
    return fHeaders;
  }

  Future<Map<String, dynamic>?> _onRequest(Function function) async {
    requestDispatch = false;
    isShowProgress = true;
    notifyListeners();
    try {
      final http.Response res = await function();
      isShowProgress = false;
      notifyListeners();
      if (!requestDispatch && res.statusCode > 199 && res.statusCode < 300) {
        return convert.json.decode(res.body);
      }
    } on Exception catch (e) {
      isShowProgress = false;
      notifyListeners();
      return {
        'error': e.toString(),
      };
    }
    return {
      'error': 'unknown error',
    };
  }

  Future<Map<String, dynamic>?> getRequest({
    required String endpoint,
    Map<String, String>? header,
  }) {
    return _onRequest(() {
      return ApiClient.client.get(
        Uri.parse('${ApiClient.url}$endpoint'),
        headers: _getHeaders(header, null),
      );
    });
  }

  Future<Map<String, dynamic>?> postRequest({
    required String endpoint,
    Map<String, String>? header,
    Map<String, dynamic>? body,
  }) {
    return _onRequest(() {
      return ApiClient.client.post(
        Uri.parse('${ApiClient.url}$endpoint'),
        headers: _getHeaders(header, body),
        body: convert.json.encode(body),
      );
    });
  }

  Future<Map<String, dynamic>?> httpPostRequest({
    required String ip,
    required String path,
    Map<String, String>? header,
    Map<String, dynamic>? body,
  }) {
    return _onRequest(() {
      return ApiClient.client.post(
        Uri.parse('http://$ip:9000/$path'),
        body: convert.json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
    });
  }
}
