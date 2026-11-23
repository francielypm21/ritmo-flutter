import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tarefa.dart';

/// Guarda e organiza as tarefas do usuário logado.
/// Cada usuário tem a própria lista, salva no aparelho como JSON.
class TarefaService {
  final String emailUsuario;
  List<Tarefa> _tarefas = [];

  TarefaService(this.emailUsuario);

  String get _chave => 'tarefas_$emailUsuario';

  /// Remove a hora de uma data, para comparar apenas o dia.
  static DateTime soDia(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null) {
      _tarefas = [];
      return;
    }
    final lista = jsonDecode(texto) as List;
    _tarefas = lista
        .map((item) => Tarefa.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_tarefas.map((t) => t.toJson()).toList());
    await prefs.setString(_chave, json);
  }

  /// Todas as tarefas de um dia, sem ordenação (usado nos marcadores
  /// do calendário).
  List<Tarefa> eventosDoDia(DateTime dia) {
    final alvo = soDia(dia);
    return _tarefas.where((t) => t.data == alvo).toList();
  }

  /// Tarefas de um dia já ordenadas: pendentes primeiro, depois
  /// concluídas, cada grupo em ordem alfabética.
  List<Tarefa> tarefasDoDia(DateTime dia) => ordenar(eventosDoDia(dia));

  static List<Tarefa> ordenar(List<Tarefa> lista) {
    final copia = [...lista];
    copia.sort((a, b) {
      // 1º critério: pendente (false) vem antes de concluída (true).
      if (a.concluida != b.concluida) return a.concluida ? 1 : -1;
      // 2º critério: ordem alfabética, ignorando maiúsculas e acentos.
      final porNome = _normalizar(a.titulo).compareTo(_normalizar(b.titulo));
      return porNome != 0 ? porNome : a.titulo.compareTo(b.titulo);
    });
    return copia;
  }

  /// "Ária" vira "aria", para que acentos e maiúsculas não baguncem
  /// a ordem alfabética.
  static String _normalizar(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
    var resultado = texto.toLowerCase().trim();
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  /// Adiciona uma tarefa nova no dia escolhido (sempre não concluída).
  Future<void> adicionar(String titulo, DateTime dia) async {
    _tarefas.add(Tarefa(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      data: soDia(dia),
    ));
    await _salvar();
  }

  Future<void> remover(String id) async {
    _tarefas.removeWhere((t) => t.id == id);
    await _salvar();
  }

  /// Devolve uma tarefa removida (botão "Desfazer").
  Future<void> restaurar(Tarefa tarefa) async {
    _tarefas.add(tarefa);
    await _salvar();
  }

  /// Marca como concluída ou volta para pendente.
  Future<void> alternarConcluida(String id) async {
    final tarefa = _tarefas.firstWhere((t) => t.id == id);
    tarefa.concluida = !tarefa.concluida;
    await _salvar();
  }
}
