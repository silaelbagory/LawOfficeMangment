import '../../core/services/firestore_service.dart';
import '../models/client_model.dart';

class ClientRepository {
  final FirestoreService _firestoreService;

  ClientRepository(this._firestoreService);

  // Create a new client
  Future<String> createClient(ClientModel clientModel) async {
    try {
      final clientData = clientModel.toMap();
      return await _firestoreService.createClient(clientData);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  // Get client by ID
  Future<ClientModel?> getClient(String clientId) async {
    try {
      final clientData = await _firestoreService.getClient(clientId);
      if (clientData != null) {
        return ClientModel.fromMap(clientData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get client: $e');
    }
  }

  // Update client
  Future<void> updateClient(String clientId, ClientModel clientModel) async {
    try {
      final clientData = clientModel.toMap();
      await _firestoreService.updateClient(clientId, clientData);
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  // Delete client
  Future<void> deleteClient(String clientId) async {
    try {
      await _firestoreService.deleteClient(clientId);
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  // Get clients by manager
  Future<List<ClientModel>> getClientsByManager(String managerId) async {
    try {
      final documents = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {'managerId': managerId},
      );
      
      return documents.map((doc) => ClientModel.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get clients by manager: $e');
    }
  }

  // Get all clients for a user
  Future<List<ClientModel>> getClientsByUser(String userId) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {'userId': userId},
        orderBy: 'createdAt',
        descending: true,
      );

      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get clients: $e');
    }
  }

  // Get clients by status
  Future<List<ClientModel>> getClientsByStatus(String userId, ClientStatus status) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {
          'userId': userId,
          'status': status.name,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get clients by status: $e');
    }
  }

  // Get clients by type
  Future<List<ClientModel>> getClientsByType(String userId, ClientType type) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {
          'userId': userId,
          'type': type.name,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get clients by type: $e');
    }
  }

  // Get active clients
  Future<List<ClientModel>> getActiveClients(String userId) async {
    return await getClientsByStatus(userId, ClientStatus.active);
  }

  // Get potential clients
  Future<List<ClientModel>> getPotentialClients(String userId) async {
    return await getClientsByStatus(userId, ClientStatus.potential);
  }

  // Get VIP clients
  Future<List<ClientModel>> getVipClients(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      return allClients.where((client) => client.isVip).toList();
    } catch (e) {
      throw Exception('Failed to get VIP clients: $e');
    }
  }

  // Search clients
  Future<List<ClientModel>> searchClients(String userId, String query) async {
    try {
      final allClients = await getClientsByUser(userId);
      
      return allClients.where((client) {
        return client.name.toLowerCase().contains(query.toLowerCase()) ||
               client.email.toLowerCase().contains(query.toLowerCase()) ||
               client.companyName?.toLowerCase().contains(query.toLowerCase()) == true ||
               client.phoneNumber?.contains(query) == true ||
               client.address?.toLowerCase().contains(query.toLowerCase()) == true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search clients: $e');
    }
  }

  // Get clients by city
  Future<List<ClientModel>> getClientsByCity(String userId, String city) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {
          'userId': userId,
          'city': city,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get clients by city: $e');
    }
  }

  // Get clients by state
  Future<List<ClientModel>> getClientsByState(String userId, String state) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {
          'userId': userId,
          'state': state,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get clients by state: $e');
    }
  }

  // Get clients by country
  Future<List<ClientModel>> getClientsByCountry(String userId, String country) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {
          'userId': userId,
          'country': country,
        },
        orderBy: 'createdAt',
        descending: true,
      );

      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get clients by country: $e');
    }
  }

  // Update client status
  Future<void> updateClientStatus(String clientId, ClientStatus status) async {
    try {
      final clientModel = await getClient(clientId);
      if (clientModel != null) {
        final updatedClient = clientModel.updateStatus(status);
        await updateClient(clientId, updatedClient);
      }
    } catch (e) {
      throw Exception('Failed to update client status: $e');
    }
  }

  // Toggle VIP status
  Future<void> toggleVipStatus(String clientId) async {
    try {
      final clientModel = await getClient(clientId);
      if (clientModel != null) {
        final updatedClient = clientModel.toggleVipStatus();
        await updateClient(clientId, updatedClient);
      }
    } catch (e) {
      throw Exception('Failed to toggle VIP status: $e');
    }
  }

  // Add case to client
  Future<void> addCaseToClient(String clientId, String caseId) async {
    try {
      final clientModel = await getClient(clientId);
      if (clientModel != null) {
        final updatedClient = clientModel.addCase(caseId);
        await updateClient(clientId, updatedClient);
      }
    } catch (e) {
      throw Exception('Failed to add case to client: $e');
    }
  }

  // Remove case from client
  Future<void> removeCaseFromClient(String clientId, String caseId) async {
    try {
      final clientModel = await getClient(clientId);
      if (clientModel != null) {
        final updatedClient = clientModel.removeCase(caseId);
        await updateClient(clientId, updatedClient);
      }
    } catch (e) {
      throw Exception('Failed to remove case from client: $e');
    }
  }

  // Get client statistics by manager
  Future<Map<String, int>> getClientStatisticsByManager(String managerId) async {
    try {
      final clients = await getClientsByManager(managerId);
      
      final totalClients = clients.length;
      final activeClients = clients.where((c) => c.status == ClientStatus.active).length;
      final inactiveClients = clients.where((c) => c.status == ClientStatus.inactive).length;
      final vipClients = clients.where((c) => c.isVip).length;
      
      return {
        'totalClients': totalClients,
        'activeClients': activeClients,
        'inactiveClients': inactiveClients,
        'vipClients': vipClients,
      };
    } catch (e) {
      throw Exception('Failed to get client statistics by manager: $e');
    }
  }

  // Get client statistics
  Future<Map<String, int>> getClientStatistics(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      
      final stats = <String, int>{
        'total': allClients.length,
        'active': 0,
        'inactive': 0,
        'potential': 0,
        'former': 0,
        'individual': 0,
        'company': 0,
        'organization': 0,
        'vip': 0,
        'withCases': 0,
        'withoutCases': 0,
      };
      
      for (final client in allClients) {
        // Count by status
        switch (client.status) {
          case ClientStatus.active:
            stats['active'] = stats['active']! + 1;
            break;
          case ClientStatus.inactive:
            stats['inactive'] = stats['inactive']! + 1;
            break;
          case ClientStatus.potential:
            stats['potential'] = stats['potential']! + 1;
            break;
          case ClientStatus.former:
            stats['former'] = stats['former']! + 1;
            break;
        }
        
        // Count by type
        switch (client.type) {
          case ClientType.individual:
            stats['individual'] = stats['individual']! + 1;
            break;
          case ClientType.company:
            stats['company'] = stats['company']! + 1;
            break;
          case ClientType.organization:
            stats['organization'] = stats['organization']! + 1;
            break;
        }
        
        // Count VIP clients
        if (client.isVip) {
          stats['vip'] = stats['vip']! + 1;
        }
        
        // Count clients with/without cases
        if (client.hasCases) {
          stats['withCases'] = stats['withCases']! + 1;
        } else {
          stats['withoutCases'] = stats['withoutCases']! + 1;
        }
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get client statistics: $e');
    }
  }

  // Get all unique cities
  Future<List<String>> getAllCities(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      final Set<String> uniqueCities = {};
      
      for (final client in allClients) {
        if (client.city != null && client.city!.isNotEmpty) {
          uniqueCities.add(client.city!);
        }
      }
      
      return uniqueCities.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get cities: $e');
    }
  }

  // Get all unique states
  Future<List<String>> getAllStates(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      final Set<String> uniqueStates = {};
      
      for (final client in allClients) {
        if (client.state != null && client.state!.isNotEmpty) {
          uniqueStates.add(client.state!);
        }
      }
      
      return uniqueStates.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get states: $e');
    }
  }

  // Get all unique countries
  Future<List<String>> getAllCountries(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      final Set<String> uniqueCountries = {};
      
      for (final client in allClients) {
        if (client.country != null && client.country!.isNotEmpty) {
          uniqueCountries.add(client.country!);
        }
      }
      
      return uniqueCountries.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get countries: $e');
    }
  }

  // Stream clients for real-time updates
  Stream<List<ClientModel>> streamClients(String userId) {
    return _firestoreService.streamClients(userId: userId).map((clientsData) {
      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    });
  }

  // Stream clients by status
  Stream<List<ClientModel>> streamClientsByStatus(String userId, ClientStatus status) {
    return _firestoreService.streamCollection(
      collection: 'clients',
      whereConditions: {
        'userId': userId,
        'status': status.name,
      },
      orderBy: 'createdAt',
      descending: true,
    ).map((clientsData) {
      return clientsData.map((data) => ClientModel.fromMap(data)).toList();
    });
  }

  // Get recent clients (last 30 days)
  Future<List<ClientModel>> getRecentClients(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      return allClients.where((client) {
        return client.createdAt.isAfter(thirtyDaysAgo);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent clients: $e');
    }
  }

  // Get client count by status
  Future<Map<ClientStatus, int>> getClientCountByStatus(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      final counts = <ClientStatus, int>{
        ClientStatus.active: 0,
        ClientStatus.inactive: 0,
        ClientStatus.potential: 0,
        ClientStatus.former: 0,
      };
      
      for (final client in allClients) {
        counts[client.status] = counts[client.status]! + 1;
      }
      
      return counts;
    } catch (e) {
      throw Exception('Failed to get client count by status: $e');
    }
  }

  // Get client count by type
  Future<Map<ClientType, int>> getClientCountByType(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      final counts = <ClientType, int>{
        ClientType.individual: 0,
        ClientType.company: 0,
        ClientType.organization: 0,
      };
      
      for (final client in allClients) {
        counts[client.type] = counts[client.type]! + 1;
      }
      
      return counts;
    } catch (e) {
      throw Exception('Failed to get client count by type: $e');
    }
  }

  // Get clients with most cases
  Future<List<ClientModel>> getClientsWithMostCases(String userId, {int limit = 10}) async {
    try {
      final allClients = await getClientsByUser(userId);
      allClients.sort((a, b) => b.caseCount.compareTo(a.caseCount));
      return allClients.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get clients with most cases: $e');
    }
  }

  // Get clients without cases
  Future<List<ClientModel>> getClientsWithoutCases(String userId) async {
    try {
      final allClients = await getClientsByUser(userId);
      return allClients.where((client) => !client.hasCases).toList();
    } catch (e) {
      throw Exception('Failed to get clients without cases: $e');
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email, {String? excludeClientId}) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {'email': email},
      );

      if (excludeClientId != null) {
        return clientsData.any((data) => data['id'] != excludeClientId);
      }
      
      return clientsData.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email existence: $e');
    }
  }

  // Get client by email
  Future<ClientModel?> getClientByEmail(String email) async {
    try {
      final clientsData = await _firestoreService.getCollection(
        collection: 'clients',
        whereConditions: {'email': email},
      );

      if (clientsData.isNotEmpty) {
        return ClientModel.fromMap(clientsData.first);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get client by email: $e');
    }
  }
}



