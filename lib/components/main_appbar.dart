import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import '../utils/keys.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Function(String?)? onSearch;
  final bool isMenu;

  final bool isSearch;
  final bool actions;
  final Widget? actionWidget;

  const MainAppBar({
    super.key,
    this.title,
    this.onSearch,
    this.isMenu = false,
    this.isSearch = false,
    this.actions = false,
    this.actionWidget,
  });

  @override
  _MainAppBarState createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainAppBarState extends State<MainAppBar> {
  bool _isSearching = false;
  late TextEditingController _searchController;

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

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      widget.onSearch!('');
    });
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
              onChanged: widget.onSearch, // Dynamic search
            )
          : Text(
              widget.title ?? "",
              style: const TextStyle(color: Colors.black),
            ),
      leading: widget.isMenu
          ? IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            )
          : null,
      actions: <Widget>[
        if (widget.actions)
          SizedBox(
            child: widget.actionWidget,
          ),
        if (widget.isSearch)
          if (_isSearching)
            IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.black,
              ),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: _startSearch,
            ),
      ],
    );
  }
}
