/// تبدیل تاریخ میلادی به شمسی (جلالی) — پیاده‌سازی مستقل، بدون نیاز به پکیج بیرونی.
/// الگوریتم استاندارد و شناخته‌شده‌ی تبدیل گرگوری↔جلالی.
class JalaliDate {
  final int year;
  final int month; // ۱ تا ۱۲
  final int day;

  const JalaliDate(this.year, this.month, this.day);

  static const List<String> monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  static const List<String> weekdayNames = [
    'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', 'شنبه', 'یکشنبه',
  ];

  /// ساخت از یک DateTime میلادی
  factory JalaliDate.fromDateTime(DateTime g) {
    final converted = _gregorianToJalali(g.year, g.month, g.day);
    return JalaliDate(converted[0], converted[1], converted[2]);
  }

  /// نام روز هفته بر اساس DateTime اصلی (چون تبدیل روز هفته نیازی به الگوریتم جلالی نداره)
  static String weekdayNameFor(DateTime g) {
    // DateTime.weekday: دوشنبه=1 ... یکشنبه=7 -> دقیقاً با ترتیب لیست بالا یکیه
    return weekdayNames[g.weekday - 1];
  }

  String get monthName => monthNames[month - 1];

  /// مثلاً: «چهارشنبه، ۲۱ شهریور ۱۴۰۵»
  String formatFull(DateTime original) {
    return '${weekdayNameFor(original)}، ${_toPersianDigits(day)} $monthName $year';
  }

  /// مثلاً: «۲۱ شهریور»
  String formatShort() => '${_toPersianDigits(day)} $monthName';

  static String _toPersianDigits(int n) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return n.toString().split('').map((d) => fa[int.parse(d)]).join();
  }

  /// الگوریتم تبدیل گرگوری به جلالی (روش شناخته‌شده‌ی عمومی)
  static List<int> _gregorianToJalali(int gy, int gm, int gd) {
    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int jy;
    int gy2 = gy;
    if (gy2 > 1600) {
      jy = 979;
      gy2 -= 1600;
    } else {
      jy = 0;
      gy2 -= 621;
    }
    final gy3 = (gm > 2) ? gy2 + 1 : gy2;
    int days = (365 * gy2) +
        ((gy3 + 3) ~/ 4) -
        ((gy3 + 99) ~/ 100) +
        ((gy3 + 399) ~/ 400) -
        80 +
        gd +
        _sumUntil(gDaysInMonth, gm - 1);
    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    int jm;
    int jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }
    return [jy, jm, jd];
  }

  static int _sumUntil(List<int> arr, int count) {
    int s = 0;
    for (var i = 0; i < count; i++) {
      s += arr[i];
    }
    return s;
  }
}
