#!/usr/bin/env python3
"""
Quick converter from ApiService to http.Client for StudentRepository
"""

import re

# Read the file
with open('lib/data/repositories/student_repository.dart', 'r', encoding='utf-8') as f:
    content = f.content()

# Pattern 1: Simple GET with no query params
# _apiService.get('/endpoint') -> http direct call
pattern1 = r"final response = await _apiService\.get\('(/[^']+)'\);"
replacement1 = lambda m: f"""final url = '${{ApiConstants.baseUrl}}{m.group(1)}';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: '{m.group(1).split('/')[-1]}');"""

# Pattern 2: GET with query params
pattern2 = r"final response = await _apiService\.get\(\s*'(/[^']+)',\s*queryParameters: ({[^}]+}),\s*\);"

# Convert
content = re.sub(pattern1, replacement1, content)

# Write back
with open('lib/data/repositories/student_repository.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Conversion complete!")
