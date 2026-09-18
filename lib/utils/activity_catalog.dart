/// Mirrors backend com.antigravity.mes.web.ActivityCatalog - keep in sync.
class ActivityDefinition {
  final String code;
  final String label;

  const ActivityDefinition(this.code, this.label);
}

class ActivityCatalog {
  static const List<ActivityDefinition> all = [
    ActivityDefinition('SPLASH', 'Splash Screen'),
    ActivityDefinition('LOGIN', 'Login Screen'),
    ActivityDefinition('DASHBOARD', 'Dashboard'),
    ActivityDefinition('PROFILE', 'Profile'),
    ActivityDefinition('EMPLOYEE_LIST', 'User Management - List'),
    ActivityDefinition('EMPLOYEE_DETAIL', 'User Management - Detail'),
    ActivityDefinition('EMPLOYEE_FORM', 'User Management - Add/Edit'),
    ActivityDefinition('ROLE_LIST', 'Role Management - List'),
    ActivityDefinition('ROLE_FORM', 'Role Management - Add/Edit'),
    ActivityDefinition('ATTENDANCE', 'Attendance (HRMS)'),
    ActivityDefinition('STATION_LIST', 'Stations / SAM - List'),
    ActivityDefinition('STATION_FORM', 'Stations / SAM - Add/Edit'),
    ActivityDefinition('OPERATIONS', 'Operations (Allocation/Stock/Production/WIP)'),
    ActivityDefinition('PRODUCTION_SCAN', 'Scan Production Books'),
    ActivityDefinition('MY_PRODUCTION', 'My Production (Operator)'),
    ActivityDefinition('REPORTS', 'AI Production Reports'),
    ActivityDefinition('PAYROLL', 'Salary Payroll Sheet'),
  ];
}
