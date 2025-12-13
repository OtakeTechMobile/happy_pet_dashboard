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
}
