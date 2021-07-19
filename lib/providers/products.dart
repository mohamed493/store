import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
   final  filterString =filterByUser ? '&orderBy="creatorId"&equalTo="$userId"':"" ;
    // var url = Uri.https(
    //     "flutter-update-93051-default-rtdb.firebaseio.com",
    //     "products.json",{"auth": "$authToken","+orderBy":"+creatorId","+equalTo":"+$userId"}
    // );
    Uri url = Uri.parse(
        'https://flutter-update-93051-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    // print(url);

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.https("flutter-update-93051-default-rtdb.firebaseio.com",
          "/userFavourites/$userId.json", {"auth": "$authToken"});
      final favouriteResponse = await http.get(url);
      final extractedFavouriteData = json.decode(favouriteResponse.body);
      // print(json.decode(response.body));
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: double.tryParse(prodData['price'].toString()),
            isFavourite: extractedFavouriteData != null
                ? extractedFavouriteData[prodId] ?? false
                : false, // the problem is here .
            imageUrl: prodData['imageUrl'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https("flutter-update-93051-default-rtdb.firebaseio.com",
        "products.json", {"auth": "${authToken}"});
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          "creatorId": userId,
          // 'isFavourite': product.isFavourite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],

        // isFavourite: product.isFavourite, ///////////
      );
      _items.add(newProduct);
    } catch (error) {
      print(error);
      throw (error);
    }
    // _items.insert(0, newProduct); // at the start of the list
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https("flutter-update-93051-default-rtdb.firebaseio.com",
          "products/$id.json", {"auth": "${authToken}"});
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            "creatorId": userId,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) async {
    final url = Uri.https("flutter-update-93051-default-rtdb.firebaseio.com",
        "products/$id.json", {"auth": "${authToken}"});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      throw HttpException("could not delete your product .");
    }
    existingProduct = null;
  }
  // Future<void> updateFavouriteProduct(String id, Product newProduct,String userId) async {
  //   final prodIndex = _items.indexWhere((prod) => prod.id == id);
  //   if (prodIndex >= 0) {
  //     final url = Uri.https(
  //       "flutter-update-93051-default-rtdb.firebaseio.com",
  //       "/products/$id.json",{"auth": "${authToken}"}
  //     );
  //     await http.patch(url,
  //         body: json.encode({
  //           'title': newProduct.title,
  //           'description': newProduct.description,
  //           'price': newProduct.price,
  //           'imageUrl': newProduct.imageUrl,
  //           'isFavourite': !newProduct.isFavourite,
  //           //'isFavourite': true,
  //
  //         }));
  //     _items[prodIndex] = newProduct;
  //     notifyListeners();
  //   } else {
  //     print('...');
  //   }
  // }
}
