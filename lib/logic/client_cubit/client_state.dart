import 'package:equatable/equatable.dart';

import '../../data/models/client_model.dart';

abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final List<ClientModel> clients;

  const ClientLoaded(this.clients);

  @override
  List<Object?> get props => [clients];
}

class ClientError extends ClientState {
  final String message;

  const ClientError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientCreated extends ClientState {
  final ClientModel client;

  const ClientCreated(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientUpdated extends ClientState {
  final ClientModel client;

  const ClientUpdated(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientDeleted extends ClientState {
  final String clientId;

  const ClientDeleted(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

class ClientStatusUpdated extends ClientState {
  final ClientModel client;

  const ClientStatusUpdated(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientVipStatusToggled extends ClientState {
  final ClientModel client;

  const ClientVipStatusToggled(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientCaseAdded extends ClientState {
  final ClientModel client;

  const ClientCaseAdded(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientCaseRemoved extends ClientState {
  final ClientModel client;

  const ClientCaseRemoved(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientStatisticsLoaded extends ClientState {
  final Map<String, int> statistics;

  const ClientStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class ClientCitiesLoaded extends ClientState {
  final List<String> cities;

  const ClientCitiesLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

class ClientStatesLoaded extends ClientState {
  final List<String> states;

  const ClientStatesLoaded(this.states);

  @override
  List<Object?> get props => [states];
}

class ClientCountriesLoaded extends ClientState {
  final List<String> countries;

  const ClientCountriesLoaded(this.countries);

  @override
  List<Object?> get props => [countries];
}



