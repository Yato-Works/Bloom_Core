# Bloom Core 拡張機能実装完了 Walkthrough

## 1. 概要
ユーザーからの要望に基づき、Bloom Core に以下の3大コアフィーチャーを完全実装・ビルド（Qt 6.11.1 + MinGW 13.1.0）しました：

1. **仮想デスクトップ切り替え機構の完全配線と直感的な API 化**
2. **Win+Ctrl 長押し／押下によるディム（Hold-to-Arm）の Core ファーストクラス機能化**
3. **Linux 風の「上下左右から何かを出せる」エッジパネル機構 (`Bloom.EdgePanel` / `Bloom.DimOverlay`) の新設**

---

## 2. 実装した主要機能と変更詳細

### (1) 仮想デスクトップ切り替えの完全配線と API 強化
- [`Win32WorkspaceBackend.cpp`](file:///C:/Users/smily/Bloom_Core/src/platforms/windows/Win32WorkspaceBackend.cpp):
  - 低レベルキーボードフック（`GlobalHotkeyService`）からの `Ctrl+Win+Left`、`Ctrl+Win+Right`、`Ctrl+Win+1..9` のシグナル（`switchPrevRequested`, `switchNextRequested`, `jumpRequested`）を `WorkspaceController` へ完全に配線。
  - `ShortcutWorkspaceSwitcher`, `ExperimentalWorkspaceSwitcher` の初期化および `WorkspaceService::startTracking()` を実行。
- [`WorkspaceModel.h`](file:///C:/Users/smily/Bloom_Core/src/core/models/WorkspaceModel.h) / [`.cpp`](file:///C:/Users/smily/Bloom_Core/src/core/models/WorkspaceModel.cpp):
  - `Workspace.currentWorkspace` (int)
  - `Workspace.workspaceCount` (int)
  - `Workspace.isSwitching` (bool)
  - `Workspace.list` (QVariantList: `{ id, name, active }`)
  - `Workspace.switchTo(int)`
  - `Workspace.switchNext()`
  - `Workspace.switchPrevious()`
  を QML Singleton `import Bloom; Workspace.*` として直接利用可能に。

### (2) Win+Ctrl ディム（Hold-to-Arm）の Core ファーストクラス化
- [`IPlatformBackend.h`](file:///C:/Users/smily/Bloom_Core/src/platforms/include/IPlatformBackend.h):
  - `isArmed()`, `isLocked()`, `dimOpacity()` 仮想関数および `shellArmedChanged`, `shellLockedChanged`, `dimOpacityChanged` シグナルを追加。
- [`WindowsPlatformBackend.h`](file:///C:/Users/smily/Bloom_Core/src/platforms/windows/WindowsPlatformBackend.h) / [`.cpp`](file:///C:/Users/smily/Bloom_Core/src/platforms/windows/WindowsPlatformBackend.cpp):
  - `m_shellController` の状態変化をインターフェース経由で Core に中継。
- [`BloomEngine.h`](file:///C:/Users/smily/Bloom_Core/src/core/runtime/BloomEngine.h) / [`.cpp`](file:///C:/Users/smily/Bloom_Core/src/core/runtime/BloomEngine.cpp):
  - `Core.armed`, `Core.locked`, `Core.dimOpacity` プロパティおよび `Core.toggleLock()`, `Core.showLauncher()`, `Core.armPermanent(bool)` メソッドを QML にエクスポート。
- [`qml/DimOverlay.qml`](file:///C:/Users/smily/Bloom_Core/qml/DimOverlay.qml) (`Bloom.DimOverlay`):
  - Win+Ctrl が押されたときに滑らかに減光（ディム）し、背景クリックガードや解除をハンドリングする正規コンポーネントを新設。

### (3) 上下左右エッジパネル機構 (`Bloom.EdgePanel`)
- [`qml/EdgePanel.qml`](file:///C:/Users/smily/Bloom_Core/qml/EdgePanel.qml) (`Bloom.EdgePanel`):
  - Linux (Wayland Layer Shell / Quickshell / AGS) のように、画面端からシュッと引き出すパネルを数行で定義可能に。
  - **プロパティ**:
    - `edge`: `"top"` | `"bottom"` | `"left"` | `"right"`
    - `panelThickness`: パネルの太さ（高さまたは幅）
    - `revealOnArm`: Win+Ctrl（ディム時）に自動で開く（デフォルト: `true`）
    - `revealOnEdgeHover`: 画面端にマウスを寄せた時に自動で開く（デフォルト: `true`）
    - `edgeZoneThickness`: 端の反応ストリップ幅（デフォルト: `12px`）
    - `autoCloseDelay`: マウスが離れてから閉じるまでの猶予ミリ秒（デフォルト: `280ms`）
    - `pinned`: ピン留め固定
    - `opened`: プログラム開閉（`open()`, `close()`, `toggle()`, `togglePin()`）
    - スムーズな Bezier / Spring カーブによるスライドイン/アウトアニメーション。
    - `default property alias contentData` により、内側に任意の UI（ボタン、ドック、グラフ、プレイヤー）をそのまま配置可能。

### (4) リファレンスシェルへの統合 (`qml/demo/DefaultShell.qml`)
- [`qml/demo/DefaultShell.qml`](file:///C:/Users/smily/Bloom_Core/qml/demo/DefaultShell.qml):
  - `DimOverlay`: Win+Ctrl での滑らかな減光背景。
  - `EdgePanel` (Top): 画面上部のステータスバー ＆ 仮想デスクトップ切り替え（`‹ 1 2 3 4 5 ›`）。
  - `EdgePanel` (Left): 画面左端のクイックランチャー＆ロックドック。
  - `EdgePanel` (Bottom): 画面下部のメディアプレイヤー＆リアルタイムWASAPIオーディオスペクトラム。
  - ホバーでも、Win+Ctrl アームでも、ピン留めでも自在に引き出せるリッチなデモに進化。

---

## 3. ビルド結果
- **ツールチェーン**: MinGW 13.1.0 + Qt 6.11.1
- **ビルドステータス**: `code 0` (完全成功)
- **成果物**: `C:\Users\smily\Bloom_Core\build-mingw\BloomCore.exe` (windeployqt 展開済み)
