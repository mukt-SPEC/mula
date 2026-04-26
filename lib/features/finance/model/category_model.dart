import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4) // Assign a new typeId
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint; // Store icon as an integer

  @HiveField(3)
  final int colorValue; // Store color as an integer (0xFF...)

  CategoryModel({
    required this.id,
    required this.name,
    this.iconCodePoint = 0xe1af, // Default icon
    this.colorValue = 0xFF4CAF50, // Default color
  });
}
