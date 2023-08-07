class Recipe {
  String issueTitle;
  String relevantMessages;
  String linkToRecipe;
  String domain;
  String issueDescription;
  String comments;
  String addedBy;

  Recipe({
    required this.issueTitle,
    required this.relevantMessages,
    required this.linkToRecipe,
    required this.domain,
    required this.issueDescription,
    required this.comments,
    required this.addedBy,
  });

  // Factory constructor to create a Recipe object from a JSON map
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      issueTitle: json['issueTitle'],
      relevantMessages: json['relevantMessages'],
      linkToRecipe: json['linkToRecipe'],
      domain: json['domain'],
      issueDescription: json['issueDescription'],
      comments: json['comments'],
      addedBy: json['addedBy'],
    );
  }

  // Convert the Recipe object to a JSON-encodable format (Map)
  Map<String, dynamic> toJson() {
    return {
      "issueTitle": issueTitle,
      "relevantMessages": relevantMessages,
      "linkToRecipe": linkToRecipe,
      "domain": domain,
      "issueDescription": issueDescription,
      "comments": comments,
      "addedBy": addedBy,
    };
  }
}
