import 'package:flutter/material.dart';

/// Groups [items] (newest-first) into columns for a bottom-anchored masonry grid.
///
/// Placement order: bottom-right → left → up → left → …
/// For 2 columns with items A (newest) … D (oldest):
/// ```
/// [ D ] [ C ]
/// [ B ] [ A ]
/// ```
List<List<T>> groupItemsBottomRightMasonry<T>(
  List<T> items, {
  required int crossAxisCount,
}) {
  if (crossAxisCount < 1) {
    throw ArgumentError.value(crossAxisCount, 'crossAxisCount', 'must be >= 1');
  }

  final columns = List.generate(crossAxisCount, (_) => <T>[]);
  for (var i = 0; i < items.length; i++) {
    final col = (crossAxisCount - 1) - (i % crossAxisCount);
    columns[col].add(items[i]);
  }
  return columns;
}

/// Masonry grid anchored to the bottom; newest item sits in the bottom-right cell.
class BottomRightMasonryGrid<T> extends StatelessWidget {
  const BottomRightMasonryGrid({
    super.key,
    required this.items,
    required this.crossAxisCount,
    required this.itemBuilder,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
  });

  /// Newest-first (index 0 = most recent check).
  final List<T> items;
  final int crossAxisCount;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final columns = groupItemsBottomRightMasonry(items, crossAxisCount: crossAxisCount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var col = 0; col < crossAxisCount; col++) ...[
          if (col > 0) SizedBox(width: crossAxisSpacing),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _columnChildren(context, columns[col]),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _columnChildren(BuildContext context, List<T> columnItems) {
    // Within a column, older items stack above newer ones (newest at bottom).
    final ordered = columnItems.reversed.toList();
    final children = <Widget>[];
    for (var row = 0; row < ordered.length; row++) {
      if (row > 0) children.add(SizedBox(height: mainAxisSpacing));
      children.add(itemBuilder(context, ordered[row]));
    }
    return children;
  }
}
