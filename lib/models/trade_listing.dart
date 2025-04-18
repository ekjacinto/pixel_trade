import 'package:cloud_firestore/cloud_firestore.dart';
import 'card.dart';

class TradeListing {
  final String id;
  final String userId;
  final String userName;
  final Card offeredCard;
  final List<String> wantedCardIds;
  final DateTime createdAt;
  final String status; // 'active', 'completed', 'cancelled'

  TradeListing({
    required this.id,
    required this.userId,
    required this.userName,
    required this.offeredCard,
    required this.wantedCardIds,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'offeredCard': offeredCard.toMap(),
      'wantedCardIds': wantedCardIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory TradeListing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TradeListing(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      offeredCard: Card.fromMap(data['offeredCard'] as Map<String, dynamic>),
      wantedCardIds: List<String>.from(data['wantedCardIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
    );
  }
} 