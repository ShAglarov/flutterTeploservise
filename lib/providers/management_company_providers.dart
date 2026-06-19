import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/management_company_models.dart';
import '../services/management_company_service.dart';

/// Provider for the full list of management companies.
/// Uses FutureProvider for simple async loading with built-in error/loading states.
final managementCompaniesProvider = FutureProvider<List<ManagementCompanyResponse>>((ref) async {
  final service = ref.watch(managementCompanyServiceProvider);
  return service.getAllManagementCompanies();
});

/// Provider for a single management company by ID.
final managementCompanyDetailProvider = FutureProvider.family<ManagementCompanyResponse, String>((ref, id) async {
  final service = ref.watch(managementCompanyServiceProvider);
  return service.getManagementCompany(id);
});
