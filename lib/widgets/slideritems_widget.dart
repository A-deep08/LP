// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_mate/pages/notes_page.dart';
import 'package:study_mate/pages/todo_widget.dart';

class SlideritemsWidget extends StatelessWidget {
  const SlideritemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> CarouselItems = [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TodoWidget()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          height: 100,
          width: 400,
          alignment: Alignment.center,
          child: Text(
            'To-do list',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesWidget()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          height: 100,
          width: 400,
          alignment: Alignment.center,
          child: Text(
            'Notes',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ];
    return CarouselSlider(
      items: CarouselItems,
      options: CarouselOptions(height: 100.0,padEnds: true,viewportFraction: 0.8,scrollPhysics: const BouncingScrollPhysics(),
      ),
      
    );
  }
}
