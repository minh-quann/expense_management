# Hướng Dẫn Sử Dụng AppLiquidGlass

**Đường dẫn file:** `lib/shared/widgets/liquid_glass/app_liquid_glass.dart`

`AppLiquidGlass` là Container cơ bản để tạo hiệu ứng Kính Lỏng (Liquid Glass / Glassmorphism) cho bất kỳ Widget nào bên trong nó. Nó xử lý toàn bộ các thao tác render nặng nề như tính toán khúc xạ ánh sáng (refraction), bóng mờ (blur), và viền ánh sáng (highlights).

## 1. Tính Năng Cốt Lõi

- **Hiệu ứng khúc xạ thực tế:** Không chỉ làm mờ (blur) thông thường, widget này bẻ cong ánh sáng đi qua nó dựa vào độ dày (thickness) và hệ số khúc xạ (refractiveIndex).
- **Tự động tương thích Dark/Light Mode:** Cường độ sáng và độ phản chiếu môi trường được tính toán tự động dựa trên giao diện hệ thống.
- **Tối ưu hóa GPU (Auto-tuning):** Tự động tắt hiệu ứng shader (chuyển sang trạng thái tĩnh) khi màn hình đang có hoạt ảnh chuyển trang (Route Transitions). Điều này ngăn ngừa tình trạng rớt frame (drop FPS).

## 2. API & Thuộc Tính

| Thuộc tính | Kiểu dữ liệu | Mô tả | Mặc định |
|---|---|---|---|
| `child` | `Widget` | Nội dung nằm trên mặt kính. | **(Bắt buộc)** |
| `borderRadius` | `double` | Độ bo góc của tấm kính (Sử dụng Superellipse). | `16.0` |
| `refractiveIndex` | `double` | Chỉ số khúc xạ. Càng cao ánh sáng càng bị bẻ cong mạnh. | `1.21` |
| `thickness` | `double` | Độ dày của kính. | `30.0` |
| `blur` | `double` | Cường độ làm mờ Gaussian nền. | `10.0` |
| `saturation` | `double` | Độ bão hoà màu của nền phía sau tấm kính. | `1.5` |
| `glassColor` | `Color?` | Màu nhuộm của kính. Tự động tính toán nếu để null. | `null` |
| `showGlow` | `bool` | Bật/tắt hiệu ứng phản hồi phát sáng khi người dùng chạm vào (Cần có GestureDetector). | `false` |

## 3. Ví Dụ Cách Dùng

### Basic Card
```dart
AppLiquidGlass(
  blur: 15.0,
  thickness: 25.0,
  child: Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Text('Thẻ Kính Lỏng', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        Text('Nội dung thẻ...'),
      ],
    ),
  ),
)
```

### Tuỳ biến hình dáng (Shape)
```dart
AppLiquidGlass(
  shape: LiquidRoundedSuperellipse(
    borderRadius: 100.0, // Bo tròn hoàn toàn
  ),
  child: Icon(Icons.home),
)
```

## 4. Lưu Ý Quan Trọng Về Hiệu Suất
- Không nên dùng `AppLiquidGlass` bên trong một `ListView` hoặc `GridView` có hàng trăm phần tử, vì Shader rất tốn kém tài nguyên render.
- Nếu bạn cần nhiều phần tử kính lỏng nằm gần nhau, hãy bọc chúng trong một thẻ `InheritedLiquidGlass` để gộp chung context render lại với nhau.
