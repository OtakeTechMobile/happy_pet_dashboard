import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    try {
      // Load environment variables
      await dotenv.load(fileName: '.env');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        log('Warning: Supabase credentials not found in .env file');
        log('Please create a .env file from .env.example with your Supabase credentials');
        return;
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      log('Supabase initialized successfully');
    } catch (e) {
      log('Error initializing Supabase: $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static SupabaseQueryBuilder from(String table) => client.from(table);
  
  static SupabaseStorageClient get storage => client.storage;
  
  static GoTrueClient get auth => client.auth;
}
