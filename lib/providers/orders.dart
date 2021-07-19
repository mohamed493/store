import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import './cart.dart';
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
 // final DateTime dateTime;
  final String dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken ;
  final String userId ;
  Orders(this.authToken,this.userId,this._orders, );
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // final url = Uri.https(
    //   "flutter-update-93051-default-rtdb.firebaseio.com",
    //   "orders.json",{"auth": "${authToken}"}
    // );
    Uri url = Uri.parse(
        'https://flutter-update-93051-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {

      final productsContent = [];
      cartProducts.forEach((cart) {
        return productsContent.add({
          "id": cart.id,
          "title": cart.title,
          "quantity": cart.quantity,
          "price": cart.price
        });
      });
      final jsonFileOfProductsContent={"a":productsContent};

      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toString(),
          'products': jsonFileOfProductsContent,
        }),
      );
      // print(response); 
      final order = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: DateTime.now().toString(),
        products: cartProducts,
      );
      _orders.insert(0, order);
    } catch (error) {
      print(error);
    }

    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    // final url = Uri.https(
    //     "flutter-update-93051-default-rtdb.firebaseio.com", "orders.json",{"auth": "${authToken}"});
    Uri url = Uri.parse(
        'https://flutter-update-93051-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //print(extractedData);
      final List<OrderItem> loadedProducts = [];
      // final loadedCartItems=[];

      extractedData == null? null:extractedData.forEach((orderId, orderData) {
        final List<CartItem> loadedCartItems = [];
         final loadedList = orderData["products"]["a"] ;//["products"][0] as List;
      //  print(loadedList);
      // print(loadedList);
        for (int i = 0; i < loadedList.length; ++i) {
          loadedCartItems.add(CartItem(
              id: loadedList[i]["id"],
              title: loadedList[i]["title"],
              quantity:loadedList[i]['quantity'],
              price: double.tryParse(loadedList[i]['price'] .toString()),
               )
              );
         };
        loadedProducts.add(OrderItem(
            id: orderId,
            amount: double.tryParse(orderData["amount"].toString()),
            products: loadedCartItems,
            dateTime:orderData["dateTime"]));
      });
      _orders = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
