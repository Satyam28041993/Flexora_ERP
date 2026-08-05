import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'app_nav_model.dart';

/// Grouped, collapsible sidebar for the Flexora shell.
///
/// Replaces the previous flat 17-item NavigationRail: destinations are now
/// grouped by shop-floor area, each group carrying its own accent colour, and
/// a filter box narrows a long list to a single keystroke-reachable item.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late final Set<int> _expanded;
  final TextEditingController _filterCtrl = TextEditingController();
  String _query = '';
  bool _collapsed = false;

  /// Item labels. Kept high-contrast against the dark slate rail so the
  /// sidebar stays readable on a bright shop-floor screen.
  static const Color _itemText = Color(0xFFCBD5E1);

  /// Group headings — dimmer than items, but still clearly legible.
  static const Color _groupText = Color(0xFF94A3B8);

  /// Hint text and chevrons only.
  static const Color _faintText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    // Start with only the active group open, so the rail stays scannable.
    _expanded = {AppNavigation.groupIndexOf(widget.selectedIndex)};
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _expanded.add(AppNavigation.groupIndexOf(widget.selectedIndex));
    }
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  bool _matches(NavItem item) =>
      _query.isEmpty || item.label.toLowerCase().contains(_query);

  @override
  Widget build(BuildContext context) {
    final width = _collapsed ? 78.0 : 268.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          if (!_collapsed) _buildFilter(),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (var g = 0; g < AppNavigation.groups.length; g++)
                  ..._buildGroup(g),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Row(
        mainAxisAlignment:
            _collapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!_collapsed)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'FLEXORA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.8,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: _collapsed ? 'Expand menu' : 'Collapse menu',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              _collapsed ? Icons.chevron_right : Icons.chevron_left,
              color: _itemText,
              size: 22,
            ),
            onPressed: () => setState(() {
              _collapsed = !_collapsed;
              if (_collapsed) {
                _filterCtrl.clear();
                _query = '';
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: _filterCtrl,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Find a screen...',
            hintStyle: const TextStyle(color: _faintText, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: _groupText, size: 19),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, color: _groupText, size: 16),
                    onPressed: () => setState(() {
                      _filterCtrl.clear();
                      _query = '';
                    }),
                  ),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroup(int g) {
    final group = AppNavigation.groups[g];
    final base = AppNavigation.firstFlatIndexOf(g);

    final visible = <int>[
      for (var i = 0; i < group.items.length; i++)
        if (_matches(group.items[i])) i,
    ];
    if (visible.isEmpty) return const [];

    // A live filter overrides manual expansion, otherwise matches stay hidden.
    final open = _query.isNotEmpty || _expanded.contains(g);
    final hasActive = visible.any((i) => base + i == widget.selectedIndex);

    return [
      if (_collapsed)
        const SizedBox(height: 8)
      else
        _buildGroupHeader(g, group, open, hasActive),
      if (open || _collapsed)
        for (final i in visible)
          _buildItem(group, group.items[i], base + i),
    ];
  }

  Widget _buildGroupHeader(int g, NavGroup group, bool open, bool hasActive) {
    return InkWell(
      onTap: _query.isNotEmpty
          ? null
          : () => setState(() {
                if (!_expanded.remove(g)) _expanded.add(g);
              }),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 10, 8, 2),
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 9),
        decoration: BoxDecoration(
          // Active group gets a faint wash of its own colour so the current
          // area of the factory is obvious at a glance.
          color: hasActive ? group.color.withAlpha(28) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: group.color.withAlpha(hasActive ? 82 : 46),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(group.icon, size: 16, color: group.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                group.title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasActive ? Colors.white : _groupText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            Icon(
              open ? Icons.expand_less : Icons.expand_more,
              size: 19,
              color: hasActive ? Colors.white70 : _faintText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(NavGroup group, NavItem item, int flatIndex) {
    final selected = flatIndex == widget.selectedIndex;

    final tile = Container(
      margin: EdgeInsets.fromLTRB(_collapsed ? 10 : 14, 2, _collapsed ? 10 : 10, 2),
      decoration: BoxDecoration(
        color: selected ? group.color.withAlpha(64) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border(
          left: BorderSide(
            color: selected ? group.color : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        hoverColor: Colors.white.withAlpha(18),
        onTap: () => widget.onDestinationSelected(flatIndex),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _collapsed ? 0 : 11,
            vertical: 11,
          ),
          child: Row(
            mainAxisAlignment:
                _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: selected ? Colors.white : _itemText,
              ),
              if (!_collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : _itemText,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return _collapsed ? Tooltip(message: item.label, child: tile) : tile;
  }
}
