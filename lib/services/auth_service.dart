import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

/// Resultado de uma tentativa de login ou cadastro:
/// ou traz o usuário (sucesso) ou uma mensagem de erro (falha).
class ResultadoAuth {
  final Usuario? usuario;
  final String? erro;

  const ResultadoAuth.sucesso(Usuario this.usuario) : erro = null;
  const ResultadoAuth.falha(String this.erro) : usuario = null;

  bool get ok => usuario != null;
}

/// Cadastro e login salvos localmente no aparelho com SharedPreferences.
/// O enunciado dispensa o Firebase; em um app real, esta classe seria
/// trocada por um serviço de autenticação (ex.: Firebase Auth) e a senha
/// nunca ficaria guardada em texto puro.
class AuthService {
  static const _chaveUsuarios = 'usuarios';
  static const _chaveSessao = 'usuario_logado';

  /// Lê o "banco" de usuários: { email: { nome, senha } }.
  static Map<String, dynamic> _lerUsuarios(SharedPreferences prefs) {
    final texto = prefs.getString(_chaveUsuarios);
    if (texto == null) return {};
    return Map<String, dynamic>.from(jsonDecode(texto) as Map);
  }

  static Future<ResultadoAuth> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = _lerUsuarios(prefs);
    final chave = email.trim().toLowerCase();

    if (usuarios.containsKey(chave)) {
      return const ResultadoAuth.falha('Já existe uma conta com esse e-mail.');
    }

    usuarios[chave] = {'nome': nome.trim(), 'senha': senha};
    await prefs.setString(_chaveUsuarios, jsonEncode(usuarios));
    await prefs.setString(_chaveSessao, chave);
    return ResultadoAuth.sucesso(Usuario(nome: nome.trim(), email: chave));
  }

  static Future<ResultadoAuth> entrar({
    required String email,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final chave = email.trim().toLowerCase();
    final dados = _lerUsuarios(prefs)[chave];

    if (dados == null) {
      return const ResultadoAuth.falha(
          'Conta não encontrada. Crie uma na aba Cadastro.');
    }
    if (dados['senha'] != senha) {
      return const ResultadoAuth.falha('Senha incorreta.');
    }

    await prefs.setString(_chaveSessao, chave);
    return ResultadoAuth.sucesso(
        Usuario(nome: dados['nome'] as String, email: chave));
  }

  /// Retorna o usuário da última sessão, ou null se ninguém estiver logado.
  static Future<Usuario?> usuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final chave = prefs.getString(_chaveSessao);
    if (chave == null) return null;

    final dados = _lerUsuarios(prefs)[chave];
    if (dados == null) return null;
    return Usuario(nome: dados['nome'] as String, email: chave);
  }

  static Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }
}
