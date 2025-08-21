import 'package:flutter/material.dart';

class HomeModel {
  final String nome;
  final String imagem;
  final Widget target;
  final bool alert;

  const HomeModel({
    required this.nome,
    required this.imagem,
    required this.target,
    this.alert = false,
  });
}

class CategoryModel {
  final String titulo;
  final List<HomeModel> jogos;

  const CategoryModel({
    required this.titulo,
    required this.jogos,
  });
}