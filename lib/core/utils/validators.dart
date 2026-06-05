/// Validadores reutilizáveis para `TextFormField`.
/// Retornam `null` quando válido ou a mensagem de erro caso contrário.
class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$',
  );

  static String? required(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório.';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe o e-mail.';
    if (!_emailRegex.hasMatch(v)) return 'E-mail inválido.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe a senha.';
    if (v.length < 6) return 'A senha deve ter ao menos 6 caracteres.';
    return null;
  }

  /// Confirmação de senha. Recebe a senha original via closure.
  static String? Function(String?) confirmPassword(String original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Confirme a senha.';
      if (value != original) return 'As senhas não coincidem.';
      return null;
    };
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null; // opcional
    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone inválido.';
    }
    return null;
  }
}
