import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:professor_ia/src/feature/home/repository/subject_list.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_text_field.dart';
import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/activity.dart';
import '../../repository/activity_list.dart';
import '../../repository/subject.dart';
import '../widget/activity_card.dart';
import '../widget/class_list_view.dart';
import '../widget/date_picker.dart';

class ActivityFormPage extends StatefulWidget {
  const ActivityFormPage({
    super.key,
  });

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  bool _isEdit = false;
  bool _isLoading = false;
  List _selectedClasses = [];

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object?>{};
  final _originalFormData = <String, Object?>{};
  final _descriptionController = TextEditingController();
  late final UserModel? currentUser;
  late List<Subject> subject;
  bool _isSnackBarVisible = false;
  final List<SnackBar> _snackBarQueue = [];

  @override
  void initState() {
    final AuthViewModel authProvider = Provider.of(context, listen: false);
    currentUser = authProvider.currentUser;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _snackBarQueue.clear();
    _descriptionController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg != null) {
      final activity = arg as Activity;
      _formData['id'] = activity.id;
      _formData['description'] = activity.description;
      _formData['subjectId'] = activity.subjectId;
      _formData['professorId'] = activity.user.id;
      _formData['classes'] = activity.classes;
      _formData['assignedDate'] = activity.assignedDate;
      _formData['dueDate'] = activity.dueDate;

      _originalFormData['id'] = activity.id;
      _originalFormData['description'] = activity.description;
      _originalFormData['subjectId'] = activity.subjectId;
      _originalFormData['professorId'] = activity.user.id;
      _originalFormData['classes'] = activity.classes;
      _originalFormData['assignedDate'] = activity.assignedDate;
      _originalFormData['dueDate'] = activity.dueDate;

      _selectedClasses = activity.classes.toList();
      _descriptionController.text = _formData['description']?.toString() ?? '';
      _isEdit = true;
    }
  }

  void updateDatePicker(DateTime? pickedDate) {
    setState(() {
      _formData['dueDate'] = pickedDate;
    });
  }

  void updateSelectedClasses(bool isChecked, String classOption) {
    setState(() {
      if (isChecked) {
        _selectedClasses.remove(classOption);
      } else {
        _selectedClasses.add(classOption);
      }
      _formData['classes'] = _selectedClasses;
    });
  }

  void _showStatusSnackBar({bool isEqual = false}) {
    final snackBar = SnackBar(
      content: Text(isEqual ? 'no_change'.i18n() : 'classes_empty'.i18n()),
      backgroundColor: Theme.of(context).colorScheme.error,
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

  Future<void> _showErrorDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('error_occurred'.i18n()),
          content: Text('error_activity'.i18n()),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_selectedClasses.isEmpty) {
      _showStatusSnackBar();
      return;
    }

    if (!isValid ||
        (_formData.toString() == _originalFormData.toString() &&
            _descriptionController.text == _originalFormData['description'])) {
      _showStatusSnackBar(isEqual: true);
      return;
    }

    _formKey.currentState?.save();

    final ActivityList activityProvider = Provider.of(context, listen: false);

    setState(() => _isLoading = true);

    try {
      _isEdit
          ? await activityProvider.updateActivity(_formData, subject.first.id)
          : await activityProvider.createActivity(
              _formData, currentUser!, subject.first.id);
    } catch (error) {
      await _showErrorDialog();
    } finally {
      Modular.to.pop();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SubjectList subjectProvider = Provider.of(context);
    subject = subjectProvider.subjectById(currentUser!.classroom);
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    ActivityCard(
                      subject: subject.first,
                      activity: Activity(
                        id: '',
                        user: currentUser!,
                        subjectId: '',
                        classes: _selectedClasses,
                        description: _descriptionController.text,
                        editDate: Timestamp.fromDate(DateTime.now()),
                        assignedDate: Timestamp.fromDate(
                            _formData['assignedDate'] as DateTime? ??
                                DateTime.now()),
                      ),
                      isForm: true,
                      isEdit: _isEdit,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CustomTextField(
                        text: 'description_field'.i18n(),
                        controller: _descriptionController,
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
                    ),
                    const SizedBox(height: 10),
                    DatePicker(
                      selectedDate: _formData['dueDate'] as DateTime?,
                      onDateChanged: updateDatePicker,
                    ),
                    const SizedBox(height: 10),
                    ClassListView(
                      selectedClasses: _selectedClasses,
                      onClassItemTap: updateSelectedClasses,
                      classOptions: subject.first.classes,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
