// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Happy Pet Dashboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get pets => 'Pets';

  @override
  String get clients => 'Clients';

  @override
  String get appointments => 'Appointments';

  @override
  String get settings => 'Settings';

  @override
  String get overview => 'Overview';

  @override
  String get revenueTrend => 'Revenue Trend';

  @override
  String get petTypes => 'Pet Types';

  @override
  String get general => 'General';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get account => 'Account';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get search => 'Search';

  @override
  String get rowsPerPage => 'Rows per page:';

  @override
  String get textOf => 'of';

  @override
  String get filter => 'Filter';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get editClient => 'Edit Client';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get editPet => 'Edit Pet';

  @override
  String clientLabel(Object name) {
    return 'Client: $name';
  }

  @override
  String get age => 'Age';

  @override
  String get status => 'Status';

  @override
  String get checkupDue => 'Checkup Due';

  @override
  String get healthy => 'Healthy';

  @override
  String get grooming => 'Grooming';

  @override
  String get checkup => 'Checkup';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get completed => 'Completed';

  @override
  String get noClientsFound => 'No clients found';

  @override
  String get pageOutOfBounds => 'Page out of bounds';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get newClient => 'New Client';

  @override
  String get personalData => 'Personal Data';

  @override
  String get fullNameRequired => 'Full Name *';

  @override
  String get requiredField => 'Required field';

  @override
  String get cpf => 'CPF';

  @override
  String get emailRequired => 'Email *';

  @override
  String get primaryPhoneRequired => 'Primary Phone *';

  @override
  String get secondaryPhone => 'Secondary Phone';

  @override
  String get zipCode => 'Zip Code';

  @override
  String get street => 'Street';

  @override
  String get number => 'Number';

  @override
  String get complement => 'Complement';

  @override
  String get neighborhood => 'Neighborhood';

  @override
  String get city => 'City';

  @override
  String get stateAbbr => 'State';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get observations => 'Observations';

  @override
  String get generalNotes => 'General Notes';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteClientMessage => 'Are you sure you want to delete this client?';

  @override
  String get delete => 'Delete';

  @override
  String get noAppointmentsFound => 'No appointments found';

  @override
  String get newAppointment => 'New Appointment';

  @override
  String get editAppointment => 'Edit Appointment';

  @override
  String get noPetsFoundCreateFirst => 'No pets found. Create a pet first.';

  @override
  String get petRequired => 'Pet *';

  @override
  String get selectPet => 'Select a pet';

  @override
  String get titleRequired => 'Title *';

  @override
  String get description => 'Description';

  @override
  String get type => 'Type';

  @override
  String get datePlaceholder => 'Date (dd/mm/yyyy)';

  @override
  String get timePlaceholder => 'Time (HH:mm)';

  @override
  String get internalNotes => 'Internal Notes';

  @override
  String get confirmDeleteAppointmentMessage => 'Are you sure you want to delete this appointment?';
}
