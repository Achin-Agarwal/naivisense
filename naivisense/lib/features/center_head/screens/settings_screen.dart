import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/api_service.dart';

class _SettingsEntry {
  final String key;
  final dynamic value;
  const _SettingsEntry(this.key, this.value);
}

final _settingsProvider = FutureProvider<List<_SettingsEntry>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/settings');
  final list = res.data as List<dynamic>;
  return list.map((e) {
    final m = e as Map<String, dynamic>;
    return _SettingsEntry(m['key'] as String, m['value']);
  }).toList();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyCtrl   = TextEditingController();
  final _valueCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _upsert() async {
    final key   = _keyCtrl.text.trim();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setting saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.softCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String key) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.delete('/settings/$key');
      ref.invalidate(_settingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
    final settings = ref.watch(_settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_settingsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildAddForm()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: settings.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e'))),
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No settings configured',
                            style: TextStyle(color: AppColors.textSecondary)),
                      )),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _SettingRow(
                        entry:    list[i],
                        onDelete: () => _delete(list[i].key),
                      ),
                      childCount: list.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add / Update Setting',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            decoration: const InputDecoration(
              labelText: 'Key (e.g. session_fee_default)',
              border:    OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller:  _valueCtrl,
            decoration:  const InputDecoration(
              labelText: 'Value',
              border:    OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _upsert,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Setting'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final _SettingsEntry entry;
  final VoidCallback onDelete;
  const _SettingRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text('${entry.value}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.softCoral),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
