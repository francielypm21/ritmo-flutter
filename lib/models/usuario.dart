/// Representa a pessoa logada no app.
class Usuario {
  final String nome;
  final String email;

  const Usuario({required this.nome, required this.email});

  /// Primeiro nome, usado na saudação do calendário.
  String get primeiroNome => nome.trim().split(' ').first;
}
