import 'dart:math';

import 'package:amc_2024/src/theme/colors.dart';
import 'package:amc_2024/src/view/leftover/leftover_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeftoverItem extends StatelessWidget {
  final double _borderRadius = 20.0;

  final String storeName;
  final double distanceToWalk;
  final double ecoScore;

  const LeftoverItem(
      {super.key,
      required this.storeName,
      required this.distanceToWalk,
      required this.ecoScore});

  getProductType() {
    return ProductType.values[Random().nextInt(ProductType.values.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius)),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    storeName,
                    style: const TextStyle(
                        color: kcPrimaryVariant,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8.0),
                  child: Text(
                    "${AppLocalizations.of(context)!.could_save} ${Random().nextInt(16) + 5}\$ !",
                    style: const TextStyle(
                        color: kcPrimaryVariant,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                      children: [
                        LeftoverLabel(productType: getProductType()),
                      ]
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.directions_walk),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text("$distanceToWalk Km", style: const TextStyle(
                        color: kcPrimaryVariant,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600
                      )),
                    ),
                    const Icon(Icons.energy_savings_leaf),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text("$ecoScore", style: const TextStyle(
                        color: kcPrimaryVariant,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600
                      )),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
