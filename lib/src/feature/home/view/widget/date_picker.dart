import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

class DatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateChanged;

  const DatePicker({
    required this.selectedDate,
    required this.onDateChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year, 12, 31),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      widget.onDateChanged(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    String currentLanguage = currentLocale.languageCode;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'delivery_date'.i18n(),
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                if (widget.selectedDate != null)
                  Text(
                    DateFormat(currentLanguage == 'en' ? 'MM/dd/y' : 'dd/MM/y')
                        .format(widget.selectedDate!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _showDatePicker(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.onDateChanged(null);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
