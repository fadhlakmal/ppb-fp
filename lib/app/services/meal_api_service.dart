import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/app/models/api_response_model.dart';
import 'package:myapp/app/models/area_model.dart';
import 'package:myapp/app/models/category_model.dart';
import 'package:myapp/app/models/user_ingredient_model.dart';
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

  Future<ApiResponseModel<MealModel>> getRandomMeal() async {
    return _request('random.php', MealModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<MealModel>> getMealById(String id) async {
    return _request('lookup.php?i=$id', MealModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<List<MealModel>>> searchMealsByName(
    String name,
  ) async {
    return _requestList('search.php?s=$name', MealModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<List<MealModel>>> searchMealsByFirstLetter(
    String letter,
  ) async {
    return _requestList(
      'search.php?f=${Uri.encodeComponent(letter)}',
      MealModel.fromJson,
      'meals',
    );
  }

  Future<ApiResponseModel<List<CategoryModel>>> getCategories() async {
    return _requestList('categories.php', CategoryModel.fromJson, 'categories');
  }

  Future<ApiResponseModel<List<MealModel>>> getMealsByCategory(
    String category,
  ) async {
    return _requestList('filter.php?c=$category', MealModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<List<AreaModel>>> getAreas() async {
    return _requestList('list.php?a=list', AreaModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<List<MealModel>>> getMealsByArea(String area) async {
    return _requestList('filter.php?a=$area', MealModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<List<IngredientModel>>> getIngredients() async {
    return _requestList('list.php?i=list', IngredientModel.fromJson, 'meals');
  }

  Future<ApiResponseModel<List<MealModel>>> getMealsByIngredient(
    String ingredient,
  ) async {
    return _requestList(
      'filter.php?i=$ingredient',
      MealModel.fromJson,
      'meals',
    );
  }
}
