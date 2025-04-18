import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trade_listing.dart';
import '../models/card.dart';

class TradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  String get _userName => _auth.currentUser?.displayName ?? 'Anonymous';

  // Get all active trade listings
  Stream<List<TradeListing>> getTradeListings() {
    try {
      return _firestore
          .collection('trades')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return <TradeListing>[];
            final listings = snapshot.docs
                .map((doc) {
                  try {
                    return TradeListing.fromFirestore(doc);
                  } catch (e) {
                    return null;
                  }
                })
                .where((listing) => listing != null)
                .cast<TradeListing>()
                .toList();
            return listings;
          })
          .handleError((error) {
            return <TradeListing>[];
          });
    } catch (e) {
      return Stream.value(<TradeListing>[]);
    }
  }

  // Get user's trade listings
  Stream<List<TradeListing>> getUserTradeListings() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('trades')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TradeListing.fromFirestore(doc)).toList();
    });
  }

  // Create a new trade listing
  Future<void> createTradeListing(Card offeredCard, List<String> wantedCardIds) async {
    if (_userId.isEmpty) return;

    final listing = TradeListing(
      id: '',
      userId: _userId,
      userName: _userName,
      offeredCard: offeredCard,
      wantedCardIds: wantedCardIds,
      createdAt: DateTime.now(),
      status: 'active',
    );

    await _firestore.collection('trades').add(listing.toMap());
  }

  // Cancel a trade listing
  Future<void> cancelTradeListing(String listingId) async {
    if (_userId.isEmpty) return;

    await _firestore.collection('trades').doc(listingId).update({
      'status': 'cancelled',
    });
  }

  // Complete a trade listing
  Future<void> completeTradeListing(String listingId) async {
    if (_userId.isEmpty) return;

    await _firestore.collection('trades').doc(listingId).update({
      'status': 'completed',
    });
  }
} 