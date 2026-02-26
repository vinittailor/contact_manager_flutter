import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/contact_controller.dart';
import '../data/models/contact_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/app_colors.dart';

// CONTACT DETAIL SCREEN — Full-screen (phone layout)
class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactController>();

    // Seed selectedContact from route arguments (only first build).
    final initial = Get.arguments as Contact;
    if (controller.selectedContact.value?.id != initial.id) {
      controller.selectedContact.value = initial;
    }

    return Obx(() {
      // Reactively read the contact — updates after edit/save.
      final contact = controller.selectedContact.value ?? initial;
      final colors = Theme.of(context).colorScheme;

      return Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              stretch: true,
              titleSpacing: 20,
              actionsPadding: EdgeInsetsGeometry.only(right: 10),
              leading: IconButton(
                icon: _AppBarCircle(
                  child: Icon(Icons.arrow_back_rounded,
                      color: colors.onSurface, size: 22),
                ),
                onPressed: controller.goBack,
              ),
              actions: [
                IconButton(
                  icon: _AppBarCircle(
                    child: Icon(
                      contact.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: contact.isFavorite
                          ? colors.tertiary
                          : colors.onSurface,
                      size: 22,
                    ),
                  ),
                  onPressed: () => controller.onDetailFavoritePressed(contact),
                ),
                PopupMenuButton<String>(
                  icon: _AppBarCircle(
                    child: Icon(Icons.more_vert_rounded,
                        color: colors.onSurface, size: 22),
                  ),
                  onSelected: (value) =>
                      controller.onDetailMenuAction(value, contact),
                  itemBuilder: (_) => _menuItems,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _HeaderBackground(contact: contact),
              ),
            ),
            SliverToBoxAdapter(
              child: _SlideUpFadeIn(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        children: [
                          _QuickActions(contact: contact),
                          const SizedBox(height: 28),
                          _InfoSection(contact: contact),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// CONTACT DETAIL PANE — Embeddable for tablet two-pane layout

class ContactDetailPane extends StatelessWidget {
  const ContactDetailPane({super.key, required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              contact.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: contact.isFavorite ? colors.tertiary : colors.onSurface,
            ),
            onPressed: () => controller.toggleFavorite(contact),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => controller.onDetailMenuAction(
              value,
              contact,
              isEmbedded: true,
            ),
            itemBuilder: (_) => _menuItems,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: _SlideUpFadeIn(
          child: Column(
            children: [
              _PaneAvatar(contact: contact),
              const SizedBox(height: 16),
              Text(
                contact.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _QuickActions(contact: contact),
              const SizedBox(height: 28),
              _InfoSection(contact: contact),
            ],
          ),
        ),
      ),
    );
  }
}

// SHARED MENU ITEMS
const List<PopupMenuEntry<String>> _menuItems = [
  PopupMenuItem(
    value: 'edit',
    child: ListTile(
      leading: Icon(Icons.edit_rounded),
      title: Text(AppStrings.edit),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    ),
  ),
  PopupMenuItem(
    value: 'delete',
    child: ListTile(
      leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
      title: Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    ),
  ),
];

// SLIDE-UP FADE-IN
class _SlideUpFadeIn extends StatelessWidget {
  const _SlideUpFadeIn({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// APP BAR CIRCLE
class _AppBarCircle extends StatelessWidget {
  const _AppBarCircle({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(180),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

// PANE AVATAR
class _PaneAvatar extends StatelessWidget {
  const _PaneAvatar({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = AppColors.avatarColor(contact.id ?? 0);

    if (contact.hasImage) {
      return Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(contact.imagePath!)),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: avatarColor.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: avatarColor.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          contact.initials,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// HEADER BACKGROUND
class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarColor = AppColors.avatarColor(contact.id ?? 0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [avatarColor.withAlpha(60), colors.surface],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Hero(
              tag: 'contact_avatar_${contact.id}',
              child: contact.hasImage
                  ? Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(File(contact.imagePath!)),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withAlpha(80),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: avatarColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withAlpha(80),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          contact.initials,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                contact.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QUICK ACTIONS — all logic delegated to controller
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactController>();
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionChip(
          icon: Icons.call_rounded,
          label: AppStrings.call,
          color: colors.primary,
          onTap: () => controller.onCallPressed(contact),
        ),
        const SizedBox(width: 16),
        if (contact.email.isNotEmpty) ...[
          _ActionChip(
            icon: Icons.email_rounded,
            label: AppStrings.email,
            color: colors.secondary,
            onTap: () => controller.onEmailPressed(contact),
          ),
          const SizedBox(width: 16),
        ],
        _ActionChip(
          icon: Icons.edit_rounded,
          label: AppStrings.edit,
          color: colors.tertiary,
          onTap: () => controller.onEditPressed(contact),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// INFO SECTION
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.phone_rounded,
                iconColor: colors.primary,
                title: AppStrings.phoneInfo,
                value: contact.phoneNumber,
              ),
              if (contact.email.isNotEmpty) ...[
                Divider(
                  height: 1,
                  indent: 56,
                  color: colors.outline.withAlpha(40),
                ),
                _InfoTile(
                  icon: Icons.email_rounded,
                  iconColor: colors.secondary,
                  title: AppStrings.emailInfo,
                  value: contact.email,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addedOn(_formatDate(contact.createdAt)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withAlpha(100),
                ),
              ),
              if (contact.updatedAt != contact.createdAt) ...[
                const SizedBox(height: 4),
                Text(
                  AppStrings.lastUpdated(_formatDate(contact.updatedAt)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withAlpha(100),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurface.withAlpha(120),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
