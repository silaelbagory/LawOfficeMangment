import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/case_model.dart';
import '../../data/repositories/case_repository.dart';
import 'case_state.dart';

class CaseCubit extends Cubit<CaseState> {
  final CaseRepository _caseRepository;

  CaseCubit(this._caseRepository) : super(CaseInitial());

  // Create a new case
  Future<void> createCase(CaseModel caseModel) async {
    try {
      emit(CaseLoading());
      
      final caseId = await _caseRepository.createCase(caseModel);
      final createdCase = caseModel.copyWith(id: caseId);
      
      emit(CaseCreated(createdCase));
      
      // Reload cases
      await loadCases(caseModel.userId);
    } catch (e) {
      emit(CaseError('Failed to create case: $e'));
    }
  }

  // Load cases by manager
  Future<void> loadCasesByManager(String managerId) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesByManager(managerId);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases by manager: $e'));
    }
  }

  // Load all cases for a user
  Future<void> loadCases(String userId) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesByUser(userId);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases: $e'));
    }
  }

  // Load cases by status
  Future<void> loadCasesByStatus(String userId, CaseStatus status) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesByStatus(userId, status);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases by status: $e'));
    }
  }

  // Load cases by priority
  Future<void> loadCasesByPriority(String userId, CasePriority priority) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesByPriority(userId, priority);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases by priority: $e'));
    }
  }

  // Load cases by client
  Future<void> loadCasesByClient(String userId, String clientId) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesByClient(userId, clientId);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases by client: $e'));
    }
  }

  // Load overdue cases
  Future<void> loadOverdueCases(String userId) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getOverdueCases(userId);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load overdue cases: $e'));
    }
  }

  // Load cases due soon
  Future<void> loadCasesDueSoon(String userId) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesDueSoon(userId);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases due soon: $e'));
    }
  }

  // Search cases
  Future<void> searchCases(String userId, String query) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.searchCases(userId, query);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to search cases: $e'));
    }
  }

  // Load cases by tag
  Future<void> loadCasesByTag(String userId, String tag) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getCasesByTag(userId, tag);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load cases by tag: $e'));
    }
  }

  // Load all tags
  Future<void> loadAllTags(String userId) async {
    try {
      final tags = await _caseRepository.getAllTags(userId);
      emit(CaseTagsLoaded(tags));
    } catch (e) {
      emit(CaseError('Failed to load tags: $e'));
    }
  }

  // Update case
  Future<void> updateCase(String caseId, CaseModel caseModel) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.updateCase(caseId, caseModel);
      emit(CaseUpdated(caseModel));
      
      // Reload cases
      await loadCases(caseModel.userId);
    } catch (e) {
      emit(CaseError('Failed to update case: $e'));
    }
  }

  // Delete case
  Future<void> deleteCase(String caseId, String userId) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.deleteCase(caseId);
      emit(CaseDeleted(caseId));
      
      // Reload cases
      await loadCases(userId);
    } catch (e) {
      emit(CaseError('Failed to delete case: $e'));
    }
  }

  // Update case status
  Future<void> updateCaseStatus(String caseId, CaseStatus status) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.updateCaseStatus(caseId, status);
      
      // Get updated case
      final updatedCase = await _caseRepository.getCase(caseId);
      if (updatedCase != null) {
        emit(CaseStatusUpdated(updatedCase));
        
        // Reload cases
        await loadCases(updatedCase.userId);
      }
    } catch (e) {
      emit(CaseError('Failed to update case status: $e'));
    }
  }

  // Update case priority
  Future<void> updateCasePriority(String caseId, CasePriority priority) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.updateCasePriority(caseId, priority);
      
      // Get updated case
      final updatedCase = await _caseRepository.getCase(caseId);
      if (updatedCase != null) {
        emit(CasePriorityUpdated(updatedCase));
        
        // Reload cases
        await loadCases(updatedCase.userId);
      }
    } catch (e) {
      emit(CaseError('Failed to update case priority: $e'));
    }
  }

  // Add tag to case
  Future<void> addTagToCase(String caseId, String tag) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.addTagToCase(caseId, tag);
      
      // Get updated case
      final updatedCase = await _caseRepository.getCase(caseId);
      if (updatedCase != null) {
        emit(CaseTagAdded(updatedCase));
        
        // Reload cases
        await loadCases(updatedCase.userId);
      }
    } catch (e) {
      emit(CaseError('Failed to add tag: $e'));
    }
  }

  // Remove tag from case
  Future<void> removeTagFromCase(String caseId, String tag) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.removeTagFromCase(caseId, tag);
      
      // Get updated case
      final updatedCase = await _caseRepository.getCase(caseId);
      if (updatedCase != null) {
        emit(CaseTagRemoved(updatedCase));
        
        // Reload cases
        await loadCases(updatedCase.userId);
      }
    } catch (e) {
      emit(CaseError('Failed to remove tag: $e'));
    }
  }

  // Add document to case
  Future<void> addDocumentToCase(String caseId, String documentId) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.addDocumentToCase(caseId, documentId);
      
      // Get updated case
      final updatedCase = await _caseRepository.getCase(caseId);
      if (updatedCase != null) {
        emit(CaseDocumentAdded(updatedCase));
        
        // Reload cases
        await loadCases(updatedCase.userId);
      }
    } catch (e) {
      emit(CaseError('Failed to add document: $e'));
    }
  }

  // Remove document from case
  Future<void> removeDocumentFromCase(String caseId, String documentId) async {
    try {
      emit(CaseLoading());
      
      await _caseRepository.removeDocumentFromCase(caseId, documentId);
      
      // Get updated case
      final updatedCase = await _caseRepository.getCase(caseId);
      if (updatedCase != null) {
        emit(CaseDocumentRemoved(updatedCase));
        
        // Reload cases
        await loadCases(updatedCase.userId);
      }
    } catch (e) {
      emit(CaseError('Failed to remove document: $e'));
    }
  }

  // Load case statistics by manager
  Future<void> loadCaseStatisticsByManager(String managerId) async {
    try {
      final statistics = await _caseRepository.getCaseStatisticsByManager(managerId);
      emit(CaseStatisticsLoaded(statistics));
    } catch (e) {
      emit(CaseError('Failed to load case statistics by manager: $e'));
    }
  }

  // Load case statistics
  Future<void> loadCaseStatistics(String userId) async {
    try {
      final statistics = await _caseRepository.getCaseStatistics(userId);
      emit(CaseStatisticsLoaded(statistics));
    } catch (e) {
      emit(CaseError('Failed to load case statistics: $e'));
    }
  }

  // Load recent cases
  Future<void> loadRecentCases(String userId) async {
    try {
      emit(CaseLoading());
      
      final cases = await _caseRepository.getRecentCases(userId);
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError('Failed to load recent cases: $e'));
    }
  }

  // Get current cases
  List<CaseModel> get currentCases {
    final currentState = state;
    if (currentState is CaseLoaded) {
      return currentState.cases;
    }
    return [];
  }

  // Get current statistics
  Map<String, int> get currentStatistics {
    final currentState = state;
    if (currentState is CaseStatisticsLoaded) {
      return currentState.statistics;
    }
    return {};
  }

  // Get current tags
  List<String> get currentTags {
    final currentState = state;
    if (currentState is CaseTagsLoaded) {
      return currentState.tags;
    }
    return [];
  }

  // Check if loading
  bool get isLoading {
    return state is CaseLoading;
  }

  // Get error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is CaseError) {
      return currentState.message;
    }
    return null;
  }

  // Clear error
  void clearError() {
    if (state is CaseError) {
      emit(CaseInitial());
    }
  }

  // Refresh cases
  Future<void> refreshCases(String userId) async {
    await loadCases(userId);
  }
}



