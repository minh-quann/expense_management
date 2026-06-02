# Hướng Dẫn Sử Dụng AppLiquidGlassButton

**Đường dẫn file:** `lib/shared/widgets/liquid_glass/app_liquid_glass_button.dart`

`AppLiquidGlassButton` là một nút bấm mang tính tương tác vật lý cực kỳ cao. Nó không chỉ là một khối kính tĩnh, mà khi người dùng tác động vật lý (chạm, kéo), nó sẽ biến dạng mềm dẻo như một khối thạch (Jelly / Liquid).

## 1. Tính Năng Cốt Lõi

- **Vật lý biến dạng (Squash & Stretch):** Tự động bóp méo (stretch) khi người dùng kéo ngón tay trên nút.
- **Hệ thống Lò Xo (Spring Simulation):** Tính toán lực cản, vận tốc và động lượng để đưa nút trở về trạng thái gốc bằng hiệu ứng nảy (bounce) y như ngoài đời thực.
- **Phản hồi ánh sáng (Glow):** Bề mặt kính sẽ tự động ánh lên (phản quang) dọc theo hướng ngón tay người dùng chạm vào.

## 2. API & Thuộc Tính

| Thuộc tính | Kiểu dữ liệu | Mô tả | Mặc định |
|---|---|---|---|
| `child` | `Widget` | Nội dung bên trong nút. | **(Bắt buộc)** |
| `onTap` | `VoidCallback?` | Hàm gọi khi người dùng nhấn nút. | `null` |
| `onLongPress`| `VoidCallback?` | Hàm gọi khi người dùng nhấn giữ. | `null` |
| `stretch` | `double` | Cường độ dãn nở. Càng cao thì nút càng dễ bị méo khi kéo. | `1.2` |
| `interactionScale`| `double` | Tỉ lệ phóng to/thu nhỏ nút khi nhấn xuống. | `0.95` |
| `resistance` | `double` | Lực cản của ma sát. (Cao hơn = khó kéo dãn hơn). | `0.08` |
| `glowIntensity`| `double` | Cường độ phát sáng phản hồi chạm. | `0.4` |

## 3. Cơ Chế Hoạt Động (Dưới góc độ kỹ thuật)

1. **Ghi nhận sự kiện:** Tích hợp một bộ lắng nghe `Listener` để phân tích `PointerDown`, `PointerMove`, `PointerUp`.
2. **Tính toán gia tốc:** Khi `PointerMove` xảy ra, gia tốc ngón tay (`velocity`) và độ dời (`offset`) sẽ được chuyển qua hàm `_applyResistance` để tính ra số pixel thực tế bị kéo dãn.
3. **Mô phỏng lò xo:** Ở sự kiện `PointerUp`, hệ thống sẽ kích hoạt 2 bộ mô phỏng vật lý `SpringSimulation` độc lập (trục X và Y) để giảm chấn tự nhiên. 

## 4. Ví Dụ Cách Dùng

### Nút Bấm Có Mức Độ Dãn Cao (Rất mềm)
```dart
AppLiquidGlassButton(
  stretch: 2.0,           // Kéo cực kỳ dãn
  interactionScale: 0.9,  // Lún sâu khi bấm
  onTap: () {
    print('Button Pressed!');
  },
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Text('Hold and Drag Me!', style: TextStyle(color: Colors.white)),
  ),
)
```
