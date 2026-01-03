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

  @override
  String get noClientsFound => 'Nenhum cliente encontrado';

  @override
  String get pageOutOfBounds => 'Página fora dos limites';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get newClient => 'Novo Cliente';

  @override
  String get personalData => 'Dados Pessoais';

  @override
  String get fullNameRequired => 'Nome Completo *';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get cpf => 'CPF';

  @override
  String get emailRequired => 'Email *';

  @override
  String get primaryPhoneRequired => 'Telefone Principal *';

  @override
  String get secondaryPhone => 'Telefone Secundário';

  @override
  String get zipCode => 'CEP';

  @override
  String get street => 'Rua';

  @override
  String get number => 'Número';

  @override
  String get complement => 'Complemento';

  @override
  String get neighborhood => 'Bairro';

  @override
  String get city => 'Cidade';

  @override
  String get stateAbbr => 'UF';

  @override
  String get emergencyContact => 'Contato de Emergência';

  @override
  String get contactName => 'Nome do Contato';

  @override
  String get contactPhone => 'Telefone do Contato';

  @override
  String get observations => 'Observações';

  @override
  String get generalNotes => 'Notas Gerais';

  @override
  String get confirmDelete => 'Confirmar Exclusão';

  @override
  String get confirmDeleteClientMessage => 'Tem certeza que deseja excluir este cliente?';

  @override
  String get delete => 'Excluir';

  @override
  String get noAppointmentsFound => 'Nenhum agendamento encontrado';

  @override
  String get newAppointment => 'Novo Agendamento';

  @override
  String get editAppointment => 'Editar Agendamento';

  @override
  String get noPetsFoundCreateFirst => 'Nenhum pet encontrado. Crie um pet primeiro.';

  @override
  String get petRequired => 'Pet *';

  @override
  String get selectPet => 'Selecione um pet';

  @override
  String get titleRequired => 'Título *';

  @override
  String get description => 'Descrição';

  @override
  String get type => 'Tipo';

  @override
  String get datePlaceholder => 'Data (dd/mm/aaaa)';

  @override
  String get timePlaceholder => 'Hora (HH:mm)';

  @override
  String get internalNotes => 'Notas Internas';

  @override
  String get confirmDeleteAppointmentMessage => 'Tem certeza que deseja excluir este agendamento?';
}
