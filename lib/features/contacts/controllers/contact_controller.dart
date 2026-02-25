import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../data/models/contact_model.dart';
import '../data/models/contact_sort_type.dart';
import '../data/repositories/contact_repository.dart';

class ContactController extends GetxController {
  final ContactRepository _repository;

  ContactController({ContactRepository? repository})
      : _repository = repository ?? ContactRepository();

  // REACTIVE STATE

  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> favoriteContacts = <Contact>[].obs;
  final RxList<Contact> filteredContacts = <Contact>[].obs;

  /// True only during initial / full fetch — drives skeleton loaders.
  final RxBool isLoading = false.obs;

  /// True during add / update / delete — drives button spinners, not lists.
  final RxBool isMutating = false.obs;

  final RxString searchQuery = ''.obs;
  final RxInt selectedTabIndex = 0.obs;

  /// Currently active sort mode (reactive).
  final Rx<ContactSortType> sortType = ContactSortType.name.obs;

  /// Selected contact for tablet two-pane layout (null = nothing selected).
  final Rxn<Contact> selectedContact = Rxn<Contact>();

  Worker? _searchWorker;

  // LIFECYCLE

  @override
  void onInit() {
    super.onInit();
    fetchContacts();

    _searchWorker = debounce<String>(
      searchQuery,
      _applySearchFilter,
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }

  // DATA OPERATIONS (CRUD)

  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _repository.getAllContacts(),
        _repository.getFavoriteContacts(),
      ]);

      contacts.assignAll(results[0]);
      favoriteContacts.assignAll(results[1]);
      _applySortAndFilter();
      _refreshSelectedContact();
    } catch (e) {
      showMessage(AppStrings.error, AppStrings.loadFailed, isError: true);
      debugPrint('ContactController.fetchContacts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addContact(Contact contact) async {
    try {
      isMutating.value = true;

      final id = await _repository.addContact(contact);
      if (id == -1) {
        showMessage(AppStrings.error, AppStrings.addFailed, isError: true);
        return false;
      }

      final now = DateTime.now();
      final inserted = contact.copyWith(id: id, createdAt: now, updatedAt: now);

      contacts.add(inserted);
      if (inserted.isFavorite) favoriteContacts.add(inserted);
      _applySortAndFilter();

      return true;
    } catch (e) {
      showMessage(AppStrings.error, AppStrings.addFailed, isError: true);
      debugPrint('ContactController.addContact error: $e');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> updateContact(Contact contact) async {
    try {
      isMutating.value = true;

      final updated = contact.copyWith(updatedAt: DateTime.now());
      final success = await _repository.updateContact(updated);
      if (!success) {
        showMessage(AppStrings.error, AppStrings.updateFailed, isError: true);
        return false;
      }

      _replaceInLists(updated);
      _applySortAndFilter();
      _refreshSelectedContact();

      return true;
    } catch (e) {
      showMessage(AppStrings.error, AppStrings.updateFailed, isError: true);
      debugPrint('ContactController.updateContact error: $e');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> deleteContact(Contact contact) async {
    if (contact.id == null) {
      showMessage(AppStrings.error, AppStrings.unsavedDelete, isError: true);
      return false;
    }

    try {
      isMutating.value = true;

      final success = await _repository.deleteContact(contact.id!);
      if (!success) {
        showMessage(AppStrings.error, AppStrings.deleteFailed, isError: true);
        return false;
      }

      contacts.removeWhere((c) => c.id == contact.id);
      favoriteContacts.removeWhere((c) => c.id == contact.id);
      filteredContacts.removeWhere((c) => c.id == contact.id);

      if (selectedContact.value?.id == contact.id) {
        selectedContact.value = null;
      }

      return true;
    } catch (e) {
      showMessage(AppStrings.error, AppStrings.deleteFailed, isError: true);
      debugPrint('ContactController.deleteContact error: $e');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> toggleFavorite(Contact contact) async {
    if (contact.id == null) return;

    try {
      final success = await _repository.toggleFavorite(contact);
      if (!success) {
        showMessage(AppStrings.error, AppStrings.favoriteFailed, isError: true);
        return;
      }

      final index = contacts.indexWhere((c) => c.id == contact.id);
      if (index == -1) return;

      final toggled = contacts[index].copyWith(
        isFavorite: !contacts[index].isFavorite,
      );

      contacts[index] = toggled;

      if (toggled.isFavorite) {
        favoriteContacts.add(toggled);
        _sortList(favoriteContacts);
      } else {
        favoriteContacts.removeWhere((c) => c.id == contact.id);
      }

      final filteredIdx =
          filteredContacts.indexWhere((c) => c.id == contact.id);
      if (filteredIdx != -1) filteredContacts[filteredIdx] = toggled;

      if (selectedContact.value?.id == contact.id) {
        selectedContact.value = toggled;
      }
    } catch (e) {
      showMessage(AppStrings.error, AppStrings.favoriteFailed, isError: true);
      debugPrint('ContactController.toggleFavorite error: $e');
    }
  }

  // NAVIGATION & ACTIONS

  void goBack() => Get.back();

  void onAddPressed() => Get.toNamed(AppRoutes.addContact);

  void onEditPressed(Contact contact) {
    Get.toNamed(AppRoutes.editContact, arguments: contact);
  }

  void navigateToDetail(Contact contact) {
    Get.toNamed(AppRoutes.contactDetail, arguments: contact);
  }

  /// Handles popup menu selection on the detail screen / pane.
  void onDetailMenuAction(
    String action,
    Contact contact, {
    bool isEmbedded = false,
  }) {
    switch (action) {
      case 'edit':
        onEditPressed(contact);
        break;
      case 'delete':
        onDeletePressed(contact, isEmbedded: isEmbedded);
        break;
    }
  }

  /// Toggles favorite and navigates back (phone detail screen behavior).
  void onDetailFavoritePressed(Contact contact) {
    toggleFavorite(contact);
    Get.back();
  }

  /// Shows delete confirmation dialog. All delete logic is handled here.
  void onDeletePressed(Contact contact, {bool isEmbedded = false}) {
    final colors = Get.theme.colorScheme;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.error.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: colors.error,
            size: 28,
          ),
        ),
        title: const Text(AppStrings.deleteContact),
        content: Text(AppStrings.deleteConfirmation(contact.fullName)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: colors.onSurface.withAlpha(180)),
            ),
          ),
          FilledButton(
            onPressed: () => _confirmDelete(contact, isEmbedded),
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Contact contact, bool isEmbedded) async {
    Get.back(); // close dialog
    final success = await deleteContact(contact);
    if (success && !isEmbedded) Get.back(); // pop detail (phone)
    if (success && isEmbedded) selectContact(null);
    if (success) {
      showMessage(
        AppStrings.success,
        AppStrings.contactDeleted(contact.fullName),
      );
    }
  }

  /// Saves a new or updated contact, navigates back, shows snackbar.
  Future<void> saveContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String email = '',
    String? imagePath,
    Contact? existingContact,
  }) async {
    final isEditing = existingContact != null;
    final now = DateTime.now();

    final contact = Contact(
      id: existingContact?.id,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phoneNumber: phoneNumber.trim(),
      email: email.trim(),
      isFavorite: existingContact?.isFavorite ?? false,
      imagePath: imagePath,
      createdAt: existingContact?.createdAt ?? now,
      updatedAt: now,
    );

    final success =
        isEditing ? await updateContact(contact) : await addContact(contact);

    if (success) {
      final name = contact.fullName;
      Get.back(result: true);
      showMessage(
        AppStrings.success,
        isEditing
            ? AppStrings.contactUpdated(name)
            : AppStrings.contactAdded(name),
      );
    }
  }

  /// Launches the phone dialer for the given contact.
  Future<void> onCallPressed(Contact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showMessage(AppStrings.error, AppStrings.callFailed, isError: true);
    }
  }

  /// Launches the email client for the given contact.
  Future<void> onEmailPressed(Contact contact) async {
    if (contact.email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: contact.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showMessage(AppStrings.error, AppStrings.emailFailed, isError: true);
    }
  }

  /// Opens the gallery image picker and returns the selected file path.
  Future<String?> pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      return picked?.path;
    } catch (e) {
      debugPrint('Image picker error: $e');
      return null;
    }
  }

  // VALIDATION

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.firstNameRequired;
    if (value.trim().length < 2) return AppStrings.nameMinLength;
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.phoneRequired;
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 7 || !RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return AppStrings.phoneInvalid;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!GetUtils.isEmail(value.trim())) return AppStrings.emailInvalid;
    return null;
  }

  // SEARCH & SORT

  void onSearchChanged(String query) => searchQuery.value = query;

  void clearSearch() {
    searchQuery.value = '';
    _applySortAndFilter();
  }

  void onSortChanged(ContactSortType type) {
    if (sortType.value == type) return;
    sortType.value = type;
    _applySortAndFilter();
  }

  void selectContact(Contact? contact) => selectedContact.value = contact;

  void changeTab(int index) => selectedTabIndex.value = index;

  // PRIVATE HELPERS

  void _sortList(RxList<Contact> list) {
    switch (sortType.value) {
      case ContactSortType.name:
        list.sort((a, b) =>
            a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case ContactSortType.dateCreated:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ContactSortType.dateModified:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
  }

  void _applySortAndFilter() {
    _sortList(contacts);
    _sortList(favoriteContacts);
    _applySearchFilter(searchQuery.value);
  }

  void _applySearchFilter(String query) {
    if (query.trim().isEmpty) {
      filteredContacts.assignAll(contacts);
      return;
    }
    final q = query.toLowerCase();
    filteredContacts.assignAll(
      contacts.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.phoneNumber.contains(q) ||
            c.email.toLowerCase().contains(q);
      }).toList(),
    );
  }

  void _replaceInLists(Contact updated) {
    final contactIdx = contacts.indexWhere((c) => c.id == updated.id);
    if (contactIdx != -1) contacts[contactIdx] = updated;

    final favIdx = favoriteContacts.indexWhere((c) => c.id == updated.id);
    if (updated.isFavorite) {
      if (favIdx != -1) {
        favoriteContacts[favIdx] = updated;
      } else {
        favoriteContacts.add(updated);
      }
    } else {
      if (favIdx != -1) favoriteContacts.removeAt(favIdx);
    }
  }

  void _refreshSelectedContact() {
    final current = selectedContact.value;
    if (current?.id == null) return;
    final fresh = contacts.firstWhereOrNull((c) => c.id == current!.id);
    selectedContact.value = fresh;
  }

  // CENTRALIZED SNACKBAR

  /// Shows a consistent snackbar. No duplicate stacking.
  void showMessage(String title, String message, {bool isError = false}) {
    if (!Get.isRegistered<GetMaterialController>()) return;
    if (Get.isSnackbarOpen) return;

    final colors = Get.theme.colorScheme;
    final color = isError ? colors.error : colors.primary;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color.withAlpha(30),
      colorText: color,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: isError ? 3 : 2),
      icon: Icon(
        isError ? Icons.error_rounded : Icons.check_circle_rounded,
        color: color,
      ),
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
