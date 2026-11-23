import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/tarefa_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatacao.dart';
import '../widgets/dialog_nova_tarefa.dart';
import '../widgets/fundo_decorado.dart';

/// Lista de tarefas do dia escolhido no calendário.
/// Pendentes aparecem primeiro e concluídas depois, ambas em ordem
/// alfabética (a ordenação fica no TarefaService).
class TelaTarefas extends StatefulWidget {
  final TarefaService servico;
  final DateTime dia;

  const TelaTarefas({super.key, required this.servico, required this.dia});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  Future<void> _adicionar() async {
    final titulo = await mostrarDialogNovaTarefa(context);
    if (titulo == null || titulo.trim().isEmpty) return;
    await widget.servico.adicionar(titulo, widget.dia);
    if (mounted) setState(() {});
  }

  Future<void> _alternar(Tarefa tarefa) async {
    final salvando = widget.servico.alternarConcluida(tarefa.id);
    setState(() {});
    await salvando;
  }

  Future<void> _remover(Tarefa tarefa) async {
    // A tarefa sai da lista na hora; o salvamento termina em seguida.
    final salvando = widget.servico.remover(tarefa.id);
    setState(() {});
    await salvando;
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppCores.superficieClara,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            '"${tarefa.titulo}" removida',
            style: const TextStyle(color: AppCores.texto),
          ),
          action: SnackBarAction(
            label: 'DESFAZER',
            textColor: AppCores.limao,
            onPressed: () async {
              await widget.servico.restaurar(tarefa);
              if (mounted) setState(() {});
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final tarefas = widget.servico.tarefasDoDia(widget.dia);
    final pendentes = tarefas.where((t) => !t.concluida).toList();
    final concluidas = tarefas.where((t) => t.concluida).toList();

    return Scaffold(
      floatingActionButton: _BotaoAdicionar(onPressed: _adicionar),
      body: FundoDecorado(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _barraTopo(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _CartaoProgresso(
                  dia: widget.dia,
                  total: tarefas.length,
                  concluidas: concluidas.length,
                ),
              ),
              Expanded(
                child: tarefas.isEmpty
                    ? const _ListaVazia()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                        children: [
                          if (pendentes.isNotEmpty) ...[
                            _TituloSecao(
                              texto: 'Pendentes',
                              quantidade: pendentes.length,
                              cor: AppCores.laranja,
                            ),
                            ...pendentes.map(_item),
                          ],
                          if (concluidas.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _TituloSecao(
                              texto: 'Concluídas',
                              quantidade: concluidas.length,
                              cor: AppCores.limao,
                            ),
                            ...concluidas.map(_item),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barraTopo() {
    return Row(
      children: [
        Material(
          color: AppCores.superficie,
          borderRadius: BorderRadius.circular(16),
          child: IconButton(
            tooltip: 'Voltar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppCores.texto),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Tarefas do dia',
          style: TextStyle(
            color: AppCores.texto,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  /// Cada tarefa pode ser arrastada para a esquerda para remover.
  Widget _item(Tarefa tarefa) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(tarefa.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _remover(tarefa),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppCores.magenta,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        child: _CartaoTarefa(
          tarefa: tarefa,
          aoAlternar: () => _alternar(tarefa),
          aoRemover: () => _remover(tarefa),
        ),
      ),
    );
  }
}

class _CartaoProgresso extends StatelessWidget {
  final DateTime dia;
  final int total;
  final int concluidas;

  const _CartaoProgresso({
    required this.dia,
    required this.total,
    required this.concluidas,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = total == 0 ? 0.0 : concluidas / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppCores.gradiente,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55FF2E93),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataPorExtenso(dia),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            total == 0
                ? 'Nenhuma tarefa ainda'
                : '$concluidas de $total concluídas',
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 10,
              backgroundColor: const Color(0x40000000),
              valueColor: const AlwaysStoppedAnimation(AppCores.limao),
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  final String texto;
  final int quantidade;
  final Color cor;

  const _TituloSecao({
    required this.texto,
    required this.quantidade,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Text(
            texto.toUpperCase(),
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$quantidade',
              style: const TextStyle(
                color: AppCores.fundo,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoTarefa extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback aoAlternar;
  final VoidCallback aoRemover;

  const _CartaoTarefa({
    required this.tarefa,
    required this.aoAlternar,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final concluida = tarefa.concluida;
    final corDestaque = concluida ? AppCores.limao : AppCores.laranja;

    return Material(
      color: AppCores.superficie,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoAlternar,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: corDestaque, width: 5)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              // Marcador redondo: vazio = pendente, cheio = concluída.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: concluida ? AppCores.limao : Colors.transparent,
                  border: Border.all(color: corDestaque, width: 2.5),
                ),
                child: concluida
                    ? const Icon(Icons.check_rounded,
                        size: 20, color: AppCores.fundo)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  tarefa.titulo,
                  style: TextStyle(
                    color: concluida ? AppCores.textoSuave : AppCores.texto,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: concluida
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppCores.textoSuave,
                    decorationThickness: 2,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remover',
                onPressed: aoRemover,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppCores.textoSuave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny_rounded, size: 64, color: AppCores.laranja),
            SizedBox(height: 16),
            Text(
              'Dia livre por enquanto',
              style: TextStyle(
                color: AppCores.texto,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Toque no + para adicionar a primeira tarefa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppCores.textoSuave),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoAdicionar extends StatelessWidget {
  final VoidCallback onPressed;

  const _BotaoAdicionar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppCores.gradiente,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88FF2E93),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: const SizedBox(
            width: 66,
            height: 66,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }
}
