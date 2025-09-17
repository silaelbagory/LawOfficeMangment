enum CaseStatus { open, inProgress, onHold, closed }
enum CasePriority { low, medium, high, urgent }

extension CaseStatusExtension on CaseStatus {
  String get displayText {
    switch (this) {
      case CaseStatus.open:
        return 'Open';
      case CaseStatus.inProgress:
        return 'In Progress';
      case CaseStatus.onHold:
        return 'On Hold';
      case CaseStatus.closed:
        return 'Closed';
    }
  }
}

extension CasePriorityExtension on CasePriority {
  String get displayText {
    switch (this) {
      case CasePriority.low:
        return 'Low';
      case CasePriority.medium:
        return 'Medium';
      case CasePriority.high:
        return 'High';
      case CasePriority.urgent:
        return 'Urgent';
    }
  }
}

class CaseModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String managerId; // Manager who owns this case
  final String? clientId;
  final CaseStatus status;
  final CasePriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? hearingDate;
  final String? notes;
  final double? estimatedHours;
  final String? caseNumber;
  final String? courtName;
  final String? caseType;
  final String? opposingParty;
  final String? opposingCounsel;
  final List<String> tags;
  final List<String> documents;

  CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.managerId,
    this.clientId,
    this.status = CaseStatus.open,
    this.priority = CasePriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.hearingDate,
    this.notes,
    this.estimatedHours,
    this.caseNumber,
    this.courtName,
    this.caseType,
    this.opposingParty,
    this.opposingCounsel,
    List<String>? tags,
    List<String>? documents,
  })  : tags = tags ?? [],
        documents = documents ?? [];

  CaseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? managerId,
    String? clientId,
    CaseStatus? status,
    CasePriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? hearingDate,
    String? notes,
    double? estimatedHours,
    String? caseNumber,
    String? courtName,
    String? caseType,
    String? opposingParty,
    String? opposingCounsel,
    List<String>? tags,
    List<String>? documents,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      managerId: managerId ?? this.managerId,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      hearingDate: hearingDate ?? this.hearingDate,
      notes: notes ?? this.notes,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      caseNumber: caseNumber ?? this.caseNumber,
      courtName: courtName ?? this.courtName,
      caseType: caseType ?? this.caseType,
      opposingParty: opposingParty ?? this.opposingParty,
      opposingCounsel: opposingCounsel ?? this.opposingCounsel,
      tags: tags ?? this.tags,
      documents: documents ?? this.documents,
    );
  }

  CaseModel updateStatus(CaseStatus newStatus) => copyWith(status: newStatus);
  CaseModel updatePriority(CasePriority newPriority) => copyWith(priority: newPriority);
  CaseModel addTag(String tag) => copyWith(tags: [...tags, tag]);
  CaseModel removeTag(String tag) => copyWith(tags: tags.where((t) => t != tag).toList());
  CaseModel addDocument(String documentId) => copyWith(documents: [...documents, documentId]);
  CaseModel removeDocument(String documentId) =>
      copyWith(documents: documents.where((d) => d != documentId).toList());

  // ✅ Safe Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'managerId': managerId,
      'clientId': clientId,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dueDate': dueDate,
      'hearingDate': hearingDate,
      'notes': notes,
      'estimatedHours': estimatedHours,
      'caseNumber': caseNumber,
      'courtName': courtName,
      'caseType': caseType,
      'opposingParty': opposingParty,
      'opposingCounsel': opposingCounsel,
      'tags': tags,
      'documents': documents,
    };
  }

  // ✅ Safe parsing from Firestore / JSON
  factory CaseModel.fromMap(Map<String, dynamic> map) {
    CaseStatus safeStatus(String? raw) {
      if (raw == null) return CaseStatus.open;
      return CaseStatus.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => CaseStatus.open,
      );
    }

    CasePriority safePriority(String? raw) {
      if (raw == null) return CasePriority.medium;
      return CasePriority.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => CasePriority.medium,
      );
    }

    return CaseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      managerId: map['managerId'] ?? '',
      clientId: map['clientId'],
      status: safeStatus(map['status']),
      priority: safePriority(map['priority']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      dueDate: _tryParseDate(map['dueDate']),
      hearingDate: _tryParseDate(map['hearingDate']),
      notes: map['notes'],
      estimatedHours: (map['estimatedHours'] is int)
          ? (map['estimatedHours'] as int).toDouble()
          : map['estimatedHours']?.toDouble(),
      caseNumber: map['caseNumber'],
      courtName: map['courtName'],
      caseType: map['caseType'],
      opposingParty: map['opposingParty'],
      opposingCounsel: map['opposingCounsel'],
      tags: List<String>.from(map['tags'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
    );
  }

  // 🔹 Helpers to parse dates safely
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // Computed properties
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != CaseStatus.closed;
  }

  bool get isDueSoon {
    if (dueDate == null) return false;
    final difference = dueDate!.difference(DateTime.now());
    return difference.inDays <= 3 && difference.inDays >= 0;
  }

  String get dueDateFormatted {
    if (dueDate == null) return '-';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  String get createdAtFormatted {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
