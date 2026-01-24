import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:me_plus/core/services/debug_log_service.dart';
import 'package:me_plus/data/services/token_storage_service.dart';
import 'package:me_plus/data/services/storage_service.dart';

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
    _loadDebugInfo();
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
• SharedPreferences: ${StorageService().prefs != null ? '✅ OK' : '❌ NULL'}
• Secure Storage: ${StorageService().secureStorage != null ? '✅ OK' : '❌ NULL'}
• iOS Keychain: Enabled
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testTokenStorage,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Test Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyLogs,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Logs'),
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
