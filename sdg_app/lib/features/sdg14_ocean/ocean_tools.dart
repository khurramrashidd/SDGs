/// SDG 14 decision logic: is the monsoon fishing ban on?
///
/// The Department of Fisheries imposes a uniform 61-day ban on all fishing
/// vessels in India's Exclusive Economic Zone beyond territorial waters,
/// to let fish breed. The dates differ by coast because the monsoon
/// reaches them at different times:
///   East coast (incl. Andaman & Nicobar): 15 April to 14 June
///   West coast (incl. Lakshadweep):       1 June to 31 July
/// Source: MPEDA, "Ban Period". Coastal states set their own bans inside
/// territorial waters (up to 12 nautical miles), usually for the same
/// season, which is why the tool tells people to check their state notice.

enum Coast { east, west }

class BanWindow {
  final DateTime start; // first banned day
  final DateTime end; // last banned day, inclusive
  const BanWindow(this.start, this.end);

  bool contains(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }
}

BanWindow banFor(Coast coast, int year) => switch (coast) {
      Coast.east => BanWindow(DateTime(year, 4, 15), DateTime(year, 6, 14)),
      Coast.west => BanWindow(DateTime(year, 6, 1), DateTime(year, 7, 31)),
    };

const banDays = 61;

class BanStatus {
  final bool active;

  /// When active: days left including today. When not: days until it
  /// starts.
  final int days;
  final BanWindow window;
  const BanStatus(this.active, this.days, this.window);
}

BanStatus banStatus(Coast coast, DateTime today) {
  final d = DateTime(today.year, today.month, today.day);
  final thisYear = banFor(coast, d.year);
  if (thisYear.contains(d)) {
    return BanStatus(true, thisYear.end.difference(d).inDays + 1, thisYear);
  }
  final next = d.isAfter(thisYear.end) ? banFor(coast, d.year + 1) : thisYear;
  return BanStatus(false, next.start.difference(d).inDays, next);
}

const mpedaSource = 'https://mpeda.gov.in/?p=589';
