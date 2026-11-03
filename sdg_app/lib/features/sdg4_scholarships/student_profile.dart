import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scholarship_model.dart';

/// The student's own details, stored ONLY on their device.
///
/// Caste, religion, income and disability are sensitive. None of it goes to
/// Firestore, because the matching happens locally against a bundled asset -
/// there is no reason for a server to ever see it.
class StudentProfile {
  final String level; // pre_matric | post_matric | ug | pg | phd
  final int studyClass; // 8..12, or 99 for higher education
  final String category; // sc | st | obc | ebc | dnt | minority | general
  final String gender; // male | female | other
  final bool disability;
  final int annualIncome; // rupees, 0 = not given
  final String state;

  const StudentProfile({
    required this.level,
    required this.studyClass,
    required this.category,
    required this.gender,
    required this.disability,
    required this.annualIncome,
    required this.state,
  });

  static const empty = StudentProfile(
    level: '',
    studyClass: 0,
    category: '',
    gender: '',
    disability: false,
    annualIncome: 0,
    state: '',
  );

  bool get isComplete => level.isNotEmpty && category.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'level': level,
        'studyClass': studyClass,
        'category': category,
        'gender': gender,
        'disability': disability,
        'annualIncome': annualIncome,
        'state': state,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> j) => StudentProfile(
        level: (j['level'] ?? '').toString(),
        studyClass: j['studyClass'] is int ? j['studyClass'] as int : 0,
        category: (j['category'] ?? '').toString(),
        gender: (j['gender'] ?? '').toString(),
        disability: j['disability'] == true,
        annualIncome:
            j['annualIncome'] is int ? j['annualIncome'] as int : 0,
        state: (j['state'] ?? '').toString(),
      );

  /// Decides how a scholarship fits this student.
  ///
  /// Hard criteria (level, class, category, gender, disability, state) can
  /// push a result to `unlikely`. Income can only ever soften it to `check` -
  /// never to `unlikely` - because our recorded cap may be out of date and a
  /// student just over the line may still qualify through an exception.
  MatchLevel matchFor(Scholarship s) {
    var soft = false;

    // Level / class
    if (!s.levels.contains(level)) return MatchLevel.unlikely;
    if (studyClass > 0 && studyClass != 99) {
      if (studyClass < s.minClass || studyClass > s.maxClass) {
        return MatchLevel.unlikely;
      }
    }

    // Category
    if (!s.categories.contains('any') &&
        !s.categories.contains(category)) {
      return MatchLevel.unlikely;
    }

    // Gender-specific schemes
    if (s.gender == 'female' && gender != 'female') {
      return MatchLevel.unlikely;
    }

    // Disability-specific schemes
    if (s.disability && !disability) return MatchLevel.unlikely;

    // State-restricted schemes
    if (!s.states.contains('any') &&
        state.isNotEmpty &&
        !s.states.contains(state)) {
      return MatchLevel.unlikely;
    }

    // Income - soft only, by design.
    if (s.incomeMax > 0 && annualIncome > 0 && annualIncome > s.incomeMax) {
      soft = true;
    }

    return soft ? MatchLevel.check : MatchLevel.strong;
  }
}

class StudentProfileStore extends ChangeNotifier {
  static const _key = 'sdg4_student_profile';

  StudentProfile _profile = StudentProfile.empty;
  StudentProfile get profile => _profile;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _profile = StudentProfile.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('profile load failed: $e');
    }
    notifyListeners();
  }

  Future<void> save(StudentProfile p) async {
    _profile = p;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(p.toJson()));
  }

  Future<void> clear() async {
    _profile = StudentProfile.empty;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ---- option lists used by the setup form ----

const kLevelOptions = <String, String>{
  'pre_matric': 'Class 8 to 10',
  'post_matric': 'Class 11 to 12',
  'ug': 'Graduation (UG)',
  'pg': 'Post graduation (PG)',
  'phd': 'MPhil / PhD',
};

const kCategoryOptions = <String, String>{
  'general': 'General',
  'obc': 'OBC',
  'sc': 'SC',
  'st': 'ST',
  'ebc': 'EBC',
  'dnt': 'DNT',
  'minority': 'Minority',
};

const kIncomeBands = <String, int>{
  'Below ₹1 lakh': 100000,
  '₹1 - 2.5 lakh': 250000,
  '₹2.5 - 4.5 lakh': 450000,
  '₹4.5 - 8 lakh': 800000,
  'Above ₹8 lakh': 1000000,
  'Prefer not to say': 0,
};

const kStates = <String>[
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
  'Jammu and Kashmir', 'Karnataka', 'Kerala', 'Madhya Pradesh',
  'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha',
  'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
  'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
];
