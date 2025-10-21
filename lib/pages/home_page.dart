import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_mate/widgets/chatbot/ui.dart';
import 'package:study_mate/widgets/grid_widgets.dart';
import 'package:study_mate/widgets/sidebar.dart';
import 'package:study_mate/widgets/slideritems_widget.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.circle_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Ui();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SlideritemsWidget(),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 190,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                children: [
                  GridWidgets(
                    title: 'Books',
                    icon: Icons.menu_book,
                    color: Color(0xFFB5EAEA),
                  ),
                  GridWidgets(
                    title: 'Scanned Notes',
                    icon: Icons.note_alt,
                    color: Color(0xFFFFBCBC),
                  ),
                  GridWidgets(
                    title: 'Screenshots/Images',
                    icon: Icons.image,
                    color: Color(0xFFFFE59D),
                  ),
                  GridWidgets(
                    title: 'Ideas',
                    icon: Icons.keyboard,
                    color: Color(0xFFC3FBD8),
                  ),
                  GridWidgets(
                    title: 'Reference Links',
                    icon: Icons.link,
                    color: Color(0xFFD7BCE8),
                  ),
                  GridWidgets(
                    title: 'Other Documents',
                    icon: Icons.folder,
                    color: Color(0xFFB5C6E0),
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
            activeItem: Icon(Icons.home_filled, color: Colors.black),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person, color: Colors.black),
            activeItem: Icon(Icons.person, color: Colors.black),
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.bar_chart, color: Colors.black),

            activeItem: Icon(Icons.bar_chart, color: Colors.black),
          ),
        ],
        onTap: (int value) {
          controller.index = value;
          setState(() {});
        },
        kIconSize: 10,
        kBottomRadius: 50,
      ),
    );
  }
}
