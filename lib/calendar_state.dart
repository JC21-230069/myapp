
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';

// Conditional imports
import 'calendar_service_stub.dart'
    if (dart.library.io) 'calendar_service_mobile.dart';

class CalendarState with ChangeNotifier {
  final CalendarService _calendarService = CalendarService();

  dynamic _selectedCalendar;
  dynamic get selectedCalendar => _selectedCalendar;

  List<dynamic> _calendars = [];
  List<dynamic> get calendars => _calendars;

  Map<DateTime, List<dynamic>> _events = {};
  Map<DateTime, List<dynamic>> get events => _events;

  List<dynamic> _selectedEvents = [];
  List<dynamic> get selectedEvents => _selectedEvents;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  CalendarFormat get calendarFormat => _calendarFormat;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  DateTime? _selectedDay;
  DateTime? get selectedDay => _selectedDay;

  CalendarState() {
    _selectedDay = _focusedDay;
    if (!kIsWeb) {
      _retrieveCalendars();
    }
  }

  Future<void> _retrieveCalendars() async {
    if (kIsWeb) return;
    try {
      final hasPermission = await _calendarService.requestPermissions();
      if (!hasPermission) {
        if (kDebugMode) {
          print('Calendar permission denied.');
        }
        return;
      }

      _calendars = await _calendarService.getCalendars();
      if (_calendars.isNotEmpty) {
        _selectedCalendar = _calendars.firstWhere(
          (cal) => cal.isReadOnly != true,
          orElse: () => _calendars.first,
        );
        await _fetchEvents();
      }
      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print('Error retrieving calendars: $e\n$s');
      }
    }
  }

  Future<void> _fetchEvents([DateTime? start, DateTime? end]) async {
    if (kIsWeb || _selectedCalendar == null) return;

    final startDate = start ?? DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final endDate = end ?? DateTime(_focusedDay.year, _focusedDay.month + 2, 0);

    try {
      final eventsResult = await _calendarService.getEvents(_selectedCalendar.id, startDate, endDate);
      final newEvents = <DateTime, List<dynamic>>{};
      for (final event in eventsResult) {
        if (event.start == null) continue;
        final day = DateTime(event.start!.year, event.start!.month, event.start!.day);
        newEvents[day] = [...newEvents[day] ?? [], event];
      }
      _events = newEvents;
      _selectedEvents = _getEventsForDay(_selectedDay!);
      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print('Error fetching events: $e\n$s');
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      if (!kIsWeb) {
        _selectedEvents = _getEventsForDay(selectedDay);
      }
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    if (!kIsWeb) {
      _fetchEvents();
    }
  }

  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  void onCalendarChanged(String? calendarId) {
    if (!kIsWeb && calendarId != null) {
      _selectedCalendar = _calendars.firstWhere((cal) => cal.id == calendarId);
      _fetchEvents();
      notifyListeners();
    }
  }

  void setToday() {
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    if (!kIsWeb) {
      _selectedEvents = _getEventsForDay(_selectedDay!);
    }
    notifyListeners();
  }

  Future<void> refreshEvents() async {
    if (!kIsWeb) {
      await _fetchEvents();
    }
  }
}
