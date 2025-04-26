import 'dart:io';

import 'package:da_storage/data/models/account_model.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:da_storage/main.dart';
import 'package:rest_api_client/rest_api_client.dart';
import 'package:path_provider/path_provider.dart';

class AuthApi {
  static void saveTokenToFile(String token) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final File tokenFile = File('${appDocumentsDir.path}/tn');

    if (!await tokenFile.exists()) {
      await tokenFile.create();
    }
    await tokenFile.writeAsString(token);
  }

  static Future<bool> login(String email, String password) async {
    final formData = FormData.fromMap({'email': email, 'password': password});
    final response = await ApiUtils.getClient().post(
      '/auth/login',
      data: formData,
    );

    if (response.response?.statusCode == HttpStatus.ok) {
      final token = response.response?.data['token'];
      ApiUtils.setClientToken(token);
      saveTokenToFile(token);

      return true;
    } else {
      return false;
    }
  }

  static void logout() async {
    ApiUtils.setClientToken('');
    saveTokenToFile('');
  }

  static Future<Account> getMe() async {
    final response = await ApiUtils.getClient().get('/auth/me');
    final data = response.response?.data;

    if (response.response?.statusCode == HttpStatus.ok) {
      return Account(
        id: data['id'],
        avatarUrl: data['avatar_url'],
        email: data['email'],
        name: data['name'],
        role: Account.getRoleByString(data['role']),
      );
    } else {
      return Account.none;
    }
  }

  static Future<Account> putMe({
    File? avatarFile,
    required String name,
    required String email,
  }) async {
    final formData = FormData.fromMap({
      'avatar_file':
          avatarFile != null
              ? MultipartFile.fromBytes(
                await avatarFile.readAsBytes(),
                filename: avatarFile.name,
              )
              : null,
      'name': name,
      'email': email,
    });
    final response = await ApiUtils.getClient().put('/auth/me', data: formData);
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.ok) {
      return Account(
        id: resData['id'],
        avatarUrl: resData['avatar_url'],
        email: resData['email'],
        name: resData['name'],
        role: Account.getRoleByString(resData['role']),
      );
    } else {
      return Account.none;
    }
  }
}
