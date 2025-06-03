import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final List<Product> _products = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  Timer? _debounce;
  String? _searchQuery;
  
  @override
  void initState() {
    super.initState();
    _fetchProducts();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadMoreProducts();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  Future<void> _fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _products.clear();
      }
    });
    
    try {
      final newProducts = await _productService.getProducts(
        searchQuery: _searchQuery,
        page: _currentPage,
      );
      
      setState(() {
        _products.addAll(newProducts);
        _hasMoreData = newProducts.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      toastification.show(
        context: context,
        title: Text('Erreur'),
        description: Text('Impossible de charger les produits: $e'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }
  
  void _loadMoreProducts() {
    setState(() {
      _currentPage++;
    });
    _fetchProducts();
  }
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.isNotEmpty ? query : null;
        _products.clear();
        _currentPage = 1;
        _hasMoreData = true;
      });
      _fetchProducts();
    });
  }
    void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirmer la suppression',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Voulez-vous vraiment supprimer "${product.name}" ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteProduct(product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _deleteProduct(Product product) async {
    try {
      await _productService.deleteProduct(product.uuid);
      
      setState(() {
        _products.removeWhere((p) => p.uuid == product.uuid);
      });
      
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Succès'),
          description: Text('Produit supprimé avec succès'),
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Erreur'),
          description: Text('Impossible de supprimer le produit: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: const Text('Liste des Produits', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-product').then((_) => _fetchProducts(refresh: true)),
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: _isLoading && _products.isEmpty
                  ? _buildLoadingIndicator()
                  : _products.isEmpty
                      ? _buildEmptyView()
                      : RefreshIndicator(
                          onRefresh: () => _fetchProducts(refresh: true),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(bottom: 80),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _products.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _products.length) {
                                  return _buildProductCard(_products[index]);
                                } else {
                                  return _buildLoadingIndicator();
                                }
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product').then((_) => _fetchProducts(refresh: true)),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter un produit',
      ),      // Barre de navigation supprimée car non fonctionnelle
    );
  }
    // Fonction _buildCategoryScroller() supprimée car non fonctionnelle
    Widget _buildProductCard(Product product) {
    // Variable originalPrice supprimée car non fonctionnelle
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/edit-product/${product.uuid}')
            .then((_) => _fetchProducts(refresh: true)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        alignment: Alignment.center,
                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ),                // Bouton favori supprimé car non fonctionnel
                Positioned(
                  top: 8,
                  right: 52,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, product),
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      tooltip: 'Supprimer',
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  // Étiquette de catégorie supprimée car non fonctionnelle
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),                      // Prix barré supprimé car non fonctionnel
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery != null
                ? 'Aucun produit trouvé pour "$_searchQuery"'
                : 'Aucun produit disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          if (_searchQuery != null)
            TextButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Effacer la recherche'),
              onPressed: () {
                setState(() {
                  _searchQuery = null;
                  _searchController.clear();
                  _products.clear();
                  _currentPage = 1;
                  _hasMoreData = true;
                });
                _fetchProducts();
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
