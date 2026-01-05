import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_mate/app/modules/search/bloc/search_bloc.dart';
import 'package:study_mate/app/modules/search/views/search_view.dart';
import 'package:study_mate/app/modules/to-do/bloc/todo_bloc.dart';
import 'package:study_mate/pages/homepage/homepage.dart';
import 'package:study_mate/widgets/chatbot/ui.dart';
import 'package:study_mate/widgets/sidebar.dart';
import 'package:study_mate/app/modules/notes/bloc/notes_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> titles = ['Home', 'Search', 'Statistics'];

  final NotchBottomBarController controller = NotchBottomBarController(
    index: 0,
  );

  int get currentIndex => controller.index;
  double sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 900;
    final bool isDesktop = width >= 900;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotesBloc()..add(LoadNotes())),
        BlocProvider(create: (_) => TodoBloc()..add(LoadTodos())),
        BlocProvider(create: (_) => SearchBloc()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotesBloc, NotesState>(
            listener: (context, state) {
              if (state is NotesLoaded) {
                context.read<SearchBloc>().add(UpdateSearchNotes(state.notes));
              }
            },
          ),
          BlocListener<TodoBloc, TodoState>(
            listener: (context, state) {
              if (state is TodoLoaded) {
                context.read<SearchBloc>().add(UpdateSearchTodos(state.todos));
              }
            },
          ),
        ],
        child: Scaffold(
          extendBody: true,

          drawer: isDesktop ? null : const Sidebar(),

          body: Row(
            children: [
              if (isDesktop) const Sidebar(),

              Expanded(
                child: Column(
                  children: [
                    AppBar(
                      centerTitle: true,
                      title: Text(
                        titles[currentIndex],
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.circle_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Ui()),
                            );
                          },
                        ),
                      ],
                    ),

                    Expanded(
                      child: IndexedStack(
                        index: currentIndex,
                        children: const [
                          HomepageContent(),
                          SearchView(),
                          Center(child: Text("Statistics Page")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: isMobile ? 0 : 12,
              left: isDesktop ? sidebarWidth : 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedNotchBottomBar(
                notchBottomBarController: controller,
                bottomBarWidth: isMobile
                    ? double.infinity
                    : isTablet
                    ? 420
                    : 360,
                bottomBarHeight: 70,

                kIconSize: 28,
                kBottomRadius: 50,
                bottomBarItems: const [
                  BottomBarItem(
                    inActiveItem: Icon(Icons.home_filled, color: Colors.black),
                    activeItem: Icon(Icons.home_filled, color: Colors.black),
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(Icons.search_sharp, color: Colors.black),
                    activeItem: Icon(Icons.search, color: Colors.black),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
