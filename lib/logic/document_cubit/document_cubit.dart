import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/document_model.dart';
import '../../data/repositories/document_repository.dart';
import 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepository _documentRepository;

  DocumentCubit(this._documentRepository) : super(DocumentInitial());

  // Upload document file
  Future<void> uploadDocumentFile({
    required File file,
    required String userId,
    required String managerId,
    String? caseId,
    String? clientId,
    String? name,
    String? description,
    DocumentType type = DocumentType.other,
    List<String> tags = const [],
    Function(double)? onProgress,
  }) async {
    try {
      emit(DocumentUploading(0.0));
      
      final documentId = await _documentRepository.uploadDocumentFile(
        file: file,
        userId: userId,
        managerId: managerId,
        caseId: caseId,
        clientId: clientId,
        name: name,
        description: description,
        type: type,
        tags: tags,
      );
      
      // Get the created document
      final document = await _documentRepository.getDocument(documentId);
      if (document != null) {
        emit(DocumentUploaded(document));
        
        // Reload documents
        await loadDocuments(userId);
      }
    } catch (e) {
      emit(DocumentUploadError('Failed to upload document: $e'));
    }
  }

  // Create a new document
  Future<void> createDocument(DocumentModel documentModel) async {
    try {
      emit(DocumentLoading());
      
      final documentId = await _documentRepository.createDocument(documentModel);
      final createdDocument = documentModel.copyWith(id: documentId);
      
      emit(DocumentCreated(createdDocument));
      
      // Reload documents
      await loadDocuments(documentModel.userId);
    } catch (e) {
      emit(DocumentError('Failed to create document: $e'));
    }
  }

  // Load documents by manager
  Future<void> loadDocumentsByManager(String managerId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByManager(managerId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents by manager: $e'));
    }
  }

  // Load all documents for a user
  Future<void> loadDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByUser(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents: $e'));
    }
  }

  // Load documents by case
  Future<void> loadDocumentsByCase(String userId, String caseId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByCase(userId, caseId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents by case: $e'));
    }
  }

  // Load documents by client
  Future<void> loadDocumentsByClient(String userId, String clientId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByClient(userId, clientId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents by client: $e'));
    }
  }

  // Load documents by type
  Future<void> loadDocumentsByType(String userId, DocumentType type) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByType(userId, type);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents by type: $e'));
    }
  }

  // Load documents by status
  Future<void> loadDocumentsByStatus(String userId, DocumentStatus status) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByStatus(userId, status);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents by status: $e'));
    }
  }

  // Load approved documents
  Future<void> loadApprovedDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getApprovedDocuments(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load approved documents: $e'));
    }
  }

  // Load pending documents
  Future<void> loadPendingDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getPendingDocuments(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load pending documents: $e'));
    }
  }

  // Load draft documents
  Future<void> loadDraftDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDraftDocuments(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load draft documents: $e'));
    }
  }

  // Load archived documents
  Future<void> loadArchivedDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getArchivedDocuments(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load archived documents: $e'));
    }
  }

  // Search documents
  Future<void> searchDocuments(String userId, String query) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.searchDocuments(userId, query);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to search documents: $e'));
    }
  }

  // Load documents by tag
  Future<void> loadDocumentsByTag(String userId, String tag) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsByTag(userId, tag);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents by tag: $e'));
    }
  }

  // Load all tags
  Future<void> loadAllTags(String userId) async {
    try {
      final tags = await _documentRepository.getAllTags(userId);
      emit(DocumentTagsLoaded(tags));
    } catch (e) {
      emit(DocumentError('Failed to load tags: $e'));
    }
  }

  // Update document
  Future<void> updateDocument(String documentId, DocumentModel documentModel) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.updateDocument(documentId, documentModel);
      emit(DocumentUpdated(documentModel));
      
      // Reload documents
      await loadDocuments(documentModel.userId);
    } catch (e) {
      emit(DocumentError('Failed to update document: $e'));
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId, String userId) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.deleteDocument(documentId);
      emit(DocumentDeleted(documentId));
      
      // Reload documents
      await loadDocuments(userId);
    } catch (e) {
      emit(DocumentError('Failed to delete document: $e'));
    }
  }

  // Update document status
  Future<void> updateDocumentStatus(String documentId, DocumentStatus status) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.updateDocumentStatus(documentId, status);
      
      // Get updated document
      final updatedDocument = await _documentRepository.getDocument(documentId);
      if (updatedDocument != null) {
        emit(DocumentStatusUpdated(updatedDocument));
        
        // Reload documents
        await loadDocuments(updatedDocument.userId);
      }
    } catch (e) {
      emit(DocumentError('Failed to update document status: $e'));
    }
  }

  // Add tag to document
  Future<void> addTagToDocument(String documentId, String tag) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.addTagToDocument(documentId, tag);
      
      // Get updated document
      final updatedDocument = await _documentRepository.getDocument(documentId);
      if (updatedDocument != null) {
        emit(DocumentTagAdded(updatedDocument));
        
        // Reload documents
        await loadDocuments(updatedDocument.userId);
      }
    } catch (e) {
      emit(DocumentError('Failed to add tag: $e'));
    }
  }

  // Remove tag from document
  Future<void> removeTagFromDocument(String documentId, String tag) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.removeTagFromDocument(documentId, tag);
      
      // Get updated document
      final updatedDocument = await _documentRepository.getDocument(documentId);
      if (updatedDocument != null) {
        emit(DocumentTagRemoved(updatedDocument));
        
        // Reload documents
        await loadDocuments(updatedDocument.userId);
      }
    } catch (e) {
      emit(DocumentError('Failed to remove tag: $e'));
    }
  }

  // Share document with user
  Future<void> shareDocumentWithUser(String documentId, String userId) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.shareDocumentWithUser(documentId, userId);
      
      // Get updated document
      final updatedDocument = await _documentRepository.getDocument(documentId);
      if (updatedDocument != null) {
        emit(DocumentShared(updatedDocument));
        
        // Reload documents
        await loadDocuments(updatedDocument.userId);
      }
    } catch (e) {
      emit(DocumentError('Failed to share document: $e'));
    }
  }

  // Unshare document with user
  Future<void> unshareDocumentWithUser(String documentId, String userId) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.unshareDocumentWithUser(documentId, userId);
      
      // Get updated document
      final updatedDocument = await _documentRepository.getDocument(documentId);
      if (updatedDocument != null) {
        emit(DocumentUnshared(updatedDocument));
        
        // Reload documents
        await loadDocuments(updatedDocument.userId);
      }
    } catch (e) {
      emit(DocumentError('Failed to unshare document: $e'));
    }
  }

  // Increment download count
  Future<void> incrementDownloadCount(String documentId) async {
    try {
      emit(DocumentLoading());
      
      await _documentRepository.incrementDownloadCount(documentId);
      
      // Get updated document
      final updatedDocument = await _documentRepository.getDocument(documentId);
      if (updatedDocument != null) {
        emit(DocumentDownloadCountIncremented(updatedDocument));
      }
    } catch (e) {
      emit(DocumentError('Failed to increment download count: $e'));
    }
  }

  // Load document statistics by manager
  Future<void> loadDocumentStatisticsByManager(String managerId) async {
    try {
      final statistics = await _documentRepository.getDocumentStatisticsByManager(managerId);
      emit(DocumentStatisticsLoaded(statistics));
    } catch (e) {
      emit(DocumentError('Failed to load document statistics by manager: $e'));
    }
  }

  // Load document statistics
  Future<void> loadDocumentStatistics(String userId) async {
    try {
      final statistics = await _documentRepository.getDocumentStatistics(userId);
      emit(DocumentStatisticsLoaded(statistics));
    } catch (e) {
      emit(DocumentError('Failed to load document statistics: $e'));
    }
  }

  // Load recent documents
  Future<void> loadRecentDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getRecentDocuments(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load recent documents: $e'));
    }
  }

  // Load most downloaded documents
  Future<void> loadMostDownloadedDocuments(String userId, {int limit = 10}) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getMostDownloadedDocuments(userId, limit: limit);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load most downloaded documents: $e'));
    }
  }

  // Load largest documents
  Future<void> loadLargestDocuments(String userId, {int limit = 10}) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getLargestDocuments(userId, limit: limit);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load largest documents: $e'));
    }
  }

  // Load expired documents
  Future<void> loadExpiredDocuments(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getExpiredDocuments(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load expired documents: $e'));
    }
  }

  // Load documents expiring soon
  Future<void> loadDocumentsExpiringSoon(String userId) async {
    try {
      emit(DocumentLoading());
      
      final documents = await _documentRepository.getDocumentsExpiringSoon(userId);
      emit(DocumentLoaded(documents));
    } catch (e) {
      emit(DocumentError('Failed to load documents expiring soon: $e'));
    }
  }

  // Get current documents
  List<DocumentModel> get currentDocuments {
    final currentState = state;
    if (currentState is DocumentLoaded) {
      return currentState.documents;
    }
    return [];
  }

  // Get current statistics
  Map<String, int> get currentStatistics {
    final currentState = state;
    if (currentState is DocumentStatisticsLoaded) {
      return currentState.statistics;
    }
    return {};
  }

  // Get current tags
  List<String> get currentTags {
    final currentState = state;
    if (currentState is DocumentTagsLoaded) {
      return currentState.tags;
    }
    return [];
  }

  // Check if loading
  bool get isLoading {
    return state is DocumentLoading;
  }

  // Check if uploading
  bool get isUploading {
    return state is DocumentUploading;
  }

  // Get upload progress
  double get uploadProgress {
    final currentState = state;
    if (currentState is DocumentUploading) {
      return currentState.progress;
    }
    return 0.0;
  }

  // Get error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is DocumentError || currentState is DocumentUploadError) {
      if (currentState is DocumentError) {
        return currentState.message;
      } else if (currentState is DocumentUploadError) {
        return currentState.message;
      }
    }
    return null;
  }

  // Clear error
  void clearError() {
    if (state is DocumentError || state is DocumentUploadError) {
      emit(DocumentInitial());
    }
  }

  // Refresh documents
  Future<void> refreshDocuments(String userId) async {
    await loadDocuments(userId);
  }
}


