# Hướng Dẫn Sử Dụng AppLiquidGlassMenu

**Đường dẫn file:** `lib/shared/widgets/liquid_glass/app_liquid_glass_menu.dart`

Đây là kiệt tác của toàn bộ hệ thống Kính Lỏng. `AppLiquidGlassMenu` cung cấp một Context Menu / Popup Menu nổi trên màn hình với hiệu ứng biến hình mượt mà và khả năng vuốt liền mạch cực kỳ cao cấp, học hỏi trực tiếp từ triết lý Native của iOS/Android.

## 1. Tính Năng Cốt Lõi (Độc Quyền)

- **Vuốt 1 chạm liền mạch (Global Seamless Drag):**
  - **Vấn đề thông thường:** Người dùng phải nhấn giữ nút -> Popup mở ra -> Nhấc ngón tay lên -> Nhấn chạm vào Menu để chọn.
  - **Giải pháp của AppLiquidGlassMenu:** Bắt gọn sự kiện toàn cục ngay từ khi mới ấn nút. Bạn có thể nhấn giữ nút, đợi Popup mở ra, rồi **giữ nguyên ngón tay và kéo thẳng sang Menu** để chọn luôn mục mong muốn, sau đó thả tay để kích hoạt. 
- **Vật lý thời gian thực:** Áp dụng toàn bộ hiệu ứng biến dạng (Squash & Stretch) và bộ mô phỏng lò xo giảm chấn y hệt như `AppLiquidGlassButton` vào thao tác kéo menu (Dù bạn kéo bằng ngón tay bắt đầu từ bên ngoài menu).
- **Auto Adjust Bound:** Tự động phát hiện mép màn hình để đẩy Menu lại vào trong vùng an toàn (Safe Area), không bao giờ bị cắt xén (clip).

## 2. API & Thuộc Tính

| Thuộc tính | Kiểu dữ liệu | Mô tả |
|---|---|---|
| `trigger` | `Widget?` | Widget hiển thị làm nút kích hoạt Menu. |
| `items` | `List<Widget>` | Danh sách các `AppLiquidGlassMenuItem`. |
| `menuAlignment` | `GlassMenuAlignment?` | Vị trí bung ra của Menu (VD: topLeft, bottomCenter). Tự động tính toán nếu để null. |
| `menuWidth` | `double` | Độ rộng của Popup (Mặc định: 220). |
| `stretch` | `double` | Cường độ dãn nở vật lý của menu khi bị kéo đi. |
| `onClose` | `VoidCallback?` | Hook được gọi sau khi đóng menu. |

## 3. Kiến trúc Vuốt Liền Mạch (Global Drag System)

Widget này vượt qua giới hạn của Flutter bằng cách sử dụng thủ thuật:
1. Đặt một `Listener` khổng lồ bao bọc cả Nút Trigger và Overlay của Menu.
2. Dùng biến trạng thái `_isGlobalDrag` để đánh dấu một chuỗi thao tác bắt nguồn từ nút kích hoạt.
3. Liên tục dịch ngược toạ độ toàn cầu của ngón tay (`globalToLocal`) vào toạ độ nội bộ của Menu để tính toán Hover Index.
4. Áp dụng toán học dời hình để gán giá trị độ trễ (stretch offset) vào thẻ `RawLiquidStretch` bên trong Menu Overlay.

## 4. Ví Dụ Cách Dùng

```dart
AppLiquidGlassMenu(
  trigger: Icon(Icons.more_horiz),
  items: [
    AppLiquidGlassMenuItem(
      title: 'Chỉnh sửa',
      icon: Icons.edit,
      onTap: () => editTask(),
    ),
    AppLiquidGlassMenuDivider(),
    AppLiquidGlassMenuItem(
      title: 'Xoá vĩnh viễn',
      isDestructive: true,
      icon: Icons.delete_forever,
      onTap: () => deleteTask(),
    ),
  ],
)
```
