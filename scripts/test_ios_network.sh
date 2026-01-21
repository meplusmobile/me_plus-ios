#!/bin/bash

# iOS Network Diagnostics Script
# Run this to test ATS compliance before deployment

echo "🔍 Testing iOS App Transport Security (ATS) Compliance"
echo "=================================================="
echo ""

API_URL="https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net"

# Test 1: Basic connectivity
echo "Test 1: Basic HTTPS Connectivity"
if curl -Is "$API_URL" > /dev/null 2>&1; then
    echo "✅ Server is reachable"
else
    echo "❌ Cannot reach server"
    exit 1
fi
echo ""

# Test 2: TLS Version
echo "Test 2: TLS Version Check"
TLS_VERSION=$(curl -sI "$API_URL" -w "%{ssl_version}\n" -o /dev/null)
echo "TLS Version: $TLS_VERSION"
if [[ "$TLS_VERSION" == "TLSv1.2" ]] || [[ "$TLS_VERSION" == "TLSv1.3" ]]; then
    echo "✅ TLS version is compliant (1.2 or 1.3)"
else
    echo "⚠️  Warning: TLS version may not be compliant"
fi
echo ""

# Test 3: Certificate validity
echo "Test 3: SSL Certificate Check"
if openssl s_client -connect meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net:443 -servername meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net < /dev/null 2>&1 | grep -q "Verify return code: 0"; then
    echo "✅ SSL certificate is valid"
else
    echo "⚠️  SSL certificate may have issues"
fi
echo ""

# Test 4: Cipher suites
echo "Test 4: Forward Secrecy Support"
CIPHER=$(openssl s_client -connect meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net:443 -cipher ECDHE 2>&1 | grep "Cipher" | head -1)
if [[ "$CIPHER" == *"ECDHE"* ]]; then
    echo "✅ Forward secrecy is supported (ECDHE)"
    echo "$CIPHER"
else
    echo "⚠️  Forward secrecy may not be properly configured"
fi
echo ""

# Test 5: API endpoint test
echo "Test 5: API Endpoint Test"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/login" -X POST -H "Content-Type: application/json" -d '{"email":"test","password":"test"}')
echo "Login endpoint status: $HTTP_CODE"
if [[ "$HTTP_CODE" == "400" ]] || [[ "$HTTP_CODE" == "401" ]] || [[ "$HTTP_CODE" == "200" ]]; then
    echo "✅ API endpoint is responding"
else
    echo "⚠️  Unexpected status code: $HTTP_CODE"
fi
echo ""

echo "=================================================="
echo "✅ All tests completed!"
echo ""
echo "iOS Compatibility Summary:"
echo "- Ensure all tests pass before App Store submission"
echo "- TLS 1.2+ is required"
echo "- Valid CA-signed certificate required"
echo "- Forward secrecy (ECDHE) must be supported"
echo ""
echo "To debug on iOS device:"
echo "  flutter run --release"
echo "  Check Xcode console for network logs"
