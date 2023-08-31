import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/repository/user_model.dart';
import '../../repository/activity.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final UserModel? user;
  final bool isProfessor;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.user,
    required this.isProfessor,
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
    await _prefs.setBool(_getActivityStatusKey(), isDone);
    setState(() {
      _isDone = isDone;
    });
    _showStatusSnackBar(isDone);
  }

  void _showStatusSnackBar(bool isDone) {
    final snackBar = SnackBar(
      content:
          Text(isDone ? 'activity_done'.i18n() : 'activity_not_done'.i18n()),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Image.network(widget.user!.imageUrl),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user!.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.activity.formattedAssignedDate(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(
                          () => _showFullDescription = !_showFullDescription),
                      child: Text(
                        widget.activity.description.replaceAll('\\n', '\n'),
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        textAlign: TextAlign.justify,
                        maxLines: _showFullDescription ? null : 4,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.activity.dueDate != null)
                          Text(
                            widget.activity.formattedDueDate(),
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
                        if (!widget.user!.isProfessor)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
