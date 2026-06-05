/// Tokens de espaçamento e raio. Centralizar evita números mágicos espalhados
/// e mantém o ritmo visual consistente (bastante respiro, cantos suaves).
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Largura máxima do conteúdo em telas grandes (layout centralizado).
  static const double contentMaxWidth = 1180;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}
