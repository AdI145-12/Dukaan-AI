import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';

part 'shared_providers.g.dart';

/// Provides the Supabase client. Used by all repository providers.
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return SupabaseClientWrapper.instance;
}

/// Streams Supabase auth state changes.
/// Used by GoRouter's redirect to protect routes.
@riverpod
Stream<AuthState> authState(Ref ref) {
  return SupabaseClientWrapper.instance.auth.onAuthStateChange;
}