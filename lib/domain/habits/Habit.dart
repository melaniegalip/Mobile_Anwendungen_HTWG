import 'package:get_it/get_it.dart';
import 'package:objectbox/objectbox.dart';
import '../../database/ObjectBox.dart';
import 'CompletionDate.dart';
import 'DayState.dart';

@Entity()
class Habit {
  int id = 0;
  String name;
  int index;
  int creationDate;

  final completionDates = ToMany<CompletionDate>();

  Habit({
    required this.name,
    required this.index,
    required this.creationDate,
  });

  DayState dayStateOn(DateTime date) {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final currentDate = DateTime.now();
    final currentDateStart = DateTime(currentDate.year, currentDate.month, currentDate.day);

    if (dateStart.isAfter(currentDateStart)) {
      return DayState.FutureDate;
    }

    if (date.isBefore(DateTime.fromMillisecondsSinceEpoch(creationDate))) {
      return DayState.HabitNotCreatedYet;
    }

    if (completionDates.any((completionDate) {
      final completionDateTime = DateTime.fromMillisecondsSinceEpoch(completionDate.dateMillis);
      return completionDateTime.isAfter(dateStart) && completionDateTime.isBefore(dateEnd);
    })) {
      return DayState.Done;
    } else {
      return DayState.NotDone;
    }
  }

  DayState isCompletedToday() {
    return dayStateOn(DateTime.now());
  }

  static int newIndex() {
    final Box<Habit> habitBox = GetIt.instance.get<ObjectBox>().store.box<Habit>();
    final habits = habitBox.getAll();
    final maxIndex = habits.map((habit) => habit.index).fold(0, (prev, curr) => prev > curr ? prev : curr);
    return maxIndex + 1;
  }
}
