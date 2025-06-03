import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';
import '../models/kategori.dart';

class ApiClient {
  static const String baseUrl = 'http://172.16.5.211:8000/api';

  Future<List<Barang>> getBarang() async {
    final response = await http.get(Uri.parse('$baseUrl/barang'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Barang.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load barang: ${response.statusCode}');
    }
  }

  Future<Barang> getBarangById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/barang/$id'));
    if (response.statusCode == 200) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load barang: ${response.statusCode}');
    }
  }

  Future<List<Kategori>> getKategori() async {
    final response = await http.get(Uri.parse('$baseUrl/kategori'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Kategori.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load kategori: ${response.statusCode}');
    }
  }
}