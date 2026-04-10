// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get sureToDeleteAllQuestions => 'Are you sure you want to delete all questions?';

  @override
  String get welcome => 'Welcome to the app';

  @override
  String get edit_sets => 'Edit my sets';

  @override
  String get settings => 'Settings';

  @override
  String get refresh_questions => 'Refresh Questions';

  @override
  String get upload_questions => 'Upload Questions';

  @override
  String get adults => 'Adults';

  @override
  String get kids => 'Kids';

  @override
  String get languages => 'Languages';

  @override
  String get primary_language => 'Primary Language';

  @override
  String get secondary_language => 'Secondary Language';

  @override
  String get pick_category => 'Pick a category';

  @override
  String get set_up_categories => 'Set up categories';

  @override
  String get remove_ad => 'Remove Ads Forever';

  @override
  String get restore_purchase => 'Restore purchase';

  @override
  String get pick_to_edit => 'Pick to edit';

  @override
  String get preferences => 'Preferences';

  @override
  String get show_animation => 'Show animation';

  @override
  String get font_size => 'Font size';

  @override
  String get show_animation_when_swiping_cards => 'Show animation when swiping cards';

  @override
  String get explore => 'Explore';

  @override
  String get start_game => 'Start game';

  @override
  String get category => 'Category';

  @override
  String get info => 'Info';

  @override
  String get share => 'Share';

  @override
  String get set_up_the_category_list => 'Set up the category';

  @override
  String get conversations => 'Conversations';

  @override
  String get questions => 'Questions';

  @override
  String get that_matter => 'that matter';

  @override
  String get nothing_here_yet => 'Nothing here yet.';

  @override
  String get try_to_choose_different_category => 'Try to choose different category';

  @override
  String get time_to_choose_the_categories_for_the_game => 'Time to choose the categories.';

  @override
  String get failed_to_load_questions => 'Failed to load questions. Please try again later.';

  @override
  String get please_fill_in_question_text => 'Please fill in the question text.';

  @override
  String get question_added => 'Question added!';

  @override
  String get failed_to_add_question => 'Failed to add question:';

  @override
  String get new_question => 'New Question';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get create_question => 'Create question';

  @override
  String get something_went_wrong => 'Something went wrong';

  @override
  String get delete_question => 'Delete question';

  @override
  String get are_you_sure_you_want_to_delete_question => 'Are you sure you want to delete this question?';

  @override
  String get discover_meaningful_questions => 'Discover deep questions that inspire meaningful and honest conversations with TrueSoul Cards.';

  @override
  String get about => 'About';

  @override
  String get about_game => 'About the Game';

  @override
  String get info_title => 'Discover, Connect, Reflect';

  @override
  String get info_description_part1 => 'This card game is designed to create memorable evenings and meaningful conversations with friends, family or new acquaintances.';

  @override
  String get info_description_part2 => 'These questions help you connect with others — to understand their values, emotions, and experiences. They also invite you to look inward, express yourself, and open up to something new.';

  @override
  String get continuePreviousGame => 'Continue previous game?';

  @override
  String get continuePreviousGameDescription => 'Do you want to continue the previous game or start a new one?';

  @override
  String get newGame => 'New Game';

  @override
  String get continueGame => 'Continue';

  @override
  String get processing_your_request => 'Processing your request...';

  @override
  String get ads_removed_successfully => 'Ads removed successfully!';

  @override
  String get error_removing_ads => 'Error removing ads';

  @override
  String get restoring_your_purchases => 'Restoring your purchases...';

  @override
  String get purchases_restored_successfully => 'Purchases restored successfully!';

  @override
  String get error_restoring_purchases => 'Error restoring purchases';

  @override
  String get play => 'Play';

  @override
  String get upload_select_category_first => 'Please select a category first.';

  @override
  String get upload_failed_read_file => 'Failed to read the selected file.';

  @override
  String get upload_json_error_root_must_be_array => 'Root must be a JSON array.';

  @override
  String get upload_json_error_item_must_be_object => 'Each array item must be a JSON object.';

  @override
  String get upload_json_error_needs_language_key =>
      'Each question must contain at least one language key (non-empty string value).';

  @override
  String get upload_failed_parse_json_file => 'Failed to parse the JSON file.';

  @override
  String get upload_choose_json_first => 'Please choose a JSON file first.';

  @override
  String get default_questions_json_filename => 'questions.json';

  @override
  String get upload_importing => 'Importing...';

  @override
  String get upload_status_failed => 'Upload failed';

  @override
  String get upload_subtitle_secure_import =>
      'Securely import JSON questions into a selected category.';

  @override
  String get upload_only_json_files => 'Only .json files are supported.';

  @override
  String get upload_failed_read_dropped_file => 'Failed to read dropped file.';

  @override
  String get upload_drop_error_unknown => 'unknown';

  @override
  String get upload_tap_or_drop_files => 'Tap to select or drop files';

  @override
  String get upload_json_format_hint =>
      'JSON file (array of objects with language keys)';

  @override
  String get browse_json => 'Browse JSON';

  @override
  String get upload_preview_title => 'Preview';

  @override
  String get upload_section_import_in_progress => 'Import in progress';

  @override
  String get upload_section_recently_uploaded => 'Recently uploaded';

  @override
  String get upload_questions_uploaded_singular => 'Uploaded 1 question';

  @override
  String upload_questions_uploaded_plural(int count) => 'Uploaded $count questions';

  @override
  String category_title_with_subcategory(String title, String subcategory) =>
      '$title ($subcategory)';

  @override
  String questions_detected_count(int count) => 'Questions detected: $count';

  @override
  String detected_languages_label(String languages) => 'Detected languages: $languages';

  @override
  String questions_preview_item(int index, String snippet) => '$index. $snippet';

  @override
  String file_size_mb(String value) => '$value MB';

  @override
  String file_size_kb(String value) => '$value KB';

  @override
  String drop_error_with_detail(String detail) => 'Drop error: $detail';

  @override
  String upload_categories_load_error(String error) => 'Something went wrong: $error';

  @override
  String upload_failed_with_error(String error) => 'Upload failed: $error';

  @override
  String invalid_json_with_message(String message) => 'Invalid JSON: $message';
}
