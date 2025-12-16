/// User role enum matching database
enum UserRole {
  admin,
  owner,
  staff,
  tutor;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.owner:
        return 'Owner';
      case UserRole.staff:
        return 'Staff';
      case UserRole.tutor:
        return 'Tutor';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere((role) => role.name == value.toLowerCase(), orElse: () => UserRole.staff);
  }
}

/// Stay status enum
enum StayStatus {
  scheduled,
  checkedIn,
  checkedOut,
  cancelled;

  String get displayName {
    switch (this) {
      case StayStatus.scheduled:
        return 'Scheduled';
      case StayStatus.checkedIn:
        return 'Checked In';
      case StayStatus.checkedOut:
        return 'Checked Out';
      case StayStatus.cancelled:
        return 'Cancelled';
    }
  }

  static StayStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'checked_in':
        return StayStatus.checkedIn;
      case 'checked_out':
        return StayStatus.checkedOut;
      case 'cancelled':
        return StayStatus.cancelled;
      default:
        return StayStatus.scheduled;
    }
  }

  String toDbString() {
    switch (this) {
      case StayStatus.checkedIn:
        return 'checked_in';
      case StayStatus.checkedOut:
        return 'checked_out';
      case StayStatus.cancelled:
        return 'cancelled';
      default:
        return 'scheduled';
    }
  }
}

/// Routine type enum
enum RoutineType {
  feeding,
  medication,
  exercise,
  grooming,
  other;

  String get displayName {
    switch (this) {
      case RoutineType.feeding:
        return 'Feeding';
      case RoutineType.medication:
        return 'Medication';
      case RoutineType.exercise:
        return 'Exercise';
      case RoutineType.grooming:
        return 'Grooming';
      case RoutineType.other:
        return 'Other';
    }
  }

  static RoutineType fromString(String value) {
    return RoutineType.values.firstWhere((type) => type.name == value.toLowerCase(), orElse: () => RoutineType.other);
  }
}

/// Routine status enum
enum RoutineStatus {
  scheduled,
  pending,
  inProgress,
  completed,
  skipped;

  String get displayName {
    switch (this) {
      case RoutineStatus.scheduled:
        return 'Scheduled';
      case RoutineStatus.pending:
        return 'Pending';
      case RoutineStatus.inProgress:
        return 'In Progress';
      case RoutineStatus.completed:
        return 'Completed';
      case RoutineStatus.skipped:
        return 'Skipped';
    }
  }

  static RoutineStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'scheduled':
        return RoutineStatus.scheduled;
      case 'in_progress':
        return RoutineStatus.inProgress;
      case 'completed':
        return RoutineStatus.completed;
      case 'skipped':
        return RoutineStatus.skipped;
      default:
        return RoutineStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case RoutineStatus.scheduled:
        return 'scheduled';
      case RoutineStatus.inProgress:
        return 'in_progress';
      case RoutineStatus.completed:
        return 'completed';
      case RoutineStatus.skipped:
        return 'skipped';
      default:
        return 'pending';
    }
  }
}

/// Attendance status enum
enum AttendanceStatus {
  present,
  absent,
  late,
  earlyDeparture;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.earlyDeparture:
        return 'Early Departure';
    }
  }

  static AttendanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'early_departure':
        return AttendanceStatus.earlyDeparture;
      default:
        return AttendanceStatus.present;
    }
  }

  String toDbString() {
    switch (this) {
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.earlyDeparture:
        return 'early_departure';
      default:
        return 'present';
    }
  }
}

/// Invoice status enum
enum InvoiceStatus {
  draft,
  pending,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  static InvoiceStatus fromString(String value) {
    return InvoiceStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => InvoiceStatus.draft,
    );
  }
}

/// Payment method enum
enum PaymentMethod {
  card,
  pix,
  boleto,
  cash,
  transfer;

  String get displayName {
    switch (this) {
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.boleto:
        return 'Boleto';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.transfer:
        return 'Bank Transfer';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value.toLowerCase(),
      orElse: () => PaymentMethod.card,
    );
  }
}
