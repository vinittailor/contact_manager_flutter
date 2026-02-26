import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/contact_controller.dart';
import '../screens/contacts_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/contact_detail_screen.dart';
import '../../../core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Breakpoint for tablet two-pane layout.
  static const double _tabletBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > _tabletBreakpoint;

        return Scaffold(
          body: isTablet
              ? _TabletLayout(controller: controller)
              : _PhoneLayout(controller: controller),
          bottomNavigationBar: Obx(
            () => NavigationBar(
              selectedIndex: controller.selectedTabIndex.value,
              onDestinationSelected: controller.changeTab,
              animationDuration: const Duration(milliseconds: 400),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.contacts_outlined),
                  selectedIcon: Icon(Icons.contacts),
                  label: AppStrings.contactsTab,
                ),
                NavigationDestination(
                  icon: Icon(Icons.star_outline_rounded),
                  selectedIcon: Icon(Icons.star_rounded),
                  label: AppStrings.favoritesTab,
                ),
              ],
            ),
          ),
          floatingActionButton: const _BuildFAB(),
        );
      },
    );
  }
}

// PHONE LAYOUT — IndexedStack keeps tab state alive across switches

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.controller});

  final ContactController controller;

  @override
  Widget build(BuildContext context) {
    // Only the IndexedStack index is reactive — children stay alive.
    return Obx(
      () => IndexedStack(
        index: controller.selectedTabIndex.value,
        children: const [
          ContactsScreen(),
          FavoritesScreen(),
        ],
      ),
    );
  }
}

// TABLET LAYOUT — two-pane master-detail

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.controller});

  final ContactController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Left Pane: List (flex 2)
        Expanded(
          flex: 2,
          child: Obx(
            () => IndexedStack(
              index: controller.selectedTabIndex.value,
              children: [
                ContactsScreen(
                  onContactTap: controller.selectContact,
                ),
                FavoritesScreen(
                  onContactTap: controller.selectContact,
                ),
              ],
            ),
          ),
        ),

        // Divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: colors.outline.withAlpha(40),
        ),

        // Right Pane: Detail (flex 3) with crossfade
        Expanded(
          flex: 3,
          child: Obx(() {
            final selected = controller.selectedContact.value;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: selected == null
                  ? const _DetailPlaceholder(key: ValueKey('placeholder'))
                  : ContactDetailPane(
                      key: ValueKey('${selected.id}_${selected.updatedAt}'),
                      contact: selected,
                    ),
            );
          }),
        ),
      ],
    );
  }
}

// DETAIL PLACEHOLDER — decorative illustration for empty right pane
class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + 0.1 * value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decorative rings
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _Ring(size: 120, color: colors.primary.withAlpha(16)),
                    _Ring(size: 96, color: colors.primary.withAlpha(24)),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.primary.withAlpha(16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.touch_app_rounded,
                        size: 32,
                        color: colors.primary.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.selectContact,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface.withAlpha(150),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.selectContactHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FAB — separated to avoid unnecessary rebuilds

class _BuildFAB extends StatelessWidget {
  const _BuildFAB();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactController>();

    return FloatingActionButton.extended(
      heroTag: 'add_contact_fab',
      onPressed: controller.onAddPressed,
      icon: const Icon(Icons.person_add_alt_1_rounded),
      label: const Text(AppStrings.addLabel),
    );
  }
}

// DECORATIVE RING — reusable circle border for empty states

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
