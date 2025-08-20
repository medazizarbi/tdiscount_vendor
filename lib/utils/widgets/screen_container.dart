import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ScreenContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ScreenContainer({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.primary,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: themedColor(
                    context, TColors.lightContainer, TColors.darkContainer),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // Title Container with styled background
                  Padding(
                    padding:
                        const EdgeInsets.all(8.0), // 8px padding from edges
                    child: Container(
                      width: double.infinity, // Expand to full width
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: themedColor(
                          context,
                          TColors.lightContainer,
                          TColors.carddark,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themedColor(
                              context,
                              TColors.black.withOpacity(0.5),
                              TColors.white.withOpacity(0.3),
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: themedColor(
                            context,
                            TColors.borderPrimary,
                            TColors.darkerGrey,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: themedColor(
                              context,
                              TColors.textPrimary,
                              TColors.textWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: padding ?? const EdgeInsets.all(8.0),
                    child: child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
