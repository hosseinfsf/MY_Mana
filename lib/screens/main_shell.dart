import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/mana_floating_bubble.dart';
import '../widgets/starfield_background.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'plan_screen.dart';
import 'assistant_screen.dart';
import 'more_screen.dart';

/// پنجره‌ی اصلی برنامه — شامل ۵ تب (بند ۱۸ سند مشخصات):
/// امروز / کاوش / برنامه / دستیار / بیشتر
/// به‌علاوه‌ی آیکون شناور و MANA Bubble که روی همه‌ی تب‌ها شناوره.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int currentIndex = 0;

  static const _tabs = [
    _TabInfo(icon: '🏠', label: 'امروز'),
    _TabInfo(icon: '🔍', label: 'کاوش'),
    _TabInfo(icon: '✅', label: 'برنامه'),
    _TabInfo(icon: '🤖', label: 'دستیار'),
    _TabInfo(icon: '⋯', label: 'بیشتر'),
  ];

  final List<Widget> _pages = const [
    HomeScreen(),
    ExploreScreen(),
    PlanScreen(),
    AssistantScreen(),
    MoreScreen(),
  ];

  /// امکان باز شدن یک تب مشخص از بیرون —
  /// مثلاً از MANA Bubble روی آیکون شناور استفاده میشه (بند ۱۹).
  void openTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.colors;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: c.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: StarfieldBackground()),
            SafeArea(
              bottom: false,
              child: IndexedStack(
                index: currentIndex,
                children: _pages,
              ),
            ),
            // آیکون شناور + بابل مانا — روی همه‌ی صفحات
            ManaFloatingBubble(onOpenTab: openTab),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final active = i == currentIndex;
                    final tab = _tabs[i];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => currentIndex = i),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (active)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  width: 16,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: c.accentGradient,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              Text(tab.icon, style: const TextStyle(fontSize: 17)),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: active ? c.textHi : c.textLo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String icon;
  final String label;
  const _TabInfo({required this.icon, required this.label});
}
