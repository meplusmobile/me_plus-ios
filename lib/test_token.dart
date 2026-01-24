import 'package:flutter/material.dart';
import 'package:me_plus/data/services/storage_service.dart';
import 'package:me_plus/data/services/token_storage_service.dart';

/// Test file to verify iOS Keychain token storage
Future<void> testTokenStorage() async {
  debugPrint('\n🔍 ==================== TOKEN STORAGE TEST ====================');
  
  // Initialize storage
  await StorageService.init();
  debugPrint('✅ Storage initialized');
  
  final tokenStorage = TokenStorageService();
  
  // Test 1: Check if token exists
  final token = await tokenStorage.getToken();
  final refreshToken = await tokenStorage.getRefreshToken();
  final userId = await tokenStorage.getUserId();
  final isLoggedIn = await tokenStorage.isLoggedIn();
  
  debugPrint('\n📊 Current Storage State:');
  debugPrint('  • Is Logged In: $isLoggedIn');
  debugPrint('  • Token exists: ${token != null}');
  debugPrint('  • Token length: ${token?.length ?? 0}');
  if (token != null && token.length > 20) {
    debugPrint('  • Token preview: ${token.substring(0, 20)}...');
  } else {
    debugPrint('  • Token value: $token');
  }
  debugPrint('  • Refresh token exists: ${refreshToken != null}');
  debugPrint('  • User ID: $userId');
  
  // Test 2: Try to save and retrieve a test token
  debugPrint('\n🧪 Testing Save/Retrieve:');
  await tokenStorage.saveAuthData(
    token: 'test_token_123456789',
    refreshToken: 'test_refresh_token_123',
    userId: 'test_user_id',
    email: 'test@example.com',
    role: 'Student',
    isFirstTimeUser: false,
  );
  debugPrint('  • Test token saved');
  
  final savedToken = await tokenStorage.getToken();
  debugPrint('  • Test token retrieved: $savedToken');
  debugPrint('  • Retrieval successful: ${savedToken == 'test_token_123456789'}');
  
  // Test 3: Check if it's using secure storage
  final storage = StorageService();
  final secureToken = await storage.getSecureString('auth_token');
  debugPrint('\n🔐 Secure Storage Check:');
  debugPrint('  • Token in iOS Keychain: ${secureToken != null}');
  debugPrint('  • Keychain value matches: ${secureToken == savedToken}');
  
  debugPrint('\n============================================================\n');
}

/// Widget to display token debug info
class TokenDebugWidget extends StatefulWidget {
  const TokenDebugWidget({super.key});

  @override
  State<TokenDebugWidget> createState() => _TokenDebugWidgetState();
}

class _TokenDebugWidgetState extends State<TokenDebugWidget> {
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    final tokenStorage = TokenStorageService();
    await tokenStorage.debugTokenStorage();
    
    final token = await tokenStorage.getToken();
    final isLoggedIn = await tokenStorage.isLoggedIn();
    final userId = await tokenStorage.getUserId();
    
    setState(() {
      _debugInfo = '''
iOS Keychain Token Status:
━━━━━━━━━━━━━━━━━━━━━━━━
Is Logged In: $isLoggedIn
Token Exists: ${token != null}
Token Length: ${token?.length ?? 0}
User ID: $userId

${token != null && token.length > 20 ? 'Token Preview:\n${token.substring(0, 50)}...' : 'Token: $token'}
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'iOS Keychain Debug',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            _debugInfo,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadDebugInfo,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
