import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:store3/providers/product.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/auth.dart';
// void main() => runApp(MyApp());
//
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Search Bar App',
// //       home: HomePage(),
// //     );
// //   }
// // }

class SearchScreen extends StatefulWidget with ChangeNotifier {
   SearchScreen([this.authToken, this.userId, this.searchList]);

  @override
  _SearchScreenState createState() => _SearchScreenState(searchList);
  static const routeName = '/Search';
  final String authToken;
  final String userId;
  final List searchList ;
}

class _SearchScreenState extends State<SearchScreen> {
  static const historyLength = 5;
//  static const routeName = '/Search';
  _SearchScreenState(searchList);
  String selectedTerm;
  List<String> _searchHistory = [
    // 'fuchsia',
    // 'flutter',
    // 'widgets',
    // 'resocoder',
  ];
  void deleteSearch(String term) async {
    Uri url = Uri.parse(
        'https://flutter-update-93051-default-rtdb.firebaseio.com/search/${widget.userId}.json?auth=${widget.authToken}&"orderBy"="user1"&"equalTo"="$term"');
    final existingSearchIndex = _searchHistory.indexWhere((search) => search==term);
    //print(existingSearchIndex);
    var existingSearch = _searchHistory[existingSearchIndex];
    setState(() {
      _searchHistory.removeAt(existingSearchIndex);
    });


    final response = await http.delete(url);
   // print(json.decode(response.body));
    if (response.statusCode >= 400) {
      _searchHistory.insert(existingSearchIndex, existingSearch);
      throw HttpException("could not delete your search .");
    }
    existingSearch = null;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
 //   final  filterString =filterByUser ? '&orderBy="creatorId"&equalTo="${widget.userId}"':"" ;
    // var url = Uri.https(
    //     "flutter-update-93051-default-rtdb.firebaseio.com",
    //     "products.json",{"auth": "$authToken","+orderBy":"+creatorId","+equalTo":"+$userId"}
    // );
    // Uri url = Uri.parse(
    //     'https://flutter-update-93051-default-rtdb.firebaseio.com/products.json?auth=${widget.authToken}');
    Uri url = Uri.parse(
        'https://flutter-update-93051-default-rtdb.firebaseio.com/search/${widget.userId}.json?auth=${widget.authToken}');
    // print(url);

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
    //   print(json.decode(response.body));
      final List<String> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        if(!loadedProducts.contains(prodData["user1"])){
        loadedProducts.add(prodData["user1"]);
        }

      });
      setState(() {
        _searchHistory = loadedProducts;
      });

       //print(loadedProducts);
    //  notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addSearch(String token ,String userId) async {
    // final url = Uri.https(
    //     "flutter-update-93051-default-rtdb.firebaseio.com",
    //     "/userFavourites/$userId.json",{"auth": "${token}"}
    // );
    Uri url = Uri.parse(
        'https://flutter-update-93051-default-rtdb.firebaseio.com/search/${userId}.json?auth=${token}');
    // final url = Uri.https("flutter-update-93051-default-rtdb.firebaseio.com",
    //     "userSearch.json", {"auth": "${widget.authToken}"});
   // print(widget.authToken);
 //   print(widget.searchList);
 //   print(widget.userId);
    try {
      // final response = await http.put(
      //   url,
      //   body: json.encode(
      //     selectedTerm,
      //   ),
      // );
      final response = await http.post(
        url,
        body: json.encode({
          "user1":selectedTerm,
         }
        ),
      );
      final newProduct = selectedTerm;
    //  _searchHistory.add(newProduct);
    //  print(json.decode(response.body));
   //   print(selectedTerm);
    } catch (error) {
      print(error);
      throw (error);
    }

  }

  List<String> filteredSearchHistory;



  List<String> filterSearchTerms({
    @required String filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }

    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }

    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void deleteSearchTerm(String term) {
    deleteSearch(term);
    _searchHistory.removeWhere((t) => t == term);

    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  FloatingSearchBarController controller;
  var _isInit = true;
  void didChangeDependencies() {
    if (_isInit) {
      //   setState(() {
      //     _isLoading = true;
      //   });
      fetchAndSetProducts().then((value) {
        //     setState(() {
        //       _isLoading = false;
        //     });
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    List<String> searchList=_searchHistory ;
  //  print(searchList);
  //  fetchAndSetProducts();
    controller = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   final auth= Provider.of<Auth>(context);
    return Scaffold(
      drawer: AppDrawer(),
      body: FloatingSearchBar(
        controller: controller,
        body: FloatingSearchBarScrollNotifier(
          child: SearchResultsListView(
            searchTerm: selectedTerm,
          ),
        ),
        transition: CircularFloatingSearchBarTransition(),
        physics: BouncingScrollPhysics(),
        title: Text(
          selectedTerm ?? 'The Search App',
          style: Theme.of(context).textTheme.headline6,
        ),
        hint: 'Search and find out...',
        actions: [
          FloatingSearchBarAction.searchToClear(),
        ],
        onQueryChanged: (query) {
          setState(() {
            filteredSearchHistory = filterSearchTerms(filter: query);
          });
        },
        onSubmitted: (query) {
          setState(() {
            addSearchTerm(query);
            selectedTerm = query;
            addSearch(auth.token, auth.userId);
          });
          controller.close();
        },
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 4,
              child: Builder(
                builder: (context) {
                  if (filteredSearchHistory.isEmpty &&
                      controller.query.isEmpty) {
                    return Container(
                      height: 56,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Start searching',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else if (filteredSearchHistory.isEmpty) {
                    return
                        ListTile(
                          title: Text(controller.query),
                          leading: const Icon(Icons.search),
                          onTap: () {
                            setState(() {
                              addSearchTerm(controller.query);
                              selectedTerm = controller.query;
                            });
                            controller.close();
                          },
                        );

                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: filteredSearchHistory
                          .map(
                            (term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    deleteSearchTerm(term);
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  putSearchTermFirst(term);
                                  selectedTerm = term;
                                });
                                controller.close();
                              },
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchResultsListView extends StatelessWidget {
  final String searchTerm;

  const SearchResultsListView({
    Key key,
    @required this.searchTerm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchTerm == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
            ),
            Text(
              'Start searching',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      );
    }
    Products products = Provider.of<Products>(context);
    List<Product> productsList = products.items;
    //  List namesList=(productsList.firstWhere((product) => product.title==searchTerm)).tolist();
    try {
      // void product =
      //      productsList.forEach((product) => product.title == searchTerm);
      List<Product> productNameList = [];
      for (int i = 0; i < productsList.length; i++) {
        if (productsList[i]
            .title
            .toLowerCase()
            .contains(searchTerm.toLowerCase())) {
          productNameList.add(productsList[i]);
        }
      }
    //  print(productNameList);
      // print(product);
      final fsb = FloatingSearchBar.of(context);
      return Padding(
        padding: EdgeInsets.only(top: fsb.height + fsb.margins.vertical),
        child: productNameList.length == 0
            ? Center(
                child: Text(
                "There is no results .",
                style: TextStyle(fontSize: 50, color: Colors.black),
              ))
            : ListView.builder(
                itemCount: productNameList.length,
                itemBuilder: (BuildContext context, int i) {
              //    print(i);
                  return ListTile(
                    title: Text('${productNameList[i].title}'),
                    subtitle: Text("${productNameList[i].description}"),
                    hoverColor: Colors.red,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: productNameList[i].id,
                      );
                    },
                  );
                },
              ),
      );
    } catch (error) {
      print(error);
    }
  }
}
