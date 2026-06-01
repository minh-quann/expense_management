import 'dart:math' as math;

import 'package:flutter/cupertino.dart'
    show CupertinoPicker, showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/sf_symbols.dart';
import 'package:expense_management/shared/widgets/liquid_glass/app_liquid_glass_button.dart';

/// Showcase screen for [liquid_glass_widgets] package.
/// Provides a comprehensive playground containing all available glass widgets
/// for visual testing and performance evaluation.
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // Navigation tab bar for screening different showcase categories
  int _selectedTabScreen = 0;

  // Bottom bar selected tab (Scaffold bottom bar test)
  int _selectedTab = 0;

  // Segmented control state
  int _segmentIndex = 0;

  // Switch states
  bool _switch1 = true;
  bool _switch2 = false;

  // Slider state
  double _sliderValue = 0.5;

  // Stepper state
  double _stepperValue = 1.0;

  // Wizard state
  int _wizardStep = 0;

  // Text inputs controllers
  late final TextEditingController _textController1;
  late final TextEditingController _textController2;
  late final TextEditingController _textController3;

  // Selected picker value
  String? _selectedPickerValue;

  LiquidGlassSettings _getGlassSettings(bool isDark) {
    return LiquidGlassSettings(
      refractiveIndex: 1.2,
      thickness: 30.0,
      blur: 1.0,
      saturation: 1.5,
      lightIntensity: isDark ? 0.0 : 1.0,
      ambientStrength: isDark ? 0.0 : 0.5,
      lightAngle: math.pi / 4,
      glassColor: isDark
          ? const Color(0xFFD0D5DD).withValues(alpha: 0.10)
          : const Color(0xFF555555).withValues(
              alpha: 0.08,
            ), // Tối màu nhẹ ở chế độ sáng để hiển thị rõ trên nền trắng
    );
  }

  @override
  void initState() {
    super.initState();
    _textController1 = TextEditingController(text: 'John Doe');
    _textController2 = TextEditingController(text: 'secret123');
    _textController3 = TextEditingController(
      text:
          'Đây là ô nhập liệu nhiều dòng sử dụng GlassTextArea.\n'
          'Bạn có thể gõ thêm dòng mới hoặc cuộn xem nội dung bên trong.',
    );

    // Auto-start the performance monitor in debug/profile modes
    // Removed GlassPerformanceMonitor.start() to improve smoothness (FPS) during user interaction.
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    _textController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBody: true,
      // Bottom navigation bar built using GlassBottomBar
      bottomNavigationBar: _buildGlassBottomBar(isDark),
      body: Stack(
        children: [
          // Background Color Layer
          Positioned.fill(
            child: Container(color: AppColors.background(context)),
          ),

          // Main Interactive Content Screen
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const ScreenHeader(title: 'LGW Showcase', showBackButton: true),

                // Primary Category Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: GlassTabBar(
                    tabs: const [
                      GlassTab(
                        icon: Icon(Icons.layers_outlined),
                        label: 'Hộp chứa',
                      ),
                      GlassTab(
                        icon: Icon(Icons.touch_app_outlined),
                        label: 'Tương tác',
                      ),
                      GlassTab(
                        icon: Icon(Icons.edit_note_outlined),
                        label: 'Nhập liệu',
                      ),
                      GlassTab(
                        icon: Icon(Icons.open_in_new_outlined),
                        label: 'Lớp phủ',
                      ),
                      GlassTab(
                        icon: Icon(Icons.speed_outlined),
                        label: 'Hiệu năng',
                      ),
                    ],
                    selectedIndex: _selectedTabScreen,
                    onTabSelected: (index) {
                      setState(() => _selectedTabScreen = index);
                    },
                    height: 52,
                    isScrollable: true,
                    selectedLabelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : AppColors.gray500,
                    ),
                    selectedIconColor: isDark
                        ? Colors.white
                        : AppColors.primary,
                    unselectedIconColor: isDark
                        ? Colors.white54
                        : AppColors.gray500,
                    indicatorColor: isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.08),
                    useOwnLayer: true,
                    settings: _getGlassSettings(isDark),
                  ),
                ),

                Expanded(child: _buildPageContent(isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the GlassBottomBar using liquid_glass_widgets
  Widget _buildGlassBottomBar(bool isDark) {
    return GlassBottomBar(
      tabs: [
        GlassBottomBarTab(
          label: 'Home',
          icon: Icon(SFSymbols.house),
          activeIcon: Icon(SFSymbols.house_fill),
          glowColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        GlassBottomBarTab(
          label: 'Trans',
          icon: Icon(SFSymbols.list_clipboard),
          activeIcon: Icon(SFSymbols.list_clipboard_fill),
          glowColor: Colors.cyan.withValues(alpha: 0.5),
        ),
        GlassBottomBarTab(
          label: 'Stats',
          icon: Icon(SFSymbols.chart_bar),
          activeIcon: Icon(SFSymbols.chart_bar_fill),
          glowColor: Colors.orange.withValues(alpha: 0.5),
        ),
        GlassBottomBarTab(
          label: 'Profile',
          icon: Icon(SFSymbols.person),
          activeIcon: Icon(SFSymbols.person_fill),
          glowColor: Colors.purple.withValues(alpha: 0.5),
        ),
      ],
      selectedIndex: _selectedTab,
      onTabSelected: (index) {
        setState(() => _selectedTab = index);
      },
      barHeight: 64,
      horizontalPadding: 20,
      verticalPadding: 12,
      selectedIconColor: isDark ? Colors.white : AppColors.primary,
      unselectedIconColor: isDark
          ? const Color(0xFF8E8E93)
          : const Color(0xFF3C3C43),
      iconSize: 24,
      labelFontSize: 11,
      glassSettings: _getGlassSettings(isDark),
    );
  }

  /// Main render switcher for different tabs
  Widget _buildPageContent(bool isDark) {
    // Colors resolved dynamically
    final cardTextColor = isDark ? Colors.white : AppColors.gray900;
    final cardSubtitleColor = isDark ? Colors.white70 : AppColors.gray600;

    Widget content;
    switch (_selectedTabScreen) {
      case 0:
        content = _buildContainersTab(isDark, cardTextColor, cardSubtitleColor);
        break;
      case 1:
        content = _buildInteractiveTab(
          isDark,
          cardTextColor,
          cardSubtitleColor,
        );
        break;
      case 2:
        content = _buildInputsTab(isDark, cardTextColor, cardSubtitleColor);
        break;
      case 3:
        content = _buildOverlaysTab(isDark, cardTextColor, cardSubtitleColor);
        break;
      case 4:
      default:
        content = _buildFeedbackTab(isDark, cardTextColor, cardSubtitleColor);
        break;
    }

    return AdaptiveLiquidGlassLayer(
      settings: _getGlassSettings(isDark),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            // Safe spacing for bottom navigation bar overlay
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Section label helper with modern underlines
  Widget _buildSectionLabel(String label, bool isDark) {
    final color = isDark ? AppColors.primaryLight : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(label, fontSize: 13, fontWeight: FontWeight.w700, color: color),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 2,
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
          ),
        ),
      ],
    );
  }

  /// TAB 0: CONTAINERS SHOWCASE
  Widget _buildContainersTab(
    bool isDark,
    Color cardTextColor,
    Color cardSubtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('GlassCard & GlassContainer', isDark),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          shape: const LiquidRoundedSuperellipse(borderRadius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'GlassCard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cardTextColor,
              ),
              const SizedBox(height: 8),
              AppText(
                'Card này sử dụng GlassCard từ liquid_glass_widgets. '
                'Nó tự động thừa kế cấu hình kính từ AdaptiveLiquidGlassLayer cha.',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: cardSubtitleColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                height: 100,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: AppText(
                  'Superellipse Container',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cardTextColor,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GlassContainer(
              width: 100,
              height: 100,
              shape: const LiquidOval(),
              alignment: Alignment.center,
              child: AppText(
                'Oval shape',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cardTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassPanel (For Larger Surfaces)', isDark),
        const SizedBox(height: 12),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Glass Panel View',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cardTextColor,
              ),
              const SizedBox(height: 8),
              AppText(
                'GlassPanel cung cấp bo góc rộng hơn (20px) và padding mặc định rộng rãi (24px) phù hợp cho các layout chi tiết, modal hoặc bảng hiển thị lớn.',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: cardSubtitleColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassListTile & Divider', isDark),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          child: Column(
            children: [
              GlassListTile(
                leading: Icon(
                  Icons.person_outline_rounded,
                  color: cardTextColor,
                ),
                title: AppText(
                  'Thông tin tài khoản',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cardTextColor,
                ),
                subtitle: AppText(
                  'Chỉnh sửa thông tin cá nhân',
                  fontSize: 11,
                  color: cardSubtitleColor,
                ),
                trailing: GlassListTile.chevron,
                onTap: () {},
              ),
              GlassListTile(
                leading: Icon(
                  Icons.notifications_none_rounded,
                  color: cardTextColor,
                ),
                title: AppText(
                  'Cài đặt thông báo',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cardTextColor,
                ),
                trailing: AppText(
                  'Bật',
                  fontSize: 13,
                  color: cardSubtitleColor,
                ),
                onTap: () {},
              ),
              GlassListTile(
                leading: Icon(Icons.shield_outlined, color: cardTextColor),
                title: AppText(
                  'Quyền riêng tư & Bảo mật',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cardTextColor,
                ),
                trailing: GlassListTile.chevron,
                isLast: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassListTile.standalone(
          leading: const Icon(Icons.star_outline_rounded, color: Colors.amber),
          title: AppText(
            'Standalone List Tile',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cardTextColor,
          ),
          subtitle: AppText(
            'Tự quản lý một layer kính riêng lẻ',
            fontSize: 11,
            color: cardSubtitleColor,
          ),
          trailing: GlassListTile.infoButton,
          onTap: () {},
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassStepper (UIStepper)', isDark),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Tăng giảm số lượng',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cardTextColor,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    'Giá trị: ${_stepperValue.toInt()}',
                    fontSize: 12,
                    color: cardSubtitleColor,
                  ),
                ],
              ),
              GlassStepper(
                value: _stepperValue,
                min: 1,
                max: 10,
                onChanged: (val) {
                  setState(() => _stepperValue = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassWizard (Sequential Steps)', isDark),
        const SizedBox(height: 12),
        GlassWizard(
          currentStep: _wizardStep,
          onStepTapped: (index) {
            setState(() => _wizardStep = index);
          },
          steps: [
            GlassWizardStep(
              title: AppText(
                'Liên kết ví',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cardTextColor,
              ),
              subtitle: AppText(
                'Kết nối tài khoản ngân hàng',
                fontSize: 11,
                color: cardSubtitleColor,
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Vui lòng kết nối ví để theo dõi các chi tiêu tự động.',
                    fontSize: 12,
                    color: cardSubtitleColor,
                  ),
                  const SizedBox(height: 8),
                  AppLiquidGlassButton(
                    width: 120,
                    height: 36,
                    onTap: () => setState(() => _wizardStep = 1),
                    padding: EdgeInsets.zero,
                    child: AppText(
                      'Tiếp theo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardTextColor,
                    ),
                  ),
                ],
              ),
            ),
            GlassWizardStep(
              title: AppText(
                'Hạn mức ngân sách',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cardTextColor,
              ),
              subtitle: AppText(
                'Đặt ngân sách chi tiêu hàng tháng',
                fontSize: 11,
                color: cardSubtitleColor,
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Thiết lập số tiền tối đa bạn muốn chi tiêu.',
                    fontSize: 12,
                    color: cardSubtitleColor,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppLiquidGlassButton(
                        width: 80,
                        height: 32,
                        onTap: () => setState(() => _wizardStep = 0),
                        padding: EdgeInsets.zero,
                        child: AppText(
                          'Quay lại',
                          fontSize: 11,
                          color: cardTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppLiquidGlassButton(
                        width: 80,
                        height: 32,
                        onTap: () => setState(() => _wizardStep = 2),
                        padding: EdgeInsets.zero,
                        child: AppText(
                          'Hoàn tất',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cardTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GlassWizardStep(
              title: AppText(
                'Hoàn thành',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cardTextColor,
              ),
              subtitle: AppText(
                'Quy trình đã hoàn tất',
                fontSize: 11,
                color: cardSubtitleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// TAB 1: INTERACTIVE COMPONENTS SHOWCASE
  Widget _buildInteractiveTab(
    bool isDark,
    Color cardTextColor,
    Color cardSubtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('GlassButtons & GlassIconButton', isDark),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppLiquidGlassButton(
              width: 50,
              height: 50,
              borderRadius: 100.0,
              padding: EdgeInsets.zero,
              onTap: () {},
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.pink500,
                size: 22,
              ),
            ),
            AppLiquidGlassButton(
              width: 110,
              height: 48,
              padding: EdgeInsets.zero,
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded, color: cardTextColor, size: 20),
                  const SizedBox(width: 6),
                  AppText('Chia sẻ', fontSize: 14, color: cardTextColor),
                ],
              ),
            ),
            GlassIconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
              shape: GlassIconButtonShape.circle,
              size: 48,
              glowColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassButtonGroup (Segmented Continuous)', isDark),
        const SizedBox(height: 12),
        Center(
          child: GlassButtonGroup(
            direction: Axis.horizontal,
            children: [
              GlassButton.custom(
                width: 80,
                height: 40,
                onTap: () {},
                shape: const LiquidRoundedSuperellipse(borderRadius: 12.0),
                settings: _getGlassSettings(isDark),
                child: Icon(
                  Icons.format_align_left_rounded,
                  color: cardTextColor,
                  size: 20,
                ),
              ),
              GlassButton.custom(
                width: 80,
                height: 40,
                onTap: () {},
                shape: const LiquidRoundedSuperellipse(borderRadius: 12.0),
                settings: _getGlassSettings(isDark),
                child: Icon(
                  Icons.format_align_center_rounded,
                  color: cardTextColor,
                  size: 20,
                ),
              ),
              GlassButton.custom(
                width: 80,
                height: 40,
                onTap: () {},
                shape: const LiquidRoundedSuperellipse(borderRadius: 12.0),
                settings: _getGlassSettings(isDark),
                child: Icon(
                  Icons.format_align_right_rounded,
                  color: cardTextColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassSegmentedControl', isDark),
        const SizedBox(height: 12),
        GlassSegmentedControl(
          segments: const ['Thu nhập', 'Chi phí', 'Chuyển khoản'],
          selectedIndex: _segmentIndex,
          onSegmentSelected: (index) {
            setState(() => _segmentIndex = index);
          },
          height: 38,
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassChip & GlassBadge', isDark),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassChip(
              label: 'Giải trí',
              icon: const Icon(Icons.movie_filter_rounded, size: 16),
              onTap: () {},
            ),
            GlassChip(
              label: 'Mua sắm',
              selected: true,
              selectedColor: AppColors.primary.withValues(alpha: 0.3),
              onTap: () {},
            ),
            GlassChip(label: 'Đồ ăn', onDeleted: () {}),
            GlassBadge(
              count: 9,
              child: GlassIconButton(
                icon: const Icon(Icons.notifications_active_rounded),
                onPressed: () {},
                size: 40,
              ),
            ),
            GlassBadge.dot(
              dotColor: Colors.green,
              position: BadgePosition.topRight,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_queue_rounded,
                  color: cardTextColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassSwitch & GlassSlider', isDark),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Hiệu ứng kính nâng cao',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cardTextColor,
                  ),
                  GlassSwitch(
                    value: _switch1,
                    onChanged: (val) => setState(() => _switch1 = val),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Chế độ tiết kiệm pin',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cardTextColor,
                  ),
                  GlassSwitch(
                    value: _switch2,
                    onChanged: (val) => setState(() => _switch2 = val),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassSlider(
                value: _sliderValue,
                onChanged: (val) => setState(() => _sliderValue = val),
                activeColor: AppColors.primary,
              ),
              Center(
                child: AppText(
                  'Độ mờ kính: ${(_sliderValue * 100).toInt()}%',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cardSubtitleColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassPullDownButton (Morphing Popup Menu)', isDark),
        const SizedBox(height: 12),
        Center(
          child: GlassMenu(
            menuWidth: 200,
            triggerBuilder: (context, toggleMenu) {
              return AppLiquidGlassButton(
                width: 160,
                height: 44,
                onTap: toggleMenu,
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTheme(
                      data: IconThemeData(size: 20, color: cardTextColor),
                      child: const Icon(Icons.arrow_drop_down_circle_outlined),
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      'Chọn thao tác',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: cardTextColor,
                    ),
                  ],
                ),
              );
            },
            items: [
              GlassMenuItem(
                title: 'Tải lại dữ liệu',
                icon: const Icon(Icons.refresh_rounded),
                onTap: () {},
              ),
              GlassMenuItem(
                title: 'Cài đặt giao diện',
                icon: const Icon(Icons.color_lens_outlined),
                onTap: () {},
              ),
              GlassMenuItem(
                title: 'Xóa toàn bộ',
                icon: const Icon(Icons.delete_sweep_rounded),
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// TAB 2: INPUT CONTROLS SHOWCASE
  Widget _buildInputsTab(
    bool isDark,
    Color cardTextColor,
    Color cardSubtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('GlassFormField & GlassTextField', isDark),
        const SizedBox(height: 12),
        GlassFormField(
          label: 'Họ và tên',
          helperText: 'Nhập đầy đủ họ tên như trong căn cước',
          child: GlassTextField(
            controller: _textController1,
            placeholder: 'Ví dụ: Nguyễn Văn A',
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: cardTextColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassFormField(
          label: 'Mật khẩu bảo mật',
          errorText: _textController2.text.length < 6
              ? 'Mật khẩu quá ngắn (tối thiểu 6 ký tự)'
              : null,
          child: GlassPasswordField(
            controller: _textController2,
            placeholder: 'Nhập mật khẩu của bạn',
            onChanged: (val) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel('GlassTextArea (Multi-line Input)', isDark),
        const SizedBox(height: 12),
        GlassTextArea(
          controller: _textController3,
          placeholder: 'Nhập ghi chú chi tiết...',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassSearchBar', isDark),
        const SizedBox(height: 12),
        GlassSearchBar(
          placeholder: 'Tìm kiếm giao dịch chi tiêu...',
          showsCancelButton: true,
          onChanged: (val) {},
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassPicker (Cupertino Bottom Popup)', isDark),
        const SizedBox(height: 12),
        GlassPicker(
          value: _selectedPickerValue,
          placeholder: 'Chọn đồng tiền hiển thị',
          onTap: () async {
            final List<String> currencies = ['VND', 'USD', 'EUR', 'JPY', 'GBP'];
            await showCupertinoModalPopup<void>(
              context: context,
              builder: (context) => Container(
                height: 260,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: AppText(
                        'Đồng Tiền Hiển Thị',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 44,
                        onSelectedItemChanged: (index) {
                          setState(
                            () => _selectedPickerValue = currencies[index],
                          );
                        },
                        children: currencies
                            .map(
                              (c) => Center(
                                child: AppText(
                                  c,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// TAB 3: POPUPS AND OVERLAYS
  Widget _buildOverlaysTab(
    bool isDark,
    Color cardTextColor,
    Color cardSubtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Hộp thoại & Lớp phủ (Overlays)', isDark),
        const SizedBox(height: 12),
        AppText(
          'Kích hoạt các hiệu ứng hộp thoại, thông báo và sheet chuyển đổi 3 trạng thái kiểu iOS.',
          fontSize: 13,
          color: cardSubtitleColor,
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 1. GlassDialog
              ListTile(
                leading: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                ),
                title: AppText(
                  'GlassDialog.show()',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardTextColor,
                ),
                subtitle: AppText(
                  'Hộp thoại cảnh báo với các nút tùy chọn kính mờ',
                  fontSize: 11,
                  color: cardSubtitleColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: cardSubtitleColor,
                ),
                onTap: () {
                  GlassDialog.show(
                    context: context,
                    title: 'Xác nhận xóa tài khoản?',
                    message:
                        'Mọi dữ liệu chi tiêu của bạn sẽ bị xóa vĩnh viễn và không thể khôi phục.',
                    actions: [
                      GlassDialogAction(
                        label: 'Hủy bộ',
                        onPressed: () => Navigator.pop(context),
                      ),
                      GlassDialogAction(
                        label: 'Xóa ngay',
                        isDestructive: true,
                        onPressed: () {
                          Navigator.pop(context);
                          GlassToast.show(
                            context,
                            message: 'Đã gửi yêu cầu xóa tài khoản',
                            type: GlassToastType.warning,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              Divider(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.08),
                height: 1,
              ),
              // 2. GlassActionSheet
              ListTile(
                leading: Icon(
                  Icons.menu_open_rounded,
                  color: AppColors.cyan600,
                ),
                title: AppText(
                  'showGlassActionSheet()',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardTextColor,
                ),
                subtitle: AppText(
                  'Action sheet trượt từ đáy màn hình',
                  fontSize: 11,
                  color: cardSubtitleColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: cardSubtitleColor,
                ),
                onTap: () {
                  showGlassActionSheet(
                    context: context,
                    title: 'Chọn hành động xuất dữ liệu',
                    message:
                        'Dữ liệu xuất ra sẽ chứa danh sách giao dịch tháng này',
                    actions: [
                      GlassActionSheetAction(
                        label: 'Xuất ra Excel (XLSX)',
                        icon: const Icon(Icons.table_view_rounded),
                        onPressed: () {},
                      ),
                      GlassActionSheetAction(
                        label: 'Xuất ra tài liệu PDF',
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        onPressed: () {},
                      ),
                      GlassActionSheetAction(
                        label: 'Đóng hoàn toàn',
                        style: GlassActionSheetStyle.destructive,
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              ),
              Divider(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.08),
                height: 1,
              ),
              // 3. GlassToast
              ListTile(
                leading: Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.orange500,
                ),
                title: AppText(
                  'GlassToast.show()',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardTextColor,
                ),
                subtitle: AppText(
                  'Thông báo nhanh tự tắt (Toast / SnackBar)',
                  fontSize: 11,
                  color: cardSubtitleColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: cardSubtitleColor,
                ),
                onTap: () {
                  final types = [
                    GlassToastType.success,
                    GlassToastType.error,
                    GlassToastType.info,
                    GlassToastType.warning,
                  ];
                  final messages = [
                    'Cập nhật thành công thông tin cấu hình!',
                    'Lỗi kết nối máy chủ dữ liệu.',
                    'Số dư ví của bạn đang ở mức thấp.',
                    'Hạn mức ngân sách sắp vượt ngưỡng.',
                  ];
                  final randomIdx = math.Random().nextInt(4);
                  GlassToast.show(
                    context,
                    message: messages[randomIdx],
                    type: types[randomIdx],
                    duration: const Duration(seconds: 3),
                  );
                },
              ),
              Divider(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.08),
                height: 1,
              ),
              // 4. GlassSheet
              ListTile(
                leading: Icon(
                  Icons.playlist_add_check_circle_outlined,
                  color: AppColors.pink500,
                ),
                title: AppText(
                  'GlassSheet.show()',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardTextColor,
                ),
                subtitle: AppText(
                  'Bottom sheet kính chứa widget tùy chọn',
                  fontSize: 11,
                  color: cardSubtitleColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: cardSubtitleColor,
                ),
                onTap: () {
                  GlassSheet.show(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        AppText(
                          'Danh sách ví tài khoản',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          3,
                          (index) => ListTile(
                            leading: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.cyan,
                            ),
                            title: AppText(
                              'Ví chi tiêu ${index + 1}',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            subtitle: AppText(
                              'Số dư: 1,500,000đ',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppLiquidGlassButton(
                          onTap: () => Navigator.pop(context),
                          width: 140,
                          height: 40,
                          padding: EdgeInsets.zero,
                          child: AppText(
                            'Hoàn tất',
                            fontSize: 14,
                            color: cardTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Divider(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.08),
                height: 1,
              ),
              // 5. GlassModalSheet
              ListTile(
                leading: Icon(
                  Icons.expand_circle_down_outlined,
                  color: AppColors.blue500,
                ),
                title: AppText(
                  'GlassModalSheet.show()',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardTextColor,
                ),
                subtitle: AppText(
                  'Modal sheet đa trạng thái kiểu iOS 18+',
                  fontSize: 11,
                  color: cardSubtitleColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: cardSubtitleColor,
                ),
                onTap: () {
                  GlassModalSheet.show(
                    context: context,
                    initialState: SheetState.half,
                    builder: (context) => Column(
                      children: [
                        const SizedBox(height: 16),
                        AppText(
                          'Cơ sở dữ liệu thống kê',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          'Nhấp giữ và kéo lên/xuống để thay đổi chiều cao sheet.',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 15,
                            itemBuilder: (context, index) => ListTile(
                              leading: const Icon(
                                Icons.insert_chart_outlined,
                                color: Colors.orange,
                              ),
                              title: AppText(
                                'Báo cáo phân tích số ${index + 1}',
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              subtitle: AppText(
                                'Phân tích thói quen tiêu dùng',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// TAB 4: PERFORMANCE AND MONITOR FEEDBACK
  Widget _buildFeedbackTab(
    bool isDark,
    Color cardTextColor,
    Color cardSubtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('GlassProgressIndicators', isDark),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const GlassProgressIndicator.circular(),
                      const SizedBox(height: 6),
                      AppText(
                        'Indeterminate',
                        fontSize: 11,
                        color: cardSubtitleColor,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const GlassProgressIndicator.circular(value: 0.75),
                      const SizedBox(height: 6),
                      AppText(
                        'Ring 75%',
                        fontSize: 11,
                        color: cardSubtitleColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const GlassProgressIndicator.linear(),
              const SizedBox(height: 4),
              AppText(
                'Linear Indeterminate',
                fontSize: 11,
                color: cardSubtitleColor,
              ),
              const SizedBox(height: 12),
              const GlassProgressIndicator.linear(value: 0.6),
              const SizedBox(height: 4),
              AppText(
                'Linear Determinate (60%)',
                fontSize: 11,
                color: cardSubtitleColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('GlassPerformanceMonitor (GPU Analysis)', isDark),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Trạng thái Monitor',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cardTextColor,
                  ),
                  AppText(
                    GlassPerformanceMonitor.isRunning ? 'ĐANG CHẠY' : 'ĐÃ DỪNG',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: GlassPerformanceMonitor.isRunning
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Premium Layers Active',
                    fontSize: 14,
                    color: cardTextColor,
                  ),
                  AppText(
                    '${GlassPerformanceMonitor.activePremiumCount}',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cardTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Cảnh báo quá tải GPU',
                    fontSize: 14,
                    color: cardTextColor,
                  ),
                  AppText(
                    GlassPerformanceMonitor.warningEmitted
                        ? 'QUÁ TẢI'
                        : 'BÌNH THƯỜNG',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: GlassPerformanceMonitor.warningEmitted
                        ? Colors.orange
                        : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppLiquidGlassButton(
                    width: 90,
                    height: 36,
                    onTap: () {
                      setState(() {
                        GlassPerformanceMonitor.start();
                      });
                    },
                    padding: EdgeInsets.zero,
                    child: AppText(
                      'Bắt đầu',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardTextColor,
                    ),
                  ),
                  AppLiquidGlassButton(
                    width: 90,
                    height: 36,
                    onTap: () {
                      setState(() {
                        GlassPerformanceMonitor.stop();
                      });
                    },
                    padding: EdgeInsets.zero,
                    child: AppText(
                      'Dừng',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardTextColor,
                    ),
                  ),
                  AppLiquidGlassButton(
                    width: 90,
                    height: 36,
                    onTap: () {
                      setState(() {
                        GlassPerformanceMonitor.reset();
                      });
                    },
                    padding: EdgeInsets.zero,
                    child: AppText(
                      'Đặt lại',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
