import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';

/// معرض صور تفاعلي للخدمة مع أسهم للتنقل ونقاط مؤشر وعداد رقمي
class ServiceImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showArrows;
  final bool showDots;
  final bool showCounter;
  final bool enableLightbox;
  final VoidCallback? onImageTap;
  final List<Widget>? overlays;

  const ServiceImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 180,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.showArrows = true,
    this.showDots = true,
    this.showCounter = true,
    this.enableLightbox = true,
    this.onImageTap,
    this.overlays,
  });

  @override
  State<ServiceImageCarousel> createState() => _ServiceImageCarouselState();
}

class _ServiceImageCarouselState extends State<ServiceImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (widget.imageUrls.length <= 1) return;
    final nextIndex = (_currentPage + 1) % widget.imageUrls.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prevPage() {
    if (widget.imageUrls.length <= 1) return;
    final prevIndex = (_currentPage - 1 + widget.imageUrls.length) % widget.imageUrls.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openLightbox(BuildContext context, int initialIndex) {
    if (widget.imageUrls.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => _LightboxViewerDialog(
        imageUrls: widget.imageUrls,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ??
        const BorderRadius.vertical(top: Radius.circular(18));
    final hasMultipleImages = widget.imageUrls.length > 1;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: AppColors.surfaceLow,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // المحتوى الأساسي: الصور
            if (widget.imageUrls.isEmpty)
              _buildEmptyPlaceholder()
            else if (!hasMultipleImages)
              _buildSingleImage(context, widget.imageUrls.first)
            else
              _buildCarousel(context),

            // الأسهم للتنقل بين الصور (تظهر فقط عند وجود عدة صور)
            if (hasMultipleImages && widget.showArrows) ...[
              // سهم التالي (اليسار في الواجهات العربية RTL)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'الصورة التالية',
                    onPressed: _nextPage,
                  ),
                ),
              ),

              // سهم السابق (اليمين في الواجهات العربية RTL)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'الصورة السابقة',
                    onPressed: _prevPage,
                  ),
                ),
              ),
            ],

            // عداد الصور (أسفل اليسار)
            if (hasMultipleImages && widget.showCounter)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 13,
                        color: AppColors.goldDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentPage + 1}/${widget.imageUrls.length}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // نقاط المؤشر السفلية (أسفل المنتصف)
            if (hasMultipleImages && widget.showDots)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.imageUrls.length, (index) {
                        final isSelected = _currentPage == index;
                        return InkWell(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isSelected ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.gold.withOpacity(0.6),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

            // أية عناصر إضافية (مثل شارات التوفر والتصنيف)
            if (widget.overlays != null) ...widget.overlays!,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      color: AppColors.surfaceLow,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration_outlined, size: 48, color: AppColors.burgundy),
            SizedBox(height: 6),
            Text(
              'لا توجد صور مضافة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(BuildContext context, String url) {
    return GestureDetector(
      onTap: widget.onImageTap ??
          (widget.enableLightbox ? () => _openLightbox(context, 0) : null),
      child: _buildNetworkImage(url),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          final url = widget.imageUrls[index];
          return GestureDetector(
            onTap: widget.onImageTap ??
                (widget.enableLightbox
                    ? () => _openLightbox(context, index)
                    : null),
            child: _buildNetworkImage(url),
          );
        },
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.surfaceLow,
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.burgundy,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.surfaceLow,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, size: 40, color: AppColors.textMuted),
              SizedBox(height: 6),
              Text(
                'تعذر تحميل الصورة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر سهم التنقل بين الصور بتأثير تفاعلي وتصميم أنيق
class _CarouselArrowButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _CarouselArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_CarouselArrowButton> createState() => _CarouselArrowButtonState();
}

class _CarouselArrowButtonState extends State<_CarouselArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHovered
                      ? Colors.white
                      : Colors.white.withOpacity(0.92),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.burgundy.withOpacity(0.3)
                        : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.22 : 0.12),
                      blurRadius: _isHovered ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: _isHovered ? AppColors.burgundy : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// نافذة المعاينة الكبيرة بكامل الشاشة عند الضغط على الصورة
class _LightboxViewerDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _LightboxViewerDialog({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_LightboxViewerDialog> createState() => _LightboxViewerDialogState();
}

class _LightboxViewerDialogState extends State<_LightboxViewerDialog> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final nextIdx = (_currentIndex + 1) % widget.imageUrls.length;
    _controller.animateToPage(
      nextIdx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prev() {
    final prevIdx = (_currentIndex - 1 + widget.imageUrls.length) % widget.imageUrls.length;
    _controller.animateToPage(
      prevIdx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الحاوية الأساسية للصورة
          Container(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 650),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, i) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 3.0,
                      child: Center(
                        child: Image.network(
                          widget.imageUrls[i],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // أسهم التنقل الكبيرة
                if (hasMultiple) ...[
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _CarouselArrowButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: 'الصورة التالية',
                        onPressed: _next,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _CarouselArrowButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: 'الصورة السابقة',
                        onPressed: _prev,
                      ),
                    ),
                  ),
                ],

                // عداد الصور العلوي
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '${_currentIndex + 1} من ${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // زر الإغلاق
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}