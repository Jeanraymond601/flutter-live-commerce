import 'package:flutter/material.dart';
import '../models/abonnement.dart';

class AbonnementCard extends StatelessWidget {
  final AbonnementPlan plan;
  final bool isSelected;
  final ValueChanged<String> onSelected;
  final VoidCallback onBuyNow;

  const AbonnementCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onSelected,
    required this.onBuyNow,
  });

  // Couleurs spécifiques selon les nouvelles spécifications
  Color get _planColor {
    switch (plan.id) {
      case 'basic':
        return const Color(0xFFFFB300); // Jaune/or
      case 'comfort':
        return const Color(0xFF2196F3); // Bleu
      case 'premium':
        return const Color(0xFFF44336); // Rouge/orangé
      default:
        return const Color(0xFF2196F3);
    }
  }

  // Caractéristiques marketing spécifiques pour chaque plan
  List<String> get _marketingFeatures {
    switch (plan.id) {
      case 'basic':
        return [
          '🟡 BASIC – Caractéristiques marketing',
          '• Idéal pour débuter',
          '• Support standard',
          '• Statistiques limitées',
          '• Jusqu\'à 1 live par jour',
        ];
      case 'comfort':
        return [
          '🔵 COMFORT – Caractéristiques marketing',
          '• Plus de visibilité',
          '• Lives illimités',
          '• Support prioritaire',
          '• Accès tableau de bord avancé',
        ];
      case 'premium':
        return [
          '🔴 PREMIUM – Caractéristiques marketing',
          '• Boost de visibilité premium',
          '• Mise en avant automatique',
          '• Support VIP 24/7',
          '• Outils marketing inclus',
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(plan.id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isSelected ? _planColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du plan en majuscules et en couleur
                Text(
                  plan.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _planColor,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // Grand cercle dégradé avec le prix
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _planColor.withOpacity(0.8),
                          _planColor.withOpacity(0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _planColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              plan.price.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 0.9,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -14),
                              child: Text(
                                plan.price.toStringAsFixed(2).split('.')[1],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'per month',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Liste des caractéristiques marketing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _marketingFeatures.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              feature.startsWith('🟡') ||
                                  feature.startsWith('🔵') ||
                                  feature.startsWith('🔴')
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Bouton BUY NOW
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      onSelected(plan.id);
                      onBuyNow();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _planColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: _planColor.withOpacity(0.3),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('BUY NOW'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
