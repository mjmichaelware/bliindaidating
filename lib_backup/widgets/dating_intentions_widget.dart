import 'package:flutter/material.dart';

/// A widget that shows the user’s current dating intentions and
/// lets them update them in‑place (or call a callback for a deeper screen).
///
/// ✦  Fits the Blind AI Dating dark‑purple cosmic theme
/// ✦  No photos, emojis, DNS, or external fonts
/// ✦  Uses Inter font + Material 3 as defined in main.dart
/// ✦  Ready for Flutter Web build with smooth animations
class DatingIntentionsWidget extends StatefulWidget {
  /// Current selected intention(s); can be multiple for flexibility.
  final List<String> currentIntentions;

  /// Callback when the user updates their intentions.
  final ValueChanged<List<String>> onIntentionsChanged;

  const DatingIntentionsWidget({
    super.key,
    required this.currentIntentions,
    required this.onIntentionsChanged,
  });

  @override
  State<DatingIntentionsWidget> createState() => _DatingIntentionsWidgetState();
}

class _DatingIntentionsWidgetState extends State<DatingIntentionsWidget>
    with SingleTickerProviderStateMixin {
  /// Possible intentions offered by the product team (edit as you wish).
  final List<String> _allIntentions = const [
    'Long‑term Relationship',
    'Short‑term Dating',
    'Open to Explore',
    'Friendship',
    'Activity Partner',
  ];

  late List<String> _selected; // mutable copy of currentIntentions
  bool _editMode = false;
  late AnimationController _controller;

  // Colors for chip states
  Color get _chipSelectedColor => Colors.pink.shade400;
  Color get _chipUnselectedColor => Colors.deepPurple.shade700;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.currentIntentions);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant DatingIntentionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIntentions != widget.currentIntentions) {
      _selected = List<String>.from(widget.currentIntentions);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      _editMode ? _controller.forward() : _controller.reverse();
    });
  }

  void _onChipTapped(String intention) {
    setState(() {
      if (_selected.contains(intention)) {
        _selected.remove(intention);
      } else {
        _selected.add(intention);
      }
    });
  }

  void _saveIntentions() {
    widget.onIntentionsChanged(_selected);
    _toggleEditMode();
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.6),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ───────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.flag_rounded,
                  color: _editMode ? Colors.pink.shade300 : Colors.white70,
                  size: 32),
              const SizedBox(width: 10),
              Text(
                'Dating Intentions',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: _editMode ? 'Cancel' : 'Edit',
                icon: Icon(
                  _editMode ? Icons.close_rounded : Icons.edit_rounded,
                  color: Colors.white70,
                  size: 26,
                ),
                onPressed: _toggleEditMode,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Display or Edit Mode ────────────────────────────────────────────
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.easeInOut,
            duration: const Duration(milliseconds: 400),
            crossFadeState: _editMode
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildDisplayMode(theme),
            secondChild: _buildEditMode(theme),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  DISPLAY MODE
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildDisplayMode(ThemeData theme) {
    if ((_selected ?? []).isEmpty) {
      return Text(
        'No intentions set yet.',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: Colors.white54, fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _selected
          .map(
            (intention) => Chip(
              label: Text(intention),
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: _chipSelectedColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  EDIT MODE
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildEditMode(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: (_allIntentions ?? []).map((intention) {
            final bool selected = _selected.contains(intention);
            return FilterChip(
              label: Text(
                intention,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: selected,
              selectedColor: _chipSelectedColor,
              backgroundColor: _chipUnselectedColor,
              showCheckmark: false,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) => _onChipTapped(intention),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _saveIntentions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              minimumSize: const Size(140, 44),
              shadowColor: Colors.red.shade900,
            ),
            child: const Text('Save'),
          ),
        )
      ],
    );
  }
}
