import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../repository/subject.dart';

class SubjectCard extends StatelessWidget {
  final double cardHeight;
  final Subject subject;

  const SubjectCard({
    super.key,
    required this.cardHeight,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Modular.to.pushNamed('details/', arguments: subject);
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
                    subject.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    subject.teachers[0],
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
