import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.onPrimaryContainer,
      title: Text(
        'HEADCHECKER',
        style: GoogleFonts.montserrat(
          fontSize: 25,
          color: colorScheme.primaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      toolbarHeight: 50,
    );
  }
}
