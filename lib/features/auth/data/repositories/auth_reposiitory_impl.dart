import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  Future<UserEntity> login(String email, String password) async {
    // Memanggil model dari data layer dan mengembalikan entity ke domain layer
    final userModel = await remoteDataSource.login(email, password);
    return userModel;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
  }
}
