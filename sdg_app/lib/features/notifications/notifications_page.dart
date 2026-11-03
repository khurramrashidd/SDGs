import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/strings.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/brand.dart';
import '../../core/layout/responsive.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('notifications'))),
      body: ContentShell(
        child: StreamBuilder<List<AppNotification>>(
          stream: service.feed(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? const <AppNotification>[];
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 52,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 14),
                    Text(context.tr('no_notifications')),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextButton.icon(
                      onPressed: () => service
                          .markAllRead(items.map((e) => e.id)),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: Text(context.tr('mark_all_read')),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      final unread = !service.isRead(n.id);
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => service.markRead(n.id),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (unread)
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 6, right: 10),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Brand.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: unread
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.body,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      if (n.createdAt != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('d MMM, h:mm a')
                                              .format(n.createdAt!),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
