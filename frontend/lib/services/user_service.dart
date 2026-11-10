import '../models/user_model.dart';
import 'api_service.dart';

class UserPage {
  final List<UserModel> users;
  final int total;
  const UserPage(this.users, this.total);
}

class UserService {
  final ApiService api;
  UserService(this.api);
  Future<UserPage> list(String query) async {
    final data = await api.request('GET', '/api/users', query: {'q': query});
    return UserPage(
      (data['users'] as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      data['total'] as int,
    );
  }

  Future<UserModel> get(String id) async {
    final data = await api.request('GET', '/api/users/$id');
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> save(UserModel user) async {
    await api.request(
      user.id.isEmpty ? 'POST' : 'PUT',
      user.id.isEmpty ? '/api/users' : '/api/users/${user.id}',
      body: user.toJson(),
    );
  }

  Future<void> delete(String id) async {
    await api.request('DELETE', '/api/users/$id');
  }
}
