import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
    Locale('uk')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @sureToDeleteAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all questions?'**
  String get sureToDeleteAllQuestions;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the app'**
  String get welcome;

  /// No description provided for @edit_sets.
  ///
  /// In en, this message translates to:
  /// **'Edit my sets'**
  String get edit_sets;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @refresh_questions.
  ///
  /// In en, this message translates to:
  /// **'Refresh Questions'**
  String get refresh_questions;

  /// No description provided for @upload_questions.
  ///
  /// In en, this message translates to:
  /// **'Upload Questions'**
  String get upload_questions;

  /// No description provided for @adults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @primary_language.
  ///
  /// In en, this message translates to:
  /// **'Primary Language'**
  String get primary_language;

  /// No description provided for @secondary_language.
  ///
  /// In en, this message translates to:
  /// **'Secondary Language'**
  String get secondary_language;

  /// No description provided for @pick_category.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get pick_category;

  /// No description provided for @set_up_categories.
  ///
  /// In en, this message translates to:
  /// **'Set up categories'**
  String get set_up_categories;

  /// No description provided for @categories_settings_info_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories_settings_info_title;

  /// No description provided for @categories_settings_info_description.
  ///
  /// In en, this message translates to:
  /// **'Select the categories you want to see in the game. Use “All” to quickly select or clear everything.'**
  String get categories_settings_info_description;

  /// No description provided for @categories_settings_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categories_settings_all;

  /// No description provided for @remove_ad.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads Forever'**
  String get remove_ad;

  /// No description provided for @restore_purchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restore_purchase;

  /// No description provided for @pick_to_edit.
  ///
  /// In en, this message translates to:
  /// **'Pick to edit'**
  String get pick_to_edit;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @show_animation.
  ///
  /// In en, this message translates to:
  /// **'Show animation'**
  String get show_animation;

  /// No description provided for @font_size.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get font_size;

  /// No description provided for @show_animation_when_swiping_cards.
  ///
  /// In en, this message translates to:
  /// **'Show animation when swiping cards'**
  String get show_animation_when_swiping_cards;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @start_game.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get start_game;

  /// No description provided for @choose_at_least_one_category_to_start_game.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one category to start the game'**
  String get choose_at_least_one_category_to_start_game;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @set_up_the_category_list.
  ///
  /// In en, this message translates to:
  /// **'Set up the category'**
  String get set_up_the_category_list;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @that_matter.
  ///
  /// In en, this message translates to:
  /// **'that matter'**
  String get that_matter;

  /// No description provided for @nothing_here_yet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothing_here_yet;

  /// No description provided for @try_to_choose_different_category.
  ///
  /// In en, this message translates to:
  /// **'Try to choose different category'**
  String get try_to_choose_different_category;

  /// No description provided for @time_to_choose_the_categories_for_the_game.
  ///
  /// In en, this message translates to:
  /// **'Time to choose the categories.'**
  String get time_to_choose_the_categories_for_the_game;

  /// No description provided for @failed_to_load_questions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load questions. Please try again later.'**
  String get failed_to_load_questions;

  /// No description provided for @please_fill_in_question_text.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the question text.'**
  String get please_fill_in_question_text;

  /// No description provided for @question_added.
  ///
  /// In en, this message translates to:
  /// **'Question added!'**
  String get question_added;

  /// No description provided for @failed_to_add_question.
  ///
  /// In en, this message translates to:
  /// **'Failed to add question:'**
  String get failed_to_add_question;

  /// No description provided for @new_question.
  ///
  /// In en, this message translates to:
  /// **'New Question'**
  String get new_question;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @create_question.
  ///
  /// In en, this message translates to:
  /// **'Create question'**
  String get create_question;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @delete_question.
  ///
  /// In en, this message translates to:
  /// **'Delete question'**
  String get delete_question;

  /// No description provided for @are_you_sure_you_want_to_delete_question.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this question?'**
  String get are_you_sure_you_want_to_delete_question;

  /// No description provided for @discover_meaningful_questions.
  ///
  /// In en, this message translates to:
  /// **'Discover deep questions that inspire meaningful and honest conversations with TrueSoul Cards.'**
  String get discover_meaningful_questions;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_game.
  ///
  /// In en, this message translates to:
  /// **'About the Game'**
  String get about_game;

  /// No description provided for @info_title.
  ///
  /// In en, this message translates to:
  /// **'Discover, Connect, Reflect'**
  String get info_title;

  /// No description provided for @info_description_part1.
  ///
  /// In en, this message translates to:
  /// **'This card game is designed to create memorable evenings and meaningful conversations with friends, family or new acquaintances.'**
  String get info_description_part1;

  /// No description provided for @info_description_part2.
  ///
  /// In en, this message translates to:
  /// **'These questions help you connect with others — to understand their values, emotions, and experiences. They also invite you to look inward, express yourself, and open up to something new.'**
  String get info_description_part2;

  /// No description provided for @continuePreviousGame.
  ///
  /// In en, this message translates to:
  /// **'Continue previous game?'**
  String get continuePreviousGame;

  /// No description provided for @continuePreviousGameDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue the previous game or start a new one?'**
  String get continuePreviousGameDescription;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @processing_your_request.
  ///
  /// In en, this message translates to:
  /// **'Processing your request...'**
  String get processing_your_request;

  /// No description provided for @ads_removed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Ads removed successfully!'**
  String get ads_removed_successfully;

  /// No description provided for @error_removing_ads.
  ///
  /// In en, this message translates to:
  /// **'Error removing ads'**
  String get error_removing_ads;

  /// No description provided for @restoring_your_purchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring your purchases...'**
  String get restoring_your_purchases;

  /// No description provided for @purchases_restored_successfully.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get purchases_restored_successfully;

  /// No description provided for @error_restoring_purchases.
  ///
  /// In en, this message translates to:
  /// **'Error restoring purchases'**
  String get error_restoring_purchases;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @upload_select_category_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a category first.'**
  String get upload_select_category_first;

  /// No description provided for @upload_failed_read_file.
  ///
  /// In en, this message translates to:
  /// **'Failed to read the selected file.'**
  String get upload_failed_read_file;

  /// No description provided for @upload_json_error_root_must_be_array.
  ///
  /// In en, this message translates to:
  /// **'Root must be a JSON array.'**
  String get upload_json_error_root_must_be_array;

  /// No description provided for @upload_json_error_item_must_be_object.
  ///
  /// In en, this message translates to:
  /// **'Each array item must be a JSON object.'**
  String get upload_json_error_item_must_be_object;

  /// No description provided for @upload_json_error_needs_language_key.
  ///
  /// In en, this message translates to:
  /// **'Each question must contain at least one language key (non-empty string value).'**
  String get upload_json_error_needs_language_key;

  /// No description provided for @upload_failed_parse_json_file.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse the JSON file.'**
  String get upload_failed_parse_json_file;

  /// No description provided for @upload_choose_json_first.
  ///
  /// In en, this message translates to:
  /// **'Please choose a JSON file first.'**
  String get upload_choose_json_first;

  /// No description provided for @default_questions_json_filename.
  ///
  /// In en, this message translates to:
  /// **'questions.json'**
  String get default_questions_json_filename;

  /// No description provided for @upload_importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get upload_importing;

  /// No description provided for @upload_status_failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get upload_status_failed;

  /// No description provided for @upload_subtitle_secure_import.
  ///
  /// In en, this message translates to:
  /// **'Import JSON questions into a selected category.'**
  String get upload_subtitle_secure_import;

  /// No description provided for @ai_prompt_text.
  ///
  /// In en, this message translates to:
  /// **'Generate 15 deep, emotional questions for self-reflection and meaningful conversation.\n\nReturn ONLY a JSON array.\n\nEach item must have:\n- \"en\" (English)\n- \"uk\" (Ukrainian translation, natural sounding)'**
  String get ai_prompt_text;

  /// No description provided for @upload_only_json_files.
  ///
  /// In en, this message translates to:
  /// **'Only .json files are supported.'**
  String get upload_only_json_files;

  /// No description provided for @upload_failed_read_dropped_file.
  ///
  /// In en, this message translates to:
  /// **'Failed to read dropped file.'**
  String get upload_failed_read_dropped_file;

  /// No description provided for @upload_drop_error_unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get upload_drop_error_unknown;

  /// No description provided for @upload_tap_or_drop_files.
  ///
  /// In en, this message translates to:
  /// **'Tap to select or drop files'**
  String get upload_tap_or_drop_files;

  /// No description provided for @upload_json_format_hint.
  ///
  /// In en, this message translates to:
  /// **'JSON file (array of objects with language keys)'**
  String get upload_json_format_hint;

  /// No description provided for @browse_json.
  ///
  /// In en, this message translates to:
  /// **'Browse JSON'**
  String get browse_json;

  /// No description provided for @upload_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get upload_preview_title;

  /// No description provided for @upload_section_import_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Import in progress'**
  String get upload_section_import_in_progress;

  /// No description provided for @upload_section_recently_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Recently uploaded'**
  String get upload_section_recently_uploaded;

  /// No description provided for @upload_questions_uploaded_singular.
  ///
  /// In en, this message translates to:
  /// **'Uploaded 1 question'**
  String get upload_questions_uploaded_singular;

  /// No description provided for @upload_questions_uploaded_plural.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {count} questions'**
  String upload_questions_uploaded_plural(int count);

  /// No description provided for @category_title_with_subcategory.
  ///
  /// In en, this message translates to:
  /// **'{title} ({subcategory})'**
  String category_title_with_subcategory(String title, String subcategory);

  /// No description provided for @questions_detected_count.
  ///
  /// In en, this message translates to:
  /// **'Questions detected: {count}'**
  String questions_detected_count(int count);

  /// No description provided for @detected_languages_label.
  ///
  /// In en, this message translates to:
  /// **'Detected languages: {languages}'**
  String detected_languages_label(String languages);

  /// No description provided for @questions_preview_item.
  ///
  /// In en, this message translates to:
  /// **'{index}. {snippet}'**
  String questions_preview_item(int index, String snippet);

  /// No description provided for @file_size_mb.
  ///
  /// In en, this message translates to:
  /// **'{value} MB'**
  String file_size_mb(String value);

  /// No description provided for @file_size_kb.
  ///
  /// In en, this message translates to:
  /// **'{value} KB'**
  String file_size_kb(String value);

  /// No description provided for @drop_error_with_detail.
  ///
  /// In en, this message translates to:
  /// **'Drop error: {detail}'**
  String drop_error_with_detail(String detail);

  /// No description provided for @upload_categories_load_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String upload_categories_load_error(String error);

  /// No description provided for @upload_failed_with_error.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String upload_failed_with_error(String error);

  /// No description provided for @invalid_json_with_message.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON: {message}'**
  String invalid_json_with_message(String message);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pl', 'pt', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
