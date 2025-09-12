import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/lawyer_action_model.dart';
import '../../data/repositories/action_repository.dart';
import 'action_state.dart';

class ActionCubit extends Cubit<ActionState> {
  final ActionRepository _actionRepository;

  ActionCubit(this._actionRepository) : super(ActionInitial());

  // Load all actions
  Future<void> loadAllActions() async {
    try {
      emit(ActionLoading());
      
      final actions = await _actionRepository.getAllActions();
      emit(ActionsLoaded(actions));
    } catch (e) {
      emit(ActionError('Failed to load actions: $e'));
    }
  }

  // Load actions by manager
  Future<void> loadActionsByManager(String managerId) async {
    try {
      emit(ActionLoading());
      
      final actions = await _actionRepository.getActionsByManager(managerId);
      emit(ActionsLoaded(actions));
    } catch (e) {
      emit(ActionError('Failed to load actions by manager: $e'));
    }
  }

  // Load actions by lawyer
  Future<void> loadActionsByLawyer(String lawyerId) async {
    try {
      emit(ActionLoading());
      
      final actions = await _actionRepository.getActionsByLawyer(lawyerId);
      emit(ActionsLoaded(actions));
    } catch (e) {
      emit(ActionError('Failed to load actions by lawyer: $e'));
    }
  }

  // Load recent actions
  Future<void> loadRecentActions() async {
    try {
      emit(ActionLoading());
      
      final actions = await _actionRepository.getRecentActions();
      emit(ActionsLoaded(actions));
    } catch (e) {
      emit(ActionError('Failed to load recent actions: $e'));
    }
  }

  // Load actions by date range
  Future<void> loadActionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      emit(ActionLoading());
      
      final actions = await _actionRepository.getActionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      emit(ActionsLoaded(actions));
    } catch (e) {
      emit(ActionError('Failed to load actions by date range: $e'));
    }
  }

  // Load actions by type
  Future<void> loadActionsByType(String actionType) async {
    try {
      emit(ActionLoading());
      
      final actions = await _actionRepository.getActionsByType(actionType);
      emit(ActionsLoaded(actions));
    } catch (e) {
      emit(ActionError('Failed to load actions by type: $e'));
    }
  }

  // Log an action
  Future<void> logAction(LawyerActionModel action) async {
    try {
      final actionId = await _actionRepository.logAction(action);
      emit(ActionLogged(actionId));
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log action: $e'));
    }
  }

  // Log client creation
  Future<void> logClientCreation({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String clientName,
    String? clientId,
  }) async {
    try {
      await _actionRepository.logClientCreation(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        managerId: managerId,
        clientName: clientName,
        clientId: clientId,
      );
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log client creation: $e'));
    }
  }

  // Log case creation
  Future<void> logCaseCreation({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) async {
    try {
      await _actionRepository.logCaseCreation(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        managerId: managerId,
        caseTitle: caseTitle,
        caseId: caseId,
      );
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log case creation: $e'));
    }
  }

  // Log case update
  Future<void> logCaseUpdate({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) async {
    try {
      await _actionRepository.logCaseUpdate(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        managerId: managerId,
        caseTitle: caseTitle,
        caseId: caseId,
      );
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log case update: $e'));
    }
  }

  // Log case deletion
  Future<void> logCaseDeletion({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) async {
    try {
      await _actionRepository.logCaseDeletion(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        managerId: managerId,
        caseTitle: caseTitle,
        caseId: caseId,
      );
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log case deletion: $e'));
    }
  }

  // Log document upload
  Future<void> logDocumentUpload({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String documentName,
    String? documentId,
  }) async {
    try {
      await _actionRepository.logDocumentUpload(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        managerId: managerId,
        documentName: documentName,
        documentId: documentId,
      );
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log document upload: $e'));
    }
  }

  // Log document deletion
  Future<void> logDocumentDeletion({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String documentName,
    String? documentId,
  }) async {
    try {
      await _actionRepository.logDocumentDeletion(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        managerId: managerId,
        documentName: documentName,
        documentId: documentId,
      );
      
      // Reload actions
      await loadAllActions();
    } catch (e) {
      emit(ActionError('Failed to log document deletion: $e'));
    }
  }

  // Load action statistics
  Future<void> loadActionStatistics() async {
    try {
      emit(ActionLoading());
      
      final statistics = await _actionRepository.getActionsCountByLawyer();
      emit(ActionStatisticsLoaded(statistics));
    } catch (e) {
      emit(ActionError('Failed to load action statistics: $e'));
    }
  }

  // Get current actions
  List<LawyerActionModel> get currentActions {
    final currentState = state;
    if (currentState is ActionsLoaded) {
      return currentState.actions;
    }
    return [];
  }

  // Get current statistics
  Map<String, int> get currentStatistics {
    final currentState = state;
    if (currentState is ActionStatisticsLoaded) {
      return currentState.statistics;
    }
    return {};
  }

  // Check if loading
  bool get isLoading {
    return state is ActionLoading;
  }

  // Get error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is ActionError) {
      return currentState.message;
    }
    return null;
  }

  // Clear error
  void clearError() {
    if (state is ActionError) {
      emit(ActionInitial());
    }
  }
}
