import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/openai_service.dart';
import '../services/auth_service.dart';
import '../models/theory_model.dart';

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

final publicTheoriesProvider = FutureProvider<List<TheoryModel>>((ref) async {
  final data = await SupabaseService.getTheories();
  return data.map((e) => TheoryModel.fromJson(e)).toList();
});

final trendingTheoriesProvider = FutureProvider<List<TheoryModel>>((ref) async {
  final data = await SupabaseService.getTheories(limit: 20);
  final sorted = data
    ..sort((a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0));
  return sorted.map((e) => TheoryModel.fromJson(e)).toList();
});

final userTheoriesProvider = FutureProvider<List<TheoryModel>>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) return [];

  final data = await SupabaseService.getUserTheories();
  return data.map((e) => TheoryModel.fromJson(e)).toList();
});

final theoryByIdProvider =
    FutureProvider.family<TheoryModel?, String>((ref, id) async {
  final client = Supabase.instance.client;
  final data =
      await client.from('theories').select().eq('id', id).maybeSingle();
  if (data == null) return null;
  return TheoryModel.fromJson(data);
});

class TheoryGeneratorNotifier extends StateNotifier<AsyncValue<String?>> {
  final OpenAIService _openAIService;
  final AuthService _authService;

  TheoryGeneratorNotifier(
    this._openAIService,
    this._authService,
  ) : super(const AsyncValue.data(null));

  Future<void> generateTheory({
    required String input,
    required String bias,
  }) async {
    state = const AsyncValue.loading();

    try {
      final theory = await _openAIService.generateTheory(
        userInput: input,
        bias: bias,
      );

      state = AsyncValue.data(theory);

      // Save to Supabase if user is logged in
      final user = _authService.currentUser;
      if (user != null) {
        await SupabaseService.createTheory(
          title: input.length > 50 ? '${input.substring(0, 50)}...' : input,
          content: theory,
          prompt: input,
          tags: [bias],
        );
        await _authService.incrementTheoriesGenerated(user.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final theoryGeneratorProvider =
    StateNotifierProvider<TheoryGeneratorNotifier, AsyncValue<String?>>((ref) {
  final openAIService = ref.watch(openAIServiceProvider);
  final authService = AuthService();

  return TheoryGeneratorNotifier(openAIService, authService);
});

// Daily message provider
final dailyMessageProvider =
    FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
  final openAIService = ref.watch(openAIServiceProvider);

  return await openAIService.generateDailyMessage(
    bias: params['bias'] as String,
    daysUntilRelease: params['daysUntilRelease'] as int,
  );
});
