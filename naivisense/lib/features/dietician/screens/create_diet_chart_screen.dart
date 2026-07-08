import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/diet_plans_repository.dart';
import '../../../data/repositories/diet_requests_repository.dart';
import '../providers/dietician_provider.dart';

class CreateDietChartScreen extends ConsumerStatefulWidget {
  final String childId;
  final String? requestId;
  const CreateDietChartScreen({
    super.key,
    required this.childId,
    this.requestId,
  });

  @override
  ConsumerState<CreateDietChartScreen> createState() =>
      _CreateDietChartScreenState();
}

class _CreateDietChartScreenState
    extends ConsumerState<CreateDietChartScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate   = DateTime.now().add(const Duration(days: 30));
  bool _loading = false;
  String? _error;

  final List<_MealEntry> _meals = [
    _MealEntry(),
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final m in _meals) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_meals.isEmpty) {
      setState(() => _error = 'Add at least one meal');
      return;
    }

    setState(() {
      _loading = true;
      _error   = null;
    });

    final mealsData = _meals.asMap().entries.map((e) {
      final m = e.value;
      return {
        'meal_id':         'meal_${DateTime.now().millisecondsSinceEpoch}_${e.key}',
        'name':            m.nameCtrl.text.trim(),
        'description':     m.descCtrl.text.trim().isEmpty ? null : m.descCtrl.text.trim(),
        'meal_time':       m.mealTime,
        'calories_approx': int.tryParse(m.caloriesCtrl.text.trim()) ?? 0,
        'ingredients':     m.ingredientsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'frequency':       m.frequency,
      };
    }).toList();

    try {
      await ref.read(dietPlansRepositoryProvider).createPlan({
        'child_id':   widget.childId,
        'start_date': _startDate.toIso8601String(),
        'end_date':   _endDate.toIso8601String(),
        'meals':      mealsData,
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });

      // Mark the diet request as completed if applicable
      if (widget.requestId != null) {
        await ref
            .read(dietRequestsRepositoryProvider)
            .updateDietRequest(widget.requestId!, {'status': 'completed'});
        ref.invalidate(dieticianRequestsProvider);
      }

      ref.invalidate(dieticianChildDietPlanProvider(widget.childId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diet chart created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error   = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final horizontalPadding = isMobile ? 16.0 : 24.0;
        final verticalPadding = isMobile ? 16.0 : 24.0;
        final spacingSmall = isMobile ? 8.0 : 10.0;
        final spacingMedium = isMobile ? 12.0 : 16.0;
        final spacingLarge = isMobile ? 20.0 : 24.0;
        final buttonHeight = isMobile ? 50.0 : 54.0;
        final buttonRadius = isMobile ? 12.0 : 14.0;
        final titleFontSize = isMobile ? 15.0 : isTablet ? 16.0 : 17.0;
        final errorFontSize = isMobile ? 13.0 : 14.0;
        final buttonFontSize = isMobile ? 15.0 : 16.0;

        final content = Form(
          key: _formKey,
          child: ListView(
            // Responsive padding keeps the form clear of system UI and keyboard.
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding + mediaQuery.viewInsets.bottom + 16,
            ),
            children: [
              _DateRow(
                label: 'Start Date',
                date: _startDate,
                isMobile: isMobile,
                onPick: (d) => setState(() => _startDate = d),
              ),
              SizedBox(height: spacingMedium),
              _DateRow(
                label: 'End Date',
                date: _endDate,
                isMobile: isMobile,
                onPick: (d) => setState(() => _endDate = d),
              ),
              SizedBox(height: spacingLarge),
              Text('Meals',
                  style: TextStyle(
                      fontSize: titleFontSize, fontWeight: FontWeight.w600)),
              SizedBox(height: spacingMedium),
              ..._meals.asMap().entries.map((e) => _MealCard(
                    index: e.key,
                    entry: e.value,
                    isMobile: isMobile,
                    onRemove: _meals.length > 1
                        ? () => setState(() => _meals.removeAt(e.key))
                        : null,
                  )),
              SizedBox(height: spacingSmall),
              TextButton.icon(
                onPressed: () => setState(() => _meals.add(_MealEntry())),
                icon: Icon(Icons.add, size: isMobile ? 20 : 22),
                label: Text('Add Meal',
                    style: TextStyle(fontSize: isMobile ? 14 : 15)),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
              ),
              SizedBox(height: spacingMedium),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: spacingMedium),
                Text(_error!,
                    style: TextStyle(
                        color: AppColors.softCoral, fontSize: errorFontSize)),
              ],
              SizedBox(height: spacingLarge),
              SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text('Save Diet Chart',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: buttonFontSize)),
                ),
              ),
              SizedBox(height: isMobile ? 32 : 40),
            ],
          ),
        );

        final responsiveBody = isMobile
            ? content
            // Center and constrain wider layouts so the form stays readable.
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Align(
                    alignment: Alignment.topCenter,
                    // Forms stay comfortably readable on tablet and desktop widths.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: content,
                    ),
                  ),
                ),
              );

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text('Create Diet Chart'),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: BackButton(onPressed: () => Navigator.pop(context)),
          ),
          body: responsiveBody,
        );
      },
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isMobile;
  final ValueChanged<DateTime> onPick;
  const _DateRow(
      {required this.label,
      required this.date,
      required this.isMobile,
      required this.onPick});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = isMobile ? 14.0 : 16.0;
    final radius = isMobile ? 10.0 : 12.0;
    final iconSize = isMobile ? 16.0 : 18.0;
    final fontSize = isMobile ? 13.0 : 14.0;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        // Responsive sizing preserves tap targets without crowding small screens.
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: iconSize, color: AppColors.primaryBlue),
            SizedBox(width: isMobile ? 10 : 12),
            Expanded(
              child: Text('$label: ${date.day}/${date.month}/${date.year}',
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor:
                      mediaQuery.textScaleFactor.clamp(1.0, 1.2).toDouble(),
                  style: TextStyle(fontSize: fontSize)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealEntry {
  final nameCtrl        = TextEditingController();
  final descCtrl        = TextEditingController();
  final caloriesCtrl    = TextEditingController();
  final ingredientsCtrl = TextEditingController();
  String mealTime  = 'breakfast';
  String frequency = 'daily';

  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    caloriesCtrl.dispose();
    ingredientsCtrl.dispose();
  }
}

class _MealCard extends StatefulWidget {
  final int index;
  final _MealEntry entry;
  final bool isMobile;
  final VoidCallback? onRemove;
  const _MealCard(
      {required this.index,
      required this.entry,
      required this.isMobile,
      required this.onRemove});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  @override
  Widget build(BuildContext context) {
    final marginBottom = widget.isMobile ? 12.0 : 16.0;
    final padding = widget.isMobile ? 14.0 : 16.0;
    final radius = widget.isMobile ? 12.0 : 14.0;
    final titleFontSize = widget.isMobile ? 13.0 : 14.0;
    final fieldSpacing = widget.isMobile ? 8.0 : 10.0;
    final iconSize = widget.isMobile ? 18.0 : 20.0;
    final optionFontSize = widget.isMobile ? 13.0 : 14.0;

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Meal ${widget.index + 1}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: titleFontSize)),
              ),
              const Spacer(),
              if (widget.onRemove != null)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(Icons.remove_circle_outline,
                      color: AppColors.softCoral, size: iconSize),
                ),
            ],
          ),
          SizedBox(height: fieldSpacing + 2),
          TextFormField(
            controller: widget.entry.nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Meal Name *',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: fieldSpacing),
          LayoutBuilder(
            builder: (context, constraints) {
              final dropdownWidth = constraints.maxWidth < 340
                  ? constraints.maxWidth
                  : (constraints.maxWidth - fieldSpacing) / 2;

              return Wrap(
                // Wrap prevents the paired dropdowns from overflowing on narrow screens.
                spacing: fieldSpacing,
                runSpacing: fieldSpacing,
                children: [
                  SizedBox(
                    width: dropdownWidth,
                    child: DropdownButtonFormField<String>(
                      initialValue: widget.entry.mealTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: ['breakfast', 'lunch', 'dinner', 'snack']
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                    t[0].toUpperCase() + t.substring(1),
                                    style:
                                        TextStyle(fontSize: optionFontSize)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => widget.entry.mealTime = v!),
                    ),
                  ),
                  SizedBox(
                    width: dropdownWidth,
                    child: DropdownButtonFormField<String>(
                      initialValue: widget.entry.frequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: ['daily', 'weekly']
                          .map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(
                                    f[0].toUpperCase() + f.substring(1),
                                    style:
                                        TextStyle(fontSize: optionFontSize)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => widget.entry.frequency = v!),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: fieldSpacing),
          TextFormField(
            controller: widget.entry.caloriesCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories (approx)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          SizedBox(height: fieldSpacing),
          TextFormField(
            controller: widget.entry.ingredientsCtrl,
            decoration: const InputDecoration(
              labelText: 'Ingredients (comma-separated)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          SizedBox(height: fieldSpacing),
          TextFormField(
            controller: widget.entry.descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
