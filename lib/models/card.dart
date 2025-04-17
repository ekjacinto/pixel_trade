import 'package:cloud_firestore/cloud_firestore.dart';

class Card {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String raritySymbols;
  final String set;
  final String url;
  final int cardNumber;

  Card({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.raritySymbols,
    required this.set,
    required this.url,
    required this.cardNumber,
  });

  factory Card.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Card(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      raritySymbols: data['rarity_symbols'] ?? '',
      set: data['set'] ?? '',
      url: data['url'] ?? '',
      cardNumber: data['card_number'] ?? 0,
    );
  }
} 