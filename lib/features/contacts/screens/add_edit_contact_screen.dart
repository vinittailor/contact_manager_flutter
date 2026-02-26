import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/contact_controller.dart';
import '../data/models/contact_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/app_colors.dart';

class AddEditContactScreen extends StatefulWidget {
  const AddEditContactScreen({super.key});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<ContactController>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;

  Contact? _existingContact;
  String? _selectedImagePath;

  bool get _isEditing => _existingContact != null;

  @override
  void initState() {
    super.initState();
    _existingContact = Get.arguments as Contact?;
    _selectedImagePath = _existingContact?.imagePath;

    _firstNameCtrl =
        TextEditingController(text: _existingContact?.firstName ?? '');
    _lastNameCtrl =
        TextEditingController(text: _existingContact?.lastName ?? '');
    _phoneCtrl =
        TextEditingController(text: _existingContact?.phoneNumber ?? '');
    _emailCtrl =
        TextEditingController(text: _existingContact?.email ?? '');

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPickImage() async {
    final path = await _controller.pickImage();
    if (path != null) setState(() => _selectedImagePath = path);
  }

  void _onRemoveImage() => setState(() => _selectedImagePath = null);

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    _controller.saveContact(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      phoneNumber: _phoneCtrl.text,
      email: _emailCtrl.text,
      imagePath: _selectedImagePath,
      existingContact: _existingContact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editContact : AppStrings.newContact),
        actionsPadding: EdgeInsetsGeometry.only(right: 10),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _controller.goBack,
        ),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: _controller.isMutating.value ? null : _onSave,
                icon: _controller.isMutating.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  _isEditing ? AppStrings.update : AppStrings.save,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AvatarPreview(
                      firstNameCtrl: _firstNameCtrl,
                      lastNameCtrl: _lastNameCtrl,
                      existingContact: _existingContact,
                      imagePath: _selectedImagePath,
                      onPickImage: _onPickImage,
                      onRemoveImage: _onRemoveImage,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _firstNameCtrl,
                      validator: _controller.validateName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.firstNameLabel,
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameCtrl,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: AppStrings.lastNameLabel,
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      validator: _controller.validatePhone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9\s\-\+\(\)]'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: AppStrings.phoneLabel,
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      validator: _controller.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onSave(),
                      decoration: const InputDecoration(
                        labelText: AppStrings.emailLabel,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppStrings.requiredFields,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// AVATAR PREVIEW
// ═════════════════════════════════════════════════════════════════════════════

class _AvatarPreview extends StatefulWidget {
  const _AvatarPreview({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    this.existingContact,
    this.imagePath,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final Contact? existingContact;
  final String? imagePath;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  @override
  State<_AvatarPreview> createState() => _AvatarPreviewState();
}

class _AvatarPreviewState extends State<_AvatarPreview> {
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _updateInitials();
    widget.firstNameCtrl.addListener(_updateInitials);
    widget.lastNameCtrl.addListener(_updateInitials);
  }

  void _updateInitials() {
    final first = widget.firstNameCtrl.text;
    final last = widget.lastNameCtrl.text;
    final newInitials =
        '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
            .toUpperCase();
    if (newInitials != _initials) {
      setState(() => _initials = newInitials);
    }
  }

  @override
  void dispose() {
    widget.firstNameCtrl.removeListener(_updateInitials);
    widget.lastNameCtrl.removeListener(_updateInitials);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final contactId = widget.existingContact?.id ?? 0;
    final bgColor = AppColors.avatarColor(contactId);
    final hasImage =
        widget.imagePath != null && widget.imagePath!.isNotEmpty;

    return Center(
      child: Stack(
        children: [
          Hero(
            tag: 'contact_avatar_$contactId',
            child: GestureDetector(
              onTap: widget.onPickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: hasImage ? null : bgColor,
                  shape: BoxShape.circle,
                  image: hasImage
                      ? DecorationImage(
                          image: FileImage(File(widget.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: (hasImage ? colors.shadow : bgColor)
                          .withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: hasImage
                    ? null
                    : Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _initials.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  key: const ValueKey('icon'),
                                  size: 40,
                                  color: Colors.white.withAlpha(200),
                                )
                              : Text(
                                  _initials,
                                  key: ValueKey(_initials),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: widget.onPickImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: 16,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
          if (hasImage)
            Positioned(
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: widget.onRemoveImage,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: colors.onError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
