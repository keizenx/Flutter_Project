import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: '1',
      name: 'Nike Air Max',
      description: 'Chaussures de sport confortables pour la course',
      price: 129.99,
      imageUrl: 'https://picsum.photos/200',
      category: 'Chaussures',
      rating: 4.5,
      reviews: 128,
    ),
    Product(
      id: '2',
      name: 'Adidas Ultraboost',
      description: 'Performance et style pour vos entraînements',
      price: 159.99,
      imageUrl: 'https://picsum.photos/201',
      category: 'Chaussures',
      rating: 4.8,
      reviews: 245,
    ),
    // Ajoutez d'autres produits ici
  ];

  List<Product> get items => [..._items];

  List<Product> get favoriteItems =>
      _items.where((item) => item.rating >= 4.5).toList();

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  List<Product> findByCategory(String category) {
    return _items.where((product) => product.category == category).toList();
  }
}
