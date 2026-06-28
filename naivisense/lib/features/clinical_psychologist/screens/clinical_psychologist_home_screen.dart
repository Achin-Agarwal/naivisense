import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/clinical_psychologist_provider.dart';

class ClinicalPsychologistHomeScreen extends ConsumerWidget {
  const ClinicalPsychologistHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(cpChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Psychologist'}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(cpChildrenProvider),
        child: children.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
              child: Text('Could not load children',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                  child: Text('No children assigned',
                      style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader(
                    title: 'Assigned Children',
                    icon: Icons.people_outline),
                const SizedBox(height: 12),
                ...list.map((c) => _ChildCard(child: c)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _CpChildObservationScreen(child: child),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              child: Text(child.name[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('${child.ageYears} years  •  ${child.severity}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── CP Child Observation Screen ───────────────────────────────────────────

class _CpChildObservationScreen extends ConsumerStatefulWidget {
  final ChildModel child;
  const _CpChildObservationScreen({required this.child});

  @override
  ConsumerState<_CpChildObservationScreen> createState() =>
      _CpChildObservationScreenState();
}

class _CpChildObservationScreenState
    extends ConsumerState<_CpChildObservationScreen> {
  final _categoryCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _picker          = ImagePicker();
  String  _selectedCategory = 'behavior';
  XFile?  _pickedVideo;

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final v = await _picker.pickVideo(source: ImageSource.gallery);
    if (v != null) setState(() => _pickedVideo = v);
  }

  Future<void> _raiseConcern() async {
    if (_descriptionCtrl.text.trim().isEmpty) return;
    final payload = {
      'child_id':    widget.child.id,
      'category':    _selectedCategory,
      'description': _descriptionCtrl.text.trim(),
    };
    bool ok;
    if (_pickedVideo != null) {
      ok = await ref.read(raiseConcernProvider.notifier).submitWithVideo(
        payload:    payload,
        childId:    widget.child.id,
        videoTitle: '$_selectedCategory observation',
        videoPath:  _pickedVideo!.path,
        mimeType:   'video/mp4',
      );
    } else {
      ok = (await ref.read(raiseConcernProvider.notifier).submit(payload)) != null;
    }
    if (ok && mounted) {
      _descriptionCtrl.clear();
      setState(() => _pickedVideo = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern raised successfully')),
      );
      ref.invalidate(cpChildConcernsProvider(widget.child.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final concerns = ref.watch(cpChildConcernsProvider(widget.child.id));
    final state    = ref.watch(raiseConcernProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.child.name),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Raise Concern form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Raise Concern',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['behavior', 'tantrum', 'health', 'regression',
                          'activity', 'other']
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c[0].toUpperCase() + c.substring(1)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: state.loading ? null : _pickVideo,
                  icon: Icon(
                    _pickedVideo != null
                        ? Icons.videocam
                        : Icons.videocam_outlined,
                    size: 16,
                  ),
                  label: Text(_pickedVideo != null
                      ? 'Video selected'
                      : 'Attach observation video (optional)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 8),
                  Text(state.error!,
                      style: const TextStyle(
                          color: AppColors.softCoral, fontSize: 12)),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: state.loading ? null : _raiseConcern,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softCoral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: state.loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text('Raise Concern',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Existing concerns
          const Text('Open Concerns',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          concerns.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Could not load concerns',
                style: TextStyle(color: AppColors.textSecondary)),
            data: (list) {
              final open = list.where((c) => c.status == 'open').toList();
              if (open.isEmpty) {
                return const Text('No open concerns',
                    style: TextStyle(color: AppColors.textSecondary));
              }
              return Column(
                children: open
                    .map((c) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.softCoral.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.softCoral.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.category,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppColors.softCoral)),
                              const SizedBox(height: 4),
                              Text(c.description,
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
