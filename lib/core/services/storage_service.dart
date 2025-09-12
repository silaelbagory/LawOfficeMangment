import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file to Firebase Storage
  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      final finalFileName = fileName ?? file.path.split('/').last;
      final ref = _storage.ref().child('$path/$finalFileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
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
      final ref = _storage.ref().child('$path/$finalFileName');
      
      final uploadTask = ref.putFile(file);
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  // Upload multiple files
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final List<String> downloadUrls = [];
      final totalFiles = files.length;
      
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final finalFileName = file.path.split('/').last;
        final ref = _storage.ref().child('$path/$finalFileName');
        
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
        
        // Calculate overall progress
        final progress = (i + 1) / totalFiles;
        onProgress?.call(progress);
      }
      
      return downloadUrls;
    } catch (e) {
      throw 'Failed to upload files: $e';
    }
  }

  // Download file
  Future<File> downloadFile({
    required String downloadUrl,
    required String localPath,
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final file = File(localPath);
      
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw 'Failed to download file: $e';
    }
  }

  // Get download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL: $e';
    }
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  // Delete file by URL
  Future<void> deleteFileByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Failed to get file metadata: $e';
    }
  }

  // List files in a folder
  Future<List<Reference>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw 'Failed to list files: $e';
    }
  }

  // Get file size
  Future<int> getFileSize(String path) async {
    try {
      final metadata = await getFileMetadata(path);
      return metadata.size ?? 0;
    } catch (e) {
      throw 'Failed to get file size: $e';
    }
  }

  // Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw 'Failed to pick image: $e';
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw 'Failed to take photo: $e';
    }
  }

  // Pick file
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
        withData: true, // Important for web compatibility
        withReadStream: true, // Important for web compatibility
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        } else if (file.bytes != null) {
          // For web, create a temporary file from bytes
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/${file.name}');
          await tempFile.writeAsBytes(file.bytes!);
          return tempFile;
        }
      }
      return null;
    } catch (e) {
      throw 'Failed to pick file: $e';
    }
  }

  // Pick multiple files
  Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
        allowMultiple: true,
        withData: true, // Important for web compatibility
        withReadStream: true, // Important for web compatibility
      );
      
      if (result != null) {
        final List<File> files = [];
        for (final file in result.files) {
          if (file.path != null) {
            files.add(File(file.path!));
          } else if (file.bytes != null) {
            // For web, create a temporary file from bytes
            final tempDir = Directory.systemTemp;
            final tempFile = File('${tempDir.path}/${file.name}');
            await tempFile.writeAsBytes(file.bytes!);
            files.add(tempFile);
          }
        }
        return files;
      }
      return [];
    } catch (e) {
      throw 'Failed to pick files: $e';
    }
  }

  // Specific methods for document management

  // Upload document
  Future<String> uploadDocument({
    required File file,
    required String userId,
    String? caseId,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = caseId != null 
          ? '${AppConstants.documentsStoragePath}/$userId/$caseId/$timestamp-$fileName'
          : '${AppConstants.documentsStoragePath}/$userId/$timestamp-$fileName';
      
      return await uploadFile(
        file: file,
        path: path,
        fileName: fileName,
      );
    } catch (e) {
      throw 'Failed to upload document: $e';
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    try {
      final fileName = 'profile-$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${AppConstants.profileImagesStoragePath}/$userId';
      
      return await uploadFile(
        file: image,
        path: path,
        fileName: fileName,
      );
    } catch (e) {
      throw 'Failed to upload profile image: $e';
    }
  }

  // Get document download URL
  Future<String> getDocumentDownloadUrl(String documentPath) async {
    try {
      return await getDownloadUrl(documentPath);
    } catch (e) {
      throw 'Failed to get document download URL: $e';
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentPath) async {
    try {
      await deleteFile(documentPath);
    } catch (e) {
      throw 'Failed to delete document: $e';
    }
  }

  // Get allowed file extensions for documents
  List<String> getAllowedDocumentExtensions() {
    return [
      'pdf',
      'doc',
      'docx',
      'txt',
      'rtf',
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'tiff',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
    ];
  }

  // Get allowed image extensions
  List<String> getAllowedImageExtensions() {
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'tiff',
      'webp',
    ];
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

  // Get file extension
  String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if file is image
  bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return getAllowedImageExtensions().contains(extension);
  }

  // Check if file is document
  bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return getAllowedDocumentExtensions().contains(extension);
  }

  // Validate file size (in bytes)
  bool validateFileSize(int fileSize, int maxSizeInBytes) {
    return fileSize <= maxSizeInBytes;
  }

  // Get max file size for documents (10MB)
  int getMaxDocumentSize() {
    return 10 * 1024 * 1024; // 10MB
  }

  // Get max file size for images (5MB)
  int getMaxImageSize() {
    return 5 * 1024 * 1024; // 5MB
  }
}
