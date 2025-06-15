import 'package:appwrite/models.dart' as appwrite_models;

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String? estimatedDuration;
  final String? imageUrl;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.estimatedDuration,
    this.imageUrl,
    required this.isActive,
  });

  factory ServiceModel.fromAppwriteDocument(appwrite_models.Document doc) {
    return ServiceModel(
      id: doc.$id,
      name: doc.data['name'] as String,
      description: doc.data['description'] as String,
      basePrice: (doc.data['basePrice'] as num).toDouble(),
      estimatedDuration: doc.data['estimatedDuration'] as String?,
      imageUrl: doc.data['imageUrl'] as String?,
      isActive: doc.data['isActive'] as bool,
    );
  }
}