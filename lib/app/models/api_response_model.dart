class ApiResponseModel<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponseModel({required this.success, this.data, this.error});
}
