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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Diet Chart'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DateRow(
              label: 'Start Date',
              date: _startDate,
              onPick: (d) => setState(() => _startDate = d),
            ),
            const SizedBox(height: 12),
            _DateRow(
              label: 'End Date',
              date: _endDate,
              onPick: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 20),
            const Text('Meals',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._meals.asMap().entries.map((e) => _MealCard(
                  index: e.key,
                  entry: e.value,
                  onRemove: _meals.length > 1
                      ? () => setState(() => _meals.removeAt(e.key))
                      : null,
                )),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _meals.add(_MealEntry())),
              icon: const Icon(Icons.add),
              label: const Text('Add Meal'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.softCoral, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text('Save Diet Chart',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;
  const _DateRow(
      {required this.label, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            Text('$label: ${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontSize: 13)),
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
  final VoidCallback? onRemove;
  const _MealCard(
      {required this.index, required this.entry, required this.onRemove});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Meal ${widget.index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              if (widget.onRemove != null)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(Icons.remove_circle_outline,
                      color: AppColors.softCoral, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
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
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => widget.entry.mealTime = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
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
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => widget.entry.frequency = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.entry.caloriesCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories (approx)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.entry.ingredientsCtrl,
            decoration: const InputDecoration(
              labelText: 'Ingredients (comma-separated)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
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
