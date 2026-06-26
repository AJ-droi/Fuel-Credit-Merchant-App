import 'package:flutter/material.dart';

class KpiCardModel {
  const KpiCardModel({
    required this.title,
    required this.value,
    required this.suffix,
    required this.meta,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.chip,
  });

  final String title;
  final String value;
  final String suffix;
  final String meta;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String? chip;
}

class TransactionModel {
  const TransactionModel({
    required this.code,
    required this.timeAgo,
    required this.litres,
    required this.product,
    required this.amount,
    required this.verified,
  });

  final String code;
  final String timeAgo;
  final String litres;
  final String product;
  final String amount;
  final bool verified;
}
