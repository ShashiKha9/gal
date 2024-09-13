import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';
import '../utils/keys.dart';
import 'dart:math' as math;

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Function(String?)? onSearch;
  final bool isMenu;
  final bool isRate;
  final bool isSearch;

  const MainAppBar({
    super.key,
    this.title,
    this.onSearch,
    this.isRate = false,
    this.isMenu = true,
    this.isSearch = false,
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
      backgroundColor: AppColors.white,
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
        if (widget.isRate)
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                const Text(
                  "Rate 1",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: const Icon(
                    Icons.compare_arrows,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
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
