import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:professor_ia/src/feature/home/usecase/firestore_service.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_text_field.dart';
import '../../repository/activity.dart';
import '../widget/activity_card.dart';
import '../widget/class_list_view.dart';

class ActivityFormPage extends StatefulWidget {
  final Activity? activity;

  const ActivityFormPage({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  bool _isLoading = false;
  List selectedClasses = [];
  final _formData = <String, Object>{};
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedClasses = widget.activity?.classes.toList() ?? [];
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      if (widget.activity != null) {
        _formData['id'] = widget.activity!.id;
        _formData['description'] = widget.activity!.description;
        _formData['subjectId'] = widget.activity!.subjectId;
        _formData['professorId'] = widget.activity!.user.id;
        _formData['classes'] = widget.activity!.classes;
        _formData['assignedDate'] = widget.activity!.assignedDate;
        _formData['dueDate'] = widget.activity!.dueDate ?? DateTime.now();

        selectedClasses = widget.activity?.classes.toList() ?? [];
      }
    }
  }

  void updateSelectedClasses(bool isChecked, String classOption) {
    setState(() {
      if (isChecked) {
        selectedClasses.remove(classOption);
      } else {
        selectedClasses.add(classOption);
      }
    });
  }

  Future<bool?> _showDialog(String title, String content) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
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

  Future<void> _submitForm() async {
    final firestoreProvider =
        Provider.of<FirestoreService>(context, listen: false);
    final confirm = await _showDialog(
      'upload_activity'.i18n(),
      'are_you_sure'.i18n(),
    );
    if (confirm!) {
      setState(() => _isLoading = true);

      try {
        if (widget.activity != null) {
          widget.activity!.classes = selectedClasses;
          await firestoreProvider.updateActivity(widget.activity!);
        } else {
          //await firestoreProvider.createActivity(widget.activity!);
        }
      } catch (error) {
        await _showDialog(
          'error_occurred'.i18n(),
          'error_updating_subject'.i18n(),
        );
      } finally {
        Modular.to.pop();
        setState(() => _isLoading = false);
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('activity_form'.i18n()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _submitForm(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (widget.activity != null)
                    ActivityCard(
                      activity: widget.activity!,
                      user: widget.activity!.user,
                      isProfessor: widget.activity!.user.isProfessor,
                      isForm: true,
                    ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    text: 'description_field'.i18n(),
                    controller: _descriptionController,
                    initialValue: _formData['description']?.toString(),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    onSaved: (description) =>
                        _formData['description'] = description ?? '',
                    validator: (userDescription) {
                      final description = userDescription ?? '';

                      if (description.trim().isEmpty) {
                        return 'description_required'.i18n();
                      }

                      if (description.trim().length < 10) {
                        return 'description_invalid'.i18n();
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ClassListView(
                    selectedClasses: selectedClasses,
                    onClassItemTap: updateSelectedClasses,
                  ),
                ],
              ),
            ),
    );
  }
}
