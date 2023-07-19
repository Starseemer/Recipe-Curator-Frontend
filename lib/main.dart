import 'package:flutter/material.dart';
import 'package:recipe_curator/cooking_terms.dart';
import 'package:recipe_curator/edit_recipe.dart';
import 'package:recipe_curator/user.dart';
import 'login.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'helpers/cookie_manager.dart';
import 'dart:convert';
import 'molecules/recipe_card.dart';
import 'recipe.dart';
import 'ingredients.dart';
import 'new_recipe.dart';
import 'favourites.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

// final GoRouter _router = GoRouter(
//     initialLocation: MyCookieManager().getCookie() != '' ? '/home' : '/login',
//     routes: <RouteBase>[
//       GoRoute(
//         path: '/login',
//         builder: (BuildContext context, GoRouterState state) {
//           return const Login();
//         },
//       ),
//       GoRoute(
//         path: '/signup',
//         builder: (BuildContext context, GoRouterState state) {
//           return const Signup();
//         },
//       ),
//       GoRoute(
//         path: '/home',
//         builder: (BuildContext context, GoRouterState state) {
//           return const MyHomePage(
//             title: 'Recipe Curator',
//           );
//         },
//       ),
//       GoRoute(
//         name: "recipe",
//         path: '/recipe/:id',
//         builder: (BuildContext context, GoRouterState state) {
//           return Recipe(id: int.parse(state.pathParameters['id']!));
//         },
//       ),
//       GoRoute(
//         name: "edit-recipe",
//         path: "/edit-recipe/:rid",
//         builder: (BuildContext context, GoRouterState state) {
//           return EditRecipe(id: int.parse(state.pathParameters['rid']!));
//         },
//       ),
//       GoRoute(
//         path: "/ingredients",
//         builder: (BuildContext context, GoRouterState state) {
//           return const Ingredients();
//         },
//       ),
//       GoRoute(
//         path: "/new_recipe",
//         builder: (BuildContext context, GoRouterState state) {
//           return const NewRecipe();
//         },
//       ),
//       GoRoute(
//         path: "/cooking-terms",
//         builder: (BuildContext context, GoRouterState state) {
//           return const CookingTerms();
//         },
//       ),
//       GoRoute(
//         path: "/favourites",
//         builder: (BuildContext context, GoRouterState state) {
//           return const Favourites();
//         },
//       ),
//     ]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Curator',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 23, 70, 149)),
        useMaterial3: true,
      ),
      // routerConfig: _router,
      initialRoute: MyCookieManager().getCookie() != ''
          ? '/home'
          : '/login', // if the user is logged in, go to the home page, otherwise go to the login page
      routes: {
        '/home': (context) => const MyHomePage(title: 'Recipe Curator'),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/recipe': (context) => const Recipe(id: 0),
        '/ingredients': (context) => const Ingredients(),
        '/new_recipe': (context) => const NewRecipe(),
        '/cooking-terms': (context) => const CookingTerms(),
        '/favourites': (context) => const Favourites(),
        '/edit-recipe': (context) => const EditRecipe(id: 0),
        '/user': (context) => const User(),
      },
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name!.split('/');
        if (MyCookieManager().getCookie() == '') {
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) => const Login(),
          );
        }
        if (pathElements[0] != '') {
          return null;
        }
        if (pathElements[1] == 'recipe') {
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) =>
                Recipe(id: int.parse(pathElements[2])),
          );
        } else if (pathElements[1] == 'edit-recipe') {
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) =>
                EditRecipe(id: int.parse(pathElements[2])),
          );
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> recipes = [];
  String token = "";
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  List<MultiSelectItem<dynamic>> _ingredients = [];
  List<MultiSelectItem<dynamic>> _cookingTerms = [];
  List<dynamic> _selectedIngredients = [];
  List<dynamic> _selectedCookingTerms = [];

  void getIngredients() async {
    List<dynamic> ingredients = [];
    http.Response response = await http.get(
      Uri.http('localhost:8002', '/ingredients'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    List<dynamic> cookingTerms = [];
    http.Response _response = await http.get(
      Uri.http('localhost:8002', '/cooking-terms'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        'Authorization': MyCookieManager().getCookie(),
      },
    );

    if (response.statusCode == 200) {
      ingredients = jsonDecode(response.body);
      cookingTerms = jsonDecode(_response.body);
      setState(() {
        _ingredients = ingredients
            .map((ingredient) => MultiSelectItem<dynamic>(
                  ingredient,
                  ingredient['name'],
                ))
            .toList();
        _cookingTerms = cookingTerms
            .map((cookingTerm) => MultiSelectItem<dynamic>(
                  cookingTerm,
                  cookingTerm['name'],
                ))
            .toList();
        _ingredients.addAll(_cookingTerms);
      });
    } else if (response.statusCode == 401) {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  Future<void> get_recipes() async {
    try {
      print("Printing cookie:");
      print(MyCookieManager().getCookie());
      http.Response response = await http.get(
        Uri.http('localhost:8001', '/recipes'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Access-Control-Allow-Origin": "*",
          'Accept': '*/*',
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          recipes = jsonDecode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.popAndPushNamed(context, '/login');
      }
    } catch (e) {
      print("Exception caught: ");
      print(e);
    }
  }

  Future<void> searchRecipe(String term) async {
    setState(() {
      isLoading = true;
    });

    List<int> selectedVoc = [];
    for (dynamic ing in _selectedIngredients) {
      selectedVoc.add(ing['id']);
    } // get the names of the selected ingredients
    if (term == null) {
      term = "";
    }
    try {
      http.Response response = await http.post(
        Uri.http('localhost:8005', '/search/recipes'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Access-Control-Allow-Origin": "*",
          'Accept': '*/*',
          'Authorization': token,
        },
        body: jsonEncode(<String, dynamic>{
          'term': term,
          'shared_voc_ids': selectedVoc,
        }),
      );
      setState(() {
        recipes = jsonDecode(response.body);
        isLoading = false;
      });
    } catch (e) {
      print("Exception caught: ");
      print(e);
    }
  }

  void getCookie() {
    setState(() {
      token = MyCookieManager().getCookie();
    });
  }

  @override
  void initState() {
    super.initState();
    getCookie();
    get_recipes();
    getIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: Text(widget.title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search Recipes',
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 0.5),
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: 45,
                    maxWidth: 300,
                  ),
                ),
                style: TextStyle(color: Colors.white),
                controller: searchController,
                onSubmitted: (value) {
                  searchRecipe(value);
                },
              ),
              SizedBox(
                height: 100,
                child: ClipRect(
                  clipBehavior: Clip.antiAlias,
                  child: MultiSelectBottomSheetField(
                    initialChildSize: 0.4,
                    searchHint: "Filter by ingredient or cooking term",
                    buttonText: Text("Filter by ingredient or cooking term",
                        style: TextStyle(color: Colors.white)),
                    items: _ingredients,
                    buttonIcon: Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(width: 0.5, color: Colors.white),
                    )),
                    isDismissible: true,
                    initialValue: _selectedIngredients,
                    searchable: true,
                    title: Text("Filter by ingredients and cooking terms"),
                    listType: MultiSelectListType.CHIP,
                    onConfirm: (p0) {
                      setState(() {
                        _selectedIngredients = p0;
                      });
                      searchRecipe(searchController.text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/new_recipe').then((_) {
                get_recipes();
              });
            },
            child: const Text(
              'Create Recipe',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/favourites');
            },
            child: const Text(
              'Favourites',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/cooking-terms');
            },
            child: const Text(
              'Cooking Terms',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/ingredients');
            },
            child: const Text(
              'Ingredients',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/user');
            },
            child: const Text(
              'Profile',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              MyCookieManager().clearCookie();
              Navigator.of(context).pushNamed('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    data: recipes[index],
                  );
                },
              ),
      ),
    );
  }
}
