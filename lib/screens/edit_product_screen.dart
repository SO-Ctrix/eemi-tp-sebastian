import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Product? _product;
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final product = await _productService.getProductDetails(widget.productId);
      
      setState(() {
        _product = product;
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _priceController.text = product.price.toString();
        _imageController.text = product.image;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Erreur'),
          description: Text('Impossible de charger les détails du produit: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 5),
        );
        
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        final updatedProduct = Product(
          uuid: widget.productId,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          image: _imageController.text,
          createdAt: _product!.createdAt,
          updatedAt: DateTime.now(),
        );

        await _productService.updateProduct(widget.productId, updatedProduct);
        
        if (mounted) {
          toastification.show(
            context: context,
            title: Text('Succès'),
            description: Text('Produit modifié avec succès'),
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            autoCloseDuration: const Duration(seconds: 3),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          toastification.show(
            context: context,
            title: Text('Erreur'),
            description: Text('Échec de la modification du produit: $e'),
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Chargement...' : 'Détail du produit'),        // Bouton de partage supprimé car non fonctionnel
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isSaving
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Enregistrement en cours...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image du produit
                        SizedBox(
                          height: 300,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  _imageController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),                              // Bouton favori supprimé car non fonctionnel
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _nameController.text,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF24969A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${_product?.price.toStringAsFixed(2)} €",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _descriptionController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              const Text(
                                'Éditer les informations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Formulaire d'édition
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nom du produit',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.shopping_bag),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez entrer un nom de produit';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.description),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez entrer une description';
                                  }
                                  return null;
                                },
                              ),                              const SizedBox(height: 16),
                              
                              // Prix et image en deux colonnes
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      decoration: InputDecoration(
                                        labelText: 'Prix',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.euro),
                                        suffixText: '€',
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Prix requis';
                                        }
                                        try {
                                          final price = double.parse(value);
                                          if (price <= 0) {
                                            return 'Prix > 0';
                                          }
                                        } catch (e) {
                                          return 'Prix invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _imageController,
                                      decoration: InputDecoration(
                                        labelText: 'URL de l\'image',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        prefixIcon: const Icon(Icons.image),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'URL requise';
                                        }
                                        final isValidUrl = Uri.tryParse(value)?.isAbsolute ?? false;
                                        if (!isValidUrl) {
                                          return 'URL invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                                const SizedBox(height: 32),
                              
                              ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: const Icon(Icons.save),
                                label: const Text('Mettre à jour le produit', style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              OutlinedButton.icon(
                                onPressed: () => _showDeleteConfirmation(context, _product!),
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: const Text('Supprimer le produit', style: TextStyle(color: Colors.red, fontSize: 16)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
  // Méthode _buildStatItem supprimée car non utilisée

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
      
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('Succès'),
          description: const Text('Produit supprimé avec succès'),
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 3),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('Erreur'),
          description: Text('Impossible de supprimer le produit: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }
}
