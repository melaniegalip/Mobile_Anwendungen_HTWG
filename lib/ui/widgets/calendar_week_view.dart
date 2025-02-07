import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CalendarWeekView extends StatefulWidget {
  final Widget Function(DateTime date, bool isSelected) dayBuilder;
  final Widget Function(String weekLabel) headerBuilder;
  final Widget Function(String dayOfWeek) dayOfWeekLabelBuilder;
  final DateTime selectedDate;
  final DateTime creationDate;

  const CalendarWeekView({
    super.key,
    required this.dayBuilder,
    required this.headerBuilder,
    required this.dayOfWeekLabelBuilder,
    required this.selectedDate,
    required this.creationDate,
  });

  @override
  CalendarWeekViewState createState() => CalendarWeekViewState();
}

class CalendarWeekViewState extends State<CalendarWeekView> {
  late DateTime displayedWeekStart;

  @override
  void initState() {
    super.initState();
    displayedWeekStart = _findStartOfWeek(widget.selectedDate);
  }

  void _goToNextWeek() {
    setState(() {
      displayedWeekStart = displayedWeekStart.add(const Duration(days: 7));
    });
  }

  DateTime get _previousWeek {
    return displayedWeekStart.subtract(const Duration(days: 7));
  }

  void _goToPreviousWeek() {
    setState(() {
      displayedWeekStart = _previousWeek;
    });
  }

  DateTime _findStartOfWeek(DateTime date) {
    int daysToSubtract = (date.weekday + 6) % 7;
    return date.subtract(Duration(days: daysToSubtract));
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = _calculateDaysOfWeek(displayedWeekStart);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.creationDate.difference(_previousWeek) <=
                Duration(days: widget.creationDate.weekday))
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousWeek,
              )
            else
              const Opacity(
                opacity: 0.0,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: null,
                ),
              ),
            widget.headerBuilder(_formatWeekLabel(displayedWeekStart)),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goToNextWeek,
            ),
          ],
        ),
        _buildCalendar(daysOfWeek, widget.selectedDate),
      ],
    );
  }

  Widget _buildCalendar(List<DateTime> daysOfWeek, DateTime selectedDate) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double itemWidth = constraints.maxWidth / 7;

        return Wrap(
          children: List.generate(7, (index) {
            return SizedBox(
              width: itemWidth,
              child: _buildItem(daysOfWeek[index], selectedDate),
            );
          }),
        );
      },
    );
  }

  Widget _buildItem(DateTime date, DateTime selectedDate) {
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
    return Column(
      children: [
        widget.dayOfWeekLabelBuilder(
            DateFormat.E((context.locale.toString())).format(date)),
        widget.dayBuilder(date, isSelected),
      ],
    );
  }

  List<DateTime> _calculateDaysOfWeek(DateTime startOfWeek) {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _formatWeekLabel(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${DateFormat.MMMd((context.locale.toString())).format(startOfWeek)} - ${DateFormat.MMMd((context.locale.toString())).format(endOfWeek)}';
  }
}
