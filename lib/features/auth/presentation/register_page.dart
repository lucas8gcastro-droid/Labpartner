import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/error_messages.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _university = TextEditingController();
  final _course = TextEditingController();
  final _semester = TextEditingController();
  final _pix = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _phone,
      _university,
      _course,
      _semester,
      _pix,
      _password,
      _confirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final hasSession = await ref.read(authControllerProvider.notifier).signUp(
            fullName: _name.text,
            email: _email.text,
            password: _password.text,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            university: _university.text.trim().isEmpty ? null : _university.text.trim(),
            course: _course.text.trim().isEmpty ? null : _course.text.trim(),
            semester: _semester.text.trim().isEmpty ? null : _semester.text.trim(),
            pixKey: _pix.text.trim().isEmpty ? null : _pix.text.trim(),
          );

      if (!mounted) return;

      if (hasSession) {
        // Logado: o redirect do GoRouter assume daqui.
        return;
      }

      // Precisa confirmar e-mail.
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirme seu e-mail'),
          content: const Text(
            'Enviamos um link de confirmação para o seu e-mail. '
            'Confirme para ativar a conta e fazer login.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      if (mounted) context.pop(); // volta ao login
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: 'Criar conta',
      subtitle: 'Cadastre-se como representante universitário.',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Já tem conta?'),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Entrar'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nome completo',
              controller: _name,
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, field: 'Nome'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'E-mail',
              controller: _email,
              prefixIcon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Telefone',
              controller: _phone,
              hint: '(00) 00000-0000',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: Validators.phone,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Universidade',
              controller: _university,
              prefixIcon: Icons.school_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Curso',
                    controller: _course,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: AppTextField(
                    label: 'Semestre',
                    controller: _semester,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Chave Pix',
              controller: _pix,
              hint: 'Para recebimento de comissões',
              prefixIcon: Icons.pix,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Senha',
              controller: _password,
              prefixIcon: Icons.lock_outline,
              obscure: true,
              textInputAction: TextInputAction.next,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Confirmar senha',
              controller: _confirm,
              prefixIcon: Icons.lock_outline,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: Validators.confirmPassword(_password.text),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Criar conta',
              isLoading: state.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
