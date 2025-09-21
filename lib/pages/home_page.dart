import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_mate/widgets/grid_widgets.dart';
import 'package:study_mate/widgets/sidebar.dart';
import 'package:study_mate/widgets/todo_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  get maxCrossAxisExtent => null;

  final NotchBottomBarController controller = NotchBottomBarController(
    index: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'HomePage',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TodoWidget(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  GridWidgets(
                    title: 'Books',
                    icon: Icons.menu_book,
                    color: Colors.deepPurple,
                  ),
                  GridWidgets(
                    title: 'Scanned Notes',
                    icon: Icons.note_alt,
                    color: Colors.teal,
                  ),
                  GridWidgets(
                    title: 'Screenshots/Images',
                    icon: Icons.image,
                    color: Colors.orange,
                  ),
                  GridWidgets(
                    title: 'Typed Notes',
                    icon: Icons.keyboard,
                    color: Colors.blue,
                  ),
                  GridWidgets(
                    title: 'Reference Links',
                    icon: Icons.link,
                    color: Colors.green,
                  ),
                  GridWidgets(
                    title: 'Other Documents',
                    icon: Icons.folder,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: controller,
        bottomBarWidth: MediaQuery.of(context).size.width,
        // notchColor: Colors.black87,
        bottomBarHeight: 30.0,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_filled, color: Colors.black),
            activeItem: Icon(Icons.home_filled, color: Colors.blueAccent),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person_sharp, color: Colors.black),
            activeItem: Icon(Icons.person_sharp, color: Colors.blueAccent),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.bar_chart, color: Colors.black),
            activeItem: Icon(Icons.bar_chart, color: Colors.blueAccent),
          ),
        ],
        onTap: (int value) {},
        kIconSize: 10,
        kBottomRadius: 50,
      ),
    );
  }
}
