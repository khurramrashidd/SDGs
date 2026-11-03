import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the Ibtidaa AI proxy on Render.
///
/// NOTE FOR ANY FUTURE CONTRIBUTOR:
/// There is deliberately NO API key anywhere in this file, and there must
/// never be one. The app cannot read provider keys from Firestore either -
/// the rules deny it. Keys live only on the proxy, which reads them with a
/// Firebase service account. Anything shipped inside an APK is readable by
/// the user holding the phone.
class AiService {
  /// Set this to your Render service URL after deploying `proxy/`.
  /// Override at build time:
  ///   flutter build apk --release --dart-define=AI_PROXY_URL=https://...
  static const String proxyUrl = String.fromEnvironment(
    'AI_PROXY_URL',
    defaultValue: 'https://ibtidaa-ai-proxy.onrender.com',
  );

  static bool get isConfigured => proxyUrl.isNotEmpty;

  /// Sends a prompt. The proxy picks the provider, rotates keys on failure
  /// and returns plain text.
  ///
  /// [task] lets the proxy apply the right system prompt and pick a provider
  /// tier, e.g. 'mentor', 'business_idea', 'course_suggest'.
  Future<AiResponse> ask({
    required String prompt,
    String task = 'general',
    String? idToken,
  }) async {
    if (prompt.trim().isEmpty) {
      return const AiResponse.error('Please type something first.');
    }
    try {
      final res = await http
          .post(
            Uri.parse('$proxyUrl/api/ai'),
            headers: {
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({'prompt': prompt, 'task': task}),
          )
          .timeout(const Duration(seconds: 45));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return AiResponse.success(
          (body['text'] ?? '').toString(),
          provider: body['provider']?.toString(),
        );
      }
      if (res.statusCode == 429) {
        return const AiResponse.error(
          'All AI services are busy right now. Please try again in a minute.',
        );
      }
      if (res.statusCode == 503) {
        return const AiResponse.error(
          'AI is not set up yet. An admin needs to add a provider key.',
        );
      }
      return const AiResponse.error(
        'Could not reach the AI service. Please try again.',
      );
    } catch (_) {
      // Render free tier sleeps when idle; the first call can be slow.
      return const AiResponse.error(
        'Could not reach the AI service. If this is the first request in a '
        'while, wait about 30 seconds and try again.',
      );
    }
  }
}

class AiResponse {
  final bool ok;
  final String text;
  final String? provider;

  const AiResponse.success(this.text, {this.provider}) : ok = true;
  const AiResponse.error(this.text)
      : ok = false,
        provider = null;
}
