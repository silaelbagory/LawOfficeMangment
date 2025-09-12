import '../../data/models/lawyer_action_model.dart';

abstract class ActionState {}

class ActionInitial extends ActionState {}

class ActionLoading extends ActionState {}

class ActionsLoaded extends ActionState {
  final List<LawyerActionModel> actions;

  ActionsLoaded(this.actions);
}

class ActionLogged extends ActionState {
  final String actionId;

  ActionLogged(this.actionId);
}

class ActionStatisticsLoaded extends ActionState {
  final Map<String, int> statistics;

  ActionStatisticsLoaded(this.statistics);
}

class ActionError extends ActionState {
  final String message;

  ActionError(this.message);
}
