import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

class LoginResponse {
  LoginResponse({
    required this.error,
    required this.username,
    required this.token,
    required this.tokenValid,
  });

  bool error;
  String token;
  String username;
  bool tokenValid;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        error: json["error"] ?? false,
        username: json["myfood_username"] ?? "",
        token: json["myfood_token"] ?? "",
        tokenValid: json["myfood_token_valid"] ?? false,
      );
}
