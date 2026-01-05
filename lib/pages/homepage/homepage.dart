import 'package:flutter/material.dart';
import 'package:study_mate/widgets/grid_widgets.dart';
import 'package:study_mate/widgets/slideritems_widget.dart';

class HomepageContent extends StatelessWidget {
  const HomepageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
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
    );
  }
}
