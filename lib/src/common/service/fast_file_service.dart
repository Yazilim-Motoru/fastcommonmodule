import '../enums/fast_file_type.dart';
import '../model/fast_file_meta.dart';
import '../model/fast_response.dart';

/// Abstract service for file/media management (upload, download, delete, etc).
abstract class FastFileService {
  /// Uploads a file and returns its metadata.
  Future<FastResponse<FastFileMeta>> upload({
    required List<int> bytes,
    required String name,
    required String mimeType,
    FastFileType type = FastFileType.other,
    List<String>? access,
    Map<String, dynamic>? meta,
  });

  /// Downloads a file by id. Returns file bytes.
  Future<FastResponse<List<int>>> download(String fileId);

  /// Deletes a file by id.
  Future<FastResponse<bool>> delete(String fileId);

  /// Gets file metadata by id.
  Future<FastResponse<FastFileMeta>> getMeta(String fileId);

  /// Lists files with optional filters (type, user, etc).
  Future<FastResponse<List<FastFileMeta>>> list({
    FastFileType? type,
    String? uploadedBy,
    String? query,
    int pageIndex = 0,
    int pageSize = 20,
  });
}
