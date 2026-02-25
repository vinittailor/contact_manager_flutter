/// Centralized static strings for the entire application.
///
/// All user-facing text should reference this class — no hardcoded strings
/// in UI or controller code.
class AppStrings {
  AppStrings._();

  // ── Navigation & Tabs ─────────────────────────────────────────────────
  static const String contactsTab = 'Contacts';
  static const String favoritesTab = 'Favorites';
  static const String addLabel = 'Add';

  // ── Screen Titles ─────────────────────────────────────────────────────
  static const String newContact = 'New Contact';
  static const String editContact = 'Edit Contact';
  static const String deleteContact = 'Delete Contact';

  // ── Actions ───────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String update = 'Update';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String call = 'Call';
  static const String email = 'Email';

  // ── Form Labels ───────────────────────────────────────────────────────
  static const String firstNameLabel = 'First Name *';
  static const String lastNameLabel = 'Last Name';
  static const String phoneLabel = 'Phone Number *';
  static const String emailLabel = 'Email';
  static const String requiredFields = '* Required fields';

  // ── Info Labels ───────────────────────────────────────────────────────
  static const String phoneInfo = 'Phone';
  static const String emailInfo = 'Email';

  // ── Validation ────────────────────────────────────────────────────────
  static const String firstNameRequired = 'First name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Enter a valid phone number';
  static const String emailInvalid = 'Enter a valid email address';

  // ── Search ────────────────────────────────────────────────────────────
  static const String searchHint = 'Search contacts...';

  // ── Sort ──────────────────────────────────────────────────────────────
  static const String sortTooltip = 'Sort contacts';
  static const String sortByName = 'Name (A–Z)';
  static const String sortByDateCreated = 'Date Created';
  static const String sortByDateModified = 'Date Modified';

  // ── Empty States ──────────────────────────────────────────────────────
  static const String noResults = 'No results found';
  static const String noContacts = 'No contacts yet';
  static const String tryDifferentSearch = 'Try a different search term';
  static const String addFirstContact =
      'Tap the + button to add your first contact';
  static const String noFavorites = 'No favorites yet';
  static const String addFavoriteHint =
      'Tap the ☆ icon on a contact to add it here';
  static const String selectContact = 'Select a contact';
  static const String selectContactHint =
      'Choose a contact from the list to view details';

  // ── Tooltips ──────────────────────────────────────────────────────────
  static const String removeFromFavorites = 'Remove from favorites';

  // ── Snackbar Titles ───────────────────────────────────────────────────
  static const String success = 'Success';
  static const String error = 'Error';

  // ── Snackbar / Error Messages ─────────────────────────────────────────
  static const String loadFailed = 'Failed to load contacts';
  static const String addFailed = 'Failed to add contact';
  static const String updateFailed = 'Failed to update contact';
  static const String deleteFailed = 'Failed to delete contact';
  static const String unsavedDelete = 'Cannot delete unsaved contact';
  static const String favoriteFailed = 'Failed to update favorite';
  static const String callFailed = 'Could not launch phone dialer';
  static const String emailFailed = 'Could not launch email client';

  // ── Dynamic Messages ──────────────────────────────────────────────────
  static String contactAdded(String name) => 'Contact "$name" has been added successfully.';
  static String contactUpdated(String name) => 'Contact "$name" has been updated successfully.';
  static String contactDeleted(String name) => 'Contact "$name" has been deleted successfully.';
  static String deleteConfirmation(String name) =>
      'Are you sure you want to delete $name? This action cannot be undone.';
  static String addedOn(String date) => 'Added on $date';
  static String lastUpdated(String date) => 'Last updated $date';
}
