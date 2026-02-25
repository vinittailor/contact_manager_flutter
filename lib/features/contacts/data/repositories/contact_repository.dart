import 'package:flutter/foundation.dart';

import '../datasources/database_helper.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final DatabaseHelper _dbHelper;

  ContactRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // CREATE
  Future<int> addContact(Contact contact) async {
    try {
      final now = DateTime.now();
      final newContact = contact.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      return await _dbHelper.insertContact(newContact);
    } catch (e) {
      debugPrint('ContactRepository.addContact error: $e');
      return -1;
    }
  }

  // READ — All
  Future<List<Contact>> getAllContacts() async {
    try {
      return await _dbHelper.getAllContacts();
    } catch (e) {
      debugPrint('ContactRepository.getAllContacts error: $e');
      return [];
    }
  }

  // READ — Favorites
  Future<List<Contact>> getFavoriteContacts() async {
    try {
      return await _dbHelper.getFavoriteContacts();
    } catch (e) {
      debugPrint('ContactRepository.getFavoriteContacts error: $e');
      return [];
    }
  }

  // READ — Single
  Future<Contact?> getContactById(int id) async {
    try {
      return await _dbHelper.getContactById(id);
    } catch (e) {
      debugPrint('ContactRepository.getContactById error: $e');
      return null;
    }
  }

  // UPDATE
  Future<bool> updateContact(Contact contact) async {
    try {
      final updated = contact.copyWith(updatedAt: DateTime.now());
      final rows = await _dbHelper.updateContact(updated);
      return rows > 0;
    } catch (e) {
      debugPrint('ContactRepository.updateContact error: $e');
      return false;
    }
  }

  // DELETE
  Future<bool> deleteContact(int id) async {
    try {
      final rows = await _dbHelper.deleteContact(id);
      return rows > 0;
    } catch (e) {
      debugPrint('ContactRepository.deleteContact error: $e');
      return false;
    }
  }

  // TOGGLE FAVORITE
  Future<bool> toggleFavorite(Contact contact) async {
    try {
      final toggled = contact.copyWith(
        isFavorite: !contact.isFavorite,
        updatedAt: DateTime.now(),
      );
      final rows = await _dbHelper.updateContact(toggled);
      return rows > 0;
    } catch (e) {
      debugPrint('ContactRepository.toggleFavorite error: $e');
      return false;
    }
  }

  // SEARCH
  Future<List<Contact>> searchContacts(String query) async {
    try {
      if (query.trim().isEmpty) return await getAllContacts();
      return await _dbHelper.searchContacts(query.trim());
    } catch (e) {
      debugPrint('ContactRepository.searchContacts error: $e');
      return [];
    }
  }
}
