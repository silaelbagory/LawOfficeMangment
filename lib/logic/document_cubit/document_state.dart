import 'package:equatable/equatable.dart';

import '../../data/models/document_model.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<DocumentModel> documents;

  const DocumentLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentCreated extends DocumentState {
  final DocumentModel document;

  const DocumentCreated(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUpdated extends DocumentState {
  final DocumentModel document;

  const DocumentUpdated(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentDeleted extends DocumentState {
  final String documentId;

  const DocumentDeleted(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class DocumentStatusUpdated extends DocumentState {
  final DocumentModel document;

  const DocumentStatusUpdated(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentTagAdded extends DocumentState {
  final DocumentModel document;

  const DocumentTagAdded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentTagRemoved extends DocumentState {
  final DocumentModel document;

  const DocumentTagRemoved(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentShared extends DocumentState {
  final DocumentModel document;

  const DocumentShared(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUnshared extends DocumentState {
  final DocumentModel document;

  const DocumentUnshared(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentDownloadCountIncremented extends DocumentState {
  final DocumentModel document;

  const DocumentDownloadCountIncremented(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentStatisticsLoaded extends DocumentState {
  final Map<String, int> statistics;

  const DocumentStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class DocumentTagsLoaded extends DocumentState {
  final List<String> tags;

  const DocumentTagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class DocumentUploading extends DocumentState {
  final double progress;

  const DocumentUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DocumentUploaded extends DocumentState {
  final DocumentModel document;

  const DocumentUploaded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUploadError extends DocumentState {
  final String message;

  const DocumentUploadError(this.message);

  @override
  List<Object?> get props => [message];
}



