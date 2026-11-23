import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/tarefa_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatacao.dart';
import '../widgets/botao_gradiente.dart';
import '../widgets/fundo_decorado.dart';
import 'tela_acesso.dart';
import 'tela_tarefas.dart';

/// Calendário mensal. Cada dia com tarefas ganha um pontinho:
/// laranja = ainda tem pendentes, verde-limão = tudo concluído.
class TelaCalendario extends StatefulWidget {
  final Usuario usuario;

  const TelaCalendario({super.key, required this.usuario});

  @override
  State<TelaCalendario> createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  late final TarefaService _servico;
  DateTime _diaFocado = DateTime.now();
  DateTime _diaSelecionado = TarefaService.soDia(DateTime.now());
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _servico = TarefaService(widget.usuario.email);
    _carregar();
  }

  Future<void> _carregar() async {
    await _servico.carregar();
    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _abrirTarefas() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TelaTarefas(servico: _servico, dia: _diaSelecionado),
      ),
    );
    // Ao voltar, redesenha para atualizar os marcadores e o resumo.
    if (mounted) setState(() {});
  }

  Future<void> _sair() async {
    await AuthService.sair();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TelaAcesso()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoDecorado(
        child: SafeArea(
          child: _carregando
              ? const Center(
                  child: CircularProgressIndicator(color: AppCores.magenta),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _cabecalho(),
                    const SizedBox(height: 24),
                    _calendario(),
                    const SizedBox(height: 16),
                    _legenda(),
                    const SizedBox(height: 20),
                    _resumoDoDia(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${widget.usuario.primeiroNome}',
                style: const TextStyle(
                  color: AppCores.textoSuave,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Seu calendário',
                style: TextStyle(
                  color: AppCores.texto,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppCores.superficie,
          borderRadius: BorderRadius.circular(16),
          child: IconButton(
            tooltip: 'Sair',
            onPressed: _sair,
            icon: const Icon(Icons.logout_rounded, color: AppCores.magenta),
          ),
        ),
      ],
    );
  }

  Widget _calendario() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: TableCalendar<Tarefa>(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _diaFocado,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
        rowHeight: 48,
        daysOfWeekHeight: 28,
        selectedDayPredicate: (dia) => isSameDay(dia, _diaSelecionado),
        onDaySelected: (selecionado, focado) {
          setState(() {
            _diaSelecionado = TarefaService.soDia(selecionado);
            _diaFocado = focado;
          });
        },
        onPageChanged: (focado) => _diaFocado = focado,
        // Diz ao calendário quais tarefas existem em cada dia.
        eventLoader: _servico.eventosDoDia,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (data, locale) =>
              capitalizar(DateFormat.yMMMM(locale).format(data)),
          titleTextStyle: const TextStyle(
            color: AppCores.texto,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          leftChevronIcon:
              const Icon(Icons.chevron_left_rounded, color: AppCores.limao),
          rightChevronIcon:
              const Icon(Icons.chevron_right_rounded, color: AppCores.limao),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          // "dom." -> "D", "seg." -> "S" ...
          dowTextFormatter: (data, locale) =>
              DateFormat.E(locale).format(data)[0].toUpperCase(),
          weekdayStyle: const TextStyle(
            color: AppCores.textoSuave,
            fontWeight: FontWeight.w800,
          ),
          weekendStyle: const TextStyle(
            color: AppCores.magenta,
            fontWeight: FontWeight.w800,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(
            color: AppCores.texto,
            fontWeight: FontWeight.w600,
          ),
          weekendTextStyle: const TextStyle(
            color: Color(0xFFFF7DBA),
            fontWeight: FontWeight.w600,
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppCores.limao, width: 2),
          ),
          todayTextStyle: const TextStyle(
            color: AppCores.limao,
            fontWeight: FontWeight.w900,
          ),
          selectedDecoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppCores.gradiente,
            boxShadow: [BoxShadow(color: Color(0x88FF2E93), blurRadius: 14)],
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        calendarBuilders: CalendarBuilders<Tarefa>(
          markerBuilder: (context, dia, eventos) {
            if (eventos.isEmpty) return null;
            final temPendente = eventos.any((t) => !t.concluida);
            return Positioned(
              bottom: 5,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: temPendente ? AppCores.laranja : AppCores.limao,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _legenda() {
    Widget item(Color cor, String texto) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(texto,
                style:
                    const TextStyle(color: AppCores.textoSuave, fontSize: 13)),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        item(AppCores.laranja, 'Com pendências'),
        const SizedBox(width: 20),
        item(AppCores.limao, 'Tudo concluído'),
      ],
    );
  }

  Widget _resumoDoDia() {
    final tarefas = _servico.eventosDoDia(_diaSelecionado);
    final pendentes = tarefas.where((t) => !t.concluida).length;
    final concluidas = tarefas.length - pendentes;

    Widget contador(String rotulo, int valor, Color cor) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppCores.superficieClara,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$valor',
                  style: TextStyle(
                    color: cor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(rotulo,
                    style: const TextStyle(color: AppCores.textoSuave)),
              ],
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dataPorExtenso(_diaSelecionado),
            style: const TextStyle(
              color: AppCores.texto,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              contador('pendentes', pendentes, AppCores.laranja),
              const SizedBox(width: 12),
              contador('concluídas', concluidas, AppCores.limao),
            ],
          ),
          const SizedBox(height: 18),
          BotaoGradiente(
            texto: 'Ver tarefas do dia',
            icone: Icons.checklist_rounded,
            onPressed: _abrirTarefas,
          ),
        ],
      ),
    );
  }
}
