import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/error_messages.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_scaffold.dart';

/// Tela de recuperação de senha.
///
/// Envia o e-mail de redefinição via Supabase. Após o envio bem-sucedido,
/// mostra um estado de confirmação em vez do formulário — assim o usuário
/// entende que a ação foi concluída sem precisar de um snackbar efêmero.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  // Controla a troca entre formulário e tela de "e-mail enviado".
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).resetPassword(_email.text);

    // Só marca como enviado se não houve erro no estado.
    final state = ref.read(authControllerProvider);
    if (!state.hasError && mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    // Erros aparecem em snackbar.
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(friendlyError(next.error!))));
      }
    });

    return AuthScaffold(
      title: _sent ? 'Verifique seu e-mail' : 'Recuperar senha',
      subtitle: _sent
          ? 'Enviamos um link de redefinição para ${_email.text.trim()}.'
          : 'Informe seu e-mail e enviaremos um link para redefinir a senha.',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Lembrou a senha?'),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
      child: _sent ? _buildSentState(context) : _buildForm(state),
    );
  }

  Widget _buildForm(AsyncValue<void> state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'E-mail',
            controller: _email,
            hint: 'voce@universidade.br',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Enviar link',
            isLoading: state.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSentState(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Se houver uma conta com esse e-mail, o link chegará em instantes. '
          'Confira também a caixa de spam.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Voltar ao login',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
