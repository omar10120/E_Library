import 'package:jwt_decoder/jwt_decoder.dart';

class TokenModel {
  final String token;

  TokenModel({required this.token});

  factory TokenModel.fromMap(Map<String, dynamic> json) {
    return TokenModel(token: json["token"]);
  }

  Map<String, dynamic> toMap() => {
        "token": token,
      };

  /// Extract role from JWT
  String get userRole {
    final decoded = JwtDecoder.decode(token);
    const roleClaimKey =
        "http://schemas.microsoft.com/ws/2008/06/identity/claims/role";
    return decoded[roleClaimKey] ?? "User";
  }

  String get username {
    final decoded = JwtDecoder.decode(token);
    return decoded['unique_name'] ?? '';
  }
}
