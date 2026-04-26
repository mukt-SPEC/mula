import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4) 
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint; 

  @HiveField(3)
  final int colorValue; 

  CategoryModel({
    required this.id,
    required this.name,
    this.iconCodePoint = 0xe1af, 
    this.colorValue = 0xFF4CAF50, 
  });
}

