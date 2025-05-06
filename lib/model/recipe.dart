class Recipe {
  final String id;
  final String title;
  final String ingredients;
  final String steps;
  final String imageBase64;
  final String userId;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageBase64,
    required this.userId,
  });

  factory Recipe.fromFirestore(Map<String, dynamic> data, String docId) {
    return Recipe(
      id: docId,
      title: data['title'] ?? '',
      ingredients: data['ingredients'] ?? '',
      steps: data['steps'] ?? '',
      imageBase64: data['imageBase64'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'imageBase64': imageBase64,
      'userId': userId,
    };
  }
}
