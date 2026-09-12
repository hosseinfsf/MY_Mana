import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class TaskItem {
  String text;
  bool done;
  TaskItem(this.text, {this.done = false});
}

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int subtab = 0; // 0: tasks, 1: shopping, 2: notes
  int range = 0; // 0: day, 1: week, 2: month

  final List<TaskItem> tasks = [
    TaskItem('ارسال گزارش هفتگی', done: true),
    TaskItem('ورزش عصرگاهی'),
    TaskItem('مرور پروژه مانا'),
  ];
  final List<TaskItem> shopping = [
    TaskItem('شیر', done: true),
    TaskItem('برنج'),
    TaskItem('میوه'),
  ];
  final List<String> notes = ['فردا با تیم درباره‌ی رابط کاربری صحبت کنم...'];

  final taskCtrl = TextEditingController();
  final shopCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppState>().colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        Text('برنامه', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.textHi)),
        const SizedBox(height: 14),
        Row(
          children: [
            _subtabChip('تسک‌های روزانه', 0, c),
            const SizedBox(width: 8),
            _subtabChip('لیست خرید', 1, c),
            const SizedBox(width: 8),
            _subtabChip('یادداشت هوشمند', 2, c),
          ],
        ),
        const SizedBox(height: 16),
        if (subtab == 0) _buildTasks(c),
        if (subtab == 1) _buildList(shopping, shopCtrl, 'آیتم جدید...', c),
        if (subtab == 2) _buildNotes(c),
      ],
    );
  }

  Widget _subtabChip(String label, int idx, dynamic c) {
    final active = subtab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => subtab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active ? c.accentGradient : null,
            color: active ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5,
                  color: active ? Colors.white : c.textLo,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }

  Widget _buildTasks(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _rangeBtn('روزانه', 0, c),
            const SizedBox(width: 6),
            _rangeBtn('هفتگی', 1, c),
            const SizedBox(width: 6),
            _rangeBtn('ماهانه', 2, c),
          ],
        ),
        const SizedBox(height: 12),
        _buildList(tasks, taskCtrl, 'کار جدید...', c, showList: false),
      ],
    );
  }

  Widget _rangeBtn(String label, int idx, dynamic c) {
    final active = range == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => range = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  color: active ? c.textHi : c.textLo,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }

  Widget _buildList(List<TaskItem> items, TextEditingController ctrl, String hint, dynamic c,
      {bool showList = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((t) => _taskRow(t, c)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _input(ctrl, hint, c)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (ctrl.text.trim().isEmpty) return;
                setState(() {
                  items.add(TaskItem(ctrl.text.trim()));
                  ctrl.clear();
                });
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(gradient: c.accentGradient, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _taskRow(TaskItem t, dynamic c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => t.done = !t.done),
            child: Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.done ? c.accent2 : Colors.transparent,
                border: Border.all(color: c.accent2, width: 2),
              ),
              alignment: Alignment.center,
              child: t.done ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.text,
              style: TextStyle(
                fontSize: 12.5,
                color: t.done ? c.textLo : c.textHi,
                decoration: t.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...notes.map((n) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
              child: Text(n, style: TextStyle(fontSize: 11.5, color: c.textLo, height: 1.7)),
            )),
        Row(
          children: [
            Expanded(child: _input(noteCtrl, 'یادداشت تازه...', c)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (noteCtrl.text.trim().isEmpty) return;
                setState(() {
                  notes.add(noteCtrl.text.trim());
                  noteCtrl.clear();
                });
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(gradient: c.accentGradient, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _input(TextEditingController ctrl, String hint, dynamic c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: TextField(
        controller: ctrl,
        style: TextStyle(fontSize: 12.5, color: c.textHi),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: c.textLo),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }
}
