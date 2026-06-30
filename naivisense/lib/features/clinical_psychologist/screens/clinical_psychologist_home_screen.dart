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
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(cpChildrenProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        // Responsive spacing
        final horizontalPadding = isMobile ? 16.0 : 24.0;

        Widget body = RefreshIndicator(
          onRefresh: () async => ref.invalidate(cpChildrenProvider),
          child: children.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(
              child: Text(
                'Could not load children',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No children assigned',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView(
                padding: EdgeInsets.all(horizontalPadding),
                children: [
                  _SectionHeader(
                    title: 'Assigned Children',
                    icon: Icons.people_outline,
                    isMobile: isMobile,
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  ...list.map((c) => _ChildCard(child: c, isMobile: isMobile)),
                ],
              );
            },
          ),
        );

        // Center content on tablet/desktop
        if (!isMobile) {
          body = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: body,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Hi, ${user?.name.split(' ').first ?? 'Psychologist'}',
              style: TextStyle(fontSize: isMobile ? 18 : 20),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, size: isMobile ? 24 : 26),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
          body: SafeArea(child: body),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isMobile;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: isMobile ? 20 : 24),

        SizedBox(width: isMobile ? 8 : 10),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final bool isMobile;

  const _ChildCard({required this.child, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final avatarRadius = isMobile ? 22.0 : 26.0;
    final nameFontSize = isMobile ? 14.0 : 16.0;
    final subtitleFontSize = isMobile ? 12.0 : 13.0;
    final cardPadding = isMobile ? 14.0 : 18.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _CpChildObservationScreen(child: child),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 10 : 14),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              child: Text(
                child.name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ),

            SizedBox(width: isMobile ? 14 : 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: nameFontSize,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${child.ageYears} years • ${child.severity}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: isMobile ? 18 : 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _CpChildObservationScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const _CpChildObservationScreen({required this.child});

  @override
  ConsumerState<_CpChildObservationScreen> createState() =>
      _CpChildObservationScreenState();
}

class _CpChildObservationScreenState
    extends ConsumerState<_CpChildObservationScreen> {
  final _categoryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _selectedCategory = 'behavior';
  XFile? _pickedVideo;

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final v = await _picker.pickVideo(source: ImageSource.gallery);

    if (v != null) {
      setState(() => _pickedVideo = v);
    }
  }

  Future<void> _raiseConcern() async {
    if (_descriptionCtrl.text.trim().isEmpty) return;

    final payload = {
      'child_id': widget.child.id,
      'category': _selectedCategory,
      'description': _descriptionCtrl.text.trim(),
    };

    bool ok;

    if (_pickedVideo != null) {
      ok = await ref
          .read(raiseConcernProvider.notifier)
          .submitWithVideo(
            payload: payload,
            childId: widget.child.id,
            videoTitle: '$_selectedCategory observation',
            videoPath: _pickedVideo!.path,
            mimeType: 'video/mp4',
          );
    } else {
      ok =
          (await ref.read(raiseConcernProvider.notifier).submit(payload)) !=
          null;
    }

    if (ok && mounted) {
      _descriptionCtrl.clear();

      setState(() {
        _pickedVideo = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern raised successfully')),
      );

      ref.invalidate(cpChildConcernsProvider(widget.child.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final concerns = ref.watch(cpChildConcernsProvider(widget.child.id));

    final state = ref.watch(raiseConcernProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;

        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        final isDesktop = constraints.maxWidth >= 1024;

        // Responsive values
        final horizontalPadding = isMobile ? 16.0 : 24.0;

        final formMaxWidth = isDesktop ? 600.0 : 700.0;

        final buttonHeight = isMobile ? 44.0 : 50.0;

        Widget body = SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: formMaxWidth),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Raise Concern Form
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Raise Concern',
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items:
                                [
                                      'behavior',
                                      'tantrum',
                                      'health',
                                      'regression',
                                      'activity',
                                      'other',
                                    ]
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c[0].toUpperCase() + c.substring(1),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedCategory = v!;
                              });
                            },
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

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: state.loading ? null : _pickVideo,
                              icon: Icon(
                                _pickedVideo != null
                                    ? Icons.videocam
                                    : Icons.videocam_outlined,
                                size: isMobile ? 16 : 18,
                              ),
                              label: Text(
                                _pickedVideo != null
                                    ? 'Video selected'
                                    : 'Attach observation video (optional)',
                                textAlign: TextAlign.center,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                minimumSize: Size.fromHeight(
                                  isMobile ? 40 : 46,
                                ),
                              ),
                            ),
                          ),

                          if (state.error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              state.error!,
                              style: const TextStyle(
                                color: AppColors.softCoral,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: state.loading ? null : _raiseConcern,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.softCoral,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: state.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      'Raise Concern',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 14 : 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Open Concerns',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Part 3 will replace this section
                    concerns.when(
                      loading: () => const LinearProgressIndicator(),

                      error: (_, _) => const Text(
                        'Could not load concerns',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),

                      data: (list) {
                        final open = list
                            .where((c) => c.status == 'open')
                            .toList();

                        if (open.isEmpty) {
                          return const Text(
                            'No open concerns',
                            style: TextStyle(color: AppColors.textSecondary),
                          );
                        }

                        return Column(
                          children: open
                              .map(
                                (c) => Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                    bottom: isMobile ? 8 : 12,
                                  ),
                                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.softCoral.withValues(
                                      alpha: 0.06,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.softCoral.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.category,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile ? 12 : 13,
                                          color: AppColors.softCoral,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        c.description,
                                        style: TextStyle(
                                          fontSize: isMobile ? 13 : 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Center content on tablet and desktop
        if (!isMobile) {
          body = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: body,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          resizeToAvoidBottomInset: true,

          appBar: AppBar(
            title: Text(widget.child.name, overflow: TextOverflow.ellipsis),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: BackButton(onPressed: () => Navigator.pop(context)),
          ),

          body: SafeArea(child: body),
        );
      },
    );
  }
}
