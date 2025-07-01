import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/app_logger.dart';

/// Продвинутый рендер Markdown контента для уроков
/// Поддерживает все основные элементы Markdown + кастомную стилизацию
class EnhancedMarkdownRenderer extends StatelessWidget {
  final String markdownData;
  final bool selectable;
  final EdgeInsetsGeometry? padding;
  final TextStyle? baseTextStyle;
  final Color? linkColor;
  final Function(String)? onLinkTap;

  const EnhancedMarkdownRenderer({
    super.key,
    required this.markdownData,
    this.selectable = true,
    this.padding,
    this.baseTextStyle,
    this.linkColor,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkColor = this.linkColor ?? theme.primaryColor;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: MarkdownBody(
        data: markdownData,
        selectable: selectable,
        onTapLink: (text, href, title) {
          if (href != null) {
            if (onLinkTap != null) {
              onLinkTap!(href);
            } else {
              _handleLinkTap(href);
            }
          }
        },
        styleSheet: MarkdownStyleSheet(
          // Базовый стиль текста
          p: baseTextStyle ??
              const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),

          // Заголовки
          h1: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
            height: 1.2,
          ),
          h2: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
            height: 1.3,
          ),
          h3: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
            height: 1.4,
          ),
          h4: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            height: 1.4,
          ),
          h5: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            height: 1.4,
          ),
          h6: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            height: 1.4,
          ),

          // Ссылки
          a: TextStyle(
            color: linkColor,
            decoration: TextDecoration.underline,
            decorationColor: linkColor.withOpacity(0.6),
          ),

          // Код
          code: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            backgroundColor: Colors.grey[200],
            color: Colors.red[700],
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          codeblockPadding: const EdgeInsets.all(12),

          // Цитаты
          blockquote: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
          blockquoteDecoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: theme.primaryColor,
                width: 4,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.all(12),

          // Списки
          listBullet: TextStyle(
            color: theme.primaryColor,
            fontSize: 16,
          ),
          unorderedListAlign: WrapAlignment.start,
          orderedListAlign: WrapAlignment.start,
          listIndent: 24,

          // Выделение текста
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          em: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),

          // Горизонтальная линия
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
          ),

          // Таблицы
          tableHead: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            backgroundColor: theme.primaryColor,
          ),
          tableBody: const TextStyle(
            fontSize: 14,
          ),
          tableBorder: TableBorder.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          tableHeadAlign: TextAlign.center,
          tableCellsDecoration: BoxDecoration(
            color: Colors.grey[50],
          ),
          tableCellsPadding: const EdgeInsets.all(8),

          // Чекбоксы (для списков задач)
          checkbox: TextStyle(
            color: theme.primaryColor,
          ),
        ),
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          <md.InlineSyntax>[
            md.EmojiSyntax(),
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
          ],
        ),
        imageDirectory: '', // Для локальных изображений
      ),
    );
  }

  Future<void> _handleLinkTap(String href) async {
    try {
      AppLogger.info('📝 Opening link: $href');
      
      final uri = Uri.parse(href);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        AppLogger.info('📝 Link opened successfully');
      } else {
        AppLogger.error('❌ Cannot launch URL: $href');
      }
    } catch (e) {
      AppLogger.error('❌ Error opening link: $e');
    }
  }
}

/// Простой Markdown рендерер для коротких текстов (без рамки)
class SimpleMarkdownRenderer extends StatelessWidget {
  final String markdownData;
  final TextStyle? textStyle;
  final Color? linkColor;

  const SimpleMarkdownRenderer({
    super.key,
    required this.markdownData,
    this.textStyle,
    this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MarkdownBody(
      data: markdownData,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          _handleLinkTap(href);
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: textStyle ?? const TextStyle(fontSize: 14, height: 1.5),
        strong: const TextStyle(fontWeight: FontWeight.bold),
        em: const TextStyle(fontStyle: FontStyle.italic),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          backgroundColor: Colors.grey[200],
          color: Colors.red[700],
        ),
        a: TextStyle(
          color: linkColor ?? theme.primaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _handleLinkTap(String href) async {
    try {
      final uri = Uri.parse(href);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.error('❌ Error opening link: $e');
    }
  }
} 