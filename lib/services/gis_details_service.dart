/// Сведения для шаблонов ГИС ЖКХ: подъезды, лифты, комнаты, основания
/// лицевых счетов, доп. листы платёжного документа и расширенные
/// параметры.
///
/// Каталог параметров НЕ захардкожен на клиенте: он приходит с сервера,
/// который читает его из самого шаблона ГИС. Поэтому обновление
/// шаблона не требует новой версии приложения.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gis_details_models.dart';
import 'base_api_service.dart';

final gisDetailsServiceProvider = Provider<GisDetailsService>((ref) {
  return GisDetailsService(ref.watch(dioProvider));
});

/// Каталог параметров — грузится один раз на сессию: он одинаков для
/// всей организации и меняется только вместе с шаблоном на сервере.
final gisCatalogProvider = FutureProvider<List<GisParamGroup>>((ref) async {
  return ref.watch(gisDetailsServiceProvider).getCatalog();
});

class GisDetailsService {
  final Dio _dio;

  GisDetailsService(this._dio);

  // ─────────────────────────── каталог ───────────────────────────

  Future<List<GisParamGroup>> getCatalog() async {
    final response = await _dio.get('/gis/details/catalog');
    final groups = (response.data['groups'] as List? ?? []);
    return groups
        .map((e) => GisParamGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────── расширенные параметры ───────────────────────

  Future<List<GisParamValue>> getParams({
    required String ownerType,
    required int ownerId,
    String? groupKey,
  }) async {
    final response = await _dio.get('/gis/details/params', queryParameters: {
      'owner_type': ownerType,
      'owner_id': ownerId,
      'group_key': ?groupKey,
    });
    return (response.data as List)
        .map((e) => GisParamValue.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Сохранить группу параметров ЦЕЛИКОМ.
  ///
  /// Сервер удаляет параметры, которых нет в запросе: иначе снятое в
  /// форме значение осталось бы в базе и уехало в портал.
  Future<List<GisParamValue>> saveParams({
    required String groupKey,
    required String ownerType,
    required int ownerId,
    required List<GisParamValue> params,
  }) async {
    final response = await _dio.put('/gis/details/params', data: {
      'group_key': groupKey,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'params': params.map((e) => e.toJson()).toList(),
    });
    return (response.data as List)
        .map((e) => GisParamValue.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────── подъезды ───────────────────────────

  Future<List<Entrance>> getEntrances(int locationId) async {
    final response = await _dio.get('/gis/details/entrances',
        queryParameters: {'location_id': locationId});
    return (response.data as List)
        .map((e) => Entrance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Entrance> createEntrance(Entrance item) async {
    final response =
        await _dio.post('/gis/details/entrances', data: item.toJson());
    return Entrance.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Entrance> updateEntrance(int id, Entrance item) async {
    final response = await _dio.put('/gis/details/entrances/$id', data: {
      'number': item.number,
      'floors': item.floors,
      'year_built': item.yearBuilt,
      'confirmed': item.confirmed,
    });
    return Entrance.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteEntrance(int id) =>
      _dio.delete('/gis/details/entrances/$id');

  // ─────────────────────────── лифты ───────────────────────────

  Future<List<Lift>> getLifts(int locationId) async {
    final response = await _dio.get('/gis/details/lifts',
        queryParameters: {'location_id': locationId});
    return (response.data as List)
        .map((e) => Lift.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Lift> createLift(Lift item) async {
    final response = await _dio.post('/gis/details/lifts', data: item.toJson());
    return Lift.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Lift> updateLift(int id, Lift item) async {
    final response = await _dio.put('/gis/details/lifts/$id', data: {
      'factory_number': item.factoryNumber,
      'lift_type': item.liftType,
      'service_life_until': item.serviceLifeUntil,
      'entrance_id': item.entranceId,
    });
    return Lift.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteLift(int id) => _dio.delete('/gis/details/lifts/$id');

  // ─────────────────────────── комнаты ───────────────────────────

  Future<List<GisRoom>> getRooms(int accountId) async {
    final response = await _dio
        .get('/gis/details/rooms', queryParameters: {'account_id': accountId});
    return (response.data as List)
        .map((e) => GisRoom.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GisRoom> createRoom(GisRoom item) async {
    final response = await _dio.post('/gis/details/rooms', data: item.toJson());
    return GisRoom.fromJson(response.data as Map<String, dynamic>);
  }

  Future<GisRoom> updateRoom(int id, GisRoom item) async {
    final response = await _dio.put('/gis/details/rooms/$id', data: {
      'number': item.number,
      'area': item.area,
      'cadastral_number': item.cadastralNumber,
      'confirmed': item.confirmed,
    });
    return GisRoom.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteRoom(int id) => _dio.delete('/gis/details/rooms/$id');

  // ─────────────────── основания лицевого счёта ───────────────────

  Future<List<AccountBasis>> getBases(int accountId) async {
    final response = await _dio
        .get('/gis/details/bases', queryParameters: {'account_id': accountId});
    return (response.data as List)
        .map((e) => AccountBasis.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AccountBasis> createBasis(AccountBasis item) async {
    final response = await _dio.post('/gis/details/bases', data: item.toJson());
    return AccountBasis.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AccountBasis> updateBasis(int id, AccountBasis item) async {
    final data = item.toJson()..remove('account_id');
    final response = await _dio.put('/gis/details/bases/$id', data: data);
    return AccountBasis.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteBasis(int id) => _dio.delete('/gis/details/bases/$id');

  // ─────────── дополнительные листы платёжного документа ───────────

  Future<List<PdExtraRow>> getPdRows(String kind, int documentId) async {
    final response = await _dio.get('/gis/details/pd/$kind',
        queryParameters: {'payment_document_id': documentId});
    return (response.data as List)
        .map((e) => PdExtraRow.fromJson(kind, e as Map<String, dynamic>))
        .toList();
  }

  Future<PdExtraRow> createPdRow(
      String kind, int documentId, Map<String, dynamic> data) async {
    final response = await _dio.post('/gis/details/pd/$kind', data: {
      ...data,
      'payment_document_id': documentId,
    });
    return PdExtraRow.fromJson(kind, response.data as Map<String, dynamic>);
  }

  Future<PdExtraRow> updatePdRow(
      String kind, int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/gis/details/pd/$kind/$id', data: data);
    return PdExtraRow.fromJson(kind, response.data as Map<String, dynamic>);
  }

  Future<void> deletePdRow(String kind, int id) =>
      _dio.delete('/gis/details/pd/$kind/$id');
}
