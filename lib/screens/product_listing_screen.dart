import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/tab_bar_delegate.dart';
import 'profile_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  bool _isSearching = false;
  String _searchQuery = '';
  
  static const List<String> _categories = ['all', 'electronics', 'jewelery', "men's clothing"];
  static const List<String> _tabLabels = ['All', 'Electronics', 'Jewelery', "Men's Clothing"];
  static const List<String> _banners = ['lib/assets/images/banner.png', 'lib/assets/images/banner2.png'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _startBannerAutoSlide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_bannerController.page!.toInt() + 1) % _banners.length;
        _bannerController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _stopSearch() {
    setState(() { _isSearching = false; _searchQuery = ''; _searchController.clear(); });
    _searchFocusNode.unfocus();
  }

  void _onSearchChanged(String query) { setState(() => _searchQuery = query); }

  void _navigateToProfile() { Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetchProducts(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: _isSearching ? 140 : 180,
              backgroundColor: Colors.white,
              elevation: 2,
              leading: _isSearching ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _stopSearch) : null,
              actions: [
                IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => setState(() => _isSearching = true)),
                if (!_isSearching) IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: _navigateToProfile),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    PageView.builder(
                      controller: _bannerController,
                      itemCount: _banners.length,
                      itemBuilder: (context, index) => Image.asset(_banners[index], fit: BoxFit.cover),
                    ),
                    if (_isSearching)
                      Positioned(bottom: 8, left: 16, right: 16, child: TextField(controller: _searchController, focusNode: _searchFocusNode, onChanged: _onSearchChanged, autofocus: true, decoration: InputDecoration(hintText: 'Search products...', filled: true, fillColor: Colors.white, prefixIcon: const Icon(Icons.search), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _onSearchChanged(''); }) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegate(TabBar(controller: _tabController, isScrollable: true, labelPadding: const EdgeInsets.only(left: 16), labelColor: const Color(0xFFFF6F00), unselectedLabelColor: Colors.grey[700], indicatorColor: const Color(0xFFFF6F00), indicatorWeight: 3, tabs: _tabLabels.map((label) => Tab(text: label)).toList())),
            ),
            SliverFillRemaining(child: TabBarView(controller: _tabController, physics: const NeverScrollableScrollPhysics(), children: _categories.map((category) => _ProductGrid(category: category, searchQuery: _searchQuery)).toList())),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final String category; final String searchQuery;
  const _ProductGrid({required this.category, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    if (provider.loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6F00)));
    var products = provider.products;
    if (category != 'all') products = products.where((p) => p.category.toLowerCase().contains(category.toLowerCase())).toList();
    if (searchQuery.isNotEmpty) { final query = searchQuery.toLowerCase(); products = products.where((p) => p.title.toLowerCase().contains(query) || p.category.toLowerCase().contains(query) || p.price.toString().contains(query)).toList(); }
    if (products.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text(searchQuery.isNotEmpty ? 'No products found' : 'No products available', style: TextStyle(color: Colors.grey[600], fontSize: 16))]));
    return GridView.builder(physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(8), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: products.length, itemBuilder: (context, index) => _ProductCard(product: products[index]));
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  const _ProductCard({required this.product});
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), child: Image.network(product.image, fit: BoxFit.contain, width: double.infinity, errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey))))), Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 1.2))), const SizedBox(height: 4), Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6F00)))])))]));
  }
}
