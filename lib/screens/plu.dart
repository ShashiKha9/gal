import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';

class PLUScreen extends StatelessWidget {
  const PLUScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "PLU Screen",
        onSearch: (p0) {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16.0),
                color: Colors.black12,
                child: const Text(
                  '0',
                  style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 5,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label) {
    return ElevatedButton(
      onPressed: () {
        // Implement the button's functionality here
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.grey[200],
        foregroundColor: const Color(0xFFC41E3A), // Apply red color to the text
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(label),
    );
  }
}
