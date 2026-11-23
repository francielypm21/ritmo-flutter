import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/usuario.dart';
import 'screens/tela_acesso.dart';
import 'screens/tela_calendario.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

/// Ponto de entrada do app.
/// Antes de desenhar a primeira tela:
/// 1. carrega os nomes de dias e meses em português (usados no calendário);
/// 2. verifica se já existe um usuário logado, para pular o login.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final usuarioLogado = await AuthService.usuarioLogado();
  runApp(RitmoApp(usuarioLogado: usuarioLogado));
}

class RitmoApp extends StatelessWidget {
  final Usuario? usuarioLogado;

  const RitmoApp({super.key, this.usuarioLogado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ritmo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      // Se não houver sessão salva, abre a tela de login/cadastro.
      home: usuarioLogado == null
          ? const TelaAcesso()
          : TelaCalendario(usuario: usuarioLogado!),
    );
  }
}
