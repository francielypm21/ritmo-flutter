/// Uma tarefa de um dia específico.
/// Toda tarefa nasce como não concluída (concluida = false).
class Tarefa {
  final String id;
  final String titulo;

  /// Dia da tarefa, sem hora (ex.: 23/11/2026 00:00).
  final DateTime data;
  bool concluida;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.data,
    this.concluida = false,
  });

  /// Converte a tarefa em um Map para salvar como JSON no aparelho.
  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'data': data.toIso8601String(),
        'concluida': concluida,
      };

  /// Recria a tarefa a partir do JSON salvo.
  factory Tarefa.fromJson(Map<String, dynamic> json) => Tarefa(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        data: DateTime.parse(json['data'] as String),
        concluida: json['concluida'] as bool? ?? false,
      );
}
