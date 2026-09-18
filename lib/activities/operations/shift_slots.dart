import 'package:flutter/material.dart';

/// The working day, divided into the hourly blocks production is logged against.
///
/// The 13:00-13:30 gap is the lunch break and deliberately has no slot: work logged
/// against it would distort both machine time and efficiency.
class ShiftSlot {
  final TimeOfDay start;
  final TimeOfDay end;

  /// Whether this slot is past the regular shift (17:30) - logged the same way as any
  /// other slot, just labelled distinctly so a supervisor can see at a glance which
  /// hours are overtime.
  final bool isOvertime;

  const ShiftSlot(this.start, this.end, {this.isOvertime = false});

  static const List<ShiftSlot> all = [
    ShiftSlot(TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 10, minute: 0)),
    ShiftSlot(TimeOfDay(hour: 10, minute: 0), TimeOfDay(hour: 11, minute: 0)),
    ShiftSlot(TimeOfDay(hour: 11, minute: 0), TimeOfDay(hour: 12, minute: 0)),
    ShiftSlot(TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 13, minute: 0)),
    ShiftSlot(TimeOfDay(hour: 13, minute: 30), TimeOfDay(hour: 14, minute: 30)),
    ShiftSlot(TimeOfDay(hour: 14, minute: 30), TimeOfDay(hour: 15, minute: 30)),
    ShiftSlot(TimeOfDay(hour: 15, minute: 30), TimeOfDay(hour: 16, minute: 30)),
    ShiftSlot(TimeOfDay(hour: 16, minute: 30), TimeOfDay(hour: 17, minute: 30)),
    ShiftSlot(TimeOfDay(hour: 17, minute: 30), TimeOfDay(hour: 18, minute: 30), isOvertime: true),
    ShiftSlot(TimeOfDay(hour: 18, minute: 30), TimeOfDay(hour: 19, minute: 30), isOvertime: true),
    ShiftSlot(TimeOfDay(hour: 19, minute: 30), TimeOfDay(hour: 20, minute: 30), isOvertime: true),
  ];

  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;

  /// "09:00 - 10:00", or "17:30 - 18:30 (Overtime)" for a slot past the regular shift.
  /// Deliberately 24-hour and locale-independent: these are fixed factory shift
  /// boundaries that supervisors know by number, not wall-clock format.
  String get label => isOvertime ? '${_two(start)} - ${_two(end)} (Overtime)' : '${_two(start)} - ${_two(end)}';

  static String _two(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Whether a "HH:mm:ss" clock time from the backend falls inside this slot.
  bool contains(String? clock) {
    if (clock == null || clock.length < 5) return false;
    final h = int.tryParse(clock.substring(0, 2));
    final m = int.tryParse(clock.substring(3, 5));
    if (h == null || m == null) return false;
    final minutes = h * 60 + m;
    return minutes >= startMinutes && minutes < endMinutes;
  }

  /// The slot covering [now], or null during the break or outside working hours.
  static ShiftSlot? current(TimeOfDay now) {
    final minutes = now.hour * 60 + now.minute;
    for (final slot in all) {
      if (minutes >= slot.startMinutes && minutes < slot.endMinutes) return slot;
    }
    return null;
  }

  int get lengthMinutes => endMinutes - startMinutes;

  /// Minutes past midnight for a "HH:mm[:ss]" clock string, or null if unparseable.
  static int? minutesOf(String? clock) {
    if (clock == null || clock.length < 5) return null;
    final h = int.tryParse(clock.substring(0, 2));
    final m = int.tryParse(clock.substring(3, 5));
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}

/// One occupied stretch of time, used to work out what is still free in a slot.
///
/// An hour holds 60 minutes and no more: without this, two entries could each claim
/// 09:00-10:00 and record 120 minutes of work inside a 60-minute hour, which would
/// silently halve every efficiency figure derived from it.
class TimeRange {
  final int startMinutes;
  final int endMinutes;

  const TimeRange(this.startMinutes, this.endMinutes);

  bool overlaps(TimeRange other) =>
      startMinutes < other.endMinutes && other.startMinutes < endMinutes;

  /// The earliest free minute in [slot] given everything already booked, or null when
  /// the slot is completely full.
  static int? nextFreeStart(ShiftSlot slot, List<TimeRange> taken) {
    if (taken.isEmpty) return slot.startMinutes;
    final sorted = [...taken]..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    var cursor = slot.startMinutes;
    for (final range in sorted) {
      if (range.startMinutes > cursor) return cursor; // gap before this booking
      if (range.endMinutes > cursor) cursor = range.endMinutes;
    }
    return cursor >= slot.endMinutes ? null : cursor;
  }

  /// Minutes still unbooked in [slot].
  static int freeMinutes(ShiftSlot slot, List<TimeRange> taken) {
    final used = taken.fold<int>(0, (sum, r) {
      final from = r.startMinutes < slot.startMinutes ? slot.startMinutes : r.startMinutes;
      final to = r.endMinutes > slot.endMinutes ? slot.endMinutes : r.endMinutes;
      return sum + (to > from ? to - from : 0);
    });
    final free = slot.lengthMinutes - used;
    return free < 0 ? 0 : free;
  }
}
