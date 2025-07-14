import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final baseUrl = "http://192.168.100.6/food_order_api";

  Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    var response = await http.post(
      Uri.parse("$baseUrl/signup.php"),
      body: {
        "name": name,
        "email": email,
        "role": 'user',
        "password": password,
      },
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    var response = await http.post(
      Uri.parse("$baseUrl/signin.php"),
      body: {
        "email": email,
        "password": password,
      },
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/get_user.php?user_id=$userId"));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        return result['data'];
      }
    }
    throw Exception('Gagal mengambil data user');
  }

  Future<List<dynamic>> getMenus() async {
    final response = await http.get(Uri.parse("$baseUrl/get_menus.php"));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        return result['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil data menu');
    }
  }

  Future<List<Map<String, dynamic>>> getOrders(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/get_orders.php"));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        return result['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil data orders');
    }
  }

  Future<Map<String, dynamic>> postOrders(
    String user_id,
    String total_amount,
    List<Map<dynamic, dynamic>> items,
  ) async {
    var response = await http.post(
      Uri.parse("$baseUrl/post_orders.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'user_id': user_id,
        'total_amount': total_amount,
        'items': jsonEncode(items), // <- ini penting!
      },
    );
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print("Gagal decode JSON: ${response.body}");
        throw Exception("Format JSON tidak valid");
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getOrderDetails(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_order_details.php?user_id=$userId"),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        return List<Map<String, dynamic>>.from(result['data']);
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil riwayat pesanan');
    }
  }
}
