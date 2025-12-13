import 'package:happy_pet_dashboard/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base repository with common Supabase operations
abstract class BaseRepository {
  SupabaseClient get client => SupabaseService.client;
  
  SupabaseQueryBuilder from(String table) => client.from(table);
  
  SupabaseStorageClient get storage => client.storage;
  
  /// Handle Supabase errors and throw formatted exceptions
  Never handleError(Object error, StackTrace stackTrace) {
    final exception = error is PostgrestException
        ? RepositoryException(
            'Database error: ${error.message}',
            details: error.details,
          )
        : error is StorageException
            ? RepositoryException(
                'Storage error: ${error.message}',
                details: error.statusCode,
              )
            : RepositoryException(
                'Unexpected error: $error',
                stackTrace: stackTrace,
              );
    
    throw exception;
  }
}

/// Custom repository exception
class RepositoryException implements Exception {
  final String message;
  final dynamic details;
  final StackTrace? stackTrace;

  RepositoryException(this.message, {this.details, this.stackTrace});

  @override
  String toString() {
    if (details != null) {
      return 'RepositoryException: $message\nDetails: $details';
    }
    return 'RepositoryException: $message';
  }
}
