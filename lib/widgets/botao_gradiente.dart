import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botão principal do app, com o gradiente magenta → laranja.
class BotaoGradiente extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;
  final IconData? icone;

  const BotaoGradiente({
    super.key,
    required this.texto,
    this.onPressed,
    this.carregando = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppCores.gradiente,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55FF2E93),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: carregando ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
            child: Center(
              child: carregando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icone != null) ...[
                          Icon(icone, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          texto.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
