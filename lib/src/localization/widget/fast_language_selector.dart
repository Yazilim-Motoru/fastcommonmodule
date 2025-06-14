import 'package:flutter/material.dart';
import '../fast_localization_controller.dart';
import '../model/fast_language.dart';

/// A widget for language selection with customizable UI.
class FastLanguageSelector extends StatelessWidget {
  final FastLocalizationController controller;
  final Widget Function(FastLanguage language, bool isSelected)? itemBuilder;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool showFlag;
  final bool showNativeName;
  final void Function(FastLanguage language)? onLanguageChanged;

  const FastLanguageSelector({
    Key? key,
    required this.controller,
    this.itemBuilder,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.showFlag = true,
    this.showNativeName = true,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: controller.availableLanguages.map((language) {
          final isSelected = language == controller.currentLanguage;
          
          if (itemBuilder != null) {
            return GestureDetector(
              onTap: () => _selectLanguage(language),
              child: itemBuilder!(language, isSelected),
            );
          }
          
          return _DefaultLanguageItem(
            language: language,
            isSelected: isSelected,
            showFlag: showFlag,
            showNativeName: showNativeName,
            onTap: () => _selectLanguage(language),
          );
        }).toList(),
      ),
    );
  }

  void _selectLanguage(FastLanguage language) async {
    await controller.changeLanguage(language);
    onLanguageChanged?.call(language);
  }
}

/// Default language item widget.
class _DefaultLanguageItem extends StatelessWidget {
  final FastLanguage language;
  final bool isSelected;
  final bool showFlag;
  final bool showNativeName;
  final VoidCallback onTap;

  const _DefaultLanguageItem({
    Key? key,
    required this.language,
    required this.isSelected,
    required this.showFlag,
    required this.showNativeName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor) : null,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag && language.flagIcon != null) ...[
              Image.asset(
                language.flagIcon!,
                width: 24,
                height: 16,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8.0),
            ],
            Text(
              showNativeName ? language.nativeName : language.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8.0),
              Icon(
                Icons.check,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dropdown language selector.
class FastLanguageDropdown extends StatelessWidget {
  final FastLocalizationController controller;
  final String? hint;
  final bool showFlag;
  final bool showNativeName;
  final void Function(FastLanguage language)? onLanguageChanged;
  final InputDecoration? decoration;

  const FastLanguageDropdown({
    Key? key,
    required this.controller,
    this.hint,
    this.showFlag = true,
    this.showNativeName = true,
    this.onLanguageChanged,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FastLanguage>(
      value: controller.currentLanguage,
      decoration: decoration ?? const InputDecoration(),
      hint: hint != null ? Text(hint!) : null,
      items: controller.availableLanguages.map((language) {
        return DropdownMenuItem<FastLanguage>(
          value: language,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFlag && language.flagIcon != null) ...[
                Image.asset(
                  language.flagIcon!,
                  width: 24,
                  height: 16,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8.0),
              ],
              Text(showNativeName ? language.nativeName : language.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (FastLanguage? language) {
        if (language != null) {
          controller.changeLanguage(language);
          onLanguageChanged?.call(language);
        }
      },
    );
  }
}

/// Popup menu language selector.
class FastLanguagePopupMenu extends StatelessWidget {
  final FastLocalizationController controller;
  final Widget child;
  final bool showFlag;
  final bool showNativeName;
  final void Function(FastLanguage language)? onLanguageChanged;

  const FastLanguagePopupMenu({
    Key? key,
    required this.controller,
    required this.child,
    this.showFlag = true,
    this.showNativeName = true,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FastLanguage>(
      child: child,
      itemBuilder: (context) {
        return controller.availableLanguages.map((language) {
          final isSelected = language == controller.currentLanguage;
          
          return PopupMenuItem<FastLanguage>(
            value: language,
            child: Row(
              children: [
                if (showFlag && language.flagIcon != null) ...[
                  Image.asset(
                    language.flagIcon!,
                    width: 24,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8.0),
                ],
                Expanded(
                  child: Text(
                    showNativeName ? language.nativeName : language.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (FastLanguage language) {
        controller.changeLanguage(language);
        onLanguageChanged?.call(language);
      },
    );
  }
}
