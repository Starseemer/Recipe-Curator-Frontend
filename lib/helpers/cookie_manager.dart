import 'dart:io';
import 'dart:html';

class MyCookieManager {
  static final MyCookieManager _instance = MyCookieManager._internal();

  factory MyCookieManager() {
    return _instance;
  }

  MyCookieManager._internal();

  void setCookie(String cookie) {
    window.localStorage['token'] = cookie;
  }

  String getCookie() {
    String? token = window.localStorage['token'];
    if (token == null) {
      return '';
    }
    return token;
  }

  void clearCookie() {
    window.localStorage['token'] = "";
  }

  HttpClientRequest setCookieFromRequest(HttpClientRequest request) {
    request.headers.add('Authorization', getCookie()!);
    return request;
  }
}
