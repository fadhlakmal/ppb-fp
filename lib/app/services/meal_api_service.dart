import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/app/models/api_response_model.dart';
import 'package:myapp/app/models/meal_model.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // fetch satu item
  Future<ApiResponseModel<T>> _request<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataKey,
  ) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/$endpoint'));

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(res.body);

        if (jsonData[dataKey] != null) {
          final List<dynamic> items = jsonData[dataKey];
          return ApiResponseModel(success: true, data: fromJson(items.first));
        }

        return ApiResponseModel(success: false, error: 'No data found');
      } else {
        return ApiResponseModel(
          success: false,
          error: 'HTTP ${res.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponseModel(success: false, error: e.toString());
    }
  }

  // fetch list item
  Future<ApiResponseModel<List<T>>> _requestList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
    String dataKey,
  ) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/$endpoint'));

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(res.body);

        if (jsonData[dataKey] != null) {
          final List<dynamic> items = jsonData[dataKey];
          return ApiResponseModel(
            success: true,
            data: items.map((item) => fromJson(item)).toList(),
          );
        }

        return ApiResponseModel(success: true, data: []);
      } else {
        return ApiResponseModel(
          success: false,
          error: 'HTTP ${res.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponseModel(success: false, error: e.toString());
    }
  }
}
