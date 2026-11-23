import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'botao_gradiente.dart';

/// Abre o diálogo de nova tarefa (showDialog).
/// Devolve o título digitado, ou null se a pessoa cancelar.
Future<String?> mostrarDialogNovaTarefa(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _DialogNovaTarefa(),
  );
}

class _DialogNovaTarefa extends StatefulWidget {
  const _DialogNovaTarefa();

  @override
  State<_DialogNovaTarefa> createState() => _DialogNovaTarefaState();
}

class _DialogNovaTarefaState extends State<_DialogNovaTarefa> {
  final _controller = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final titulo = _controller.text.trim();
    if (titulo.isEmpty) {
      setState(() => _erro = 'Digite o nome da tarefa');
      return;
    }
    Navigator.of(context).pop(titulo);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppCores.superficie,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppCores.gradiente,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_task_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Nova tarefa',
                  style: TextStyle(
                    color: AppCores.texto,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppCores.texto),
              decoration: AppTheme.campo(
                rotulo: 'O que precisa ser feito?',
                icone: Icons.edit_rounded,
                erro: _erro,
              ),
              onChanged: (_) {
                if (_erro != null) setState(() => _erro = null);
              },
              onSubmitted: (_) => _confirmar(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppCores.textoSuave,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BotaoGradiente(
                    texto: 'Adicionar',
                    onPressed: _confirmar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
