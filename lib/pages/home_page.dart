import 'package:flutter/material.dart';
import '../models/card.dart' as models;
import '../services/card_service.dart';
import '../services/auth_service.dart';

void main() {
  runApp(MaterialApp(home: MainScreen()));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CardsTab(),
    const WishlistTab(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TCGP Trader"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = AuthService();
              await authService.signOut();
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class CardsTab extends StatefulWidget {
  const CardsTab({super.key});

  @override
  _CardsTabState createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  final CardService _cardService = CardService();
  List<models.Card> _filteredCards = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<models.Card> _wishlist = {};

  void _filterCards(String query) {
    setState(() {
      _filteredCards = _filteredCards
          .where((card) => card.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showCardPopup(models.Card card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(card.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(card.imageUrl, height: 150, fit: BoxFit.contain),
              const SizedBox(height: 10),
              Text(card.description),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _wishlist.add(card);
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Add to Wishlist"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search Cards",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: _filterCards,
          ),
        ),
        Expanded(
          child: StreamBuilder<List<models.Card>>(
            stream: _cardService.getCards(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cards = snapshot.data ?? [];
              if (_filteredCards.isEmpty) {
                _filteredCards = cards;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.of(context).size.width ~/ 150).clamp(2, 4),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _filteredCards.length,
                itemBuilder: (context, index) {
                  final card = _filteredCards[index];
                  return GestureDetector(
                    onTap: () => _showCardPopup(card),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            card.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 80),
                          ),
                        ),
                        Text(
                          card.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class WishlistTab extends StatefulWidget {
  const WishlistTab({super.key});

  @override
  _WishlistTabState createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  @override
  Widget build(BuildContext context) {
    final cardsTabState = context.findAncestorStateOfType<_CardsTabState>();

    if (cardsTabState == null || cardsTabState._wishlist.isEmpty) {
      return const Center(child: Text("Your wishlist is empty."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: cardsTabState._wishlist.length,
      itemBuilder: (context, index) {
        final card = cardsTabState._wishlist.elementAt(index);
        return ListTile(
          leading: Image.network(card.imageUrl, width: 50, fit: BoxFit.contain),
          title: Text(card.name),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                cardsTabState._wishlist.remove(card);
              });
            },
          ),
        );
      },
    );
  }
}

// Placeholder Search Screen
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Center(child: Text("Search functionality goes here")),
    );
  }
}

// Placeholder Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(child: Text("Profile details go here")),
    );
  }
}
