import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/department.dart';
import 'package:galaxy_mini/screens/item_page.dart';
import 'package:galaxy_mini/screens/park_orders.dart';
import 'package:galaxy_mini/screens/plu_screen.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/utils/keys.dart';
import 'components/side_drawer.dart';
import 'example_page.dart';

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
    const ExamplePage(),
  ];

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = index;
        });
      case 1:
        setState(() {
          _selectedIndex = index;
        });
      case 2:
        setState(() {
          _selectedIndex = index;
        });
      case 3:
        setState(() {
          _selectedIndex = index;
        });
      case 4:
        showModal(context);
    }
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
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          backgroundColor: AppColors.lightPink,
          items: const [
            BottomNavigationBarItem(
              label: 'Hot Menu',
              icon: Icon(
                Icons.local_fire_department_outlined,
              ),
              activeIcon: Icon(
                Icons.local_fire_department,
                color: Colors.red,
              ),
              backgroundColor: AppColors.lightPink,
            ),
            BottomNavigationBarItem(
              label: 'PLU',
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              backgroundColor: AppColors.lightPink,
            ),
            BottomNavigationBarItem(
              label: 'Department',
              icon: Icon(Icons.window_outlined),
              activeIcon: Icon(Icons.window),
              backgroundColor: AppColors.lightPink,
            ),
            BottomNavigationBarItem(
              label: 'Parked',
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              backgroundColor: AppColors.lightPink,
            ),
            BottomNavigationBarItem(
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

  void showModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Example Dialog'),
        actions: <TextButton>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}
