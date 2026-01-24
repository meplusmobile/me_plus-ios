import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:me_plus/core/services/debug_log_service.dart';
import 'package:me_plus/data/services/token_storage_service.dart';
import 'package:me_plus/data/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final _debugService = DebugLogService();
  final _tokenStorage = TokenStorageService();
  
  String _tokenInfo = 'Loading...';
  String _storageInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    // Try to initialize storage if not ready
    if (!StorageService.isReady) {
      _debugService.logWarning('Storage not ready! Attempting to initialize...');
      try {
        await StorageService.init();
        _debugService.logSuccess('Storage initialized successfully');
      } catch (e) {
        _debugService.logError('Storage init failed: $e');
      }
    }
    await _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    // Get token info
    final token = await _tokenStorage.getToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    final userId = await _tokenStorage.getUserId();
    final isLoggedIn = await _tokenStorage.isLoggedIn();

    setState(() {
      _tokenInfo = '''
🔐 Token Status:
━━━━━━━━━━━━━━━━━━━━━━━━
• Logged In: ${isLoggedIn ? '✅ YES' : '❌ NO'}
• Token Exists: ${token != null ? '✅ YES' : '❌ NO'}
• Token Length: ${token?.length ?? 0}
${token != null && token.length > 30 ? '• Preview: ${token.substring(0, 30)}...' : token != null ? '• Token: $token' : ''}
• Refresh Token: ${refreshToken != null ? '✅ EXISTS' : '❌ NULL'}
• User ID: ${userId ?? 'N/A'}
''';

      _storageInfo = '''
💾 Storage Status:
━━━━━━━━━━━━━━━━━━━━━━━━
• Storage Ready: ${StorageService.isReady ? '✅ YES' : '❌ NO'}
• Secure Storage: ${StorageService().secureStorage != null ? '✅ OK' : '❌ NULL'}
• iOS Keychain: ${StorageService.isReady ? '✅ Active' : '❌ Inactive'}
• Using: iOS Keychain ONLY (no SharedPreferences)
''';
    });

    _debugService.logInfo('Debug screen loaded');
    _debugService.logToken(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Debug Console',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDebugInfo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _debugService.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Token & Storage Info Panel
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  _tokenInfo,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const Divider(color: Colors.grey),
                SelectableText(
                  _storageInfo,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                // First Row of Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testTokenStorage,
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Test Token', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _reinitStorage,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Init Storage', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Second Row of Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _runFullDiagnostic,
                        icon: const Icon(Icons.troubleshoot, size: 16),
                        label: const Text('Full Diagnostic', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyLogs,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Logs', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Logs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _debugService.logs.length,
              itemBuilder: (context, index) {
                final log = _debugService.logs[index];
                return _buildLogItem(log);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(DebugLog log) {
    Color backgroundColor;
    Color textColor;

    switch (log.type) {
      case DebugLogType.error:
        backgroundColor = Colors.red.shade900.withOpacity(0.3);
        textColor = Colors.redAccent;
        break;
      case DebugLogType.warning:
        backgroundColor = Colors.orange.shade900.withOpacity(0.3);
        textColor = Colors.orangeAccent;
        break;
      case DebugLogType.success:
        backgroundColor = Colors.green.shade900.withOpacity(0.3);
        textColor = Colors.greenAccent;
        break;
      default:
        backgroundColor = Colors.grey.shade900.withOpacity(0.3);
        textColor = Colors.white70;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.formattedTime,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              log.message,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testTokenStorage() async {
    _debugService.logInfo('Starting token storage test...');
    
    // Test 1: Save a test token directly to Keychain
    _debugService.logInfo('🧪 Test 1: Saving test token to iOS Keychain...');
    final storage = StorageService();
    try {
      await storage.saveSecureString('test_token', 'my_test_token_12345');
      _debugService.logSuccess('Test token saved');
      
      // Test 2: Retrieve it immediately
      _debugService.logInfo('🧪 Test 2: Retrieving test token from iOS Keychain...');
      final retrieved = await storage.getSecureString('test_token');
      if (retrieved == 'my_test_token_12345') {
        _debugService.logSuccess('✅ iOS Keychain WORKS! Token retrieved successfully!');
      } else if (retrieved == null) {
        _debugService.logError('❌ iOS Keychain FAILED! Retrieved NULL');
      } else {
        _debugService.logError('❌ iOS Keychain MISMATCH! Got: $retrieved');
      }
      
      // Clean up test
      await storage.removeSecure('test_token');
      _debugService.logInfo('Test token removed');
    } catch (e) {
      _debugService.logError('iOS Keychain test error: $e');
    }
    
    // Test 3: Check actual auth token
    final token = await _tokenStorage.getToken();
    _debugService.logToken(token);
    
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      _debugService.logSuccess('Refresh token exists');
    } else {
      _debugService.logError('Refresh token is NULL');
    }
    
    final userId = await _tokenStorage.getUserId();
    _debugService.logInfo('User ID: ${userId ?? 'NULL'}');
    
    final isLoggedIn = await _tokenStorage.isLoggedIn();
    if (isLoggedIn) {
      _debugService.logSuccess('User is logged in');
    } else {
      _debugService.logError('User is NOT logged in');
    }
    
    await _loadDebugInfo();
  }

  Future<void> _runFullDiagnostic() async {
    _debugService.logInfo('🔬 ═══════════════════════════════════════');
    _debugService.logInfo('🔬 RUNNING FULL DIAGNOSTIC');
    _debugService.logInfo('🔬 ═══════════════════════════════════════');
    
    // Test 1: Memory Cache
    _debugService.logInfo('');
    _debugService.logInfo('📍 TEST 1: Memory Cache');
    _debugService.logInfo('─────────────────────────────────────');
    final tokenService = TokenStorageService();
    // Force a fresh read to test retrieval
    final token1 = await tokenService.getToken();
    if (token1 != null) {
      _debugService.logSuccess('✅ Token in Memory Cache: ${token1.substring(0, 30)}...');
    } else {
      _debugService.logError('❌ Token NOT in Memory Cache');
    }
    
    // Test 2: SharedPreferences
    _debugService.logInfo('');
    _debugService.logInfo('📍 TEST 2: SharedPreferences');
    _debugService.logInfo('─────────────────────────────────────');
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupToken = prefs.getString('backup_auth_token');
      if (backupToken != null) {
        _debugService.logSuccess('✅ Token in SharedPreferences: ${backupToken.substring(0, 30)}...');
        _debugService.logInfo('   Length: ${backupToken.length}');
      } else {
        _debugService.logError('❌ Token NOT in SharedPreferences');
      }
      
      // List all keys
      final allKeys = prefs.getKeys();
      _debugService.logInfo('   All SP keys: ${allKeys.join(', ')}');
    } catch (e) {
      _debugService.logError('❌ SharedPreferences error: $e');
    }
    
    // Test 3: iOS Keychain
    _debugService.logInfo('');
    _debugService.logInfo('📍 TEST 3: iOS Keychain');
    _debugService.logInfo('─────────────────────────────────────');
    final storage = StorageService();
    try {
      // Direct keychain test
      const testKey = '__diagnostic_test__';
      const testValue = 'diagnostic_test_12345';
      
      await storage.saveSecureString(testKey, testValue);
      await Future.delayed(const Duration(milliseconds: 300));
      final readTest = await storage.getSecureString(testKey);
      await storage.removeSecure(testKey);
      
      if (readTest == testValue) {
        _debugService.logSuccess('✅ iOS Keychain: WORKING');
      } else {
        _debugService.logError('❌ iOS Keychain: BROKEN (read: ${readTest ?? 'NULL'})');
      }
      
      // Check actual token in keychain
      final keychainToken = await storage.getSecureString('auth_token');
      if (keychainToken != null) {
        _debugService.logSuccess('✅ Auth Token in Keychain: ${keychainToken.substring(0, 30)}...');
        _debugService.logInfo('   Length: ${keychainToken.length}');
      } else {
        _debugService.logError('❌ Auth Token NOT in Keychain');
      }
    } catch (e) {
      _debugService.logError('❌ Keychain test error: $e');
    }
    
    // Test 4: Token Retrieval
    _debugService.logInfo('');
    _debugService.logInfo('📍 TEST 4: Token Retrieval via Service');
    _debugService.logInfo('─────────────────────────────────────');
    final finalToken = await tokenService.getToken();
    if (finalToken != null) {
      _debugService.logSuccess('✅ Final Token Retrieved: ${finalToken.substring(0, 30)}...');
      _debugService.logInfo('   Length: ${finalToken.length}');
    } else {
      _debugService.logError('❌ Final Token: NULL');
    }
    
    // Test 5: Login Status
    _debugService.logInfo('');
    _debugService.logInfo('📍 TEST 5: Login Status');
    _debugService.logInfo('─────────────────────────────────────');
    final isLoggedIn = await tokenService.isLoggedIn();
    final userId = await tokenService.getUserId();
    final userEmail = await tokenService.getUserEmail();
    
    if (isLoggedIn) {
      _debugService.logSuccess('✅ User is LOGGED IN');
      _debugService.logInfo('   User ID: $userId');
      _debugService.logInfo('   Email: $userEmail');
    } else {
      _debugService.logError('❌ User is NOT LOGGED IN');
    }
    
    _debugService.logInfo('');
    _debugService.logInfo('═══════════════════════════════════════');
    _debugService.logInfo('🔬 DIAGNOSTIC COMPLETE');
    _debugService.logInfo('═══════════════════════════════════════');
    
    await _loadDebugInfo();
  }

  Future<void> _reinitStorage() async {
    _debugService.logInfo('🔄 Re-initializing storage...');
    
    try {
      await StorageService.init();
      
      if (StorageService.isReady) {
        _debugService.logSuccess('✅ Storage initialized successfully!');
        _debugService.logSuccess('Secure Storage (iOS Keychain): ${StorageService().secureStorage != null ? 'OK' : 'NULL'}');
      } else {
        _debugService.logError('❌ Storage init completed but not ready');
      }
    } catch (e) {
      _debugService.logError('❌ Storage initialization failed: $e');
    }
    
    await _loadDebugInfo();
  }

  void _copyLogs() {
    final logsText = _debugService.logs
        .map((log) => '[${log.formattedTime}] ${log.message}')
        .join('\n');
    
    final fullText = '$_tokenInfo\n$_storageInfo\n\nLogs:\n$logsText';
    
    Clipboard.setData(ClipboardData(text: fullText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
