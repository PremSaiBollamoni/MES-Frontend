import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// No description provided for @aProductOf.
  ///
  /// In en, this message translates to:
  /// **'A product of'**
  String get aProductOf;

  /// No description provided for @aUsernameMesWillBe.
  ///
  /// In en, this message translates to:
  /// **'A username (MES...) will be generated automatically on save.'**
  String get aUsernameMesWillBe;

  /// No description provided for @aiProductionReport.
  ///
  /// In en, this message translates to:
  /// **'AI Production Report'**
  String get aiProductionReport;

  /// No description provided for @aiReports.
  ///
  /// In en, this message translates to:
  /// **'AI Reports'**
  String get aiReports;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @accessibleActivities.
  ///
  /// In en, this message translates to:
  /// **'Accessible Activities'**
  String get accessibleActivities;

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Account & Role'**
  String get accountRole;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeBundles.
  ///
  /// In en, this message translates to:
  /// **'Active Bundles'**
  String get activeBundles;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @actualSam.
  ///
  /// In en, this message translates to:
  /// **'Actual SAM'**
  String get actualSam;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @addRole.
  ///
  /// In en, this message translates to:
  /// **'Add Role'**
  String get addRole;

  /// No description provided for @addStation.
  ///
  /// In en, this message translates to:
  /// **'Add Station'**
  String get addStation;

  /// No description provided for @additions.
  ///
  /// In en, this message translates to:
  /// **'Additions'**
  String get additions;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @allZones.
  ///
  /// In en, this message translates to:
  /// **'All Zones'**
  String get allZones;

  /// No description provided for @allStationsCovered.
  ///
  /// In en, this message translates to:
  /// **'All stations covered'**
  String get allStationsCovered;

  /// No description provided for @alreadyHere.
  ///
  /// In en, this message translates to:
  /// **'Already here'**
  String get alreadyHere;

  /// No description provided for @anEmployeeCanHoldMore.
  ///
  /// In en, this message translates to:
  /// **'An employee can hold more than one role. Select every role this person should be able to sign in as.'**
  String get anEmployeeCanHoldMore;

  /// No description provided for @assignStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Assign & Start Tracking'**
  String get assignStartTracking;

  /// No description provided for @assignRoles.
  ///
  /// In en, this message translates to:
  /// **'Assign Roles'**
  String get assignRoles;

  /// No description provided for @assignOperatorsToStationsFor.
  ///
  /// In en, this message translates to:
  /// **'Assign operators to stations for the shift'**
  String get assignOperatorsToStationsFor;

  /// No description provided for @assignOperatorsToStationsTo.
  ///
  /// In en, this message translates to:
  /// **'Assign operators to stations to see them here.'**
  String get assignOperatorsToStationsTo;

  /// No description provided for @atLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Characters;

  /// No description provided for @attendanceReport.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get attendanceReport;

  /// No description provided for @avgEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Avg Efficiency'**
  String get avgEfficiency;

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get bestDay;

  /// No description provided for @biometricHrms.
  ///
  /// In en, this message translates to:
  /// **'Biometric (HRMS)'**
  String get biometricHrms;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @bundleReference.
  ///
  /// In en, this message translates to:
  /// **'Bundle Reference'**
  String get bundleReference;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @chooseAView.
  ///
  /// In en, this message translates to:
  /// **'Choose a view'**
  String get chooseAView;

  /// No description provided for @chooseWhichRoleToUse.
  ///
  /// In en, this message translates to:
  /// **'Choose which role to use for this session.'**
  String get chooseWhichRoleToUse;

  /// No description provided for @claudeGeneratedAnalyticsReportsExported.
  ///
  /// In en, this message translates to:
  /// **'Claude-generated analytics reports, exported as PDF.'**
  String get claudeGeneratedAnalyticsReportsExported;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @compositionByDepartment.
  ///
  /// In en, this message translates to:
  /// **'Composition by department'**
  String get compositionByDepartment;

  /// No description provided for @compositionByRole.
  ///
  /// In en, this message translates to:
  /// **'Composition by role'**
  String get compositionByRole;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @connectionOffline.
  ///
  /// In en, this message translates to:
  /// **'Connection offline'**
  String get connectionOffline;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @couldnTLoadWipData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load WIP data'**
  String get couldnTLoadWipData;

  /// No description provided for @couldnTLoadAttendance.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load attendance'**
  String get couldnTLoadAttendance;

  /// No description provided for @couldnTLoadEmployees.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load employees'**
  String get couldnTLoadEmployees;

  /// No description provided for @couldnTLoadOperators.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load operators'**
  String get couldnTLoadOperators;

  /// No description provided for @couldnTLoadProductionEntries.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load production entries'**
  String get couldnTLoadProductionEntries;

  /// No description provided for @couldnTLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load reports'**
  String get couldnTLoadReports;

  /// No description provided for @couldnTLoadStationStatus.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load station status'**
  String get couldnTLoadStationStatus;

  /// No description provided for @couldnTLoadStations.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load stations'**
  String get couldnTLoadStations;

  /// No description provided for @couldnTLoadStockAvailability.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load stock availability'**
  String get couldnTLoadStockAvailability;

  /// No description provided for @couldnTLoadStockPosition.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load stock position'**
  String get couldnTLoadStockPosition;

  /// No description provided for @couldnTLoadThatDay.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load that day'**
  String get couldnTLoadThatDay;

  /// No description provided for @couldnTLoadThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this month'**
  String get couldnTLoadThisMonth;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createBundle.
  ///
  /// In en, this message translates to:
  /// **'Create Bundle'**
  String get createBundle;

  /// No description provided for @createEmployee.
  ///
  /// In en, this message translates to:
  /// **'Create Employee'**
  String get createEmployee;

  /// No description provided for @createRole.
  ///
  /// In en, this message translates to:
  /// **'Create Role'**
  String get createRole;

  /// No description provided for @createStation.
  ///
  /// In en, this message translates to:
  /// **'Create Station'**
  String get createStation;

  /// No description provided for @createAStationInStation.
  ///
  /// In en, this message translates to:
  /// **'Create a station in Station Management before allocating operators.'**
  String get createAStationInStation;

  /// No description provided for @createBundlesMoveBetweenStations.
  ///
  /// In en, this message translates to:
  /// **'Create bundles, move between stations, track queues'**
  String get createBundlesMoveBetweenStations;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentStockOnHand.
  ///
  /// In en, this message translates to:
  /// **'Current stock on hand'**
  String get currentStockOnHand;

  /// No description provided for @dailyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Daily Attendance'**
  String get dailyAttendance;

  /// No description provided for @dailyStockPosition.
  ///
  /// In en, this message translates to:
  /// **'Daily Stock Position'**
  String get dailyStockPosition;

  /// No description provided for @dailyAttendanceRegisterLatenessAnd.
  ///
  /// In en, this message translates to:
  /// **'Daily attendance register, lateness and manning gaps'**
  String get dailyAttendanceRegisterLatenessAnd;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfJoining.
  ///
  /// In en, this message translates to:
  /// **'Date of Joining'**
  String get dateOfJoining;

  /// No description provided for @deactivateEmployee.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Employee'**
  String get deactivateEmployee;

  /// No description provided for @defaultDepartmentOptional.
  ///
  /// In en, this message translates to:
  /// **'Default Department (optional)'**
  String get defaultDepartmentOptional;

  /// No description provided for @defaultRole.
  ///
  /// In en, this message translates to:
  /// **'Default Role'**
  String get defaultRole;

  /// No description provided for @defectLoggingAndQcVerification.
  ///
  /// In en, this message translates to:
  /// **'Defect logging and QC verification will appear here once the QC module goes live.'**
  String get defectLoggingAndQcVerification;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteEmployee.
  ///
  /// In en, this message translates to:
  /// **'Delete Employee'**
  String get deleteEmployee;

  /// No description provided for @deleteRole.
  ///
  /// In en, this message translates to:
  /// **'Delete Role'**
  String get deleteRole;

  /// No description provided for @deleteStation.
  ///
  /// In en, this message translates to:
  /// **'Delete Station'**
  String get deleteStation;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @deviceUserId.
  ///
  /// In en, this message translates to:
  /// **'Device User ID'**
  String get deviceUserId;

  /// No description provided for @dispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get dispatched;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit Employee'**
  String get editEmployee;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editRole.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get editRole;

  /// No description provided for @editStation.
  ///
  /// In en, this message translates to:
  /// **'Edit Station'**
  String get editStation;

  /// No description provided for @efficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get efficiency;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get elapsedTime;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @emergencyContactName.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Name'**
  String get emergencyContactName;

  /// No description provided for @emergencyContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Number'**
  String get emergencyContactNumber;

  /// No description provided for @emergencyNumber.
  ///
  /// In en, this message translates to:
  /// **'Emergency Number'**
  String get emergencyNumber;

  /// No description provided for @employeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get employeeCode;

  /// No description provided for @employeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Employee Details'**
  String get employeeDetails;

  /// No description provided for @employeeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Employee added successfully'**
  String get employeeAddedSuccessfully;

  /// No description provided for @employeeCodeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Employee code is required'**
  String get employeeCodeIsRequired;

  /// No description provided for @employeeDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Employee deactivated'**
  String get employeeDeactivated;

  /// No description provided for @employeeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Employee deleted'**
  String get employeeDeleted;

  /// No description provided for @employeeReactivated.
  ///
  /// In en, this message translates to:
  /// **'Employee reactivated'**
  String get employeeReactivated;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @endTimeMustBeAfter.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeMustBeAfter;

  /// No description provided for @enterAValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterAValidNumber;

  /// No description provided for @enterAValidWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid whole number'**
  String get enterAValidWholeNumber;

  /// No description provided for @enterAWholeNumberGreater.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number greater than zero'**
  String get enterAWholeNumberGreater;

  /// No description provided for @enterAWholeNumberZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, zero or more'**
  String get enterAWholeNumberZero;

  /// No description provided for @enterValidWholeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Enter valid whole numbers'**
  String get enterValidWholeNumbers;

  /// No description provided for @estWagePerOperator.
  ///
  /// In en, this message translates to:
  /// **'Est. Wage (per operator)'**
  String get estWagePerOperator;

  /// No description provided for @estWageTeamTotal.
  ///
  /// In en, this message translates to:
  /// **'Est. Wage (team total)'**
  String get estWageTeamTotal;

  /// No description provided for @estWages.
  ///
  /// In en, this message translates to:
  /// **'Est. Wages'**
  String get estWages;

  /// No description provided for @everyHrmsEmployeeIsAlready.
  ///
  /// In en, this message translates to:
  /// **'Every HRMS employee is already linked to a record in this app.'**
  String get everyHrmsEmployeeIsAlready;

  /// No description provided for @everyPresentOperatorIsAlready.
  ///
  /// In en, this message translates to:
  /// **'Every present operator is already tracking elsewhere for this shift date.'**
  String get everyPresentOperatorIsAlready;

  /// No description provided for @everythingSInSync.
  ///
  /// In en, this message translates to:
  /// **'Everything\'s in sync'**
  String get everythingSInSync;

  /// No description provided for @exception.
  ///
  /// In en, this message translates to:
  /// **'Exception:'**
  String get exception;

  /// No description provided for @exportsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Exports & analytics'**
  String get exportsAnalytics;

  /// No description provided for @facePhotoEnrolledInHrms.
  ///
  /// In en, this message translates to:
  /// **'Face photo enrolled in HRMS'**
  String get facePhotoEnrolledInHrms;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @fillInEveryFieldWith.
  ///
  /// In en, this message translates to:
  /// **'Fill in every field with valid values'**
  String get fillInEveryFieldWith;

  /// No description provided for @fingerprintAndRfidStillRequire.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint and RFID still require physical enrollment on the device itself.'**
  String get fingerprintAndRfidStillRequire;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullWorkerRankingTopLowest.
  ///
  /// In en, this message translates to:
  /// **'Full worker ranking, top/lowest performers and recommendations'**
  String get fullWorkerRankingTopLowest;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @generateYourFirstAttendanceReport.
  ///
  /// In en, this message translates to:
  /// **'Generate your first attendance report using the button above.'**
  String get generateYourFirstAttendanceReport;

  /// No description provided for @generateYourFirstDailyProduction.
  ///
  /// In en, this message translates to:
  /// **'Generate your first daily production report using the button above.'**
  String get generateYourFirstDailyProduction;

  /// No description provided for @generateYourFirstStationWise.
  ///
  /// In en, this message translates to:
  /// **'Generate your first station-wise stock report using the button above.'**
  String get generateYourFirstStationWise;

  /// No description provided for @generateYourFirstWorkerPerformance.
  ///
  /// In en, this message translates to:
  /// **'Generate your first worker performance report using the button above.'**
  String get generateYourFirstWorkerPerformance;

  /// No description provided for @generatingAiReportThisCan.
  ///
  /// In en, this message translates to:
  /// **'Generating AI report - this can take a minute...'**
  String get generatingAiReportThisCan;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @highestSamRanked.
  ///
  /// In en, this message translates to:
  /// **'HIGHEST SAM, RANKED'**
  String get highestSamRanked;

  /// No description provided for @hrmsCode.
  ///
  /// In en, this message translates to:
  /// **'HRMS Code'**
  String get hrmsCode;

  /// No description provided for @hrmsNotConnectedYet.
  ///
  /// In en, this message translates to:
  /// **'HRMS not connected yet'**
  String get hrmsNotConnectedYet;

  /// No description provided for @highestSamBottleneck.
  ///
  /// In en, this message translates to:
  /// **'Highest SAM = Bottleneck'**
  String get highestSamBottleneck;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgress;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importFromHrms.
  ///
  /// In en, this message translates to:
  /// **'Import from HRMS'**
  String get importFromHrms;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @initialStation.
  ///
  /// In en, this message translates to:
  /// **'Initial Station'**
  String get initialStation;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @leaveBlankToKeepEach.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep each employee\'s HRMS department'**
  String get leaveBlankToKeepEach;

  /// No description provided for @liveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Live Attendance'**
  String get liveAttendance;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @liveMannedUnmannedBoardWith.
  ///
  /// In en, this message translates to:
  /// **'Live manned / unmanned board with bottleneck alerts'**
  String get liveMannedUnmannedBoardWith;

  /// No description provided for @logEntry.
  ///
  /// In en, this message translates to:
  /// **'Log Entry'**
  String get logEntry;

  /// No description provided for @logProduction.
  ///
  /// In en, this message translates to:
  /// **'Log Production'**
  String get logProduction;

  /// No description provided for @logStock.
  ///
  /// In en, this message translates to:
  /// **'Log Stock'**
  String get logStock;

  /// No description provided for @logPiecesProducedOnBehalf.
  ///
  /// In en, this message translates to:
  /// **'Log pieces produced on behalf of an operator'**
  String get logPiecesProducedOnBehalf;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @maximumStockThresholdOptional0.
  ///
  /// In en, this message translates to:
  /// **'Maximum Stock Threshold (optional, 0 = no ceiling)'**
  String get maximumStockThresholdOptional0;

  /// No description provided for @minimumStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock Threshold'**
  String get minimumStockThreshold;

  /// No description provided for @monthlyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Monthly Attendance'**
  String get monthlyAttendance;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @moveBundle.
  ///
  /// In en, this message translates to:
  /// **'Move Bundle'**
  String get moveBundle;

  /// No description provided for @moveSomeBundlesToSee.
  ///
  /// In en, this message translates to:
  /// **'Move some bundles to see station queues here.'**
  String get moveSomeBundlesToSee;

  /// No description provided for @moveToStation.
  ///
  /// In en, this message translates to:
  /// **'Move to Station'**
  String get moveToStation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordLeaveBlankTo.
  ///
  /// In en, this message translates to:
  /// **'New Password (leave blank to keep unchanged)'**
  String get newPasswordLeaveBlankTo;

  /// No description provided for @noActiveBundles.
  ///
  /// In en, this message translates to:
  /// **'No active bundles'**
  String get noActiveBundles;

  /// No description provided for @noActiveStations.
  ///
  /// In en, this message translates to:
  /// **'No active stations'**
  String get noActiveStations;

  /// No description provided for @noActivityForThisDay.
  ///
  /// In en, this message translates to:
  /// **'No activity for this day'**
  String get noActivityForThisDay;

  /// No description provided for @noActivityLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No activity logged yet'**
  String get noActivityLoggedYet;

  /// No description provided for @noAvailableOperators.
  ///
  /// In en, this message translates to:
  /// **'No available operators'**
  String get noAvailableOperators;

  /// No description provided for @noEmployeesMatchYourSearch.
  ///
  /// In en, this message translates to:
  /// **'No employees match your search'**
  String get noEmployeesMatchYourSearch;

  /// No description provided for @noEmployeesYet.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get noEmployeesYet;

  /// No description provided for @noMannedStations.
  ///
  /// In en, this message translates to:
  /// **'No manned stations'**
  String get noMannedStations;

  /// No description provided for @noOneMatches.
  ///
  /// In en, this message translates to:
  /// **'No one matches \\'**
  String get noOneMatches;

  /// No description provided for @noOperatorsPresentOrStations.
  ///
  /// In en, this message translates to:
  /// **'No operators present or stations available'**
  String get noOperatorsPresentOrStations;

  /// No description provided for @noProductionEntriesLoggedFor.
  ///
  /// In en, this message translates to:
  /// **'No production entries logged for you yet.'**
  String get noProductionEntriesLoggedFor;

  /// No description provided for @noPunchesRecordedYetToday.
  ///
  /// In en, this message translates to:
  /// **'No punches recorded yet today.'**
  String get noPunchesRecordedYetToday;

  /// No description provided for @noQueueData.
  ///
  /// In en, this message translates to:
  /// **'No queue data'**
  String get noQueueData;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @noStationMatches.
  ///
  /// In en, this message translates to:
  /// **'No station matches \\'**
  String get noStationMatches;

  /// No description provided for @noStationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stations available'**
  String get noStationsAvailable;

  /// No description provided for @noStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No stations found'**
  String get noStationsFound;

  /// No description provided for @noStationsSetUpYet.
  ///
  /// In en, this message translates to:
  /// **'No stations set up yet.'**
  String get noStationsSetUpYet;

  /// No description provided for @noStationsYet.
  ///
  /// In en, this message translates to:
  /// **'No stations yet.'**
  String get noStationsYet;

  /// No description provided for @noUnallocatedOrUnmannedStations.
  ///
  /// In en, this message translates to:
  /// **'No unallocated or unmanned stations for this shift date.'**
  String get noUnallocatedOrUnmannedStations;

  /// No description provided for @noZonesFound.
  ///
  /// In en, this message translates to:
  /// **'No zones found'**
  String get noZonesFound;

  /// No description provided for @notYetSyncedToHrms.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced to HRMS - fingerprint/RFID enrollment must be done directly on the'**
  String get notYetSyncedToHrms;

  /// No description provided for @nothingToShowYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet'**
  String get nothingToShowYet;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @openingAdditionsDispatchedByPost.
  ///
  /// In en, this message translates to:
  /// **'Opening / additions / dispatched by post-sewing zone'**
  String get openingAdditionsDispatchedByPost;

  /// No description provided for @operationName.
  ///
  /// In en, this message translates to:
  /// **'Operation Name'**
  String get operationName;

  /// No description provided for @operationNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Operation name is required'**
  String get operationNameIsRequired;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @operatorAllocation.
  ///
  /// In en, this message translates to:
  /// **'Operator Allocation'**
  String get operatorAllocation;

  /// No description provided for @operatorCount.
  ///
  /// In en, this message translates to:
  /// **'Operator Count'**
  String get operatorCount;

  /// No description provided for @operators.
  ///
  /// In en, this message translates to:
  /// **'Operators'**
  String get operators;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @overallProductionEfficiencyTargetsAnd.
  ///
  /// In en, this message translates to:
  /// **'Overall production, efficiency, targets and bottlenecks'**
  String get overallProductionEfficiencyTargetsAnd;

  /// No description provided for @previousReports.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS REPORTS'**
  String get previousReports;

  /// No description provided for @packingRtmAndDispatchStock.
  ///
  /// In en, this message translates to:
  /// **'Packing, RTM, and dispatch stock will appear here once the stock module goes live.'**
  String get packingRtmAndDispatchStock;

  /// No description provided for @passwordLeaveBlankToUse.
  ///
  /// In en, this message translates to:
  /// **'Password (leave blank to use default: MES2K26)'**
  String get passwordLeaveBlankToUse;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @personalEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Personal & Emergency Contact'**
  String get personalEmergencyContact;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @pickAMonthToReview.
  ///
  /// In en, this message translates to:
  /// **'Pick a month to review the full period'**
  String get pickAMonthToReview;

  /// No description provided for @pickAnyPastDateTo.
  ///
  /// In en, this message translates to:
  /// **'Pick any past date to see that day\'s attendance'**
  String get pickAnyPastDateTo;

  /// No description provided for @pieceRatePay.
  ///
  /// In en, this message translates to:
  /// **'Piece Rate Pay'**
  String get pieceRatePay;

  /// No description provided for @piecesLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Pieces (Last 30 Days)'**
  String get piecesLast30Days;

  /// No description provided for @piecesIssued.
  ///
  /// In en, this message translates to:
  /// **'Pieces Issued'**
  String get piecesIssued;

  /// No description provided for @piecesProduced.
  ///
  /// In en, this message translates to:
  /// **'Pieces Produced'**
  String get piecesProduced;

  /// No description provided for @piecesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Pieces completed'**
  String get piecesCompleted;

  /// No description provided for @piecesIssued2.
  ///
  /// In en, this message translates to:
  /// **'Pieces issued'**
  String get piecesIssued2;

  /// No description provided for @preShiftCheckIsFabric.
  ///
  /// In en, this message translates to:
  /// **'Pre-shift check: is fabric/stock ready at each station'**
  String get preShiftCheckIsFabric;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @productionEntry.
  ///
  /// In en, this message translates to:
  /// **'Production Entry'**
  String get productionEntry;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'RECENT ENTRIES'**
  String get recentEntries;

  /// No description provided for @recentlyJoined.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY JOINED'**
  String get recentlyJoined;

  /// No description provided for @ratePerPiece.
  ///
  /// In en, this message translates to:
  /// **'Rate Per Piece (₹)'**
  String get ratePerPiece;

  /// No description provided for @reactivateEmployee.
  ///
  /// In en, this message translates to:
  /// **'Reactivate Employee'**
  String get reactivateEmployee;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @reportHtmlFallback.
  ///
  /// In en, this message translates to:
  /// **'Report (HTML fallback)'**
  String get reportHtmlFallback;

  /// No description provided for @reportReady.
  ///
  /// In en, this message translates to:
  /// **'Report ready'**
  String get reportReady;

  /// No description provided for @reportRegenerated.
  ///
  /// In en, this message translates to:
  /// **'Report regenerated'**
  String get reportRegenerated;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roleDetails.
  ///
  /// In en, this message translates to:
  /// **'Role Details'**
  String get roleDetails;

  /// No description provided for @roleName.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get roleName;

  /// No description provided for @roleCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Role created successfully'**
  String get roleCreatedSuccessfully;

  /// No description provided for @roleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Role deleted'**
  String get roleDeleted;

  /// No description provided for @roleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Role is required'**
  String get roleIsRequired;

  /// No description provided for @roleNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Role name is required'**
  String get roleNameIsRequired;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @rolesAreManagedFromThe.
  ///
  /// In en, this message translates to:
  /// **'Roles are managed from the \\'**
  String get rolesAreManagedFromThe;

  /// No description provided for @rolesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Roles updated'**
  String get rolesUpdated;

  /// No description provided for @s1SubAssembly.
  ///
  /// In en, this message translates to:
  /// **'S1 · Sub Assembly'**
  String get s1SubAssembly;

  /// No description provided for @s2FullGarment.
  ///
  /// In en, this message translates to:
  /// **'S2 · Full Garment'**
  String get s2FullGarment;

  /// No description provided for @s2FullGarmentAssembly.
  ///
  /// In en, this message translates to:
  /// **'S2 · Full Garment Assembly'**
  String get s2FullGarmentAssembly;

  /// No description provided for @samTargets.
  ///
  /// In en, this message translates to:
  /// **'SAM & Targets'**
  String get samTargets;

  /// No description provided for @samStandardAllowedMinutes.
  ///
  /// In en, this message translates to:
  /// **'SAM (Standard Allowed Minutes)'**
  String get samStandardAllowedMinutes;

  /// No description provided for @signInAs.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN AS'**
  String get signInAs;

  /// No description provided for @switchRole.
  ///
  /// In en, this message translates to:
  /// **'SWITCH ROLE'**
  String get switchRole;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveRoles.
  ///
  /// In en, this message translates to:
  /// **'Save Roles'**
  String get saveRoles;

  /// No description provided for @searchByNameOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code'**
  String get searchByNameOrCode;

  /// No description provided for @searchByStationOrOperation.
  ///
  /// In en, this message translates to:
  /// **'Search by station or operation'**
  String get searchByStationOrOperation;

  /// No description provided for @searchEmployees.
  ///
  /// In en, this message translates to:
  /// **'Search employees'**
  String get searchEmployees;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectARole.
  ///
  /// In en, this message translates to:
  /// **'Select a role'**
  String get selectARole;

  /// No description provided for @selectAStation.
  ///
  /// In en, this message translates to:
  /// **'Select a station'**
  String get selectAStation;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selectAtLeastOneActivity.
  ///
  /// In en, this message translates to:
  /// **'Select at least one activity'**
  String get selectAtLeastOneActivity;

  /// No description provided for @selectAtLeastOneRole.
  ///
  /// In en, this message translates to:
  /// **'Select at least one role'**
  String get selectAtLeastOneRole;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @setUpStationsFirstThen.
  ///
  /// In en, this message translates to:
  /// **'Set up stations first, then check back here.'**
  String get setUpStationsFirstThen;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @shiftsLogged.
  ///
  /// In en, this message translates to:
  /// **'Shifts Logged'**
  String get shiftsLogged;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @standardSam.
  ///
  /// In en, this message translates to:
  /// **'Standard SAM'**
  String get standardSam;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking'**
  String get startTracking;

  /// No description provided for @station.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get station;

  /// No description provided for @stationDetails.
  ///
  /// In en, this message translates to:
  /// **'Station Details'**
  String get stationDetails;

  /// No description provided for @stationNumber.
  ///
  /// In en, this message translates to:
  /// **'Station Number'**
  String get stationNumber;

  /// No description provided for @stationQueues.
  ///
  /// In en, this message translates to:
  /// **'Station Queues'**
  String get stationQueues;

  /// No description provided for @stationStatus.
  ///
  /// In en, this message translates to:
  /// **'Station Status'**
  String get stationStatus;

  /// No description provided for @stationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Station deleted'**
  String get stationDeleted;

  /// No description provided for @stationNumberCanTBe.
  ///
  /// In en, this message translates to:
  /// **'Station number can\'t be changed after creation.'**
  String get stationNumberCanTBe;

  /// No description provided for @stationNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Station number is required'**
  String get stationNumberIsRequired;

  /// No description provided for @stationWiseStockReport.
  ///
  /// In en, this message translates to:
  /// **'Station-wise Stock Report'**
  String get stationWiseStockReport;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @stationsTracked.
  ///
  /// In en, this message translates to:
  /// **'Stations Tracked'**
  String get stationsTracked;

  /// No description provided for @stockAvailability.
  ///
  /// In en, this message translates to:
  /// **'Stock Availability'**
  String get stockAvailability;

  /// No description provided for @stockAvailabilityIsAutoFlagged.
  ///
  /// In en, this message translates to:
  /// **'Stock availability is auto-flagged HIGH_STOCK when the logged quantity exceeds this ceiling.'**
  String get stockAvailabilityIsAutoFlagged;

  /// No description provided for @stockAvailabilityIsAutoFlagged2.
  ///
  /// In en, this message translates to:
  /// **'Stock availability is auto-flagged LOW_STOCK when the Supervisor\'s logged quantity falls below this (NO_STOCK at exactly 0).'**
  String get stockAvailabilityIsAutoFlagged2;

  /// No description provided for @stockStatusShortagesAndDaily.
  ///
  /// In en, this message translates to:
  /// **'Stock status, shortages and daily position by station/zone'**
  String get stockStatusShortagesAndDaily;

  /// No description provided for @stockZonesHavenTBeen.
  ///
  /// In en, this message translates to:
  /// **'Stock zones haven\'t been seeded on the server yet.'**
  String get stockZonesHavenTBeen;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop Tracking'**
  String get stopTracking;

  /// No description provided for @switchRole2.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get switchRole2;

  /// No description provided for @switchRole3.
  ///
  /// In en, this message translates to:
  /// **'Switch role'**
  String get switchRole3;

  /// No description provided for @syncAll.
  ///
  /// In en, this message translates to:
  /// **'Sync All'**
  String get syncAll;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// No description provided for @syncAttendanceFromHrms.
  ///
  /// In en, this message translates to:
  /// **'Sync attendance from HRMS'**
  String get syncAttendanceFromHrms;

  /// No description provided for @syncThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Sync this month'**
  String get syncThisMonth;

  /// No description provided for @syncWithHrms.
  ///
  /// In en, this message translates to:
  /// **'Sync with HRMS'**
  String get syncWithHrms;

  /// No description provided for @todaySAttendance.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S ATTENDANCE'**
  String get todaySAttendance;

  /// No description provided for @tapToCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create one.'**
  String get tapToCreateOne;

  /// No description provided for @tapToLogPiecesProduced.
  ///
  /// In en, this message translates to:
  /// **'Tap + to log pieces produced on behalf of an operator, or start tracking from Operator Allocation.'**
  String get tapToLogPiecesProduced;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap \\'**
  String get tap;

  /// No description provided for @targetPiecesDay.
  ///
  /// In en, this message translates to:
  /// **'Target Pieces / Day'**
  String get targetPiecesDay;

  /// No description provided for @targetPiecesHour.
  ///
  /// In en, this message translates to:
  /// **'Target Pieces / Hour'**
  String get targetPiecesHour;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @theBiometricAttendancePortalHasn.
  ///
  /// In en, this message translates to:
  /// **'The biometric attendance portal hasn\'t been configured on the server yet.'**
  String get theBiometricAttendancePortalHasn;

  /// No description provided for @thisEmployeeHasNoLogged.
  ///
  /// In en, this message translates to:
  /// **'This employee has no logged entries or tracking session on this date.'**
  String get thisEmployeeHasNoLogged;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisPermanentlyRemovesTheSelected.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the selected employee(s). Anyone with associated records elsewhere will be skipped automatically.'**
  String get thisPermanentlyRemovesTheSelected;

  /// No description provided for @thisPermanentlyRemovesTheSelected2.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the selected role(s). Any role still assigned to employees will be skipped automatically.'**
  String get thisPermanentlyRemovesTheSelected2;

  /// No description provided for @timeOnMachine.
  ///
  /// In en, this message translates to:
  /// **'Time on Machine'**
  String get timeOnMachine;

  /// No description provided for @todaySPunchesPresentAbsent.
  ///
  /// In en, this message translates to:
  /// **'Today\'s punches & present / absent status'**
  String get todaySPunchesPresentAbsent;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalRoles.
  ///
  /// In en, this message translates to:
  /// **'Total Roles'**
  String get totalRoles;

  /// No description provided for @totalSam.
  ///
  /// In en, this message translates to:
  /// **'Total SAM'**
  String get totalSam;

  /// No description provided for @totalWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Total Workforce'**
  String get totalWorkforce;

  /// No description provided for @tryADifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get tryADifferentSearchTerm;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @uploadFacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Face Photo'**
  String get uploadFacePhoto;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @wipBundleTracking.
  ///
  /// In en, this message translates to:
  /// **'WIP / Bundle Tracking'**
  String get wipBundleTracking;

  /// No description provided for @wagesEarned.
  ///
  /// In en, this message translates to:
  /// **'Wages Earned'**
  String get wagesEarned;

  /// No description provided for @workDetails.
  ///
  /// In en, this message translates to:
  /// **'Work Details'**
  String get workDetails;

  /// No description provided for @workerPerformanceReport.
  ///
  /// In en, this message translates to:
  /// **'Worker Performance Report'**
  String get workerPerformanceReport;

  /// No description provided for @youCanMoveIndividualsTo.
  ///
  /// In en, this message translates to:
  /// **'You can move individuals to a different role afterward.'**
  String get youCanMoveIndividualsTo;

  /// No description provided for @yourAccountHoldsMoreThan.
  ///
  /// In en, this message translates to:
  /// **'Your account holds more than one role. Choose which one to use for this session.'**
  String get yourAccountHoldsMoreThan;

  /// No description provided for @yourDashboardWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard will appear here once this role\'s PALMS module goes live.'**
  String get yourDashboardWillAppearHere;

  /// No description provided for @yourPieceCountAndShift.
  ///
  /// In en, this message translates to:
  /// **'Your piece count and shift efficiency will appear here once production tracking goes live.'**
  String get yourPieceCountAndShift;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// No description provided for @howManyPieces.
  ///
  /// In en, this message translates to:
  /// **'how many pieces?'**
  String get howManyPieces;

  /// No description provided for @noThresholdSet.
  ///
  /// In en, this message translates to:
  /// **'no threshold set'**
  String get noThresholdSet;

  /// No description provided for @notBuiltYet.
  ///
  /// In en, this message translates to:
  /// **'not built yet'**
  String get notBuiltYet;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'not configured'**
  String get notConfigured;

  /// No description provided for @operatorIsWorkingRightNow.
  ///
  /// In en, this message translates to:
  /// **'operator is working right now'**
  String get operatorIsWorkingRightNow;

  /// No description provided for @physicalBiometricDeviceByWhoever.
  ///
  /// In en, this message translates to:
  /// **'physical biometric device by whoever administers it; that can\'t be triggered from here.'**
  String get physicalBiometricDeviceByWhoever;

  /// No description provided for @piecesCompleted2.
  ///
  /// In en, this message translates to:
  /// **'pieces completed'**
  String get piecesCompleted2;

  /// No description provided for @piecesIssued3.
  ///
  /// In en, this message translates to:
  /// **'pieces issued'**
  String get piecesIssued3;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'powered by'**
  String get poweredBy;

  /// No description provided for @seeEveryone.
  ///
  /// In en, this message translates to:
  /// **'see everyone'**
  String get seeEveryone;

  /// No description provided for @shiftDate.
  ///
  /// In en, this message translates to:
  /// **'shift date'**
  String get shiftDate;

  /// No description provided for @whatSTheBottleneckRight.
  ///
  /// In en, this message translates to:
  /// **'what\'s the bottleneck right now'**
  String get whatSTheBottleneckRight;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GTMES'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'GramTarang Garments Manufacturing Execution System'**
  String get appTagline;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get langTelugu;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @splashConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get splashConnecting;

  /// No description provided for @splashOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline. Ensure the backend is running.'**
  String get splashOffline;

  /// No description provided for @splashUnableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to backend at {url}'**
  String splashUnableToConnect(String url);

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your MES account to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get loginUsernameRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get loginPasswordRequired;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String loginWelcomeBack(String name);

  /// No description provided for @institutions.
  ///
  /// In en, this message translates to:
  /// **'GramTarang Technologies  &  Centurion University of Technology and Management'**
  String get institutions;

  /// No description provided for @roleSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get roleSelectTitle;

  /// No description provided for @roleSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You hold more than one role. Pick the one you want to work as.'**
  String get roleSelectSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOut;

  /// No description provided for @noModules.
  ///
  /// In en, this message translates to:
  /// **'No modules are assigned to your role yet.'**
  String get noModules;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get navEmployees;

  /// No description provided for @navRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get navRoles;

  /// No description provided for @navStations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get navStations;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get navOperations;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get commonInactive;

  /// No description provided for @commonPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get commonPresent;

  /// No description provided for @commonAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get commonAbsent;

  /// No description provided for @commonLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get commonLate;

  /// No description provided for @myProduction.
  ///
  /// In en, this message translates to:
  /// **'My Production'**
  String get myProduction;

  /// No description provided for @operation.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get operation;

  /// No description provided for @noProductionYet.
  ///
  /// In en, this message translates to:
  /// **'No production recorded yet.'**
  String get noProductionYet;

  /// No description provided for @errCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load data'**
  String get errCouldNotLoad;

  /// No description provided for @errNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this feature'**
  String get errNoAccess;

  /// No description provided for @notYetSyncedToHrmsFull.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced to HRMS - fingerprint/RFID enrollment must be done directly on the physical biometric device by whoever administers it; that can\'t be triggered from here.'**
  String get notYetSyncedToHrmsFull;

  /// No description provided for @rolesAreManagedFromAssignRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles are managed from the Assign Roles action on the employee detail screen.'**
  String get rolesAreManagedFromAssignRoles;

  /// No description provided for @tapAddEmployeeToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Employee to create the first record.'**
  String get tapAddEmployeeToCreate;

  /// No description provided for @importsAllUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Imports all {count} unlinked HRMS employees under one role. You can move individuals to a different role afterward.'**
  String importsAllUnlinked(int count);

  /// No description provided for @atThisStation.
  ///
  /// In en, this message translates to:
  /// **'At this station'**
  String get atThisStation;

  /// No description provided for @presentToday.
  ///
  /// In en, this message translates to:
  /// **'Present today'**
  String get presentToday;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noResults;

  /// No description provided for @errSessionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Your session expired - please log in again'**
  String get errSessionInvalid;

  /// No description provided for @errPiecesNegative.
  ///
  /// In en, this message translates to:
  /// **'Pieces produced cannot be negative'**
  String get errPiecesNegative;

  /// No description provided for @errTimeNotPositive.
  ///
  /// In en, this message translates to:
  /// **'Time on machine must be more than zero'**
  String get errTimeNotPositive;

  /// No description provided for @errTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'A time range is required'**
  String get errTimeRequired;

  /// No description provided for @errEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get errEndBeforeStart;

  /// No description provided for @errEmployeeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Employee not found'**
  String get errEmployeeNotFound;

  /// No description provided for @errStationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Station not found'**
  String get errStationNotFound;

  /// No description provided for @errHrmsNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'HRMS is not connected yet'**
  String get errHrmsNotConfigured;

  /// No description provided for @errHrmsUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the HRMS attendance portal'**
  String get errHrmsUnreachable;

  /// No description provided for @errHrmsRejected.
  ///
  /// In en, this message translates to:
  /// **'HRMS refused this server. Contact the HRMS administrator.'**
  String get errHrmsRejected;

  /// No description provided for @errReportsDisabled.
  ///
  /// In en, this message translates to:
  /// **'AI reports are turned off'**
  String get errReportsDisabled;

  /// No description provided for @errReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Report generation failed'**
  String get errReportFailed;

  /// No description provided for @syncAttendance.
  ///
  /// In en, this message translates to:
  /// **'Sync attendance'**
  String get syncAttendance;

  /// No description provided for @nobodyPresentToday.
  ///
  /// In en, this message translates to:
  /// **'Nobody present today'**
  String get nobodyPresentToday;

  /// No description provided for @tapSyncToPullAttendance.
  ///
  /// In en, this message translates to:
  /// **'Tap sync above to pull attendance from HRMS.'**
  String get tapSyncToPullAttendance;

  /// No description provided for @entriesWithoutATime.
  ///
  /// In en, this message translates to:
  /// **'Entries without a time'**
  String get entriesWithoutATime;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entries;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @syncedRecords.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} attendance record(s)'**
  String syncedRecords(int count);

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesCount(int count);

  /// No description provided for @timeMustBeWithinSlot.
  ///
  /// In en, this message translates to:
  /// **'Time must be within {slot}'**
  String timeMustBeWithinSlot(String slot);

  /// No description provided for @timeOverlapsAnotherEntry.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps an entry already logged at {range}.'**
  String timeOverlapsAnotherEntry(String range);

  /// No description provided for @minutesFree.
  ///
  /// In en, this message translates to:
  /// **'{count} min free'**
  String minutesFree(int count);

  /// No description provided for @hourIsFull.
  ///
  /// In en, this message translates to:
  /// **'Hour full'**
  String get hourIsFull;

  /// No description provided for @errTimeOverlap.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps another entry already logged for this operator'**
  String get errTimeOverlap;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'te':
      return L10nTe();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
