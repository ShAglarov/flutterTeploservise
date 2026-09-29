import 'dart:io';

import 'package:flutter/foundation.dart';

/// Настройка TLS для HTTP/WebSocket клиентов.
///
/// SECURITY: раньше приложение принимало ЛЮБОЙ сертификат
/// (`badCertificateCallback => true`) во всех сборках, включая release.
/// Это полностью снимает защиту TLS: любой в сети между устройством и
/// сервером (публичный Wi-Fi, скомпрометированный роутер, MITM-прокси)
/// мог подставить свой сертификат и читать/менять трафик — включая
/// логин, пароли и JWT-токены.
///
/// Теперь обход проверки доступен ТОЛЬКО в debug-сборках, где он нужен
/// для работы через корпоративные прокси и с self-signed сертификатами
/// локального сервера. В release проверка сертификата обязательна.
///
/// Если production-сервер использует self-signed сертификат, правильное
/// решение — выпустить доверенный сертификат (Let's Encrypt) либо добавить
/// CA сервера в [trustedCertificateAuthorities], а не отключать проверку.
class SecureHttp {
  SecureHttp._();

  /// PEM-содержимое дополнительных доверенных CA (например, внутренний CA).
  /// Пусто по умолчанию — используются системные корневые сертификаты.
  static final List<String> trustedCertificateAuthorities = <String>[];

  /// Разрешён ли обход проверки сертификата.
  /// True только в debug-сборках.
  static bool get allowInsecureCertificates => kDebugMode;

  /// Создаёт [SecurityContext] с системными CA плюс [trustedCertificateAuthorities].
  static SecurityContext buildSecurityContext() {
    final context = SecurityContext.defaultContext;
    for (final pem in trustedCertificateAuthorities) {
      try {
        context.setTrustedCertificatesBytes(pem.codeUnits);
      } catch (e) {
        debugPrint('⚠️ [SecureHttp] Failed to add trusted CA: $e');
      }
    }
    return context;
  }

  /// Применяет политику проверки сертификатов к [client].
  static void applyTo(HttpClient client) {
    if (allowInsecureCertificates) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint(
          '⚠️ [SecureHttp] DEBUG: accepting untrusted certificate for $host:$port '
          '(subject: ${cert.subject})',
        );
        return true;
      };
    }
    // В release badCertificateCallback не задаётся — Dart отклоняет
    // недоверенные сертификаты сам.
  }

  /// Готовый [HttpClient] с применённой политикой TLS.
  static HttpClient createClient({Duration? connectionTimeout}) {
    final client = HttpClient(context: buildSecurityContext());
    if (connectionTimeout != null) {
      client.connectionTimeout = connectionTimeout;
    }
    applyTo(client);
    return client;
  }
}

/// [HttpOverrides] для глобальной настройки TLS.
class SecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context ?? SecureHttp.buildSecurityContext());
    SecureHttp.applyTo(client);
    return client;
  }
}
