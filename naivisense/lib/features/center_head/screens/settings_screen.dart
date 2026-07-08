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
    final settings = ref.watch(_settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // ==========================================
        // Responsive Breakpoints
        // ==========================================

        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final horizontalPadding = isMobile ? 16.0 : 24.0;

        final titleSize = isMobile ? 20.0 : 24.0;

        return Scaffold(
          backgroundColor: AppColors.background,

          resizeToAvoidBottomInset: true,

          appBar: AppBar(
            title: Text(
              "System Settings",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
              ),
            ),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_settingsProvider);
            },

            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              slivers: [
                /// Center content on Tablet/Desktop
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 600,
                      ),

                      child: _buildAddForm(isMobile),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),

                  sliver: settings.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                    error: (e, _) => SliverToBoxAdapter(
                      child: Center(child: Text("Error: $e")),
                    ),

                    data: (list) {
                      if (list.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                "No settings configured",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((_, index) {
                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? double.infinity : 700,
                              ),

                              child: _SettingRow(
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

  // ===================================================
  // Responsive Add Form
  // ===================================================

  Widget _buildAddForm(bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 24),

      padding: EdgeInsets.all(isMobile ? 16 : 24),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: AppColors.divider),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            "Add / Update Setting",

            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 15 : 18,
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          TextField(
            controller: _keyCtrl,

            decoration: const InputDecoration(
              labelText: "Key (e.g. session_fee_default)",
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: isMobile ? 12 : 16),

          TextField(
            controller: _valueCtrl,

            decoration: const InputDecoration(
              labelText: "Value",
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          SizedBox(
            width: double.infinity,
            height: isMobile ? 48 : 54,

            child: ElevatedButton(
              onPressed: _saving ? null : _upsert,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,

                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "Save Setting",
                      style: TextStyle(fontSize: isMobile ? 14 : 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
// =======================================================
// Responsive Setting Row
// =======================================================

class _SettingRow extends StatelessWidget {
  final _SettingsEntry entry;
  final VoidCallback onDelete;

  const _SettingRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ==========================================
    // Responsive Breakpoints
    // ==========================================

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile ? 14.0 : 18.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    final keyFont = isMobile ? 13.0 : 15.0;
    final valueFont = isMobile ? 12.0 : 14.0;
    final iconSize = isMobile ? 20.0 : 24.0;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 14),

      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: AppColors.divider),
      ),

      // ==========================================
      // Wrap prevents overflow on small devices
      // ==========================================
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 12,

        children: [
          SizedBox(
            width: isMobile
                ? width * 0.60
                : isTablet
                ? 420
                : 520,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  entry.key,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: keyFont,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${entry.value}',

                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: valueFont,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onDelete,
            splashRadius: 24,
            icon: Icon(
              Icons.delete_outline,
              size: iconSize,
              color: AppColors.softCoral,
            ),
          ),
        ],
      ),
    );
  }
}
