import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/case_cubit/case_cubit.dart';
import '../../../logic/case_cubit/case_state.dart';
import '../../../logic/document_cubit/document_cubit.dart';
import '../../../logic/document_cubit/document_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // For web compatibility:
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  File? _selectedFile; // For mobile/desktop only
  DocumentType _selectedType = DocumentType.other;
  DocumentStatus _selectedStatus = DocumentStatus.pending;
  DateTime? _expiryDate;
  List<String> _tags = [];
  final _tagController = TextEditingController();
  bool _isPublic = false;
  bool _isEncrypted = false;
  String? _selectedCaseId;
  List<CaseModel> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        // Removed the upload IconButton from actions
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DocumentCubit, DocumentState>(
            listener: (context, state) {
              if (state is DocumentUploaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document uploaded successfully')),
                );
                Navigator.pushNamed(context,'/documents');
              } else if (state is DocumentUploadError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
          ),
          BlocListener<CaseCubit, dynamic>(
            listener: (context, state) {
              if (state is CaseLoaded) {
                setState(() {
                  _cases = state.cases;
                });
              }
            },
          ),
        ],
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFileSelectionSection(theme),
                  SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                  _buildDocumentInfoSection(theme),
                  SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                  _buildDocumentSettingsSection(theme),
                  SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                  _buildTagsSection(theme),
                  SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelectionSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select File',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (_selectedFileBytes == null && _selectedFile == null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: InkWell(
                  onTap: _selectFile,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Tap to select a file',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Supported formats: PDF, DOC, DOCX, TXT, JPG, PNG, etc.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getFileIcon(_selectedFileName ?? ''),
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFileName ?? '',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFile != null
                                    ? _getFileSize(_selectedFile!)
                                    : _selectedFileBytes != null
                                        ? '${(_selectedFileBytes!.length / 1024).toStringAsFixed(1)} KB'
                                        : '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                              _selectedFileBytes = null;
                              _selectedFileName = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: OutlineButton(
                            text: 'Change File',
                            onPressed: _selectFile,
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Upload',
                            onPressed: _uploadDocument,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Document Name',
              hint: 'Enter document name',
              controller: _nameController,
              validator: Validators.validateDocumentName,
              isRequired: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            MultilineTextField(
              label: 'Description',
              hint: 'Enter document description',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            DropdownButtonFormField<String?>(
              value: _selectedCaseId,
              decoration: const InputDecoration(
                labelText: 'Case (Optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Select a case (optional)'),
                ),
                ..._cases.map((caseModel) => DropdownMenuItem<String?>(
                  value: caseModel.id,
                  child: Text(caseModel.title),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCaseId = value;
                });
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DocumentType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Document Type',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayText),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value ?? DocumentType.other;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: DropdownButtonFormField<DocumentStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayText),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? DocumentStatus.pending;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            InkWell(
              onTap: () => _selectExpiryDate(),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (Optional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'Select expiry date',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSettingsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SwitchListTile(
              title: const Text('Public Document'),
              subtitle: const Text('Make this document accessible to others'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Encrypted Document'),
              subtitle: const Text('Encrypt this document for security'),
              value: _isEncrypted,
              onChanged: (value) {
                setState(() {
                  _isEncrypted = value;
                });
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            MultilineTextField(
              label: 'Notes',
              hint: 'Enter any additional notes',
              controller: _notesController,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Add Tag',
                    hint: 'Enter a tag',
                    controller: _tagController,
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Wrap(
                spacing: AppConstants.smallPadding,
                runSpacing: AppConstants.smallPadding,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeTag(tag),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlineButton(
                text: 'Cancel',
                onPressed: state is DocumentUploading ? null : () =>Navigator.pushNamed(context,'/documents'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: PrimaryButton(
                text: 'Upload Document',
                onPressed: state is DocumentUploading ? null : _uploadDocument,
                isLoading: state is DocumentUploading,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      withData: true, // مهم عشان الويب
      allowedExtensions: StorageService().getAllowedDocumentExtensions(),
      type: FileType.custom,
      dialogTitle: 'Select Document',
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.single;

      setState(() {
        _selectedFileName = pickedFile.name;

        if (pickedFile.bytes != null) {
          // Web أو أي منصة ترجّع bytes
          _selectedFileBytes = pickedFile.bytes;
          _selectedFile = null;
        } else if (pickedFile.path != null) {
          // Mobile/Desktop
          _selectedFile = File(pickedFile.path!);
          _selectedFileBytes = null;
        } else {
          // لا bytes ولا path → خطأ
          _selectedFile = null;
          _selectedFileBytes = null;
          _selectedFileName = null;
        }
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select file: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}


  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _addTag([String? tag]) {
    final tagText = tag ?? _tagController.text.trim();
    if (tagText.isNotEmpty && !_tags.contains(tagText)) {
      setState(() {
        _tags.add(tagText);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  void _uploadDocument() async {
    if ((_selectedFileBytes == null && _selectedFile == null) || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        final documentName = _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : _selectedFileName!;
        try {
          // Upload the document (web: bytes, mobile: File)
          await context.read<DocumentCubit>().uploadDocumentFile(
            file: _selectedFile, // null on web
            fileBytes: _selectedFileBytes, // null on mobile
            fileName: _selectedFileName!,
            userId: user.id,
            managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
            caseId: _selectedCaseId,
            name: documentName,
            description: _descriptionController.text.trim(),
            type: _selectedType,
            tags: _tags,
          );
          if (!mounted) return;
          await context.read<ActionCubit>().logDocumentUpload(
            lawyerId: user.id,
            lawyerName: user.name,
            managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
            documentName: documentName,
            documentId: null,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    }
  }

  void _loadCases() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.role == UserRole.manager) {
        context.read<CaseCubit>().loadCasesByManager(user.id);
      } else {
        context.read<CaseCubit>().loadCases(user.id);
      }
    }
  }
}
