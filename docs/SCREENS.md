# GTMES Screen Inventory

Every screen in `lib/activities/`, with the activity that gates it. A screen is reachable only
when the user's active role holds that activity — enforced both in the drawer and by the
backend on each request.

Role activities are defined in the `roles` table and mirrored in
`lib/utils/activity_catalog.dart`.

---

## Entry and session

| Screen | File | Activity |
|---|---|---|
| Splash | `splash_screen.dart` | `SPLASH` |
| Login | `login_screen.dart` | `LOGIN` |
| Role selection | `role_selection_screen.dart` | — shown when the user holds several roles |
| Main shell | `main_shell_screen.dart` | — hosts the drawer and swaps the body |
| Dashboard | `dashboard_screen.dart` | `DASHBOARD` |
| Profile | `profile_screen.dart` | `PROFILE` |

The login screen carries the language selector in its top-right corner, so it can be switched
before authenticating.

## Dashboards

`dashboard_screen.dart` selects one of four bodies from the active role.

| Dashboard | File | Roles | Shows |
|---|---|---|---|
| Workforce | `components/dashboard/workforce_dashboard.dart` | Factory Manager, HR Manager | Total, active and inactive headcount; distribution by role and department; recent joiners |
| Attendance | `components/dashboard/attendance_dashboard.dart` | Production Supervisor | Total employees, present, absent and late counts |
| SAM | `components/dashboard/sam_dashboard.dart` | IE Analyst | Total SAM, station counts for zones S1 and S2, stations ranked by SAM with the bottleneck marked |
| My Production | `components/dashboard/my_production_dashboard.dart` | Operator | Average efficiency, best day, shifts logged, personal entry history |

QC Inspector and Store Keeper receive a placeholder dashboard stating their intended scope.
Their modules are provisioned but not yet built.

---

## Operations — activity `OPERATIONS`

| Screen | File | Purpose |
|---|---|---|
| Operations hub | `operations/operations_hub_screen.dart` | Entry point to every operations module |
| Station allocation list | `operations/station_allocation_list_screen.dart` | All stations with manned state, colour-coded |
| Station assignment | `operations/station_assign_screen.dart` | Assign operators present today to a station |
| Tracking session | `operations/tracking_session_screen.dart` | Live timer with efficiency updating continuously |
| Production entry | `operations/production_entry_screen.dart` | Employees present today, with attendance sync |
| Employee slots | `operations/employee_slots_screen.dart` | One operator's day across eight hourly slots |
| Employee day detail | `operations/employee_day_detail_screen.dart` | A single day's activity for one operator |
| Station status | `operations/station_status_screen.dart` | Needs Attention and Manned views, bottleneck escalated |
| Stock availability | `operations/stock_availability_screen.dart` | Whether each station has material, with reasons |
| Stock position | `operations/stock_position_screen.dart` | Opening, additions, dispatched and closing per zone |
| WIP / bundles | `operations/wip_bundle_screen.dart` | Bundles in progress and queue depth per station |

### Supporting dialogs and widgets

| File | Purpose |
|---|---|
| `slot_entry_dialog.dart` | Log an entry into an hourly slot — station, pieces, time range |
| `log_production_entry_dialog.dart` | Log an entry outside the hourly flow |
| `production_entry_detail_dialog.dart` | Full detail: pieces, time, efficiency, wages |
| `pieces_prompt_dialog.dart` | Pieces issued / completed prompt for tracking |
| `stock_quantity_dialog.dart` | Capture a stock quantity |
| `update_stock_position_dialog.dart` | Update a zone's daily position |
| `wip_bundle_dialogs.dart` | Create, move and complete a bundle |
| `entry_pickers.dart` | Station and employee pickers with search |
| `shift_slots.dart` | The eight shift slots, and free/occupied time arithmetic |
| `employee_activity_card.dart`, `operations_widgets.dart`, `stock_availability_row.dart`, `tracking_stat_tile.dart`, `wip_bundle_lists.dart` | Shared presentation widgets |

---

## Workforce

| Screen | File | Activity |
|---|---|---|
| Employee list | `employee_list_screen.dart` | `EMPLOYEE_LIST` |
| Employee detail | `employee_detail_screen.dart` | `EMPLOYEE_DETAIL` |
| Employee form | `employee_form_screen.dart` | `EMPLOYEE_FORM` |
| HRMS import | `hrms_import_screen.dart` | `EMPLOYEE_FORM` |
| Assign roles | `assign_roles_screen.dart` | `EMPLOYEE_FORM` |
| Role list | `role_list_screen.dart` | `ROLE_LIST` |
| Role form | `role_form_screen.dart` | `ROLE_FORM` |

HRMS import compares the register against the biometric system and offers anyone present there
but missing here, so a new joiner can be added without re-typing their details.

## Attendance — activity `ATTENDANCE`

| Screen | File |
|---|---|
| Attendance hub | `attendance_screen.dart` |
| Live attendance | `live_attendance_screen.dart` |
| Daily attendance | `daily_attendance_screen.dart` |
| Monthly attendance | `monthly_attendance_screen.dart` |

## Stations

| Screen | File | Activity |
|---|---|---|
| Station list | `station_list_screen.dart` | `STATION_LIST` |
| Station form | `station_form_screen.dart` | `STATION_FORM` |

The station form sets SAM, operator count, hourly and daily targets, rate per piece, and stock
thresholds. Every production figure in the application derives from these values, so it is the
most consequential form in the product.

## Reports — activity `REPORTS`

| Screen | File | Purpose |
|---|---|---|
| Report types | `reports_screen.dart` | Choose Production, Stock, Attendance or Worker Performance |
| Report list | `reports/report_type_screen.dart` | Reports already generated for a type; generate for a date |
| PDF opener | `reports/report_pdf_opener.dart` | Fetch and display the rendered PDF |
| List item | `reports/report_list_item.dart` | Row presentation |

---

## Role → screen map

| Role | Reachable screens |
|---|---|
| **Factory Manager** | Dashboard, Profile, Stations, Operations, Reports |
| **Production Supervisor** | Dashboard, Profile, Attendance, Operations, Stations, Station form |
| **HR Manager** | Dashboard, Profile, Employees, Roles, Attendance, Reports |
| **IE Analyst** | Dashboard, Profile, Stations, Station form |
| **Operator** | Dashboard, Profile, My Production |
| **QC Inspector** | Dashboard, Profile |
| **Store Keeper** | Dashboard, Profile |
