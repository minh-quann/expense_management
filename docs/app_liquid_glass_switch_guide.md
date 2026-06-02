# Hướng Dẫn Sử Dụng AppLiquidGlassSwitch

**Đường dẫn file:** `lib/shared/widgets/liquid_glass/app_liquid_glass_switch.dart`

`AppLiquidGlassSwitch` là một nút gạt (Toggle Switch) tối giản được phủ lớp shader Kính Lỏng (Liquid Glass). 

## 1. Tính Năng Cốt Lõi

- **Xử lý Theme tự động:** Tự động đổi màu đường ray (track) để đảm bảo độ tương phản. Ở Dark Mode, rãnh trượt sẽ là màu kính mờ ảo trong suốt; ở Light Mode, rãnh trượt sẽ ngả xám nhạt tinh tế.
- **Tích hợp xúc giác (Haptics):** Mỗi lần người dùng gạt qua lại, máy sẽ tự động tạo rung phản hồi nhẹ.

## 2. API & Thuộc Tính

| Thuộc tính | Kiểu dữ liệu | Mô tả |
|---|---|---|
| `value` | `bool` | Trạng thái Bật/Tắt của công tắc. |
| `onChanged` | `ValueChanged<bool>` | Callback khi công tắc thay đổi giá trị. |
| `activeColor`| `Color?` | Màu rãnh trượt khi Bật (Mặc định: Primary App Color). |
| `inactiveColor`| `Color?` | Màu rãnh trượt khi Tắt (Mặc định: Auto-resolve). |
| `thumbColor` | `Color` | Màu của núm tròn (Mặc định: Trắng). |
| `enableHaptics`| `bool` | Kích hoạt Rung phản hồi (Mặc định: true). |

## 3. Ví Dụ Cách Dùng

```dart
AppLiquidGlassSwitch(
  value: _isBiometricsEnabled,
  activeColor: AppColors.primary,
  onChanged: (val) {
    setState(() {
      _isBiometricsEnabled = val;
    });
  },
)
```
