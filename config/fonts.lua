local wezterm = require('wezterm')
local font_size = 12

-- Maple Mono NF CN 未安装时会反复报错，改用系统已有字体
return {
   font = wezterm.font_with_fallback({
      'Cascadia Mono',
      'JetBrains Mono',
      'Microsoft YaHei',
      'Consolas',
   }),
   font_size = font_size,

   -- Cascadia / JetBrains 通用连字，去掉 Maple 专用特性
   harfbuzz_features = {
      'calt',
      'liga',
      'zero',
   },

   freetype_load_target = 'Normal',
   freetype_render_target = 'Normal',
}
