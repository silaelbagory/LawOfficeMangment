import 'package:equatable/equatable.dart';

import '../../data/models/case_model.dart';

abstract class CaseState extends Equatable {
  const CaseState();

  @override
  List<Object?> get props => [];
}

class CaseInitial extends CaseState {}

class CaseLoading extends CaseState {}

class CaseLoaded extends CaseState {
  final List<CaseModel> cases;

  const CaseLoaded(this.cases);

  @override
  List<Object?> get props => [cases];
}

class CaseError extends CaseState {
  final String message;

  const CaseError(this.message);

  @override
  List<Object?> get props => [message];
}

class CaseCreated extends CaseState {
  final CaseModel caseModel;

  const CaseCreated(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseUpdated extends CaseState {
  final CaseModel caseModel;

  const CaseUpdated(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseDeleted extends CaseState {
  final String caseId;

  const CaseDeleted(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class CaseStatusUpdated extends CaseState {
  final CaseModel caseModel;

  const CaseStatusUpdated(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CasePriorityUpdated extends CaseState {
  final CaseModel caseModel;

  const CasePriorityUpdated(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseTagAdded extends CaseState {
  final CaseModel caseModel;

  const CaseTagAdded(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseTagRemoved extends CaseState {
  final CaseModel caseModel;

  const CaseTagRemoved(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseDocumentAdded extends CaseState {
  final CaseModel caseModel;

  const CaseDocumentAdded(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseDocumentRemoved extends CaseState {
  final CaseModel caseModel;

  const CaseDocumentRemoved(this.caseModel);

  @override
  List<Object?> get props => [caseModel];
}

class CaseStatisticsLoaded extends CaseState {
  final Map<String, int> statistics;

  const CaseStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class CaseTagsLoaded extends CaseState {
  final List<String> tags;

  const CaseTagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}



