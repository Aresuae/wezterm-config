local wezterm = require('wezterm')
local platform = require('utils.platform')()
local backdrops = require('utils.backdrops')
local act = wezterm.action

-- 个人代理端口（仅在本地使用）
local PROXY_PORT = '2080'

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'F5',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },

   -- custom commands --
   {
      key = 'F6',
      mods = 'NONE',
      action = act.InputSelector({
         title = 'Quick Commands',
          choices = {
             { label = 'Set Proxy (Windows)', id = 'proxy-win' },
             { label = 'Set Proxy (Linux)', id = 'proxy-linux' },
             { label = 'Agent Update', id = 'agent' },
          },
          action = wezterm.action_callback(function(window, pane, id)
             if id == 'proxy-win' then
                pane:send_text('$env:http_proxy="http://127.0.0.1:' .. PROXY_PORT .. '"; $env:HTTP_PROXY=$env:http_proxy; $env:https_proxy="http://127.0.0.1:' .. PROXY_PORT .. '"; $env:HTTPS_PROXY=$env:https_proxy; $env:no_proxy="localhost,127.0.0.1"; $env:NO_PROXY=$env:no_proxy\r')
             elseif id == 'proxy-linux' then
                pane:send_text('export http_proxy="http://127.0.0.1:' .. PROXY_PORT .. '"\rexport HTTP_PROXY="$http_proxy"\rexport https_proxy="http://127.0.0.1:' .. PROXY_PORT .. '"\rexport HTTPS_PROXY="$https_proxy"\rexport no_proxy="localhost,127.0.0.1,.local"\rexport NO_PROXY="$no_proxy"\r')
             elseif id == 'agent' then
                pane:send_text('claude update; npm upgrade -g opencode-ai; npm upgrade -g @openai/codex; npm upgrade -g @google/gemini-cli\r')
             end
          end),
      }),
   },
   {
      key = 'u',
      mods = mod.SUPER,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- cursor movement --
   { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\x1bOH' },
   { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\x1bOF' },
   { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\x15' },

   -- copy/paste --
   { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },
   { key = 'Insert',     mods = 'SHIFT',       action = act.PasteFrom('PrimarySelection') },

   -- tabs --
   -- tabs: spawn+close
   { key = 'Enter',      mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
   { key = 't',          mods = mod.SUPER_REV, action = act.SpawnTab('DefaultDomain') },
   { key = 'w',          mods = mod.SUPER,     action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
    { key = 'h',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
    { key = 'l',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
    { key = 'h',          mods = mod.SUPER .. '|SHIFT', action = act.MoveTabRelative(-1) },
    { key = 'l',          mods = mod.SUPER .. '|SHIFT', action = act.MoveTabRelative(1) },

   -- window --
   -- spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   -- background controls --
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   {
      key = [[,]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_back(window)
      end),
   },
   {
      key = [[.]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_forward(window)
      end),
   },
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = 'Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            ---@diagnostic disable-next-line: param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },

   -- panes --
   -- 左右分屏（竖线分开，新窗格在右侧）
   {
      key = [[\]],
      mods = mod.SUPER,
      action = act.SplitPane({
         direction = 'Right',
         size = { Percent = 50 },
      }),
   },
   -- 上下分屏（横线分开，新窗格在下方）
   {
      key = [[\]],
      mods = mod.SUPER_REV,
      action = act.SplitPane({
         direction = 'Down',
         size = { Percent = 50 },
      }),
   },
   -- 一键左右两列
   {
      key = '2',
      mods = mod.SUPER .. '|SHIFT',
      action = act.SplitPane({
         direction = 'Right',
         size = { Percent = 50 },
      }),
   },
   -- 一键三等分竖屏（对应你图里三列布局）
   {
      key = '3',
      mods = mod.SUPER .. '|SHIFT',
      action = wezterm.action_callback(function(window, pane)
         local tab = window:mux_window():active_tab()
         pane:split({ direction = 'Right', size = { Percent = 66 } })
         tab:active_pane():split({ direction = 'Right', size = { Percent = 50 } })
      end),
   },

    -- panes: close pane
    { key = 'x', mods = mod.SUPER_REV, action = act.CloseCurrentPane({ confirm = true }) },
    -- panes: zoom pane
    { key = 'z', mods = mod.SUPER, action = act.TogglePaneZoomState },
   -- 当前窗格拖成独立新窗口（WezTerm 不支持鼠标拖拽，用快捷键代替）
   {
      key = 'd',
      mods = mod.SUPER_REV,
      action = wezterm.action_callback(function(_window, pane)
         pane:move_to_new_window()
      end),
   },
   -- 当前窗格移到新标签页
   {
      key = 'd',
      mods = mod.SUPER .. '|SHIFT',
      action = wezterm.action_callback(function(_window, pane)
         pane:move_to_new_tab()
      end),
   },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
   -- 方向键调整分屏大小（类似拖拽，步进 5 格）
   { key = 'LeftArrow',  mods = mod.SUPER .. '|SHIFT', action = act.AdjustPaneSize({ 'Left', 5 }) },
   { key = 'RightArrow', mods = mod.SUPER .. '|SHIFT', action = act.AdjustPaneSize({ 'Right', 5 }) },
   { key = 'UpArrow',    mods = mod.SUPER .. '|SHIFT', action = act.AdjustPaneSize({ 'Up', 5 }) },
   { key = 'DownArrow',  mods = mod.SUPER .. '|SHIFT', action = act.AdjustPaneSize({ 'Down', 5 }) },
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

    -- scrollback
    { key = 'PageUp',   mods = 'SHIFT', action = act.ScrollByPage(-0.5) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(0.5) },

    -- fonts: resize
    { key = 'UpArrow',    mods = mod.SUPER_REV,     action = act.IncreaseFontSize },
    { key = 'DownArrow',  mods = mod.SUPER_REV,     action = act.DecreaseFontSize },
    { key = 'r',          mods = mod.SUPER_REV,     action = act.ResetFontSize },

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
          timeout_milliseconds = 1000,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timeout_milliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- 右键弹出操作菜单（WezTerm 无系统级右键菜单，用选择器模拟）
   {
      event = { Down = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = wezterm.action_callback(function(window, pane)
         local has_selection = window:get_selection_text_for_pane(pane) ~= ''
         local choices = {
            { label = '左右分屏', id = 'split_right' },
            { label = '上下分屏', id = 'split_down' },
            { label = '关闭当前窗格', id = 'close_pane' },
            { label = '窗格 → 独立新窗口', id = 'new_window' },
            { label = '窗格 → 新标签页', id = 'new_tab' },
            { label = '随机壁纸', id = 'backdrop' },
         }
         if has_selection then
            table.insert(choices, 1, { label = '复制选中', id = 'copy' })
         else
            table.insert(choices, 1, { label = '粘贴', id = 'paste' })
         end

         window:perform_action(
            act.InputSelector({
               title = '窗格操作',
               choices = choices,
               action = wezterm.action_callback(function(win, p, id)
                  if id == 'paste' then
                     win:perform_action(act.PasteFrom('Clipboard'), p)
                  elseif id == 'copy' then
                     win:perform_action(act.CopyTo('Clipboard'), p)
                     win:perform_action(act.ClearSelection, p)
                  elseif id == 'split_right' then
                     p:split({ direction = 'Right', size = { Percent = 50 } })
                  elseif id == 'split_down' then
                     p:split({ direction = 'Down', size = { Percent = 50 } })
                  elseif id == 'close_pane' then
                     win:perform_action(act.CloseCurrentPane({ confirm = true }), p)
                  elseif id == 'new_window' then
                     p:move_to_new_window()
                  elseif id == 'new_tab' then
                     p:move_to_new_tab()
                  elseif id == 'backdrop' then
                     backdrops:random(win)
                  end
               end),
            }),
            pane
         )
      end),
   },
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   leader = { key = 'Space', mods = mod.SUPER_REV },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
