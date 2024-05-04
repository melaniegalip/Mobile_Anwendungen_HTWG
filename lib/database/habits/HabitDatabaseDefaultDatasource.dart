import 'package:get_it/get_it.dart';
import 'package:mobile_anwendungen/database/ObjectBox.dart';
import 'package:mobile_anwendungen/database/habits/HabitDatabaseDatasource.dart';
import 'package:mobile_anwendungen/domain/habits/Habit.dart';

import '../../domain/habits/CompletionDate.dart';
import '../../objectbox.g.dart';

class HabitsDatabaseDefaultDatasource extends HabitDatabaseDatasource {
  final Box<Habit> _habitBox = GetIt.instance.get<ObjectBox>().store.box<Habit>();

  @override
  void addHabit(Habit habit) {
    _habitBox.put(habit);
  }

  @override
  List<Habit> listHabits() {
    final habits = _habitBox.getAll();
    habits.sort((a, b) => a.index.compareTo(b.index));
    return habits;
  }

  @override
  void completeHabit(Habit habit) {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    final completionDate = CompletionDate(dateMillis: nowMillis);
    habit.completionDates.add(completionDate);
    _habitBox.put(habit);
  }

  @override
  void unCompleteHabit(Habit habit) {
    if (habit.completionDates.isNotEmpty) {
      habit.completionDates.sort((a, b) => b.dateMillis.compareTo(a.dateMillis));
      habit.completionDates.removeAt(0);
      _habitBox.put(habit);
    }
  }

  @override
  void reorderHabit(int oldIndex, int newIndex) {
    final habits = listHabits();

    if(newIndex > oldIndex){
      newIndex -= 1;
    }
    final habitToMove = habits.removeAt(oldIndex);
    habits.insert(newIndex, habitToMove);

    habits.asMap().forEach((index, habit) {
      habit.index = index;
    });

    _habitBox.putMany(habits);
  }

  @override
  void deleteHabit(Habit habit) {
    _habitBox.remove(habit.id);
  }
}