import '../../core/services/firestore_service.dart';
import '../models/lawyer_action_model.dart';

class ActionRepository {
  final FirestoreService _firestoreService;

  ActionRepository(this._firestoreService);

  // Log a lawyer action
  Future<String> logAction(LawyerActionModel action) async {
    try {
      final actionData = action.toMap();
      return await _firestoreService.createDocument(
        collection: 'lawyer_actions',
        data: actionData,
      );
    } catch (e) {
      throw Exception('Failed to log action: $e');
    }
  }

  // Get actions by manager
  Future<List<LawyerActionModel>> getActionsByManager(String managerId) async {
    try {
      final documents = await _firestoreService.getCollection(
        collection: 'lawyer_actions',
        whereConditions: {'managerId': managerId},
      );
      
      return documents.map((doc) => LawyerActionModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get actions by manager: $e');
    }
  }

  // Get all actions
  Future<List<LawyerActionModel>> getAllActions() async {
    try {
      final actionsData = await _firestoreService.getCollection(
        collection: 'lawyer_actions',
        orderBy: 'timestamp',
        descending: true,
      );

      return actionsData.map((data) => LawyerActionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get all actions: $e');
    }
  }

  // Get actions by lawyer
  Future<List<LawyerActionModel>> getActionsByLawyer(String lawyerId) async {
    try {
      final actionsData = await _firestoreService.getCollection(
        collection: 'lawyer_actions',
        whereConditions: {'lawyerId': lawyerId},
        orderBy: 'timestamp',
        descending: true,
      );

      return actionsData.map((data) => LawyerActionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get actions by lawyer: $e');
    }
  }

  // Get actions by date range
  Future<List<LawyerActionModel>> getActionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final actionsData = await _firestoreService.getCollection(
        collection: 'lawyer_actions',
        whereConditions: {
          'timestamp': {
            '>=': startDate,
            '<=': endDate,
          },
        },
        orderBy: 'timestamp',
        descending: true,
      );

      return actionsData.map((data) => LawyerActionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get actions by date range: $e');
    }
  }

  // Get actions by action type
  Future<List<LawyerActionModel>> getActionsByType(String actionType) async {
    try {
      final actionsData = await _firestoreService.getCollection(
        collection: 'lawyer_actions',
        whereConditions: {'metadata.actionType': actionType},
        orderBy: 'timestamp',
        descending: true,
      );

      return actionsData.map((data) => LawyerActionModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get actions by type: $e');
    }
  }

  // Get recent actions (last 30 days)
  Future<List<LawyerActionModel>> getRecentActions() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return await getActionsByDateRange(
        startDate: thirtyDaysAgo,
        endDate: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get recent actions: $e');
    }
  }

  // Get actions count by lawyer
  Future<Map<String, int>> getActionsCountByLawyer() async {
    try {
      final allActions = await getAllActions();
      final Map<String, int> counts = {};

      for (final action in allActions) {
        counts[action.lawyerName] = (counts[action.lawyerName] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get actions count by lawyer: $e');
    }
  }

  // Get actions count by type
  Future<Map<String, int>> getActionsCountByType() async {
    try {
      final allActions = await getAllActions();
      final Map<String, int> counts = {};

      for (final action in allActions) {
        final actionType = action.metadata?['actionType'] ?? 'unknown';
        counts[actionType] = (counts[actionType] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get actions count by type: $e');
    }
  }

  // Stream all actions for real-time updates
  Stream<List<LawyerActionModel>> streamAllActions() {
    return _firestoreService.streamCollection(collection: 'lawyer_actions').map((actionsData) {
      return actionsData.map((data) => LawyerActionModel.fromMap(data)).toList();
    });
  }

  // Stream actions by lawyer for real-time updates
  Stream<List<LawyerActionModel>> streamActionsByLawyer(String lawyerId) {
    return _firestoreService.streamCollection(
      collection: 'lawyer_actions',
      whereConditions: {'lawyerId': lawyerId},
    ).map((actionsData) {
      return actionsData.map((data) => LawyerActionModel.fromMap(data)).toList();
    });
  }

  // Delete action (for cleanup purposes)
  Future<void> deleteAction(String actionId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: 'lawyer_actions',
        documentId: actionId,
      );
    } catch (e) {
      throw Exception('Failed to delete action: $e');
    }
  }

  // Helper methods for common actions

  // Log case creation
  Future<void> logCaseCreation({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) async {
    final action = LawyerActionModel.createCase(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      caseTitle: caseTitle,
      caseId: caseId,
    );
    await logAction(action);
  }

  // Log case update
  Future<void> logCaseUpdate({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) async {
    final action = LawyerActionModel.updateCase(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      caseTitle: caseTitle,
      caseId: caseId,
    );
    await logAction(action);
  }

  // Log case deletion
  Future<void> logCaseDeletion({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) async {
    final action = LawyerActionModel.deleteCase(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      caseTitle: caseTitle,
      caseId: caseId,
    );
    await logAction(action);
  }

  // Log client creation
  Future<void> logClientCreation({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String clientName,
    String? clientId,
  }) async {
    final action = LawyerActionModel.createClient(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      clientName: clientName,
      clientId: clientId,
    );
    await logAction(action);
  }

  // Log client update
  Future<void> logClientUpdate({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String clientName,
    String? clientId,
  }) async {
    final action = LawyerActionModel.updateClient(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      clientName: clientName,
      clientId: clientId,
    );
    await logAction(action);
  }

  // Log document upload
  Future<void> logDocumentUpload({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String documentName,
    String? documentId,
  }) async {
    final action = LawyerActionModel.uploadDocument(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      documentName: documentName,
      documentId: documentId,
    );
    await logAction(action);
  }

  // Log document deletion
  Future<void> logDocumentDeletion({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String documentName,
    String? documentId,
  }) async {
    final action = LawyerActionModel.deleteDocument(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      documentName: documentName,
      documentId: documentId,
    );
    await logAction(action);
  }
}
