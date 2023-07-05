import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Construye la interfaz de usuario de la aplicación
  @override
  Widget build(BuildContext context) {
    // Utiliza el patrón de diseño Provider para el manejo del estado
    return ChangeNotifierProvider(
      // Crea una instancia de MyAppState para manejar el estado de la aplicación
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        // Establece MyHomePage como la página principal de la aplicación
        home: MyHomePage(),
      ),
    );
  }
}

// Clase para manejar el estado de la aplicación
class MyAppState extends ChangeNotifier {
  // La palabra actual que se muestra al usuario
  var current = WordPair.random();
  // Lista de todas las palabras que se han mostrado al usuario
  var history = <WordPair>[];

  // Clave para acceder al estado de la lista animada de historial
  GlobalKey? historyListKey;

  // Genera una nueva palabra y la añade al historial
  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  // Lista de palabras que el usuario ha marcado como favoritas
  var favorites = <WordPair>[];

  // Marca o desmarca una palabra como favorita
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  // Elimina una palabra de la lista de favoritos
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

// Clase para la página principal de la aplicación
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Clase para el estado de la página principal de la aplicación
class _MyHomePageState extends State<MyHomePage> {
  // Índice de la página actual que se muestra al usuario
  var selectedIndex = 0;

  // Construye la interfaz de usuario de la página principal
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    // Selecciona la página actual en función del índice seleccionado
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // Contenedor para la página actual, con su color de fondo y una sutil animación de cambio
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    // Devuelve un Scaffold que contiene la interfaz de usuario de la página principal
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Utiliza un diseño más adecuado para móviles con BottomNavigationBar en pantallas estrechas
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            // Utiliza NavigationRail en pantallas más anchas
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

// Clase para la página del generador de palabras
class GeneratorPage extends StatelessWidget {
  // Construye la interfaz de usuario de la página del generador
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // Determina el icono de favorito en función de si la palabra actual es una favorita
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    // Devuelve la interfaz de usuario de la página del generador
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

// Clase para la tarjeta grande que muestra la palabra actual
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  // Construye la interfaz de usuario de la tarjeta grande
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // Devuelve la interfaz de usuario de la tarjeta grande
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
         duration: Duration(milliseconds: 200),
          // Asegura que la palabra compuesta se ajuste correctamente cuando la ventana es demasiado estrecha
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Clase para la página de favoritos
class FavoritesPage extends StatelessWidget {
  // Construye la interfaz de usuario de la página de favoritos
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    // Si el usuario no tiene favoritos, muestra un mensaje
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    // Devuelve la interfaz de usuario de la página de favoritos
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Hace un mejor uso de las ventanas anchas con una cuadrícula
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Clase para la lista de historial
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

// Clase para el estado de la lista de historial
class _HistoryListViewState extends State<HistoryListView> {
  // Necesario para que [MyAppState] pueda decirle a [AnimatedList] que anime los nuevos elementos
  final _key = GlobalKey();

  // Se utiliza para "desvanecer" los elementos de historial en la parte superior, para sugerir la continuación
  static const Gradient _maskingGradient = LinearGradient(
    // Este gradiente va de totalmente transparente a totalmente negro opaco...
    colors: [Colors.transparent, Colors.black],
    // ... desde la parte superior (transparente) hasta la mitad (0.5) del camino hacia abajo
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Construye la interfaz de usuario de la lista de historial
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    // Devuelve la interfaz de usuario de la lista de historial
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // Este modo de mezcla toma la opacidad del shader (es decir, nuestro gradiente)
      // y la aplica al destino (es decir, nuestra lista animada)
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
