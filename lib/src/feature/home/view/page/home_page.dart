import 'package:flutter/material.dart';

import '../../repository/subject_model.dart';
import 'subject_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildSubjectCard(
      BuildContext context, double cardHeight, Subject subject) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectDetailsPage(subject: subject),
            ),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
            height: cardHeight,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      subject.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text(
                    subject.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    subject.teacher,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Cancelar Inscrição'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 8,
                    onSelected: (value) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.21;
    return Scaffold(
      body: ListView.builder(
        itemCount: Subject.subjects.length,
        itemBuilder: (context, index) {
          return buildSubjectCard(context, cardHeight, Subject.subjects[index]);
        },
      ),
    );
  }
}
