import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/client_model.dart';
import '../../data/repositories/client_repository.dart';
import 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  final ClientRepository _clientRepository;

  ClientCubit(this._clientRepository) : super(ClientInitial());

  // Create a new client
  Future<void> createClient(ClientModel clientModel) async {
    try {
      emit(ClientLoading());
      
      final clientId = await _clientRepository.createClient(clientModel);
      final createdClient = clientModel.copyWith(id: clientId);
      
      emit(ClientCreated(createdClient));
      
      // Reload clients
      await loadClients(clientModel.userId);
    } catch (e) {
      emit(ClientError('Failed to create client: $e'));
    }
  }

  // Load clients by manager
  Future<void> loadClientsByManager(String managerId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByManager(managerId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients by manager: $e'));
    }
  }

  // Load all clients for a user
  Future<void> loadClients(String userId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByUser(userId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients: $e'));
    }
  }

  // Load clients by status
  Future<void> loadClientsByStatus(String userId, ClientStatus status) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByStatus(userId, status);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients by status: $e'));
    }
  }

  // Load clients by type
  Future<void> loadClientsByType(String userId, ClientType type) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByType(userId, type);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients by type: $e'));
    }
  }

  // Load active clients
  Future<void> loadActiveClients(String userId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getActiveClients(userId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load active clients: $e'));
    }
  }

  // Load potential clients
  Future<void> loadPotentialClients(String userId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getPotentialClients(userId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load potential clients: $e'));
    }
  }

  // Load VIP clients
  Future<void> loadVipClients(String userId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getVipClients(userId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load VIP clients: $e'));
    }
  }

  // Search clients
  Future<void> searchClients(String userId, String query) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.searchClients(userId, query);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to search clients: $e'));
    }
  }

  // Load clients by city
  Future<void> loadClientsByCity(String userId, String city) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByCity(userId, city);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients by city: $e'));
    }
  }

  // Load clients by state
  Future<void> loadClientsByState(String userId, String state) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByState(userId, state);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients by state: $e'));
    }
  }

  // Load clients by country
  Future<void> loadClientsByCountry(String userId, String country) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsByCountry(userId, country);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients by country: $e'));
    }
  }

  // Update client
  Future<void> updateClient(String clientId, ClientModel clientModel) async {
    try {
      emit(ClientLoading());
      
      await _clientRepository.updateClient(clientId, clientModel);
      emit(ClientUpdated(clientModel));
      
      // Reload clients
      await loadClients(clientModel.userId);
    } catch (e) {
      emit(ClientError('Failed to update client: $e'));
    }
  }

  // Delete client
  Future<void> deleteClient(String clientId, String userId) async {
    try {
      emit(ClientLoading());
      
      await _clientRepository.deleteClient(clientId);
      emit(ClientDeleted(clientId));
      
      // Reload clients
      await loadClients(userId);
    } catch (e) {
      emit(ClientError('Failed to delete client: $e'));
    }
  }

  // Update client status
  Future<void> updateClientStatus(String clientId, ClientStatus status) async {
    try {
      emit(ClientLoading());
      
      await _clientRepository.updateClientStatus(clientId, status);
      
      // Get updated client
      final updatedClient = await _clientRepository.getClient(clientId);
      if (updatedClient != null) {
        emit(ClientStatusUpdated(updatedClient));
        
        // Reload clients
        await loadClients(updatedClient.userId);
      }
    } catch (e) {
      emit(ClientError('Failed to update client status: $e'));
    }
  }

  // Toggle VIP status
  Future<void> toggleVipStatus(String clientId) async {
    try {
      emit(ClientLoading());
      
      await _clientRepository.toggleVipStatus(clientId);
      
      // Get updated client
      final updatedClient = await _clientRepository.getClient(clientId);
      if (updatedClient != null) {
        emit(ClientVipStatusToggled(updatedClient));
        
        // Reload clients
        await loadClients(updatedClient.userId);
      }
    } catch (e) {
      emit(ClientError('Failed to toggle VIP status: $e'));
    }
  }

  // Add case to client
  Future<void> addCaseToClient(String clientId, String caseId) async {
    try {
      emit(ClientLoading());
      
      await _clientRepository.addCaseToClient(clientId, caseId);
      
      // Get updated client
      final updatedClient = await _clientRepository.getClient(clientId);
      if (updatedClient != null) {
        emit(ClientCaseAdded(updatedClient));
        
        // Reload clients
        await loadClients(updatedClient.userId);
      }
    } catch (e) {
      emit(ClientError('Failed to add case to client: $e'));
    }
  }

  // Remove case from client
  Future<void> removeCaseFromClient(String clientId, String caseId) async {
    try {
      emit(ClientLoading());
      
      await _clientRepository.removeCaseFromClient(clientId, caseId);
      
      // Get updated client
      final updatedClient = await _clientRepository.getClient(clientId);
      if (updatedClient != null) {
        emit(ClientCaseRemoved(updatedClient));
        
        // Reload clients
        await loadClients(updatedClient.userId);
      }
    } catch (e) {
      emit(ClientError('Failed to remove case from client: $e'));
    }
  }

  // Load client statistics by manager
  Future<void> loadClientStatisticsByManager(String managerId) async {
    try {
      final statistics = await _clientRepository.getClientStatisticsByManager(managerId);
      emit(ClientStatisticsLoaded(statistics));
    } catch (e) {
      emit(ClientError('Failed to load client statistics by manager: $e'));
    }
  }

  // Load client statistics
  Future<void> loadClientStatistics(String userId) async {
    try {
      final statistics = await _clientRepository.getClientStatistics(userId);
      emit(ClientStatisticsLoaded(statistics));
    } catch (e) {
      emit(ClientError('Failed to load client statistics: $e'));
    }
  }

  // Load all cities
  Future<void> loadAllCities(String userId) async {
    try {
      final cities = await _clientRepository.getAllCities(userId);
      emit(ClientCitiesLoaded(cities));
    } catch (e) {
      emit(ClientError('Failed to load cities: $e'));
    }
  }

  // Load all states
  Future<void> loadAllStates(String userId) async {
    try {
      final states = await _clientRepository.getAllStates(userId);
      emit(ClientStatesLoaded(states));
    } catch (e) {
      emit(ClientError('Failed to load states: $e'));
    }
  }

  // Load all countries
  Future<void> loadAllCountries(String userId) async {
    try {
      final countries = await _clientRepository.getAllCountries(userId);
      emit(ClientCountriesLoaded(countries));
    } catch (e) {
      emit(ClientError('Failed to load countries: $e'));
    }
  }

  // Load recent clients
  Future<void> loadRecentClients(String userId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getRecentClients(userId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load recent clients: $e'));
    }
  }

  // Load clients with most cases
  Future<void> loadClientsWithMostCases(String userId, {int limit = 10}) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsWithMostCases(userId, limit: limit);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients with most cases: $e'));
    }
  }

  // Load clients without cases
  Future<void> loadClientsWithoutCases(String userId) async {
    try {
      emit(ClientLoading());
      
      final clients = await _clientRepository.getClientsWithoutCases(userId);
      emit(ClientLoaded(clients));
    } catch (e) {
      emit(ClientError('Failed to load clients without cases: $e'));
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email, {String? excludeClientId}) async {
    try {
      return await _clientRepository.emailExists(email, excludeClientId: excludeClientId);
    } catch (e) {
      emit(ClientError('Failed to check email existence: $e'));
      return false;
    }
  }

  // Get client by email
  Future<ClientModel?> getClientByEmail(String email) async {
    try {
      return await _clientRepository.getClientByEmail(email);
    } catch (e) {
      emit(ClientError('Failed to get client by email: $e'));
      return null;
    }
  }

  // Get current clients
  List<ClientModel> get currentClients {
    final currentState = state;
    if (currentState is ClientLoaded) {
      return currentState.clients;
    }
    return [];
  }

  // Get current statistics
  Map<String, int> get currentStatistics {
    final currentState = state;
    if (currentState is ClientStatisticsLoaded) {
      return currentState.statistics;
    }
    return {};
  }

  // Get current cities
  List<String> get currentCities {
    final currentState = state;
    if (currentState is ClientCitiesLoaded) {
      return currentState.cities;
    }
    return [];
  }

  // Get current states
  List<String> get currentStates {
    final currentState = state;
    if (currentState is ClientStatesLoaded) {
      return currentState.states;
    }
    return [];
  }

  // Get current countries
  List<String> get currentCountries {
    final currentState = state;
    if (currentState is ClientCountriesLoaded) {
      return currentState.countries;
    }
    return [];
  }

  // Check if loading
  bool get isLoading {
    return state is ClientLoading;
  }

  // Get error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is ClientError) {
      return currentState.message;
    }
    return null;
  }

  // Clear error
  void clearError() {
    if (state is ClientError) {
      emit(ClientInitial());
    }
  }

  // Refresh clients
  Future<void> refreshClients(String userId) async {
    await loadClients(userId);
  }
}



