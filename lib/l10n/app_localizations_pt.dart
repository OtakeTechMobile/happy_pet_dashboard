// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Happy Pet Dashboard';

  @override
  String get dashboard => 'Painel';

  @override
  String get pets => 'Pets';

  @override
  String get clients => 'Clientes';

  @override
  String get appointments => 'Agendamentos';

  @override
  String get settings => 'Configurações';

  @override
  String get overview => 'Visão Geral';

  @override
  String get revenueTrend => 'Tendência de Receita';

  @override
  String get petTypes => 'Tipos de Pet';

  @override
  String get general => 'Geral';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificações';

  @override
  String get emailNotifications => 'Notificações por Email';

  @override
  String get pushNotifications => 'Notificações Push';

  @override
  String get account => 'Conta';

  @override
  String get profile => 'Perfil';

  @override
  String get logout => 'Sair';

  @override
  String get search => 'Pesquisar';

  @override
  String get rowsPerPage => 'Linhas por página:';

  @override
  String get textOf => 'de';

  @override
  String get filter => 'Filtro';

  @override
  String get english => 'Inglês';

  @override
  String get portuguese => 'Português';

  @override
  String get editClient => 'Editar Cliente';

  @override
  String get name => 'Nome';

  @override
  String get phone => 'Telefone';

  @override
  String get address => 'Endereço';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get editPet => 'Editar Pet';

  @override
  String clientLabel(Object name) {
    return 'Cliente: $name';
  }

  @override
  String get age => 'Idade';

  @override
  String get status => 'Status';

  @override
  String get checkupDue => 'Check-up Vencido';

  @override
  String get healthy => 'Saudável';

  @override
  String get grooming => 'Banho e Tosa';

  @override
  String get checkup => 'Consulta';

  @override
  String get scheduled => 'Agendado';

  @override
  String get completed => 'Concluído';
}
