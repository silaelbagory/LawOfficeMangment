import '../../core/services/firestore_service.dart';
import '../models/case_model.dart';

class CaseRepository {
  final FirestoreService _firestoreService;

  CaseRepository(this._firestoreService);

  // Create a new case
  Future<String> createCase(CaseModel caseModel) async {
    try {
      final caseData = caseModel.toMap();
      return await _firestoreService.createCase(caseData);
    } catch (e) {
      throw Exception('Failed to create case: $e');
    }
  }

  // Get case by ID
  Future<CaseModel?> getCase(String caseId) async {
    try {
      final caseData = await _firestoreService.getCase(caseId);
      if (caseData != null) {
        return CaseModel.fromMap(caseData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get case: $e');
    }
  }

  // Update case
  Future<void> updateCase(String caseId, CaseModel caseModel) async {
    try {
      final caseData = caseModel.toMap();
      await _firestoreService.updateCase(caseId, caseData);
    } catch (e) {
      throw Exception('Failed to update case: $e');
    }
  }

  // Delete case
  Future<void> deleteCase(String caseId) async {
    try {
      await _firestoreService.deleteCase(caseId);
    } catch (e) {
      throw Exception('Failed to delete case: $e');
    }
  }

  // Get cases by manager
  Future<List<CaseModel>> getCasesByManager(String managerId) async {
    try {
      final documents = await _firestoreService.getCollection(
        collection: 'cases',
        whereConditions: {'managerId': managerId},
      );
      
      return documents.map((doc) => CaseModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get cases by manager: $e');
    }
  }

  // Get all cases for a user
  Future<List<CaseModel>> getCasesByUser(String userId) async {
    try {
      final casesData = await _firestoreService.getCollection(
        collection: 'cases',
        whereConditions: {'userId': userId},
        orderBy: 'createdAt',
        descending: true,
      );

      return casesData.map((data) => CaseModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get cases: $e');
    }
  }

  // Get cases by status
  Future<List<CaseModel>> getCasesByStatus(String userId, CaseStatus status) async {
    try {
      final casesData = await _firestoreService.getCollection(
        collection: 'cases',
        whereConditions: {
          'userId': userId,
          'status': status.name,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return casesData.map((data) => CaseModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get cases by status: $e');
    }
  }

  // Get cases by priority
  Future<List<CaseModel>> getCasesByPriority(String userId, CasePriority priority) async {
    try {
      final casesData = await _firestoreService.getCollection(
        collection: 'cases',
        whereConditions: {
          'userId': userId,
          'priority': priority.name,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return casesData.map((data) => CaseModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get cases by priority: $e');
    }
  }

  // Get cases by client
  Future<List<CaseModel>> getCasesByClient(String userId, String clientId) async {
    try {
      final casesData = await _firestoreService.getCollection(
        collection: 'cases',
        whereConditions: {
          'userId': userId,
          'clientId': clientId,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return casesData.map((data) => CaseModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get cases by client: $e');
    }
  }

  // Get overdue cases
  Future<List<CaseModel>> getOverdueCases(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      final now = DateTime.now();
      
      return allCases.where((caseModel) {
        return caseModel.dueDate != null && 
               now.isAfter(caseModel.dueDate!) && 
               caseModel.status != CaseStatus.closed;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get overdue cases: $e');
    }
  }

  // Get cases due soon (within 3 days)
  Future<List<CaseModel>> getCasesDueSoon(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      final now = DateTime.now();
      
      return allCases.where((caseModel) {
        if (caseModel.dueDate == null) return false;
        final difference = caseModel.dueDate!.difference(now);
        return difference.inDays <= 3 && difference.inDays >= 0;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get cases due soon: $e');
    }
  }

  // Search cases
  Future<List<CaseModel>> searchCases(String userId, String query) async {
    try {
      final allCases = await getCasesByUser(userId);
      
      return allCases.where((caseModel) {
        return caseModel.title.toLowerCase().contains(query.toLowerCase()) ||
               caseModel.description.toLowerCase().contains(query.toLowerCase()) ||
               caseModel.caseNumber?.toLowerCase().contains(query.toLowerCase()) == true ||
               caseModel.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search cases: $e');
    }
  }

  // Get cases with specific tag
  Future<List<CaseModel>> getCasesByTag(String userId, String tag) async {
    try {
      final allCases = await getCasesByUser(userId);
      
      return allCases.where((caseModel) {
        return caseModel.tags.contains(tag);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get cases by tag: $e');
    }
  }

  // Get all unique tags for a user
  Future<List<String>> getAllTags(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      final Set<String> uniqueTags = {};
      
      for (final caseModel in allCases) {
        uniqueTags.addAll(caseModel.tags);
      }
      
      return uniqueTags.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get tags: $e');
    }
  }

  // Update case status
  Future<void> updateCaseStatus(String caseId, CaseStatus status) async {
    try {
      final caseModel = await getCase(caseId);
      if (caseModel != null) {
        final updatedCase = caseModel.updateStatus(status);
        await updateCase(caseId, updatedCase);
      }
    } catch (e) {
      throw Exception('Failed to update case status: $e');
    }
  }

  // Update case priority
  Future<void> updateCasePriority(String caseId, CasePriority priority) async {
    try {
      final caseModel = await getCase(caseId);
      if (caseModel != null) {
        final updatedCase = caseModel.updatePriority(priority);
        await updateCase(caseId, updatedCase);
      }
    } catch (e) {
      throw Exception('Failed to update case priority: $e');
    }
  }

  // Add tag to case
  Future<void> addTagToCase(String caseId, String tag) async {
    try {
      final caseModel = await getCase(caseId);
      if (caseModel != null) {
        final updatedCase = caseModel.addTag(tag);
        await updateCase(caseId, updatedCase);
      }
    } catch (e) {
      throw Exception('Failed to add tag: $e');
    }
  }

  // Remove tag from case
  Future<void> removeTagFromCase(String caseId, String tag) async {
    try {
      final caseModel = await getCase(caseId);
      if (caseModel != null) {
        final updatedCase = caseModel.removeTag(tag);
        await updateCase(caseId, updatedCase);
      }
    } catch (e) {
      throw Exception('Failed to remove tag: $e');
    }
  }

  // Add document to case
  Future<void> addDocumentToCase(String caseId, String documentId) async {
    try {
      final caseModel = await getCase(caseId);
      if (caseModel != null) {
        final updatedCase = caseModel.addDocument(documentId);
        await updateCase(caseId, updatedCase);
      }
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  // Remove document from case
  Future<void> removeDocumentFromCase(String caseId, String documentId) async {
    try {
      final caseModel = await getCase(caseId);
      if (caseModel != null) {
        final updatedCase = caseModel.removeDocument(documentId);
        await updateCase(caseId, updatedCase);
      }
    } catch (e) {
      throw Exception('Failed to remove document: $e');
    }
  }

  // Get case statistics by manager
  Future<Map<String, int>> getCaseStatisticsByManager(String managerId) async {
    try {
      final cases = await getCasesByManager(managerId);
      
      final totalCases = cases.length;
      final openCases = cases.where((c) => c.status == CaseStatus.open).length;
      final closedCases = cases.where((c) => c.status == CaseStatus.closed).length;
      final urgentCases = cases.where((c) => c.priority == CasePriority.urgent).length;
      final overdueCases = cases.where((c) => c.isOverdue).length;
      
      return {
        'totalCases': totalCases,
        'openCases': openCases,
        'closedCases': closedCases,
        'urgentCases': urgentCases,
        'overdueCases': overdueCases,
      };
    } catch (e) {
      throw Exception('Failed to get case statistics by manager: $e');
    }
  }

  // Get case statistics
  Future<Map<String, int>> getCaseStatistics(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      
      final stats = <String, int>{
        'total': allCases.length,
        'open': 0,
        'inProgress': 0,
        'onHold': 0,
        'closed': 0,
        'overdue': 0,
        'dueSoon': 0,
      };
      
      final now = DateTime.now();
      
      for (final caseModel in allCases) {
        // Count by status
        switch (caseModel.status) {
          case CaseStatus.open:
            stats['open'] = stats['open']! + 1;
            break;
          case CaseStatus.inProgress:
            stats['inProgress'] = stats['inProgress']! + 1;
            break;
          case CaseStatus.onHold:
            stats['onHold'] = stats['onHold']! + 1;
            break;
          case CaseStatus.closed:
            stats['closed'] = stats['closed']! + 1;
            break;
        }
        
        // Count overdue cases
        if (caseModel.dueDate != null && 
            now.isAfter(caseModel.dueDate!) && 
            caseModel.status != CaseStatus.closed) {
          stats['overdue'] = stats['overdue']! + 1;
        }
        
        // Count cases due soon
        if (caseModel.dueDate != null) {
          final difference = caseModel.dueDate!.difference(now);
          if (difference.inDays <= 3 && difference.inDays >= 0) {
            stats['dueSoon'] = stats['dueSoon']! + 1;
          }
        }
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get case statistics: $e');
    }
  }

  // Stream cases for real-time updates
  Stream<List<CaseModel>> streamCases(String userId) {
    return _firestoreService.streamCases(userId: userId).map((casesData) {
      return casesData.map((data) => CaseModel.fromMap(data)).toList();
    });
  }

  // Stream cases by status
  Stream<List<CaseModel>> streamCasesByStatus(String userId, CaseStatus status) {
    return _firestoreService.streamCollection(
      collection: 'cases',
      whereConditions: {
        'userId': userId,
        'status': status.name,
      },
      orderBy: 'createdAt',
      descending: true,
    ).map((casesData) {
      return casesData.map((data) => CaseModel.fromMap(data)).toList();
    });
  }

  // Get recent cases (last 30 days)
  Future<List<CaseModel>> getRecentCases(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      return allCases.where((caseModel) {
        return caseModel.createdAt.isAfter(thirtyDaysAgo);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent cases: $e');
    }
  }

  // Get case count by status
  Future<Map<CaseStatus, int>> getCaseCountByStatus(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      final counts = <CaseStatus, int>{
        CaseStatus.open: 0,
        CaseStatus.inProgress: 0,
        CaseStatus.onHold: 0,
        CaseStatus.closed: 0,
      };
      
      for (final caseModel in allCases) {
        counts[caseModel.status] = counts[caseModel.status]! + 1;
      }
      
      return counts;
    } catch (e) {
      throw Exception('Failed to get case count by status: $e');
    }
  }

  // Get case count by priority
  Future<Map<CasePriority, int>> getCaseCountByPriority(String userId) async {
    try {
      final allCases = await getCasesByUser(userId);
      final counts = <CasePriority, int>{
        CasePriority.low: 0,
        CasePriority.medium: 0,
        CasePriority.high: 0,
        CasePriority.urgent: 0,
      };
      
      for (final caseModel in allCases) {
        counts[caseModel.priority] = counts[caseModel.priority]! + 1;
      }
      
      return counts;
    } catch (e) {
      throw Exception('Failed to get case count by priority: $e');
    }
  }
}



