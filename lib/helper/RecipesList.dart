import 'package:af_support_open_ai/helper/recipe.dart';

class RecipesList {
  List<Recipe> recipesList;

  RecipesList({required this.recipesList});

  // Factory constructor to create a RecipesList object from a JSON map
  factory RecipesList.fromJson(Map<String, dynamic>? json) {
    return RecipesList(
      recipesList: (json != null && json.containsKey('recipes'))
          ? List<Recipe>.from(json['recipes'].map((recipeJson) => Recipe.fromJson(recipeJson)))
          : [],
    );
  }

  // Convert the RecipesList object to a JSON-encodable format (Map)
  Map<String, dynamic> toJson() {
    return {
      "recipes": List<dynamic>.from(recipesList.map((recipe) => recipe.toJson())),
    };
  }
}


