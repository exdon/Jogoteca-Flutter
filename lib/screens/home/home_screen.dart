import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/data/home/home_data.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/screens/home/category_screen.dart';
import 'package:jogoteca/screens/menu_gestao/about.dart';
import 'package:jogoteca/screens/menu_gestao/configurations.dart';
import 'package:jogoteca/utils/navigation_utils.dart';
import 'package:jogoteca/widget/home/home_card.dart';
import 'package:jogoteca/widget/home/home_carousel_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> _pressedCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          SafeArea(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _buildCarousel(),
                const SizedBox(height: 20),
                ...HomeData.categories.asMap().entries.map(
                      (entry) => _buildCategory(
                    context,
                    categoriaIndex: entry.key,
                    category: entry.value,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.cyanAccent, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          AppConstants.appTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.cyanAccent,
                offset: Offset(0, 0),
              ),
              Shadow(
                blurRadius: 20.0,
                color: Colors.pinkAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: [_buildPopupMenu()],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        if (value == 'config') {
          NavigationUtils.navigateWithSlideAnimation(context, Configurations());
        } else if (value == 'sobre') {
          NavigationUtils.navigateWithSlideAnimation(context, About());
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'config',
          child: Text(AppConstants.configMenuItem),
        ),
        PopupMenuItem(
          value: 'sobre',
          child: Text(AppConstants.aboutMenuItem),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 350,
        autoPlay: true,
        autoPlayInterval: AppConstants.carouselInterval,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
      items: HomeData.carouselGames
          .map((jogo) => HomeCarouselCard(jogo: jogo))
          .toList(),
    );
  }

  Widget _buildCategory(
      BuildContext context, {
        required int categoriaIndex,
        required CategoryModel category,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(context, category),
            _buildCategoryGames(categoriaIndex, category.jogos),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, CategoryModel category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category.titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              NavigationUtils.navigateWithSlideAnimation(
                context,
                CategoryScreen(
                  titulo: category.titulo,
                  jogos: category.jogos,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGames(int categoriaIndex, List<HomeModel> jogos) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: jogos.length,
        itemBuilder: (context, i) {
          final jogo = jogos[i];
          final int cardId = categoriaIndex * 1000 + i;
          final bool isPressed = _pressedCards.contains(cardId);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: HomeCard(
              jogo: jogo,
              isPressed: isPressed,
              onTapDown: () => setState(() => _pressedCards.add(cardId)),
              onTapUp: () => setState(() => _pressedCards.remove(cardId)),
              onTapCancel: () => setState(() => _pressedCards.remove(cardId)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        AppConstants.backgroundImage,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
      ),
    );
  }
}