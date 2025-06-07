class AreaModel {
  final String strArea;

  AreaModel({required this.strArea});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(strArea: json['strArea'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'strArea': strArea};
  }
}
