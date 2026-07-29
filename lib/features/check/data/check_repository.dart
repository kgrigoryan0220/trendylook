import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import 'check_exceptions.dart';
import 'models/check_record.dart';

/// CHECK-01..08 (TECH_SPEC_v1.2.md 5.2): препроцессинг + upload + вызов
/// Edge Function analyze-look + чтение истории (checks, RLS).
class CheckRepository {
  CheckRepository(this._client);

  final SupabaseClient _client;
  static const _uuid = Uuid();

  /// CHECK-02: resize max 2048px, JPEG quality 85%, EXIF strip.
  Future<String> uploadPhoto(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Не авторизован');

    final compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: AppConstants.maxImageDimension,
      minHeight: AppConstants.maxImageDimension,
      quality: AppConstants.jpegQuality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    final Uint8List bytes = compressed ?? await file.readAsBytes();
    if (bytes.lengthInBytes > AppConstants.maxUploadBytes) {
      throw const AnalysisFailedException('Файл слишком большой (макс. 10 MB)');
    }

    final path = '${user.id}/${_uuid.v4()}.jpg';
    await _client.storage.from(AppConstants.lookPhotosBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
        );
    return path;
  }

  /// CHECK-03/04/05/06/07/08: вызов analyze-look, маппинг ошибок paywall/
  /// rate_limited/analysis_failed на типизированные исключения.
  Future<CheckRecord> analyzeLook({
    required String imagePath,
    String locale = 'ru',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'analyze-look',
        body: {'image_path': imagePath, 'locale': locale},
      );
      final checkId = response.data['check_id'] as String;
      return fetchCheck(checkId);
    } on FunctionException catch (e) {
      final details = e.details;
      final errorCode = details is Map ? details['error'] as String? : null;
      switch (errorCode) {
        case 'paywall':
          throw const PaywallException();
        case 'rate_limited':
          throw const RateLimitedException();
        default:
          final message = details is Map ? details['message'] as String? : null;
          throw AnalysisFailedException(
            message ??
                'Не получилось проанализировать фото. Попробуй ещё раз — проверка не списана.',
          );
      }
    }
  }

  Future<CheckRecord> fetchCheck(String id) async {
    final row = await _client.from('checks').select().eq('id', id).single();
    return CheckRecord.fromJson(row);
  }

  /// HIST-01: paginated (20/page), исключая soft-deleted.
  Future<List<CheckRecord>> fetchHistory({int page = 0}) async {
    final from = page * AppConstants.historyPageSize;
    final to = from + AppConstants.historyPageSize - 1;
    final rows = await _client
        .from('checks')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);
    return (rows as List).map((r) => CheckRecord.fromJson(r)).toList();
  }

  /// HIST-03: soft delete.
  Future<void> softDeleteCheck(String id) async {
    await _client
        .from('checks')
        .update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
  }

  Future<String> getSignedUrl(String path, {int expiresIn = 3600}) async {
    return _client.storage
        .from(AppConstants.lookPhotosBucket)
        .createSignedUrl(path, expiresIn);
  }

  Future<Map<String, String>> getSignedUrls(
    List<String> paths, {
    int expiresIn = 3600,
  }) async {
    if (paths.isEmpty) return {};
    final results = await _client.storage
        .from(AppConstants.lookPhotosBucket)
        .createSignedUrlsResult(paths, expiresIn);
    final map = <String, String>{};
    for (final r in results) {
      if (r is SignedUrlSuccess) {
        map[r.path] = r.signedUrl;
      }
    }
    return map;
  }
}
