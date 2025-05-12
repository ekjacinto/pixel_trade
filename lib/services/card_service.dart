import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/card.dart';

class CardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all cards
  Stream<List<Card>> getCards() {
    return _firestore.collection('cards').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Card.fromFirestore(doc)).toList();
    });
  }

  // Get user's wishlist
  Stream<List<Card>> getWishlist() {
    if (_userId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Card.fromFirestore(doc)).toList();
    });
  }

  // Get user's collection
  Stream<List<Card>> getCollection() {
    if (_userId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('collection')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Card.fromFirestore(doc)).toList();
    });
  }

  // Add card to user's wishlist
  Future<void> addToWishlist(Card card) async {
    if (_userId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(card.id)
        .set(card.toMap());
  }

  // Add card to user's collection
  Future<void> addToCollection(Card card) async {
    if (_userId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('collection')
        .doc(card.id)
        .set(card.toMap());
  }

  // Remove card from user's wishlist
  Future<void> removeFromWishlist(String cardId) async {
    if (_userId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(cardId)
        .delete();
  }

  // Remove card from user's collection
  Future<void> removeFromCollection(String cardId) async {
    if (_userId.isEmpty) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('collection')
        .doc(cardId)
        .delete();
  }

  // Check if card is in user's wishlist
  Future<bool> isInWishlist(String cardId) async {
    if (_userId.isEmpty) return false;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(cardId)
        .get();
    
    return doc.exists;
  }

  // Check if card is in user's collection
  Future<bool> isInCollection(String cardId) async {
    if (_userId.isEmpty) return false;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('collection')
        .doc(cardId)
        .get();
    
    return doc.exists;
  }

  // Get a single card by ID
  Future<Card?> getCard(String cardId) async {
    final doc = await _firestore.collection('cards').doc(cardId).get();
    if (doc.exists) {
      return Card.fromFirestore(doc);
    }
    return null;
  }
} 