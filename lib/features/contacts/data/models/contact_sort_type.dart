import '../../../../core/constants/app_strings.dart';

/// Sort modes available for the contacts list.
enum ContactSortType {
  /// Alphabetical by full name (A → Z). Default.
  name(AppStrings.sortByName),

  /// Newest contacts first (by createdAt descending).
  dateCreated(AppStrings.sortByDateCreated),

  /// Most recently updated first (by updatedAt descending).
  dateModified(AppStrings.sortByDateModified);

  const ContactSortType(this.label);

  /// Human-readable label shown in the sort menu.
  final String label;
}
