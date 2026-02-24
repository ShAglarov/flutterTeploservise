// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IncidentActivityFeed)
final incidentActivityFeedProvider = IncidentActivityFeedFamily._();

final class IncidentActivityFeedProvider
    extends
        $AsyncNotifierProvider<IncidentActivityFeed, List<IncidentActivity>> {
  IncidentActivityFeedProvider._({
    required IncidentActivityFeedFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'incidentActivityFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$incidentActivityFeedHash();

  @override
  String toString() {
    return r'incidentActivityFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IncidentActivityFeed create() => IncidentActivityFeed();

  @override
  bool operator ==(Object other) {
    return other is IncidentActivityFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incidentActivityFeedHash() =>
    r'0a3fcca8f7f240c17e634d9022caf7a8ad201329';

final class IncidentActivityFeedFamily extends $Family
    with
        $ClassFamilyOverride<
          IncidentActivityFeed,
          AsyncValue<List<IncidentActivity>>,
          List<IncidentActivity>,
          FutureOr<List<IncidentActivity>>,
          int
        > {
  IncidentActivityFeedFamily._()
    : super(
        retry: null,
        name: r'incidentActivityFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IncidentActivityFeedProvider call(int incidentId) =>
      IncidentActivityFeedProvider._(argument: incidentId, from: this);

  @override
  String toString() => r'incidentActivityFeedProvider';
}

abstract class _$IncidentActivityFeed
    extends $AsyncNotifier<List<IncidentActivity>> {
  late final _$args = ref.$arg as int;
  int get incidentId => _$args;

  FutureOr<List<IncidentActivity>> build(int incidentId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<IncidentActivity>>, List<IncidentActivity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<IncidentActivity>>,
                List<IncidentActivity>
              >,
              AsyncValue<List<IncidentActivity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
