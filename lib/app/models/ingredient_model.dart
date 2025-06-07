class IngredientModel {
  final String idIngredient;
  final String strIngredient;
  final String? strDescription;
  final String? strType;

  IngredientModel({
    required this.idIngredient,
    required this.strIngredient,
    this.strDescription,
    this.strType,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      idIngredient: json['idIngredient'] ?? '',
      strIngredient: json['strIngredient'] ?? '',
      strDescription: json['strDescription'],
      strType: json['strType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idIngredient': idIngredient,
      'strIngredient': strIngredient,
      'strDescription': strDescription,
      'strType': strType,
    };
  }
}
