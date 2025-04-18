import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rest_api_client/rest_api_client.dart';

class ApiUtils {
  static late RestApiClient client;
  static bool isTokenLoaded = false;

  static Future<void> init() async {
    client = RestApiClientImpl(
      options: RestApiClientOptions(
        baseUrl: 'https://positive-emlynn-daemonz-org-6d211396.koyeb.app/v1',
      ),
    );

    await loadClientToken();
    await client.init();
  }

  static RestApiClient getClient() {
    return client;
  }

  static bool isLoggedIn() {
    return client.headers['Token']?.isNotEmpty ?? false;
  }

  static void setClientToken(String token) {
    client.addOrUpdateHeader(key: 'Token', value: token);
  }

  static Future<void> loadClientToken() async {
    if (isTokenLoaded) {
      return;
    }

    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final File tokenFile = File('${appDocumentsDir.path}/tn');

      if (await tokenFile.exists()) {
        final String token = await tokenFile.readAsString();
        setClientToken(token);
      }

      isTokenLoaded = true;
    } catch (e) {
      return;
    }
  }
}
