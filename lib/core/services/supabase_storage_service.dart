import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload file to Supabase Storage
  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      final finalFileName = fileName ?? file.path.split('/').last;
      final filePath = '$path/$finalFileName';
      
      // Upload file to Supabase Storage
      await _supabase.storage
          .from('documents')
          .uploadBinary(filePath, file.readAsBytesSync());
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from('documents')
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  // Upload file with progress tracking
  Future<String> uploadFileWithProgress({
    required File file,
    required String path,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final finalFileName = fileName ?? file.path.split('/').last;
      final filePath = '$path/$finalFileName';
      
      // For now, we'll simulate progress since Supabase doesn't have built-in progress tracking
      onProgress?.call(0.0);
      
      // Upload file to Supabase Storage
      await _supabase.storage
          .from('documents')
          .uploadBinary(filePath, file.readAsBytesSync());
      
      onProgress?.call(1.0);
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from('documents')
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  // Upload document file
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

  // Upload image file
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

  // Delete file from Supabase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      await _supabase.storage
          .from('documents')
          .remove([filePath]);
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }
Future<String> uploadDocumentBytes({
  required Uint8List bytes,
  required String fileName,
  required String userId,
  String? caseId,
}) async {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileExtension = fileName.split('.').last;
    final baseFileName = fileName.split('.').first;
    final uniqueFileName = '${baseFileName}_$timestamp.$fileExtension';

    final path = caseId != null 
        ? 'users/$userId/cases/$caseId/$uniqueFileName'
        : 'users/$userId/documents/$uniqueFileName';

    // ✅ رفع الـ bytes على Supabase
    await _supabase.storage
        .from('documents')
        .uploadBinary(path, bytes);

    // ✅ إرجاع رابط الملف
    final publicUrl = _supabase.storage
        .from('documents')
        .getPublicUrl(path);

    return publicUrl;
  } catch (e) {
    throw 'Failed to upload document bytes: $e';
  }
}

  // Get file info
  Future<Map<String, dynamic>?> getFileInfo(String filePath) async {
    try {
      final response = await _supabase.storage
          .from('documents')
          .list(path: filePath);
      
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

  // List files in a directory
  Future<List<Map<String, dynamic>>> listFiles(String path) async {
    try {
      final response = await _supabase.storage
          .from('documents')
          .list(path: path);
      
      return response.map((file) => {
        'name': file.name,
        'id': file.id,
        'updated_at': file.updatedAt,
        'created_at': file.createdAt,
        'last_accessed_at': file.lastAccessedAt,
        'metadata': file.metadata,
      }).toList();
    } catch (e) {
      throw 'Failed to list files: $e';
    }
  }

  // Pick file from device
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

  // Pick image from camera
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

  // Pick image from gallery
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

  // Get allowed document extensions
  List<String> getAllowedDocumentExtensions() {
    return [
      'pdf', 'doc', 'docx', 'txt', 'rtf',
      'jpg', 'jpeg', 'png', 'gif', 'bmp',
      'xls', 'xlsx', 'ppt', 'pptx',
    ];
  }

  // Get allowed image extensions
  List<String> getAllowedImageExtensions() {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  }

  // Get maximum file size (10MB)
  int getMaxFileSize() {
    return 10 * 1024 * 1024; // 10MB in bytes
  }

  // Get maximum document size (50MB)
  int getMaxDocumentSize() {
    return 50 * 1024 * 1024; // 50MB in bytes
  }

  // Validate file size
  bool validateFileSize(int fileSize, int maxSize) {
    return fileSize <= maxSize;
  }

  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Extract file path from URL
  String extractFilePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the 'documents' segment and return everything after it
      final documentsIndex = pathSegments.indexOf('documents');
      if (documentsIndex != -1 && documentsIndex < pathSegments.length - 1) {
        return pathSegments.sublist(documentsIndex + 1).join('/');
      }
      
      return '';
    } catch (e) {
      return '';
    }
  }

  // Get file extension from path
  String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  // Get MIME type from file extension
  String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
