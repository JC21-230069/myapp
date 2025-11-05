import 'package:device_calendar/device_calendar.dart';
import 'package:go_router/go_router.dart';

import 'event_edit_screen.dart';
import 'main.dart';
import 'memo_screen.dart';
import 'notification_setting_screen.dart';
import 'register_screen.dart';
import 'weekly_report_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/memo',
      builder: (context, state) {
        final DateTime? selectedDate = state.extra as DateTime?;
        return MemoScreen(selectedDate: selectedDate);
      },
    ),
    GoRoute(
      path: '/weekly_report',
      builder: (context, state) => const WeeklyReportScreen(),
    ),
    GoRoute(
      path: '/notification_setting',
      builder: (context, state) => const NotificationSettingScreen(),
    ),
    GoRoute(
      path: '/event/edit',
      builder: (context, state) {
        final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
        return EventEditScreen(
          event: args['event'] as Event?,
          calendar: args['calendar'] as Calendar,
          selectedDate: args['selectedDate'] as DateTime?,
        );
      },
    ),
  ],
);

class AppRouter {
  static GoRouter get router => _router;
}
