import 'package:flutter/material.dart';
import 'package:me_plus/data/services/api_service.dart';
import 'package:me_plus/data/services/token_storage_service.dart';

/// Debug screen to test API connectivity and token
class DebugApiScreen extends StatefulWidget {
  const DebugApiScreen({super.key});

  @override
  State<DebugApiScreen> createState() => _DebugApiScreenState();
}

class _DebugApiScreenState extends State<DebugApiScreen> {
  final ApiService _apiService = ApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();
  
  String _output = 'Press buttons to test API\n\n';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _checkToken,
                    child: const Text('Check Token'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testApiMe,
                    child: const Text('Test /api/me'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testBehavior,
                    child: const Text('Test Behavior'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _clearOutput,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkToken() async {
    setState(() {
      _isLoading = true;
      _output += '🔍 Checking token...\n';
    });

    try {
      final token = await _tokenStorage.getToken();
      final refreshToken = await _tokenStorage.getRefreshToken();
      final userId = await _tokenStorage.getUserId();
      final role = await _tokenStorage.getUserRole();
      final email = await _tokenStorage.getUserEmail();

      setState(() {
        _output += '✅ Token exists: ${token != null && token.isNotEmpty}\n';
        if (token != null && token.isNotEmpty) {
          _output += '   Token preview: ${token.substring(0, 30)}...\n';
        }
        _output += '✅ RefreshToken exists: ${refreshToken != null && refreshToken.isNotEmpty}\n';
        _output += '✅ UserID: $userId\n';
        _output += '✅ Role: $role\n';
        _output += '✅ Email: $email\n\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _output += '❌ Error checking token: $e\n\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testApiMe() async {
    setState(() {
      _isLoading = true;
      _output += '🌐 Testing /api/me...\n';
    });

    try {
      final response = await _apiService.get('/api/me');

      setState(() {
        _output += '📡 Response:\n';
        _output += '   Success: ${response.success}\n';
        _output += '   Status Code: ${response.statusCode}\n';
        
        if (response.success && response.data != null) {
          _output += '✅ Data received:\n';
          _output += '   ${response.data.toString().substring(0, 200)}...\n\n';
        } else {
          _output += '❌ Error: ${response.error}\n\n';
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _output += '❌ Exception: $e\n\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testBehavior() async {
    setState(() {
      _isLoading = true;
      _output += '🌐 Testing /api/behavior-streak...\n';
    });

    try {
      final response = await _apiService.get('/api/behavior-streak');

      setState(() {
        _output += '📡 Response:\n';
        _output += '   Success: ${response.success}\n';
        _output += '   Status Code: ${response.statusCode}\n';
        
        if (response.success && response.data != null) {
          _output += '✅ Data received:\n';
          final dataStr = response.data.toString();
          _output += '   ${dataStr.substring(0, dataStr.length > 200 ? 200 : dataStr.length)}...\n\n';
        } else {
          _output += '❌ Error: ${response.error}\n\n';
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _output += '❌ Exception: $e\n\n';
        _isLoading = false;
      });
    }
  }

  void _clearOutput() {
    setState(() {
      _output = 'Press buttons to test API\n\n';
    });
  }
}
