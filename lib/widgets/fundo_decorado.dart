import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fundo escuro com "manchas" de luz coloridas atrás do conteúdo.
class FundoDecorado extends StatelessWidget {
  final Widget child;

  const FundoDecorado({super.key, required this.child});

  Widget _mancha(Color cor, double tamanho) => Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [cor, cor.withAlpha(0)]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppCores.fundo,
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _mancha(const Color(0x88FF2E93), 320),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _mancha(const Color(0x777B2FFF), 360),
          ),
          Positioned(
            top: 260,
            left: -60,
            child: _mancha(const Color(0x33FF8A00), 200),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
