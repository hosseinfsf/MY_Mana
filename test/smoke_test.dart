import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mana_dastyar/main.dart';

void main() {
  testWidgets('برنامه بدون خطا بالا میاد و صفحه‌ی آنبوردینگ یا اصلی رو نشون میده',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ManaApp());
    // یه چرخه‌ی build/frame برای اجازه دادن به لود شدن AppState/AiSettings (async)
    await tester.pump(const Duration(milliseconds: 500));

    // نباید هیچ اکسپشنی در حین build رخ بده (مخصوصاً باگ قبلیِ
    // «No MaterialLocalizations found for locale fa»)
    expect(tester.takeException(), isNull);
  });
}
