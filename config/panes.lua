-- 分屏与当前窗格焦点相关配置
return {
   -- 鼠标移到窗格上即切换焦点（配合点击、拖拽分屏线）
   pane_focus_follows_mouse = true,

   -- 非当前窗格变暗：当前窗格保持全亮，对比更明显
   inactive_pane_hsb = {
      saturation = 0.55,
      brightness = 0.38,
   },
}
