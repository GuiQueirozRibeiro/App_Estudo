import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/repository/user_model.dart';
import '../../repository/activity.dart';

class ActivityCard extends StatefulWidget {
  final double cardHeight;
  final Activity activity;
  final UserModel? user;
  final bool isProfessor;

  const ActivityCard({
    super.key,
    required this.cardHeight,
    required this.activity,
    required this.user,
    required this.isProfessor,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _showFullDescription = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String _getActivityStatusKey() {
    return 'activity_${widget.activity.id}_status';
  }

  Future<String> _getActivityStatus() async {
    return _prefs.getString(_getActivityStatusKey()) ?? "A fazer";
  }

  Future<void> _updateActivityStatus(String newStatus) async {
    await _prefs.setString(_getActivityStatusKey(), newStatus);
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
          child: Column(
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
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.activity.description.replaceAll('\\n', '\n'),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.justify,
                maxLines: _showFullDescription ? null : 4,
              ),
              if (widget.activity.dueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Entregar ${widget.activity.formattedDueDate()}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.activity.description.length > 4)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showFullDescription = !_showFullDescription;
                        });
                      },
                      child: Text(
                        _showFullDescription
                            ? 'show_less'.i18n()
                            : 'show_more'.i18n(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!widget.isProfessor && widget.activity.dueDate != null)
                    FutureBuilder<String>(
                      future: _getActivityStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final activityStatus = snapshot.data ?? "A fazer";

                        if (activityStatus == "A fazer") {
                          return IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () async {
                              await _updateActivityStatus("Feito");
                              setState(() {
                                widget.activity.status = "Feito";
                              });
                            },
                          );
                        } else if (activityStatus == "Feito") {
                          return Text(
                            "Feito",
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          );
                        } else if (widget.activity.dueDate != null &&
                            DateTime.now().isAfter(widget.activity.dueDate!)) {
                          return Text(
                            "Pendente",
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          );
                        }

                        return const SizedBox.shrink();
                      },
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
