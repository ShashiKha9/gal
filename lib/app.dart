import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/PLU.dart';
import 'package:galaxy_mini/screens/department.dart';
import 'package:galaxy_mini/screens/item_page.dart';
import 'package:galaxy_mini/screens/park_orders.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/utils/keys.dart';
import 'components/side_drawer.dart';
import 'home_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const ItemPage(),
    const PLUScreen(),
    const DepartmentPage(),
    const ParkOrderScreen(),
    const HomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedLabelStyle: const TextStyle(color: Colors.white60),
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          backgroundColor: AppColors.greenTwo,
          items: const [
            BottomNavigationBarItem(
              label: 'Hot Menu',
              icon: Icon(Icons.local_fire_department_outlined),
              activeIcon: Icon(Icons.local_fire_department),
              backgroundColor: AppColors.greenTwo,
            ),
            BottomNavigationBarItem(
              label: 'PLU',
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              backgroundColor: AppColors.greenTwo,
            ),
            BottomNavigationBarItem(
              label: 'Department',
              icon: Icon(Icons.menu_book),
              activeIcon: Icon(Icons.menu_book),
              backgroundColor: AppColors.greenTwo,
            ),
            BottomNavigationBarItem(
              label: 'Parked orders',
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              backgroundColor: AppColors.greenTwo,
            ),
            BottomNavigationBarItem(
              label: 'Previous bill',
              icon: Icon(Icons.print_outlined),
              activeIcon: Icon(Icons.print),
              backgroundColor: AppColors.greenTwo,
            ),
          ],
        ),
      ),
    );
  }
}
