import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/pages/new_notes.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/notes_card.dart';

class HomePage extends StatelessWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, NewNotes.route());
            },
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          //date selector
          const DateSelector(),
          Row(
            children: [
              Expanded(
                child: NotesCard(
                  color: Color.fromRGBO(246, 222, 194, 1),
                  headerText: 'First Note',
                  descriptionText: 'This is the first note',
                ),
              ),
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: strengthenColor(
                    const Color.fromRGBO(246, 222, 194, 1),
                    0.69,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('10:00 AM', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
