import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Supported languages
enum AppLanguage {
  english('en', 'English'),
  afrikaans('af', 'Afrikaans'),
  zulu('zu', 'isiZulu'),
  xhosa('xh', 'isiXhosa'),
  sotho('st', 'Sesotho');

  final String code;
  final String name;

  const AppLanguage(this.code, this.name);

  static AppLanguage fromCode(String code) {
    return values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

// Provider for current language
final currentLanguageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english);

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('preferred_language') ?? 'en';
    state = AppLanguage.fromCode(savedCode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', language.code);
    state = language;
  }
}

// Localization service
class LocalizationService {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'K53 Learner\'s License App',
      'welcome': 'Welcome',
      'study_mode': 'Study Mode',
      'mock_exam': 'Mock Exam',
      'progress': 'Progress',
      'settings': 'Settings',
      'logout': 'Logout',
      'correct': 'Correct!',
      'incorrect': 'Incorrect',
      'explanation': 'Explanation',
      'submit': 'Submit',
      'next_question': 'Next Question',
      'previous_question': 'Previous Question',
      'score': 'Score',
      'time': 'Time',
      'category': 'Category',
      'difficulty': 'Difficulty',
      'rules_of_road': 'Rules of the Road',
      'road_signs': 'Road Signs',
      'vehicle_controls': 'Vehicle Controls',
      'general_knowledge': 'General Knowledge',
    },
    'af': {
      'app_title': 'K53 Leerlinglisensie App',
      'welcome': 'Welkom',
      'study_mode': 'Studiemodus',
      'mock_exam': 'Mokeksamen',
      'progress': 'Vordering',
      'settings': 'Instellings',
      'logout': 'Teken uit',
      'correct': 'Korrek!',
      'incorrect': 'Verkeerd',
      'explanation': 'Verduideliking',
      'submit': 'Dien in',
      'next_question': 'Volgende Vraag',
      'previous_question': 'Vorige Vraag',
      'score': 'Telling',
      'time': 'Tyd',
      'category': 'Kategorie',
      'difficulty': 'Moeilikheidsgraad',
      'rules_of_road': 'Reëls van die Pad',
      'road_signs': 'Padtekens',
      'vehicle_controls': 'Voertuigbeheer',
      'general_knowledge': 'Algemene Kennis',
    },
    'zu': {
      'app_title': 'I-App ye-Layisense ye-K53',
      'welcome': 'Siyakwamukela',
      'study_mode': 'Indlela Yokufunda',
      'mock_exam': 'Ukuhlolwa',
      'progress': 'Intuthuko',
      'settings': 'Izilungiselelo',
      'logout': 'Phuma',
      'correct': 'Kulungile!',
      'incorrect': 'Akulungile',
      'explanation': 'Incazelo',
      'submit': 'Thumela',
      'next_question': 'Umbuzo Olandelayo',
      'previous_question': 'Umbuzo Wangaphambili',
      'score': 'Amaphuzu',
      'time': 'Isikhathi',
      'category': 'Isigaba',
      'difficulty': 'Ubunzima',
      'rules_of_road': 'Imithetho Yomgwaqo',
      'road_signs': 'Izimpawu Zomgwaqo',
      'vehicle_controls': 'Ukulawula Imoto',
      'general_knowledge': 'Ulwazi Olujwayelekile',
    },
    'xh': {
      'app_title': 'I-App ye-Layisense ye-K53',
      'welcome': 'Wamkelekile',
      'study_mode': 'Indlela Yokufunda',
      'mock_exam': 'Uvavanyo',
      'progress': 'Intsebenziswano',
      'settings': 'Iisetingi',
      'logout': 'Phuma',
      'correct': 'Ichanekile!',
      'incorrect': 'Ayichanekanga',
      'explanation': 'Ingcaciso',
      'submit': 'Thumela',
      'next_question': 'Umbuzo Olandelayo',
      'previous_question': 'Umbuzo Wangaphambili',
      'score': 'Amanqaku',
      'time': 'Ixesha',
      'category': 'Udidi',
      'difficulty': 'Ubunzima',
      'rules_of_road': 'Imigaqo Yendlela',
      'road_signs': 'Iimpawu Zendlela',
      'vehicle_controls': 'Ulawulo Lwemoto',
      'general_knowledge': 'Ulwazi Oluqukiweleyo',
    },
    'st': {
      'app_title': 'App ya Layisense ya K53',
      'welcome': 'Rea u amohela',
      'study_mode': 'Mokhoa oa ho ithuta',
      'mock_exam': 'Tekanyetso',
      'progress': 'Tsoelopele',
      'settings': 'Litlhophiso',
      'logout': 'Tsoa',
      'correct': 'E nepahetseng!',
      'incorrect': 'Ha e nepe',
      'explanation': 'Tlhaloso',
      'submit': 'Romella',
      'next_question': 'Potso e Latelang',
      'previous_question': 'Potso e Fetileng',
      'score': 'Lintlha',
      'time': 'Nako',
      'category': 'Sehlopha',
      'difficulty': 'Bokhoni',
      'rules_of_road': 'Melao ea Tsela',
      'road_signs': 'Matšoao a Tsela',
      'vehicle_controls': 'Taolo ea Koloi',
      'general_knowledge': 'Tsebo e Akaretsang',
    },
  };

  static String translate(String key, WidgetRef ref) {
    final language = ref.read(currentLanguageProvider);
    return _translations[language.code]?[key] ?? key;
  }

  static String translateWithLanguage(String key, AppLanguage language) {
    return _translations[language.code]?[key] ?? key;
  }

  static List<AppLanguage> get supportedLanguages => AppLanguage.values;

  static Future<void> initialize() async {
    // Load any additional translations or perform setup
  }
}

// Extension for easy translation
extension LocalizationExtension on String {
  String tr(WidgetRef ref) {
    return LocalizationService.translate(this, ref);
  }
}

// Widget for language selection
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(currentLanguageProvider);

    return DropdownButton<AppLanguage>(
      value: currentLanguage,
      onChanged: (language) {
        if (language != null) {
          ref.read(currentLanguageProvider.notifier).setLanguage(language);
        }
      },
      items: LocalizationService.supportedLanguages.map((language) {
        return DropdownMenuItem<AppLanguage>(
          value: language,
          child: Text(language.name),
        );
      }).toList(),
    );
  }
}