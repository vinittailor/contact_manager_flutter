import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../controllers/contact_controller.dart';
import '../data/models/contact_model.dart';
import '../data/models/contact_sort_type.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/app_colors.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, this.onContactTap});

  /// If provided (tablet mode), tapping a card calls this instead of navigating.
  final ValueChanged<Contact>? onContactTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.contactsTab),
        actions: [
          Obx(() {
            final current = controller.sortType.value;
            return PopupMenuButton<ContactSortType>(
              icon: Icon(
                current == ContactSortType.name
                    ? Icons.sort_by_alpha_rounded
                    : Icons.sort_rounded,
              ),
              tooltip: AppStrings.sortTooltip,
              onSelected: controller.onSortChanged,
              itemBuilder: (_) => ContactSortType.values.map((type) {
                return PopupMenuItem<ContactSortType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type == current
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: type == current
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchField(controller: controller),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const _ShimmerList();

        final contacts = controller.filteredContacts;

        if (contacts.isEmpty) {
          return _EmptyState(
            hasSearch: controller.searchQuery.value.isNotEmpty,
          );
        }

        final selectedId = controller.selectedContact.value?.id;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return _ContactCard(
              contact: contact,
              isSelected: onContactTap != null && contact.id == selectedId,
              onTap: () {
                if (onContactTap != null) {
                  onContactTap!(contact);
                } else {
                  controller.navigateToDetail(contact);
                }
              },
              onFavoriteToggle: () => controller.toggleFavorite(contact),
            );
          },
        );
      }),
    );
  }
}

// SEARCH FIELD
class _SearchField extends StatefulWidget {
  const _SearchField({required this.controller});
  final ContactController controller;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: _textController,
      onChanged: widget.controller.onSearchChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.onSurface.withAlpha(120),
        ),
        suffixIcon: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    key: const ValueKey('clear'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _textController.clear();
                      widget.controller.clearSearch();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withAlpha(100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// CONTACT AVATAR
class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.contact, this.radius = 24});

  final Contact contact;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = AppColors.avatarColor(contact.id ?? 0);

    if (contact.hasImage) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: FileImage(File(contact.imagePath!)),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        contact.initials,
        style: theme.textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}

// CONTACT CARD
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isSelected = false,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color:
              isSelected ? colors.primary.withAlpha(24) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary.withAlpha(60)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: colors.primary.withAlpha(20),
            highlightColor: colors.primary.withAlpha(10),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Hero(
                    tag: 'contact_avatar_${contact.id}',
                    child: _ContactAvatar(contact: contact, radius: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contact.phoneNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withAlpha(150),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        contact.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        key: ValueKey(contact.isFavorite),
                        color: contact.isFavorite
                            ? colors.tertiary
                            : colors.onSurface.withAlpha(100),
                        size: 24,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// EMPTY STATE
class _EmptyState extends StatelessWidget {
  const _EmptyState({this.hasSearch = false});
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DecorativeIcon(
                icon: hasSearch
                    ? Icons.search_off_rounded
                    : Icons.person_add_alt_1_rounded,
                ringColor: colors.primary,
              ),
              const SizedBox(height: 28),
              Text(
                hasSearch ? AppStrings.noResults : AppStrings.noContacts,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.withAlpha(200),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasSearch
                    ? AppStrings.tryDifferentSearch
                    : AppStrings.addFirstContact,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withAlpha(120),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// DECORATIVE ICON
class _DecorativeIcon extends StatelessWidget {
  const _DecorativeIcon({required this.icon, required this.ringColor});
  final IconData icon;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _Ring(size: 120, color: ringColor.withAlpha(20)),
          _Ring(size: 96, color: ringColor.withAlpha(30)),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ringColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: ringColor.withAlpha(180)),
          ),
        ],
      ),
    );
  }
}

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

// SHIMMER LOADING
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) => _ShimmerCard(delay: index * 80),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({required this.delay});
  final int delay;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final pulse = 0.5 + 0.5 * math.cos(_ctrl.value * 2 * math.pi);
        final alpha = ((0.04 + 0.06 * pulse) * 255).round().clamp(0, 255);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: baseColor.withAlpha(alpha),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 140,
                      decoration: BoxDecoration(
                        color: baseColor.withAlpha(alpha),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: baseColor.withAlpha((alpha * 0.8).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
