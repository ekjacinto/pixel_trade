import 'package:flutter/material.dart';
import 'package:tcgp_trade/pages/login_page.dart';
import '../models/card.dart' as models;
import '../models/trade_listing.dart';
import '../services/card_service.dart';
import '../services/auth_service.dart';
import '../services/trade_service.dart';
import 'chat_screen.dart';
import '../services/chat_service.dart';
import '../models/chat.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const int _numScreens = 5;  // Updated number of screens

  final List<Widget> _screens = [
    const HomePage(),
    const CollectionScreen(),
    const TradeTab(),
    MessagesTab(),  // Added MessagesTab
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _numScreens) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _selectedIndex.clamp(0, _numScreens - 1);
    if (safeIndex != _selectedIndex) {
      setState(() => _selectedIndex = safeIndex);
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF152B44),
          selectedItemColor: const Color(0xFF4FD1C5),
          unselectedItemColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_rounded),
              label: 'Collection',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded),
              label: 'Trade',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
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
  static const int _numScreens = 5;  // Updated to include Messages tab

  final List<Widget> _screens = [
    const CardsTab(),
    const CollectionScreen(),
    const TradeTab(),
    MessagesTab(),  // Added Messages tab
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _numScreens) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure index is within bounds
    final safeIndex = _selectedIndex.clamp(0, _numScreens - 1);
    if (safeIndex != _selectedIndex) {
      setState(() => _selectedIndex = safeIndex);
    }

    return Scaffold(
      body: _screens[safeIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF152B44),
          elevation: 0,
          selectedItemColor: const Color(0xFF4FD1C5),
          unselectedItemColor: const Color(0xFF6B7280),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark_rounded),
              label: "Collection",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded),
              label: "Trade",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

class CardsTab extends StatefulWidget {
  const CardsTab({super.key});

  @override
  CardsTabState createState() => CardsTabState();
}

class CardsTabState extends State<CardsTab> {
  final CardService _cardService = CardService();
  List<models.Card> _filteredCards = [];
  final TextEditingController _searchController = TextEditingController();

  void _filterCards(String query) {
    setState(() {
      _filteredCards = _filteredCards
          .where((card) => card.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TCGP Trade",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Cards",
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor.withAlpha(128),
              ),
              onChanged: _filterCards,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<models.Card>>(
              stream: _cardService.getCards(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final cards = snapshot.data ?? [];
                if (_filteredCards.isEmpty) {
                  _filteredCards = cards;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = _filteredCards[index];
                    return Hero(
                      tag: 'card_${card.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showCardPopup(card),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(26),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      card.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(
                                        child: Icon(
                                          Icons.image_not_supported_rounded,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    card.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCardPopup(models.Card card) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        child: Hero(
          tag: 'card_${card.id}',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -120,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.network(
                    card.imageUrl,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 180),
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: Icons.favorite_border_rounded,
                            label: "Wishlist",
                            onPressed: () async {
                              await _cardService.addToWishlist(card);
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                          ),
                          ActionButton(
                            icon: Icons.collections_bookmark_rounded,
                            label: "Pokedex",
                            onPressed: () async {
                              await _cardService.addToPokedex(card);
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Collection",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFF4FD1C5).withAlpha(26),
                  borderRadius: BorderRadius.circular(15),
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF4FD1C5),
                unselectedLabelColor: const Color(0xFF6B7280),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.favorite_rounded),
                    text: "Wishlist",
                  ),
                  Tab(
                    icon: Icon(Icons.collections_bookmark_rounded),
                    text: "Pokedex",
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  WishlistTab(),
                  PokedexTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistTab extends StatefulWidget {
  const WishlistTab({super.key});

  @override
  WishlistTabState createState() => WishlistTabState();
}

class WishlistTabState extends State<WishlistTab> {
  final CardService _cardService = CardService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<models.Card>>(
      stream: _cardService.getWishlist(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final wishlist = snapshot.data ?? [];
        if (wishlist.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your wishlist is empty",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Add cards you want to collect",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: wishlist.length,
          itemBuilder: (context, index) {
            final card = wishlist[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            card.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          card.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle_rounded),
                        color: Colors.red,
                        onPressed: () => _cardService.removeFromWishlist(card.id),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PokedexTab extends StatefulWidget {
  const PokedexTab({super.key});

  @override
  PokedexTabState createState() => PokedexTabState();
}

class PokedexTabState extends State<PokedexTab> {
  final CardService _cardService = CardService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<models.Card>>(
      stream: _cardService.getPokedex(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pokedex = snapshot.data ?? [];
        if (pokedex.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 64,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your Pokedex is empty",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Add cards you own to your collection",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: pokedex.length,
          itemBuilder: (context, index) {
            final card = pokedex[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            card.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          card.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle_rounded),
                        color: Colors.red,
                        onPressed: () => _cardService.removeFromPokedex(card.id),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _authService.deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Not signed in"))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      user.displayName ?? "No username set",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? "No email set",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _authService.signOut();
                          // Let the AuthWrapper handle navigation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isDeleting ? null : _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class TradeTab extends StatefulWidget {
  const TradeTab({super.key});

  @override
  TradeTabState createState() => TradeTabState();
}

class TradeTabState extends State<TradeTab> {
  final TradeService _tradeService = TradeService();
  final CardService _cardService = CardService();
  final AuthService _authService = AuthService();

  void _showCreateTradeDialog(BuildContext context) {
    models.Card? selectedCard;
    List<String> wantedCardIds = [];
    final TextEditingController offeredSearchController = TextEditingController();
    final TextEditingController wantedSearchController = TextEditingController();
    String offeredSearchQuery = '';
    String wantedSearchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF152B44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Trade Listing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a card to offer:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search bar for offered cards
                    TextField(
                      controller: offeredSearchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search your cards...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.search, color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          offeredSearchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<models.Card>>(
                      stream: _cardService.getPokedex(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4FD1C5),
                            ),
                          );
                        }

                        final cards = snapshot.data ?? [];
                        final filteredCards = offeredSearchQuery.isEmpty
                            ? cards
                            : cards.where((card) =>
                                card.name.toLowerCase().contains(offeredSearchQuery)).toList();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            value: selectedCard?.id,
                            hint: const Text(
                              'Select a card',
                              style: TextStyle(color: Colors.white70),
                            ),
                            isExpanded: true,
                            dropdownColor: const Color(0xFF152B44),
                            underline: Container(),
                            items: filteredCards.map((card) {
                              return DropdownMenuItem<String>(
                                key: ValueKey(card.id),
                                value: card.id,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          card.imageUrl,
                                          width: 60,
                                          height: 84,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          card.name,
                                          style: const TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (cardId) {
                              if (cardId != null) {
                                final card = cards.firstWhere((c) => c.id == cardId);
                                setState(() {
                                  selectedCard = card;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select cards you want:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search bar for wanted cards
                    TextField(
                      controller: wantedSearchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search cards...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.search, color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          wantedSearchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<models.Card>>(
                      stream: _cardService.getCards(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4FD1C5),
                            ),
                          );
                        }

                        final cards = snapshot.data ?? [];
                        final filteredCards = wantedSearchQuery.isEmpty
                            ? cards
                            : cards.where((card) =>
                                card.name.toLowerCase().contains(wantedSearchQuery)).toList();

                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];
                              return CheckboxListTile(
                                title: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        card.imageUrl,
                                        width: 40,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        card.name,
                                        style: const TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                value: wantedCardIds.contains(card.id),
                                checkColor: const Color(0xFF152B44),
                                fillColor: MaterialStateProperty.resolveWith(
                                  (states) => states.contains(MaterialState.selected)
                                      ? const Color(0xFF4FD1C5)
                                      : Colors.white54,
                                ),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      wantedCardIds.add(card.id);
                                    } else {
                                      wantedCardIds.remove(card.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedCard != null && wantedCardIds.isNotEmpty
                              ? () async {
                                  await _tradeService.createTradeListing(
                                    selectedCard!,
                                    wantedCardIds,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FD1C5),
                            foregroundColor: const Color(0xFF152B44),
                            disabledBackgroundColor: Colors.white24,
                            disabledForegroundColor: Colors.white30,
                          ),
                          child: const Text('Create Listing'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserAvatar(String userId, String userName) {
    return FutureBuilder<String?>(
      future: _authService.getUserPhotoURL(userId),
      builder: (context, snapshot) {
        final initials = userName.isNotEmpty 
            ? (userName.length >= 2 ? userName.substring(0, 2) : userName[0]).toUpperCase()
            : '?';
            
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF4FD1C5),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF4FD1C5).withOpacity(0.2),
            radius: 20,
            backgroundImage: snapshot.data != null ? NetworkImage(snapshot.data!) : null,
            child: snapshot.data == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF4FD1C5),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trade",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<TradeListing>>(
        stream: _tradeService.getTradeListings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4FD1C5),
              ),
            );
          }

          final listings = snapshot.data ?? [];
          
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 64,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No trade listings available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new trade listing to get started',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info section with gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4FD1C5).withOpacity(0.2),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildUserAvatar(listing.userId, listing.userName),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Trading Card',
                                    style: TextStyle(
                                      color: const Color(0xFF4FD1C5).withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Add message button if it's not the user's own listing
                          if (listing.userId != _authService.currentUser?.uid)
                            IconButton(
                              icon: const Icon(
                                Icons.message_rounded,
                                color: Color(0xFF4FD1C5),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      otherUserId: listing.userId,
                                      otherUserName: listing.userName,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    // Offered card section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                color: Color(0xFF4FD1C5),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Offering:',
                                style: TextStyle(
                                  color: Color(0xFF4FD1C5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    listing.offeredCard.imageUrl,
                                    width: 60,
                                    height: 84,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    listing.offeredCard.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Color(0xFF4FD1C5),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Looking for:',
                                style: TextStyle(
                                  color: Color(0xFF4FD1C5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (listing.wantedCardIds.isNotEmpty)
                            FutureBuilder<List<models.Card?>>(
                              future: Future.wait(
                                listing.wantedCardIds.map((id) => _cardService.getCard(id)),
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4FD1C5),
                                      ),
                                    ),
                                  );
                                }

                                final cards = snapshot.data?.where((card) => card != null).cast<models.Card>().toList() ?? [];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: cards.map((card) => Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              card.imageUrl,
                                              width: 60,
                                              height: 84,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              card.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )).toList(),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 16),
        child: FloatingActionButton(
          onPressed: () => _showCreateTradeDialog(context),
          backgroundColor: const Color(0xFF4FD1C5),
          child: const Icon(
            Icons.add,
            color: Color(0xFF152B44),
          ),
        ),
      ),
    );
  }
}

class MessagesTab extends StatelessWidget {
  final ChatService _chatService = ChatService();

  MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chat>>(
      stream: _chatService.getUserChats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final chats = snapshot.data!;

        if (chats.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: FutureBuilder<String?>(
                future: AuthService().getUsername(
                  chat.participants.firstWhere(
                    (id) => id != _chatService.userId,
                  ),
                ),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Loading...',
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
              subtitle: Text(
                chat.lastMessage,
                style: const TextStyle(color: Colors.white54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                _formatTimestamp(chat.lastMessageAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              onTap: () async {
                final otherUserId = chat.participants.firstWhere(
                  (id) => id != _chatService.userId,
                );
                final username = await AuthService().getUsername(otherUserId);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: otherUserId,
                        otherUserName: username ?? 'Unknown User',
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
