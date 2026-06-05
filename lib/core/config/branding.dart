import 'package:flutter/material.dart';

/// Identidade da marca em um único lugar.
///
/// Como o nome "LabPartner" é provisório, todo texto/cor de marca passa por
/// aqui. Para rebrandizar, basta editar esta classe — nenhuma tela referencia
/// o nome diretamente.
class Branding {
  const Branding._();

  static const String appName = 'LabPartner';
  static const String tagline = 'Química fina para a universidade';
  static const String legalName = 'LabPartner Tecnologia Ltda.';
  static const String supportEmail = 'contato@labpartner.com.br';

  /// Cor-semente da marca (usada pelo tema).
  static const Color seedColor = Color(0xFF4F46E5); // indigo
}
