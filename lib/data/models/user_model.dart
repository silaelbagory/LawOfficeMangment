import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  manager,
  lawyer;

  String get value {
    switch (this) {
      case UserRole.manager:
        return 'manager';
      case UserRole.lawyer:
        return 'lawyer';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'manager':
        return UserRole.manager;
      case 'lawyer':
        return UserRole.lawyer;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }
}

enum UserStatus {
  pending,
  approved,
  rejected,
  active,
  inactive;

  String get value {
    switch (this) {
      case UserStatus.pending:
        return 'pending';
      case UserStatus.approved:
        return 'approved';
      case UserStatus.rejected:
        return 'rejected';
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
    }
  }

  static UserStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return UserStatus.pending;
      case 'approved':
        return UserStatus.approved;
      case 'rejected':
        return UserStatus.rejected;
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      default:
        return UserStatus.pending;
    }
  }
}

class UserPermissions {
  final bool casesRead;
  final bool casesWrite;
  final bool clientsRead;
  final bool clientsWrite;
  final bool documentsRead;
  final bool documentsWrite;
  final bool reportsRead;
  final bool reportsWrite;
  final bool usersRead;
  final bool usersWrite;

  const UserPermissions({
    this.casesRead = false,
    this.casesWrite = false,
    this.clientsRead = false,
    this.clientsWrite = false,
    this.documentsRead = false,
    this.documentsWrite = false,
    this.reportsRead = false,
    this.reportsWrite = false,
    this.usersRead = false,
    this.usersWrite = false,
  });

  factory UserPermissions.manager() {
    return const UserPermissions(
      casesRead: true,
      casesWrite: true,
      clientsRead: true,
      clientsWrite: true,
      documentsRead: true,
      documentsWrite: true,
      reportsRead: true,
      reportsWrite: true,
      usersRead: true,
      usersWrite: true,
    );
  }

  factory UserPermissions.lawyer({
    bool casesRead = true,
    bool casesWrite = false,
    bool clientsRead = true,
    bool clientsWrite = false,
    bool documentsRead = true,
    bool documentsWrite = false,
    bool reportsRead = false,
    bool reportsWrite = false,
    bool usersRead = false,
    bool usersWrite = false,
  }) {
    return UserPermissions(
      casesRead: casesRead,
      casesWrite: casesWrite,
      clientsRead: clientsRead,
      clientsWrite: clientsWrite,
      documentsRead: documentsRead,
      documentsWrite: documentsWrite,
      reportsRead: reportsRead,
      reportsWrite: reportsWrite,
      usersRead: usersRead,
      usersWrite: usersWrite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'casesRead': casesRead,
      'casesWrite': casesWrite,
      'clientsRead': clientsRead,
      'clientsWrite': clientsWrite,
      'documentsRead': documentsRead,
      'documentsWrite': documentsWrite,
      'reportsRead': reportsRead,
      'reportsWrite': reportsWrite,
      'usersRead': usersRead,
      'usersWrite': usersWrite,
    };
  }

  factory UserPermissions.fromMap(Map<String, dynamic> map) {
    return UserPermissions(
      casesRead: map['casesRead'] ?? false,
      casesWrite: map['casesWrite'] ?? false,
      clientsRead: map['clientsRead'] ?? false,
      clientsWrite: map['clientsWrite'] ?? false,
      documentsRead: map['documentsRead'] ?? false,
      documentsWrite: map['documentsWrite'] ?? false,
      reportsRead: map['reportsRead'] ?? false,
      reportsWrite: map['reportsWrite'] ?? false,
      usersRead: map['usersRead'] ?? false,
      usersWrite: map['usersWrite'] ?? false,
    );
  }

  UserPermissions copyWith({
    bool? casesRead,
    bool? casesWrite,
    bool? clientsRead,
    bool? clientsWrite,
    bool? documentsRead,
    bool? documentsWrite,
    bool? reportsRead,
    bool? reportsWrite,
    bool? usersRead,
    bool? usersWrite,
  }) {
    return UserPermissions(
      casesRead: casesRead ?? this.casesRead,
      casesWrite: casesWrite ?? this.casesWrite,
      clientsRead: clientsRead ?? this.clientsRead,
      clientsWrite: clientsWrite ?? this.clientsWrite,
      documentsRead: documentsRead ?? this.documentsRead,
      documentsWrite: documentsWrite ?? this.documentsWrite,
      reportsRead: reportsRead ?? this.reportsRead,
      reportsWrite: reportsWrite ?? this.reportsWrite,
      usersRead: usersRead ?? this.usersRead,
      usersWrite: usersWrite ?? this.usersWrite,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final UserPermissions permissions;
  final UserStatus status;
  final String? createdBy; // ID of the manager who created this user
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'permissions': permissions.toMap(),
      'status': status.value,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'lawyer'),
      permissions: UserPermissions.fromMap(map['permissions'] ?? {}),
      status: UserStatus.fromString(map['status'] ?? 'pending'),
      createdBy: map['createdBy'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    UserPermissions? permissions,
    UserStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool hasPermission(String permission) {
    switch (permission) {
      case 'casesRead':
        return permissions.casesRead;
      case 'casesWrite':
        return permissions.casesWrite;
      case 'clientsRead':
        return permissions.clientsRead;
      case 'clientsWrite':
        return permissions.clientsWrite;
      case 'documentsRead':
        return permissions.documentsRead;
      case 'documentsWrite':
        return permissions.documentsWrite;
      case 'reportsRead':
        return permissions.reportsRead;
      case 'reportsWrite':
        return permissions.reportsWrite;
      case 'usersRead':
        return permissions.usersRead;
      case 'usersWrite':
        return permissions.usersWrite;
      default:
        return false;
    }
  }

  bool get isManager => role == UserRole.manager;
  bool get isLawyer => role == UserRole.lawyer;
  bool get isPending => status == UserStatus.pending;
  bool get isApproved => status == UserStatus.approved;
  bool get isRejected => status == UserStatus.rejected;
  bool get isInactive => status == UserStatus.inactive;
  
  // Check if this user was created by a specific manager
  bool wasCreatedBy(String managerId) {
    return createdBy == managerId;
  }
  
  // Check if this user can access content created by a specific manager
  bool canAccessContentFrom(String managerId) {
    // Managers can access everything
    if (isManager) return true;
    
    // Lawyers can only access content from their creator
    return wasCreatedBy(managerId);
  }
}