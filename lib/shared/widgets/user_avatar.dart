import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String firstName;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.firstName,
    this.radius = 24,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackColor = backgroundColor ?? Theme.of(context).primaryColor;
    final fallbackTextStyle = textStyle ?? TextStyle(
      color: Colors.white,
      fontSize: radius * 0.75,
      fontWeight: FontWeight.bold,
    );

    // Если нет URL аватарки, показываем инициалы
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _buildInitialsAvatar(fallbackColor, fallbackTextStyle);
    }

    // Проверяем тип изображения
    final isSvg = photoUrl!.toLowerCase().endsWith('.svg');
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: fallbackColor,
      child: ClipOval(
        child: isSvg 
          ? _buildSvgAvatar(fallbackColor, fallbackTextStyle)
          : _buildNetworkAvatar(fallbackColor, fallbackTextStyle),
      ),
    );
  }

  Widget _buildSvgAvatar(Color fallbackColor, TextStyle fallbackTextStyle) {
    return SvgPicture.network(
      photoUrl!,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => _buildLoadingIndicator(),
      // В случае ошибки SVG показываем инициалы
      errorBuilder: (context, error, stackTrace) {
        print('SVG Avatar loading error: $error');
        return _buildInitialsAvatar(fallbackColor, fallbackTextStyle);
      },
    );
  }

  Widget _buildNetworkAvatar(Color fallbackColor, TextStyle fallbackTextStyle) {
    return CachedNetworkImage(
      imageUrl: photoUrl!,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingIndicator(),
      errorWidget: (context, url, error) {
        print('Network Avatar loading error: $error');
        return _buildInitialsAvatar(fallbackColor, fallbackTextStyle);
      },
    );
  }

  Widget _buildInitialsAvatar(Color backgroundColor, TextStyle textStyle) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
          style: textStyle,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: radius * 0.6,
          height: radius * 0.6,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
} 