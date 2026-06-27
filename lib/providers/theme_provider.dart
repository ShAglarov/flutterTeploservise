import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

// ─────────────────────────────────────────────────
// Theme preference enum
// ─────────────────────────────────────────────────
enum ThemePreference { system, light, dark }

const String _themeStorageKey = 'app_theme_preference';

// ─────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────
@riverpod
class Theme extends _$Theme {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  ThemePreference build() {
    _load();
    return ThemePreference.dark;
  }

  Future<void> _load() async {
    try {
      final saved = await _storage.read(key: _themeStorageKey);
      if (saved != null) {
        state = ThemePreference.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => ThemePreference.dark,
        );
      }
    } catch (_) {
      // Ignore read errors — keep default (dark)
    }
  }

  Future<void> setTheme(ThemePreference pref) async {
    state = pref;
    try {
      await _storage.write(key: _themeStorageKey, value: pref.name);
    } catch (_) {
      // Ignore write errors
    }
  }
}

// ─────────────────────────────────────────────────
// Convenience providers
// ─────────────────────────────────────────────────

/// Convenience provider: resolves ThemePreference → ThemeMode
@riverpod
ThemeMode themeMode(Ref ref) {
  final pref = ref.watch(themeProvider);
  switch (pref) {
    case ThemePreference.light:
      return ThemeMode.light;
    case ThemePreference.dark:
      return ThemeMode.dark;
    case ThemePreference.system:
      return ThemeMode.system;
  }
}

/// Convenience provider: true when the effective theme is dark.
/// Takes system brightness into account when preference is 'system'.
@riverpod
bool isDarkMode(Ref ref) {
  final pref = ref.watch(themeProvider);
  switch (pref) {
    case ThemePreference.dark:
      return true;
    case ThemePreference.light:
      return false;
    case ThemePreference.system:
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
  }
}
