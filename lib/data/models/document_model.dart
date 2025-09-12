import 'package:equatable/equatable.dart';

enum DocumentType {
  contract,
  agreement,
  courtFiling,
  correspondence,
  evidence,
  report,
  invoice,
  receipt,
  certificate,
  license,
  permit,
  other,
}

extension DocumentTypeExtension on DocumentType {
  String get displayText {
    switch (this) {
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.agreement:
        return 'Agreement';
      case DocumentType.courtFiling:
        return 'Court Filing';
      case DocumentType.correspondence:
        return 'Correspondence';
      case DocumentType.evidence:
        return 'Evidence';
      case DocumentType.report:
        return 'Report';
      case DocumentType.invoice:
        return 'Invoice';
      case DocumentType.receipt:
        return 'Receipt';
      case DocumentType.certificate:
        return 'Certificate';
      case DocumentType.license:
        return 'License';
      case DocumentType.permit:
        return 'Permit';
      case DocumentType.other:
        return 'Other';
    }
  }
}

enum DocumentStatus {
  draft,
  pending,
  approved,
  rejected,
  archived,
}

extension DocumentStatusExtension on DocumentStatus {
  String get displayText {
    switch (this) {
      case DocumentStatus.draft:
        return 'Draft';
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.archived:
        return 'Archived';
    }
  }
}

class DocumentModel extends Equatable {
  final String id;
  final String name;
  final String originalName;
  final String description;
  final String userId; // User who uploaded the document
  final String managerId; // Manager who owns this document
  final String? caseId; // Associated case
  final String? clientId; // Associated client
  final DocumentType type;
  final DocumentStatus status;
  final String fileUrl;
  final String filePath;
  final String fileExtension;
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiryDate;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final String? notes;
  final String? version;
  final String? uploadedBy;
  final bool isPublic;
  final bool isEncrypted;
  final String? password;
  final String? checksum;
  final int downloadCount;
  final DateTime? lastAccessed;
  final String? folderPath;
  final List<String> sharedWith;
  final String? thumbnailUrl;
  final Map<String, dynamic>? properties;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.originalName,
    required this.description,
    required this.userId,
    required this.managerId,
    this.caseId,
    this.clientId,
    this.type = DocumentType.other,
    this.status = DocumentStatus.pending,
    required this.fileUrl,
    required this.filePath,
    required this.fileExtension,
    required this.fileSize,
    required this.mimeType,
    required this.createdAt,
    required this.updatedAt,
    this.expiryDate,
    this.tags = const [],
    this.metadata,
    this.notes,
    this.version,
    this.uploadedBy,
    this.isPublic = false,
    this.isEncrypted = false,
    this.password,
    this.checksum,
    this.downloadCount = 0,
    this.lastAccessed,
    this.folderPath,
    this.sharedWith = const [],
    this.thumbnailUrl,
    this.properties,
  });

  // Create DocumentModel from Firestore document
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      originalName: map['originalName'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      managerId: map['managerId'] ?? '',
      caseId: map['caseId'],
      clientId: map['clientId'],
      type: DocumentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DocumentType.other,
      ),
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DocumentStatus.pending,
      ),
      fileUrl: map['fileUrl'] ?? '',
      filePath: map['filePath'] ?? '',
      fileExtension: map['fileExtension'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      mimeType: map['mimeType'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
      expiryDate: map['expiryDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      metadata: map['metadata'],
      notes: map['notes'],
      version: map['version'],
      uploadedBy: map['uploadedBy'],
      isPublic: map['isPublic'] ?? false,
      isEncrypted: map['isEncrypted'] ?? false,
      password: map['password'],
      checksum: map['checksum'],
      downloadCount: map['downloadCount'] ?? 0,
      lastAccessed: map['lastAccessed'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastAccessed'])
          : null,
      folderPath: map['folderPath'],
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      thumbnailUrl: map['thumbnailUrl'],
      properties: map['properties'],
    );
  }

  // Convert DocumentModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'originalName': originalName,
      'description': description,
      'userId': userId,
      'managerId': managerId,
      'caseId': caseId,
      'clientId': clientId,
      'type': type.name,
      'status': status.name,
      'fileUrl': fileUrl,
      'filePath': filePath,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'tags': tags,
      'metadata': metadata,
      'notes': notes,
      'version': version,
      'uploadedBy': uploadedBy,
      'isPublic': isPublic,
      'isEncrypted': isEncrypted,
      'password': password,
      'checksum': checksum,
      'downloadCount': downloadCount,
      'lastAccessed': lastAccessed?.millisecondsSinceEpoch,
      'folderPath': folderPath,
      'sharedWith': sharedWith,
      'thumbnailUrl': thumbnailUrl,
      'properties': properties,
    };
  }

  // Create a copy of DocumentModel with updated fields
  DocumentModel copyWith({
    String? id,
    String? name,
    String? originalName,
    String? description,
    String? userId,
    String? managerId,
    String? caseId,
    String? clientId,
    DocumentType? type,
    DocumentStatus? status,
    String? fileUrl,
    String? filePath,
    String? fileExtension,
    int? fileSize,
    String? mimeType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiryDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? notes,
    String? version,
    String? uploadedBy,
    bool? isPublic,
    bool? isEncrypted,
    String? password,
    String? checksum,
    int? downloadCount,
    DateTime? lastAccessed,
    String? folderPath,
    List<String>? sharedWith,
    String? thumbnailUrl,
    Map<String, dynamic>? properties,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      managerId: managerId ?? this.managerId,
      caseId: caseId ?? this.caseId,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      filePath: filePath ?? this.filePath,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      version: version ?? this.version,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isPublic: isPublic ?? this.isPublic,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      password: password ?? this.password,
      checksum: checksum ?? this.checksum,
      downloadCount: downloadCount ?? this.downloadCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      folderPath: folderPath ?? this.folderPath,
      sharedWith: sharedWith ?? this.sharedWith,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      properties: properties ?? this.properties,
    );
  }

  // Get document type display text
  String get typeDisplayText {
    switch (type) {
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.agreement:
        return 'Agreement';
      case DocumentType.courtFiling:
        return 'Court Filing';
      case DocumentType.correspondence:
        return 'Correspondence';
      case DocumentType.evidence:
        return 'Evidence';
      case DocumentType.report:
        return 'Report';
      case DocumentType.invoice:
        return 'Invoice';
      case DocumentType.receipt:
        return 'Receipt';
      case DocumentType.certificate:
        return 'Certificate';
      case DocumentType.license:
        return 'License';
      case DocumentType.permit:
        return 'Permit';
      case DocumentType.other:
        return 'Other';
    }
  }

  // Get document status display text
  String get statusDisplayText {
    switch (status) {
      case DocumentStatus.draft:
        return 'Draft';
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.archived:
        return 'Archived';
    }
  }

  // Get status color (for UI)
  String get statusColor {
    switch (status) {
      case DocumentStatus.draft:
        return 'grey';
      case DocumentStatus.pending:
        return 'orange';
      case DocumentStatus.approved:
        return 'green';
      case DocumentStatus.rejected:
        return 'red';
      case DocumentStatus.archived:
        return 'blue';
    }
  }

  // Get file size formatted
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Check if document is image
  bool get isImage {
    return mimeType.startsWith('image/') || 
           ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp'].contains(fileExtension.toLowerCase());
  }

  // Check if document is PDF
  bool get isPdf {
    return mimeType == 'application/pdf' || fileExtension.toLowerCase() == 'pdf';
  }

  // Check if document is document (Word, Excel, PowerPoint)
  bool get isDocument {
    return mimeType.startsWith('application/') && 
           ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(fileExtension.toLowerCase());
  }

  // Check if document is text
  bool get isText {
    return mimeType.startsWith('text/') || 
           ['txt', 'rtf', 'md'].contains(fileExtension.toLowerCase());
  }

  // Get document icon based on type
  String get documentIcon {
    if (isImage) return 'image';
    if (isPdf) return 'picture_as_pdf';
    if (isDocument) return 'description';
    if (isText) return 'text_snippet';
    return 'insert_drive_file';
  }

  // Check if document is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if document expires soon (within 30 days)
  bool get expiresSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now);
    return difference.inDays <= 30 && difference.inDays >= 0;
  }

  // Get days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    return expiryDate!.difference(now).inDays;
  }

  // Check if document is approved
  bool get isApproved {
    return status == DocumentStatus.approved;
  }

  // Check if document is pending
  bool get isPending {
    return status == DocumentStatus.pending;
  }

  // Check if document is draft
  bool get isDraft {
    return status == DocumentStatus.draft;
  }

  // Check if document is archived
  bool get isArchived {
    return status == DocumentStatus.archived;
  }

  // Get document age in days
  int get documentAgeInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Check if document was created recently (within last 7 days)
  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }

  // Check if document was updated recently (within last 24 hours)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours <= 24;
  }

  // Check if document was accessed recently (within last 7 days)
  bool get isRecentlyAccessed {
    if (lastAccessed == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastAccessed!);
    return difference.inDays <= 7;
  }

  // Add tag
  DocumentModel addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(
      tags: [...tags, tag],
      updatedAt: DateTime.now(),
    );
  }

  // Remove tag
  DocumentModel removeTag(String tag) {
    if (!tags.contains(tag)) return this;
    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Update status
  DocumentModel updateStatus(DocumentStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  // Increment download count
  DocumentModel incrementDownloadCount() {
    return copyWith(
      downloadCount: downloadCount + 1,
      lastAccessed: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Share with user
  DocumentModel shareWith(String userId) {
    if (sharedWith.contains(userId)) return this;
    return copyWith(
      sharedWith: [...sharedWith, userId],
      updatedAt: DateTime.now(),
    );
  }

  // Unshare with user
  DocumentModel unshareWith(String userId) {
    if (!sharedWith.contains(userId)) return this;
    return copyWith(
      sharedWith: sharedWith.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Check if document is shared with user
  bool isSharedWith(String userId) {
    return sharedWith.contains(userId);
  }

  // Get creation date as formatted string
  String get createdAtFormatted {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get update date as formatted string
  String get updatedAtFormatted {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  // Get expiry date as formatted string
  String? get expiryDateFormatted {
    if (expiryDate == null) return null;
    return '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}';
  }

  // Get last accessed date as formatted string
  String? get lastAccessedFormatted {
    if (lastAccessed == null) return null;
    return '${lastAccessed!.day}/${lastAccessed!.month}/${lastAccessed!.year}';
  }

  // Validate document data
  bool get isValid {
    return id.isNotEmpty && 
           name.isNotEmpty && 
           originalName.isNotEmpty &&
           fileUrl.isNotEmpty &&
           filePath.isNotEmpty &&
           userId.isNotEmpty;
  }

  // Get document summary
  String get summary {
    final parts = <String>[];
    parts.add(name);
    parts.add('(${fileSizeFormatted})');
    parts.add(statusDisplayText);
    if (caseId != null) {
      parts.add('Case: $caseId');
    }
    return parts.join(' • ');
  }

  // Check if document has tags
  bool get hasTags {
    return tags.isNotEmpty;
  }

  // Get tag count
  int get tagCount {
    return tags.length;
  }

  // Check if document is shared
  bool get isShared {
    return sharedWith.isNotEmpty;
  }

  // Get share count
  int get shareCount {
    return sharedWith.length;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        originalName,
        description,
        userId,
        caseId,
        clientId,
        type,
        status,
        fileUrl,
        filePath,
        fileExtension,
        fileSize,
        mimeType,
        createdAt,
        updatedAt,
        expiryDate,
        tags,
        metadata,
        notes,
        version,
        uploadedBy,
        isPublic,
        isEncrypted,
        password,
        checksum,
        downloadCount,
        lastAccessed,
        folderPath,
        sharedWith,
        thumbnailUrl,
        properties,
      ];

  @override
  String toString() {
    return 'DocumentModel(id: $id, name: $name, type: $type, status: $status, fileSize: $fileSizeFormatted)';
  }
}
