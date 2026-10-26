import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_statemanagement/core/exception/exception.dart';
import 'package:riverpod_statemanagement/core/service/http_service.dart';
import 'package:riverpod_statemanagement/example/async_notifier/provider.dart';
import 'package:riverpod_statemanagement/example/async_notifier/user_model.dart';

class AsyncNotifierExampleView extends ConsumerWidget {
  const AsyncNotifierExampleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AsyncNotifier User'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(userNotifierProvider.notifier).refresh();
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            onSelected: (value) {
              if (value == 'load_1') {
                ref.read(userNotifierProvider.notifier).fetchUserById(1);
              } else if (value == 'test_404') {
                ref.read(userNotifierProvider.notifier).fetchUserById(99999);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'load_1', child: Text('Load User 1')),
              const PopupMenuItem(
                value: 'test_404',
                child: Text('Test API 404 Error (ID: 99999)'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userNotifierProvider.notifier).refresh();
        },
        child: userAsync.when(
          data: (user) => _buildUserData(context, ref, user),
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching user data...'),
              ],
            ),
          ),
          error: (error, stackTrace) => _buildErrorWidget(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);

    // Differentiate between API error, network error, timeout, and general errors
    final IconData errorIcon;
    final String errorTitle;
    final String errorMessage;
    final int? statusCode;

    if (error is ApiException) {
      errorIcon = Icons.cloud_off_rounded;
      errorTitle = 'API Error';
      errorMessage = error.message; // Exact message returned from the API
      statusCode = error.statusCode;
    } else if (error is NetworkException) {
      errorIcon = Icons.wifi_off_rounded;
      errorTitle = 'Network Error';
      errorMessage = error.message;
      statusCode = null;
    } else if (error is HttpTimeoutException) {
      errorIcon = Icons.timer_off_outlined;
      errorTitle = 'Request Timeout';
      errorMessage = error.message;
      statusCode = null;
    } else if (error is AppException) {
      errorIcon = Icons.error_outline_rounded;
      errorTitle = 'Application Error';
      errorMessage = error.message;
      statusCode = error.statusCode;
    } else {
      errorIcon = Icons.warning_amber_rounded;
      errorTitle = 'Unexpected Error';
      errorMessage = error.toString();
      statusCode = null;
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorIcon,
                  color: theme.colorScheme.error,
                  size: 54,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                errorTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              if (statusCode != null) ...[
                const SizedBox(height: 8),
                Chip(
                  backgroundColor: theme.colorScheme.errorContainer,
                  side: BorderSide.none,
                  label: Text(
                    'Status: $statusCode',
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'API / System Message',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        ref.read(userNotifierProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => ref
                        .read(userNotifierProvider.notifier)
                        .fetchUserById(1),
                    icon: const Icon(Icons.person),
                    label: const Text('Load User 1'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserData(BuildContext context, WidgetRef ref, User user) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user.image != null && user.image!.isNotEmpty
                      ? NetworkImage(user.image!)
                      : null,
                  child: user.image == null || user.image!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName.isNotEmpty
                      ? user.fullName
                      : (user.username ?? 'Unknown'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.username != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (user.id != null)
                      Chip(
                        avatar: const Icon(Icons.tag, size: 16),
                        label: Text('ID: ${user.id}'),
                      ),
                    if (user.gender != null)
                      Chip(
                        avatar: Icon(
                          user.gender?.toLowerCase() == 'female'
                              ? Icons.female
                              : Icons.male,
                          size: 16,
                        ),
                        label: Text(user.gender!.toUpperCase()),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email ?? 'N/A'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Username'),
                subtitle: Text(user.username ?? 'N/A'),
              ),
              if (user.accessToken != null) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.token_outlined),
                  title: const Text('Access Token'),
                  subtitle: Text(
                    user.accessToken!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final prevId = (user.id ?? 2) > 1 ? (user.id! - 1) : 1;
                  ref.read(userNotifierProvider.notifier).fetchUserById(prevId);
                },
                icon: const Icon(Icons.chevron_left),
                label: const Text('Prev User'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  final nextId = (user.id ?? 1) + 1;
                  ref.read(userNotifierProvider.notifier).fetchUserById(nextId);
                },
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next User'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () {
              ref.read(userNotifierProvider.notifier).fetchUserById(99999);
            },
            icon: const Icon(Icons.bug_report_outlined),
            label: const Text('Test API 404 Error (Fetch User 99999)'),
          ),
        ),
      ],
    );
  }
}
