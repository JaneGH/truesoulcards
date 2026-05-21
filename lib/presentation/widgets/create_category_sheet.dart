import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/core/constants/category_color_palette.dart';
import 'package:truesoulcards/core/constants/category_icon_names.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/custom_categories_provider.dart';
import 'package:truesoulcards/presentation/utils/category_icon_mapper.dart';
import 'package:truesoulcards/presentation/widgets/shared/premium_focus_field.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

Future<bool?> showCreateCategorySheet({
  required BuildContext context,
  required CategoryTabType tabType,
  String? initialTitle,
  int? initialColor,
  String? initialIcon,
  String? categoryId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CreateCategorySheet(
      tabType: tabType,
      initialTitle: initialTitle,
      initialColor: initialColor,
      initialIcon: initialIcon,
      categoryId: categoryId,
    ),
  );
}

class _CreateCategorySheet extends ConsumerStatefulWidget {
  const _CreateCategorySheet({
    required this.tabType,
    this.initialTitle,
    this.initialColor,
    this.initialIcon,
    this.categoryId,
  });

  final CategoryTabType tabType;
  final String? initialTitle;
  final int? initialColor;
  final String? initialIcon;
  final String? categoryId;

  bool get isEdit => categoryId != null;

  @override
  ConsumerState<_CreateCategorySheet> createState() =>
      _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<_CreateCategorySheet> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  late int _selectedColor;
  late String _selectedIcon;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialTitle ?? '');
    _nameFocusNode = FocusNode();
    _selectedColor = widget.initialColor ?? kDefaultCategoryColor;
    _selectedIcon = widget.initialIcon ?? kDefaultCustomCategoryIcon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.create_category_name_required)),
      );
      return;
    }

    setState(() => _saving = true);
    final controller = ref.read(customCategoriesControllerProvider);

    try {
      if (widget.isEdit) {
        await controller.update(
          id: widget.categoryId!,
          title: title,
          color: _selectedColor,
          iconName: _selectedIcon,
        );
      } else {
        await controller.create(
          title: title,
          tabType: widget.tabType,
          color: _selectedColor,
          iconName: _selectedIcon,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.something_went_wrong}: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        decoration: BoxDecoration(
          color: AppDecorations.premiumSurfaceFill(cs, isDark: isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
          ),
          boxShadow: AppDecorations.ambientCardShadow(
            isDark: isDark,
            elevation: 1.1,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEdit ? l10n.rename_category : l10n.create_category,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.create_category_name_label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              PremiumFocusField(
                focusNode: _nameFocusNode,
                backgroundColor: AppDecorations.premiumSurfaceFill(cs, isDark: isDark),
                outlineColor: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
                shadowColor: AppDecorations.premiumSurfaceShadow(isDark: isDark),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: TextField(
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: Color(_selectedColor),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.create_category_color_label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kCategoryColorPalette.map((colorValue) {
                  final selected = _selectedColor == colorValue;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorValue),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? (isDark ? cs.onSurface : AppColors.darkBrown)
                              : Colors.white.withOpacity(0.5),
                          width: selected ? 2.5 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Color(colorValue).withOpacity(0.45),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.create_category_icon_label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: kCustomCategoryIconNames.length,
                  itemBuilder: (context, index) {
                    final name = kCustomCategoryIconNames[index];
                    final selected = _selectedIcon == name;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? Color(_selectedColor).withOpacity(0.25)
                              : AppDecorations.premiumNestedFill(
                                  cs,
                                  isDark: isDark,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Color(_selectedColor)
                                : AppDecorations.premiumSurfaceBorder(
                                    cs,
                                    isDark: isDark,
                                  ),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: categoryIcon(
                            name,
                            size: 26,
                            color: isDark ? cs.onSurface : AppColors.darkBrown,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
