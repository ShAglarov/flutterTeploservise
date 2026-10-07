import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_models.dart';
import '../services/organization_service.dart';

/// Список организаций системы. Загружается только на экране суперадмина,
/// поэтому обычный FutureProvider без кэша на диске.
final organizationsProvider =
    FutureProvider<List<OrganizationResponse>>((ref) async {
  final service = ref.watch(organizationServiceProvider);
  return service.getAll();
});
