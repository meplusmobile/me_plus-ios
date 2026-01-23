# StudentRepository Conversion Plan

## Pattern to convert from ApiService to http.Client

### OLD Pattern (ApiService):
```dart
Future<T> method() async {
  final response = await _apiService.get('/endpoint');
  return Model.fromJson(response.data);
}
```

### NEW Pattern (http.Client):
```dart
Future<T> method() async {
  final url = '${ApiConstants.baseUrl}/endpoint';
  final headers = await _getHeaders();
  final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
  final data = _handleResponse(response, operation: 'MethodName');
  return Model.fromJson(data);
}
```

## Methods to convert (all 30+):
- ✅ getProfile
- ✅ updateProfile
- ⏳ getBehaviorStreak
- ⏳ claimBehaviorReward
- ⏳ getWeekDetails
- ⏳ getBehaviorThisMonth
- ⏳ getBehaviorReport
- ⏳ getStartOfWeeks
- ⏳ getBehaviorByDay
- ⏳ getStoreRewards
- ⏳ purchaseReward
- ⏳ confirmPurchaseReceived
- ⏳ getStudentPurchases
- ⏳ getPurchasesThisMonth
- ⏳ getAllPurchases
- ⏳ getActivity
- ⏳ getBehaviorsByDay
- ⏳ reportMissingReward
- ⏳ getHonorList
- ⏳ getNotifications
- ⏳ markNotificationAsRead
- ⏳ deleteNotification
- ⏳ getNotificationSettings
