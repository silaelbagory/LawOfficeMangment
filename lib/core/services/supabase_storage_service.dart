import 'dart:io';
import 'dart:typed_data'; // مهم لـ Uint8List

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName;

  SupabaseStorageService({this.bucketName = 'documents'});

  /// Upload bytes (for web)
  Future<String> uploadDocumentBytes({
    required Uint8List bytes,
    required String fileName,
    required String userId,
    String? caseId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseFileName = fileName.split('.').first;
      final extension = fileName.split('.').last;
      final uniqueFileName = '${baseFileName}_$timestamp.$extension';

      final path = caseId != null
          ? 'users/$userId/cases/$caseId/$uniqueFileName'
          : 'users/$userId/documents/$uniqueFileName';

      await _supabase.storage.from(bucketName).uploadBinary(path, bytes);

      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw 'Failed to upload document bytes: $e';
    }
  }

  /// Upload file to Supabase Storage
  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      final finalFileName = fileName ?? file.path.split('/').last;
      final filePath = '$path/$finalFileName';

      Uint8List bytes = await file.readAsBytes();

      await _supabase.storage.from(bucketName).uploadBinary(filePath, bytes);

      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  /// Upload file with progress tracking
  Future<String> uploadFileWithProgress({
    required File file,
    required String path,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final finalFileName = fileName ?? file.path.split('/').last;
      final filePath = '$path/$finalFileName';

      Uint8List bytes = await file.readAsBytes();

      // simulate progress
      onProgress?.call(0.0);

      await _supabase.storage.from(bucketName).uploadBinary(filePath, bytes);

      onProgress?.call(1.0);

      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  /// Upload document file (mobile)
  Future<String> uploadDocument({
    required File file,
    required String userId,
    String? caseId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last;
      final baseFileName = fileName.split('.').first;
      final uniqueFileName = '${baseFileName}_$timestamp.$fileExtension';

      final path = caseId != null
          ? 'users/$userId/cases/$caseId/$uniqueFileName'
          : 'users/$userId/documents/$uniqueFileName';

      return await uploadFile(
        file: file,
        path: path,
        fileName: uniqueFileName,
      );
    } catch (e) {
      throw 'Failed to upload document: $e';
    }
  }

  /// Upload image file
  Future<String> uploadImage({
    required File file,
    required String userId,
    String? caseId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last;
      final baseFileName = fileName.split('.').first;
      final uniqueFileName = '${baseFileName}_$timestamp.$fileExtension';

      final path = caseId != null
          ? 'users/$userId/cases/$caseId/images/$uniqueFileName'
          : 'users/$userId/images/$uniqueFileName';

      return await uploadFile(
        file: file,
        path: path,
        fileName: uniqueFileName,
      );
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  /// Get file info
  Future<Map<String, dynamic>?> getFileInfo(String filePath) async {
    try {
      final response = await _supabase.storage.from(bucketName).list(
        path: filePath,
      );

      if (response.isNotEmpty) {
        final file = response.first;
        return {
          'name': file.name,
          'id': file.id,
          'updated_at': file.updatedAt,
          'created_at': file.createdAt,
          'last_accessed_at': file.lastAccessedAt,
          'metadata': file.metadata,
        };
      }
      return null;
    } catch (e) {
      throw 'Failed to get file info: $e';
    }
  }

  /// List files in directory
  Future<List<Map<String, dynamic>>> listFiles(String path) async {
    try {
      final response = await _supabase.storage.from(bucketName).list(
        path: path,
      );

      return response
          .map((file) => {
                'name': file.name,
                'id': file.id,
                'updated_at': file.updatedAt,
                'created_at': file.createdAt,
                'last_accessed_at': file.lastAccessedAt,
                'metadata': file.metadata,
              })
          .toList();
    } catch (e) {
      throw 'Failed to list files: $e';
    }
  }

  /// Pick file from device
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? getAllowedDocumentExtensions(),
        dialogTitle: dialogTitle ?? 'Select a file',
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw 'Failed to pick file: $e';
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw 'Failed to pick image from camera: $e';
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw 'Failed to pick image from gallery: $e';
    }
  }

  /// Allowed document extensions
  List<String> getAllowedDocumentExtensions() {
    return [
      'pdf', 'doc', 'docx', 'txt', 'rtf',
      'jpg', 'jpeg', 'png', 'gif', 'bmp',
      'xls', 'xlsx', 'ppt', 'pptx',
    ];
  }

  /// Allowed image extensions
  List<String> getAllowedImageExtensions() {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  }

  /// Max file size (10MB)
  int getMaxFileSize() => 10 * 1024 * 1024;

  /// Max document size (50MB)
  int getMaxDocumentSize() => 50 * 1024 * 1024;

  /// Validate file size
  bool validateFileSize(int fileSize, int maxSize) => fileSize <= maxSize;

  /// Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Extract file path from URL
  String extractFilePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final documentsIndex = pathSegments.indexOf(bucketName);
      if (documentsIndex != -1 && documentsIndex < pathSegments.length - 1) {
        return pathSegments.sublist(documentsIndex + 1).join('/');
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Get file extension
  String getFileExtension(String filePath) => filePath.split('.').last.toLowerCase();

  /// Get MIME type
  String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);
    switch (extension) {
      case 'pdf': return 'application/pdf';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls': return 'application/vnd.ms-excel';
      case 'xlsx': return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt': return 'application/vnd.ms-powerpoint';
      case 'pptx': return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt': return 'text/plain';
      case 'rtf': return 'application/rtf';
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'bmp': return 'image/bmp';
      case 'webp': return 'image/webp';
      default: return 'application/octet-stream';
    }
  }
}
