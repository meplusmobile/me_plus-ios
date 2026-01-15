class GoogleLoginRequest {
  final String accessToken;

  GoogleLoginRequest({required this.accessToken});

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken};
  }
}
