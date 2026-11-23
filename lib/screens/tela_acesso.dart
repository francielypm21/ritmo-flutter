import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/botao_gradiente.dart';
import '../widgets/fundo_decorado.dart';
import 'tela_calendario.dart';

/// Tela de login e cadastro na mesma página, com abas para alternar.
class TelaAcesso extends StatefulWidget {
  const TelaAcesso({super.key});

  @override
  State<TelaAcesso> createState() => _TelaAcessoState();
}

class _TelaAcessoState extends State<TelaAcesso> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _modoCadastro = false;
  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _trocarModo(bool cadastro) {
    if (cadastro == _modoCadastro) return;
    setState(() {
      _modoCadastro = cadastro;
      _erro = null;
    });
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    final resultado = _modoCadastro
        ? await AuthService.cadastrar(
            nome: _nomeController.text,
            email: _emailController.text,
            senha: _senhaController.text,
          )
        : await AuthService.entrar(
            email: _emailController.text,
            senha: _senhaController.text,
          );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (resultado.ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TelaCalendario(usuario: resultado.usuario!),
        ),
      );
    } else {
      setState(() => _erro = resultado.erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoDecorado(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _logo(),
                  const SizedBox(height: 36),
                  _abas(),
                  const SizedBox(height: 16),
                  _formulario(),
                  const SizedBox(height: 20),
                  _rodape(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppCores.gradiente,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x66FF2E93), blurRadius: 24),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              color: AppCores.texto,
              height: 1,
            ),
            children: [
              TextSpan(text: 'ritmo'),
              TextSpan(text: '.', style: TextStyle(color: AppCores.limao)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seu dia, no seu compasso.',
          style: TextStyle(color: AppCores.textoSuave, fontSize: 16),
        ),
      ],
    );
  }

  /// Seletor "Entrar | Cadastro".
  Widget _abas() {
    Widget aba(String texto, bool ativa, VoidCallback aoTocar) {
      return Expanded(
        child: GestureDetector(
          onTap: aoTocar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: ativa ? AppCores.gradiente : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ativa ? Colors.white : AppCores.textoSuave,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          aba('Entrar', !_modoCadastro, () => _trocarModo(false)),
          aba('Cadastro', _modoCadastro, () => _trocarModo(true)),
        ],
      ),
    );
  }

  Widget _formulario() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Form(
        key: _formKey,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _modoCadastro ? 'Crie sua conta' : 'Bem-vindo de volta',
                style: const TextStyle(
                  color: AppCores.texto,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              // O campo de nome só aparece no cadastro.
              if (_modoCadastro) ...[
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: AppCores.texto),
                  decoration: AppTheme.campo(
                    rotulo: 'Nome',
                    icone: Icons.person_rounded,
                  ),
                  validator: (valor) => (valor == null || valor.trim().isEmpty)
                      ? 'Informe seu nome'
                      : null,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppCores.texto),
                decoration: AppTheme.campo(
                  rotulo: 'E-mail',
                  icone: Icons.alternate_email_rounded,
                ),
                validator: (valor) {
                  final email = valor?.trim() ?? '';
                  if (email.isEmpty) return 'Informe seu e-mail';
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _senhaController,
                obscureText: !_senhaVisivel,
                style: const TextStyle(color: AppCores.texto),
                decoration: AppTheme.campo(
                  rotulo: 'Senha',
                  icone: Icons.lock_rounded,
                  sufixo: IconButton(
                    icon: Icon(
                      _senhaVisivel
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppCores.textoSuave,
                    ),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
                onFieldSubmitted: (_) => _enviar(),
                validator: (valor) {
                  final senha = valor ?? '';
                  if (senha.isEmpty) return 'Informe sua senha';
                  if (_modoCadastro && senha.length < 6) {
                    return 'Use pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              if (_erro != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.error_rounded,
                        color: AppCores.magenta, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _erro!,
                        style: const TextStyle(
                          color: AppCores.magenta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              BotaoGradiente(
                texto: _modoCadastro ? 'Criar conta' : 'Entrar',
                icone: _modoCadastro
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
                carregando: _carregando,
                onPressed: _enviar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rodape() {
    return Center(
      child: GestureDetector(
        onTap: () => _trocarModo(!_modoCadastro),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppCores.textoSuave, fontSize: 15),
            children: [
              TextSpan(
                text: _modoCadastro
                    ? 'Já tem conta? '
                    : 'Ainda não tem conta? ',
              ),
              TextSpan(
                text: _modoCadastro ? 'Entrar' : 'Cadastre-se',
                style: const TextStyle(
                  color: AppCores.limao,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
