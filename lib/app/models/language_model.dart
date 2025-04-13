class LanguageModel {
  final String id;
  final String name;
  final String flagUrl;
  final String description;

  LanguageModel({
    required this.id,
    required this.name,
    required this.flagUrl,
    required this.description,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'],
      name: json['name'],
      flagUrl: json['flagUrl'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'flagUrl': flagUrl,
      'description': description,
    };
  }
}