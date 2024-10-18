import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import 'package:galaxy_mini/utils/keys.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Function(String?)? onSearch; // Dynamic search function
  final bool isMenu;
  final bool isSearch;
  final bool actions;
  final Widget? actionWidget;
  final bool isLeading;
  final Widget? leadingWidget;

  const MainAppBar({
    super.key,
    this.title,
    this.onSearch,
    this.isMenu = false,
    this.isSearch = false,
    this.actions = false,
    this.actionWidget,
    this.isLeading = false,
    this.leadingWidget,
  });

  @override
  _MainAppBarState createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainAppBarState extends State<MainAppBar> {
  bool _isSearching = false; // Whether search mode is active
  late TextEditingController _searchController; // To manage search input

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.lightPink,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              onChanged: (value) {
                if (widget.onSearch != null) {
                  widget.onSearch!(
                      value); // Pass search value to the page's search logic
                }
              },
            )
          : Text(
              widget.title ?? "",
              style: const TextStyle(color: Colors.black),
            ),
      leading: widget.isMenu
          ? IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            )
          : widget.isLeading
              ? widget.leadingWidget
              : null,
      actions: <Widget>[
        if (widget.actions)
          SizedBox(
            child: widget.actionWidget,
          ),
        if (widget.isSearch)
          IconButton(
            icon: _isSearching
                ? const Icon(
                    Icons.clear,
                    color: Colors.black,
                  )
                : const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear(); // Clear search input
                  if (widget.onSearch != null) {
                    widget.onSearch!(null); // Reset search
                  }
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
      ],
    );
  }
}
