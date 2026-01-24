import 'package:flutter/foundation.dart';

/// Service to collect logs for display in UI
class DebugLogService {
  static final DebugLogService _instance = DebugLogService._internal();
  factory DebugLogService() => _instance;
  DebugLogService._internal();

  final List<DebugLog> _logs = [];
  final int _maxLogs = 100;

  void addLog(String message, {DebugLogType type = DebugLogType.info}) {
    final log = DebugLog(
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
    
    _logs.insert(0, log);
    if (_logs.length > _maxLogs) {
      _logs.removeLast();
    }
    
    debugPrint('${type.emoji} $message');
  }

  List<DebugLog> get logs => List.unmodifiable(_logs);

  void clear() {
    _logs.clear();
    debugPrint('🧹 Logs cleared');
  }

  void logToken(String? token) {
    if (token == null) {
      addLog('❌ Token is NULL', type: DebugLogType.error);
    } else if (token.isEmpty) {
      addLog('❌ Token is EMPTY', type: DebugLogType.error);
    } else {
      final preview = token.length > 30 ? '${token.substring(0, 30)}...' : token;
      addLog('✅ Token: $preview (length: ${token.length})', type: DebugLogType.success);
    }
  }

  void logApiCall(String endpoint, int statusCode, {String? error}) {
    if (statusCode >= 200 && statusCode < 300) {
      addLog('✅ API: $endpoint → $statusCode', type: DebugLogType.success);
    } else {
      addLog('❌ API: $endpoint → $statusCode ${error ?? ''}', type: DebugLogType.error);
    }
  }

  void logInfo(String message) {
    addLog('ℹ️ $message', type: DebugLogType.info);
  }

  void logWarning(String message) {
    addLog('⚠️ $message', type: DebugLogType.warning);
  }

  void logError(String message) {
    addLog('❌ $message', type: DebugLogType.error);
  }

  void logSuccess(String message) {
    addLog('✅ $message', type: DebugLogType.success);
  }
}

class DebugLog {
  final String message;
  final DebugLogType type;
  final DateTime timestamp;

  DebugLog({
    required this.message,
    required this.type,
    required this.timestamp,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}

enum DebugLogType {
  info,
  success,
  warning,
  error;

  String get emoji {
    switch (this) {
      case DebugLogType.info:
        return 'ℹ️';
      case DebugLogType.success:
        return '✅';
      case DebugLogType.warning:
        return '⚠️';
      case DebugLogType.error:
        return '❌';
    }
  }
}
