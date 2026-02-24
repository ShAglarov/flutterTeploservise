// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IncidentFormController)
final incidentFormControllerProvider = IncidentFormControllerFamily._();

final class IncidentFormControllerProvider
    extends $NotifierProvider<IncidentFormController, IncidentFormState> {
  IncidentFormControllerProvider._({
    required IncidentFormControllerFamily super.from,
    required IncidentResponse? super.argument,
  }) : super(
         retry: null,
         name: r'incidentFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$incidentFormControllerHash();

  @override
  String toString() {
    return r'incidentFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IncidentFormController create() => IncidentFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncidentFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncidentFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IncidentFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incidentFormControllerHash() =>
    r'3344faed880e455aafacaa82b34409b0f0f33a89';

final class IncidentFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          IncidentFormController,
          IncidentFormState,
          IncidentFormState,
          IncidentFormState,
          IncidentResponse?
        > {
  IncidentFormControllerFamily._()
    : super(
        retry: null,
        name: r'incidentFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IncidentFormControllerProvider call(IncidentResponse? initialIncident) =>
      IncidentFormControllerProvider._(argument: initialIncident, from: this);

  @override
  String toString() => r'incidentFormControllerProvider';
}

abstract class _$IncidentFormController extends $Notifier<IncidentFormState> {
  late final _$args = ref.$arg as IncidentResponse?;
  IncidentResponse? get initialIncident => _$args;

  IncidentFormState build(IncidentResponse? initialIncident);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<IncidentFormState, IncidentFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IncidentFormState, IncidentFormState>,
              IncidentFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
