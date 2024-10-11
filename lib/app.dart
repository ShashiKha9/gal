import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/scaffold_message.dart';
import 'package:galaxy_mini/screens/home_screens/department_screen.dart';
import 'package:galaxy_mini/screens/home_screens/hot_items_screen.dart';
import 'package:galaxy_mini/screens/home_screens/parked_orders_screen.dart';
import 'package:galaxy_mini/screens/home_screens/plu_screen.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/side_drawer.dart';
import 'screens/home_screens/example_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;
  bool showPLU = false; // New variable to manage PLU visibility

  static List<Widget> _widgetOptions = <Widget>[
    const HotItemsScreen(),
    const PLUScreen(),
    const DepartmentScreen(),
    const ParkedOrderScreen(),
    const ExamplePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      final isReprintSelected = showPLU ? index == 4 : index == 3;

      if (isReprintSelected) {
        scaffoldMessage(message: "Unable to Connect Printer!");
      } else {
        _selectedIndex = index;
      }
    });
  }

  Future<void> _loadShowPLU() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showPLU = prefs.getBool('showPLU') ?? false;

    setState(() {
      _widgetOptions = [
        const HotItemsScreen(),
        if (showPLU) const PLUScreen(), // Conditionally include PLUScreen
        const DepartmentScreen(),
        const ParkedOrderScreen(),
        const ExamplePage(),
      ];
    });
  }

  void _updatePLUVisibility() {
    _loadShowPLU(); // Call to load the updated PLU visibility
  }

  @override
  void initState() {
    super.initState();
    _loadShowPLU();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const SideDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          backgroundColor: AppColors.lightPink,
          items: [
            const BottomNavigationBarItem(
              label: 'Hot Menu',
              icon: Icon(Icons.local_fire_department_outlined),
              activeIcon: Icon(Icons.local_fire_department, color: Colors.red),
              backgroundColor: AppColors.lightPink,
            ),
            if (showPLU) // Use the state variable here
              const BottomNavigationBarItem(
                label: 'PLU',
                icon: Icon(Icons.calculate_outlined),
                activeIcon: Icon(Icons.calculate),
                backgroundColor: AppColors.lightPink,
              ),
            const BottomNavigationBarItem(
              label: 'Dept',
              icon: Icon(Icons.window_outlined),
              activeIcon: Icon(Icons.window),
              backgroundColor: AppColors.lightPink,
            ),
            const BottomNavigationBarItem(
              label: 'Parked',
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              backgroundColor: AppColors.lightPink,
            ),
            const BottomNavigationBarItem(
              label: 'RePrint',
              icon: ImageIcon(AssetImage(AppIcons.rePrintIcon)),
              activeIcon: ImageIcon(AssetImage(AppIcons.rePrintIcon)),
              backgroundColor: AppColors.lightPink,
            ),
          ],
        ),
      ),
    );
  }
}
