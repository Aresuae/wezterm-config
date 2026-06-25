# WezTerm 个人配置

基于 [little3tar/wezterm](https://github.com/little3tar/wezterm) 定制，面向 **Windows** 日常使用：分屏、当前窗格高亮、右键操作菜单、动态壁纸。

## 特性

- **分屏**：左右 / 上下 / 一键两列 / 一键三列
- **焦点高亮**：非当前窗格自动变暗，鼠标移入切换焦点
- **右键菜单**：在终端区域右键弹出操作列表（粘贴、分屏、拆窗口等）
- **字体**：`Cascadia Mono` + `Microsoft YaHei`（无需额外安装 Maple Mono）
- **外观**：Catppuccin Mocha 配色 + 半透明动态背景
- **快捷键**：`Alt` 为主修饰键，避免与 Win 键冲突

## 快速安装

### 1. 安装 WezTerm

```powershell
winget install wez.wezterm
```

或从 [WezTerm Releases](https://github.com/wezterm/wezterm/releases) 下载。

### 2. 克隆配置

```powershell
# 备份旧配置（如有）
Rename-Item $env:USERPROFILE\.config\wezterm wezterm.bak -ErrorAction SilentlyContinue

# 克隆
git clone https://github.com/Aresuae/wezterm-config.git $env:USERPROFILE\.config\wezterm
```

### 3. 重载

打开 WezTerm，按 `Ctrl + Shift + R`，或重启终端。

## 常用操作

| 操作 | 方式 |
|------|------|
| 左右两列 | `Alt + \` 或 `Alt + Shift + 2` |
| 上下两行 | `Alt + Ctrl + \` |
| 三列 | `Alt + Shift + 3` |
| 切换窗格 | `Alt + Ctrl + H/J/K/L` |
| 窗格拆成独立窗口 | `Alt + Ctrl + D` |
| 调整分屏宽度 | 拖动紫色分隔线，或 `Alt + Shift + 方向键` |
| **右键菜单** | **在终端内松开右键** → ↑↓ 选择，Enter 确认 |

### 右键菜单项

- 粘贴 / 复制选中
- 左右分屏 / 上下分屏
- 关闭当前窗格
- 窗格 → 独立新窗口 / 新标签页
- 随机壁纸

> WezTerm **没有** Windows 那种图形化右键菜单，这里用「选择列表」模拟。鼠标**不能**把窗格拖成独立窗口，请用菜单或 `Alt + Ctrl + D`。

## 目录结构

```
wezterm/
├── wezterm.lua           # 主入口
├── config/
│   ├── appearance.lua    # 外观、背景
│   ├── panes.lua         # 分屏焦点高亮
│   ├── bindings.lua      # 快捷键 + 右键菜单
│   ├── fonts.lua         # 字体
│   ├── launch.lua        # 启动 Shell 菜单
│   └── domains.lua       # WSL/SSH（需自行创建，见 example）
├── events/               # 状态栏、标签标题
├── colors/custom.lua     # 配色
├── backdrops/            # 壁纸图片
└── KEYBINDINGS.md        # 完整快捷键文档
```

## 可选配置

### WSL / SSH

```powershell
Copy-Item config\domains.lua.example config\domains.lua
# 编辑 domains.lua 填入你的 WSL 发行版或 SSH 地址
```

### 换字体

编辑 `config/fonts.lua`，用 `wezterm ls-fonts --list-system` 查看本机可用字体。

## 快捷键文档

完整列表见 [KEYBINDINGS.md](./KEYBINDINGS.md)。

## 致谢

- [WezTerm](https://wezterm.org/)
- 配置基底：[little3tar/wezterm](https://github.com/little3tar/wezterm)
- [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)

## 许可证

MIT License
