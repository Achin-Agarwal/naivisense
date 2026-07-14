import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/services/api_service.dart';
import '../widgets/setting_form.dart';
import '../widgets/setting_row.dart';

class SettingsEntry {
  final String key;
  final dynamic value;

  const SettingsEntry(this.key, this.value);
}

final _settingsProvider = FutureProvider<List<SettingsEntry>>((ref) async {
  final api = ref.read(apiServiceProvider);

  final res = await api.get('/settings');

  final list = res.data as List<dynamic>;

  return list.map((e) {
    final m = e as Map<String, dynamic>;

    return SettingsEntry(m['key'] as String, m['value']);
  }).toList();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  bool _saving = false;

  Future _upsert() async {
    final key = _keyCtrl.text.trim();
    final value = _valueCtrl.text.trim();

    if (key.isEmpty || value.isEmpty) return;

    setState(() => _saving = true);

    try {
      final api = ref.read(apiServiceProvider);

      await api.put('/settings/$key', data: {'value': value});

      _keyCtrl.clear();
      _valueCtrl.clear();

      ref.invalidate(_settingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Setting saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.softCoral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future _delete(String key) async {
    try {
      final api = ref.read(apiServiceProvider);

      await api.delete('/settings/$key');

      ref.invalidate(_settingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final settings = ref.watch(_settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              'System Settings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: r.sp(20, tablet: 22, desktop: 24),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_settingsProvider);
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: r.isMobile ? double.infinity : 600,
                      ),
                      child: SettingForm(
                        keyController: _keyCtrl,
                        valueController: _valueCtrl,
                        saving: _saving,
                        onSave: _upsert,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    r.horizontalPadding,
                    0,
                    r.horizontalPadding,
                    r.verticalPadding + 8,
                  ),
                  sliver: settings.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                    error: (e, _) => SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Error: $e',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: r.sp(14, tablet: 15, desktop: 16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    data: (list) {
                      if (list.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(
                              r.w(32, tablet: 36, desktop: 40),
                            ),
                            child: Center(
                              child: Text(
                                'No settings configured',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: r.sp(15, tablet: 16, desktop: 17),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: r.isMobile ? double.infinity : 700,
                              ),
                              child: SettingRow(
                                entry: list[index],
                                onDelete: () {
                                  _delete(list[index].key);
                                },
                              ),
                            ),
                          );
                        }, childCount: list.length),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
