import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'https://eemi-39b84a24258a.herokuapp.com';

  Future<List<Product>> getProducts({String? searchQuery, int page = 1, int limit = 10}) async {
    try {
      final queryParams = <String, String>{};
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
        final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // L'API renvoie un objet avec {count, rows} au lieu d'un tableau directement
        final List<dynamic> productsJson = jsonResponse['rows'] ?? [];
        return productsJson.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }
  Future<Product> updateProduct(String uuid, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$uuid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String uuid) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$uuid'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  Future<Product> getProductDetails(String uuid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$uuid'),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }
}
