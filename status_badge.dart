import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/enums.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Perfil de negócio do usuário (espelha a tabela public.users).
@freezed
class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    String? phone,
    String? university,
    String? course,
    String? semester,
    @JsonKey(name: 'pix_key') String? pixKey,
    @Default(UserRole.representative) UserRole role,
    @JsonKey(name: 'commission_rate') @Default(0.1) double commissionRate,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  /// Primeiro nome, para saudações.
  String get firstName => fullName.trim().split(' ').first;

  bool get isAdmin => role.isAdmin;
}
