import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:galaxy_mini/screens/settings.dart';

class UpDownArrowIcon extends StatelessWidget {
  const UpDownArrowIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Icon(
          Icons.arrow_upward,
          color: Colors.black,
          size: 24.0,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Icon(
            Icons.arrow_downward,
            color: Colors.black,
            size: 24.0,
          ),
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> foodItems = [
    'Pizza', 'Burger', 'Pasta', 'Sushi',
    'Tacos', 'Salad', 'Steak', 'Ramen',
    'Chicken Wings', 'Burritos', 'Hot Dogs', 'Fried Rice',
    'Noodles', 'Falafel', 'Gyro', 'Dumplings',
    'Spring Rolls', 'Sandwich', 'Quesadilla', 'Mac & Cheese',
    'Lasagna', 'Calamari', 'Goulash', 'Bruschetta',
    'Pancakes', 'Waffles', 'Crepes', 'Croissant',
    'Bagels', 'Cheeseburger', 'Poke Bowl', 'Pad Thai',
    'Grilled Cheese', 'Banh Mi', 'Ceviche', 'Churros',
    'Samosas', 'Pita Bread', 'Nachos', 'Empanadas',
  ];

  final Map<String, double> foodPrices = {
    'Pizza': 150, 'Burger': 100, 'Pasta': 80, 'Sushi': 300,
    'Tacos': 180, 'Salad': 120, 'Steak': 200, 'Ramen': 250,
    'Chicken Wings': 230, 'Burritos': 190, 'Hot Dogs': 50, 'Fried Rice': 60,
    'Noodles': 120, 'Falafel': 170, 'Gyro': 130, 'Dumplings': 220,
    'Spring Rolls': 155, 'Sandwich': 30, 'Quesadilla': 90, 'Mac & Cheese': 210,
    'Lasagna': 250, 'Calamari': 225, 'Goulash': 230, 'Bruschetta': 300,
    'Pancakes': 120, 'Waffles': 165, 'Crepes': 175, 'Croissant': 90,
    'Bagels': 45, 'Cheeseburger': 125, 'Poke Bowl': 180, 'Pad Thai': 160,
    'Grilled Cheese': 130, 'Banh Mi': 170, 'Ceviche': 135, 'Churros': 165,
    'Samosas': 20, 'Pita Bread': 45, 'Nachos': 170, 'Empanadas': 155,
  };

  final Map<String, int> selectedItems = {};
  double _totalPrice = 0.0;
  String? _lastSelectedItem;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _selectItem(String item) {
    _audioPlayer.play(AssetSource('assets/beep.mp3')); // Play beep sound

    setState(() {
      _lastSelectedItem = item;
      if (selectedItems.containsKey(item)) {
        selectedItems[item] = selectedItems[item]! + 1;
      } else {
        selectedItems[item] = 1;
      }
      _totalPrice += foodPrices[item]!;
    });
  }

  void _incrementQuantity() {
    if (_lastSelectedItem != null) {
      setState(() {
        selectedItems[_lastSelectedItem!] = selectedItems[_lastSelectedItem!]! + 1;
        _totalPrice += foodPrices[_lastSelectedItem!]!;
      });
    }
  }

  void _decrementQuantity() {
    if (_lastSelectedItem != null && selectedItems[_lastSelectedItem!]! > 0) {
      setState(() {
        _totalPrice -= foodPrices[_lastSelectedItem!]!;
        selectedItems[_lastSelectedItem!] = selectedItems[_lastSelectedItem!]! - 1;

        if (selectedItems[_lastSelectedItem!] == 0) {
          selectedItems.remove(_lastSelectedItem!);
          _lastSelectedItem = selectedItems.isNotEmpty ? selectedItems.keys.last : null;
        }
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galaxy Mini'),
        leading: Builder(
          builder: (BuildContext context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFC41E3A),
              ),
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Upcoming orders'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Customer Credits'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync data'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1,
          ),
          itemCount: foodItems.length,
          itemBuilder: (context, index) {
            final item = foodItems[index];
            return GestureDetector(
              onTap: () => _selectItem(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: const Color(0xFFC41E3A),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_lastSelectedItem != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        '${selectedItems[_lastSelectedItem]}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _lastSelectedItem!,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: Rs.${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.print),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => BillPage(
                  //           selectedItems: selectedItems,
                  //           foodPrices: foodPrices,
                  //           totalPrice: _totalPrice,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}