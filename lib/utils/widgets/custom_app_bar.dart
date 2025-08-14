import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/theme_provider.dart';
import '../constants/colors.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showThemeToggle;
  final Widget? leading;
  final bool floating;
  final bool pinned;
  final bool snap;
  final double? expandedHeight;

  const CustomSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showThemeToggle = true,
    this.leading,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.expandedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: TColors.primary,
      elevation: 0,
      title: titleWidget ??
          Image.asset(
            "assets/images/tdiscount_images/Logo-Tdiscount-market-noire.png",
            height: 40,
            fit: BoxFit.contain,
          ),
      centerTitle: true,
      leading: leading,
      automaticallyImplyLeading: false,
      floating: floating,
      pinned: pinned,
      snap: snap,
      expandedHeight: expandedHeight,
      actions: [
        if (actions != null) ...actions!,
        if (showThemeToggle)
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return PopupMenuButton<ThemeMode>(
                icon: Icon(
                  themeProvider.themeIcon,
                  color: TColors.black,
                ),
                onSelected: (ThemeMode mode) {
                  themeProvider.setTheme(mode);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Row(
                      children: [
                        Icon(
                          Icons.brightness_auto,
                          color: themeProvider.themeMode == ThemeMode.system
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('System'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color: themeProvider.themeMode == ThemeMode.light
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('Light'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('Dark'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
