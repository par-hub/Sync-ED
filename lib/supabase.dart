import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://axdsnimuwwrvazvmlzle.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4ZHNuaW11d3dydmF6dm1semxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MjQ5OTMsImV4cCI6MjA1OTEwMDk5M30.CxPamCAm4K5socN8g1c9DAQj9qfDvhOEDd206wa2A20';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  //runApp(MyApp());
}

class SupabaseService {

    static DateTime getCustomTimestamp({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    }) {
    final now = DateTime.now();
    return DateTime(
      year ?? now.year,
      month ?? now.month,
      day ?? now.day,
      hour ?? now.hour,
      minute ?? now.minute,
    );
  }
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  // Current user ID getter
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Get Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;


  // Authentication methods
  Future<AuthResponse?> signUp({
    required String email,
    required String display,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final userData = {
          'user_id': response.user!.id,
          'display_name': display,
        };

        await _supabase.from('Users').insert(userData);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Check if user exists in database
      if (response.user != null) {
        final users = await getData('Users');
        final userExists = users.any((user) => user['user_id'] == response.user!.id);
        
        // If user doesn't exist in Users table, create entry
        if (!userExists) {
          await _supabase.auth.signOut();
          throw Exception('User not found. Please register first.');
        }
      }
      
      return response;
    } on AuthException catch (error) {
      if (error.statusCode == 400) {
        throw Exception('Invalid email or password');
      } else if (error.statusCode == 401) {
        throw Exception('Not authorized');
      } else {
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  Future<void> signInWithGitHub() async {
    // try {
    //   final response = await _supabase.auth.signInWithOAuth(
    //     Provider.github,
    //     redirectTo: 'io.supabase.sync-ed://login-callback',
    //     scopes: 'read:user user:email',
    //   );

    //   // Only try to create user entry if sign in was successful
    //   if (response.session != null) {
    //     final user = response.user;
    //     if (user != null) {
    //       final users = await getData('Users');
    //       final userExists = users.any((u) => u['user_id'] == user.id);

    //       if (!userExists) {
    //         final userData = {
    //           'user_id': user.id,
    //           'email': user.email,
    //           'display_name': user.userMetadata?['name'] ?? user.email?.split('@')[0],
    //         };
    //         await _supabase.from('Users').insert(userData);
    //       }
    //     }
    //   }
      
    //   return response;
    // } catch (e) {
    //   throw Exception('GitHub sign in failed: $e');
    // }
  }

  // Future<bool?> signInWithLinkedin() async {
  //   try {
  //     final response = await _supabase.auth.signInWithOAuth(
  //       Provider.linkedin,  
  //       redirectTo: Uri.parse('https://axdsnimuwwrvazvmlzle.supabase.co/auth/v1/callback').toString(),
  //       scopes: 'r_liteprofile r_emailaddress',  // Updated LinkedIn specific scopes
  //     );
  //     if (response) {
  //       final user = _supabase.auth.currentUser;
  //       if (user != null) {
  //         final userData = {
  //           'user_id': user.id,
  //           'email': user.email,
  //           'display_name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0],
  //         };
  //         await _supabase.from('Users').insert(userData);
  //       }
  //     }

      
  //     return response;
  //   } catch (e) {
  //     throw Exception('LinkedIn sign in failed: $e');  // Updated error message
  //   }
  // }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getData(String tableName) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select();
      
      if (response == null) {
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  
  Future<String> sendMessage({
    required String message,
    String? postId,

  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      
      final messageData = {
        'message': message,
        'user_id': currentUserId,
        'post_id': postId,
      };
      
      final response = await _supabase
          .from('Messages')
          .insert(messageData)
          .select()
          .single();
          
      return response['message_id'] as String;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudyPlannerNotes() async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      
      final response = await _supabase
          .from('Study_planner_notes')
          .select()
          .eq('user_id', currentUserId)
          .order('created_at');
      
      if (response == null) {
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching study planner notes: $e');
      throw Exception('Failed to load study notes');
    }
  }


  Future<Map<String, dynamic>> addToStudyPlanner({
    required String title,
    String? notes,
    DateTime? date,
    required int id
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      
      final planData = {
        'title': title,
        'notes': notes,
        'user_Id': currentUserId,
        'id':id,
        'date': date?.toIso8601String(),
      };
      
      final response = await _supabase
          .from('Study_planner_notes')
          .insert(planData)
          .select()
          .single();
          
      return response['message_id'];
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<String> sendAiMessage({
    required String message,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      
      final messageData = {
        'text': message,
        'user_id': currentUserId,
      };
      
      final response = await _supabase
          .from('AIChat')
          .insert(messageData)
          .select()
          .single();
          
      return response['message_id'] as String;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<Map<String, dynamic>> insertData(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  //Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      final response = await _supabase
          .from('Users')
          .update(data)
          .eq('user_id', currentUserId);
      if (response.error != null) {
        throw Exception('Error updating user profile: ${response.error!.message}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Helper method to upload pdf notes
  Future<String> uploadNote({
    required String title,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
    String? data,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      final storage = _supabase.storage.from('pdfnotes');
      
      await storage.uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          contentType: contentType ?? 'application/pdf',
          upsert: true,
        ),
      );

      final String publicUrl = storage.getPublicUrl(path);
      final noteData = {
        'title': title,
        'data': data,
        'note': publicUrl,
        'user_id': currentUserId,
      };
      await _supabase.from('Posts').insert(noteData);
      return publicUrl;
    } on StorageException catch (e) {
      throw Exception('Storage error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading note: $e');
    }
  }

  // Helper method to upload profile picture
  Future<String> uploadImage({
    required String display,
    required String path,
    required Uint8List fileBytes,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User is not authenticated');
      }
      final storage = _supabase.storage.from('avatars');
      
      await storage.uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(
          contentType: 'image/*', 
          upsert: true,
        ),
      );

      final String publicUrl = storage.getPublicUrl(path);
      final userData = {
        'display_name': display,
        'pfp': publicUrl,
      };
      await updateUserProfile(userData);
      return publicUrl;
    } on StorageException catch (e) {
      throw Exception('Storage error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading image: $e'); 
    }
  }
  Future<List<Map<String, dynamic>>> getMessages() async {
  try {
    final response = await _supabase
        .from('Messages')
        .select()
        .order('created_at');
    
    if (response == null) {
      return [];
    }
    
    return List<Map<String, dynamic>>.from(response as List);
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
  }
}

