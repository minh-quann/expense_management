# Hướng Dẫn Cốt Lõi Hệ Thống Liquid Glass (Kính Lỏng)

Thư mục `lib/shared/widgets/liquid_glass` chứa các widget UI cao cấp được thiết kế riêng cho ứng dụng, mang lại trải nghiệm thị giác (Glassmorphism) và xúc giác (Spring Physics) đẳng cấp.

Hệ thống được thiết kế để tự động tương thích với cả Light Mode và Dark Mode mà không cần cấu hình thủ công phức tạp.

---

## 1. `AppLiquidGlass` (Container Kính Lỏng Nhất Quán)
**File:** `app_liquid_glass.dart`

Đây là nền tảng cốt lõi của mọi hiệu ứng kính trong app. Widget này đóng vai trò như một `Container` nhưng được phủ lên lớp shader khúc xạ ánh sáng thực tế.

**Tính năng nổi bật:**
- Tự động quản lý hiệu suất (Performance Auto-tuning): Nhận diện khi ứng dụng đang chuyển trang (Route Transitions) để tạm dừng hiệu ứng shader, giúp tiết kiệm tài nguyên GPU và tránh giật lag.
- Nhận diện Theme (Light/Dark mode) thông minh để cân chỉnh cường độ sáng (`lightIntensity`) và độ phản chiếu môi trường (`ambientStrength`).

**Ví dụ sử dụng:**
```dart
AppLiquidGlass(
  blur: 10.0,
  thickness: 30.0,
  refractiveIndex: 1.21,
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Text('Nội dung trên nền kính lỏng'),
  ),
)
```

---

## 2. `AppLiquidGlassButton` (Nút Bấm Vật Lý Đàn Hồi)
**File:** `app_liquid_glass_button.dart`

Widget nút bấm mang lại cảm giác "sống động" như một khối thạch (Jelly).

**Tính năng nổi bật:**
- **Squash & Stretch (Biến dạng vật lý):** Thay vì chỉ chìm xuống khi nhấn như nút bấm thông thường, nút này cho phép người dùng nhấn giữ và **kéo ngón tay** để làm méo (stretch) nút theo hướng kéo.
- **Spring Simulation (Lò xo):** Khi thả tay ra, thuật toán vật lý `SpringSimulation` sẽ tính toán động lượng và trả nút về vị trí cũ với hiệu ứng rung lắc nhẹ cực kỳ chân thực.
- Hỗ trợ cả `onTap` và `onLongPress`.

---

## 3. `AppLiquidGlassMenu` (Context Menu Tràn Viền Liền Mạch)
**File:** `app_liquid_glass_menu.dart`

Đây là widget phức tạp và cao cấp nhất trong bộ công cụ, mô phỏng lại trải nghiệm Context Menu mượt mà của hệ điều hành iOS/Android gốc.

**Tính năng Độc Quyền (Seamless Global Drag):**
- **Vuốt 1 chạm liền mạch:** Người dùng nhấn giữ (Long Press) nút Trigger để mở Menu -> Menu bung ra -> Người dùng tiếp tục kéo ngón tay thẳng xuống Menu để bôi đen/chọn các mục -> Thả tay ra để thực thi lệnh. Tất cả chỉ trong 1 thao tác vuốt mà không bao giờ bị đứt đoạn.
- **Vật lý thời gian thực:** Cảm giác uốn dẻo (Morphing) vẫn được duy trì kể cả khi bạn thực hiện thao tác vuốt liền mạch nhờ vào bộ lắng nghe sự kiện toàn cục (`Global Listener`) tính toán gia tốc (velocity) và độ trễ (resistance) theo micro-giây.

**Ví dụ sử dụng:**
```dart
AppLiquidGlassMenu(
  trigger: Icon(Icons.more_vert),
  items: [
    AppLiquidGlassMenuItem(
      title: 'Tải lại dữ liệu',
      icon: Icons.refresh,
      onTap: () => reload(),
    ),
    AppLiquidGlassMenuDivider(),
    AppLiquidGlassMenuItem(
      title: 'Xoá toàn bộ',
      isDestructive: true,
      icon: Icons.delete,
      onTap: () => delete(),
    ),
  ],
)
```

---

## 4. `AppLiquidGlassSwitch` (Công Tắc Thủy Tinh)
**File:** `app_liquid_glass_switch.dart`

Một nút gạt (Switch) tối giản nhưng được phủ lớp kính lỏng cao cấp.

**Tính năng:**
- Tự động chuyển đổi màu track (nền rãnh trượt) thông minh: Màu trắng trong suốt mờ ảo khi ở Dark Mode và màu xám nhạt khi ở Light Mode.
- Hỗ trợ Haptics Feedback (Rung phản hồi xúc giác) tích hợp sẵn mỗi khi gạt công tắc.

## Lưu ý về Hiệu Suất (Performance Rules)
1. Tuyệt đối hạn chế việc lồng (nest) nhiều widget `AppLiquidGlass` vào nhau nếu không thực sự cần thiết vì các Shader khúc xạ ánh sáng rất tốn kém tài nguyên GPU.
2. Tránh sử dụng hiệu ứng này ở các danh sách cuộn (`ListView`, `GridView`) có quá nhiều phần tử phức tạp. Thay vào đó, hãy sử dụng `InheritedLiquidGlass` để gộp nhóm (group) layer lại với nhau nếu cần.
