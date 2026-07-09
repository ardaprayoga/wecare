import '../../domain/entities/service_package_entity.dart';

class ServicePackageModel extends ServicePackageEntity {
  ServicePackageModel({
    required super.id,
    required super.packageName,
    required super.description,
    required super.durationMinutes,
    required super.basePrice,
    super.scopeOfWork,
  });

  factory ServicePackageModel.fromJson(Map<String, dynamic> json) {
    return ServicePackageModel(
      id: json['id'],
      packageName: json['package_name'],
      description: json['description'],
      durationMinutes: json['duration_minutes'],
      basePrice: double.parse(json['base_price'].toString()),
      scopeOfWork: json['scope_of_work'],
    );
  }
}
