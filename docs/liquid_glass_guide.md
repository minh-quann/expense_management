# Hướng dẫn triển khai hiệu ứng Liquid Glass (Kính lỏng) trong Flutter

Tài liệu này hướng dẫn chi tiết cách tạo hiệu ứng kính lỏng khúc xạ (Liquid Glass) cao cấp kết hợp hiệu ứng biến dạng hữu cơ (squash & stretch) cho thanh điều hướng dưới (Bottom Navigation Bar) và các thanh chuyển đổi (Toggle Bar) bằng cách sử dụng các widget dùng chung trong dự án.

---

## 1. Nguyên lý hoạt động của Liquid Glass

Hiệu ứng Liquid Glass mô phỏng một thấu kính thủy tinh lỏng thực tế bao gồm các đặc tính vật lý:
- **Khúc xạ (Refraction):** Bẻ cong ánh sáng đi qua kính tạo cảm giác thấu kính dày.
- **Độ mờ (Blur):** Làm mờ hậu cảnh đằng sau lớp kính.
- **Ánh sáng (Specular Highlight & Ambient):** Tạo đường viền sáng bóng dựa trên hướng ánh sáng.
- **Sắc sai (Chromatic Aberration):** Sự phân tách màu sắc nhẹ ở rìa thấu kính do hiện tượng tán sắc ánh sáng.
- **Hòa trộn lỏng (Liquid Blending):** Khi hai thấu kính ở gần nhau, chúng sẽ tự động hút và hòa vào nhau giống như những giọt nước.

---

## 2. Cấu trúc Widget chính

Thư viện `liquid_glass_renderer` cung cấp các Widget cốt lõi sau để cấu thành hiệu ứng:

```
LiquidGlassLayer (Bao bọc cấu hình kính chung)
  └── LiquidGlassBlendGroup (Nhóm các thấu kính hòa trộn)
        ├── LiquidGlass.grouped (Thanh nền Nav Bar)
        └── LiquidGlass.withOwnLayer (Viên Pill trượt đè lên trên)
```

Để đơn giản hóa và tăng tính tái sử dụng, dự án đã đóng gói sẵn hai Widget dùng chung tiện lợi:
1. **`AppLiquidGlassIndicator`:** Dành cho các thanh điều hướng trượt có viên thuốc (Bottom Navigation, Toggle Bar). Tự động bao gồm hiệu ứng nền kính lỏng, viên trượt lỏng co giãn và blend group.
2. **`AppLiquidGlass`:** Dành cho các hộp kính tĩnh (Bento Card, Glass Button, Glass Container).

---

## 3. Các tham số cấu hình chính (`LiquidGlassSettings`)

| Tham số | Ý nghĩa | Giá trị gợi ý |
| :--- | :--- | :--- |
| `refractiveIndex` | Chỉ số khúc xạ. Quyết định mức độ bẻ cong hình ảnh phía sau. | `1.1` - `1.3` (1.21 là tối ưu) |
| `thickness` | Độ dày của kính. Kính càng dày đường viền khúc xạ càng lớn. | `20` - `50` |
| `blur` | Độ mờ hậu cảnh (Gaussian Blur). | `10` - `20` |
| `saturation` | Độ bão hòa màu sắc đi qua kính. Tăng màu sắc giúp kính trông sống động hơn. | `1.2` - `1.8` |
| `lightIntensity` | Cường độ ánh sáng chiếu lên kính tạo highlight sáng bóng ở rìa. | `0.7` (Dark Mode) - `2.5` (Active Pill) |
| `ambientStrength` | Độ sáng môi trường xung quanh giúp hiển thị rõ bề mặt kính. | `0.2` (Tối) - `0.5` (Sáng) |
| `lightAngle` | Góc của nguồn sáng chiếu tới (tính bằng Radian). | `math.pi / 4` (Góc 45 độ) |
| `chromaticAberration`| Độ sắc sai (tách màu cầu vồng ở viền thấu kính). | `0.2` - `0.5` |
| `glassColor` | Màu sắc tint của kính (thường dùng màu trắng hoặc xám trong suốt). | `Color.fromValues(alpha: 0.45)` |

---

## 4. Sử dụng Widget dùng chung `AppLiquidGlassIndicator` cho Navigation Bar và Toggle Bar

Widget dùng chung `AppLiquidGlassIndicator` từ [app_liquid_glass.dart](file:///home/quan/Documents/expense_management/lib/shared/widgets/app_liquid_glass.dart) đã tích hợp sẵn toàn bộ cấu hình kính lỏng nền, hiệu ứng hòa trộn (blend) và viên trượt lỏng co giãn (squash & stretch) tự nhiên.

### Cú pháp sử dụng cơ bản:

```dart
import 'package:expense_management/shared/widgets/app_liquid_glass.dart';

AppLiquidGlassIndicator(
  selectedIndex: currentIndex,
  count: 4,
  onChanged: (index) {
    // Xử lý khi đổi tab
  },
  child: Row(
    children: [
      // Các tab item
    ],
  ),
)
```

### Các thuộc tính tùy biến chính của `AppLiquidGlassIndicator`:

| Thuộc tính | Kiểu dữ liệu | Mặc định | Ý nghĩa |
| :--- | :--- | :--- | :--- |
| `borderRadius` | `double` | `100.0` | Bo góc của thanh nền kính và viên trượt (mặc định bo tròn pill). |
| `refractiveIndex`| `double` | `1.21` | Chỉ số khúc xạ bẻ cong ánh sáng của nền kính. |
| `thickness` | `double` | `30.0` | Độ dày đường viền khúc xạ của thanh nền kính. |
| `blur` | `double` | `10.0` | Độ mờ Gaussian hậu cảnh. |
| `saturation` | `double` | `1.5` | Độ tăng cường bão hòa màu sắc hậu cảnh qua kính. |
| `blend` | `double` | `10.0` | Bán kính tương tác hòa trộn (pixel) giữa thấu kính nền và thấu kính viên trượt. |
| `glassColor` | `Color?` | `null` | Màu kính nền (Tự động chuyển đổi Light/Dark Mode nếu để null). |
| `padding` | `EdgeInsetsGeometry?` | `null` | Khoảng đệm bên trong của thanh nền kính. |
| `margin` | `EdgeInsetsGeometry?` | `null` | Khoảng cách lề bên ngoài. |

---

## 5. Ví dụ thực tế áp dụng trong dự án

### Ví dụ 1: Thanh Bottom Navigation Bar (`app_shell.dart`)
```dart
SizedBox(
  height: 64,
  child: AppLiquidGlassIndicator(
    selectedIndex: widget.navigationShell.currentIndex,
    count: 4,
    isDark: isDark,
    onChanged: (index) => _onTap(context, index),
    borderRadius: 100,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildNavItem(context, 0, SFSymbols.house, SFSymbols.house_fill, 'Trang chủ'),
        _buildNavItem(context, 1, SFSymbols.list_clipboard, SFSymbols.list_clipboard_fill, 'Giao dịch'),
        _buildNavItem(context, 2, SFSymbols.chart_bar, SFSymbols.chart_bar_fill, 'Thống kê'),
        _buildNavItem(context, 3, SFSymbols.person, SFSymbols.person_fill, 'Tài khoản'),
      ],
    ),
  ),
)
```

### Ví dụ 2: Thanh Toggle Bar chọn loại giao dịch (`animated_toggle_bar.dart`)
```dart
SizedBox(
  height: 52,
  child: AppLiquidGlassIndicator(
    selectedIndex: widget.selectedIndex,
    count: widget.options.length,
    isDark: isDark,
    onChanged: widget.onChanged,
    borderRadius: 100,
    padding: const EdgeInsets.all(2),
    child: ClipRSuperellipse(
      borderRadius: BorderRadius.circular(98),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Xây dựng các nút nhấn Toggle...
        },
      ),
    ),
  ),
)
```

---

## 6. Sử dụng Widget dùng chung `AppLiquidGlass` cho hộp kính tĩnh (Glass Box Card)

Để áp dụng hiệu ứng kính lỏng lên các khối giao diện tĩnh khác một cách nhanh chóng (chẳng hạn như làm mờ thẻ Bento, các nút bấm độc lập, hoặc header), hãy sử dụng Widget dùng chung `AppLiquidGlass`:

```dart
import 'package:expense_management/shared/widgets/app_liquid_glass.dart';

// Ví dụ: Tạo một thẻ kính lỏng (Glass Box Card)
AppLiquidGlass(
  borderRadius: 24.0, // Bo góc Squircle tự động
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      Text('Số dư khả dụng'),
      Text('\$1,250.00'),
    ],
  ),
)
```

### Các thuộc tính tùy biến chính của `AppLiquidGlass`:
- `borderRadius`: Bo góc của hộp kính (mặc định sử dụng hình siêu elip `LiquidRoundedSuperellipse` 16.0).
- `glassColor`: Tự động thích ứng với chế độ Sáng/Tối nếu không truyền vào.
- `lightIntensity`: Tự động căn chỉnh độ tương phản rìa sáng cho chế độ Sáng/Tối.
- `padding` / `margin`: Điều chỉnh khoảng cách bên trong/bên ngoài hộp.
