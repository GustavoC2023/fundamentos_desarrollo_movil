import 'package:flutter/material.dart';
import '../models/pizza.dart';

class PizzaCard extends StatelessWidget {
  final Pizza pizza;
  final VoidCallback onTap;

  const PizzaCard({super.key, required this.pizza, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade100,
          child: Text(pizza.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          pizza.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(pizza.descripcion),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('M: \$${pizza.precioMediana.toStringAsFixed(0)}'),
            Text('G: \$${pizza.precioGrande.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}