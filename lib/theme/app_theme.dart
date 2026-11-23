import 'package:flutter/material.dart';

/// Paleta do app: fundo escuro com destaques vibrantes
/// (magenta, laranja e verde-limão).
class AppCores {
  static const fundo = Color(0xFF0F0B1E);
  static const superficie = Color(0xFF1C1633);
  static const superficieClara = Color(0xFF2A2248);
  static const magenta = Color(0xFFFF2E93);
  static const laranja = Color(0xFFFF8A00);
  static const limao = Color(0xFFC6FF00);
  static const violeta = Color(0xFF7B2FFF);
  static const texto = Colors.white;
  static const textoSuave = Color(0xFFB7AFCF);

  /// Gradiente principal, usado em botões e destaques.
  static const gradiente = LinearGradient(
    colors: [magenta, laranja],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get tema => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppCores.fundo,
        colorScheme: const ColorScheme.dark(
          primary: AppCores.magenta,
          secondary: AppCores.limao,
          surface: AppCores.superficie,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppCores.limao,
          selectionColor: Color(0x55C6FF00),
          selectionHandleColor: AppCores.limao,
        ),
      );

  /// Estilo padrão dos campos de texto (login, cadastro e nova tarefa).
  static InputDecoration campo({
    required String rotulo,
    IconData? icone,
    Widget? sufixo,
    String? erro,
  }) {
    OutlineInputBorder borda(Color cor, double largura) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return InputDecoration(
      labelText: rotulo,
      errorText: erro,
      filled: true,
      fillColor: AppCores.superficieClara,
      labelStyle: const TextStyle(color: AppCores.textoSuave),
      floatingLabelStyle: const TextStyle(
        color: AppCores.limao,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: icone == null
          ? null
          : Icon(icone, color: AppCores.textoSuave),
      suffixIcon: sufixo,
      counterStyle: const TextStyle(color: AppCores.textoSuave),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: borda(Colors.transparent, 0),
      enabledBorder: borda(Colors.transparent, 0),
      focusedBorder: borda(AppCores.limao, 2),
      errorBorder: borda(AppCores.magenta, 1.5),
      focusedErrorBorder: borda(AppCores.magenta, 2),
      errorStyle: const TextStyle(color: AppCores.magenta),
    );
  }
}
