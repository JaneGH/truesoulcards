import 'package:flutter/material.dart';

enum Filter {
  showMySets,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  // final Map<Filter, bool> currentFilters;

  @override
  State<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _showMySets = false;

  @override
  void initState() {
    super.initState();
    // _showMySets = widget.currentFilters[Filter.showMySets]!;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
          if(didPop) return;
          Navigator.of(context).pop({
            Filter.showMySets: _showMySets,
          });
        },
        child: Column(
          children: [
            SwitchListTile(
              value: _showMySets,
              onChanged: (isChecked) {
                setState(() {
                  _showMySets = isChecked;
                });
              },
              title: Text(
                'Show my sets',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              subtitle: Text(
                'Show all cards with created sets.',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              activeColor: Theme.of(context).colorScheme.tertiary,
              contentPadding: const EdgeInsets.only(left: 34, right: 22),
            ),
          ],
        ),
      ),
    );
  }
}