import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFormUser,
    this.status = '',
    this.timestamp,
  });

  final String text;
  final bool isFormUser;
  final String status;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFormUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: isFormUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: isFormUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                      fontSize: 16,
                    ),
                  ),
                  selectable: true,
                  imageBuilder: (uri, title, alt) =>
                      Image.network(uri.toString()),
                  onTapLink: (text, url, title) async {
                    if (url != null) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        print('Could not launch $url');
                      }
                    }
                  },
                ),
                if (isFormUser && status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (!isFormUser && timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _formatTimestamp(timestamp!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return DateFormat('h:mm a').format(dateTime);
  }
}
