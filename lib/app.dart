import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/PLU.dart';
import 'package:galaxy_mini/screens/department.dart';
import 'package:galaxy_mini/screens/item_page.dart';
import 'package:galaxy_mini/screens/park_orders.dart';
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
    const ParkOrderScreen(
      parkedOrders: [],
    ),
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
    // _syncProvider.getItemsAll();
    // _syncProvider.getDepartmentsAll();
    // _fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color for the Scaffold
      key: scaffoldKey, // Use MainAppBar here with widget.title
      drawer: const SideDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: const Color(
            0xFFC41E3A), // Red background color for the BottomNavigationBar
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              label: 'Hot Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.price_change),
              label: 'NPOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Department',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              label: 'Parked orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.print_rounded),
              label: 'Previous bill',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800], // Color for selected item
          unselectedItemColor: Colors.white, // Color for unselected items
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
