import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton accessor for the Supabase client.
/// ALWAYS import and use this. Never call Supabase.instance.client directly.
class SupabaseClientWrapper {
	SupabaseClientWrapper._();

	static SupabaseClient get instance => Supabase.instance.client;
}