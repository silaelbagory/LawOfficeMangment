import 'package:cloud_firestore/cloud_firestore.dart';

class LawyerActionModel {
  final String id;
  final String lawyerId;
  final String lawyerName;
  final String managerId; // Manager who owns this action
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const LawyerActionModel({
    required this.id,
    required this.lawyerId,
    required this.lawyerName,
    required this.managerId,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'managerId': managerId,
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  factory LawyerActionModel.fromMap(Map<String, dynamic> map) {
    return LawyerActionModel(
      id: map['id'] ?? '',
      lawyerId: map['lawyerId'] ?? '',
      lawyerName: map['lawyerName'] ?? '',
      managerId: map['managerId'] ?? '',
      action: map['action'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  LawyerActionModel copyWith({
    String? id,
    String? lawyerId,
    String? lawyerName,
    String? managerId,
    String? action,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return LawyerActionModel(
      id: id ?? this.id,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      managerId: managerId ?? this.managerId,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for common actions
  static LawyerActionModel createCase({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Created case: $caseTitle',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'create_case',
        'caseId': caseId,
        'caseTitle': caseTitle,
      },
    );
  }

  static LawyerActionModel updateCase({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Updated case: $caseTitle',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'update_case',
        'caseId': caseId,
        'caseTitle': caseTitle,
      },
    );
  }

  static LawyerActionModel deleteCase({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String caseTitle,
    String? caseId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Deleted case: $caseTitle',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'delete_case',
        'caseId': caseId,
        'caseTitle': caseTitle,
      },
    );
  }

  static LawyerActionModel createClient({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String clientName,
    String? clientId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Created client: $clientName',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'create_client',
        'clientId': clientId,
        'clientName': clientName,
      },
    );
  }

  static LawyerActionModel updateClient({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String clientName,
    String? clientId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Updated client: $clientName',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'update_client',
        'clientId': clientId,
        'clientName': clientName,
      },
    );
  }

  static LawyerActionModel uploadDocument({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String documentName,
    String? documentId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Uploaded document: $documentName',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'upload_document',
        'documentId': documentId,
        'documentName': documentName,
      },
    );
  }

  static LawyerActionModel deleteDocument({
    required String lawyerId,
    required String lawyerName,
    required String managerId,
    required String documentName,
    String? documentId,
  }) {
    return LawyerActionModel(
      id: '',
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      managerId: managerId,
      action: 'Deleted document: $documentName',
      timestamp: DateTime.now(),
      metadata: {
        'actionType': 'delete_document',
        'documentId': documentId,
        'documentName': documentName,
      },
    );
  }
}
