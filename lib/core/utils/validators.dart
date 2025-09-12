class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\u0600-\u06FF\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name contains invalid characters';
    }
    
    return null;
  }
  
  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if phone number is between 7 and 15 digits
    if (cleanPhone.length < 7 || cleanPhone.length > 15) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Text length validation
  static String? validateTextLength(String? value, String fieldName, {int? minLength, int? maxLength}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }
  
  // Case title validation
  static String? validateCaseTitle(String? value) {
    return validateTextLength(value, 'Case title', minLength: 3, maxLength: 100);
  }
  
  // Case description validation
  static String? validateCaseDescription(String? value) {
    return validateTextLength(value, 'Case description', minLength: 10, maxLength: 500);
  }
  
  // Client name validation
  static String? validateClientName(String? value) {
    return validateName(value);
  }
  
  // Document name validation
  static String? validateDocumentName(String? value) {
    return validateTextLength(value, 'Document name', minLength: 3, maxLength: 100);
  }
  
  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Address must be at least 10 characters long';
    }
    
    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }
    
    return null;
  }
  
  // Date validation
  static String? validateDate(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return '$fieldName cannot be in the future';
    }
    
    return null;
  }
  
  // Future date validation
  static String? validateFutureDate(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    final now = DateTime.now();
    if (value.isBefore(now)) {
      return '$fieldName cannot be in the past';
    }
    
    return null;
  }
  
  // Number validation
  static String? validateNumber(String? value, String fieldName, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must be at most $max';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // File extension validation
  static String? validateFileExtension(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return 'File name is required';
    }
    
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }
  
  // File size validation (in bytes)
  static String? validateFileSize(int? fileSize, int maxSizeInBytes) {
    if (fileSize == null) {
      return 'File size is required';
    }
    
    if (fileSize > maxSizeInBytes) {
      final maxSizeInMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must be less than ${maxSizeInMB}MB';
    }
    
    return null;
  }
  
  // Multiple field validation
  static Map<String, String?> validateMultipleFields(Map<String, String?> fields) {
    final Map<String, String?> errors = {};
    
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;
      
      switch (fieldName) {
        case 'email':
          errors[fieldName] = validateEmail(value);
          break;
        case 'password':
          errors[fieldName] = validatePassword(value);
          break;
        case 'name':
        case 'clientName':
          errors[fieldName] = validateName(value);
          break;
        case 'phone':
          errors[fieldName] = validatePhone(value);
          break;
        case 'caseTitle':
          errors[fieldName] = validateCaseTitle(value);
          break;
        case 'caseDescription':
          errors[fieldName] = validateCaseDescription(value);
          break;
        case 'documentName':
          errors[fieldName] = validateDocumentName(value);
          break;
        case 'address':
          errors[fieldName] = validateAddress(value);
          break;
        default:
          errors[fieldName] = validateRequired(value, fieldName);
      }
    }
    
    // Remove null values
    errors.removeWhere((key, value) => value == null);
    
    return errors;
  }
  
  // Form validation helper
  static bool isFormValid(Map<String, String?> errors) {
    return errors.isEmpty;
  }
  
  // Get first error message
  static String? getFirstError(Map<String, String?> errors) {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }
  
  // Get all error messages
  static List<String> getAllErrors(Map<String, String?> errors) {
    return errors.values.where((error) => error != null).cast<String>().toList();
  }
}


