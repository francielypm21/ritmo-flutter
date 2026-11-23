import 'package:intl/intl.dart';

String capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// Ex.: "Segunda-feira, 23 de novembro"
String dataPorExtenso(DateTime data) =>
    capitalizar(DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(data));
