// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppTheme)
final appThemeProvider = AppThemeProvider._();

final class AppThemeProvider
    extends $NotifierProvider<AppTheme, ThemePreference> {
  AppThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeHash();

  @$internal
  @override
  AppTheme create() => AppTheme();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemePreference>(value),
    );
  }
}

String _$appThemeHash() => r'54c679b31845b0d93f24cec4ea2bf6a49b0279a6';

abstract class _$AppTheme extends $Notifier<ThemePreference> {
  ThemePreference build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemePreference, ThemePreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemePreference, ThemePreference>,
              ThemePreference,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Convenience provider: resolves ThemePreference → ThemeMode

@ProviderFor(themeMode)
final themeModeProvider = ThemeModeProvider._();

/// Convenience provider: resolves ThemePreference → ThemeMode

final class ThemeModeProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  /// Convenience provider: resolves ThemePreference → ThemeMode
  ThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return themeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeHash() => r'e03bdba5a136fa275a853f52a7538bebf800c8bb';

/// Convenience provider: true when the effective theme is dark.
/// Takes system brightness into account when preference is 'system'.

@ProviderFor(isDarkMode)
final isDarkModeProvider = IsDarkModeProvider._();

/// Convenience provider: true when the effective theme is dark.
/// Takes system brightness into account when preference is 'system'.

final class IsDarkModeProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Convenience provider: true when the effective theme is dark.
  /// Takes system brightness into account when preference is 'system'.
  IsDarkModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isDarkModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isDarkModeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isDarkMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isDarkModeHash() => r'91e21c0f91caadae7d2c0d8ec06c1022cc097312';
