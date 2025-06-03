import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  bool _isLoading = false;
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newProduct = Product(
          uuid: '',  // The API will generate this
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          image: _imageController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _productService.createProduct(newProduct);
        
        if (mounted) {
          toastification.show(
            context: context,
            title: Text('Succès'),
            description: Text('Produit ajouté avec succès'),
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
            description: Text('Échec de l\'ajout du produit: $e'),
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image preview section
                    Container(
                      height: 220,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _imageController.text.isNotEmpty && 
                             Uri.tryParse(_imageController.text)?.isAbsolute == true
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    _imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey[400]),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Image non disponible',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),                                // Bouton d'édition d'image supprimé car non fonctionnel
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ajoutez une image du produit',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    
                    // Form fields
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations du produit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom du produit',
                              hintText: 'Ex: T-shirt coton premium',
                              prefixIcon: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).primaryColor),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer un nom de produit';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Décrivez votre produit en détail',
                              prefixIcon: Icon(Icons.description_outlined, color: Theme.of(context).primaryColor),
                              alignLabelWithHint: true,
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer une description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  decoration: InputDecoration(
                                    labelText: 'Prix',
                                    hintText: 'Ex: 29.99',
                                    prefixIcon: Icon(Icons.euro, color: Theme.of(context).primaryColor),
                                    suffixText: '€',
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez entrer un prix';
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
                                    hintText: 'https://...',
                                    prefixIcon: Icon(Icons.image_outlined, color: Theme.of(context).primaryColor),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
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
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                      // Section des options supplémentaires supprimée car non fonctionnelle
                    
                    const SizedBox(height: 30),
                    
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('Ajouter le produit', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
