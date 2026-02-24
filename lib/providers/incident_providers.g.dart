// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IncidentFilter)
final incidentFilterProvider = IncidentFilterProvider._();

final class IncidentFilterProvider
    extends $NotifierProvider<IncidentFilter, IncidentFilterState> {
  IncidentFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incidentFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incidentFilterHash();

  @$internal
  @override
  IncidentFilter create() => IncidentFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncidentFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncidentFilterState>(value),
    );
  }
}

String _$incidentFilterHash() => r'3851b294396331da8215a55ad0c5d2c430cb43bf';

abstract class _$IncidentFilter extends $Notifier<IncidentFilterState> {
  IncidentFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<IncidentFilterState, IncidentFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IncidentFilterState, IncidentFilterState>,
              IncidentFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(allIncidents)
final allIncidentsProvider = AllIncidentsProvider._();

final class AllIncidentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IncidentResponse>>,
          List<IncidentResponse>,
          Stream<List<IncidentResponse>>
        >
    with
        $FutureModifier<List<IncidentResponse>>,
        $StreamProvider<List<IncidentResponse>> {
  AllIncidentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allIncidentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allIncidentsHash();

  @$internal
  @override
  $StreamProviderElement<List<IncidentResponse>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IncidentResponse>> create(Ref ref) {
    return allIncidents(ref);
  }
}

String _$allIncidentsHash() => r'ae8724dc4354b8124ddd5a0c6eb52a6ad6718390';

@ProviderFor(filteredIncidents)
final filteredIncidentsProvider = FilteredIncidentsProvider._();

final class FilteredIncidentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IncidentResponse>>,
          AsyncValue<List<IncidentResponse>>,
          AsyncValue<List<IncidentResponse>>
        >
    with $Provider<AsyncValue<List<IncidentResponse>>> {
  FilteredIncidentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredIncidentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredIncidentsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<IncidentResponse>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<IncidentResponse>> create(Ref ref) {
    return filteredIncidents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<IncidentResponse>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<IncidentResponse>>>(
        value,
      ),
    );
  }
}

String _$filteredIncidentsHash() => r'3b3e272a8ed3eb0e0ace6248431320681599c527';

@ProviderFor(singleIncident)
final singleIncidentProvider = SingleIncidentFamily._();

final class SingleIncidentProvider
    extends
        $FunctionalProvider<
          AsyncValue<IncidentResponse?>,
          IncidentResponse?,
          Stream<IncidentResponse?>
        >
    with
        $FutureModifier<IncidentResponse?>,
        $StreamProvider<IncidentResponse?> {
  SingleIncidentProvider._({
    required SingleIncidentFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'singleIncidentProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$singleIncidentHash();

  @override
  String toString() {
    return r'singleIncidentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<IncidentResponse?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<IncidentResponse?> create(Ref ref) {
    final argument = this.argument as int;
    return singleIncident(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleIncidentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$singleIncidentHash() => r'9efe18df9ca6ab7f327730bad4e83b0dde3e51cf';

final class SingleIncidentFamily extends $Family
    with $FunctionalFamilyOverride<Stream<IncidentResponse?>, int> {
  SingleIncidentFamily._()
    : super(
        retry: null,
        name: r'singleIncidentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SingleIncidentProvider call(int id) =>
      SingleIncidentProvider._(argument: id, from: this);

  @override
  String toString() => r'singleIncidentProvider';
}
