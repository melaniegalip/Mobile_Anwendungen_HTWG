import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_anwendungen/domain/model/day_state.dart';
import 'package:mobile_anwendungen/screens/list_habits/list_habits_model.dart';
import 'package:mobile_anwendungen/screens/list_habits/list_habits_providers.dart';
import '../../domain/model/habit.dart';
import '../../lang/locale_keys.g.dart';

class ListHabits extends ConsumerStatefulWidget {
  const ListHabits({super.key});

  @override
  ListHabitsState createState() => ListHabitsState();
}

class ListHabitsState extends ConsumerState<ListHabits> {
  bool _isEditing = false;

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ListHabitsController controller = ref.read(listHabitsControllerProvider);
    final ListHabitsModel model = ref.watch(listHabitsModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.listHabitsTitle.tr()),
        actions: [
          model.when(
            loading: () => Container(),
            loaded: (habits) => _editButton(habits),
          ),
        ],
      ),
      body: model.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (habits) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _onData(habits),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showUpsertHabit(null),
        tooltip: LocaleKeys.listHabitsFloatingActionButtonTooltip.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _onData(List<Habit> habits) {
    return habits.isEmpty ? _emptyState() : (_isEditing ? _buildEditableList(habits) : _buildList(habits));
  }

  Widget _editButton(List<Habit> habits) {
    return habits.isNotEmpty
        ? IconButton(
      icon: Icon(_isEditing ? Icons.check : Icons.edit),
      onPressed: _toggleEditing,
      tooltip: _isEditing ? LocaleKeys.finish.tr() : LocaleKeys.edit.tr(),
    )
        : Container();
  }

  Widget _buildList(List<Habit> habits) {
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _habit(habit, _habitCheckbox(habit));
      },
    );
  }

  Widget _buildEditableList(List<Habit> habits) {
    final controller = ref.read(listHabitsControllerProvider);

    return ReorderableListView(
      onReorder: controller.onReorder,
      proxyDecorator: (child, index, animation) => child,
      padding: const EdgeInsets.symmetric(vertical: 0),
      children: habits
          .map((habit) => _habit(habit, _habitEditActions(habit)))
          .toList(),
    );
  }

  Material _habit(Habit habit, Widget trailing) {
    final controller = ref.read(listHabitsControllerProvider);

    return Material(
      color: Colors.transparent,
      key: ValueKey(habit.index),
      child: ListTile(
        title: Text(
          habit.name,
          style: habit.isCompletedToday() == DayState.done
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        trailing: trailing,
        onTap: () {
          if (_isEditing) controller.showUpsertHabit(habit);
        },
        enabled: _isEditing || habit.isCompletedToday() != DayState.done,
        shape: const Border(bottom: BorderSide()),
      ),
    );
  }

  SizedBox _habitCheckbox(Habit habit) {
    final controller = ref.read(listHabitsControllerProvider);

    return SizedBox(
      width: 24,
      height: 24,
      child: Checkbox(
        visualDensity: VisualDensity.compact,
        value: habit.isCompletedToday() == DayState.done,
        onChanged: (isChecked) {
          if (isChecked ?? false) {
            controller.onCompleteHabit(habit);
          } else {
            controller.onUnCompleteHabit(habit);
          }
        },
      ),
    );
  }

  Row _habitEditActions(Habit habit) {
    final controller = ref.read(listHabitsControllerProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => controller.onDeleteHabit(habit),
        ),
        const Icon(Icons.drag_handle_sharp),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty.png'),
          Text(
            LocaleKeys.textIfItIsEmpty.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

abstract class ListHabitsController {
  void showUpsertHabit(Habit? habit);
  void onCompleteHabit(Habit habit);
  void onUnCompleteHabit(Habit habit);
  void onReorder(int oldIndex, int newIndex);
  void onDeleteHabit(Habit habit);
}
