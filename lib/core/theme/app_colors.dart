import 'package:flutter/material.dart';

/// Paleta da plataforma.
///
/// Direção: neutros frios (slate) + um indigo sóbrio como cor de marca, com
/// acentos pontuais para estados (sucesso/aviso/erro). Tons calibrados para um
/// visual corporativo, científico e clean — referências: Stripe, Linear, Vercel.
class AppColors {
  const AppColors._();

  // Marca ---------------------------------------------------------------------
  static const Color primary = Color(0xFF4F46E5); // indigo 600
  static const Color primaryHover = Color(0xFF4338CA); // indigo 700
  static const Color primarySoft = Color(0xFFEEF2FF); // indigo 50 (fundos suaves)
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Neutros (slate) -----------------------------------------------------------
  static const Color background = Color(0xFFF8FAFC); // slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // slate 100
  static const Color border = Color(0xFFE2E8F0); // slate 200
  static const Color borderStrong = Color(0xFFCBD5E1); // slate 300

  static const Color textPrimary = Color(0xFF0F172A); // slate 900
  static const Color textSecondary = Color(0xFF475569); // slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // slate 400

  // Estados -------------------------------------------------------------------
  static const Color success = Color(0xFF059669); // emerald 600
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706); // amber 600
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626); // red 600
  static const Color errorSoft = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB); // blue 600
  static const Color infoSoft = Color(0xFFEFF6FF);

  // Sombras --------------------------------------------------------------------
  /// Sombra sutil para cards (estilo SaaS, quase imperceptível).
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F0F172A), // slate 900 ~6%
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // slate 900 ~4%
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
}
