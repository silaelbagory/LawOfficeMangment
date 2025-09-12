import 'package:equatable/equatable.dart';

enum ClientType {
  individual,
  company,
  organization,
}

extension ClientTypeExtension on ClientType {
  String get displayText {
    switch (this) {
      case ClientType.individual:
        return 'Individual';
      case ClientType.company:
        return 'Company';
      case ClientType.organization:
        return 'Organization';
    }
  }
}

enum ClientStatus {
  active,
  inactive,
  potential,
  former,
}

extension ClientStatusExtension on ClientStatus {
  String get displayText {
    switch (this) {
      case ClientStatus.active:
        return 'Active';
      case ClientStatus.inactive:
        return 'Inactive';
      case ClientStatus.potential:
        return 'Potential';
      case ClientStatus.former:
        return 'Former';
    }
  }
}

class ClientModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final ClientType type;
  final ClientStatus status;
  final String userId; // Lawyer/Admin who created the client
  final String managerId; // Manager who owns this client
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? companyName;
  final String? contactPerson;
  final String? website;
  final String? notes;
  final List<String> caseIds;
  final Map<String, dynamic>? metadata;
  final String? taxId;
  final String? registrationNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? occupation;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? preferredLanguage;
  final String? timeZone;
  final bool isVip;
  final double? creditLimit;
  final String? paymentTerms;
  final String? billingAddress;
  final String? shippingAddress;

  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.type = ClientType.individual,
    this.status = ClientStatus.active,
    required this.userId,
    required this.managerId,
    required this.createdAt,
    required this.updatedAt,
    this.companyName,
    this.contactPerson,
    this.website,
    this.notes,
    this.caseIds = const [],
    this.metadata,
    this.taxId,
    this.registrationNumber,
    this.dateOfBirth,
    this.gender,
    this.occupation,
    this.emergencyContact,
    this.emergencyPhone,
    this.preferredLanguage,
    this.timeZone,
    this.isVip = false,
    this.creditLimit,
    this.paymentTerms,
    this.billingAddress,
    this.shippingAddress,
  });

  // Create ClientModel from Firestore document
  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      country: map['country'],
      type: ClientType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ClientType.individual,
      ),
      status: ClientStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ClientStatus.active,
      ),
      userId: map['userId'] ?? '',
      managerId: map['managerId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
      companyName: map['companyName'],
      contactPerson: map['contactPerson'],
      website: map['website'],
      notes: map['notes'],
      caseIds: List<String>.from(map['caseIds'] ?? []),
      metadata: map['metadata'],
      taxId: map['taxId'],
      registrationNumber: map['registrationNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'])
          : null,
      gender: map['gender'],
      occupation: map['occupation'],
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
      preferredLanguage: map['preferredLanguage'],
      timeZone: map['timeZone'],
      isVip: map['isVip'] ?? false,
      creditLimit: map['creditLimit']?.toDouble(),
      paymentTerms: map['paymentTerms'],
      billingAddress: map['billingAddress'],
      shippingAddress: map['shippingAddress'],
    );
  }

  // Convert ClientModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'type': type.name,
      'status': status.name,
      'userId': userId,
      'managerId': managerId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'website': website,
      'notes': notes,
      'caseIds': caseIds,
      'metadata': metadata,
      'taxId': taxId,
      'registrationNumber': registrationNumber,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'gender': gender,
      'occupation': occupation,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'preferredLanguage': preferredLanguage,
      'timeZone': timeZone,
      'isVip': isVip,
      'creditLimit': creditLimit,
      'paymentTerms': paymentTerms,
      'billingAddress': billingAddress,
      'shippingAddress': shippingAddress,
    };
  }

  // Create a copy of ClientModel with updated fields
  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    ClientType? type,
    ClientStatus? status,
    String? userId,
    String? managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? companyName,
    String? contactPerson,
    String? website,
    String? notes,
    List<String>? caseIds,
    Map<String, dynamic>? metadata,
    String? taxId,
    String? registrationNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? occupation,
    String? emergencyContact,
    String? emergencyPhone,
    String? preferredLanguage,
    String? timeZone,
    bool? isVip,
    double? creditLimit,
    String? paymentTerms,
    String? billingAddress,
    String? shippingAddress,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      type: type ?? this.type,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      caseIds: caseIds ?? this.caseIds,
      metadata: metadata ?? this.metadata,
      taxId: taxId ?? this.taxId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timeZone: timeZone ?? this.timeZone,
      isVip: isVip ?? this.isVip,
      creditLimit: creditLimit ?? this.creditLimit,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  // Get client type display text
  String get typeDisplayText {
    switch (type) {
      case ClientType.individual:
        return 'Individual';
      case ClientType.company:
        return 'Company';
      case ClientType.organization:
        return 'Organization';
    }
  }

  // Get client status display text
  String get statusDisplayText {
    switch (status) {
      case ClientStatus.active:
        return 'Active';
      case ClientStatus.inactive:
        return 'Inactive';
      case ClientStatus.potential:
        return 'Potential';
      case ClientStatus.former:
        return 'Former';
    }
  }

  // Get status color (for UI)
  String get statusColor {
    switch (status) {
      case ClientStatus.active:
        return 'green';
      case ClientStatus.inactive:
        return 'orange';
      case ClientStatus.potential:
        return 'blue';
      case ClientStatus.former:
        return 'grey';
    }
  }

  // Get full address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  // Get display name (company name for companies, name for individuals)
  String get displayName {
    if (type == ClientType.company && companyName != null && companyName!.isNotEmpty) {
      return companyName!;
    }
    return name;
  }

  // Get contact person name
  String get contactName {
    if (type == ClientType.company && contactPerson != null && contactPerson!.isNotEmpty) {
      return contactPerson!;
    }
    return name;
  }

  // Get client initials for avatar
  String get initials {
    final nameToUse = displayName;
    final names = nameToUse.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return names[0][0].toUpperCase();
    }
  }

  // Check if client is active
  bool get isActive {
    return status == ClientStatus.active;
  }

  // Check if client is potential
  bool get isPotential {
    return status == ClientStatus.potential;
  }

  // Check if client is former
  bool get isFormer {
    return status == ClientStatus.former;
  }

  // Get age (if date of birth is available)
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Get case count
  int get caseCount {
    return caseIds.length;
  }

  // Check if client has cases
  bool get hasCases {
    return caseIds.isNotEmpty;
  }

  // Add case
  ClientModel addCase(String caseId) {
    if (caseIds.contains(caseId)) return this;
    return copyWith(
      caseIds: [...caseIds, caseId],
      updatedAt: DateTime.now(),
    );
  }

  // Remove case
  ClientModel removeCase(String caseId) {
    if (!caseIds.contains(caseId)) return this;
    return copyWith(
      caseIds: caseIds.where((id) => id != caseId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Update status
  ClientModel updateStatus(ClientStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  // Toggle VIP status
  ClientModel toggleVipStatus() {
    return copyWith(
      isVip: !isVip,
      updatedAt: DateTime.now(),
    );
  }

  // Get client creation date as formatted string
  String get createdAtFormatted {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get client update date as formatted string
  String get updatedAtFormatted {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  // Get date of birth as formatted string
  String? get dateOfBirthFormatted {
    if (dateOfBirth == null) return null;
    return '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}';
  }

  // Check if client was created recently (within last 7 days)
  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }

  // Check if client was updated recently (within last 24 hours)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours <= 24;
  }

  // Get client age in days
  int get clientAgeInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Validate client data
  bool get isValid {
    return id.isNotEmpty && 
           name.isNotEmpty && 
           email.isNotEmpty &&
           email.contains('@') &&
           userId.isNotEmpty;
  }

  // Get primary contact method
  String get primaryContact {
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      return phoneNumber!;
    }
    return email;
  }

  // Check if client has complete address
  bool get hasCompleteAddress {
    return address != null && 
           city != null && 
           state != null && 
           zipCode != null &&
           address!.isNotEmpty &&
           city!.isNotEmpty &&
           state!.isNotEmpty &&
           zipCode!.isNotEmpty;
  }

  // Check if client has emergency contact
  bool get hasEmergencyContact {
    return emergencyContact != null && 
           emergencyPhone != null &&
           emergencyContact!.isNotEmpty &&
           emergencyPhone!.isNotEmpty;
  }

  // Get client summary
  String get summary {
    final parts = <String>[];
    parts.add(displayName);
    if (type == ClientType.company && contactPerson != null) {
      parts.add('Contact: $contactPerson');
    }
    parts.add('Status: ${statusDisplayText}');
    if (caseCount > 0) {
      parts.add('Cases: $caseCount');
    }
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        address,
        city,
        state,
        zipCode,
        country,
        type,
        status,
        userId,
        createdAt,
        updatedAt,
        companyName,
        contactPerson,
        website,
        notes,
        caseIds,
        metadata,
        taxId,
        registrationNumber,
        dateOfBirth,
        gender,
        occupation,
        emergencyContact,
        emergencyPhone,
        preferredLanguage,
        timeZone,
        isVip,
        creditLimit,
        paymentTerms,
        billingAddress,
        shippingAddress,
      ];

  @override
  String toString() {
    return 'ClientModel(id: $id, name: $name, email: $email, type: $type, status: $status)';
  }
}
