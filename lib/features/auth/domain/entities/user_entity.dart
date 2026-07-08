class UserEntity {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin', 'mitra', 'pelanggan'
  final String? token;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });
}
