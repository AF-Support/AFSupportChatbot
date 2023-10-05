class ZenDeskQuestionArray {
  List<ZenDeskQuestion> zendeskArray;

  ZenDeskQuestionArray({required this.zendeskArray});

  // Factory constructor to create a ZenDeskQuestionArray object from a JSON map
  factory ZenDeskQuestionArray.fromJson(Map<String, dynamic>? json) {
    return ZenDeskQuestionArray(
      zendeskArray: (json != null && json.containsKey('zendeskQs'))
          ? List<ZenDeskQuestion>.from(json['zendeskQs'].map((zendeskJson) =>
          ZenDeskQuestion.fromJson(zendeskJson)))
          : [],
    );
  }

  // Convert the ZenDeskQuestionArray object to a JSON-encodable format (Map)
  Map<String, dynamic> toJson() {
    return {
      "zendeskQs": List<dynamic>.from(
          zendeskArray.map((zendeskQuestion) => zendeskQuestion.toJson())),
    };
  }
}

class ZenDeskQuestion {
  String clientText;
  int expected_recipe_id;
  int zd_ticket_number;

  ZenDeskQuestion({
    required this.clientText,
    required this.expected_recipe_id,
    required this.zd_ticket_number
  });

  // Factory constructor to create a ZenDeskQuestion object from a JSON map
  factory ZenDeskQuestion.fromJson(Map<String, dynamic> json) {
    return ZenDeskQuestion(
        clientText: json['clientText'],
        expected_recipe_id: json['expected_recipe_id'],
        zd_ticket_number: json['zd_ticket_number']
    );
  }

  @override
  String toString() {
    return 'clientText: $clientText \nexpected_recipe_id: $expected_recipe_id \nzd_ticket_number: $zd_ticket_number';
  }

  // Convert the ZenDeskQuestion object to a JSON-encodable format (Map)
  Map<String, dynamic> toJson() {
    return {
      "clientText": clientText,
      "expected_recipe_id": expected_recipe_id,
      "zd_ticket_number": zd_ticket_number
    };
  }
}