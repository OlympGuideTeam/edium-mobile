part of 'create_quiz_screen.dart';

class _EdiumDateTimePicker extends StatefulWidget {
  final DateTime initial;

  const _EdiumDateTimePicker({required this.initial});

  @override
  State<_EdiumDateTimePicker> createState() => _EdiumDateTimePickerState();
}

class _EdiumDateTimePickerState extends State<_EdiumDateTimePicker> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late int _displayedMonth;
  late int _displayedYear;

  static const _monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  static const _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
        widget.initial.year, widget.initial.month, widget.initial.day);
    _selectedHour = widget.initial.hour;
    _selectedMinute = widget.initial.minute;
    _displayedMonth = widget.initial.month;
    _displayedYear = widget.initial.year;
  }

  void _prevMonth() {
    setState(() {
      if (_displayedMonth == 1) {
        _displayedMonth = 12;
        _displayedYear--;
      } else {
        _displayedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayedMonth == 12) {
        _displayedMonth = 1;
        _displayedYear++;
      } else {
        _displayedMonth++;
      }
    });
  }

  List<DateTime?> _buildCalendarGrid() {
    final firstDay = DateTime(_displayedYear, _displayedMonth, 1);
    final daysInMonth =
        DateTime(_displayedYear, _displayedMonth + 1, 0).day;

    final startWeekday = firstDay.weekday;
    final leadingBlanks = startWeekday - 1;

    final List<DateTime?> cells = [];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayedYear, _displayedMonth, d));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  void _confirm() {
    final result = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendarGrid();
    final today = DateTime.now();
    final canGoPrev = _displayedYear > today.year ||
        (_displayedYear == today.year && _displayedMonth > today.month);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mono150,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: canGoPrev ? _prevMonth : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mono50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color:
                          canGoPrev ? AppColors.mono700 : AppColors.mono200,
                    ),
                  ),
                ),
                Text(
                  '${_monthNames[_displayedMonth - 1]} $_displayedYear',
                  style: AppTextStyles.subtitle
                      .copyWith(color: AppColors.mono900),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mono50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_right,
                        size: 20, color: AppColors.mono700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),


            Row(
              children: _weekDays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),


            ...List.generate(cells.length ~/ 7, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(7, (col) {
                    final cell = cells[row * 7 + col];
                    if (cell == null) {
                      return const Expanded(child: SizedBox(height: 40));
                    }

                    final isSelected = _isSameDay(cell, _selectedDate);
                    final isCurrentDay = _isToday(cell);
                    final isPast = cell.isBefore(
                        DateTime(today.year, today.month, today.day));

                    return Expanded(
                      child: GestureDetector(
                        onTap: isPast
                            ? null
                            : () => setState(() => _selectedDate = cell),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.mono900
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${cell.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected || isCurrentDay
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : isPast
                                        ? AppColors.mono200
                                        : isCurrentDay
                                            ? AppColors.mono900
                                            : AppColors.mono700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),

            const SizedBox(height: 20),


            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mono50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.mono100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_outlined,
                      size: 18, color: AppColors.mono400),
                  const SizedBox(width: 10),
                  Text(
                    'Время',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.mono700),
                  ),
                  const Spacer(),

                  _TimeScrollWheel(
                    value: _selectedHour,
                    maxValue: 23,
                    onChanged: (v) => setState(() => _selectedHour = v),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.mono900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  _TimeScrollWheel(
                    value: _selectedMinute,
                    maxValue: 59,
                    step: 5,
                    onChanged: (v) => setState(() => _selectedMinute = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),


            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonH,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  textStyle: AppTextStyles.primaryButton,
                ),
                child: Text(
                  'Готово — ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1].toLowerCase()}, '
                  '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

