import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vila_tour_pmdm/src/models/models.dart';
import 'package:vila_tour_pmdm/src/providers/theme_provider.dart';
import 'package:vila_tour_pmdm/src/screens/screens.dart';
import 'package:vila_tour_pmdm/src/services/article_service.dart';
import 'package:vila_tour_pmdm/src/utils/utils.dart';
import 'package:vila_tour_pmdm/src/widgets/widgets.dart';
import 'package:vila_tour_pmdm/src/providers/providers.dart';

class HomePage extends StatefulWidget {
  static final routeName = 'home_screen';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Índice actual del slider

  late Future<List<Article>> _futureArticles; // Define el future aquí

  @override
  void initState() {
    super.initState();
    _futureArticles =
        ArticleService().getLastArticles(); // Asigna el future solo una vez
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavigationBar(),
      body: Stack(
        children: [
          WavesWidget(),
          SingleChildScrollView(
            child: Column(
              children: [
                BarScreenArrow(labelText: 'VILATOUR', arrowBack: false),
                Container(
                  height: 320,
                  child: FutureBuilder(
                    future: _futureArticles,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        List<Article> articles = snapshot.data!;

                        return Column(
                          children: [
                            CarouselSlider.builder(
                              options: carouselOptions(),
                              itemCount: articles.length,
                              itemBuilder: (context, index, realIndex) {
                                var article = articles[index];
                                return ImageCarousel(article: article);
                              },
                            ),
                            const SizedBox(height: 10),
                            DockIndex(
                              articles: articles,
                              currentIndex: _currentIndex,
                            ),
                          ],
                        );
                      } else {
                        return Center(
                          child: Text('No hay artículos disponibles.'),
                        );
                      }
                    },
                  ),
                ),
                _MainContent()
              ],
            ),
          ),
        ],
      ),
    );
  }

  CarouselOptions carouselOptions() {
    return CarouselOptions(
      height: 300,
      autoPlay: true, // Reproducción automática
      autoPlayInterval: const Duration(seconds: 3), // Intervalo
      enlargeCenterPage: true, // Resalta la diapositiva central
      viewportFraction: 0.9, // Ocupa el 90% del ancho de la pantalla
      onPageChanged: (index, reason) {
        setState(() {
          _currentIndex = index; // Actualiza el índice actual
        });
      },
    );
  }
}

class DockIndex extends StatelessWidget {
  const DockIndex({
    super.key,
    required this.articles,
    required int currentIndex,
  }) : _currentIndex = currentIndex;

  final List<Article> articles;
  final int _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        articles.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 12 : 8, // Tamaño del punto
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? Colors.blueAccent // Color activo
                : Colors.grey, // Color inactivo
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class ImageCarousel extends StatelessWidget {
  const ImageCarousel({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String route = LoginScreen.routeName;
        if (article is Festival) route = DetailsFestival.routeName;
        if (article is Place) route = PlacesDetails.routeName;
        if (article is Recipe) route = RecipeDetails.routeName;
        Navigator.pushNamed(
          context,
          route,
          arguments: article,
        );
      },
      child: Hero(
        tag: article.id,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: FadeInImage(
            placeholder: const AssetImage('assets/logo.ico'),
            image: article.images.isEmpty
                ? const AssetImage('assets/logo.ico')
                : MemoryImage(
                    decodeImageBase64(article.images.first.path),
                  ),
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
            placeholderFit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class ToggleThemeButton extends StatelessWidget {
  const ToggleThemeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
      child: Icon(Icons.dark_mode),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: [
            _SingleCard(
              route: PlacesScreen.routeName,
              color: Colors.blueAccent,
              icon: Icons.place,
              text: 'Lugares de Interés',
            ),
            _SingleCard(
              route: FestivalsScreen.routeName,
              color: Colors.pinkAccent,
              icon: Icons.celebration,
              text: 'Festivales',
            ),
          ],
        ),
        TableRow(
          children: [
            _SingleCard(
              route: RecipesScreen.routeName,
              color: Colors.purpleAccent,
              icon: Icons.restaurant_menu,
              text: 'Recetas',
            ),
            _SingleCard(
              route: LoginScreen.routeName,
              color: Colors.purple,
              icon: Icons.map,
              text: 'Rutas',
            ),
          ],
        ),
      ],
    );
  }
}

class _SingleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String route;

  _SingleCard({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: 100,
              height: 160,
              decoration: defaultDecoration(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(icon, size: 35, color: Colors.white),
                    backgroundColor: color,
                  ),
                  SizedBox(height: 15),
                  Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
