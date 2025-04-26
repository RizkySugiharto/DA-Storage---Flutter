import 'dart:io';

import 'package:da_storage/data/models/account_model.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:da_storage/main.dart';
import 'package:rest_api_client/rest_api_client.dart';

class AccountsApi {
  static Future<List<Account>> getAllAccounts({
    String? search,
    AccountRole? role,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/accounts',
      queryParameters: {
        'search': search ?? '',
        'role': {AccountRole.admin: 'admin', AccountRole.staff: 'staff'}[role],
        'sort_by': sortBy ?? '',
        'sort_order': sortOrder ?? '',
      },
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    if (response.response?.statusCode != HttpStatus.ok) {
      return [Account.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Account.fromJSON(item)).toList();

    return data;
  }

  static Future<Account> getSingleAccount(int id) async {
    final response = await ApiUtils.getClient().get('/accounts/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode != HttpStatus.ok) {
      return Account.none;
    }

    final data = Account.fromJSON(resData);

    return data;
  }

  static Future<Account> post({
    File? avatarFile,
    required String name,
    required String email,
    required String password,
    required AccountRole role,
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
      'password': password,
      'role': {AccountRole.admin: 'admin', AccountRole.staff: 'staff'}[role],
    });
    final response = await ApiUtils.getClient().post(
      '/accounts',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.created) {
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

  static Future<Account> put({
    required int id,
    File? avatarFile,
    required String name,
    required String email,
    String? password,
    required AccountRole role,
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
      'password': password,
      'role': {AccountRole.admin: 'admin', AccountRole.staff: 'staff'}[role],
    });
    final response = await ApiUtils.getClient().put(
      '/accounts/$id',
      data: formData,
    );
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

  static Future<bool> delete(int id) async {
    final response = await ApiUtils.getClient().delete('/accounts/$id');
    return response.response?.statusCode == HttpStatus.resetContent;
  }
}
