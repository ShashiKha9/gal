import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_dropdown.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:galaxy_mini/screens/master_settings_screens/customer_masters/add_new_customer.dart';
import 'package:galaxy_mini/screens/report_screens/billwise_report_screen.dart';
import 'package:galaxy_mini/screens/report_screens/cancelled_billwise_screen.dart';
import 'package:galaxy_mini/screens/report_screens/customerwise_report_screen.dart';
import 'package:galaxy_mini/screens/report_screens/datewise_reposrt_screen.dart';
import 'package:galaxy_mini/screens/report_screens/departmentwise_report_screen.dart';
import 'package:galaxy_mini/screens/report_screens/itemwise_report_screen.dart';
import 'package:galaxy_mini/screens/report_screens/nc_billwise_report.dart';
import 'package:galaxy_mini/screens/report_screens/upcoming_itemwise_report.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/theme/font_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReportSceens extends StatefulWidget {
  const ReportSceens({super.key});

  @override
  State<ReportSceens> createState() => _ReportSceensState();
}

class _ReportSceensState extends State<ReportSceens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showViewSummary = false;

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

  String? selectedCustomerName;
  String? selectedCustomerCode;

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
    const DepartmentwiseReportScreen(),
    const DatewiseReportScreen(),
    const CancelledBillwiseScreen(),
    const NcBillwiseReport(),
    const UpcomingItemwiseReport(),
    const CustomerwiseReportScreen(),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // If the Screen is Customerwise then Floating Button with search will be displayed
          if (_tabTitles[_tabController.index] == "Customerwise Report")
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Customer Data"),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Consumer<SyncProvider>(
                            builder: (context, syncProvider, child) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: syncProvider.customerList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final customer = syncProvider.customerList[index];
                              return ListTile(
                                title: Text(
                                  '${customer.customerCode ?? 'No Code'} - ${customer.name ?? 'Unnamed'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Mobile: ${customer.mobile1 ?? 'No Number'}',
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedCustomerName = customer.name;
                                    selectedCustomerCode =
                                        customer.customerCode;
                                  });
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        }),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddNewCustomer(),
                              ),
                            );
                          },
                          child: const Text("Add new customer"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.search),
            )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View Summary
                  if (_tabTitles[_tabController.index] == "Billwise Report" ||
                      _tabTitles[_tabController.index] ==
                          "Departmentwise Report" ||
                      _tabTitles[_tabController.index] == "Datewise Report" ||
                      _tabTitles[_tabController.index] ==
                          "Cancelled Billwise Report")
                    viewSummary(),

                  // View Summary Details - Condition -> if showViewSummary & others are true
                  if (showViewSummary &&
                          _tabTitles[_tabController.index] ==
                              "Billwise Report" ||
                      showViewSummary &&
                          _tabTitles[
                                  _tabController.index] ==
                              "Departmentwise Report" ||
                      showViewSummary &&
                          _tabTitles[_tabController.index] ==
                              "Datewise Report" ||
                      showViewSummary &&
                          _tabTitles[_tabController.index] ==
                              "Cancelled Billwise Report")
                    viewSummaryDetails(),

                  // Button Of Print Report & Download & Share
                  if (_tabTitles[_tabController.index] == "Billwise Report" ||
                      _tabTitles[_tabController.index] == "Itemwise Report" ||
                      _tabTitles[_tabController.index] ==
                          "Departmentwise Report" ||
                      _tabTitles[_tabController.index] == "Datewise Report" ||
                      _tabTitles[_tabController.index] ==
                          "Cancelled Billwise Report")
                    printDownload(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
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
                            child: Text(
                                DateFormat('dd MMMM yyyy').format(fromDate!)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('To Date'),
                          ElevatedButton(
                            onPressed: () => _selectToDate(context),
                            child: Text(
                                DateFormat('dd MMMM yyyy').format(toDate!)),
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
                  // Expanded(
                  //   child: TabBarView(
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     controller: _tabController,
                  //     children: _tabContent,
                  //   ),
                  // ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _tabContent,
        ),
      ),
    );
  }

  Row viewSummary() {
    return Row(
      children: [
        Text("View Summary", style: blackBold),
        IconButton(
          icon: Icon(
            showViewSummary ? Icons.arrow_drop_down : Icons.arrow_drop_up,
          ),
          onPressed: () {
            setState(() {
              showViewSummary = !showViewSummary;
            });
          },
        ),
      ],
    );
  }

  Column viewSummaryDetails() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Items Sold: 1.0',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Cash Amount: 2000.0',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Total Amount: 2000.0',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 50),
      ],
    );
  }

  Row printDownload() {
    return Row(
      children: [
        AppButton(
          buttonText: "Print Report",
          onTap: () {},
        ),
        const SizedBox(width: 10),
        AppButton(
          buttonText: "Download & Share",
          onTap: () {},
        ),
      ],
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
