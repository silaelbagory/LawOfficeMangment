import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic CRUD operations

  // Create document
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      DocumentReference docRef;
      if (documentId != null) {
        docRef = _firestore.collection(collection).doc(documentId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }
      return docRef.id;
    } catch (e) {
      throw 'Failed to create document: $e';
    }
  }

  // Get document by ID
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Failed to get document: $e';
    }
  }

  // Update document
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw 'Failed to update document: $e';
    }
  }

  // Delete document
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw 'Failed to delete document: $e';
    }
  }

  // Get collection with optional filters
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? whereConditions,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply where conditions
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw 'Failed to get collection: $e';
    }
  }

  // Stream collection
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? whereConditions,
  }) {
    try {
      Query query = _firestore.collection(collection);

      // Apply where conditions
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      throw 'Failed to stream collection: $e';
    }
  }

  // Stream document
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    try {
      return _firestore.collection(collection).doc(documentId).snapshots().map((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }
        return null;
      });
    } catch (e) {
      throw 'Failed to stream document: $e';
    }
  }

  // Batch operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final documentId = operation['documentId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;

        DocumentReference docRef;
        if (documentId != null) {
          docRef = _firestore.collection(collection).doc(documentId);
        } else {
          docRef = _firestore.collection(collection).doc();
        }

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to perform batch operation: $e';
    }
  }

  // Search documents
  Future<List<Map<String, dynamic>>> searchDocuments({
    required String collection,
    required String field,
    required String searchTerm,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      // For text search, we'll use array-contains for tags or simple equality
      // For more complex search, consider using Algolia or similar service
      if (field == 'tags') {
        query = query.where(field, arrayContains: searchTerm.toLowerCase());
      } else {
        // Simple case-insensitive search (limited by Firestore)
        query = query.where(field, isGreaterThanOrEqualTo: searchTerm)
                    .where(field, isLessThanOrEqualTo: searchTerm + '\uf8ff');
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw 'Failed to search documents: $e';
    }
  }

  // Get document count
  Future<int> getDocumentCount({
    required String collection,
    Map<String, dynamic>? whereConditions,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw 'Failed to get document count: $e';
    }
  }

  // Check if document exists
  Future<bool> documentExists({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check document existence: $e';
    }
  }

  // Transaction operations
  Future<T> runTransaction<T>(Future<T> Function(Transaction transaction) updateFunction) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      throw 'Transaction failed: $e';
    }
  }

  // Specific collection methods

  // Users collection
  Future<String> createUser(Map<String, dynamic> userData) async {
    return await createDocument(
      collection: AppConstants.usersCollection,
      data: userData,
    );
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    return await getDocument(
      collection: AppConstants.usersCollection,
      documentId: userId,
    );
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await updateDocument(
      collection: AppConstants.usersCollection,
      documentId: userId,
      data: userData,
    );
  }

  Future<void> deleteUser(String userId) async {
    await deleteDocument(
      collection: AppConstants.usersCollection,
      documentId: userId,
    );
  }

  // Cases collection
  Future<String> createCase(Map<String, dynamic> caseData) async {
    return await createDocument(
      collection: AppConstants.casesCollection,
      data: caseData,
    );
  }

  Future<Map<String, dynamic>?> getCase(String caseId) async {
    return await getDocument(
      collection: AppConstants.casesCollection,
      documentId: caseId,
    );
  }

  Future<void> updateCase(String caseId, Map<String, dynamic> caseData) async {
    await updateDocument(
      collection: AppConstants.casesCollection,
      documentId: caseId,
      data: caseData,
    );
  }

  Future<void> deleteCase(String caseId) async {
    await deleteDocument(
      collection: AppConstants.casesCollection,
      documentId: caseId,
    );
  }

  Stream<List<Map<String, dynamic>>> streamCases({String? userId}) {
    return streamCollection(
      collection: AppConstants.casesCollection,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: userId != null ? {'userId': userId} : null,
    );
  }

  // Clients collection
  Future<String> createClient(Map<String, dynamic> clientData) async {
    return await createDocument(
      collection: AppConstants.clientsCollection,
      data: clientData,
    );
  }

  Future<Map<String, dynamic>?> getClient(String clientId) async {
    return await getDocument(
      collection: AppConstants.clientsCollection,
      documentId: clientId,
    );
  }

  Future<void> updateClient(String clientId, Map<String, dynamic> clientData) async {
    await updateDocument(
      collection: AppConstants.clientsCollection,
      documentId: clientId,
      data: clientData,
    );
  }

  Future<void> deleteClient(String clientId) async {
    await deleteDocument(
      collection: AppConstants.clientsCollection,
      documentId: clientId,
    );
  }

  Stream<List<Map<String, dynamic>>> streamClients({String? userId}) {
    return streamCollection(
      collection: AppConstants.clientsCollection,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: userId != null ? {'userId': userId} : null,
    );
  }

  // Documents collection
  Future<String> createDocumentRecord(Map<String, dynamic> documentData) async {
    return await createDocument(
      collection: AppConstants.documentsCollection,
      data: documentData,
    );
  }

  Future<Map<String, dynamic>?> getDocumentRecord(String documentId) async {
    return await getDocument(
      collection: AppConstants.documentsCollection,
      documentId: documentId,
    );
  }

  Future<void> updateDocumentRecord(String documentId, Map<String, dynamic> documentData) async {
    await updateDocument(
      collection: AppConstants.documentsCollection,
      documentId: documentId,
      data: documentData,
    );
  }

  Future<void> deleteDocumentRecord(String documentId) async {
    await deleteDocument(
      collection: AppConstants.documentsCollection,
      documentId: documentId,
    );
  }

  Stream<List<Map<String, dynamic>>> streamDocuments({String? userId, String? caseId}) {
    Map<String, dynamic>? whereConditions;
    if (userId != null) {
      whereConditions = {'userId': userId};
    }
    if (caseId != null) {
      whereConditions = whereConditions ?? {};
      whereConditions['caseId'] = caseId;
    }

    return streamCollection(
      collection: AppConstants.documentsCollection,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: whereConditions,
    );
  }
}


