import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_dropdown.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/home_screens/example_page.dart';
import 'package:galaxy_mini/screens/report_screens/billwise_report_screen.dart';
import 'package:galaxy_mini/screens/report_screens/itemwise_report_screen.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ReportSceens extends StatefulWidget {
  const ReportSceens({super.key});

  @override
  State<ReportSceens> createState() => _ReportSceensState();
}

class _ReportSceensState extends State<ReportSceens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DateTime? fromDate;
  DateTime? toDate;
  String? selectedOrderStatus = 'All Payment';
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);

    fromDate = DateTime.now();
    toDate = DateTime.now();
  }

  final List<String> _tabTitles = [
    "Billwise Report",
    "Itemwise Report",
    "Departmentwise Report",
    "Datewise Report",
    "Cancelled Billwise Report",
    "NC Billwise Report",
    "Upcoming Order Itemwise Report",
    "Customerwise Report",
  ];

  final List<Widget> _tabContent = [
    const BillwiseReportScreen(),
    const ItemwiseReportScreen(),
    const ExamplePage(),
    const ExamplePage(),
    const ExamplePage(),
    const ExamplePage(),
    const ExamplePage(),
    const ExamplePage(),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: _tabTitles[_tabController.index],
        actions: true,
        isLeading: true,
        leadingWidget: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actionWidget: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 70),
            ...List.generate(_tabTitles.length, (index) {
              return _buildTab(context, index, _tabTitles[index]);
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('From Date'),
                      ElevatedButton(
                        onPressed: () => _selectFromDate(context),
                        child:
                            Text(DateFormat('dd MMMM yyyy').format(fromDate!)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('To Date'),
                      ElevatedButton(
                        onPressed: () => _selectToDate(context),
                        child: Text(DateFormat('dd MMMM yyyy').format(toDate!)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_tabTitles[_tabController.index] == "Billwise Report" ||
                  _tabTitles[_tabController.index] ==
                      "Cancelled Billwise Report")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppDropdown(
                    labelText: "Payment Mode",
                    value: selectedOrderStatus,
                    items: const [
                      "All Payment",
                      "Card",
                      "Cash",
                      "UPI",
                      "Credit Party",
                      "Multiple Payment",
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedOrderStatus = value;
                        // Fetch orders only when order status is changed, if needed
                        // _loadOrders();
                      });
                    },
                  ),
                ),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: _tabContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title) {
    bool isSelected = _tabController.index == index;
    return Container(
      color: isSelected ? AppColors.lightPink : Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        onTap: () {
          _tabController.index = index;
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fromDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != fromDate) {
      setState(() {
        fromDate = pickedDate;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: toDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != toDate) {
      setState(() {
        toDate = pickedDate;
      });
    }
  }
}
