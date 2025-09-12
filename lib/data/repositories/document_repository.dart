import 'dart:io';

import '../../core/services/firestore_service.dart';
import '../../core/services/supabase_storage_service.dart';
import '../models/document_model.dart';

class DocumentRepository {
  final FirestoreService _firestoreService;
  final SupabaseStorageService _storageService;

  DocumentRepository(this._firestoreService, this._storageService);

  // Create a new document
  Future<String> createDocument(DocumentModel documentModel) async {
    try {
      final documentData = documentModel.toMap();
      return await _firestoreService.createDocumentRecord(documentData);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  // Get document by ID
  Future<DocumentModel?> getDocument(String documentId) async {
    try {
      final documentData = await _firestoreService.getDocumentRecord(documentId);
      if (documentData != null) {
        return DocumentModel.fromMap(documentData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  // Update document
  Future<void> updateDocument(String documentId, DocumentModel documentModel) async {
    try {
      final documentData = documentModel.toMap();
      await _firestoreService.updateDocumentRecord(documentId, documentData);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        // Delete file from Supabase Storage
        await _storageService.deleteFile(documentModel.filePath);
        
        // Delete document record from Firestore
        await _firestoreService.deleteDocumentRecord(documentId);
      }
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Upload document file
  Future<String> uploadDocumentFile({
    required File file,
    required String userId,
    required String managerId,
    String? caseId,
    String? clientId,
    String? name,
    String? description,
    DocumentType type = DocumentType.other,
    List<String> tags = const [],
  }) async {
    try {
      // Upload file to Supabase Storage
      final fileUrl = await _storageService.uploadDocument(
        file: file,
        userId: userId,
        caseId: caseId,
      );

      // Create document model
      final documentModel = DocumentModel(
        id: '', // Will be set by Firestore
        name: name ?? file.path.split('/').last,
        originalName: file.path.split('/').last,
        description: description ?? '',
        userId: userId,
        managerId: managerId,
        caseId: caseId,
        clientId: clientId,
        type: type,
        fileUrl: fileUrl,
        filePath: _storageService.extractFilePathFromUrl(fileUrl),
        fileExtension: _storageService.getFileExtension(file.path),
        fileSize: await file.length(),
        mimeType: _storageService.getMimeType(file.path),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        uploadedBy: userId,
      );

      // Save document record to Firestore
      final documentId = await createDocument(documentModel);
      
      return documentId;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Get documents by manager
  Future<List<DocumentModel>> getDocumentsByManager(String managerId) async {
    try {
      final documents = await _firestoreService.getCollection(
        collection: 'documents',
        whereConditions: {'managerId': managerId},
      );
      
      return documents.map((doc) => DocumentModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get documents by manager: $e');
    }
  }

  // Get all documents for a user
  Future<List<DocumentModel>> getDocumentsByUser(String userId) async {
    try {
      final documentsData = await _firestoreService.getCollection(
        collection: 'documents',
        whereConditions: {'userId': userId},
        orderBy: 'createdAt',
        descending: true,
      );

      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  // Get documents by case
  Future<List<DocumentModel>> getDocumentsByCase(String userId, String caseId) async {
    try {
      final documentsData = await _firestoreService.getCollection(
        collection: 'documents',
        whereConditions: {
          'userId': userId,
          'caseId': caseId,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get documents by case: $e');
    }
  }

  // Get documents by client
  Future<List<DocumentModel>> getDocumentsByClient(String userId, String clientId) async {
    try {
      final documentsData = await _firestoreService.getCollection(
        collection: 'documents',
        whereConditions: {
          'userId': userId,
          'clientId': clientId,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get documents by client: $e');
    }
  }

  // Get documents by type
  Future<List<DocumentModel>> getDocumentsByType(String userId, DocumentType type) async {
    try {
      final documentsData = await _firestoreService.getCollection(
        collection: 'documents',
        whereConditions: {
          'userId': userId,
          'type': type.name,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get documents by type: $e');
    }
  }

  // Get documents by status
  Future<List<DocumentModel>> getDocumentsByStatus(String userId, DocumentStatus status) async {
    try {
      final documentsData = await _firestoreService.getCollection(
        collection: 'documents',
        whereConditions: {
          'userId': userId,
          'status': status.name,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get documents by status: $e');
    }
  }

  // Get approved documents
  Future<List<DocumentModel>> getApprovedDocuments(String userId) async {
    return await getDocumentsByStatus(userId, DocumentStatus.approved);
  }

  // Get pending documents
  Future<List<DocumentModel>> getPendingDocuments(String userId) async {
    return await getDocumentsByStatus(userId, DocumentStatus.pending);
  }

  // Get draft documents
  Future<List<DocumentModel>> getDraftDocuments(String userId) async {
    return await getDocumentsByStatus(userId, DocumentStatus.draft);
  }

  // Get archived documents
  Future<List<DocumentModel>> getArchivedDocuments(String userId) async {
    return await getDocumentsByStatus(userId, DocumentStatus.archived);
  }

  // Search documents
  Future<List<DocumentModel>> searchDocuments(String userId, String query) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      
      return allDocuments.where((document) {
        return document.name.toLowerCase().contains(query.toLowerCase()) ||
               document.description.toLowerCase().contains(query.toLowerCase()) ||
               document.originalName.toLowerCase().contains(query.toLowerCase()) ||
               document.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }

  // Get documents with specific tag
  Future<List<DocumentModel>> getDocumentsByTag(String userId, String tag) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      
      return allDocuments.where((document) {
        return document.tags.contains(tag);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get documents by tag: $e');
    }
  }

  // Get all unique tags for a user
  Future<List<String>> getAllTags(String userId) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      final Set<String> uniqueTags = {};
      
      for (final document in allDocuments) {
        uniqueTags.addAll(document.tags);
      }
      
      return uniqueTags.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get tags: $e');
    }
  }

  // Update document status
  Future<void> updateDocumentStatus(String documentId, DocumentStatus status) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        final updatedDocument = documentModel.updateStatus(status);
        await updateDocument(documentId, updatedDocument);
      }
    } catch (e) {
      throw Exception('Failed to update document status: $e');
    }
  }

  // Add tag to document
  Future<void> addTagToDocument(String documentId, String tag) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        final updatedDocument = documentModel.addTag(tag);
        await updateDocument(documentId, updatedDocument);
      }
    } catch (e) {
      throw Exception('Failed to add tag: $e');
    }
  }

  // Remove tag from document
  Future<void> removeTagFromDocument(String documentId, String tag) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        final updatedDocument = documentModel.removeTag(tag);
        await updateDocument(documentId, updatedDocument);
      }
    } catch (e) {
      throw Exception('Failed to remove tag: $e');
    }
  }

  // Share document with user
  Future<void> shareDocumentWithUser(String documentId, String userId) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        final updatedDocument = documentModel.shareWith(userId);
        await updateDocument(documentId, updatedDocument);
      }
    } catch (e) {
      throw Exception('Failed to share document: $e');
    }
  }

  // Unshare document with user
  Future<void> unshareDocumentWithUser(String documentId, String userId) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        final updatedDocument = documentModel.unshareWith(userId);
        await updateDocument(documentId, updatedDocument);
      }
    } catch (e) {
      throw Exception('Failed to unshare document: $e');
    }
  }

  // Increment download count
  Future<void> incrementDownloadCount(String documentId) async {
    try {
      final documentModel = await getDocument(documentId);
      if (documentModel != null) {
        final updatedDocument = documentModel.incrementDownloadCount();
        await updateDocument(documentId, updatedDocument);
      }
    } catch (e) {
      throw Exception('Failed to increment download count: $e');
    }
  }

  // Get document statistics by manager
  Future<Map<String, int>> getDocumentStatisticsByManager(String managerId) async {
    try {
      final documents = await getDocumentsByManager(managerId);
      
      final totalDocuments = documents.length;
      final pendingDocuments = documents.where((d) => d.status == DocumentStatus.pending).length;
      final approvedDocuments = documents.where((d) => d.status == DocumentStatus.approved).length;
      final totalSize = documents.fold<int>(0, (sum, doc) => sum + doc.fileSize);
      
      return {
        'totalDocuments': totalDocuments,
        'pendingDocuments': pendingDocuments,
        'approvedDocuments': approvedDocuments,
        'totalSize': totalSize,
      };
    } catch (e) {
      throw Exception('Failed to get document statistics by manager: $e');
    }
  }

  // Get document statistics
  Future<Map<String, int>> getDocumentStatistics(String userId) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      
      final stats = <String, int>{
        'total': allDocuments.length,
        'draft': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'archived': 0,
        'images': 0,
        'pdfs': 0,
        'documents': 0,
        'text': 0,
        'other': 0,
        'expired': 0,
        'expiresSoon': 0,
        'shared': 0,
        'totalSize': 0,
        'totalDownloads': 0,
      };
      
      for (final document in allDocuments) {
        // Count by status
        switch (document.status) {
          case DocumentStatus.draft:
            stats['draft'] = stats['draft']! + 1;
            break;
          case DocumentStatus.pending:
            stats['pending'] = stats['pending']! + 1;
            break;
          case DocumentStatus.approved:
            stats['approved'] = stats['approved']! + 1;
            break;
          case DocumentStatus.rejected:
            stats['rejected'] = stats['rejected']! + 1;
            break;
          case DocumentStatus.archived:
            stats['archived'] = stats['archived']! + 1;
            break;
        }
        
        // Count by file type
        if (document.isImage) {
          stats['images'] = stats['images']! + 1;
        } else if (document.isPdf) {
          stats['pdfs'] = stats['pdfs']! + 1;
        } else if (document.isDocument) {
          stats['documents'] = stats['documents']! + 1;
        } else if (document.isText) {
          stats['text'] = stats['text']! + 1;
        } else {
          stats['other'] = stats['other']! + 1;
        }
        
        // Count expired documents
        if (document.isExpired) {
          stats['expired'] = stats['expired']! + 1;
        }
        
        // Count documents expiring soon
        if (document.expiresSoon) {
          stats['expiresSoon'] = stats['expiresSoon']! + 1;
        }
        
        // Count shared documents
        if (document.isShared) {
          stats['shared'] = stats['shared']! + 1;
        }
        
        // Sum total size and downloads
        stats['totalSize'] = stats['totalSize']! + document.fileSize;
        stats['totalDownloads'] = stats['totalDownloads']! + document.downloadCount;
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get document statistics: $e');
    }
  }

  // Stream documents for real-time updates
  Stream<List<DocumentModel>> streamDocuments(String userId) {
    return _firestoreService.streamDocuments(userId: userId).map((documentsData) {
      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    });
  }

  // Stream documents by case
  Stream<List<DocumentModel>> streamDocumentsByCase(String userId, String caseId) {
    return _firestoreService.streamDocuments(userId: userId, caseId: caseId).map((documentsData) {
      return documentsData.map((data) => DocumentModel.fromMap(data)).toList();
    });
  }

  // Get recent documents (last 30 days)
  Future<List<DocumentModel>> getRecentDocuments(String userId) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      return allDocuments.where((document) {
        return document.createdAt.isAfter(thirtyDaysAgo);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent documents: $e');
    }
  }

  // Get most downloaded documents
  Future<List<DocumentModel>> getMostDownloadedDocuments(String userId, {int limit = 10}) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      allDocuments.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
      return allDocuments.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get most downloaded documents: $e');
    }
  }

  // Get largest documents
  Future<List<DocumentModel>> getLargestDocuments(String userId, {int limit = 10}) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      allDocuments.sort((a, b) => b.fileSize.compareTo(a.fileSize));
      return allDocuments.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get largest documents: $e');
    }
  }

  // Get expired documents
  Future<List<DocumentModel>> getExpiredDocuments(String userId) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      return allDocuments.where((document) => document.isExpired).toList();
    } catch (e) {
      throw Exception('Failed to get expired documents: $e');
    }
  }

  // Get documents expiring soon
  Future<List<DocumentModel>> getDocumentsExpiringSoon(String userId) async {
    try {
      final allDocuments = await getDocumentsByUser(userId);
      return allDocuments.where((document) => document.expiresSoon).toList();
    } catch (e) {
      throw Exception('Failed to get documents expiring soon: $e');
    }
  }

}


