import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repository/activity.dart';
import '../../repository/activity_list.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final bool isProfessor;
  final bool isForm;

  const ActivityCard({
    super.key,
    required this.activity,
    this.isProfessor = false,
    this.isForm = false,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  late SharedPreferences _prefs;
  bool _isDone = false;
  bool _isLoading = true;
  bool _showFullDescription = false;
  bool _isSnackBarVisible = false;
  final List<SnackBar> _snackBarQueue = [];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences().then((_) {
      _initActivityStatus();
    });
  }

  @override
  void dispose() {
    _snackBarQueue.clear();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _initActivityStatus() {
    try {
      final status = _prefs.getBool(_getActivityStatusKey()) ?? false;
      setState(() {
        _isDone = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isDone = false;
        _isLoading = false;
      });
    }
  }

  String _getActivityStatusKey() {
    return 'activity_${widget.activity.id}_status';
  }

  Future<void> _updateActivityStatus(bool isDone) async {
    if (widget.activity.dueDate!.day <= DateTime.now().day) {
      _showStatusSnackBar(_isDone, isAlert: true);
    } else {
      await _prefs.setBool(_getActivityStatusKey(), isDone);
      setState(() {
        _isDone = isDone;
      });
      _showStatusSnackBar(isDone);
    }
  }

  void _showStatusSnackBar(bool isDone, {bool? isAlert}) {
    final snackBar = SnackBar(
      content: Text(isAlert != null
          ? 'activity_finish'.i18n()
          : isDone
              ? 'activity_done'.i18n()
              : 'activity_not_done'.i18n()),
      backgroundColor: isDone
          ? Theme.of(context).colorScheme.onError
          : Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 2),
    );

    _snackBarQueue.clear();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _snackBarQueue.add(snackBar);
    _showNextSnackBar();
  }

  void _showNextSnackBar() {
    if (!_isSnackBarVisible && _snackBarQueue.isNotEmpty) {
      final snackBar = _snackBarQueue.removeAt(0);

      setState(() {
        _isSnackBarVisible = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
        setState(() {
          _isSnackBarVisible = false;
        });
        _showNextSnackBar();
      });
    }
  }

  void _deleteActivity() async {
    bool confirmDelete = await _showConfirmationDialog();
    if (confirmDelete == true) {
      await _performDeleteActivity();
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_activity'.i18n()),
          content: Text('are_you_sure'.i18n()),
          actions: [
            TextButton(
              child: Text('no'.i18n()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('yes'.i18n()),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('error_occurred'.i18n()),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.i18n()),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteActivity() async {
    setState(() => _isLoading = true);
    final ActivityList activityProvider = Provider.of(context, listen: false);

    try {
      await activityProvider.deleteActivity(widget.activity.id);
    } catch (error) {
      _showErrorDialog('unexpected_error'.i18n());
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    String currentLanguage = currentLocale.languageCode;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.outlineVariant,
              ))
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(widget.activity.user.imageUrl),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.activity.user.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.activity.isEdit
                                  ? widget.activity.formattedAssignedDate(
                                          currentLanguage) +
                                      widget.activity
                                          .formattedEditDate(currentLanguage)
                                  : widget.activity
                                      .formattedAssignedDate(currentLanguage),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isProfessor && !widget.isForm)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Modular.to.pushNamed(
                                  'activityFormPage',
                                  arguments: widget.activity),
                              child: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _deleteActivity(),
                              child: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() =>
                              _showFullDescription = !_showFullDescription),
                          child: Text(
                            widget.activity.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            textAlign: _showFullDescription
                                ? TextAlign.justify
                                : TextAlign.left,
                            maxLines: _showFullDescription ? null : 4,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.activity.dueDate != null)
                    const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.activity.dueDate != null)
                        Text(
                          widget.activity.formattedDueDate(currentLanguage),
                          style: TextStyle(
                            fontSize: 14,
                            color: _isDone
                                ? Theme.of(context).colorScheme.onError
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (!widget.isProfessor &&
                          widget.activity.dueDate != null)
                        GestureDetector(
                          onTap: () async {
                            await _updateActivityStatus(!_isDone);
                          },
                          child: Icon(
                            _isDone ? Icons.check_circle : Icons.cancel,
                            color: _isDone
                                ? Theme.of(context).colorScheme.onError
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
