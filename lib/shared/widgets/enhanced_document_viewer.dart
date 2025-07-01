import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/utils/app_logger.dart';

/// Просмотрщик документов с серверной конвертацией PDF в изображения
class EnhancedDocumentViewer extends StatefulWidget {
  final String documentUrl;
  final String? title;
  final String? description;
  final String? fileExtension;
  final int? sizeBytes;
  final bool showDownloadButton;
  final Color? accentColor;

  const EnhancedDocumentViewer({
    super.key,
    required this.documentUrl,
    this.title,
    this.description,
    this.fileExtension,
    this.sizeBytes,
    this.showDownloadButton = true,
    this.accentColor,
  });

  @override
  State<EnhancedDocumentViewer> createState() => _EnhancedDocumentViewerState();
}

class _EnhancedDocumentViewerState extends State<EnhancedDocumentViewer> {
  late String _elementId;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isExpanded = false;
  String? _textContent;
  
  // Состояние для слайдового режима
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFullscreen = false;
  
  // Состояние для PDF как изображений
  List<String> _pdfImages = [];
  bool _isConvertingPdf = false;
  String? _documentId;
  bool _showFallbackIframe = false;

  @override
  void initState() {
    super.initState();
    _elementId = 'document-viewer-${const Uuid().v4()}';
    _initializeViewer();
  }

  void _initializeViewer() {
    final extension = widget.fileExtension?.toLowerCase() ?? _getExtensionFromUrl();
    
    if (extension == '.txt' || extension == '.md') {
      _loadTextContent();
    } else if (extension == '.pdf') {
      _initializePdfViewer();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Предпросмотр недоступен для данного типа файла';
      });
    }
  }

  String _getExtensionFromUrl() {
    try {
      final uri = Uri.parse(widget.documentUrl);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1) {
        return path.substring(lastDot);
      }
    } catch (e) {
      AppLogger.error('Error parsing URL for extension: $e');
    }
    return '';
  }

  Future<void> _loadTextContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info('📄 Loading text content from: ${widget.documentUrl}');
      
      // Загружаем текстовый контент через fetch
      final request = html.HttpRequest();
      request.open('GET', widget.documentUrl);
      request.onLoadEnd.listen((_) {
        if (request.status == 200) {
          setState(() {
            _textContent = request.responseText;
            _isLoading = false;
            _hasError = false;
          });
          AppLogger.info('📄 Text content loaded successfully');
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = 'Ошибка загрузки: ${request.status}';
            _isLoading = false;
          });
          AppLogger.error('❌ Error loading text content: ${request.status}');
        }
      });
      
      request.onError.listen((_) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Ошибка сети при загрузке файла';
          _isLoading = false;
        });
        AppLogger.error('❌ Network error loading text content');
      });
      
      request.send();
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
      AppLogger.error('❌ Exception loading text content: $e');
    }
  }

  Future<void> _initializePdfViewer() async {
    try {
      AppLogger.info('📄 Initializing PDF viewer with image conversion for: ${widget.documentUrl}');
      
      // Генерируем уникальный ID документа из URL
      _documentId = _generateDocumentId(widget.documentUrl);
      
      setState(() {
        _isLoading = true;
        _isConvertingPdf = false;
      });
      
      // Сначала пытаемся получить уже сконвертированные изображения
      await _loadExistingPdfImages();
      
    } catch (e) {
      AppLogger.error('❌ Error initializing PDF viewer: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Ошибка инициализации PDF: $e';
        _isLoading = false;
      });
    }
  }
  
  String _generateDocumentId(String url) {
    // Создаем уникальный ID на основе URL
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Первые 16 символов хеша
  }
  
  Future<void> _loadExistingPdfImages() async {
    try {
      AppLogger.info('🔍 Checking for existing PDF images: $_documentId');
      
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('getPdfImages');
      
      final result = await callable.call({
        'documentId': _documentId,
      });
      
      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true && data['imageUrls'] != null) {
        final imageUrls = List<String>.from(data['imageUrls']);
        
        if (imageUrls.isNotEmpty) {
          AppLogger.info('✅ Found ${imageUrls.length} existing PDF images');
          setState(() {
            _pdfImages = imageUrls;
            _totalPages = imageUrls.length;
            _currentPage = 1;
            _isLoading = false;
            _hasError = false;
          });
          _updatePageIndicator();
          return;
        }
      }
      
      // Если изображений нет - конвертируем PDF
      AppLogger.info('⚡ No existing images found, converting PDF...');
      await _convertPdfToImages();
      
    } catch (e) {
      AppLogger.error('❌ Error loading existing PDF images: $e');
      // В случае ошибки пытаемся конвертировать
      await _convertPdfToImages();
    }
  }
  
  Future<void> _convertPdfToImages() async {
    try {
      setState(() {
        _isConvertingPdf = true;
        _isLoading = true;
      });
      
      AppLogger.info('🔄 Converting PDF to images: ${widget.documentUrl}');
      
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('convertPdfToImages');
      
      final result = await callable.call({
        'pdfUrl': widget.documentUrl,
        'documentId': _documentId,
      });
      
      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true && data['imageUrls'] != null) {
        final imageUrls = List<String>.from(data['imageUrls']);
        
        AppLogger.info('✅ PDF converted successfully: ${imageUrls.length} pages');
        
        setState(() {
          _pdfImages = imageUrls;
          _totalPages = imageUrls.length;
          _currentPage = 1;
          _isLoading = false;
          _isConvertingPdf = false;
          _hasError = false;
        });
        
        _updatePageIndicator();
      } else {
        throw Exception('Conversion failed: ${data['error'] ?? 'Unknown error'}');
      }
      
    } catch (e) {
      AppLogger.error('❌ Error converting PDF to images: $e');
      AppLogger.info('🔄 Falling back to simple iframe viewer');
      setState(() {
        _showFallbackIframe = true;
        _isLoading = false;
        _isConvertingPdf = false;
        _hasError = false; // Убираем ошибку, так как используем fallback
      });
      _initializeSimpleIframe();
    }
  }

  void _initializeSimpleIframe() {
    try {
      AppLogger.info('📄 Initializing simple iframe for PDF: ${widget.documentUrl}');
      
      // Создаем простой iframe элемент
      final iframe = html.IFrameElement()
        ..src = widget.documentUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..id = '${_elementId}_fallback_iframe';

      // Регистрируем view factory для iframe
      ui_web.platformViewRegistry.registerViewFactory(
        '${_elementId}_fallback',
        (int viewId) => iframe,
      );
      
      AppLogger.info('✅ Simple iframe initialized successfully');
      
    } catch (e) {
      AppLogger.error('❌ Error initializing simple iframe: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Ошибка отображения PDF: $e';
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      AppLogger.info('📄 Previous page: $_currentPage/$_totalPages');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      AppLogger.info('📄 Next page: $_currentPage/$_totalPages');
    }
  }

  void _goToPage(int pageNumber) {
    final iframe = html.document.getElementById('${_elementId}_iframe') as html.IFrameElement?;
    if (iframe != null) {
      // Простое переключение страниц через URL
      final baseUrl = widget.documentUrl.split('#')[0];
      iframe.src = '$baseUrl#page=$pageNumber';
      AppLogger.info('📄 Navigate to page $pageNumber');
    }
  }

  void _toggleFullscreen() {
    final container = html.document.getElementById(_elementId);
    if (container != null) {
      if (!_isFullscreen) {
        container.requestFullscreen();
        setState(() => _isFullscreen = true);
      } else {
        html.document.exitFullscreen();
        setState(() => _isFullscreen = false);
      }
    }
  }

  void _exitFullscreen() {
    if (_isFullscreen) {
      html.document.exitFullscreen();
      setState(() => _isFullscreen = false);
    }
  }

  void _updatePageIndicator() {
    final indicator = html.document.getElementById('${_elementId}_page_indicator');
    if (indicator != null) {
      indicator.innerText = '$_currentPage / $_totalPages';
    }
  }

  Future<void> _downloadDocument() async {
    try {
      AppLogger.info('📄 Downloading document: ${widget.documentUrl}');
      
      // Используем url_launcher для скачивания
      final uri = Uri.parse(widget.documentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        AppLogger.info('📄 Document download initiated');
      } else {
        // Fallback: создаем ссылку для скачивания
        html.AnchorElement(href: widget.documentUrl)
          ..download = widget.title ?? 'document'
          ..click();
        AppLogger.info('📄 Document download via anchor element');
      }
      
    } catch (e) {
      AppLogger.error('❌ Error downloading document: $e');
      
      // Показываем сообщение об ошибке
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка скачивания: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInNewTab() async {
    try {
      html.window.open(widget.documentUrl, '_blank');
      AppLogger.info('📄 Document opened in new tab');
    } catch (e) {
      AppLogger.error('❌ Error opening document in new tab: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.primaryColor;
    final extension = widget.fileExtension?.toLowerCase() ?? _getExtensionFromUrl();

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок документа
            Row(
              children: [
                Icon(
                  extension == '.pdf' ? Icons.slideshow : _getDocumentIcon(extension),
                  color: accentColor,
                  size: extension == '.pdf' ? 24 : 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? (extension == '.pdf' ? 'PDF' : 'Документ'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (extension == '.pdf') ...[
                        const SizedBox(height: 2),
                        Text(
                          'Навигация стрелками ← →',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Кнопки навигации для PDF
                if (extension == '.pdf') ...[
                  IconButton(
                    onPressed: _currentPage > 1 ? _previousPage : null,
                    icon: const Icon(Icons.keyboard_arrow_left),
                    tooltip: 'Предыдущая страница',
                    color: accentColor,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_currentPage / $_totalPages',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                    icon: const Icon(Icons.keyboard_arrow_right),
                    tooltip: 'Следующая страница',
                    color: accentColor,
                  ),
                ],
                if (widget.showDownloadButton) ...[
                  IconButton(
                    onPressed: _downloadDocument,
                    icon: const Icon(Icons.download),
                    tooltip: 'Скачать',
                    color: accentColor,
                  ),
                  IconButton(
                    onPressed: _openInNewTab,
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Открыть в новой вкладке',
                    color: accentColor,
                  ),
                ],
              ],
            ),

            // Описание и размер файла
            if (widget.description != null || widget.sizeBytes != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.description != null) ...[
                    Expanded(
                      child: Text(
                        widget.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                  if (widget.sizeBytes != null) ...[
                    Text(
                      _formatFileSize(widget.sizeBytes!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Состояние загрузки
            if (_isLoading) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _isConvertingPdf 
                            ? 'Конвертируем PDF в изображения...' 
                            : 'Загрузка...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Состояние ошибки
            if (_hasError) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage ?? 'Предпросмотр недоступен',
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _downloadDocument,
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Скачать'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openInNewTab,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Открыть'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Контент документа
            if (!_isLoading && !_hasError) ...[
              // Текстовый контент
              if (_textContent != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isExpanded 
                            ? _textContent!
                            : _textContent!.length > 500
                                ? '${_textContent!.substring(0, 500)}...'
                                : _textContent!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (_textContent!.length > 500) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(_isExpanded ? 'Свернуть' : 'Показать полностью'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // PDF Image Viewer
              if (extension == '.pdf' && _pdfImages.isNotEmpty) ...[
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.grey[50],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Image.network(
                        _pdfImages[_currentPage - 1],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                'Ошибка загрузки страницы $_currentPage',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // Подсказка по навигации
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.slideshow, size: 16, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PDF как слайды • Навигация: стрелки ← → или кнопки',
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // PDF Fallback Iframe Viewer
              if (extension == '.pdf' && _showFallbackIframe) ...[
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: HtmlElementView(
                      viewType: '${_elementId}_fallback',
                    ),
                  ),
                ),
                
                // Подсказка fallback режима
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'PDF просмотр • Базовый режим без конвертации',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension) {
      case '.pdf':
        return Icons.slideshow;
      case '.txt':
      case '.md':
        return Icons.description;
      case '.docx':
      case '.doc':
        return Icons.article;
      default:
        return Icons.description;
    }
  }

  @override
  void dispose() {
    // Убираем полноэкранный режим если активен
    if (_isFullscreen) {
      _exitFullscreen();
    }
    super.dispose();
  }
} 