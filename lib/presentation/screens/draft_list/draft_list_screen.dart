import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/draft_vendor_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/draft/draft_bloc.dart';
import '../../blocs/draft/draft_event.dart';
import '../../blocs/draft/draft_state.dart';
import '../../blocs/vendor_form/vendor_form_bloc.dart';
import '../../blocs/vendor_stepper/vendor_stepper_bloc.dart';
import '../vendor_profile/vendor_profile_screen.dart';

class DraftListScreen extends StatelessWidget {
  final UserEntity user;

  const DraftListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // The DraftBloc should already be provided by the parent (DashboardScreen)
    final draftBloc = context.read<DraftBloc>();

    // Load drafts on first build if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (draftBloc.state is! DraftListLoaded &&
          draftBloc.state is! DraftLoading) {
        draftBloc.add(DraftLoadAllRequested());
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Draft Vendors'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<DraftBloc, DraftState>(
        listener: (context, state) {
          // Handle deletion - reload list automatically happens in bloc
          if (state is DraftDeleted) {
            // The bloc already dispatches DraftLoadAllRequested, so we just need to listen
            // Optionally show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Draft deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is DraftError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DraftLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DraftError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading drafts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DraftBloc>().add(DraftLoadAllRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DraftListLoaded) {
            final drafts = state.drafts;

            if (drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.drafts_outlined,
                      size: 80,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Drafts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have any saved drafts yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DraftBloc>().add(DraftLoadAllRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: drafts.length,
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  return _DraftCard(
                    draft: draft,
                    onResume: () => _handleResumeDraft(context, draft),
                    onDelete: () => _handleDeleteDraft(context, draft),
                  );
                },
              ),
            );
          }

          // Handle DraftDeleted state - show loading while list reloads
          // Note: DraftDeleted immediately triggers DraftLoadAllRequested,
          // so we'll see DraftLoading next, which is handled above
          if (state is DraftDeleted) {
            return const Center(child: CircularProgressIndicator());
          }

          // Initial state or any other state - load drafts
          // This handles DraftInitial, DraftSaved, etc.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _handleResumeDraft(BuildContext context, DraftVendorEntity draft) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<VendorFormBloc>(create: (_) => sl<VendorFormBloc>()),
            BlocProvider<VendorStepperBloc>(
              create: (_) => sl<VendorStepperBloc>(),
            ),
            BlocProvider<DraftBloc>.value(value: context.read<DraftBloc>()),
          ],
          child: VendorProfileScreen(user: user, draftId: draft.id),
        ),
      ),
    );
  }

  void _handleDeleteDraft(BuildContext context, DraftVendorEntity draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Draft'),
        content: Text(
          'Are you sure you want to delete this draft?\n\n'
          '${draft.previewTitle}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DraftBloc>().add(DraftDeleteRequested(draft.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final DraftVendorEntity draft;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onResume,
    required this.onDelete,
  });

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${monthNames[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastUpdated = _formatDateTime(draft.updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onResume,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.previewTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (draft.previewSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            draft.previewSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated $lastUpdated',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Section ${draft.currentSectionIndex + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Resume'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
