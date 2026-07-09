class ServicePackageEntity {
  final int id;
  final String packageName;
  final String description;
  final int durationMinutes;
  final double basePrice;
  final String? scopeOfWork;

  ServicePackageEntity({
    required this.id,
    required this.packageName,
    required this.description,
    required this.durationMinutes,
    required this.basePrice,
    this.scopeOfWork,
  });
}
