import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';

class PLUScreen extends StatefulWidget {
  const PLUScreen({super.key});

  @override
  _PLUScreenState createState() => _PLUScreenState();
}

class _PLUScreenState extends State<PLUScreen> {
  String displayText = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'X') {
        if (displayText.isNotEmpty) {
          displayText = displayText.substring(0, displayText.length - 1);
        }
        if (displayText.isEmpty) {
          displayText = '0';
        }
      } else if (value == '+/-') {
        displayText = displayText.startsWith('-')
            ? displayText.substring(1)
            : '-$displayText';
      } else if (value == 'PLU' || value == 'Price') {
        // Implement PLU and Price functionality here
      } else {
        if (displayText == '0') {
          displayText = value;
        } else {
          displayText += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: const MainAppBar(
        isMenu: true,
        title: "PLU",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(16.0),
              color: Colors.white.withOpacity(0.5),
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('X'), // Delete key
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('+/-'),
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('PLU'),
                _buildButton('0'),
                _buildButton('00'),
                _buildButton('.'),
                _buildButton('Price'),
              ],
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.white, // Button background color
        foregroundColor: Colors.black, // Button text color
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(label),
    );
  }
}
