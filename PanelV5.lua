--[[
    Yokatta Panel v4.6 (светлая, розовая, с мультяшными кошкой и мечом)
    Открытие/закрытие: M
    made by Hohoruno
]]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ALLOWED = {
	[3548844166] = true,   -- твой UserId
	[1884221246] = true,   -- друг 1
	[1508151580] = true, 
    [3027495927] = true,
    [352395] = true  -- друг 2
}

if not ALLOWED[Players.LocalPlayer.UserId] then
	warn("[Yokatta] Нет доступа")
	return
end
------------------------------------------------------------
-- КОНФИГ
------------------------------------------------------------
local CONFIG = {
	Title = "Yokatta",
	Credits = "made by Hohoruno",
	ToggleKey = Enum.KeyCode.M,
	CursorKey = Enum.KeyCode.LeftAlt, -- переключает «свободный курсор» / «камера у игры»
	TackleKey = Enum.KeyCode.F, -- клавиша Tackle Power (вкладка Utilities)
	LagGhostVisibleKey = nil, -- показать / скрыть призрака (убери строку, если не нужна)
    Tabs = { "Stats", "Utilities", "Esp", "AutoUse", "Troll", "Custom", "Settings" },
	Size = Vector2.new(620, 400),

	-- Если захочешь свои картинки: вставь сюда "rbxassetid://ЧИСЛО".
	-- Пока пусто — кошка и меч рисуются прямо из UI-элементов (ничего грузить не нужно).
	CatImage = "",
	SwordImage = "",
}

-- Розовая палитра
local C = {
	Bg = Color3.fromRGB(255, 241, 246),
	Sidebar = Color3.fromRGB(255, 228, 238),
	Header = Color3.fromRGB(250, 204, 224),
	HeaderLine = Color3.fromRGB(221, 132, 174),
	Accent = Color3.fromRGB(234, 150, 185),
	AccentStrong = Color3.fromRGB(200, 103, 159),
	TextDark = Color3.fromRGB(105, 32, 102),
	TextMid = Color3.fromRGB(173, 74, 141),
	Outline = Color3.fromRGB(105, 32, 102),
	Fur = Color3.fromRGB(255, 249, 243),
	Blush = Color3.fromRGB(255, 150, 185),
	Gold = Color3.fromRGB(255, 205, 100),
	-- ниже ключи для смены темы
	Card = Color3.fromRGB(255, 250, 252),
	TrackOff = Color3.fromRGB(232, 205, 220),
	Off = Color3.fromRGB(205, 170, 190),
	Close = Color3.fromRGB(226, 90, 130),
	Dot = Color3.fromRGB(226, 60, 120),
}

------------------------------------------------------------
-- УТИЛИТЫ
------------------------------------------------------------
local function tween(obj, props, time, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	return inst
end

local function corner(r)
	return create("UICorner", { CornerRadius = r or UDim.new(0, 8) })
end

local function round()
	return corner(UDim.new(0.5, 0))
end

local function stroke(thickness, color)
	return create("UIStroke", {
		Thickness = thickness or 2,
		Color = color or C.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function getGuiParent()
	local ok, ui = pcall(function()
		return (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if ok and ui then
		return ui
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

------------------------------------------------------------
-- МУЛЬТЯШНАЯ КОШКА (рисуется из Frame'ов)
------------------------------------------------------------
local function makeCat(parent, px, position, anchor)
	local root = create("Frame", {
		Name = "Cat",
		AnchorPoint = anchor or Vector2.new(0, 0),
		Position = position or UDim2.new(),
		Size = UDim2.fromOffset(px, px),
		BackgroundTransparency = 1,
	})
	root.Parent = parent

	if CONFIG.CatImage ~= "" then
		create("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = CONFIG.CatImage,
			ScaleType = Enum.ScaleType.Fit,
		}).Parent = root
		return root
	end

	-- уши
	for _, side in ipairs({ -1, 1 }) do
		local x = 0.5 + side * 0.28
		local ear = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, 0.25),
			Size = UDim2.fromScale(0.3, 0.3),
			Rotation = 45,
			BackgroundColor3 = C.Fur,
			ZIndex = 1,
		}, { corner(UDim.new(0, math.max(2, px * 0.04))), stroke(2) })
		ear.Parent = root

		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, 0.27),
			Size = UDim2.fromScale(0.15, 0.15),
			Rotation = 45,
			BackgroundColor3 = C.Blush,
			ZIndex = 2,
		}, { corner(UDim.new(0, 2)) }).Parent = root
	end

	-- голова
	local head = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.6),
		Size = UDim2.fromScale(0.88, 0.72),
		BackgroundColor3 = C.Fur,
		ZIndex = 3,
	}, { round(), stroke(2) })
	head.Parent = root

	-- полоски на лбу
	for i = -1, 1 do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5 + i * 0.09, 0.03),
			Size = UDim2.new(0.035, 0, 0.12, 0),
			BackgroundColor3 = C.Accent,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, { round() }).Parent = head
	end

	-- глаза
	for _, x in ipairs({ 0.3, 0.7 }) do
		local eye = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, 0.5),
			Size = UDim2.fromScale(0.13, 0.28),
			BackgroundColor3 = Color3.fromRGB(60, 20, 70),
			ZIndex = 4,
		}, { round() })
		eye.Parent = head
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.62, 0.3),
			Size = UDim2.fromScale(0.45, 0.28),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 5,
		}, { round() }).Parent = eye
	end

	-- щёчки
	for _, x in ipairs({ 0.15, 0.85 }) do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, 0.7),
			Size = UDim2.fromScale(0.14, 0.2),
			BackgroundColor3 = C.Blush,
			BackgroundTransparency = 0.35,
			ZIndex = 4,
		}, { round() }).Parent = head
	end

	-- носик
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.66),
		Size = UDim2.fromScale(0.08, 0.1),
		BackgroundColor3 = Color3.fromRGB(233, 110, 150),
		ZIndex = 5,
	}, { round() }).Parent = head

	-- ротик
	create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.8),
		Size = UDim2.fromScale(0.22, 0.2),
		BackgroundTransparency = 1,
		Text = "w",
		TextScaled = true,
		TextColor3 = Color3.fromRGB(60, 20, 70),
		Font = Enum.Font.GothamBold,
		ZIndex = 5,
	}).Parent = head

	-- усики
	for _, side in ipairs({ -1, 1 }) do
		for k = -1, 1 do
			create("Frame", {
				AnchorPoint = Vector2.new(side == -1 and 1 or 0, 0.5),
				Position = UDim2.fromScale(side == -1 and 0.1 or 0.9, 0.68 + k * 0.07),
				Size = UDim2.new(0.17, 0, 0, 2),
				Rotation = side * k * 12,
				BackgroundColor3 = C.Outline,
				BorderSizePixel = 0,
				ZIndex = 4,
			}).Parent = head
		end
	end

	return root
end

------------------------------------------------------------
-- МУЛЬТЯШНЫЙ МЕЧ (рисуется из Frame'ов)
------------------------------------------------------------
local function makeSword(parent, px, rotation, position, anchor)
	local root = create("Frame", {
		Name = "Sword",
		AnchorPoint = anchor or Vector2.new(0, 0),
		Position = position or UDim2.new(),
		Size = UDim2.fromOffset(px, px),
		Rotation = rotation or 0,
		BackgroundTransparency = 1,
	})
	root.Parent = parent

	if CONFIG.SwordImage ~= "" then
		create("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = CONFIG.SwordImage,
			ScaleType = Enum.ScaleType.Fit,
		}).Parent = root
		return root
	end

	-- рукоять
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.68),
		Size = UDim2.fromScale(0.1, 0.2),
		BackgroundColor3 = C.AccentStrong,
		ZIndex = 1,
	}, { corner(UDim.new(0, 3)), stroke(2) }).Parent = root

	-- навершие
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.92),
		Size = UDim2.fromScale(0.15, 0.15),
		BackgroundColor3 = C.Gold,
		ZIndex = 2,
	}, { round(), stroke(2) }).Parent = root

	-- клинок
	local blade = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.03),
		Size = UDim2.fromScale(0.17, 0.62),
		BackgroundColor3 = Color3.fromRGB(240, 246, 255),
		ZIndex = 2,
	}, { round(), stroke(2) })
	blade.Parent = root

	create("Frame", { -- блик
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.3, 0.12),
		Size = UDim2.fromScale(0.16, 0.6),
		BackgroundColor3 = Color3.fromRGB(195, 215, 248),
		BorderSizePixel = 0,
		ZIndex = 3,
	}, { round() }).Parent = blade

	-- гарда
	local guard = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.67),
		Size = UDim2.fromScale(0.5, 0.09),
		BackgroundColor3 = C.Gold,
		ZIndex = 4,
	}, { round(), stroke(2) })
	guard.Parent = root

	create("Frame", { -- камушек
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.16, 0.7),
		BackgroundColor3 = Color3.fromRGB(233, 110, 150),
		ZIndex = 5,
	}, { round() }).Parent = guard

	-- искорки
	for _, s in ipairs({ { 0.78, 0.12, 0.09 }, { 0.2, 0.3, 0.06 } }) do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(s[1], s[2]),
			Size = UDim2.fromScale(s[3], s[3]),
			Rotation = 45,
			BackgroundColor3 = C.Gold,
			ZIndex = 6,
		}, { corner(UDim.new(0, 1)) }).Parent = root
	end

	return root
end

------------------------------------------------------------
-- ОЧИСТКА СТАРОЙ ВЕРСИИ
------------------------------------------------------------
local parent = getGuiParent()
local old = parent:FindFirstChild("YokattaUI")
if old then
	old:Destroy()
end
local oldCursor = parent:FindFirstChild("YokattaCursor")
if oldCursor then
	oldCursor:Destroy()
end

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local Gui = create("ScreenGui", {
	Name = "YokattaUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})
Gui.Parent = parent

local Main = create("CanvasGroup", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(CONFIG.Size.X, CONFIG.Size.Y),
	BackgroundColor3 = C.Bg,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
}, {
	corner(UDim.new(0, 16)),
	create("UIStroke", { Color = C.HeaderLine, Thickness = 2, Transparency = 0.1 }),
})
local Scale = create("UIScale", { Scale = 0.85 })
Scale.Parent = Main
Main.Parent = Gui

------------------------------------------------------------
-- ШАПКА
------------------------------------------------------------
local HEADER_H = 54

local Header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, HEADER_H),
	BackgroundColor3 = C.Header,
	BorderSizePixel = 0,
	ZIndex = 2,
})
Header.Parent = Main

create("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 1, -2),
	BackgroundColor3 = C.HeaderLine,
	BorderSizePixel = 0,
	ZIndex = 3,
}).Parent = Header

makeCat(Header, 42, UDim2.fromOffset(12, 6))

create("TextLabel", {
	Name = "Title",
	Position = UDim2.fromOffset(64, 0),
	Size = UDim2.new(0, 110, 1, 0),
	BackgroundTransparency = 1,
	Text = CONFIG.Title,
	TextColor3 = C.TextDark,
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 3,
}).Parent = Header

makeSword(Header, 38, 35, UDim2.fromOffset(176, 8))

local CloseBtn = create("TextButton", {
	Name = "Close",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -14, 0.5, 0),
	Size = UDim2.fromOffset(30, 30),
	BackgroundColor3 = C.Accent,
	Text = "✕",
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = false,
	ZIndex = 4,
}, { corner(UDim.new(0, 9)) })
CloseBtn.Parent = Header

CloseBtn.MouseEnter:Connect(function()
	tween(CloseBtn, { BackgroundColor3 = C.Close }, 0.15)
end)
CloseBtn.MouseLeave:Connect(function()
	tween(CloseBtn, { BackgroundColor3 = C.Accent }, 0.15)
end)

------------------------------------------------------------
-- САЙДБАР
------------------------------------------------------------
local SIDEBAR_W = 152
local TAB_H = 36
local TAB_GAP = 4
local TAB_TOP = 14

local Sidebar = create("Frame", {
	Name = "Sidebar",
	Position = UDim2.fromOffset(0, HEADER_H),
	Size = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H),
	BackgroundColor3 = C.Sidebar,
	BorderSizePixel = 0,
})
Sidebar.Parent = Main

local Indicator = create("Frame", {
	Name = "Indicator",
	Size = UDim2.fromOffset(4, TAB_H - 12),
	Position = UDim2.fromOffset(0, TAB_TOP + 6),
	BackgroundColor3 = C.TextMid,
	BorderSizePixel = 0,
}, { corner(UDim.new(0, 2)) })
Indicator.Parent = Sidebar

create("TextLabel", {
	Name = "Credits",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, -8),
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1,
	Text = CONFIG.Credits,
	TextColor3 = C.TextMid,
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
}).Parent = Sidebar

------------------------------------------------------------
-- КОНТЕНТ / СТРАНИЦЫ
------------------------------------------------------------
local Content = create("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(SIDEBAR_W, HEADER_H),
	Size = UDim2.new(1, -SIDEBAR_W, 1, -HEADER_H),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
})
Content.Parent = Main

-- декор в углу: кошка + меч (полупрозрачно, под страницами)
local Deco = create("CanvasGroup", {
	Name = "Deco",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -8, 1, -8),
	Size = UDim2.fromOffset(170, 170),
	BackgroundTransparency = 1,
	GroupTransparency = 0.45,
	ZIndex = 0,
})
Deco.Parent = Content
makeSword(Deco, 150, 30, UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0.5))
makeCat(Deco, 105, UDim2.fromScale(0.42, 0.72), Vector2.new(0.5, 0.5))

local Pages = {}
local Holders = {}
local TabButtons = {}
local currentTab

local function createPage(name)
	local page = create("CanvasGroup", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 2,
	})
	page.Parent = Content

	local scroll = create("ScrollingFrame", {
		Name = "Holder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, {
		create("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 14),
		}),
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	scroll.Parent = page

	create("TextLabel", {
		Name = "PageTitle",
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = C.TextDark,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = scroll

	create("TextLabel", {
		Name = "Placeholder",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "Здесь пока пусто — скоро добавим функции",
		TextColor3 = C.TextMid,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = scroll

	Pages[name] = page
	Holders[name] = scroll
end

local tabToken = 0
local function selectTab(name)
	if currentTab == name then
		return
	end
	local prev = currentTab
	currentTab = name
	tabToken += 1
	local myToken = tabToken

	for tabName, btn in pairs(TabButtons) do
		local active = tabName == name
		tween(btn, {
			BackgroundTransparency = active and 0.1 or 1,
			TextColor3 = active and C.TextDark or C.TextMid,
		}, 0.2)
	end

	local btn = TabButtons[name]
	tween(Indicator, { Position = UDim2.fromOffset(0, btn.Position.Y.Offset + 6) }, 0.3, Enum.EasingStyle.Back)

	for pageName, page in pairs(Pages) do
		if pageName ~= prev and pageName ~= name then
			page.Visible = false
			page.GroupTransparency = 1
		end
	end

	if prev then
		local oldPage = Pages[prev]
		local t = tween(oldPage, { GroupTransparency = 1 }, 0.12)
		t.Completed:Connect(function()
			if currentTab ~= prev then
				oldPage.Visible = false
			end
		end)
	end

	local page = Pages[name]
	page.Position = UDim2.fromOffset(14, 0)
	page.GroupTransparency = 1
	page.Visible = true
	task.delay(prev and 0.08 or 0, function()
		if tabToken ~= myToken then
			return
		end
		tween(page, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, 0.3, Enum.EasingStyle.Quint)
	end)
end

for i, name in ipairs(CONFIG.Tabs) do
	createPage(name)

	local btn = create("TextButton", {
		Name = name,
		Position = UDim2.fromOffset(12, TAB_TOP + (i - 1) * (TAB_H + TAB_GAP)),
		Size = UDim2.new(1, -24, 0, TAB_H),
		BackgroundColor3 = C.Accent,
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = C.TextMid,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		AutoButtonColor = false,
	}, { corner(UDim.new(0, 9)) })
	btn.Parent = Sidebar
	TabButtons[name] = btn

	btn.MouseEnter:Connect(function()
		if currentTab ~= name then
			tween(btn, { BackgroundTransparency = 0.6, TextColor3 = C.TextDark }, 0.15)
		end
	end)
	btn.MouseLeave:Connect(function()
		if currentTab ~= name then
			tween(btn, { BackgroundTransparency = 1, TextColor3 = C.TextMid }, 0.15)
		end
	end)
	btn.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
end

------------------------------------------------------------
-- ВКЛ / ВЫКЛ ВКЛАДОК (переключатели лежат в Settings)
------------------------------------------------------------
local TabEnabled = {}
for _, n in ipairs(CONFIG.Tabs) do
	TabEnabled[n] = true
end
local TabHooks = {} -- [имя вкладки] = функция, вызывается при отключении

local function layoutTabs()
	local idx = 0
	for _, name in ipairs(CONFIG.Tabs) do
		local btn = TabButtons[name]
		if btn then
			if TabEnabled[name] then
				btn.Visible = true
				btn.Position = UDim2.fromOffset(12, TAB_TOP + idx * (TAB_H + TAB_GAP))
				idx += 1
			else
				btn.Visible = false
			end
		end
	end
	local cb = currentTab and TabButtons[currentTab]
	if cb and TabEnabled[currentTab] then
		tween(Indicator, { Position = UDim2.fromOffset(0, cb.Position.Y.Offset + 6) }, 0.25)
	end
end

local function setTabEnabled(name, on)
	on = on and true or false
	if TabEnabled[name] == on then
		return
	end
	TabEnabled[name] = on
	if not on and TabHooks[name] then
		pcall(TabHooks[name])
	end
	layoutTabs()
	if not on and currentTab == name then
		for _, n in ipairs(CONFIG.Tabs) do
			if TabEnabled[n] then
				selectTab(n)
				break
			end
		end
	end
end

------------------------------------------------------------
-- ОТКРЫТИЕ / ЗАКРЫТИЕ
------------------------------------------------------------
local isOpen = false
local animToken = 0
local PanelScale = 1

-- СВОЙ КУРСОР: мордочка кошки, которая следует за мышью поверх всего.
-- Работает, даже если игра прячет или подменяет системный курсор.
local CursorGui = create("ScreenGui", {
	Name = "YokattaCursor",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 2147483647,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Enabled = false,
})
CursorGui.Parent = parent

local CursorHolder = create("Frame", {
	Name = "Cursor",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(28, 28),
	BackgroundTransparency = 1,
	Active = false,
})
CursorHolder.Parent = CursorGui
makeCat(CursorHolder, 28, UDim2.new())

-- маленькая точка в центре — это и есть точка клика
create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(4, 4),
	BackgroundColor3 = C.Dot,
	ZIndex = 20,
}, { round() }).Parent = CursorHolder

local cursorConn
local cursorMode = true -- true = свободный курсор (кликаем по панели), false = камера у игры
local applied = nil -- что сейчас применено: "cursor" / "game"

-- подсказка в сайдбаре
local ModeHint = create("TextLabel", {
	Name = "ModeHint",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, -30),
	Size = UDim2.new(1, 0, 0, 18),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = C.TextMid,
	Font = Enum.Font.Gotham,
	TextSize = 11,
})
ModeHint.Parent = Sidebar

local function updateHint()
	local keyName = CONFIG.CursorKey.Name
	if cursorMode then
		ModeHint.Text = keyName .. " — вернуть камеру"
	else
		ModeHint.Text = keyName .. " — включить курсор"
	end
end

local GameState = { icon = nil, behavior = nil } -- что хочет сама игра

local function applyGameControl(holdingRMB)
	-- отдаём мышь и камеру игре
	if applied ~= "game" then
		applied = "game"
		CursorGui.Enabled = false
		if GameState.icon ~= nil then
			UIS.MouseIconEnabled = GameState.icon
		end
		if GameState.behavior ~= nil then
			UIS.MouseBehavior = GameState.behavior
		end
	else
		-- пока игра рулит сама — запоминаем её состояние
		-- (при зажатой ПКМ не запоминаем: там временная блокировка мыши)
		if not holdingRMB then
			GameState.icon = UIS.MouseIconEnabled
			GameState.behavior = UIS.MouseBehavior
		end
	end
end

local function applyFreeCursor()
	if applied ~= "cursor" then
		applied = "cursor"
		CursorGui.Enabled = true
	end
	UIS.MouseIconEnabled = false -- прячем системный, рисуем свой
	if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
	local pos = UIS:GetMouseLocation()
	CursorHolder.Position = UDim2.fromOffset(pos.X, pos.Y)
end

local function setCursorMode(on)
	cursorMode = on
	updateHint()
end

local function freeCursor()
	GameState.icon = UIS.MouseIconEnabled
	GameState.behavior = UIS.MouseBehavior
	applied = nil
	if cursorConn then
		cursorConn:Disconnect()
	end
	updateHint()
	cursorConn = RunService.RenderStepped:Connect(function()
		-- пока зажата ПКМ — камера у игры (можно крутить мышью как обычно)
		local holdingRMB = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		if cursorMode and not holdingRMB then
			applyFreeCursor()
		else
			applyGameControl(holdingRMB)
		end
	end)
end

local restoreToken = 0

local function restoreCursor()
	if cursorConn then
		cursorConn:Disconnect()
		cursorConn = nil
	end
	applied = nil
	CursorGui.Enabled = false

	local icon, behavior = GameState.icon, GameState.behavior
	if icon == nil then
		icon = true
	end
	if behavior == nil or behavior == Enum.MouseBehavior.LockCurrentPosition then
		behavior = Enum.MouseBehavior.Default -- временную блокировку от ПКМ не возвращаем
	end

	-- возвращаем состояние игры и ~0.5 сек подряд закрепляем его,
	-- чтобы камера гарантированно снова начала крутиться
	restoreToken += 1
	local my = restoreToken
	local t0 = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if my ~= restoreToken or isOpen or os.clock() - t0 > 0.5 then
			conn:Disconnect()
			return
		end
		UIS.MouseIconEnabled = icon
		UIS.MouseBehavior = behavior
	end)
end

-- переключение «курсор / камера» клавишей
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or Gui:GetAttribute("BindListening") then
		return
	end
	if isOpen and input.KeyCode == CONFIG.CursorKey then
		setCursorMode(not cursorMode)
	end
end)

local function openPanel()
	if isOpen then
		return
	end
	isOpen = true
	animToken += 1
	freeCursor()
	Main.Visible = true
	tween(Scale, { Scale = PanelScale }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tween(Main, { GroupTransparency = 0 }, 0.25)
end

local function closePanel()
	if not isOpen then
		return
	end
	isOpen = false
	animToken += 1
	restoreCursor()
	local my = animToken
	tween(Scale, { Scale = 0.88 * PanelScale }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local t = tween(Main, { GroupTransparency = 1 }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	t.Completed:Connect(function()
		if animToken == my and not isOpen then
			Main.Visible = false
		end
	end)
end

local function togglePanel()
	if isOpen then
		closePanel()
	else
		openPanel()
	end
end

local function setPanelScale(v)
	PanelScale = math.clamp(v, 0.5, 1.6)
	if isOpen then
		tween(Scale, { Scale = PanelScale }, 0.15)
	end
end

CloseBtn.MouseButton1Click:Connect(closePanel)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or Gui:GetAttribute("BindListening") then
		return
	end
	if input.KeyCode == CONFIG.ToggleKey then
		togglePanel()
	end
end)

------------------------------------------------------------
-- ПЕРЕТАСКИВАНИЕ (за шапку)
------------------------------------------------------------
do
	local dragging, dragStart, startPos

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if
			dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

------------------------------------------------------------
-- СОХРАНЕНИЕ НАСТРОЕК
------------------------------------------------------------
local HttpService = game:GetService("HttpService")

local Persist = {
	File = "Yokatta_" .. tostring(Players.LocalPlayer.UserId) .. ".json",
	AutoSave = true,
	RestoreSwitches = false, -- восстанавливать ли вкл/выкл функций при запуске
	Loading = false,
	List = {},
	Counter = {},
	SectionOf = {},
	LastJson = nil,
	-- эти переключатели НЕ восстанавливаются, пока не включено «Запоминать вкл/выкл»
	SwitchLabels = {},
	SwitchSections = { ["МНОЖИТЕЛИ"] = true, ["TROLL PACK: РЕЖИМЫ"] = true },
}
for _, n in ipairs({
	"M1 Speed", "Удалять выбранные кулдауны", "Tackle Power", "Magnet (коллайдер мяча)", "Lock-On",
	"Esp (подсветка + скиллы)", "Предикция мяча", "Метка LastVector3 (сфера)", "Свой FOV и зум",
	"Кошка над выбранными игроками",
	"Auto Dribble", "Auto M1 Tackle", "Auto Slide Tackle", "Auto Shot", "Auto ES / BHT",
	"Auto Defence Skills", "Auto Goal", "Auto Call Pass", "Auto Dive",
	"Spin (крутиться)", "Эмоуты по кругу", "Своя анимация (по ID)", "Следовать за игроком",
	"Мяч крутится вокруг тебя", "Free Cam", "Spectate",
}) do
	Persist.SwitchLabels[n] = true
end

local function pageHolderOf(holder)
	local cur = holder
	while cur do
		if cur:IsA("ScrollingFrame") and cur.Name == "Holder" then
			return cur
		end
		cur = cur.Parent
	end
end

-- стабильный id: вкладка / секция / названия фолдаутов / секция группы / подпись (+#n при повторе)
function Persist.idFor(holder, label)
	local root = pageHolderOf(holder)
	local parts = { root and root.Parent and root.Parent.Name or "?" }
	if root then
		parts[#parts + 1] = Persist.SectionOf[root] or ""
	end
	local chain = {}
	local cur = holder
	while cur and cur ~= root do
		local name = cur:GetAttribute("PName")
		if not name and cur:IsA("Frame") and cur.Parent then
			for _, sib in ipairs(cur.Parent:GetChildren()) do
				if sib:IsA("TextButton") and sib.LayoutOrder == cur.LayoutOrder - 1 then
					local sTxt, sOrig = sib.Text, sib:GetAttribute("YKOrig")
					if sOrig and sTxt == sib:GetAttribute("YKTr") then sTxt = sOrig end
					name = sTxt:match("^%S+%s+(.+)$") -- «▸ Название» -> «Название»
					break
				end
			end
		end
		if name then
			table.insert(chain, 1, name)
		end
		cur = cur.Parent
	end
	for _, n in ipairs(chain) do
		parts[#parts + 1] = n
	end
	if holder ~= root then
		parts[#parts + 1] = Persist.SectionOf[holder] or ""
	end
	parts[#parts + 1] = label
	local base = table.concat(parts, "/")
	local n = (Persist.Counter[base] or 0) + 1
	Persist.Counter[base] = n
	return n > 1 and (base .. "#" .. n) or base
end

-- kind: "toggle" | "slider" | "choice" | "text" | "bind" | "data"
function Persist.addId(id, kind, get, set, label, section)
	table.insert(Persist.List, { id = id, kind = kind, get = get, set = set, label = label, section = section })
end

function Persist.add(holder, label, kind, get, set)
	Persist.addId(Persist.idFor(holder, label), kind, get, set, label, Persist.SectionOf[holder])
end

function Persist.snapshot()
	local values = {}
	for _, rec in ipairs(Persist.List) do
		local ok, v = pcall(rec.get)
		if ok then
			if rec.kind == "bind" then
				values[rec.id] = v and v.Name or false
			elseif v ~= nil then
				values[rec.id] = v
			end
		end
	end
	return { version = 1, meta = { restoreSwitches = Persist.RestoreSwitches }, values = values }
end

function Persist.save(force)
	if Persist.Loading or not writefile then
		return
	end
	if not force and not Persist.AutoSave then
		return
	end
	local ok, json = pcall(function()
		return HttpService:JSONEncode(Persist.snapshot())
	end)
	if not ok or (json == Persist.LastJson and not force) then
		return
	end
	Persist.LastJson = json
	pcall(writefile, Persist.File, json)
end

function Persist.load()
	if not (isfile and readfile) then
		return
	end
	local ok, data = pcall(function()
		if isfile(Persist.File) then
			return HttpService:JSONDecode(readfile(Persist.File))
		end
	end)
	if not ok or type(data) ~= "table" or type(data.values) ~= "table" then
		return
	end
	Persist.RestoreSwitches = type(data.meta) == "table" and data.meta.restoreSwitches == true
	Persist.Loading = true
	for _, rec in ipairs(Persist.List) do
		local v = data.values[rec.id]
		local skip = not Persist.RestoreSwitches
			and ((rec.kind == "toggle" and Persist.SwitchLabels[rec.label])
				or (rec.section and Persist.SwitchSections[rec.section]))
		if v ~= nil and not skip then
			pcall(function()
				if rec.kind == "bind" then
					local key = type(v) == "string" and Enum.KeyCode[v] or nil
					if rec.get() ~= key then
						rec.set(key)
					end
				elseif rec.kind == "data" then
					rec.set(v)
				elseif (rec.kind == "toggle" and type(v) == "boolean")
					or (rec.kind == "slider" and type(v) == "number")
					or (rec.kind == "text" and type(v) == "string")
					or rec.kind == "choice" then
					if rec.get() ~= v then
						rec.set(v)
					end
				end
			end)
		end
	end
	Persist.Loading = false
end

------------------------------------------------------------
-- КОМПОНЕНТЫ ДЛЯ ВКЛАДОК (Section / Note / Toggle / Choice / Slider / Button)
------------------------------------------------------------
local UI = {}

do
	local orderOf = {}

	local function nextOrder(holder)
		orderOf[holder] = (orderOf[holder] or 10) + 1
		return orderOf[holder]
	end

	local function card(holder, height)
		local f = create("Frame", {
			LayoutOrder = nextOrder(holder),
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = C.Card,
			BorderSizePixel = 0,
		}, {
			corner(UDim.new(0, 10)),
			create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
		})
		f.Parent = holder
		return f
	end

	UI.Card = card

	local function clearPlaceholder(holder)
		local ph = holder:FindFirstChild("Placeholder")
		if ph then
			ph:Destroy()
		end
	end
	UI.ClearPlaceholder = clearPlaceholder

	function UI.Section(holder, text)
		Persist.SectionOf[holder] = text
		local l = create("TextLabel", {
			LayoutOrder = nextOrder(holder),
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.TextMid,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		l.Parent = holder
		return l
	end

	function UI.Note(holder, text)
		local l = create("TextLabel", {
			LayoutOrder = nextOrder(holder),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = text,
			TextWrapped = true,
			TextColor3 = C.TextMid,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		l.Parent = holder
		return l
	end

	function UI.Toggle(holder, text, default, callback)
		local row = card(holder, 40)
		create("TextLabel", {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -80, 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		local track = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(44, 22),
			BackgroundColor3 = C.TrackOff,
			Text = "",
			AutoButtonColor = false,
		}, { round() })
		track.Parent = row

		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, { round() })
		knob.Parent = track

		local state = default and true or false
		local function render(animate)
			local pos = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			local col = state and C.AccentStrong or C.TrackOff
			if animate then
				tween(knob, { Position = pos }, 0.18)
				tween(track, { BackgroundColor3 = col }, 0.18)
			else
				knob.Position = pos
				track.BackgroundColor3 = col
			end
		end
		render(false)

		track.MouseButton1Click:Connect(function()
			state = not state
			render(true)
			if callback then
				callback(state)
			end
		end)

		local obj = {}
		function obj.Set(v, silent)
			state = v and true or false
			render(true)
			if not silent and callback then
				callback(state)
			end
		end
		function obj.Get()
			return state
		end
        		Persist.add(holder, text, "toggle", obj.Get, function(v) obj.Set(v) end)
		return obj
	end

	-- options = { {значение, "Подпись"}, ... }
	function UI.Choice(holder, text, options, default, callback)
		local row = card(holder, 44)
		local boxW = #options * 88 - 4
		create("TextLabel", {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -(boxW + 30), 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		local box = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(boxW, 28),
			BackgroundTransparency = 1,
		}, {
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		box.Parent = row

		local current = default
		local buttons = {}
		local function render()
			for value, btn in pairs(buttons) do
				local on = value == current
				tween(btn, {
					BackgroundColor3 = on and C.AccentStrong or C.Sidebar,
					TextColor3 = on and Color3.new(1, 1, 1) or C.TextMid,
				}, 0.15)
			end
		end

		for i, opt in ipairs(options) do
			local btn = create("TextButton", {
				LayoutOrder = i,
				Size = UDim2.fromOffset(84, 28),
				BackgroundColor3 = C.Sidebar,
				Text = opt[2],
				TextColor3 = C.TextMid,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = box
			buttons[opt[1]] = btn
			btn.MouseButton1Click:Connect(function()
				if current == opt[1] then
					return
				end
				current = opt[1]
				render()
				if callback then
					callback(current)
				end
			end)
		end
		render()

		local obj = {}
		function obj.Set(v, silent)
			current = v
			render()
			if not silent and callback then
				callback(current)
			end
		end
		function obj.Get()
			return current
		end
        		Persist.add(holder, text, "choice", obj.Get, function(v) obj.Set(v) end)
		return obj
	end

	-- слайдер + поле для точного числа (в поле можно ввести значение выше максимума слайдера)
	function UI.Slider(holder, text, min, max, default, decimals, callback)
		local row = card(holder, 62)
		create("TextLabel", {
			Position = UDim2.fromOffset(14, 6),
			Size = UDim2.new(1, -110, 0, 24),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		local box = create("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 6),
			Size = UDim2.fromOffset(72, 24),
			BackgroundColor3 = C.Sidebar,
			Text = "",
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ClearTextOnFocus = false,
		}, { corner(UDim.new(0, 7)) })
		box.Parent = row

		local track = create("Frame", {
			Position = UDim2.new(0, 14, 0, 45),
			Size = UDim2.new(1, -28, 0, 6),
			BackgroundColor3 = C.TrackOff,
		}, { round() })
		track.Parent = row

		local fill = create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = C.AccentStrong,
		}, { round() })
		fill.Parent = track

		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
		}, { round(), stroke(2, C.AccentStrong) })
		knob.Parent = track

		local hit = create("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 16, 0, 28),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 3,
		})
		hit.Parent = track

		local mult = 10 ^ (decimals or 2)
		local function roundv(v)
			return math.floor(v * mult + 0.5) / mult
		end

		local value = roundv(default)
		local function render()
			local a = math.clamp((value - min) / (max - min), 0, 1)
			fill.Size = UDim2.fromScale(a, 1)
			knob.Position = UDim2.fromScale(a, 0.5)
			box.Text = tostring(roundv(value))
		end
		render()

		local function set(v, silent)
			value = roundv(v)
			render()
			if not silent and callback then
				callback(value)
			end
		end

		local dragging = false
		local function fromInput(input)
			local a = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			set(min + (max - min) * a)
		end

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				fromInput(input)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if
				dragging
				and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			then
				fromInput(input)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		box.FocusLost:Connect(function()
			local n = tonumber(box.Text)
			if n then
				set(math.max(min, n))
			else
				render()
			end
		end)

		local obj = {}
		function obj.Set(v, silent)
			set(v, silent)
		end
		function obj.Get()
			return value
		end
        		Persist.add(holder, text, "slider", obj.Get, function(v) obj.Set(v) end)
		return obj
	end

	-- группа: контейнер, в который можно добавлять строки позже (порядок сохраняется)
	function UI.Group(holder)
		local g = create("Frame", {
			LayoutOrder = nextOrder(holder),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		g.Parent = holder
		return g
	end

	-- поле ввода текста. callback(text, enterPressed): если вернёт true — поле очищается
	function UI.TextInput(holder, text, default, placeholder, callback)
		local row = card(holder, 44)
		create("TextLabel", {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -190, 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		local box = create("TextBox", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(160, 28),
			BackgroundColor3 = C.Sidebar,
			Text = default or "",
			PlaceholderText = placeholder or "",
			PlaceholderColor3 = C.TextMid,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ClearTextOnFocus = false,
		}, { corner(UDim.new(0, 8)) })
		box.Parent = row

		box.FocusLost:Connect(function(enterPressed)
			if callback and callback(box.Text, enterPressed) == true then
				box.Text = ""
			end
		end)

		local obj = {}
		function obj.Set(v, silent)
			box.Text = v
			if not silent and callback then
				callback(box.Text, false)
			end
		end
		function obj.Get()
			return box.Text
		end
		Persist.add(holder, text, "text", obj.Get, function(v) obj.Set(v) end)
		return obj
	end

	function UI.Button(holder, text, callback)
		local b = create("TextButton", {
			LayoutOrder = nextOrder(holder),
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = C.Accent,
			Text = text,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			AutoButtonColor = false,
		}, { corner(UDim.new(0, 10)) })
		b.Parent = holder
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundColor3 = C.AccentStrong }, 0.15)
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundColor3 = C.Accent }, 0.15)
		end)
		b.MouseButton1Click:Connect(function()
			if callback then
				callback()
			end
		end)
		return b
	end
    	-- строка выбора клавиши: get() -> KeyCode|nil, set(KeyCode|nil). opts.noClear = нельзя очистить
	local bindListening
	UIS.InputBegan:Connect(function(input)
		local l = bindListening
		if not l or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		bindListening = nil
		local key = input.KeyCode
		if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
			if not l.noClear then
				l.set(nil)
			end
		elseif key ~= Enum.KeyCode.Unknown then
			l.set(key)
		end
		l.render()
		task.delay(0.1, function()
			if not bindListening then
				Gui:SetAttribute("BindListening", nil)
			end
		end)
	end)

	function UI.BindRow(holder, text, get, set, opts)
		opts = opts or {}
		local row = card(holder, 40)
		create("TextLabel", {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -140, 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		local btn = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(110, 28),
			BackgroundColor3 = C.Sidebar,
			Text = "",
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			AutoButtonColor = false,
		}, { corner(UDim.new(0, 8)) })
		btn.Parent = row

		local function render()
			local k = get()
			btn.Text = k and k.Name or "—"
		end
		render()

		btn.MouseButton1Click:Connect(function()
			if bindListening then
				bindListening.render()
			end
			bindListening = { set = set, render = render, noClear = opts.noClear }
			Gui:SetAttribute("BindListening", true)
			btn.Text = "Нажми клавишу…"
		end)

		Persist.add(holder, text, "bind", get, function(k)
			set(k)
			render()
		end)
		return render
	end
end

------------------------------------------------------------
-- LAG GHOST (ядро; включён всегда, без GUI)
--   режим "server"  - где тебя видит сервер (задержка = пинг/2)
--   режим "players" - где тебя видят другие игроки (пинг + интерполяция на их стороне)
-- Настройки — во вкладке Settings. Для других скриптов: shared.LagGhost.CFrame
------------------------------------------------------------
local LagGhost = {}

do
	local LocalPlayer = Players.LocalPlayer
	local StatsService = game:GetService("Stats")

	local GHOST_NAME = "lagghost"
	local GHOST_TRANSPARENCY = 0.5
	local GHOST_COLOR = Color3.fromRGB(80, 170, 255)
	local GHOST_MATERIAL = Enum.Material.ForceField

	-- "none" | "movement" | "character"
	local ROTATION_MODE = "character"

	-- пинг
	local PING_SOURCE = "auto" -- "auto" | "data" | "network"
	local PING_FALLBACK = 0.12
	local PING_MEDIAN = 7
	local PING_SMOOTH = 0.15
	local PING_MIN, PING_MAX = 0.0, 1.0

	-- ручные поправки (сек)
	local SERVER_OFFSET = 0
	local PLAYERS_OFFSET = 0

	-- состояние (меняется из Settings)
	local mode = "players" -- по умолчанию: как видят игроки
	local visible = false -- по умолчанию: невидим
	local interp = 0.1 -- задержка интерполяции чужих персонажей

	local character = LocalPlayer.Character
	local ghost = nil
	local ghostParts = {}
	local lastPos = nil
	local lastYaw = 0
	local lastTarget = 0

	local function fireChange()
		if LagGhost.OnChange then
			LagGhost.OnChange()
		end
	end

	---------------------------------------------------------------------
	-- пинг
	---------------------------------------------------------------------
	local pingSec = PING_FALLBACK
	local pingReady = false
	local window = {}
	local lastDelay = 0

	local function readData()
		local ok, ms = pcall(function()
			return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and type(ms) == "number" and ms > 0 then
			return ms / 1000
		end
		return nil
	end

	local function readNetwork()
		local ok, s = pcall(function()
			return LocalPlayer:GetNetworkPing()
		end)
		if ok and type(s) == "number" and s > 0 then
			return s * 2
		end
		return nil
	end

	local function sampleRTT()
		if PING_SOURCE == "network" then
			return readNetwork() or readData()
		end
		return readData() or readNetwork()
	end

	local function median(list)
		local copy = table.clone(list)
		table.sort(copy)
		return copy[math.ceil(#copy / 2)]
	end

	local function updatePing()
		local s = sampleRTT()
		if not s then
			return
		end
		s = math.clamp(s, PING_MIN, PING_MAX)

		window[#window + 1] = s
		if #window > PING_MEDIAN then
			table.remove(window, 1)
		end

		local m = median(window)
		if not pingReady then
			pingSec = m
			pingReady = true
		else
			pingSec = pingSec + (m - pingSec) * PING_SMOOTH
		end
	end

	local function currentDelay()
		local d
		if mode == "server" then
			d = pingSec * 0.5 + SERVER_OFFSET
		else
			d = pingSec + interp + PLAYERS_OFFSET
		end
		return math.max(0, d)
	end

	---------------------------------------------------------------------
	-- история позиций
	---------------------------------------------------------------------
	local history = {}
	local first, last = 1, 0
	local KEEP = 2.5 -- сек истории (с запасом на макс. пинг + интерполяцию)

	local function clearHistory()
		history = {}
		first, last = 1, 0
	end

	local function record(t, cf)
		last += 1
		history[last] = { t = t, cf = cf }

		while first < last and history[first + 1].t < t - KEEP do
			history[first] = nil
			first += 1
		end

		if first > 512 then
			local fresh = {}
			for i = first, last do
				fresh[#fresh + 1] = history[i]
			end
			history = fresh
			first, last = 1, #fresh
		end
	end

	local function sampleHistory(target)
		if last < first then
			return nil
		end
		if target >= history[last].t then
			return history[last].cf
		end
		if target <= history[first].t then
			return history[first].cf
		end

		for i = last - 1, first, -1 do
			local a = history[i]
			if a.t <= target then
				local b = history[i + 1]
				local span = b.t - a.t
				if span <= 1e-6 then
					return b.cf
				end
				return a.cf:Lerp(b.cf, (target - a.t) / span)
			end
		end
		return history[first].cf
	end

	---------------------------------------------------------------------
	-- призрак
	---------------------------------------------------------------------
	local function getGhostCFrame(cf)
		local pos = cf.Position

		if ROTATION_MODE == "character" then
			local look = cf.LookVector
			if Vector3.new(look.X, 0, look.Z).Magnitude > 0.05 then
				lastYaw = math.atan2(-look.X, -look.Z)
			end
		elseif ROTATION_MODE == "movement" then
			if lastPos then
				local delta = Vector3.new(pos.X - lastPos.X, 0, pos.Z - lastPos.Z)
				if delta.Magnitude > 0.05 then
					lastYaw = math.atan2(-delta.X, -delta.Z)
				end
			end
		else
			lastYaw = 0
		end

		lastPos = pos
		return CFrame.new(pos) * CFrame.Angles(0, lastYaw, 0)
	end

	local function setNeutralPose(model)
		local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		local joints = {}
		for _, inst in ipairs(model:GetDescendants()) do
			if inst:IsA("JointInstance") and inst.Part0 and inst.Part1 then
				if inst:IsA("Motor6D") then
					inst.Transform = CFrame.new()
				end
				joints[inst.Part0] = joints[inst.Part0] or {}
				table.insert(joints[inst.Part0], inst)
			end
		end

		local visited = { [root] = true }
		local function build(part0)
			for _, joint in ipairs(joints[part0] or {}) do
				local part1 = joint.Part1
				if not visited[part1] then
					visited[part1] = true
					part1.CFrame = part0.CFrame * joint.C0 * joint.C1:Inverse()
					build(part1)
				end
			end
		end
		build(root)
	end

	local function applyVisibility()
		for _, part in ipairs(ghostParts) do
			if part.Parent then
				part.Transparency = visible and GHOST_TRANSPARENCY or 1
			end
		end
	end

	local JUNK = {
		"Script", "LocalScript", "ModuleScript", "Animator", "Humanoid",
		"BillboardGui", "SurfaceGui", "ParticleEmitter", "Trail", "Beam",
		"PointLight", "SpotLight", "SurfaceLight", "Sound", "Decal", "Texture",
		"Fire", "Smoke", "Sparkles", "ForceField", "Highlight",
		"Shirt", "Pants", "ShirtGraphic", "BodyColors", "CharacterMesh",
	}

	local function createGhost()
		if ghost then
			ghost:Destroy()
			ghost = nil
		end
		ghostParts = {}

		if not character then
			return
		end

		local oldArchivable = character.Archivable
		character.Archivable = true
		local clone = character:Clone()
		character.Archivable = oldArchivable
		if not clone then
			return
		end

		clone.Name = GHOST_NAME

		for _, inst in ipairs(clone:GetDescendants()) do
			for _, className in ipairs(JUNK) do
				if inst:IsA(className) then
					inst:Destroy()
					break
				end
			end
		end

		for _, inst in ipairs(clone:GetDescendants()) do
			if inst:IsA("BasePart") then
				inst.Anchored = true
				inst.CanCollide = false
				inst.CanTouch = false
				inst.CanQuery = false
				inst.CastShadow = false
				if inst.Name == "HumanoidRootPart" then
					inst.Transparency = 1
				else
					inst.Color = GHOST_COLOR
					inst.Material = GHOST_MATERIAL
					if inst:IsA("MeshPart") then
						inst.TextureID = ""
					end
					table.insert(ghostParts, inst)
				end
			elseif inst:IsA("SpecialMesh") then
				inst.TextureId = ""
			end
		end

		local root = clone:FindFirstChild("HumanoidRootPart")
		if not root then
			clone:Destroy()
			return
		end
		clone.PrimaryPart = root

		setNeutralPose(clone)
		applyVisibility()

		clone.Parent = workspace
		ghost = clone
	end

	if character then
		createGhost()
	end

	---------------------------------------------------------------------
	-- запись и обновление
	---------------------------------------------------------------------
	RunService.Heartbeat:Connect(function()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			record(os.clock(), root.CFrame)
		end
	end)

	local pub = {} -- shared.LagGhost (одна и та же таблица, поля обновляются)
	shared.LagGhost = pub

	RunService.RenderStepped:Connect(function()
		local now = os.clock()
		updatePing()

		if not ghost then
			return
		end

		local delay = currentDelay()
		lastDelay = delay
		local target = math.max(now - delay, lastTarget)
		lastTarget = target

		local cf = sampleHistory(target)
		if not cf then
			return
		end

		local ghostCF = getGhostCFrame(cf)
		ghost:PivotTo(ghostCF)

		pub.Mode = mode
		pub.Delay = delay
		pub.Ping = pingSec
		pub.CFrame = ghostCF
	end)

	LocalPlayer.CharacterAdded:Connect(function(newChar)
		character = newChar
		clearHistory()
		lastTarget = 0
		lastPos = nil
		lastYaw = 0
		task.spawn(function()
			newChar:WaitForChild("HumanoidRootPart", 10)
			if character == newChar then
				createGhost()
			end
		end)
	end)

	-- горячие клавиши (необязательные, см. CONFIG)
	UIS.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if CONFIG.LagGhostVisibleKey and input.KeyCode == CONFIG.LagGhostVisibleKey then
			LagGhost.SetVisible(not visible)
		end
	end)

	---------------------------------------------------------------------
	-- API для вкладки Settings
	---------------------------------------------------------------------
	function LagGhost.SetMode(m)
		if m ~= "server" and m ~= "players" then
			return
		end
		mode = m
		lastTarget = 0
		fireChange()
	end
	function LagGhost.GetMode()
		return mode
	end

	function LagGhost.SetVisible(v)
		visible = v and true or false
		applyVisibility()
		fireChange()
	end
	function LagGhost.GetVisible()
		return visible
	end

	function LagGhost.SetInterp(v)
		interp = math.clamp(v, 0, 1)
		lastTarget = 0
		fireChange()
	end
	function LagGhost.GetInterp()
		return interp
	end

	-- возвращает: пинг (сек), текущая задержка призрака (сек)
	function LagGhost.GetInfo()
		return pingSec, lastDelay
	end
end

local StatsAPI = { values = {}, touched = {} } -- общее состояние Stats (используют другие вкладки)

------------------------------------------------------------
-- ВКЛАДКА STATS
------------------------------------------------------------
do
	local LocalPlayer = Players.LocalPlayer
	local h = Holders.Stats

	if h then
		UI.ClearPlaceholder(h)

		local STATS = {
			{ key = "SpeedMultiplier", label = "Speed", max = 10 },
			{ key = "JumpMultiplier", label = "Jump", max = 10 },
			{ key = "FlowMultiplier", label = "Flow", max = 100 },
			{ key = "PowerMultiplier", label = "Power", max = 50 },
		}

		local function setPlayerInfoValue(valueName, newValue)
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local folder = char:WaitForChild("PlayerInfo", 5)
			if not folder then
				warn("PlayerInfo not found")
				return
			end

			local value = folder:FindFirstChild(valueName)
			if value then
				value.Value = newValue
			else
				warn("Value not found:", valueName)
			end
		end

		local values = StatsAPI.values
		local touched = StatsAPI.touched -- что менял пользователь (только это применяем заново после респауна)
		local sliders = {}

		UI.Section(h, "МНОЖИТЕЛИ")

		for _, st in ipairs(STATS) do
			values[st.key] = 1
			sliders[st.key] = UI.Slider(h, st.label, 0, st.max, 1, 2, function(v)
				values[st.key] = v
				touched[st.key] = true
				task.spawn(setPlayerInfoValue, st.key, v)
			end)
		end

		UI.Button(h, "Сбросить всё на 1", function()
			for _, st in ipairs(STATS) do
				sliders[st.key].Set(1, true)
				values[st.key] = 1
				touched[st.key] = true
				task.spawn(setPlayerInfoValue, st.key, 1)
			end
		end)

		UI.Note(
			h,
			"Значение применяется сразу при изменении. Точное число можно ввести в поле справа (можно больше максимума слайдера). После респауна заново применяются только те значения, которые ты менял."
		)

		LocalPlayer.CharacterAdded:Connect(function()
			for key in pairs(touched) do
				task.spawn(setPlayerInfoValue, key, values[key])
			end
		end)
	end
end

------------------------------------------------------------
-- ВНЕШНИЙ ВИД: ТЕМЫ, РАЗМЕР, ЯЗЫКИ, CREDITS
------------------------------------------------------------
local Look = { Theme = "pink", Lang = "ru" }
do
	local function rgb(r, g, b)
		return Color3.fromRGB(r, g, b)
	end

	--------------------------------------------------------
	-- ТЕМЫ
	--------------------------------------------------------
	local THEME_ORDER = { "pink", "black", "yellow", "red", "white", "gray", "purple" }
	local KEYS = { "Bg", "Sidebar", "Header", "HeaderLine", "Accent", "AccentStrong", "TextDark", "TextMid", "Card", "TrackOff", "Off", "Close", "Dot" }
	local THEMES = {
		pink = { name = "Розовая", swatch = rgb(234, 150, 185),
			Bg = rgb(255, 241, 246), Sidebar = rgb(255, 228, 238), Header = rgb(250, 204, 224), HeaderLine = rgb(221, 132, 174),
			Accent = rgb(234, 150, 185), AccentStrong = rgb(200, 103, 159), TextDark = rgb(105, 32, 102), TextMid = rgb(173, 74, 141),
			Card = rgb(255, 250, 252), TrackOff = rgb(232, 205, 220), Off = rgb(205, 170, 190), Close = rgb(226, 90, 130), Dot = rgb(226, 60, 120) },
		black = { name = "Чёрная", swatch = rgb(28, 28, 34),
			Bg = rgb(18, 18, 22), Sidebar = rgb(27, 27, 33), Header = rgb(36, 36, 44), HeaderLine = rgb(92, 92, 112),
			Accent = rgb(66, 66, 84), AccentStrong = rgb(112, 112, 156), TextDark = rgb(238, 238, 244), TextMid = rgb(158, 158, 176),
			Card = rgb(34, 34, 41), TrackOff = rgb(58, 58, 70), Off = rgb(88, 88, 100), Close = rgb(170, 60, 75), Dot = rgb(255, 90, 130) },
		yellow = { name = "Жёлтая", swatch = rgb(244, 201, 60),
			Bg = rgb(255, 250, 224), Sidebar = rgb(255, 242, 186), Header = rgb(252, 226, 120), HeaderLine = rgb(204, 160, 24),
			Accent = rgb(244, 201, 60), AccentStrong = rgb(186, 132, 0), TextDark = rgb(74, 54, 0), TextMid = rgb(135, 100, 10),
			Card = rgb(255, 254, 244), TrackOff = rgb(236, 224, 176), Off = rgb(204, 190, 140), Close = rgb(214, 120, 20), Dot = rgb(230, 90, 20) },
		red = { name = "Красная", swatch = rgb(214, 50, 50),
			Bg = rgb(255, 238, 238), Sidebar = rgb(255, 222, 222), Header = rgb(246, 176, 176), HeaderLine = rgb(204, 62, 62),
			Accent = rgb(236, 112, 112), AccentStrong = rgb(186, 32, 32), TextDark = rgb(96, 14, 14), TextMid = rgb(166, 48, 48),
			Card = rgb(255, 250, 250), TrackOff = rgb(240, 208, 208), Off = rgb(205, 165, 165), Close = rgb(150, 20, 20), Dot = rgb(255, 50, 50) },
		white = { name = "Белая", swatch = rgb(250, 250, 252),
			Bg = rgb(255, 255, 255), Sidebar = rgb(242, 244, 248), Header = rgb(230, 233, 240), HeaderLine = rgb(186, 192, 208),
			Accent = rgb(200, 206, 224), AccentStrong = rgb(78, 90, 128), TextDark = rgb(28, 30, 40), TextMid = rgb(98, 104, 124),
			Card = rgb(250, 251, 253), TrackOff = rgb(214, 218, 228), Off = rgb(176, 182, 196), Close = rgb(220, 80, 90), Dot = rgb(230, 60, 80) },
		gray = { name = "Серая", swatch = rgb(140, 144, 152),
			Bg = rgb(222, 223, 227), Sidebar = rgb(204, 206, 212), Header = rgb(184, 187, 195), HeaderLine = rgb(118, 122, 134),
			Accent = rgb(150, 154, 166), AccentStrong = rgb(82, 86, 100), TextDark = rgb(32, 34, 42), TextMid = rgb(76, 80, 94),
			Card = rgb(236, 237, 240), TrackOff = rgb(176, 179, 188), Off = rgb(150, 153, 162), Close = rgb(176, 70, 80), Dot = rgb(214, 60, 80) },
		purple = { name = "Пурпурная", swatch = rgb(145, 90, 215),
			Bg = rgb(244, 236, 255), Sidebar = rgb(231, 217, 252), Header = rgb(206, 182, 246), HeaderLine = rgb(130, 86, 202),
			Accent = rgb(170, 130, 232), AccentStrong = rgb(118, 68, 190), TextDark = rgb(48, 20, 92), TextMid = rgb(104, 64, 166),
			Card = rgb(251, 247, 255), TrackOff = rgb(218, 205, 240), Off = rgb(184, 168, 210), Close = rgb(190, 70, 150), Dot = rgb(220, 60, 170) },
	}

	local PROPS = {
		Frame = { "BackgroundColor3" },
		CanvasGroup = { "BackgroundColor3" },
		TextLabel = { "BackgroundColor3", "TextColor3" },
		TextButton = { "BackgroundColor3", "TextColor3" },
		TextBox = { "BackgroundColor3", "TextColor3", "PlaceholderColor3" },
		ScrollingFrame = { "BackgroundColor3", "ScrollBarImageColor3" },
		ImageLabel = { "BackgroundColor3", "ImageColor3" },
		ImageButton = { "BackgroundColor3", "ImageColor3" },
		UIStroke = { "Color" },
	}
	-- эти объекты не перекрашиваются (кошка, меч, образцы цветов тем)
	local SKIP = { Cat = true, Sword = true, Swatch = true }

	local function ckey(c)
		return math.floor(c.R * 255 + 0.5) * 65536 + math.floor(c.G * 255 + 0.5) * 256 + math.floor(c.B * 255 + 0.5)
	end

	local function skipped(inst, root)
		local p = inst
		while p and p ~= root do
			if SKIP[p.Name] then
				return true
			end
			p = p.Parent
		end
		return false
	end

	local function recolor(root, map)
		for _, inst in ipairs(root:GetDescendants()) do
			local props = PROPS[inst.ClassName]
			if props and not skipped(inst, root) then
				for _, p in ipairs(props) do
					local nv = map[ckey(inst[p])]
					if nv then
						inst[p] = nv
					end
				end
			end
		end
	end

	function Look.SetTheme(code)
		local t = THEMES[code]
		if not t or code == Look.Theme then
			return
		end
		local map = {}
		for _, k in ipairs(KEYS) do
			local o, n = C[k], t[k]
			if o ~= n then
				local key = ckey(o)
				if map[key] == nil then
					map[key] = n
				end
			end
		end
		for _, k in ipairs(KEYS) do
			C[k] = t[k]
		end
		C.Outline = t.TextDark
		Look.Theme = code
		recolor(Gui, map)
		recolor(CursorGui, map)
		if Look.OnTheme then
			Look.OnTheme()
		end
	end

	--------------------------------------------------------
	-- ПЕРЕВОДЫ (порядок колонок: en zh ja ko es fr de pt it; ru — оригинал)
	--------------------------------------------------------
	local CODES = { "ru", "en", "zh", "ja", "ko", "es", "fr", "de", "pt", "it" }
	local DICT, PFX, PAT = {}, {}, {}
	for _, c in ipairs(CODES) do
		DICT[c] = {}
	end

	-- R: ключ = русский оригинал, дальше 9 переводов
	local function R(key, ...)
		local v = { ... }
		DICT.ru[key] = key
		for i = 1, 9 do
			DICT[CODES[i + 1]][key] = v[i]
		end
	end
	-- E: ключ любой (напр. английский), дальше 10 значений, включая русский
	local function E(key, ...)
		local v = { ... }
		for i = 1, 10 do
			DICT[CODES[i]][key] = v[i]
		end
	end
	-- P: префикс (текст, к которому в коде дописывают имя)
	local function P(key, ...)
		local v = { ... }
		local e = { key = key, ru = key }
		for i = 1, 9 do
			e[CODES[i + 1]] = v[i]
		end
		PFX[#PFX + 1] = e
	end
	-- T: шаблон (Lua-pattern), перевод — строка для string.format
	local function T(pat, ...)
		local v = { ... }
		local e = { pat = pat }
		for i = 1, 9 do
			e[CODES[i + 1]] = v[i]
		end
		PAT[#PAT + 1] = e
	end

	-- вкладки
	E("Stats", "Статистика", "Stats", "统计", "統計", "통계", "Estadísticas", "Statistiques", "Statistiken", "Estatísticas", "Statistiche")
	E("Utilities", "Утилиты", "Utilities", "工具", "ユーティリティ", "유틸리티", "Utilidades", "Utilitaires", "Werkzeuge", "Utilitários", "Utilità")
	E("AutoUse", "Авто-действия", "Auto Use", "自动使用", "オート使用", "자동 사용", "Uso automático", "Utilisation auto", "Auto-Nutzung", "Uso automático", "Uso automatico")
	E("Troll", "Тролль", "Troll", "恶搞", "いたずら", "장난", "Bromas", "Farces", "Scherz", "Zoeira", "Scherzi")
	E("Custom", "Свои", "Custom", "自定义", "カスタム", "커스텀", "Personalizado", "Personnalisé", "Benutzerdef.", "Personalizado", "Personalizzato")
	E("Settings", "Настройки", "Settings", "设置", "設定", "설정", "Ajustes", "Paramètres", "Einstellungen", "Configurações", "Impostazioni")

	-- префиксы и шаблоны
	P("Вкладка ", "Tab ", "标签 ", "タブ ", "탭 ", "Pestaña ", "Onglet ", "Tab ", "Aba ", "Scheda ")
	P("Клавиша ", "Key ", "按键 ", "キー ", "키 ", "Tecla ", "Touche ", "Taste ", "Tecla ", "Tasto ")
	P("Цель: ", "Target: ", "目标：", "ターゲット: ", "대상: ", "Objetivo: ", "Cible : ", "Ziel: ", "Alvo: ", "Bersaglio: ")
	P("Режим: ", "Mode: ", "模式：", "モード: ", "모드: ", "Modo: ", "Mode : ", "Modus: ", "Modo: ", "Modalità: ")
	P("Файл: ", "File: ", "文件：", "ファイル: ", "파일: ", "Archivo: ", "Fichier : ", "Datei: ", "Arquivo: ", "File: ")
	T("^Пинг: (%d+) мс | задержка призрака: (%d+) мс$", "Ping: %s ms | ghost delay: %s ms", "延迟：%s 毫秒 | 幽灵延迟：%s 毫秒", "Ping: %s ms | ゴースト遅延: %s ms", "핑: %s ms | 고스트 지연: %s ms", "Ping: %s ms | retraso del fantasma: %s ms", "Ping : %s ms | délai du fantôme : %s ms", "Ping: %s ms | Geisterverzögerung: %s ms", "Ping: %s ms | atraso do fantasma: %s ms", "Ping: %s ms | ritardo del fantasma: %s ms")
	T("^(.+) — вернуть камеру$", "%s — return camera", "%s — 恢复相机", "%s — カメラに戻す", "%s — 카메라 복귀", "%s — devolver cámara", "%s — rendre la caméra", "%s — Kamera zurückgeben", "%s — devolver câmera", "%s — restituisci telecamera")
	T("^(.+) — включить курсор$", "%s — enable cursor", "%s — 启用光标", "%s — カーソルを有効化", "%s — 커서 켜기", "%s — activar cursor", "%s — activer le curseur", "%s — Cursor aktivieren", "%s — ativar cursor", "%s — attiva cursore")

	-- Settings
	R("LAG GHOST (работает всегда)", "LAG GHOST (always on)", "LAG GHOST（始终运行）", "LAG GHOST（常時動作）", "LAG GHOST (항상 작동)", "LAG GHOST (siempre activo)", "LAG GHOST (toujours actif)", "LAG GHOST (immer aktiv)", "LAG GHOST (sempre ativo)", "LAG GHOST (sempre attivo)")
	R("Режим призрака", "Ghost mode", "幽灵模式", "ゴーストモード", "고스트 모드", "Modo fantasma", "Mode fantôme", "Geistermodus", "Modo fantasma", "Modalità fantasma")
	R("Игроки", "Players", "玩家", "プレイヤー", "플레이어", "Jugadores", "Joueurs", "Spieler", "Jogadores", "Giocatori")
	R("Сервер", "Server", "服务器", "サーバー", "서버", "Servidor", "Serveur", "Server", "Servidor", "Server")
	R("Показывать призрака", "Show ghost", "显示幽灵", "ゴーストを表示", "고스트 표시", "Mostrar fantasma", "Afficher le fantôme", "Geist anzeigen", "Mostrar fantasma", "Mostra fantasma")
	R("Интерполяция игроков (сек)", "Player interpolation (sec)", "玩家插值（秒）", "プレイヤー補間（秒）", "플레이어 보간 (초)", "Interpolación de jugadores (s)", "Interpolation des joueurs (s)", "Spieler-Interpolation (Sek.)", "Interpolação de jogadores (s)", "Interpolazione giocatori (s)")
	R("ВКЛАДКИ", "TABS", "标签页", "タブ", "탭", "PESTAÑAS", "ONGLETS", "TABS", "ABAS", "SCHEDE")
	R("Отключённая вкладка только скрывается. Включённые в ней функции продолжают работать.", "A disabled tab is only hidden. Functions enabled in it keep working.", "停用的标签页仅被隐藏，其中已开启的功能仍会继续运行。", "無効にしたタブは非表示になるだけです。その中で有効な機能は動作し続けます。", "비활성화한 탭은 숨겨질 뿐이며, 그 안에서 켜 둔 기능은 계속 작동합니다.", "Una pestaña desactivada solo se oculta. Las funciones activadas en ella siguen funcionando.", "Un onglet désactivé est seulement masqué. Les fonctions qui y sont activées continuent de fonctionner.", "Ein deaktivierter Tab wird nur ausgeblendet. Darin aktivierte Funktionen laufen weiter.", "Uma aba desativada apenas fica oculta. As funções ativadas nela continuam funcionando.", "Una scheda disattivata viene solo nascosta. Le funzioni attivate al suo interno continuano a funzionare.")
	R("КЛАВИШИ ПАНЕЛИ", "PANEL KEYS", "面板按键", "パネルのキー", "패널 키", "TECLAS DEL PANEL", "TOUCHES DU PANNEAU", "PANEL-TASTEN", "TECLAS DO PAINEL", "TASTI DEL PANNELLO")
	R("Открыть / закрыть панель", "Open / close panel", "打开 / 关闭面板", "パネルを開く / 閉じる", "패널 열기 / 닫기", "Abrir / cerrar panel", "Ouvrir / fermer le panneau", "Panel öffnen / schließen", "Abrir / fechar painel", "Apri / chiudi pannello")
	R("Курсор / камера (пока панель открыта)", "Cursor / camera (while panel is open)", "光标 / 相机（面板打开时）", "カーソル / カメラ（パネル表示中）", "커서 / 카메라 (패널이 열려 있는 동안)", "Cursor / cámara (con el panel abierto)", "Curseur / caméra (panneau ouvert)", "Cursor / Kamera (solange das Panel offen ist)", "Cursor / câmera (com o painel aberto)", "Cursore / telecamera (a pannello aperto)")
	R("Показать / скрыть призрака", "Show / hide ghost", "显示 / 隐藏幽灵", "ゴーストの表示 / 非表示", "고스트 표시 / 숨기기", "Mostrar / ocultar fantasma", "Afficher / masquer le fantôme", "Geist ein- / ausblenden", "Mostrar / ocultar fantasma", "Mostra / nascondi fantasma")
	R("Клавиша Tackle Power", "Tackle Power key", "Tackle Power 按键", "Tackle Power のキー", "Tackle Power 키", "Tecla de Tackle Power", "Touche Tackle Power", "Taste für Tackle Power", "Tecla do Tackle Power", "Tasto Tackle Power")
	R("Все остальные бинды по умолчанию пустые. Они настраиваются в своих вкладках.", "All other binds are empty by default. They are set up in their own tabs.", "其他所有按键绑定默认为空，请在各自的标签页中设置。", "その他のキー割り当てはデフォルトで空です。各タブで設定してください。", "그 밖의 모든 키 바인드는 기본적으로 비어 있습니다. 각자의 탭에서 설정하세요.", "Todos los demás atajos están vacíos por defecto. Se configuran en sus propias pestañas.", "Tous les autres raccourcis sont vides par défaut. Ils se configurent dans leurs onglets respectifs.", "Alle anderen Tastenbelegungen sind standardmäßig leer. Sie werden in den jeweiligen Tabs eingestellt.", "Todos os outros atalhos ficam vazios por padrão. Eles são configurados nas respectivas abas.", "Tutte le altre combinazioni sono vuote per impostazione predefinita. Si configurano nelle rispettive schede.")
	R("СОХРАНЕНИЕ НАСТРОЕК", "SAVING SETTINGS", "保存设置", "設定の保存", "설정 저장", "GUARDADO DE AJUSTES", "SAUVEGARDE DES PARAMÈTRES", "EINSTELLUNGEN SPEICHERN", "SALVAR CONFIGURAÇÕES", "SALVATAGGIO IMPOSTAZIONI")
	R("Автосохранение", "Autosave", "自动保存", "自動保存", "자동 저장", "Autoguardado", "Sauvegarde auto", "Automatisch speichern", "Salvamento automático", "Salvataggio automatico")
	R("Запоминать вкл/выкл функций и множители", "Remember function on/off states and multipliers", "记住功能开关状态和倍率", "機能のオン/オフと倍率を記憶する", "기능 켜기/끄기 및 배수 기억", "Recordar estado de funciones y multiplicadores", "Mémoriser l'état des fonctions et les multiplicateurs", "Funktionsstatus und Multiplikatoren merken", "Lembrar estado das funções e multiplicadores", "Ricorda stato delle funzioni e moltiplicatori")
	R("Сохранить сейчас", "Save now", "立即保存", "今すぐ保存", "지금 저장", "Guardar ahora", "Enregistrer maintenant", "Jetzt speichern", "Salvar agora", "Salva ora")
	R("Удалить файл настроек (нажми дважды)", "Delete settings file (press twice)", "删除设置文件（点击两次）", "設定ファイルを削除（2回押す）", "설정 파일 삭제 (두 번 누르기)", "Eliminar archivo de ajustes (pulsa dos veces)", "Supprimer le fichier de paramètres (appuyer deux fois)", "Einstellungsdatei löschen (zweimal drücken)", "Excluir arquivo de configurações (pressione duas vezes)", "Elimina file impostazioni (premi due volte)")
	R("Точно? Нажми ещё раз", "Sure? Press again", "确定吗？再点一次", "本当に？もう一度押してください", "확실합니까? 다시 누르세요", "¿Seguro? Pulsa otra vez", "Sûr ? Appuyez encore", "Sicher? Noch einmal drücken", "Certeza? Pressione de novo", "Sicuro? Premi ancora")
	R("Файл удалён, автосохранение выключено", "File deleted, autosave turned off", "文件已删除，自动保存已关闭", "ファイルを削除しました。自動保存はオフです", "파일이 삭제되었고 자동 저장이 꺼졌습니다", "Archivo eliminado, autoguardado desactivado", "Fichier supprimé, sauvegarde auto désactivée", "Datei gelöscht, automatisches Speichern ausgeschaltet", "Arquivo excluído, salvamento automático desligado", "File eliminato, salvataggio automatico disattivato")
	R("Папка workspace экзекьютора. Сохраняется каждые 3 сек при изменениях. Вкл/выкл функций и множители Stats при запуске остаются выключенными, пока не включишь «Запоминать вкл/выкл».", "Executor workspace folder. Saved every 3 seconds when something changes. Function on/off states and Stats multipliers stay off at startup until you enable “Remember function on/off states and multipliers”.", "执行器的 workspace 文件夹。有变化时每 3 秒保存一次。启动时功能开关和 Stats 倍率保持关闭，直到你开启“记住功能开关状态和倍率”。", "エグゼキューターの workspace フォルダ。変更があると3秒ごとに保存されます。起動時、機能のオン/オフと Stats の倍率は「機能のオン/オフと倍率を記憶する」を有効にするまでオフのままです。", "익스큐터의 workspace 폴더입니다. 변경 사항이 있으면 3초마다 저장됩니다. 시작 시 기능 켜기/끄기와 Stats 배수는 ‘기능 켜기/끄기 및 배수 기억’을 켜기 전까지 꺼진 상태로 유지됩니다.", "Carpeta workspace del ejecutor. Se guarda cada 3 s si hay cambios. Al iniciar, el estado de las funciones y los multiplicadores de Stats permanecen desactivados hasta que actives «Recordar estado de funciones y multiplicadores».", "Dossier workspace de l'exécuteur. Enregistré toutes les 3 s en cas de modification. Au démarrage, l'état des fonctions et les multiplicateurs Stats restent désactivés tant que vous n'activez pas « Mémoriser l'état des fonctions et les multiplicateurs ».", "Workspace-Ordner des Executors. Wird bei Änderungen alle 3 Sek. gespeichert. Funktionsstatus und Stats-Multiplikatoren bleiben beim Start aus, bis du „Funktionsstatus und Multiplikatoren merken“ aktivierst.", "Pasta workspace do executor. Salva a cada 3 s quando há alterações. Ao iniciar, o estado das funções e os multiplicadores de Stats ficam desligados até você ativar «Lembrar estado das funções e multiplicadores».", "Cartella workspace dell'executor. Salva ogni 3 s quando ci sono modifiche. All'avvio, lo stato delle funzioni e i moltiplicatori di Stats restano disattivati finché non abiliti «Ricorda stato delle funzioni e moltiplicatori».")
	R("Нажми клавишу…", "Press a key…", "请按下按键…", "キーを押してください…", "키를 누르세요…", "Pulsa una tecla…", "Appuyez sur une touche…", "Taste drücken…", "Pressione uma tecla…", "Premi un tasto…")

	-- Внешний вид / язык / credits
	R("ВНЕШНИЙ ВИД", "APPEARANCE", "外观", "外観", "외관", "APARIENCIA", "APPARENCE", "DARSTELLUNG", "APARÊNCIA", "ASPETTO")
	R("Размер панели (%)", "Panel size (%)", "面板大小（%）", "パネルサイズ（%）", "패널 크기 (%)", "Tamaño del panel (%)", "Taille du panneau (%)", "Panelgröße (%)", "Tamanho do painel (%)", "Dimensione pannello (%)")
	R("Тема оформления", "Theme", "主题", "テーマ", "테마", "Tema", "Thème", "Design", "Tema", "Tema")
	R("Розовая", "Pink", "粉色", "ピンク", "핑크", "Rosa", "Rose", "Rosa", "Rosa", "Rosa")
	R("Чёрная", "Black", "黑色", "ブラック", "블랙", "Negro", "Noir", "Schwarz", "Preto", "Nero")
	R("Жёлтая", "Yellow", "黄色", "イエロー", "옐로", "Amarillo", "Jaune", "Gelb", "Amarelo", "Giallo")
	R("Красная", "Red", "红色", "レッド", "레드", "Rojo", "Rouge", "Rot", "Vermelho", "Rosso")
	R("Белая", "White", "白色", "ホワイト", "화이트", "Blanco", "Blanc", "Weiß", "Branco", "Bianco")
	R("Серая", "Gray", "灰色", "グレー", "그레이", "Gris", "Gris", "Grau", "Cinza", "Grigio")
	R("Пурпурная", "Purple", "紫色", "パープル", "퍼플", "Púrpura", "Violet", "Violett", "Roxo", "Viola")
	R("ЯЗЫК", "LANGUAGE", "语言", "言語", "언어", "IDIOMA", "LANGUE", "SPRACHE", "IDIOMA", "LINGUA")
	R("Переведены основные подписи панели. Тексты, которых нет в словаре, остаются на русском.", "The main panel labels are translated. Texts missing from the dictionary stay in Russian.", "已翻译面板的主要文字。词典中没有的文本仍显示为俄语。", "パネルの主なラベルを翻訳しています。辞書にないテキストはロシア語のままです。", "패널의 주요 문구가 번역되어 있습니다. 사전에 없는 텍스트는 러시아어로 남습니다.", "Se traducen las etiquetas principales del panel. Los textos que no están en el diccionario siguen en ruso.", "Les libellés principaux du panneau sont traduits. Les textes absents du dictionnaire restent en russe.", "Die wichtigsten Beschriftungen des Panels sind übersetzt. Texte ohne Wörterbucheintrag bleiben auf Russisch.", "Os principais rótulos do painel estão traduzidos. Textos que não estão no dicionário permanecem em russo.", "Le etichette principali del pannello sono tradotte. I testi non presenti nel dizionario restano in russo.")
	E("CREDITS", "БЛАГОДАРНОСТИ", "CREDITS", "致谢", "クレジット", "크레딧", "CRÉDITOS", "REMERCIEMENTS", "DANKSAGUNGEN", "CRÉDITOS", "RINGRAZIAMENTI")
	E("made by Hohoruno", "сделал Hohoruno", "made by Hohoruno", "作者：Hohoruno", "制作: Hohoruno", "제작: Hohoruno", "hecho por Hohoruno", "créé par Hohoruno", "erstellt von Hohoruno", "feito por Hohoruno", "creato da Hohoruno")
	E("CrossGamer for moral support", "CrossGamer — за моральную поддержку", "CrossGamer for moral support", "CrossGamer —— 感谢精神上的支持", "CrossGamer — 精神的な支えに感謝", "CrossGamer — 정신적 응원에 감사", "CrossGamer por el apoyo moral", "CrossGamer pour le soutien moral", "CrossGamer für die moralische Unterstützung", "CrossGamer pelo apoio moral", "CrossGamer per il supporto morale")
	E("Saphire for helping me with ideas and motivation", "Saphire — за помощь с идеями и мотивацией", "Saphire for helping me with ideas and motivation", "Saphire —— 感谢在创意和动力上的帮助", "Saphire — アイデアとモチベーションの手助けに感謝", "Saphire — 아이디어와 동기부여에 도움 준 것에 감사", "Saphire por ayudarme con ideas y motivación", "Saphire pour son aide en idées et en motivation", "Saphire für die Hilfe mit Ideen und Motivation", "Saphire por me ajudar com ideias e motivação", "Saphire per l'aiuto con idee e motivazione")
	E("Aviddr for supporting project", "Aviddr — за поддержку проекта", "Aviddr for supporting project", "Aviddr —— 感谢对项目的支持", "Aviddr — プロジェクトの支援に感謝", "Aviddr — 프로젝트를 지원해 준 것에 감사", "Aviddr por apoyar el proyecto", "Aviddr pour son soutien au projet", "Aviddr für die Unterstützung des Projekts", "Aviddr por apoiar o projeto", "Aviddr per il sostegno al progetto")
	E("Veluni and Meltdowfrost for fun", "Veluni и Meltdowfrost — за веселье", "Veluni and Meltdowfrost for fun", "Veluni 和 Meltdowfrost —— 感谢带来的乐趣", "Veluni と Meltdowfrost — 楽しさをありがとう", "Veluni와 Meltdowfrost — 즐거움을 줘서 감사", "Veluni y Meltdowfrost por la diversión", "Veluni et Meltdowfrost pour le fun", "Veluni und Meltdowfrost für den Spaß", "Veluni e Meltdowfrost pela diversão", "Veluni e Meltdowfrost per il divertimento")

	-- частые подписи из других вкладок
	R("МНОЖИТЕЛИ", "MULTIPLIERS", "倍率", "倍率", "배수", "MULTIPLICADORES", "MULTIPLICATEURS", "MULTIPLIKATOREN", "MULTIPLICADORES", "MOLTIPLICATORI")
	R("КУЛДАУНЫ", "COOLDOWNS", "冷却时间", "クールダウン", "쿨다운", "ENFRIAMIENTOS", "TEMPS DE RECHARGE", "ABKLINGZEITEN", "RECARGAS", "RICARICHE")
	R("Сбросить всё на 1", "Reset all to 1", "全部重置为 1", "すべて1にリセット", "모두 1로 초기화", "Restablecer todo a 1", "Tout remettre à 1", "Alles auf 1 zurücksetzen", "Redefinir tudo para 1", "Reimposta tutto a 1")
	R("Сила", "Power", "力度", "パワー", "파워", "Fuerza", "Puissance", "Stärke", "Força", "Potenza")
	R("Мяч", "Ball", "球", "ボール", "공", "Balón", "Ballon", "Ball", "Bola", "Palla")
	R("Игрок", "Player", "玩家", "プレイヤー", "플레이어", "Jugador", "Joueur", "Spieler", "Jogador", "Giocatore")
	R("Курсор", "Cursor", "光标", "カーソル", "커서", "Cursor", "Curseur", "Cursor", "Cursor", "Cursore")
	R("Скорость", "Speed", "速度", "速度", "속도", "Velocidad", "Vitesse", "Geschwindigkeit", "Velocidade", "Velocità")
	R("Высота", "Height", "高度", "高さ", "높이", "Altura", "Hauteur", "Höhe", "Altura", "Altezza")
	R("Громкость", "Volume", "音量", "音量", "볼륨", "Volumen", "Volume", "Lautstärke", "Volume", "Volume")
	R("Размер коллайдера", "Collider size", "碰撞体大小", "コライダーサイズ", "콜라이더 크기", "Tamaño del colisionador", "Taille du collider", "Collider-Größe", "Tamanho do colisor", "Dimensione del collider")
	R("Режим цели", "Target mode", "目标模式", "ターゲットモード", "대상 모드", "Modo de objetivo", "Mode de cible", "Zielmodus", "Modo de alvo", "Modalità bersaglio")
	R("Свой хитбокс (X Y Z)", "Custom hitbox (X Y Z)", "自定义判定框 (X Y Z)", "カスタムヒットボックス (X Y Z)", "사용자 히트박스 (X Y Z)", "Hitbox propia (X Y Z)", "Hitbox perso (X Y Z)", "Eigene Hitbox (X Y Z)", "Hitbox própria (X Y Z)", "Hitbox personalizzata (X Y Z)")
	R("Время рывка (сек)", "Dash time (sec)", "冲刺时间（秒）", "ダッシュ時間（秒）", "돌진 시간 (초)", "Tiempo de impulso (s)", "Durée de l'élan (s)", "Sprintzeit (Sek.)", "Tempo de arrancada (s)", "Tempo di scatto (s)")
	R("Показать/скрыть GUI", "Show/hide GUI", "显示/隐藏 GUI", "GUIの表示/非表示", "GUI 표시/숨기기", "Mostrar/ocultar GUI", "Afficher/masquer l'interface", "GUI ein-/ausblenden", "Mostrar/ocultar GUI", "Mostra/nascondi GUI")
	R("ПОВЕДЕНИЕ", "BEHAVIOR", "行为", "動作", "동작", "COMPORTAMIENTO", "COMPORTEMENT", "VERHALTEN", "COMPORTAMENTO", "COMPORTAMENTO")
	R("Поворачивать персонажа", "Rotate character", "旋转角色", "キャラクターを回転", "캐릭터 회전", "Girar personaje", "Faire pivoter le personnage", "Charakter drehen", "Girar personagem", "Ruota personaggio")
	R("Захват камеры", "Camera capture", "相机锁定", "カメラ固定", "카메라 고정", "Captura de cámara", "Capture de caméra", "Kamerafixierung", "Captura de câmera", "Cattura telecamera")
	R("Плавность камеры", "Camera smoothness", "相机平滑度", "カメラの滑らかさ", "카메라 부드러움", "Suavidad de cámara", "Fluidité de la caméra", "Kameraglättung", "Suavidade da câmera", "Fluidità telecamera")
	R("Показывать GUI", "Show GUI", "显示 GUI", "GUIを表示", "GUI 표시", "Mostrar GUI", "Afficher l'interface", "GUI anzeigen", "Mostrar GUI", "Mostra GUI")
	R("Размер GUI", "GUI size", "GUI 大小", "GUIサイズ", "GUI 크기", "Tamaño de GUI", "Taille de l'interface", "GUI-Größe", "Tamanho da GUI", "Dimensione GUI")
	R("Позиция X (%)", "Position X (%)", "X 位置（%）", "X位置（%）", "X 위치 (%)", "Posición X (%)", "Position X (%)", "Position X (%)", "Posição X (%)", "Posizione X (%)")
	R("Позиция Y (%)", "Position Y (%)", "Y 位置（%）", "Y位置（%）", "Y 위치 (%)", "Posición Y (%)", "Position Y (%)", "Position Y (%)", "Posição Y (%)", "Posizione Y (%)")
	R("Сбросить позицию GUI", "Reset GUI position", "重置 GUI 位置", "GUI位置をリセット", "GUI 위치 초기화", "Restablecer posición de GUI", "Réinitialiser la position", "GUI-Position zurücksetzen", "Redefinir posição da GUI", "Reimposta posizione GUI")
	R("R (красный)", "R (red)", "R（红）", "R（赤）", "R (빨강)", "R (rojo)", "R (rouge)", "R (Rot)", "R (vermelho)", "R (rosso)")
	R("G (зелёный)", "G (green)", "G（绿）", "G（緑）", "G (초록)", "G (verde)", "G (vert)", "G (Grün)", "G (verde)", "G (verde)")
	R("B (синий)", "B (blue)", "B（蓝）", "B（青）", "B (파랑)", "B (azul)", "B (bleu)", "B (Blau)", "B (azul)", "B (blu)")
	R("Подсветка игроков", "Player highlight", "玩家高亮", "プレイヤーのハイライト", "플레이어 강조", "Resaltado de jugadores", "Surbrillance des joueurs", "Spielerhervorhebung", "Destaque de jogadores", "Evidenziazione giocatori")
	R("Прозрачность заливки", "Fill transparency", "填充透明度", "塗りの透明度", "채우기 투명도", "Transparencia del relleno", "Transparence du remplissage", "Füllungstransparenz", "Transparência do preenchimento", "Trasparenza riempimento")
	R("Цвет красной команды", "Red team color", "红队颜色", "赤チームの色", "레드 팀 색상", "Color del equipo rojo", "Couleur de l'équipe rouge", "Farbe des roten Teams", "Cor da equipe vermelha", "Colore squadra rossa")
	R("Цвет синей команды", "Blue team color", "蓝队颜色", "青チームの色", "블루 팀 색상", "Color del equipo azul", "Couleur de l'équipe bleue", "Farbe des blauen Teams", "Cor da equipe azul", "Colore squadra blu")
	R("Цвет выбранных игроков", "Selected players color", "所选玩家颜色", "選択したプレイヤーの色", "선택한 플레이어 색상", "Color de jugadores seleccionados", "Couleur des joueurs sélectionnés", "Farbe ausgewählter Spieler", "Cor dos jogadores selecionados", "Colore giocatori selezionati")
	R("ИГРОКИ", "PLAYERS", "玩家", "プレイヤー", "플레이어", "JUGADORES", "JOUEURS", "SPIELER", "JOGADORES", "GIOCATORI")
	R("Снять все метки", "Clear all marks", "清除所有标记", "すべてのマークを解除", "모든 표시 해제", "Quitar todas las marcas", "Retirer toutes les marques", "Alle Markierungen entfernen", "Remover todas as marcas", "Rimuovi tutti i segni")
	R("Цвет кошки", "Cat color", "猫咪颜色", "ネコの色", "고양이 색상", "Color del gato", "Couleur du chat", "Katzenfarbe", "Cor do gato", "Colore del gatto")
	R("Размер кошки (px)", "Cat size (px)", "猫咪大小（px）", "ネコのサイズ（px）", "고양이 크기 (px)", "Tamaño del gato (px)", "Taille du chat (px)", "Katzengröße (px)", "Tamanho do gato (px)", "Dimensione gatto (px)")
	R("Высота над головой (студы)", "Height above head (studs)", "头顶高度（studs）", "頭上の高さ（スタッド）", "머리 위 높이 (스터드)", "Altura sobre la cabeza (studs)", "Hauteur au-dessus de la tête (studs)", "Höhe über dem Kopf (Studs)", "Altura acima da cabeça (studs)", "Altezza sopra la testa (stud)")
	R("Показывать скиллы", "Show skills", "显示技能", "スキルを表示", "스킬 표시", "Mostrar habilidades", "Afficher les compétences", "Skills anzeigen", "Mostrar habilidades", "Mostra abilità")
	R("Дистанция показа (студы)", "Display distance (studs)", "显示距离（studs）", "表示距離（スタッド）", "표시 거리 (스터드)", "Distancia de visualización (studs)", "Distance d'affichage (studs)", "Anzeigedistanz (Studs)", "Distância de exibição (studs)", "Distanza di visualizzazione (stud)")
	R("Режим предикции", "Prediction mode", "预测模式", "予測モード", "예측 모드", "Modo de predicción", "Mode de prédiction", "Vorhersagemodus", "Modo de previsão", "Modalità di previsione")
	R("Время предикции (сек)", "Prediction time (sec)", "预测时间（秒）", "予測時間（秒）", "예측 시간 (초)", "Tiempo de predicción (s)", "Durée de prédiction (s)", "Vorhersagezeit (Sek.)", "Tempo de previsão (s)", "Tempo di previsione (s)")
	R("Толщина линии", "Line thickness", "线条粗细", "線の太さ", "선 두께", "Grosor de línea", "Épaisseur de ligne", "Linienstärke", "Espessura da linha", "Spessore linea")
	R("УВЕДОМЛЕНИЯ И ЗВУКИ", "NOTIFICATIONS AND SOUNDS", "通知与声音", "通知とサウンド", "알림 및 소리", "NOTIFICACIONES Y SONIDOS", "NOTIFICATIONS ET SONS", "BENACHRICHTIGUNGEN UND SOUNDS", "NOTIFICAÇÕES E SONS", "NOTIFICHE E SUONI")
	R("Всплывающие уведомления", "Pop-up notifications", "弹出通知", "ポップアップ通知", "팝업 알림", "Notificaciones emergentes", "Notifications contextuelles", "Pop-up-Benachrichtigungen", "Notificações pop-up", "Notifiche popup")
	R("Звук уведомлений", "Notification sound", "通知声音", "通知音", "알림 소리", "Sonido de notificaciones", "Son des notifications", "Benachrichtigungston", "Som de notificações", "Suono notifiche")
	R("Тест уведомления", "Test notification", "测试通知", "通知をテスト", "알림 테스트", "Probar notificación", "Tester la notification", "Benachrichtigung testen", "Testar notificação", "Prova notifica")
	R("Эмоуты", "Emotes", "表情动作", "エモート", "이모트", "Emotes", "Emotes", "Emotes", "Emotes", "Emote")
	R("Скорость полёта", "Flight speed", "飞行速度", "飛行速度", "비행 속도", "Velocidad de vuelo", "Vitesse de vol", "Fluggeschwindigkeit", "Velocidade de voo", "Velocità di volo")
	R("Чувствительность мыши", "Mouse sensitivity", "鼠标灵敏度", "マウス感度", "마우스 감도", "Sensibilidad del ratón", "Sensibilité de la souris", "Mausempfindlichkeit", "Sensibilidade do mouse", "Sensibilità del mouse")
	R("◀ Предыдущий игрок", "◀ Previous player", "◀ 上一位玩家", "◀ 前のプレイヤー", "◀ 이전 플레이어", "◀ Jugador anterior", "◀ Joueur précédent", "◀ Vorheriger Spieler", "◀ Jogador anterior", "◀ Giocatore precedente")
	R("Следующий игрок ▶", "Next player ▶", "下一位玩家 ▶", "次のプレイヤー ▶", "다음 플레이어 ▶", "Siguiente jugador ▶", "Joueur suivant ▶", "Nächster Spieler ▶", "Próximo jogador ▶", "Giocatore successivo ▶")
	R("Обновить список игроков", "Refresh player list", "刷新玩家列表", "プレイヤー一覧を更新", "플레이어 목록 새로고침", "Actualizar lista de jugadores", "Actualiser la liste des joueurs", "Spielerliste aktualisieren", "Atualizar lista de jogadores", "Aggiorna elenco giocatori")
	R("Бинд вкл/выкл", "On/off bind", "开/关按键", "オン/オフ キー", "켜기/끄기 키", "Atajo activar/desactivar", "Raccourci activer/désactiver", "Ein/Aus-Taste", "Atalho ligar/desligar", "Tasto attiva/disattiva")
	R("Макс. дистанция (студы)", "Max distance (studs)", "最大距离（studs）", "最大距離（スタッド）", "최대 거리 (스터드)", "Distancia máx. (studs)", "Distance max. (studs)", "Max. Distanz (Studs)", "Distância máx. (studs)", "Distanza max. (stud)")
	R("Следующий игрок", "Next player", "下一位玩家", "次のプレイヤー", "다음 플레이어", "Siguiente jugador", "Joueur suivant", "Nächster Spieler", "Próximo jogador", "Giocatore successivo")
	R("Предыдущий игрок", "Previous player", "上一位玩家", "前のプレイヤー", "이전 플레이어", "Jugador anterior", "Joueur précédent", "Vorheriger Spieler", "Jogador anterior", "Giocatore precedente")
	R("Радиус (студы)", "Radius (studs)", "半径（studs）", "半径（スタッド）", "반경 (스터드)", "Radio (studs)", "Rayon (studs)", "Radius (Studs)", "Raio (studs)", "Raggio (stud)")
	R("Дистанция (студы)", "Distance (studs)", "距离（studs）", "距離（スタッド）", "거리 (스터드)", "Distancia (studs)", "Distance (studs)", "Distanz (Studs)", "Distância (studs)", "Distanza (stud)")

	--------------------------------------------------------
	-- ДВИЖОК ПЕРЕВОДА
	--------------------------------------------------------
	-- ===== Резервный автоперевод =====
	-- Если строки нет в DICT/PFX/PAT, она переводится онлайн (Google Translate) и кэшируется
	-- (в памяти + в файле Yokatta_translations.json). Числа маскируются ({1}, {2}…),
	-- поэтому динамические строки вроде «Пинг 45 мс» переводятся один раз, а не на каждое значение.
	-- Нужна поддержка HTTP в executor (request / http_request / syn.request); без неё остаётся русский.
	local MT = {}
	do
		local MT_LANG = { en = "en", zh = "zh-CN", ja = "ja", ko = "ko", es = "es", fr = "fr", de = "de", pt = "pt", it = "it" }
		local MT_FILE = "Yokatta_translations.json"
		local MT_LIMIT = 2500 -- максимум онлайн-запросов за сессию (защита от спама)
		local MT_WORKERS = 3
		local httpReq = (syn and syn.request) or (http and http.request) or http_request or request

		local cache = {}
		for code in pairs(MT_LANG) do
			cache[code] = {}
		end
		if isfile and readfile and isfile(MT_FILE) then
			local ok, data = pcall(function()
				return HttpService:JSONDecode(readfile(MT_FILE))
			end)
			if ok and type(data) == "table" then
				for code, map in pairs(data) do
					if cache[code] and type(map) == "table" then
						cache[code] = map
					end
				end
			end
		end

		local dirty = false
		if writefile then
			task.spawn(function()
				while Gui.Parent do
					task.wait(5)
					if dirty then
						dirty = false
						pcall(function()
							writefile(MT_FILE, HttpService:JSONEncode(cache))
						end)
					end
				end
			end)
		end

		-- числа заменяются на токены 99101, 99102… (цифры переводчики не трогают), потом возвращаются
		local function mask(text)
			local nums = {}
			local masked = text:gsub("%-?%d+[%.,]?%d*", function(n)
				nums[#nums + 1] = n
				return tostring(99100 + #nums)
			end)
			return masked, nums
		end

		local function unmask(text, nums)
			for i = 1, #nums do
				if not text:find(tostring(99100 + i), 1, true) then
					return nil
				end
			end
			return (text:gsub("%f[%d]99%d%d%d%f[%D]", function(t)
				return nums[tonumber(t) - 99100]
			end))
		end

		local warned = {}
		local function warnOnce(msg)
			if not warned[msg] then
				warned[msg] = true
				warn("[Yokatta] автоперевод: " .. msg)
			end
		end

		local ENDPOINTS = {
			"https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=ru&tl=%s",
			"https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=ru&tl=%s",
		}

		local function parse(body)
			local ok, data = pcall(function()
				return HttpService:JSONDecode(body)
			end)
			if not ok or type(data) ~= "table" then
				return nil
			end
			local out = {}
			if type(data[1]) == "table" then
				for _, seg in ipairs(data[1]) do
					if type(seg) == "table" and type(seg[1]) == "string" then
						out[#out + 1] = seg[1]
					end
				end
			elseif type(data.sentences) == "table" then
				for _, sn in ipairs(data.sentences) do
					if type(sn) == "table" and type(sn.trans) == "string" then
						out[#out + 1] = sn.trans
					end
				end
			end
			if #out == 0 then
				return nil
			end
			return table.concat(out)
		end

		local function fetch(text, lang)
			local q = HttpService:UrlEncode(text)
			local lastErr = "?"
			for _, ep in ipairs(ENDPOINTS) do
				local url = string.format(ep, MT_LANG[lang])
				local req
				if #q > 1500 then
					req = {
						Url = url,
						Method = "POST",
						Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
						Body = "q=" .. q,
					}
				else
					req = { Url = url .. "&q=" .. q, Method = "GET" }
				end
				local ok, res = pcall(httpReq, req)
				if not ok then
					lastErr = tostring(res)
				elseif type(res) ~= "table" then
					lastErr = "пустой ответ"
				elseif res.StatusCode ~= 200 and res.Success ~= true then
					lastErr = "HTTP " .. tostring(res.StatusCode)
				else
					local r = parse(res.Body)
					if r then
						return r
					end
					lastErr = "не удалось разобрать ответ"
				end
			end
			warnOnce("запрос не удался (" .. lastErr .. ")")
			return nil
		end

		local queue, waiting, failed = {}, {}, {}
		local active, used = 0, 0
		MT.Resync = function() end -- подставляется ниже (sync)

		local function pump()
			while active < MT_WORKERS and #queue > 0 do
				local job = table.remove(queue, 1)
				active += 1
				task.spawn(function()
					local res = fetch(job.masked, job.lang)
					if not res then
						job.tries = (job.tries or 0) + 1
						if job.tries < 4 then
							-- возможно лимит запросов: ждём и пробуем снова
							task.wait(1.5 * job.tries)
							queue[#queue + 1] = job
							active -= 1
							pump()
							return
						end
						failed[job.key] = true
					else
						cache[job.lang][job.masked] = res
						dirty = true
					end
					local set = waiting[job.key]
					waiting[job.key] = nil
					if res and set and Look.Lang == job.lang then
						for inst in pairs(set) do
							if inst.Parent then
								MT.Resync(inst)
							end
						end
					end
					task.wait(0.12) -- небольшая пауза между запросами
					active -= 1
					pump()
				end)
			end
		end

		function MT.ClearFailed()
			failed = {}
		end

		-- возвращает перевод из кэша или исходный текст (и ставит строку в очередь на перевод)
		function MT.Lookup(text, lang, inst)
			local map = cache[lang]
			if not map or not text:find("[\208\209]") then
				return text
			end
			if not httpReq then
				warnOnce("в этом executor нет request/http_request, поэтому строки вне словаря остаются русскими")
				return text
			end
			if text:find("</?%a[^>]*>") then
				return text -- RichText-теги не отдаём переводчику
			end
			local masked, nums = mask(text)
			local hit = map[masked]
			if hit then
				local r = unmask(hit, nums)
				if r then
					return r
				end
				-- числа потерялись при переводе: переводим строку целиком, вместе с числами
				masked, nums = text, {}
				hit = map[masked]
				if hit then
					return hit
				end
			end
			local key = lang .. "|" .. masked
			if failed[key] then
				return text
			end
			local set = waiting[key]
			if not set then
				if used >= MT_LIMIT then
					return text
				end
				used += 1
				set = setmetatable({}, { __mode = "k" })
				waiting[key] = set
				queue[#queue + 1] = { key = key, lang = lang, masked = masked }
				pump()
			end
			if inst then
				set[inst] = true
			end
			return text
		end
	end

	local function translate(text, lang, inst)
		if lang == "ru" or text == "" then
			return text
		end
		local d = DICT[lang]
		local v = d[text]
		if v then
			return v
		end
		for _, p in ipairs(PFX) do
			local k = p.key
			if text:sub(1, #k) == k then
				local rest = text:sub(#k + 1)
				return (p[lang] or k) .. (d[rest] or MT.Lookup(rest, lang, inst))
			end
		end
		for _, p in ipairs(PAT) do
			local caps = { text:match(p.pat) }
			if #caps > 0 and p[lang] then
				return string.format(p[lang], table.unpack(caps))
			end
		end
		return MT.Lookup(text, lang, inst)
	end

	-- оригинал хранится в атрибуте YKOrig, последний наш перевод — в YKTr
	local function sync(inst)
		local cur = inst.Text
		local orig = inst:GetAttribute("YKOrig")
		if orig == nil or cur ~= inst:GetAttribute("YKTr") then
			orig = cur
			inst:SetAttribute("YKOrig", orig)
		end
		local new = translate(orig, Look.Lang, inst)
		inst:SetAttribute("YKTr", new)
		if new ~= cur then
			inst.Text = new
		end
	end
	MT.Resync = sync

	local hooked = setmetatable({}, { __mode = "k" })
	local function hook(inst)
		if hooked[inst] or not (inst:IsA("TextLabel") or inst:IsA("TextButton")) then
			return
		end
		hooked[inst] = true
		inst:GetPropertyChangedSignal("Text"):Connect(function()
			if Look.Lang ~= "ru" then
				sync(inst)
			end
		end)
		if Look.Lang ~= "ru" then
			sync(inst)
		end
	end

	-- переводим ВСЕ окна Yokatta (панель, курсор, уведомления, HUD-виджеты авто-функций), а не только главное
	local roots = setmetatable({}, { __mode = "k" })
	local function addRoot(g)
		if not g or roots[g] then
			return
		end
		roots[g] = true
		for _, inst in ipairs(g:GetDescendants()) do
			hook(inst)
		end
		g.DescendantAdded:Connect(hook)
	end
	local function isOurs(g)
		return g:IsA("ScreenGui") and string.sub(g.Name, 1, 7) == "Yokatta"
	end
	addRoot(Gui)
	addRoot(CursorGui)
	for _, g in ipairs(parent:GetChildren()) do
		if isOurs(g) then
			addRoot(g)
		end
	end
	parent.ChildAdded:Connect(function(g)
		if isOurs(g) then
			addRoot(g)
		end
	end)

	function Look.SetLang(code)
		if not DICT[code] or code == Look.Lang then
			return
		end
		Look.Lang = code
		MT.ClearFailed()
		for g in pairs(roots) do
			if g.Parent then
				for _, inst in ipairs(g:GetDescendants()) do
					if inst:IsA("TextLabel") or inst:IsA("TextButton") then
						hook(inst)
						sync(inst)
					end
				end
			end
		end
		if Look.OnLang then
			Look.OnLang()
		end
	end

	--------------------------------------------------------
	-- ИНТЕРФЕЙС В SETTINGS
	--------------------------------------------------------
	local LANGS = {
		{ "ru", "Русский" }, { "en", "English" }, { "zh", "中文" }, { "ja", "日本語" }, { "ko", "한국어" },
		{ "es", "Español" }, { "fr", "Français" }, { "de", "Deutsch" }, { "pt", "Português" }, { "it", "Italiano" },
	}

	local function label(parent, props)
		props.BackgroundTransparency = 1
		props.Font = props.Font or Enum.Font.GothamMedium
		props.TextSize = props.TextSize or 14
		props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
		local l = create("TextLabel", props)
		l.Parent = parent
		return l
	end

	function Look.BuildAppearance(h)
		UI.Section(h, "ВНЕШНИЙ ВИД")

		UI.Slider(h, "Размер панели (%)", 50, 150, 100, 0, function(v)
			setPanelScale(v / 100)
		end)

		-- тема
		local trow = UI.Card(h, 84)
		label(trow, { Position = UDim2.fromOffset(14, 6), Size = UDim2.new(0.5, -14, 0, 24), Text = "Тема оформления", TextColor3 = C.TextDark })
		local nameLbl = label(trow, {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.new(0.5, -14, 0, 24),
			Text = THEMES[Look.Theme].name, TextColor3 = C.TextMid, Font = Enum.Font.GothamBold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		local wrap = create("Frame", {
			Position = UDim2.fromOffset(14, 38), Size = UDim2.new(1, -28, 0, 36), BackgroundTransparency = 1,
		}, {
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})
		wrap.Parent = trow
		local swatches = {}
		for i, code in ipairs(THEME_ORDER) do
			local b = create("TextButton", {
				Name = "Swatch", LayoutOrder = i, Size = UDim2.fromOffset(32, 32), BackgroundColor3 = THEMES[code].swatch,
				Text = "", AutoButtonColor = false,
			}, { round(), create("UIStroke", { Thickness = 1, Color = rgb(150, 150, 150), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) })
			b.Parent = wrap
			swatches[code] = b
			b.MouseButton1Click:Connect(function()
				Look.SetTheme(code)
			end)
		end
		local function refreshTheme()
			for code, b in pairs(swatches) do
				local sel = code == Look.Theme
				local s = b:FindFirstChildOfClass("UIStroke")
				s.Thickness = sel and 3 or 1
				s.Color = sel and C.TextDark or rgb(150, 150, 150)
			end
			nameLbl.Text = THEMES[Look.Theme].name
			nameLbl.TextColor3 = C.TextMid
		end
		refreshTheme()

		-- язык
		UI.Section(h, "ЯЗЫК")
		local lrow = UI.Card(h, 8 + 4 * 34 + 6)
		local grid = create("Frame", {
			Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 4 * 34), BackgroundTransparency = 1,
		}, {
			create("UIGridLayout", {
				CellSize = UDim2.fromOffset(128, 28), CellPadding = UDim2.fromOffset(6, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		grid.Parent = lrow
		local lbtns = {}
		for i, l in ipairs(LANGS) do
			local b = create("TextButton", {
				LayoutOrder = i, BackgroundColor3 = C.Sidebar, Text = l[2], TextColor3 = C.TextMid,
				Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			b.Parent = grid
			lbtns[l[1]] = b
			b.MouseButton1Click:Connect(function()
				Look.SetLang(l[1])
			end)
		end
		local function refreshLang()
			for code, b in pairs(lbtns) do
				local on = code == Look.Lang
				b.BackgroundColor3 = on and C.AccentStrong or C.Sidebar
				b.TextColor3 = on and Color3.new(1, 1, 1) or C.TextMid
			end
		end
		refreshLang()
		UI.Note(h, "Переведены основные подписи панели. Тексты, которых нет в словаре, остаются на русском.")

		Look.OnTheme = function()
			refreshTheme()
			refreshLang()
		end
		Look.OnLang = refreshLang

		Persist.addId("Settings/Appearance/Theme", "data", function()
			return Look.Theme
		end, function(v)
			if type(v) == "string" then
				Look.SetTheme(v)
			end
		end, "Тема оформления", "ВНЕШНИЙ ВИД")
		Persist.addId("Settings/Appearance/Language", "data", function()
			return Look.Lang
		end, function(v)
			if type(v) == "string" then
				Look.SetLang(v)
			end
		end, "Язык", "ЯЗЫК")
	end

	function Look.BuildCredits(h)
		UI.Section(h, "CREDITS")
		local g = UI.Group(h)
		local lines = {
			"made by Hohoruno",
			"CrossGamer for moral support",
			"Saphire for helping me with ideas and motivation",
			"Aviddr for supporting project",
			"Veluni and Meltdowfrost for fun",
		}
		for i, text in ipairs(lines) do
			label(g, {
				LayoutOrder = i, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				Text = text, TextWrapped = true, TextColor3 = C.TextDark, TextSize = 13,
			})
		end
	end
end

------------------------------------------------------------
-- ВКЛАДКА SETTINGS
------------------------------------------------------------
do
	local h = Holders.Settings

	if h then
		UI.ClearPlaceholder(h)

		Look.BuildAppearance(h)

		UI.Section(h, "LAG GHOST (работает всегда)")

		local modeChoice = UI.Choice(h, "Режим призрака", {
			{ "players", "Игроки" },
			{ "server", "Сервер" },
		}, LagGhost.GetMode(), function(v)
			LagGhost.SetMode(v)
		end)

		local visToggle = UI.Toggle(h, "Показывать призрака", LagGhost.GetVisible(), function(v)
			LagGhost.SetVisible(v)
		end)

		UI.Slider(h, "Интерполяция игроков (сек)", 0, 0.3, LagGhost.GetInterp(), 2, function(v)
			LagGhost.SetInterp(v)
		end)

		local info = UI.Note(h, "")

		-- если режим/видимость поменялись горячими клавишами — обновляем переключатели
		LagGhost.OnChange = function()
			modeChoice.Set(LagGhost.GetMode(), true)
			visToggle.Set(LagGhost.GetVisible(), true)
		end

		task.spawn(function()
			while Gui.Parent do
				local ping, delay = LagGhost.GetInfo()
				info.Text = string.format(
					"Пинг: %d мс | задержка призрака: %d мс",
					math.floor(ping * 1000 + 0.5),
					math.floor(delay * 1000 + 0.5)
				)
				task.wait(0.25)
			end
		end)
        		------------------------------------------------------------
		-- ВКЛАДКИ
		------------------------------------------------------------
		UI.Section(h, "ВКЛАДКИ")
		for _, name in ipairs(CONFIG.Tabs) do
			if name ~= "Settings" then
				UI.Toggle(h, "Вкладка " .. name, true, function(v)
					setTabEnabled(name, v)
				end)
			end
		end
		UI.Note(h, "Отключённая вкладка только скрывается. Включённые в ней функции продолжают работать.")

		------------------------------------------------------------
		-- КЛАВИШИ ПАНЕЛИ
		------------------------------------------------------------
		UI.Section(h, "КЛАВИШИ ПАНЕЛИ")
		UI.BindRow(h, "Открыть / закрыть панель", function() return CONFIG.ToggleKey end,
			function(k) CONFIG.ToggleKey = k end, { noClear = true })
		UI.BindRow(h, "Курсор / камера (пока панель открыта)", function() return CONFIG.CursorKey end,
			function(k) CONFIG.CursorKey = k; updateHint() end, { noClear = true })
		UI.BindRow(h, "Показать / скрыть призрака", function() return CONFIG.LagGhostVisibleKey end,
			function(k) CONFIG.LagGhostVisibleKey = k end)
		UI.BindRow(h, "Клавиша Tackle Power", function() return CONFIG.TackleKey end,
			function(k) CONFIG.TackleKey = k end)
		UI.Note(h, "Все остальные бинды по умолчанию пустые. Они настраиваются в своих вкладках.")

		------------------------------------------------------------
		-- СОХРАНЕНИЕ НАСТРОЕК
		------------------------------------------------------------
		UI.Section(h, "СОХРАНЕНИЕ НАСТРОЕК")
		local autoToggle = UI.Toggle(h, "Автосохранение", Persist.AutoSave, function(v)
			Persist.AutoSave = v
			if not v then
				Persist.save(true)
			end
		end)
		UI.Toggle(h, "Запоминать вкл/выкл функций и множители", Persist.RestoreSwitches, function(v)
			Persist.RestoreSwitches = v
		end)
		UI.Button(h, "Сохранить сейчас", function()
			Persist.save(true)
		end)
		local delAt, delBtn = -10, nil
		delBtn = UI.Button(h, "Удалить файл настроек (нажми дважды)", function()
			if os.clock() - delAt < 3 then
				delAt = -10
				Persist.AutoSave = false
				autoToggle.Set(false, true)
				pcall(function()
					if delfile and isfile and isfile(Persist.File) then
						delfile(Persist.File)
					end
				end)
				delBtn.Text = "Файл удалён, автосохранение выключено"
			else
				delAt = os.clock()
				delBtn.Text = "Точно? Нажми ещё раз"
				task.delay(3, function()
					if delAt ~= -10 and os.clock() - delAt >= 3 then
						delBtn.Text = "Удалить файл настроек (нажми дважды)"
					end
				end)
			end
		end)
		UI.Note(h, "Файл: " .. Persist.File)
		UI.Note(h, "Папка workspace экзекьютора. Сохраняется каждые 3 сек при изменениях. Вкл/выкл функций и множители Stats при запуске остаются выключенными, пока не включишь «Запоминать вкл/выкл».")

		Look.BuildCredits(h)
	end
end

------------------------------------------------------------
-- ВКЛАДКА UTILITIES: M1 Speed / Кулдауны / Tackle Power
-- (всё выключено по умолчанию, включается переключателями)
------------------------------------------------------------
do
	local LocalPlayer = Players.LocalPlayer
	local h = Holders.Utilities

	-- пока включён режим курсора, клики по панели не считаем кликами в игре
	local function panelHasMouse()
		return isOpen and applied == "cursor"
	end

	if h then
		UI.ClearPlaceholder(h)

		---------------------------------------------------------
		-- M1 SPEED
		---------------------------------------------------------
		local M1 = {
			Enabled = false,
			FlowName = "Speedster", -- значение Flow, при котором применяется бонус (регистр не важен)
			BurstAndFlow = 9.1, -- SpeedBurst + Flow
			FlowOnly = 4.55, -- только Flow
			BurstOnly = 4.9, -- только SpeedBurst
			Clicking = 2, -- зажата M1
			Idle = 1, -- обычное состояние
		}

		local speedValue, instanceVal

		local function bindCharacter(char)
			speedValue, instanceVal = nil, nil
			if not char then
				return
			end
			task.spawn(function()
				local info = char:WaitForChild("PlayerInfo", 10)
				local sv = info and info:WaitForChild("SpeedMultiplier", 10)
				local iv = char:WaitForChild("InstanceValue", 10)
				if LocalPlayer.Character == char then
					speedValue, instanceVal = sv, iv
				end
			end)
		end
		bindCharacter(LocalPlayer.Character)
		LocalPlayer.CharacterAdded:Connect(bindCharacter)

		local function restoreSpeed()
			if not speedValue then
				return
			end
			if StatsAPI.touched.SpeedMultiplier then
				speedValue.Value = StatsAPI.values.SpeedMultiplier
			else
				speedValue.Value = M1.Idle
			end
		end

		local function updateSpeed()
			if not speedValue or not instanceVal then
				return
			end

			local flow = instanceVal:FindFirstChild("Flow")
			local speedBurst = instanceVal:FindFirstChild("SpeedBurst")

			local hasSpeedster = false
			if flow and flow:IsA("ValueBase") and M1.FlowName ~= "" then
				hasSpeedster = tostring(flow.Value):lower() == M1.FlowName:lower()
			end

			local target
			if speedBurst and hasSpeedster then
				target = M1.BurstAndFlow
			elseif hasSpeedster then
				target = M1.FlowOnly
			elseif speedBurst then
				target = M1.BurstOnly
			elseif not panelHasMouse() and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				target = M1.Clicking
			else
				target = M1.Idle
			end

			if speedValue.Value ~= target then
				speedValue.Value = target
			end
		end

		RunService.Heartbeat:Connect(function()
			if M1.Enabled then
				updateSpeed()
			end
		end)

		UI.Section(h, "M1 SPEED")
		UI.Toggle(h, "M1 Speed", false, function(v)
			M1.Enabled = v
			if not v then
				restoreSpeed()
			end
		end)
		UI.TextInput(h, "Название Flow (его значение)", M1.FlowName, "Speedster", function(t)
			M1.FlowName = t:match("^%s*(.-)%s*$")
			return false
		end)
		UI.Note(
			h,
			"Пока M1 Speed включён, он сам управляет SpeedMultiplier (слайдер Speed в Stats не действует). При выключении вернётся значение из Stats, если ты его менял, иначе 1."
		)

		---------------------------------------------------------
		-- КУЛДАУНЫ
		---------------------------------------------------------
		local FOLDER_NAME = "InstanceValue"
		local CD = {
			Enabled = false,
			Names = {}, -- [имя в нижнем регистре] = true для отмеченных
		}
		local cdConns = {}

		local function disconnectCD()
			for _, c in ipairs(cdConns) do
				c:Disconnect()
			end
			table.clear(cdConns)
		end

		local function isTarget(obj)
			return CD.Names[obj.Name:lower()] == true
		end

		local function sweep(folder)
			if not CD.Enabled then
				return
			end
			for _, child in ipairs(folder:GetChildren()) do
				if isTarget(child) then
					child:Destroy()
				end
			end
		end

		local function watchFolder(folder)
			sweep(folder)
			table.insert(
				cdConns,
				folder.ChildAdded:Connect(function(child)
					if CD.Enabled and isTarget(child) then
						child:Destroy()
					end
				end)
			)
		end

		local function watchCharacter(char)
			disconnectCD()
			local existing = char:FindFirstChild(FOLDER_NAME)
			if existing then
				watchFolder(existing)
			end
			table.insert(
				cdConns,
				char.ChildAdded:Connect(function(child)
					if child.Name == FOLDER_NAME then
						watchFolder(child)
					end
				end)
			)
		end

		LocalPlayer.CharacterAdded:Connect(watchCharacter)
		if LocalPlayer.Character then
			watchCharacter(LocalPlayer.Character)
		end

		local function sweepNow()
			local char = LocalPlayer.Character
			local folder = char and char:FindFirstChild(FOLDER_NAME)
			if folder then
				sweep(folder)
			end
		end

		UI.Section(h, "КУЛДАУНЫ")
		UI.Toggle(h, "Удалять выбранные кулдауны", false, function(v)
			CD.Enabled = v
			if v then
				sweepNow()
			end
		end)

		local cdGroup = UI.Group(h)
		local rows = {}

		local function addCooldown(name, on)
			local key = name:lower()
			if rows[key] then
				rows[key].Set(true)
				return
			end
			CD.Names[key] = on or nil
			rows[key] = UI.Toggle(cdGroup, name, on, function(v)
				CD.Names[key] = v or nil
				if v then
					sweepNow()
				end
			end)
		end

		for _, n in ipairs({ "KickCooldown", "RunningCoodlown", "CantPossess" }) do
			addCooldown(n, true)
		end

		UI.TextInput(h, "Добавить своё значение", "", "Имя + Enter", function(t, enter)
			if not enter then
				return false
			end
			local name = t:match("^%s*(.-)%s*$")
			if name == "" then
				return false
			end
			addCooldown(name, true)
			return true
		end)
		UI.Note(h, "Отмеченные значения удаляются из InstanceValue, как только появляются. Свои названия впиши в поле и нажми Enter.")

		---------------------------------------------------------
		-- TACKLE POWER
		---------------------------------------------------------
		local TK = {
			Enabled = false,
			Force = 55,
			Duration = 0.4,
			PreDelay = 0.10,
			LockFacing = false, -- нельзя повернуться, пока идёт тэкл
			Locked = false,
		}

		-- если в character.InstanceValue есть любое из этих значений, рывок не работает
		local BLOCKERS = { "SlideTackleCooldown", "Kick", "SlideTackle", "ChargingKick", "Possession" }

		local function isBlocked(character)
			local folder = character:FindFirstChild("InstanceValue")
			if not folder then
				return false
			end
			for _, name in ipairs(BLOCKERS) do
				if folder:FindFirstChild(name) then
					return true
				end
			end
			return false
		end

		UIS.InputBegan:Connect(function(input, gp)
			if gp or not TK.Enabled then
				return
			end
			if input.KeyCode ~= CONFIG.TackleKey then
				return
			end

			-- проверка ТОЛЬКО в момент нажатия
			local character = LocalPlayer.Character
			if not character or isBlocked(character) then
				return
			end

			-- блокировка поворота (по желанию): с момента нажатия до конца тэкла
			local ownsLock = false
			local lockAttachment, lockAlign, lockHumanoid, prevAutoRotate

			local function unlock()
				if not ownsLock then
					return
				end
				ownsLock = false
				TK.Locked = false
				if lockAlign then
					lockAlign:Destroy()
					lockAlign = nil
				end
				if lockAttachment then
					lockAttachment:Destroy()
					lockAttachment = nil
				end
				if lockHumanoid and lockHumanoid.Parent and prevAutoRotate ~= nil then
					lockHumanoid.AutoRotate = prevAutoRotate
				end
			end

			if TK.LockFacing and not TK.Locked then
				local hrp0 = character:FindFirstChild("HumanoidRootPart")
				lockHumanoid = character:FindFirstChildOfClass("Humanoid")
				if hrp0 and lockHumanoid then
					local look = hrp0.CFrame.LookVector
					local flat0 = Vector3.new(look.X, 0, look.Z)
					if flat0.Magnitude > 0.001 then
						ownsLock = true
						TK.Locked = true
						prevAutoRotate = lockHumanoid.AutoRotate
						lockHumanoid.AutoRotate = false

						lockAttachment = Instance.new("Attachment")
						lockAttachment.Parent = hrp0

						lockAlign = Instance.new("AlignOrientation")
						lockAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
						lockAlign.Attachment0 = lockAttachment
						lockAlign.RigidityEnabled = true
						lockAlign.CFrame = CFrame.lookAt(Vector3.zero, flat0.Unit)
						lockAlign.Parent = hrp0
					end
				end
			end

			task.wait(TK.PreDelay)

			character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChild("Humanoid")
			if not hrp or not humanoid then
				unlock()
				return
			end

			-- направление только персонажа, без вертикали
			local look = hrp.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude < 0.001 then
				unlock()
				return
			end
			local direction = flat.Unit

			local attachment = Instance.new("Attachment")
			attachment.Parent = hrp

			local velocity = Instance.new("LinearVelocity")
			velocity.Attachment0 = attachment
			velocity.MaxForce = math.huge
			velocity.VectorVelocity = direction * TK.Force
			velocity.Parent = hrp

			task.delay(TK.Duration, function()
				velocity:Destroy()
				attachment:Destroy()
				unlock()
			end)
		end)

		UI.Section(h, "TACKLE POWER (клавиша F)")
		UI.Toggle(h, "Tackle Power", false, function(v)
			TK.Enabled = v
		end)
		UI.Slider(h, "Сила", 0, 200, TK.Force, 0, function(v)
			TK.Force = v
		end)
		UI.Slider(h, "Время рывка (сек)", 0.05, 2, TK.Duration, 2, function(v)
			TK.Duration = v
		end)
		UI.Toggle(h, "Блокировать поворот во время тэкла", false, function(v)
			TK.LockFacing = v
		end)
		UI.Note(
			h,
			"Рывок не сработает, если в InstanceValue уже есть SlideTackleCooldown, Kick, SlideTackle, ChargingKick или Possession. Блокировка поворота действует с момента нажатия F (после проверок) и до конца тэкла."
		)
	end
end

------------------------------------------------------------
-- UTILITIES: MAGNET + LOCK-ON
------------------------------------------------------------
do
	local LocalPlayer = Players.LocalPlayer
	local h = Holders.Utilities

	if h then
		------------------------------------------------------------
		-- НАСТРОЙКИ МЯЧА (поменяй, если в игре называется иначе)
		------------------------------------------------------------
		local FOLDER_NAME = "Messi"
		local BALL_NAME = "/e ball"
		local COLLIDER_NAME = "Collider"

		------------------------------------------------------------
		-- ОТСЛЕЖИВАНИЕ МЯЧЕЙ (общее для Magnet и Lock-On)
		-- Работает на событиях: если папки/мяча нет — скрипт просто
		-- ждёт и ничего не грузит. Если мячей много — следит за каждым.
		------------------------------------------------------------
		local balls = {} -- [ball] = { collider, orig, conns, sizeConn }
		local ballFolder = nil
		local folderConns = {}
		local Magnet = { Enabled = false, Size = 3 }

		local function enforce(rec)
			local c = rec.collider
			if not c or not c.Parent then
				return
			end
			local want = Vector3.new(Magnet.Size, Magnet.Size, Magnet.Size)
			if c.Size ~= want then
				c.Size = want
			end
		end

		local function restore(rec)
			local c = rec.collider
			if c and c.Parent and rec.orig and c.Size ~= rec.orig then
				c.Size = rec.orig
			end
		end

		local function bindCollider(rec, c)
			if rec.sizeConn then
				rec.sizeConn:Disconnect()
			end
			rec.collider = c
			rec.orig = c.Size
			-- если игра сама вернёт размер — сразу вернём наш (без цикла опроса)
			rec.sizeConn = c:GetPropertyChangedSignal("Size"):Connect(function()
				if Magnet.Enabled then
					enforce(rec)
				end
			end)
			if Magnet.Enabled then
				enforce(rec)
			end
		end

		local function untrack(ball)
			local rec = balls[ball]
			if not rec then
				return
			end
			balls[ball] = nil
			for _, conn in ipairs(rec.conns) do
				conn:Disconnect()
			end
			if rec.sizeConn then
				rec.sizeConn:Disconnect()
			end
			restore(rec)
		end

		local function track(ball)
			if balls[ball] or ball.Name ~= BALL_NAME then
				return
			end
			if not (ball:IsA("Model") or ball:IsA("BasePart")) then
				return
			end

			local rec = { conns = {} }
			balls[ball] = rec

			local c = ball:FindFirstChild(COLLIDER_NAME)
			if c and c:IsA("BasePart") then
				bindCollider(rec, c)
			end

			-- коллайдер может появиться позже самого мяча
			table.insert(
				rec.conns,
				ball.ChildAdded:Connect(function(child)
					if child.Name == COLLIDER_NAME and child:IsA("BasePart") and not rec.collider then
						bindCollider(rec, child)
					end
				end)
			)
			table.insert(
				rec.conns,
				ball.ChildRemoved:Connect(function(child)
					if child == rec.collider then
						if rec.sizeConn then
							rec.sizeConn:Disconnect()
							rec.sizeConn = nil
						end
						rec.collider = nil
						rec.orig = nil
					end
				end)
			)
		end

		local function detachFolder()
			for _, conn in ipairs(folderConns) do
				conn:Disconnect()
			end
			table.clear(folderConns)
			for ball in pairs(balls) do
				untrack(ball)
			end
			ballFolder = nil
		end

		local function attachFolder(f)
			detachFolder()
			ballFolder = f
			for _, child in ipairs(f:GetChildren()) do
				track(child)
			end
			table.insert(folderConns, f.ChildAdded:Connect(track))
			table.insert(folderConns, f.ChildRemoved:Connect(untrack))
			table.insert(
				folderConns,
				f.AncestryChanged:Connect(function()
					if not f:IsDescendantOf(workspace) then
						detachFolder()
					end
				end)
			)
		end

		do
			local f = workspace:FindFirstChild(FOLDER_NAME)
			if f then
				attachFolder(f)
			end
		end
		-- папка может появиться (или пересоздаться) позже
		workspace.ChildAdded:Connect(function(child)
			if child.Name == FOLDER_NAME and child ~= ballFolder then
				attachFolder(child)
			end
		end)

		local function setMagnetEnabled(v)
			Magnet.Enabled = v and true or false
			for _, rec in pairs(balls) do
				if Magnet.Enabled then
					enforce(rec)
				else
					restore(rec)
				end
			end
		end

		local function setMagnetSize(s)
			Magnet.Size = math.max(0.1, s)
			if Magnet.Enabled then
				for _, rec in pairs(balls) do
					enforce(rec)
				end
			end
		end

		------------------------------------------------------------
		-- LOCK-ON: состояние
		------------------------------------------------------------
		local MODES = { "ball", "player", "cursor" }
		local MODE_LABEL = { ball = "Мяч", player = "Игрок", cursor = "Курсор" }

		local LO = {
			Enabled = false,
			Mode = "ball",
			FaceChar = true,
			FaceCam = false,
			CamSmooth = 0.3,
			Target = nil,
			Pinned = false, -- цель выбрана вручную (клавишей «следующая цель»)
			Hitboxes = {}, -- заполняется ниже
			HitboxIndex = 1,
		}

		local widgetPos = { x = 50, y = 12 } -- в процентах экрана
		local guiShown = false -- по умолчанию GUI Lock-On выключен

		-- слайдеры настроек GUI (создаются ниже, нужны для перетаскивания)
		local xSlider, ySlider

		------------------------------------------------------------
		-- LOCK-ON: GUI (маленькое окошко со статусом)
		------------------------------------------------------------
		do
			local old = parent:FindFirstChild("YokattaLockOn")
			if old then
				old:Destroy()
			end
		end

		local LockGui = create("ScreenGui", {
			Name = "YokattaLockOn",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 998,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		LockGui.Parent = parent

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(190, 62),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = guiShown,
		}, {
			corner(UDim.new(0, 12)),
			create("UIStroke", { Color = C.HeaderLine, Thickness = 2 }),
		})
		local WScale = create("UIScale", { Scale = 1 })
		WScale.Parent = Widget
		Widget.Parent = LockGui

		local dot = create("Frame", {
			Position = UDim2.fromOffset(12, 10),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = C.Off,
		}, { round() })
		dot.Parent = Widget

		create("TextLabel", {
			Position = UDim2.fromOffset(30, 5),
			Size = UDim2.fromOffset(120, 20),
			BackgroundTransparency = 1,
			Text = "Lock-On",
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = Widget

		local modeLabel = create("TextLabel", {
			Position = UDim2.fromOffset(12, 26),
			Size = UDim2.fromOffset(166, 16),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = C.TextMid,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		modeLabel.Parent = Widget

		local targetLabel = create("TextLabel", {
			Position = UDim2.fromOffset(12, 42),
			Size = UDim2.fromOffset(166, 16),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = C.TextMid,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		targetLabel.Parent = Widget

		local function setWidgetPos(x, y, fromDrag)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
			if fromDrag then
				if xSlider then
					xSlider.Set(widgetPos.x, true)
				end
				if ySlider then
					ySlider.Set(widgetPos.y, true)
				end
			end
		end

		-- перетаскивание окошка мышью (когда панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100, true)
				end
			end)
		end

		------------------------------------------------------------
		-- LOCK-ON: цели
		------------------------------------------------------------
		local function isValid(t)
			if not t or not t.Parent or not t:IsDescendantOf(workspace) then
				return false
			end
			local hum = t:IsA("Model") and t:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health <= 0 then
				return false
			end
			return true
		end

		local function getPos(t)
			local hrp = t:IsA("Model") and t:FindFirstChild("HumanoidRootPart")
			if hrp then
				return hrp.Position
			end
			local ok, cf = pcall(t.GetPivot, t)
			if ok then
				return cf.Position
			end
			return nil
		end

		local function targetName(t)
			if not t then
				return nil
			end
			local p = t:IsA("Model") and Players:GetPlayerFromCharacter(t)
			if p then
				return p.DisplayName
			end
			return t.Name == BALL_NAME and "мяч" or t.Name
		end

		local function gatherCandidates(mode)
			local list = {}
			if mode == "ball" then
				for ball in pairs(balls) do
					if isValid(ball) then
						list[#list + 1] = ball
					end
				end
			else
				for _, p in ipairs(Players:GetPlayers()) do
					local ch = p ~= LocalPlayer and p.Character
					if ch and isValid(ch) and ch:FindFirstChild("HumanoidRootPart") then
						list[#list + 1] = ch
					end
				end
			end
			return list
		end

		local function sortedCandidates(mode)
			local list = gatherCandidates(mode)
			if #list == 0 then
				return list
			end

			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			local mouse = UIS:GetMouseLocation()

			local scored = {}
			for _, t in ipairs(list) do
				local pos = getPos(t)
				local score
				if pos then
					if mode == "cursor" then
						if cam then
							local v, on = cam:WorldToViewportPoint(pos)
							if on then
								score = (Vector2.new(v.X, v.Y) - mouse).Magnitude
							end
						end
					elseif root then
						score = (pos - root.Position).Magnitude
					end
				end
				if score then
					scored[#scored + 1] = { t = t, s = score }
				end
			end
			table.sort(scored, function(a, b)
				return a.s < b.s
			end)

			local out = {}
			for i, e in ipairs(scored) do
				out[i] = e.t
			end
			return out
		end

		local function pickNearest(mode)
			return sortedCandidates(mode)[1]
		end

		local function refreshGui()
			dot.BackgroundColor3 = LO.Enabled and Color3.fromRGB(110, 200, 140) or C.Off
			local hb = LO.Hitboxes[LO.HitboxIndex]
			modeLabel.Text = "Режим: " .. MODE_LABEL[LO.Mode] .. " | " .. (hb and hb.name or "Прямо")
			if not LO.Enabled then
				targetLabel.Text = "Цель: выкл"
			else
				targetLabel.Text = "Цель: " .. (targetName(LO.Target) or "нет")
			end
		end

		------------------------------------------------------------
		-- LOCK-ON: хитбоксы (поворот УГЛОМ хитбокса)
		------------------------------------------------------------
		local function fmtNum(n)
			return tostring(math.floor(n * 100 + 0.5) / 100)
		end

		local function hbName(size)
			return string.format("Угол %s x %s x %s", fmtNum(size.X), fmtNum(size.Y), fmtNum(size.Z))
		end

		LO.Hitboxes = {
			{ name = "Прямо", size = nil },
			{ name = hbName(Vector3.new(19, 40, 18.5)), size = Vector3.new(19, 40, 18.5) },
			{ name = hbName(Vector3.new(5.75, 7.15, 7.15)), size = Vector3.new(5.75, 7.15, 7.15) },
		}

		local function wrapAngle(a)
			return (a + math.pi) % (2 * math.pi) - math.pi
		end

		-- yaw в той же системе, что и CFrame.Angles(0, yaw, 0)
		local function yawOf(dx, dz)
			return math.atan2(-dx, -dz)
		end

		-- поворот, при котором ближайший к текущему взгляду УГОЛ хитбокса смотрит на цель
		local function cornerYaw(toTargetYaw, currentYaw, size)
			local hx, hz = size.X / 2, size.Z / 2
			local best, bestDiff = toTargetYaw, math.huge
			for _, sx in ipairs({ -1, 1 }) do
				for _, sz in ipairs({ -1, 1 }) do
					local phi = yawOf(sx * hx, sz * hz)
					local candidate = toTargetYaw - phi
					local diff = math.abs(wrapAngle(candidate - currentYaw))
					if diff < bestDiff then
						bestDiff = diff
						best = candidate
					end
				end
			end
			return best
		end

		local rebuildHitboxList -- объявлена ниже (в разделе UI)

		local function setHitbox(i)
			LO.HitboxIndex = math.clamp(i, 1, #LO.Hitboxes)
			if rebuildHitboxList then
				rebuildHitboxList()
			end
			refreshGui()
		end

		local function cycleHitbox()
			setHitbox(LO.HitboxIndex % #LO.Hitboxes + 1)
		end

		local function addHitbox(x, y, z)
			local size = Vector3.new(math.max(0.1, x), math.max(0.1, y), math.max(0.1, z))
			table.insert(LO.Hitboxes, { name = hbName(size), size = size, custom = true })
			setHitbox(#LO.Hitboxes)
		end

		local function removeLastCustomHitbox()
			for i = #LO.Hitboxes, 1, -1 do
				if LO.Hitboxes[i].custom then
					table.remove(LO.Hitboxes, i)
					if LO.HitboxIndex >= i then
						LO.HitboxIndex = math.max(1, LO.HitboxIndex - 1)
					end
					setHitbox(LO.HitboxIndex)
					return
				end
			end
		end

		------------------------------------------------------------
		-- LOCK-ON: поворот персонажа / камеры
		------------------------------------------------------------
		local facing = nil -- { att, align, hum }
		local ownsAuto = false

		local function releaseFacing()
			if facing then
				if facing.align then
					facing.align:Destroy()
				end
				if facing.att then
					facing.att:Destroy()
				end
				if ownsAuto and facing.hum and facing.hum.Parent then
					facing.hum.AutoRotate = true
				end
				facing = nil
			end
			ownsAuto = false
		end

		local function setLockEnabled(v)
			LO.Enabled = v and true or false
			LO.Target = nil
			LO.Pinned = false
			if not LO.Enabled then
				LO.Yaw = nil
				releaseFacing()
			end
			refreshGui()
		end

		local retimer, guiTimer = 1, 0

		local function setMode(m)
			LO.Mode = m
			LO.Target = nil
			LO.Pinned = false
			retimer = 1
			refreshGui()
		end

		local function nextTarget()
			if not LO.Enabled then
				return
			end
			local list = sortedCandidates(LO.Mode)
			if #list == 0 then
				LO.Target = nil
				return
			end
			local idx = table.find(list, LO.Target)
			LO.Target = list[((idx or 0) % #list) + 1]
			LO.Pinned = true
			refreshGui()
		end

		RunService.Heartbeat:Connect(function(dt)
			if not LO.Enabled then
				LO.Yaw = nil
				return
			end

			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not root or not hum then
				LO.Yaw = nil
				releaseFacing()
				return
			end

			-- поиск цели: редко и только если цели нет (если мяча нет — почти ничего не стоит)
			retimer += dt
			if not isValid(LO.Target) then
				LO.Target = nil
				LO.Pinned = false
				if retimer >= 0.2 then
					retimer = 0
					LO.Target = pickNearest(LO.Mode)
				end
			elseif LO.Mode == "cursor" and not LO.Pinned and retimer >= 0.1 then
				retimer = 0
				LO.Target = pickNearest("cursor") or LO.Target
			end

			-- поворот персонажа
			LO.Yaw = nil
			local tp = LO.Target and getPos(LO.Target)
			if tp and LO.FaceChar then
				local d = Vector3.new(tp.X - root.Position.X, 0, tp.Z - root.Position.Z)
				if d.Magnitude > 0.5 then
					if not facing or not facing.align or not facing.align.Parent then
						releaseFacing()
						local att = Instance.new("Attachment")
						att.Parent = root
						local align = Instance.new("AlignOrientation")
						align.Mode = Enum.OrientationAlignmentMode.OneAttachment
						align.Attachment0 = att
						align.RigidityEnabled = true
						align.Parent = root
						facing = { att = att, align = align, hum = hum }
					end

					-- угол поворота: прямо на цель или углом выбранного хитбокса
					local yaw = yawOf(d.X, d.Z)
					local hb = LO.Hitboxes[LO.HitboxIndex]
					if hb and hb.size then
						local look = root.CFrame.LookVector
						yaw = cornerYaw(yaw, yawOf(look.X, look.Z), hb.size)
					end
					facing.align.CFrame = CFrame.Angles(0, yaw, 0)
					-- Shift Lock / игра каждый кадр разворачивают персонажа по камере и перебивают
					-- AlignOrientation, поэтому угол ещё и задаём напрямую (здесь и после камеры)
					LO.Yaw = yaw
					root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)

					if hum.AutoRotate then
						hum.AutoRotate = false
						ownsAuto = true
					end
				end
			else
				releaseFacing()
			end

			-- обновление текста окошка (не каждый кадр)
			guiTimer += dt
			if guiTimer >= 0.15 then
				guiTimer = 0
				refreshGui()
			end
		end)

		LocalPlayer.CharacterAdded:Connect(function()
			facing = nil
			ownsAuto = false
		end)

		-- камера: после штатной камеры игры
		pcall(function()
			RunService:UnbindFromRenderStep("YokattaLockOnCam")
		end)
		RunService:BindToRenderStep("YokattaLockOnCam", Enum.RenderPriority.Camera.Value + 1, function()
			if LO.Enabled and LO.FaceChar and LO.Yaw then
				local ch = LocalPlayer.Character
				local r = ch and ch:FindFirstChild("HumanoidRootPart")
				if r then
					r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, LO.Yaw, 0)
				end
			end
			if not (LO.Enabled and LO.FaceCam and LO.Target) then
				return
			end
			local cam = workspace.CurrentCamera
			local tp = cam and getPos(LO.Target)
			if not tp then
				return
			end
			local cf = cam.CFrame
			cam.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, tp), LO.CamSmooth)
		end)

		------------------------------------------------------------
		-- БИНДЫ
		------------------------------------------------------------
		local Binds = {	-- magnetToggle и guiToggle по умолчанию не назначены
		}
		local bindButtons = {}
		local listening = nil -- { id, btn }

		local function refreshBind(id)
			local btn = bindButtons[id]
			if btn then
				btn.Text = Binds[id] and Binds[id].Name or "—"
			end
		end

		local function stopListening()
			if listening then
				refreshBind(listening.id)
				listening = nil
			end
		end

		local function makeBindRow(group, order, id, label)
			local row = create("Frame", {
				LayoutOrder = order,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = group

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = label,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row
			bindButtons[id] = btn
            			refreshBind(id)
			Persist.addId("bind/LockOn/" .. id, "bind", function() return Binds[id] end,
				function(k) Binds[id] = k; refreshBind(id) end)

			btn.MouseButton1Click:Connect(function()
				stopListening()
				listening = { id = id, btn = btn }
				btn.Text = "Нажми клавишу…"
			end)
		end

		------------------------------------------------------------
		-- UI: MAGNET
		------------------------------------------------------------
		UI.Section(h, "MAGNET")
		local magnetToggle = UI.Toggle(h, "Magnet (коллайдер мяча)", false, setMagnetEnabled)
		UI.Slider(h, "Размер коллайдера", 1, 30, Magnet.Size, 1, setMagnetSize)
		UI.Note(
			h,
			"Увеличивает «Collider» у мячей. Работает на событиях: если мяча нет или их несколько — ничего не лагает. При выключении возвращает исходный размер."
		)

		------------------------------------------------------------
		-- UI: LOCK-ON
		------------------------------------------------------------
		UI.Section(h, "LOCK-ON")
		local lockToggle = UI.Toggle(h, "Lock-On", false, setLockEnabled)
		local modeChoice = UI.Choice(h, "Режим цели", {
			{ "ball", "Мяч" },
			{ "player", "Игрок" },
			{ "cursor", "Курсор" },
		}, LO.Mode, setMode)

		------------------------------------------------------------
		-- UI: ХИТБОКС LOCK-ON
		------------------------------------------------------------
		UI.Section(h, "ХИТБОКС LOCK-ON (смотрит углом)")
		local hitboxGroup = UI.Group(h)

		rebuildHitboxList = function()
			for _, c in ipairs(hitboxGroup:GetChildren()) do
				if not c:IsA("UIListLayout") then
					c:Destroy()
				end
			end
			for i, hb in ipairs(LO.Hitboxes) do
				UI.Button(hitboxGroup, (i == LO.HitboxIndex and "● " or "○ ") .. hb.name, function()
					setHitbox(i)
				end)
			end
		end
		rebuildHitboxList()

		UI.TextInput(h, "Свой хитбокс (X Y Z)", "", "5 7 7 + Enter", function(t, enter)
			if not enter then
				return false
			end
			local nums = {}
			for n in t:gmatch("%d+%.?%d*") do
				nums[#nums + 1] = tonumber(n)
			end
			if #nums < 3 then
				return false
			end
			addHitbox(nums[1], nums[2], nums[3])
			return true
		end)
		UI.Button(h, "Удалить последний свой хитбокс", removeLastCustomHitbox)
		UI.Note(
			h,
			"Выбери хитбокс из списка или впиши свой размер (например «5.75 7.15 7.15») и нажми Enter. Персонаж повернётся так, что на цель будет смотреть угол этого хитбокса. «Прямо» — обычный поворот лицом к цели."
		)

		local settingsBtn
		local settingsGroup
		settingsBtn = UI.Button(h, "⚙ Настройки Lock-On", function()
			settingsGroup.Visible = not settingsGroup.Visible
			settingsBtn.Text = settingsGroup.Visible and "⚙ Настройки Lock-On (скрыть)" or "⚙ Настройки Lock-On"
		end)

		settingsGroup = UI.Group(h)
		settingsGroup.Visible = false

		-- бинды
		UI.Section(settingsGroup, "БИНДЫ (нажми на кнопку, затем клавишу; Esc/Backspace — очистить)")
		local bindGroup = UI.Group(settingsGroup)
		makeBindRow(bindGroup, 1, "lockToggle", "Lock-On вкл/выкл")
		makeBindRow(bindGroup, 2, "modeCycle", "Сменить режим")
		makeBindRow(bindGroup, 3, "hitboxCycle", "Сменить хитбокс")

		local extraGroup = UI.Group(settingsGroup)
		extraGroup.Visible = false
		makeBindRow(extraGroup, 1, "nextTarget", "Следующая цель")
		makeBindRow(extraGroup, 2, "magnetToggle", "Magnet вкл/выкл")
		makeBindRow(extraGroup, 3, "guiToggle", "Показать/скрыть GUI")

		local extraBtn
		extraBtn = UI.Button(settingsGroup, "+ Доп. бинды", function()
			extraGroup.Visible = not extraGroup.Visible
			extraBtn.Text = extraGroup.Visible and "− Скрыть доп. бинды" or "+ Доп. бинды"
		end)

		-- поведение
		UI.Section(settingsGroup, "ПОВЕДЕНИЕ")
		UI.Toggle(settingsGroup, "Поворачивать персонажа", true, function(v)
			LO.FaceChar = v
			if not v then
				releaseFacing()
			end
		end)
		UI.Toggle(settingsGroup, "Захват камеры", false, function(v)
			LO.FaceCam = v
		end)
		UI.Slider(settingsGroup, "Плавность камеры", 0.05, 1, LO.CamSmooth, 2, function(v)
			LO.CamSmooth = v
		end)

		-- GUI
		UI.Section(settingsGroup, "GUI LOCK-ON")
		local guiToggle = UI.Toggle(settingsGroup, "Показывать GUI", guiShown, function(v)
			guiShown = v
			Widget.Visible = v
		end)
		UI.Slider(settingsGroup, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(settingsGroup, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(settingsGroup, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(settingsGroup, "Сбросить позицию GUI", function()
			setWidgetPos(50, 12, true)
		end)
		UI.Note(
			settingsGroup,
			"GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора. Режим «Курсор» берёт игрока, ближайшего к курсору на экране."
		)

		UI.Note(
			h,
			"Lock-On: «Мяч» — ближайший мяч, «Игрок» — ближайший игрок, «Курсор» — игрок ближе всего к курсору. Персонаж разворачивается к цели (по желанию — и камера). Если цели нет, Lock-On просто ждёт."
		)

		refreshGui()

		------------------------------------------------------------
		-- ДЕЙСТВИЯ БИНДОВ + ОБРАБОТКА КЛАВИШ
		------------------------------------------------------------
		local actions = {
			lockToggle = function()
				lockToggle.Set(not lockToggle.Get())
			end,
			modeCycle = function()
				local i = table.find(MODES, LO.Mode) or 1
				modeChoice.Set(MODES[i % #MODES + 1])
			end,
			nextTarget = function()
				nextTarget()
			end,
			hitboxCycle = function()
				cycleHitbox()
			end,
			magnetToggle = function()
				magnetToggle.Set(not magnetToggle.Get())
			end,
			guiToggle = function()
				guiToggle.Set(not guiToggle.Get())
			end,
		}

		UIS.InputBegan:Connect(function(input, gp)
			-- режим «жду клавишу для бинда»
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local id = listening.id
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						Binds[id] = nil
					elseif key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
						-- клавиша занята панелью — оставляем прежний бинд
					else
						for otherId, k in pairs(Binds) do
							if k == key and otherId ~= id then
								Binds[otherId] = nil
								refreshBind(otherId)
							end
						end
						Binds[id] = key
					end
					refreshBind(id)
				end
				return
			end

			if gp then
				return
			end
			for id, key in pairs(Binds) do
				if input.KeyCode == key and actions[id] then
					actions[id]()
					break
				end
			end
		end)
	end
end

------------------------------------------------------------
-- ВКЛАДКА ESP
------------------------------------------------------------
do
	local LocalPlayer = Players.LocalPlayer
	local h = Holders.Esp

	if h then
		UI.ClearPlaceholder(h)

		------------------------------------------------------------
		-- НАСТРОЙКИ (значения по умолчанию; меняются из панели)
		------------------------------------------------------------
		local ESP = {
			Enabled = true,
			Highlight = true,
			FillTransparency = 0.5,
			TeamColors = {
				red = Color3.fromRGB(255, 0, 0),
				blue = Color3.fromRGB(0, 120, 255),
			},
			MarkColor = Color3.fromRGB(255, 220, 0),
			Skills = true,
			SkillMaxDistance = 100, -- дальше метка со скиллами не видна
			NearShowAll = true, -- вблизи показывать ВСЕ скиллы не на КД
			NearDistance = 40,
			NearEnemyOnly = true,
		}

		local PRED = {
			Enabled = false,
			Mode = "curved", -- "lined" = Lined Prediction, "curved" = Curved Pred
			Time = 2,
			Segments = 25,
			Thickness = 0.15,
			LineColor = Color3.fromRGB(0, 255, 255),
			CurvedColor = Color3.fromRGB(255, 170, 0),
			-- только для Curved Pred
			MinTurn = 0.15, -- рад/с: слабее считаем прямой линией
			MaxTurn = 8, -- рад/с: ограничение поворота
			TurnSmooth = 0.35, -- сглаживание поворота (меньше = плавнее)
			TurnDecay = 0, -- затухание кручения (1/с)
			Bounce = 0.6, -- отскок от земли
		}

		local LAST = {
			Enabled = true,
			Radius = 1.5,
			Color = Color3.fromRGB(255, 0, 0),
			Transparency = 0.15,
		}

		local CAM = { Enabled = true, FOV = 90, MaxZoom = 200, MinZoom = 0.5 }

		local marked = {} -- [player] = true (выбран в панели)
		local BALLS = {} -- общий список мячей для предикции и метки LastVector3

		------------------------------------------------------------
		-- ПОДСВЕТКА ИГРОКОВ + СКИЛЛЫ НАД ГОЛОВОЙ
		------------------------------------------------------------
		do
			local TEAM_FLAG = "MatchTeam"
			local HIGHLIGHT_REFRESH = 0.5
			local SKILL_REFRESH = 0.1

			local WORLD_OFFSET = Vector3.new(0, 4.5, 0)
			local WORLD_LINE_HEIGHT = 18
			local WORLD_TEXT_SIZE = 14
			local WORLD_WIDTH = 220

			local VALUES_FOLDER = "InstanceValue"
			local CHARGING_NAME = "ChargingKick"
			local FLOW_SCALE = 1 -- если поток хранится как 0..1, поставь 100
			local IGNORE_TOOLS = {}

			local DANGER_SKILLS = {
				["Exploisive Speed"] = true,
				["Explosive Speed"] = true,
				["Blackhole Trap"] = true,
				["Kaiser Impact"] = true,
				["Ignited Steal"] = true,
			}

			local SHOT_SKILLS = {
				["Death Drop"] = { flow = 65, charge = false },
				["Fire Tornado"] = { flow = 65, charge = false },
				["Big Bang Drive"] = { flow = 80, charge = false },
				["Northern Impact"] = { flow = 40, charge = false },
				["Kaiser Impact"] = { flow = 80, charge = true },
				["Canon Shot"] = { charge = true },
				["Lion Shot"] = { charge = true },
				["Dragon Drive"] = { charge = true },
				["Direct Shot"] = { charge = true },
				["Shadow Shot"] = { charge = true },
				["Shine Drive"] = { charge = true },
			}
			local SHOT_REQUIRE_EQUIPPED = true

			local STATE_MARK = { equipped = "●", charge = "◆", flow = "✦" }
			local STATE_COLORS = {
				equipped = Color3.fromRGB(230, 140, 0),
				charge = Color3.fromRGB(220, 40, 40),
				flow = Color3.fromRGB(190, 0, 255),
			}
			local DANGER_MARK = "⚠"
			local DANGER_TEXT = Color3.fromRGB(255, 80, 80)

			local function norm(name)
				return ((name:gsub("%s", "")):lower())
			end

			local function esc(s)
				return ((s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")))
			end

			local DANGER_N, SHOT_N = {}, {}
			for n in pairs(DANGER_SKILLS) do
				DANGER_N[norm(n)] = true
			end
			for n, d in pairs(SHOT_SKILLS) do
				SHOT_N[norm(n)] = d
			end

			local EXTRA_KNOWN_SKILLS = {
				"Roulette", "Elastico", "Illusion Ball", "Skystep", "Flurry Dash", "Chop Dribble",
				"Tsunami Boost", "Zero Reset Turn", "Ice Ground", "Mega Quake", "Einstaz",
				"Spinning Top", "Killer Slide", "Spiral Draw", "Running Blaze", "Spinning Cut",
			}
			local KNOWN_SKILLS = {}
			for name in pairs(DANGER_SKILLS) do
				KNOWN_SKILLS[norm(name)] = name
			end
			for name in pairs(SHOT_SKILLS) do
				KNOWN_SKILLS[norm(name)] = name
			end
			for _, name in ipairs(EXTRA_KNOWN_SKILLS) do
				KNOWN_SKILLS[norm(name)] = name
			end

			local highlights, worldGuis, memory = {}, {}, {}

			-- команда
			local function getTeamName(player)
				local mt = player:FindFirstChild(TEAM_FLAG)
				if not mt then
					return nil
				end
				local v
				if mt:IsA("ValueBase") then
					v = mt.Value
				else
					v = mt:GetAttribute("Value")
				end
				if typeof(v) == "Instance" then
					v = v.Name
				end
				if v == nil then
					return nil
				end
				return string.lower(tostring(v))
			end

			local function getTeamColor(player)
				local name = getTeamName(player)
				return name and ESP.TeamColors[name] or nil
			end

			local function isEnemy(player)
				local mine = getTeamName(LocalPlayer)
				local theirs = getTeamName(player)
				return mine ~= nil and theirs ~= nil and mine ~= theirs
			end

			local function isNearTarget(player)
				if not ESP.NearShowAll then
					return false
				end
				if ESP.NearEnemyOnly and not isEnemy(player) then
					return false
				end
				local myChar = LocalPlayer.Character
				local char = player.Character
				local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not myHrp or not hrp then
					return false
				end
				return (myHrp.Position - hrp.Position).Magnitude <= ESP.NearDistance
			end

			-- подсветка
			local function removeHighlight(player)
				local hl = highlights[player]
				if hl then
					hl:Destroy()
					highlights[player] = nil
				end
			end

			local function refreshPlayer(player)
				if not ESP.Enabled or not ESP.Highlight or player == LocalPlayer then
					removeHighlight(player)
					return
				end

				local char = player.Character
				local color = marked[player] and ESP.MarkColor or getTeamColor(player)
				if not char or not color then
					removeHighlight(player)
					return
				end

				local hl = highlights[player]
				if not hl or not hl.Parent or hl.Parent ~= char then
					if hl then
						hl:Destroy()
					end
					hl = Instance.new("Highlight")
					hl.Name = "YokattaHighlight"
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.OutlineColor = Color3.new(1, 1, 1)
					hl.Parent = char
					highlights[player] = hl
				end
				hl.FillColor = color
				hl.FillTransparency = ESP.FillTransparency
			end

			-- данные игрока
			local function getValuesFolder(player)
				local char = player.Character
				return char and char:FindFirstChild(VALUES_FOLDER)
			end

			local function getFlow(player)
				local char = player.Character
				local info = char and char:FindFirstChild("PlayerInfo")
				local flow = info and info:FindFirstChild("Flow")
				if not flow then
					return 0
				end
				local v
				if flow:IsA("ValueBase") then
					v = flow.Value
				else
					v = flow:GetAttribute("Value")
				end
				return (tonumber(v) or 0) * FLOW_SCALE
			end

			-- скиллы игрока без КД: { {name, equipped}, ... }
			local function collectSkills(player)
				local folder = getValuesFolder(player)
				local found = {}

				local cds = {}
				if folder then
					for _, v in ipairs(folder:GetChildren()) do
						cds[v.Name:lower()] = true
					end
				end

				local bp = player:FindFirstChild("Backpack") or player:FindFirstChildOfClass("Backpack")
				local bpVisible = false
				if bp then
					for _, child in ipairs(bp:GetChildren()) do
						if not child:IsA("LuaSourceContainer") and not child:IsA("GuiBase") then
							bpVisible = true
							if not IGNORE_TOOLS[child.Name] and found[child.Name] == nil then
								found[child.Name] = false
							end
						end
					end
				end

				local char = player.Character
				if char then
					for _, child in ipairs(char:GetChildren()) do
						if child:IsA("Tool") and not IGNORE_TOOLS[child.Name] then
							found[child.Name] = true
						end
					end
				end

				local mem = memory[player]
				if not mem then
					mem = {}
					memory[player] = mem
				end

				if bpVisible then
					table.clear(mem)
				else
					for name in pairs(found) do
						mem[name] = true
					end
					for cdName in pairs(cds) do
						local base = cdName:match("^(.+)cooldown$")
						local display = base and KNOWN_SKILLS[base]
						if display and not IGNORE_TOOLS[display] then
							mem[display] = true
						end
					end
					for name in pairs(mem) do
						if found[name] == nil then
							found[name] = false
						end
					end
				end

				local list = {}
				for name, equipped in pairs(found) do
					if cds[norm(name) .. "cooldown"] ~= true then
						table.insert(list, { name = name, equipped = equipped })
					end
				end
				table.sort(list, function(a, b)
					return a.name < b.name
				end)
				return list
			end

			local function evalState(name, equipped, charging, flow)
				local def = SHOT_N[norm(name)]
				if not def then
					return nil
				end
				local present = equipped or not SHOT_REQUIRE_EQUIPPED
				local chargeOk = (not def.charge) or charging
				if def.flow and present and chargeOk and flow >= def.flow then
					return "flow"
				end
				if def.charge and present and charging then
					return "charge"
				end
				if equipped then
					return "equipped"
				end
				return nil
			end

			-- метка над головой
			local function updateWorldSkills(player, lines)
				local gui = worldGuis[player]
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")

				if not ESP.Skills or #lines == 0 or not hrp then
					if gui then
						gui.Enabled = false
					end
					return
				end

				if not gui or gui.Parent ~= hrp then
					if gui then
						gui:Destroy()
					end
					gui = Instance.new("BillboardGui")
					gui.Name = "YokattaSkillAlert"
					gui.AlwaysOnTop = true
					gui.LightInfluence = 0
					gui.StudsOffset = WORLD_OFFSET
					gui.Adornee = hrp
					gui.Parent = hrp

					local lbl = Instance.new("TextLabel")
					lbl.Name = "Text"
					lbl.Size = UDim2.new(1, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.RichText = true
					lbl.Font = Enum.Font.GothamBold
					lbl.TextSize = WORLD_TEXT_SIZE
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.TextStrokeTransparency = 0.3
					lbl.Parent = gui
					worldGuis[player] = gui
				end

				gui.MaxDistance = math.max(ESP.SkillMaxDistance, ESP.NearDistance)
				gui.Enabled = true
				gui.Size = UDim2.fromOffset(WORLD_WIDTH, WORLD_LINE_HEIGHT * #lines + 4)
				gui.Text.Text = table.concat(lines, "\n")
			end

			local function updateSkills(player)
				if player == LocalPlayer or not (ESP.Enabled and ESP.Skills) then
					updateWorldSkills(player, {})
					return
				end

				local folder = getValuesFolder(player)
				local charging = folder ~= nil and folder:FindFirstChild(CHARGING_NAME) ~= nil
				local flow = getFlow(player)
				local showAll = isNearTarget(player)
				local worldLines = {}

				for _, s in ipairs(collectSkills(player)) do
					local state = evalState(s.name, s.equipped, charging, flow)
					local danger = DANGER_N[norm(s.name)] == true
					local charged = state == "charge" or state == "flow"

					if danger or charged or showAll then
						local color
						if charged then
							color = STATE_COLORS[state]
						elseif danger then
							color = DANGER_TEXT
						else
							color = Color3.new(1, 1, 1)
						end
						local prefix = (danger and (DANGER_MARK .. " ") or "")
							.. (charged and (STATE_MARK[state] .. " ") or "")
						table.insert(
							worldLines,
							string.format('<font color="#%s">%s%s</font>', color:ToHex(), prefix, esc(s.name))
						)
					end
				end

				updateWorldSkills(player, worldLines)
			end

			function ESP.RefreshHighlights()
				for _, p in ipairs(Players:GetPlayers()) do
					refreshPlayer(p)
				end
			end

			function ESP.RefreshPlayer(p)
				refreshPlayer(p)
			end

			function ESP.RefreshAll()
				for _, p in ipairs(Players:GetPlayers()) do
					refreshPlayer(p)
					updateSkills(p)
				end
			end

			ESP.GetTeamName = getTeamName
            ESP.GetSkills = collectSkills

			-- подписки
			local function hookPlayer(player)
				if player == LocalPlayer then
					return
				end

				refreshPlayer(player)

				player.CharacterAdded:Connect(function()
					task.wait()
					refreshPlayer(player)
					updateSkills(player)
				end)

				local function hookTeam(obj)
					if obj.Name ~= TEAM_FLAG then
						return
					end
					refreshPlayer(player)
					if obj:IsA("ValueBase") then
						obj.Changed:Connect(function()
							refreshPlayer(player)
						end)
					end
					obj.AttributeChanged:Connect(function()
						refreshPlayer(player)
					end)
				end

				player.ChildAdded:Connect(hookTeam)
				local existing = player:FindFirstChild(TEAM_FLAG)
				if existing then
					hookTeam(existing)
				end
			end

			for _, p in ipairs(Players:GetPlayers()) do
				hookPlayer(p)
			end
			Players.PlayerAdded:Connect(hookPlayer)

			Players.PlayerRemoving:Connect(function(p)
				memory[p] = nil
				marked[p] = nil
				removeHighlight(p)
				local g = worldGuis[p]
				if g then
					g:Destroy()
					worldGuis[p] = nil
				end
			end)

			local skillTimer, hlTimer = 0, 0
			RunService.Heartbeat:Connect(function(dt)
				if not ESP.Enabled then
					return
				end
				skillTimer += dt
				hlTimer += dt

				if skillTimer >= SKILL_REFRESH then
					skillTimer = 0
					if ESP.Skills then
						for _, p in ipairs(Players:GetPlayers()) do
							updateSkills(p)
						end
					end
				end

				if hlTimer >= HIGHLIGHT_REFRESH then
					hlTimer = 0
					for _, p in ipairs(Players:GetPlayers()) do
						refreshPlayer(p)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- ОБЩИЙ СПИСОК МЯЧЕЙ (сканируем карту один раз)
		------------------------------------------------------------
		do
			local NAMES = { ["Football"] = true, ["/e ball"] = true }

			local function isBall(obj)
				return NAMES[obj.Name] == true and (obj:IsA("BasePart") or obj:IsA("Model"))
			end

			for _, obj in ipairs(workspace:GetDescendants()) do
				if isBall(obj) then
					BALLS[obj] = true
				end
			end
			workspace.DescendantAdded:Connect(function(obj)
				if NAMES[obj.Name] and isBall(obj) then
					BALLS[obj] = true
				end
			end)
			workspace.DescendantRemoving:Connect(function(obj)
				BALLS[obj] = nil
			end)
		end

		------------------------------------------------------------
-- ПАТЧ 1 из 2. ЗАМЕНИ целиком блок
--   "ПРЕДИКЦИЯ МЯЧА: Lined Prediction / Curved Pred"
-- (от строки `do` с `local SEARCH_INTERVAL = 0.5` и до его `end`,
--  перед блоком "МЕТКА LastVector3") на код ниже.
-- Нового: красная часть линии ниже заданной высоты + таймер до неё.
------------------------------------------------------------
do
	local SEARCH_INTERVAL = 0.5
	local SUBSTEPS = 5
	local HIST_TIME = 0.30
	local MIN_SAMPLES = 5
	local MIN_SPAN = 0.12
	local MIN_HSPEED = 10

	-- новые настройки красной зоны
	PRED.ZoneEnabled = true -- красная часть + таймер
	PRED.ZoneTimer = true -- показывать таймер
	PRED.ZoneHeight = 47.5 -- высота зоны (студы)
	PRED.ZoneFromGround = true -- true: высота от земли, false: абсолютная Y
	PRED.ZoneColor = Color3.fromRGB(255, 40, 40)

	do
		local old = workspace:FindFirstChild("YokattaPrediction")
		if old then
			old:Destroy()
		end
	end
	local folder = Instance.new("Folder")
	folder.Name = "YokattaPrediction"
	folder.Parent = workspace

	local lines = {}
	local redLines = {}
	local connection, target
	local lastSearch = 0
	local linesVisible = false
	local curvedShown = false
	local hist = setmetatable({}, { __mode = "k" })
	local turnSmooth = setmetatable({}, { __mode = "k" })

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local floorCache = { t = -1, obj = nil, y = nil }

	-- таймер у начала красной зоны
	local timerPart = Instance.new("Part")
	timerPart.Name = "ZoneTimerAnchor"
	timerPart.Size = Vector3.new(0.2, 0.2, 0.2)
	timerPart.Anchored = true
	timerPart.CanCollide = false
	timerPart.CanQuery = false
	timerPart.CanTouch = false
	timerPart.CastShadow = false
	timerPart.Transparency = 1
	timerPart.Parent = folder

	local timerGui = Instance.new("BillboardGui")
	timerGui.Size = UDim2.fromOffset(90, 24)
	timerGui.StudsOffset = Vector3.new(0, 2.5, 0)
	timerGui.AlwaysOnTop = true
	timerGui.LightInfluence = 0
	timerGui.Adornee = timerPart
	timerGui.Enabled = false
	timerGui.Parent = timerPart

	local timerLabel = Instance.new("TextLabel")
	timerLabel.Size = UDim2.fromScale(1, 1)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 16
	timerLabel.TextColor3 = PRED.ZoneColor
	timerLabel.TextStrokeTransparency = 0.2
	timerLabel.Text = ""
	timerLabel.Parent = timerGui

	local function currentColor()
		return curvedShown and PRED.CurvedColor or PRED.LineColor
	end

	local function newLinePart(color)
		local line = Instance.new("Part")
		line.Anchored = true
		line.CanCollide = false
		line.CanQuery = false
		line.CanTouch = false
		line.CastShadow = false
		line.Material = Enum.Material.Neon
		line.Color = color
		line.Size = Vector3.new(PRED.Thickness, PRED.Thickness, 1)
		line.Transparency = 1
		line.Parent = folder
		return line
	end

	local function buildLines()
		for _, l in ipairs(lines) do
			l:Destroy()
		end
		for _, l in ipairs(redLines) do
			l:Destroy()
		end
		table.clear(lines)
		table.clear(redLines)
		for i = 1, PRED.Segments do
			lines[i] = newLinePart(currentColor())
			redLines[i] = newLinePart(PRED.ZoneColor)
		end
		linesVisible = false
	end
	buildLines()

	local function showLines(state)
		if linesVisible == state then
			return
		end
		linesVisible = state
		if not state then
			for _, line in ipairs(lines) do
				line.Transparency = 1
			end
			for _, line in ipairs(redLines) do
				line.Transparency = 1
			end
			timerGui.Enabled = false
		end
		-- при state = true прозрачность каждого сегмента выставляет frame()
	end

	local function setCurvedColor(curved)
		if curvedShown == curved then
			return
		end
		curvedShown = curved
		for _, line in ipairs(lines) do
			line.Color = currentColor()
		end
	end

	local function getClosestBall()
		local character = LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return nil
		end
		local closest, shortest = nil, math.huge
		for obj in pairs(BALLS) do
			if obj.Parent then
				if obj:IsA("BasePart") then
					local d = (hrp.Position - obj.Position).Magnitude
					if d < shortest then
						shortest = d
						closest = obj
					end
				end
			else
				BALLS[obj] = nil
			end
		end
		return closest
	end

	-- ставит сегмент; если он нулевой длины, прячет
	local function setSeg(part, startPos, endPos)
		local distance = (startPos - endPos).Magnitude
		if distance < 0.001 then
			part.Transparency = 1
			return
		end
		part.Transparency = 0
		part.Size = Vector3.new(PRED.Thickness, PRED.Thickness, distance)
		part.CFrame = CFrame.lookAt((startPos + endPos) / 2, endPos)
	end

	-- ===== Lined Prediction =====
	local function simulateLined(obj)
		local startPos = obj.Position
		local velocity = obj.AssemblyLinearVelocity
		local gravity = workspace.Gravity
		local pts = { startPos }
		for i = 1, PRED.Segments do
			local t = (i / PRED.Segments) * PRED.Time
			pts[i + 1] = startPos + velocity * t + Vector3.new(0, -0.5 * gravity * t * t, 0)
		end
		return pts
	end

	-- ===== Curved Pred =====
	local function sampleBalls()
		local now = os.clock()
		for obj in pairs(BALLS) do
			if obj.Parent then
				if obj:IsA("BasePart") then
					local hs = hist[obj]
					if not hs then
						hs = {}
						hist[obj] = hs
					end
					hs[#hs + 1] = { t = now, p = obj.Position }
					while #hs > 2 and now - hs[1].t > HIST_TIME do
						table.remove(hs, 1)
					end
				end
			else
				BALLS[obj] = nil
			end
		end
	end

	local function getFloor(obj)
		local now = os.clock()
		if floorCache.obj == obj and floorCache.y and now - floorCache.t < 0.1 then
			return floorCache.y
		end

		local ignore = { folder, obj }
		local marks = workspace:FindFirstChild("YokattaLastMarks")
		if marks then
			ignore[#ignore + 1] = marks
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				ignore[#ignore + 1] = plr.Character
			end
		end
		rayParams.FilterDescendantsInstances = ignore

		local radius = math.max(obj.Size.X, obj.Size.Y, obj.Size.Z) / 2
		local res = workspace:Raycast(obj.Position, Vector3.new(0, -300, 0), rayParams)
		local y = (res and res.Position.Y or (obj.Position.Y - 3000)) + radius

		floorCache.t, floorCache.obj, floorCache.y = now, obj, y
		return y
	end

	local function estimate(obj, floorY)
		local gravity = workspace.Gravity
		local hs = hist[obj]
		local fallback = obj.AssemblyLinearVelocity
		if not hs or #hs < MIN_SAMPLES then
			return fallback, 0
		end

		local first, last = hs[1], hs[#hs]
		if last.t - first.t < MIN_SPAN then
			return fallback, 0
		end

		local midT = (first.t + last.t) / 2
		local mid = hs[1]
		for _, s in ipairs(hs) do
			if math.abs(s.t - midT) < math.abs(mid.t - midT) then
				mid = s
			end
		end
		local d1, d2 = mid.t - first.t, last.t - mid.t
		if d1 < 0.03 or d2 < 0.03 then
			return fallback, 0
		end

		local v1 = (mid.p - first.p) / d1
		local v2 = (last.p - mid.p) / d2
		local tc1, tc2 = (first.t + mid.t) / 2, (mid.t + last.t) / 2

		local h1 = Vector3.new(v1.X, 0, v1.Z)
		local h2 = Vector3.new(v2.X, 0, v2.Z)

		local omega = 0
		if h1.Magnitude > MIN_HSPEED and h2.Magnitude > MIN_HSPEED then
			local ang = math.atan2(h1.Z * h2.X - h1.X * h2.Z, h1.X * h2.X + h1.Z * h2.Z)
			omega = ang / (tc2 - tc1)
		end

		local prev = turnSmooth[obj] or 0
		omega = prev + (omega - prev) * PRED.TurnSmooth
		turnSmooth[obj] = omega
		if math.abs(omega) < PRED.MinTurn then
			omega = 0
		end
		omega = math.clamp(omega, -PRED.MaxTurn, PRED.MaxTurn)

		local lag = last.t - tc2
		local hv = CFrame.Angles(0, omega * lag, 0) * h2
		local vy = v2.Y - gravity * lag

		local onGround = obj.Position.Y - floorY < 0.3
		if onGround and math.abs(v2.Y) < 3 then
			vy = 0
		end

		return Vector3.new(hv.X, vy, hv.Z), omega
	end

	local function simulateCurved(obj, v, omega, floorY)
		local gravity = workspace.Gravity
		local step = (PRED.Time / PRED.Segments) / SUBSTEPS
		local pos = obj.Position
		local pts = { pos }
		local t = 0

		for i = 1, PRED.Segments do
			for _ = 1, SUBSTEPS do
				local vx, vz, vy = v.X, v.Z, v.Y

				if omega ~= 0 then
					local a = omega * math.exp(-PRED.TurnDecay * t) * step
					local c, s = math.cos(a), math.sin(a)
					vx, vz = vx * c + vz * s, -vx * s + vz * c
				end

				local airborne = pos.Y > floorY + 0.05 or vy > 1
				if airborne then
					vy -= gravity * step
				end

				v = Vector3.new(vx, vy, vz)
				pos = pos + v * step

				if pos.Y < floorY then
					pos = Vector3.new(pos.X, floorY, pos.Z)
					if v.Y < -3 then
						v = Vector3.new(v.X, -v.Y * PRED.Bounce, v.Z)
					else
						v = Vector3.new(v.X, 0, v.Z)
					end
				end
				t += step
			end
			pts[i + 1] = pos
		end
		return pts
	end

	-- ===== красная зона + таймер =====
	local function drawLines(pts)
		local zoneOn = PRED.ZoneEnabled
		local limit
		if zoneOn then
			local base = 0
			if PRED.ZoneFromGround then
				local r = math.max(target.Size.X, target.Size.Y, target.Size.Z) / 2
				base = getFloor(target) - r
			end
			limit = base + PRED.ZoneHeight
		end

		local entryPos, entryTime

		for i, line in ipairs(lines) do
			local a, b = pts[i], pts[i + 1]
			local red = redLines[i]
			if not a or not b then
				line.Transparency = 1
				red.Transparency = 1
			elseif not zoneOn then
				setSeg(line, a, b)
				red.Transparency = 1
			else
				local aBelow, bBelow = a.Y < limit, b.Y < limit
				if aBelow and bBelow then
					line.Transparency = 1
					setSeg(red, a, b)
				elseif not aBelow and not bBelow then
					setSeg(line, a, b)
					red.Transparency = 1
				else
					local t = (limit - a.Y) / (b.Y - a.Y)
					local c = a:Lerp(b, t)
					if aBelow then
						-- выходит из зоны вверх
						setSeg(red, a, c)
						setSeg(line, c, b)
					else
						-- входит в зону сверху
						setSeg(line, a, c)
						setSeg(red, c, b)
						if not entryPos then
							entryPos = c
							entryTime = ((i - 1) + t) / PRED.Segments * PRED.Time
						end
					end
				end
			end
		end

		if zoneOn and PRED.ZoneTimer and entryPos then
			timerPart.Position = entryPos
			timerLabel.Text = string.format("%.2f с", entryTime)
			timerLabel.TextColor3 = PRED.ZoneColor
			timerGui.Enabled = true
		else
			timerGui.Enabled = false
		end
	end

	-- ===== кадр =====
	local function frame()
		local curved = PRED.Mode == "curved"
		if curved then
			sampleBalls()
		end

		if not target or not target.Parent then
			target = nil
			showLines(false)

			local now = os.clock()
			if now - lastSearch < SEARCH_INTERVAL then
				return
			end
			lastSearch = now

			target = getClosestBall()
			if not target then
				return
			end
		end

		linesVisible = true

		local pts
		if curved then
			local floorY = getFloor(target)
			local v, omega = estimate(target, floorY)
			setCurvedColor(omega ~= 0)
			pts = simulateCurved(target, v, omega, floorY)
		else
			setCurvedColor(false)
			pts = simulateLined(target)
		end

		drawLines(pts)
	end

	-- ===== API для панели =====
	function PRED.SetEnabled(v)
		PRED.Enabled = v and true or false
		if PRED.Enabled then
			if connection then
				return
			end
			target = getClosestBall()
			connection = RunService.RenderStepped:Connect(frame)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
			target = nil
			table.clear(turnSmooth)
			showLines(false)
		end
	end

	function PRED.Rebuild()
		buildLines()
	end

	function PRED.ApplyColors()
		for _, line in ipairs(lines) do
			line.Color = currentColor()
		end
	end

	function PRED.ApplyZone()
		for _, line in ipairs(redLines) do
			line.Color = PRED.ZoneColor
		end
		timerLabel.TextColor3 = PRED.ZoneColor
	end

	function PRED.OnModeChanged()
		table.clear(turnSmooth)
		curvedShown = false
		PRED.ApplyColors()
	end
end

		------------------------------------------------------------
		-- МЕТКА LastVector3 МЯЧА (красная сфера, видна сквозь стены)
		-- путь: <мяч> -> InstanceValue -> LastVector3 (.Value)
		------------------------------------------------------------
		do
			local LAST_FOLDER = "InstanceValue"
			local LAST_NAME = "LastVector3"

			do
				local old = workspace:FindFirstChild("YokattaLastMarks")
				if old then
					old:Destroy()
				end
			end
			local folder = Instance.new("Folder")
			folder.Name = "YokattaLastMarks"
			folder.Parent = workspace

			local marks = {} -- [ball] = { part, adorn }

			local function readLastVector(ball)
				local iv = ball:FindFirstChild(LAST_FOLDER)
				local obj = iv and iv:FindFirstChild(LAST_NAME)
				if not obj then
					return nil
				end
				local ok, v = pcall(function()
					if obj:IsA("ValueBase") then
						return obj.Value
					end
					return obj:GetAttribute("Value")
				end)
				if not ok then
					return nil
				end
				if typeof(v) == "Vector3" then
					return v
				end
				if typeof(v) == "CFrame" then
					return v.Position
				end
				return nil
			end

			local function getMark(ball)
				local m = marks[ball]
				if m and m.part.Parent then
					return m
				end

				local part = Instance.new("Part")
				part.Name = "LastVector3Mark"
				part.Shape = Enum.PartType.Ball
				part.Size = Vector3.new(LAST.Radius * 2, LAST.Radius * 2, LAST.Radius * 2)
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Material = Enum.Material.Neon
				part.Color = LAST.Color
				part.Transparency = 1
				part.Parent = folder

				local adorn = Instance.new("SphereHandleAdornment")
				adorn.Adornee = part
				adorn.Radius = LAST.Radius
				adorn.Color3 = LAST.Color
				adorn.Transparency = LAST.Transparency
				adorn.AlwaysOnTop = true
				adorn.ZIndex = 5
				adorn.Visible = false
				adorn.Parent = part

				m = { part = part, adorn = adorn }
				marks[ball] = m
				return m
			end

			function LAST.Hide()
				for _, m in pairs(marks) do
					m.part.Transparency = 1
					m.adorn.Visible = false
				end
			end

			function LAST.Restyle()
				for _, m in pairs(marks) do
					m.part.Size = Vector3.new(LAST.Radius * 2, LAST.Radius * 2, LAST.Radius * 2)
					m.part.Color = LAST.Color
					m.adorn.Radius = LAST.Radius
					m.adorn.Color3 = LAST.Color
				end
			end

			RunService.RenderStepped:Connect(function()
				for ball, m in pairs(marks) do
					if not BALLS[ball] or not ball.Parent then
						m.part:Destroy()
						marks[ball] = nil
					end
				end

				if not LAST.Enabled then
					return
				end

				for ball in pairs(BALLS) do
					if ball.Parent then
						local pos = readLastVector(ball)
						if pos and pos.Magnitude > 0.01 then
							local m = getMark(ball)
							m.part.Position = pos
							m.part.Transparency = LAST.Transparency
							m.adorn.Visible = true
						else
							local m = marks[ball]
							if m then
								m.part.Transparency = 1
								m.adorn.Visible = false
							end
						end
					end
				end
			end)
		end

		------------------------------------------------------------
		-- КАМЕРА: FOV и дистанция зума (вкл/выкл переключателем в панели)
		------------------------------------------------------------
		do
			local camera = workspace.CurrentCamera
			local original = {
				maxZoom = LocalPlayer.CameraMaxZoomDistance,
				minZoom = LocalPlayer.CameraMinZoomDistance,
				fov = camera.FieldOfView,
			}

			local function apply()
				camera = workspace.CurrentCamera
				LocalPlayer.CameraMaxZoomDistance = CAM.MaxZoom
				LocalPlayer.CameraMinZoomDistance = math.min(CAM.MinZoom, CAM.MaxZoom)
				camera.FieldOfView = CAM.FOV
			end

			local function restore()
				camera = workspace.CurrentCamera
				LocalPlayer.CameraMaxZoomDistance = original.maxZoom
				LocalPlayer.CameraMinZoomDistance = original.minZoom
				camera.FieldOfView = original.fov
			end

			-- применяем каждый кадр: игра может сбрасывать значения
			RunService.RenderStepped:Connect(function()
				if CAM.Enabled then
					apply()
				end
			end)

			function CAM.Set(v)
				CAM.Enabled = v and true or false
				if CAM.Enabled then
					apply()
				else
					restore()
				end
			end
		end

		------------------------------------------------------------
-- МЕТКА-КОШКА НАД ВЫБРАННЫМИ ИГРОКАМИ
------------------------------------------------------------
local CATMARK = {
	Enabled = true,
	Color = Color3.fromRGB(255, 220, 0),
	Size = 48, -- пикселей
	Height = 7.5, -- студов над HumanoidRootPart
}

do
	local guis = {} -- [player] = { gui = BillboardGui, tint = { Frame, ... } }
	local OUT = Color3.fromRGB(60, 20, 70)

	local function buildCat(root)
		local tint = {}

		for _, side in ipairs({ -1, 1 }) do
			local x = 0.5 + side * 0.3
			local ear = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(x, 0.2),
				Size = UDim2.fromScale(0.28, 0.28),
				Rotation = 45,
				BackgroundColor3 = CATMARK.Color,
				ZIndex = 1,
			}, { corner(UDim.new(0, 3)), stroke(2, OUT) })
			ear.Parent = root
			tint[#tint + 1] = ear

			create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(x, 0.22),
				Size = UDim2.fromScale(0.14, 0.14),
				Rotation = 45,
				BackgroundColor3 = C.Blush,
				ZIndex = 2,
			}, { corner(UDim.new(0, 2)) }).Parent = root
		end

		local head = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.58),
			Size = UDim2.fromScale(0.92, 0.72),
			BackgroundColor3 = CATMARK.Color,
			ZIndex = 3,
		}, { round(), stroke(2, OUT) })
		head.Parent = root
		tint[#tint + 1] = head

		-- полоски на лбу
		for i = -1, 1 do
			create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5 + i * 0.1, 0.04),
				Size = UDim2.fromScale(0.04, 0.14),
				BackgroundColor3 = OUT,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, { round() }).Parent = head
		end

		-- глаза
		for _, x in ipairs({ 0.3, 0.7 }) do
			local eye = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(x, 0.48),
				Size = UDim2.fromScale(0.14, 0.3),
				BackgroundColor3 = OUT,
				ZIndex = 4,
			}, { round() })
			eye.Parent = head
			create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.62, 0.3),
				Size = UDim2.fromScale(0.45, 0.28),
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 5,
			}, { round() }).Parent = eye
		end

		-- щёчки
		for _, x in ipairs({ 0.14, 0.86 }) do
			create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(x, 0.68),
				Size = UDim2.fromScale(0.14, 0.18),
				BackgroundColor3 = C.Blush,
				BackgroundTransparency = 0.35,
				ZIndex = 4,
			}, { round() }).Parent = head
		end

		-- носик
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.64),
			Size = UDim2.fromScale(0.09, 0.09),
			BackgroundColor3 = Color3.fromRGB(233, 110, 150),
			ZIndex = 5,
		}, { round() }).Parent = head

		-- ротик
		create("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.8),
			Size = UDim2.fromScale(0.26, 0.2),
			BackgroundTransparency = 1,
			Text = "ω",
			TextScaled = true,
			TextColor3 = OUT,
			Font = Enum.Font.GothamBold,
			ZIndex = 5,
		}).Parent = head

		-- усики
		for _, side in ipairs({ -1, 1 }) do
			for k = -1, 1 do
				create("Frame", {
					AnchorPoint = Vector2.new(side == -1 and 1 or 0, 0.5),
					Position = UDim2.fromScale(side == -1 and 0.06 or 0.94, 0.66 + k * 0.07),
					Size = UDim2.new(0.16, 0, 0, 2),
					Rotation = side * k * 12,
					BackgroundColor3 = OUT,
					BorderSizePixel = 0,
					ZIndex = 4,
				}).Parent = head
			end
		end

		-- ошейник с бубенчиком
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.92),
			Size = UDim2.fromScale(0.5, 0.08),
			BackgroundColor3 = Color3.fromRGB(226, 60, 90),
			ZIndex = 6,
		}, { round(), stroke(1, OUT) }).Parent = root
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.96),
			Size = UDim2.fromScale(0.1, 0.1),
			BackgroundColor3 = C.Gold,
			ZIndex = 7,
		}, { round(), stroke(1, OUT) }).Parent = root

		return tint
	end

	local function createCat(hrp)
		local gui = Instance.new("BillboardGui")
		gui.Name = "YokattaCatMark"
		gui.AlwaysOnTop = true
		gui.LightInfluence = 0
		gui.Adornee = hrp
		gui.Size = UDim2.fromOffset(CATMARK.Size, CATMARK.Size)
		gui.StudsOffset = Vector3.new(0, CATMARK.Height, 0)
		gui.Parent = hrp

		local root = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		})
		root.Parent = gui

		return { gui = gui, tint = buildCat(root) }
	end

	local function removeCat(p)
		local g = guis[p]
		if g then
			g.gui:Destroy()
			guis[p] = nil
		end
	end

	local function updateCat(p)
		if p == LocalPlayer or not (ESP.Enabled and CATMARK.Enabled and marked[p]) then
			removeCat(p)
			return
		end
		local char = p.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			removeCat(p)
			return
		end

		local g = guis[p]
		if not g or g.gui.Parent ~= hrp then
			removeCat(p)
			g = createCat(hrp)
			guis[p] = g
		end

		g.gui.Size = UDim2.fromOffset(CATMARK.Size, CATMARK.Size)
		g.gui.StudsOffset = Vector3.new(0, CATMARK.Height, 0)
		for _, f in ipairs(g.tint) do
			f.BackgroundColor3 = CATMARK.Color
		end
	end

	function CATMARK.RefreshPlayer(p)
		updateCat(p)
	end

	function CATMARK.RefreshAll()
		for _, p in ipairs(Players:GetPlayers()) do
			updateCat(p)
		end
	end

	Players.PlayerRemoving:Connect(removeCat)

	-- подхватывает респауны, включение/выключение Esp и т.п.
	local timer = 0
	RunService.Heartbeat:Connect(function(dt)
		timer += dt
		if timer >= 0.2 then
			timer = 0
			CATMARK.RefreshAll()
		end
	end)
end

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ (цвет, бинд, широкий выбор)
		------------------------------------------------------------
		local binds = {} -- [id] = { Key, render }
		local listening = nil -- { obj, render }

		-- строка-карточка внутри собственной группы (чтобы не ломать порядок в списке)
		local function customRow(holder, height)
			local g = UI.Group(holder)
			local f = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			f.Parent = g
			return f, g
		end

		local function rowLabel(row, text, rightPad)
			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -rightPad, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row
		end

		-- выбор цвета: кликни по квадрату -> три слайдера R/G/B
		local function colorRow(holder, text, default, callback)
			local wrap = UI.Group(holder)
            			wrap:SetAttribute("PName", text)
			local header = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			header.Parent = wrap
			rowLabel(header, text, 100)

			local swatch = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(64, 26),
				BackgroundColor3 = default,
				Text = "",
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)), stroke(2, C.Outline) })
			swatch.Parent = header

			local sub = UI.Group(wrap)
			sub.Visible = false

			local cur = {
				r = math.floor(default.R * 255 + 0.5),
				g = math.floor(default.G * 255 + 0.5),
				b = math.floor(default.B * 255 + 0.5),
			}
			local function apply()
				local col = Color3.fromRGB(cur.r, cur.g, cur.b)
				swatch.BackgroundColor3 = col
				if callback then
					callback(col)
				end
			end
			for _, ch in ipairs({ { "r", "R (красный)" }, { "g", "G (зелёный)" }, { "b", "B (синий)" } }) do
				UI.Slider(sub, ch[2], 0, 255, cur[ch[1]], 0, function(v)
					cur[ch[1]] = math.clamp(math.floor(v + 0.5), 0, 255)
					apply()
				end)
			end

			swatch.MouseButton1Click:Connect(function()
				sub.Visible = not sub.Visible
			end)
		end

		-- широкий выбор из нескольких вариантов (для длинных названий)
		local function wideChoice(holder, text, options, default, callback)
			local row = customRow(holder, 44)
			rowLabel(row, text, #options * 132 + 20)

			local box = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(#options * 132 - 4, 28),
				BackgroundTransparency = 1,
			}, {
				create("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})
			box.Parent = row

			local current = default
			local buttons = {}
			local function render()
				for value, btn in pairs(buttons) do
					local on = value == current
					tween(btn, {
						BackgroundColor3 = on and C.AccentStrong or C.Sidebar,
						TextColor3 = on and Color3.new(1, 1, 1) or C.TextMid,
					}, 0.15)
				end
			end

			for i, opt in ipairs(options) do
				local btn = create("TextButton", {
					LayoutOrder = i,
					Size = UDim2.fromOffset(128, 28),
					BackgroundColor3 = C.Sidebar,
					Text = opt[2],
					TextColor3 = C.TextMid,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					AutoButtonColor = false,
				}, { corner(UDim.new(0, 8)) })
				btn.Parent = box
				buttons[opt[1]] = btn
				btn.MouseButton1Click:Connect(function()
					if current == opt[1] then
						return
					end
					current = opt[1]
					render()
					if callback then
						callback(current)
					end
				end)
			end
			render()
            			Persist.add(holder, text, "choice", function() return current end, function(v)
				if v ~= current then
					current = v
					render()
					if callback then callback(current) end
				end
			end)
		end

		-- строка бинда: клик -> нажми клавишу (Esc/Backspace — очистить)
		local function bindRow(holder, id, text, default)
			local row = customRow(holder, 40)
			rowLabel(row, text, 140)

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row

			local obj = { Key = default }
			obj.render = function()
				btn.Text = obj.Key and obj.Key.Name or "—"
			end
			obj.render()

			btn.MouseButton1Click:Connect(function()
				if listening and listening.obj ~= obj then
					listening.render()
				end
				listening = { obj = obj, render = obj.render }
				btn.Text = "Нажми клавишу…"
			end)
            			Persist.addId("bind/Esp/" .. id, "bind", function() return obj.Key end,
				function(k) obj.Key = k; obj.render() end)
			binds[id] = obj
			return obj
		end

		------------------------------------------------------------
		-- UI: ESP / ЦВЕТА
		------------------------------------------------------------
		UI.Section(h, "ESP")
		local masterToggle = UI.Toggle(h, "Esp (подсветка + скиллы)", ESP.Enabled, function(v)
			ESP.Enabled = v
			ESP.RefreshAll()
		end)
		UI.Toggle(h, "Подсветка игроков", ESP.Highlight, function(v)
			ESP.Highlight = v
			ESP.RefreshHighlights()
		end)
		UI.Slider(h, "Прозрачность заливки", 0, 1, ESP.FillTransparency, 2, function(v)
			ESP.FillTransparency = v
			ESP.RefreshHighlights()
		end)
		colorRow(h, "Цвет красной команды", ESP.TeamColors.red, function(c)
			ESP.TeamColors.red = c
			ESP.RefreshHighlights()
		end)
		colorRow(h, "Цвет синей команды", ESP.TeamColors.blue, function(c)
			ESP.TeamColors.blue = c
			ESP.RefreshHighlights()
		end)
		colorRow(h, "Цвет выбранных игроков", ESP.MarkColor, function(c)
			ESP.MarkColor = c
			ESP.RefreshHighlights()
		end)

		------------------------------------------------------------
		-- UI: ИГРОКИ (выбор прямо в панели)
		------------------------------------------------------------
		UI.Section(h, "ИГРОКИ")
UI.Note(h, "Включи игрока — он подсветится цветом выбранных игроков и над ним появится кошка. Под именем видны команда и скиллы (● — в руках).")
local playersGroup = UI.Group(h)
local playerRows = {}

local function teamInfo(p)
	local name = ESP.GetTeamName(p)
	if not name then
		return "Команда: —", C.TextMid
	end
	return "Команда: " .. name, ESP.TeamColors[name] or C.TextMid
end

local function skillsInfo(p)
	local ok, list = pcall(ESP.GetSkills, p)
	if not ok or not list or #list == 0 then
		return "Скиллы: —"
	end
	local names = {}
	for _, s in ipairs(list) do
		names[#names + 1] = (s.equipped and "● " or "") .. s.name
	end
	return "Скиллы: " .. table.concat(names, ", ")
end

local function addPlayerRow(p)
	if p == LocalPlayer or playerRows[p] then
		return
	end
	local g = UI.Group(playersGroup)

	local row = create("Frame", {
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Card,
		BorderSizePixel = 0,
	}, {
		corner(UDim.new(0, 10)),
		create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
	})
	row.Parent = g

	local info = create("Frame", {
		Size = UDim2.new(1, -70, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 14),
		}),
		create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	info.Parent = row

	create("TextLabel", {
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = p.DisplayName,
		TextColor3 = C.TextDark,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}).Parent = info

	local teamLbl = create("TextLabel", {
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = C.TextMid,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	teamLbl.Parent = info

	local skillsLbl = create("TextLabel", {
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = "",
		TextWrapped = true,
		TextColor3 = C.TextMid,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	skillsLbl.Parent = info

	-- переключатель справа
	local track = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(44, 22),
		BackgroundColor3 = C.TrackOff,
		Text = "",
		AutoButtonColor = false,
	}, { round() })
	track.Parent = row

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, { round() })
	knob.Parent = track

	local state = marked[p] == true
	local function render(animate)
		local pos = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		local col = state and C.AccentStrong or C.TrackOff
		if animate then
			tween(knob, { Position = pos }, 0.18)
			tween(track, { BackgroundColor3 = col }, 0.18)
		else
			knob.Position = pos
			track.BackgroundColor3 = col
		end
	end
	render(false)

	local function apply()
		marked[p] = state or nil
		ESP.RefreshPlayer(p)
		CATMARK.RefreshPlayer(p)
	end

	track.MouseButton1Click:Connect(function()
		state = not state
		render(true)
		apply()
	end)

	local toggle = {}
	function toggle.Set(v)
		state = v and true or false
		render(true)
		apply()
	end
	function toggle.Get()
		return state
	end

	local function refresh()
		local text, color = teamInfo(p)
		teamLbl.Text = text
		teamLbl.TextColor3 = color
		skillsLbl.Text = skillsInfo(p)
	end
	refresh()

	playerRows[p] = { group = g, toggle = toggle, refresh = refresh }
end

for _, p in ipairs(Players:GetPlayers()) do
	addPlayerRow(p)
end
Players.PlayerAdded:Connect(addPlayerRow)
Players.PlayerRemoving:Connect(function(p)
	local r = playerRows[p]
	if r then
		r.group:Destroy()
		playerRows[p] = nil
	end
end)

-- обновляем команды и скиллы, пока открыта вкладка Esp
task.spawn(function()
	while Gui.Parent do
		if isOpen and currentTab == "Esp" then
			for _, r in pairs(playerRows) do
				r.refresh()
			end
		end
		task.wait(0.5)
	end
end)

UI.Button(h, "Снять все метки", function()
	for _, r in pairs(playerRows) do
		r.toggle.Set(false)
	end
end)

------------------------------------------------------------
-- UI: КОШКА НАД ВЫБРАННЫМИ
------------------------------------------------------------
UI.Section(h, "КОШКА НАД ВЫБРАННЫМИ")
UI.Toggle(h, "Кошка над выбранными игроками", CATMARK.Enabled, function(v)
	CATMARK.Enabled = v
	CATMARK.RefreshAll()
end)
colorRow(h, "Цвет кошки", CATMARK.Color, function(c)
	CATMARK.Color = c
	CATMARK.RefreshAll()
end)
UI.Slider(h, "Размер кошки (px)", 16, 150, CATMARK.Size, 0, function(v)
	CATMARK.Size = v
	CATMARK.RefreshAll()
end)
UI.Slider(h, "Высота над головой (студы)", 3, 20, CATMARK.Height, 1, function(v)
	CATMARK.Height = v
	CATMARK.RefreshAll()
end)
		------------------------------------------------------------
		-- UI: СКИЛЛЫ НАД ГОЛОВОЙ
		------------------------------------------------------------
		UI.Section(h, "СКИЛЛЫ НАД ГОЛОВОЙ")
		local skillsToggle = UI.Toggle(h, "Показывать скиллы", ESP.Skills, function(v)
			ESP.Skills = v
			ESP.RefreshAll()
		end)
		UI.Slider(h, "Дистанция показа (студы)", 10, 300, ESP.SkillMaxDistance, 0, function(v)
			ESP.SkillMaxDistance = v
		end)
		UI.Toggle(h, "Вблизи показывать ВСЕ скиллы", ESP.NearShowAll, function(v)
			ESP.NearShowAll = v
		end)
		UI.Slider(h, "Дистанция «вблизи» (студы)", 5, 150, ESP.NearDistance, 0, function(v)
			ESP.NearDistance = v
		end)
		UI.Toggle(h, "«Вблизи» только для врагов", ESP.NearEnemyOnly, function(v)
			ESP.NearEnemyOnly = v
		end)
		UI.Note(h, "Всегда показываются опасные скиллы (⚠) и заряженные удары (◆ / ✦).")

		------------------------------------------------------------
		-- UI: ПРЕДИКЦИЯ МЯЧА
		------------------------------------------------------------
		UI.Section(h, "ПРЕДИКЦИЯ МЯЧА")
		local predToggle = UI.Toggle(h, "Предикция мяча", PRED.Enabled, function(v)
			PRED.SetEnabled(v)
		end)

		local curvedGroup
		wideChoice(h, "Режим предикции", {
			{ "lined", "Lined Prediction" },
			{ "curved", "Curved Pred" },
		}, PRED.Mode, function(v)
			PRED.Mode = v
			if curvedGroup then
				curvedGroup.Visible = v == "curved"
			end
			PRED.OnModeChanged()
		end)

		UI.Slider(h, "Время предикции (сек)", 0.5, 5, PRED.Time, 1, function(v)
			PRED.Time = v
		end)
		UI.Slider(h, "Сегментов линии", 5, 60, PRED.Segments, 0, function(v)
			PRED.Segments = math.floor(v + 0.5)
			PRED.Rebuild()
		end)
		UI.Slider(h, "Толщина линии", 0.05, 1, PRED.Thickness, 2, function(v)
			PRED.Thickness = v
		end)
		colorRow(h, "Цвет линии (прямая)", PRED.LineColor, function(c)
			PRED.LineColor = c
			PRED.ApplyColors()
		end)
		colorRow(h, "Цвет линии (кручёная)", PRED.CurvedColor, function(c)
			PRED.CurvedColor = c
			PRED.ApplyColors()
		end)

		curvedGroup = UI.Group(h)
		curvedGroup.Visible = PRED.Mode == "curved"
		UI.Section(curvedGroup, "НАСТРОЙКИ CURVED PRED")
		UI.Slider(curvedGroup, "Мин. кручение (рад/с)", 0, 2, PRED.MinTurn, 2, function(v)
			PRED.MinTurn = v
		end)
		UI.Slider(curvedGroup, "Макс. кручение (рад/с)", 1, 20, PRED.MaxTurn, 1, function(v)
			PRED.MaxTurn = v
		end)
		UI.Slider(curvedGroup, "Сглаживание кручения", 0.05, 1, PRED.TurnSmooth, 2, function(v)
			PRED.TurnSmooth = v
		end)
		UI.Slider(curvedGroup, "Затухание кручения (1/с)", 0, 3, PRED.TurnDecay, 2, function(v)
			PRED.TurnDecay = v
		end)
		UI.Slider(curvedGroup, "Отскок от земли", 0, 1, PRED.Bounce, 2, function(v)
			PRED.Bounce = v
		end)
		UI.Note(
			curvedGroup,
			"Lined — прямая линия по скорости мяча + гравитация. Curved — по истории позиций гнёт линию по дуге (кручёные удары), учитывает землю и отскок. Мин. кручение: чем меньше, тем чувствительнее."
		)

				UI.Section(h, "КРАСНАЯ ЗОНА ЛИНИИ")
		UI.Toggle(h, "Красная зона + таймер", PRED.ZoneEnabled, function(v)
			PRED.ZoneEnabled = v
		end)
		UI.Toggle(h, "Показывать таймер", PRED.ZoneTimer, function(v)
			PRED.ZoneTimer = v
		end)
		UI.Slider(h, "Высота зоны (студы)", 0, 200, PRED.ZoneHeight, 1, function(v)
			PRED.ZoneHeight = v
		end)
		UI.Toggle(h, "Высота от земли (выкл = абсолютная Y)", PRED.ZoneFromGround, function(v)
			PRED.ZoneFromGround = v
		end)
		colorRow(h, "Цвет красной зоны", PRED.ZoneColor, function(c)
			PRED.ZoneColor = c
			PRED.ApplyZone()
		end)
		UI.Note(h, "Часть линии ниже заданной высоты красится в цвет зоны, а рядом с её началом показывается таймер. Если мяч уже в зоне, таймер скрыт.")
		------------------------------------------------------------
		-- UI: МЕТКА LastVector3
		------------------------------------------------------------
		UI.Section(h, "МЕТКА LastVector3")
		local lastToggle = UI.Toggle(h, "Метка LastVector3 (сфера)", LAST.Enabled, function(v)
			LAST.Enabled = v
			if not v then
				LAST.Hide()
			end
		end)
		UI.Slider(h, "Радиус метки", 0.2, 10, LAST.Radius, 1, function(v)
			LAST.Radius = v
			LAST.Restyle()
		end)
		colorRow(h, "Цвет метки", LAST.Color, function(c)
			LAST.Color = c
			LAST.Restyle()
		end)

		------------------------------------------------------------
		-- UI: КАМЕРА / FOV
		------------------------------------------------------------
		UI.Section(h, "КАМЕРА / FOV")
		UI.Toggle(h, "Свой FOV и зум", CAM.Enabled, function(v)
			CAM.Set(v)
		end)
		UI.Slider(h, "FOV (макс. 120)", 30, 120, CAM.FOV, 0, function(v)
			CAM.FOV = math.clamp(v, 1, 120)
		end)
		UI.Slider(h, "Макс. дистанция камеры", 10, 1000, CAM.MaxZoom, 0, function(v)
			CAM.MaxZoom = v
		end)
		UI.Slider(h, "Мин. дистанция камеры", 0.5, 20, CAM.MinZoom, 1, function(v)
			CAM.MinZoom = v
		end)

		------------------------------------------------------------
		-- UI: БИНДЫ
		------------------------------------------------------------
		UI.Section(h, "БИНДЫ (нажми на кнопку, затем клавишу; Esc/Backspace — очистить)")
		bindRow(h, "master", "Esp вкл/выкл", nil)
		bindRow(h, "skills", "Скиллы вкл/выкл", nil)
		bindRow(h, "prediction", "Предикция вкл/выкл", nil)
		bindRow(h, "last", "Метка LastVector3 вкл/выкл", nil)
		UI.Note(
			h,
			"Клавиши панели (M и переключатель курсора) занять нельзя. Если одна клавиша занята под другое действие здесь, оно очистится."
		)

		local actions = {
			master = function()
				masterToggle.Set(not masterToggle.Get())
			end,
			skills = function()
				skillsToggle.Set(not skillsToggle.Get())
			end,
			prediction = function()
				predToggle.Set(not predToggle.Get())
			end,
			last = function()
				lastToggle.Set(not lastToggle.Get())
			end,
		}

		UIS.InputBegan:Connect(function(input, gp)
			-- режим «жду клавишу для бинда»
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local obj, render = listening.obj, listening.render
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						obj.Key = nil
					elseif key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
						-- клавиша занята панелью — оставляем прежний бинд
					else
						for _, other in pairs(binds) do
							if other ~= obj and other.Key == key then
								other.Key = nil
								other.render()
							end
						end
						obj.Key = key
					end
					render()
				end
				return
			end

			if gp then
				return
			end
			for id, b in pairs(binds) do
				if b.Key and input.KeyCode == b.Key and actions[id] then
					actions[id]()
					break
				end
			end
		end)
	end
end

------------------------------------------------------------
-- ВКЛАДКА TROLL: Spin / Dance / Follow / Ball Orbit / Уведомления / TROLL PACK
------------------------------------------------------------
do
	local LocalPlayer = Players.LocalPlayer
	local SoundService = game:GetService("SoundService")
	local Debris = game:GetService("Debris")
	local h = Holders.Troll

	if h then
		UI.ClearPlaceholder(h)

		local function getChar()
			local c = LocalPlayer.Character
			return c,
				c and c:FindFirstChild("HumanoidRootPart"),
				c and c:FindFirstChildOfClass("Humanoid")
		end

		---------------------------------------------------------
		-- SPIN
		---------------------------------------------------------
		local SPIN = { Enabled = false, Speed = 12 }
		local spinHum

		local function stopSpin()
			if spinHum and spinHum.Parent then
				spinHum.AutoRotate = true
			end
			spinHum = nil
		end

		RunService.Heartbeat:Connect(function(dt)
			if not SPIN.Enabled then
				return
			end
			local _, root, hum = getChar()
			if not root or not hum then
				return
			end
			if hum.AutoRotate then
				hum.AutoRotate = false
				spinHum = hum
			end
			root.CFrame = root.CFrame * CFrame.Angles(0, SPIN.Speed * dt, 0)
		end)

		UI.Section(h, "SPIN")
		UI.Toggle(h, "Spin (крутиться)", false, function(v)
			SPIN.Enabled = v
			if not v then
				stopSpin()
			end
		end)
		UI.Slider(h, "Скорость (рад/с)", 1, 40, SPIN.Speed, 0, function(v)
			SPIN.Speed = v
		end)
		UI.Note(h, "Пока Spin включён, он перехватывает поворот персонажа (конфликтует с Lock-On и режимами Troll Pack).")

		---------------------------------------------------------
		-- DANCE / СВОЯ АНИМАЦИЯ
		---------------------------------------------------------
		local EMO = { Dance = false, Interval = 3, AnimOn = false, AnimId = "", AnimSpeed = 1 }
		local EMOTES = { "dance", "dance2", "dance3", "cheer", "laugh", "point", "wave" }
		local danceToken = 0

		local function startDance()
			danceToken += 1
			local my = danceToken
			task.spawn(function()
				local i = 0
				while EMO.Dance and danceToken == my do
					local _, _, hum = getChar()
					if hum then
						i = i % #EMOTES + 1
						pcall(function()
							hum:PlayEmote(EMOTES[i])
						end)
					end
					task.wait(EMO.Interval)
				end
			end)
		end

		local animTrack
		local function stopAnim()
			if animTrack then
				pcall(function()
					animTrack:Stop()
				end)
				animTrack = nil
			end
		end

		local function playAnim()
			stopAnim()
			if not EMO.AnimOn or EMO.AnimId == "" then
				return
			end
			local _, _, hum = getChar()
			local animator = hum and hum:FindFirstChildOfClass("Animator")
			if not animator then
				return
			end
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://" .. EMO.AnimId
			local ok, track = pcall(function()
				return animator:LoadAnimation(anim)
			end)
			if not ok or not track then
				return
			end
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action4
			track:Play()
			track:AdjustSpeed(EMO.AnimSpeed)
			animTrack = track
		end

		LocalPlayer.CharacterAdded:Connect(function()
			animTrack = nil
			task.delay(1, function()
				if EMO.AnimOn then
					playAnim()
				end
			end)
		end)

		UI.Section(h, "DANCE / АНИМАЦИЯ")
		UI.Toggle(h, "Эмоуты по кругу", false, function(v)
			EMO.Dance = v
			if v then
				startDance()
			else
				danceToken += 1
			end
		end)
		UI.Slider(h, "Пауза между эмоутами (сек)", 1, 10, EMO.Interval, 1, function(v)
			EMO.Interval = v
		end)
		UI.Toggle(h, "Своя анимация (по ID)", false, function(v)
			EMO.AnimOn = v
			if v then
				playAnim()
			else
				stopAnim()
			end
		end)
		UI.TextInput(h, "ID анимации", "", "число", function(t)
			EMO.AnimId = t:match("%d+") or ""
			if EMO.AnimOn then
				playAnim()
			end
			return false
		end)
		UI.Slider(h, "Скорость анимации", 0.1, 3, EMO.AnimSpeed, 1, function(v)
			EMO.AnimSpeed = v
			if animTrack then
				animTrack:AdjustSpeed(v)
			end
		end)
		UI.Note(h, "Эмоуты работают только если в игре стоит стандартный Animate и персонаж стоит на месте. Своя анимация загрузится, только если ID доступен этой игре (обычно анимации от Roblox).")

		---------------------------------------------------------
		-- FOLLOW
		---------------------------------------------------------
		local FOL = { Enabled = false, Target = nil, Distance = 5 }
		local statusNote

		local function setTarget(p)
			FOL.Target = p
			statusNote.Text = p and ("Цель: " .. p.DisplayName) or "Цель: нет"
		end

		local function findPlayer(q)
			q = q:lower()
			if q == "" then
				return nil
			end
			local partial
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					local n, d = p.Name:lower(), p.DisplayName:lower()
					if n == q or d == q then
						return p
					end
					if not partial and (n:find(q, 1, true) or d:find(q, 1, true)) then
						partial = p
					end
				end
			end
			return partial
		end

		local function nearestPlayer()
			local _, root = getChar()
			if not root then
				return nil
			end
			local best, bestD = nil, math.huge
			for _, p in ipairs(Players:GetPlayers()) do
				local ch = p ~= LocalPlayer and p.Character
				local r = ch and ch:FindFirstChild("HumanoidRootPart")
				if r then
					local d = (r.Position - root.Position).Magnitude
					if d < bestD then
						best, bestD = p, d
					end
				end
			end
			return best
		end

		local folTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			if not FOL.Enabled or not FOL.Target then
				return
			end
			folTimer += dt
			if folTimer < 0.1 then
				return
			end
			folTimer = 0

			local _, root, hum = getChar()
			local tch = FOL.Target.Character
			local troot = tch and tch:FindFirstChild("HumanoidRootPart")
			if not root or not hum or not troot then
				return
			end

			local flatDiff = Vector3.new(root.Position.X - troot.Position.X, 0, root.Position.Z - troot.Position.Z)
			if flatDiff.Magnitude <= FOL.Distance + 1 then
				hum:MoveTo(root.Position)
				return
			end
			hum:MoveTo(troot.Position + flatDiff.Unit * FOL.Distance)
		end)

		Players.PlayerRemoving:Connect(function(p)
			if p == FOL.Target then
				setTarget(nil)
			end
		end)

		UI.Section(h, "FOLLOW")
		UI.Toggle(h, "Следовать за игроком", false, function(v)
			FOL.Enabled = v
			if not v then
				local _, root, hum = getChar()
				if root and hum then
					hum:MoveTo(root.Position)
				end
			end
		end)
		UI.TextInput(h, "Ник игрока", "", "ник + Enter", function(t, enter)
			if not enter then
				return false
			end
			local p = findPlayer(t)
			setTarget(p)
			return p ~= nil
		end)
		statusNote = UI.Note(h, "Цель: нет")
		UI.Button(h, "Взять ближайшего игрока", function()
			setTarget(nearestPlayer())
		end)
		UI.Slider(h, "Дистанция (студы)", 2, 30, FOL.Distance, 0, function(v)
			FOL.Distance = v
		end)

		---------------------------------------------------------
		-- BALL ORBIT
		---------------------------------------------------------
		local ORB = { Enabled = false, Radius = 8, Speed = 4, Height = 3 }
		local orbAngle = 0
		local ballCache, ballSearchT = nil, 0
		local BALL_FOLDER = "Messi"
		local BALL_NAMES = { ["/e ball"] = true, ["Football"] = true }

		local function ballPart(obj)
			if not obj then
				return nil
			end
			if obj:IsA("BasePart") then
				return obj
			end
			if obj:IsA("Model") then
				return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
			end
			return nil
		end

		local function findBall()
			if ballCache and ballCache.Parent then
				return ballCache
			end
			ballCache = nil
			local now = os.clock()
			if now - ballSearchT < 1 then
				return nil
			end
			ballSearchT = now

			local found
			local folder = workspace:FindFirstChild(BALL_FOLDER)
			if folder then
				for _, c in ipairs(folder:GetChildren()) do
					if BALL_NAMES[c.Name] then
						found = c
						break
					end
				end
			end
			if not found then
				found = workspace:FindFirstChild("/e ball", true) or workspace:FindFirstChild("Football", true)
			end
			ballCache = ballPart(found)
			return ballCache
		end

		RunService.Heartbeat:Connect(function(dt)
			if not ORB.Enabled then
				return
			end
			local _, root = getChar()
			local ball = root and findBall()
			if not ball then
				return
			end
			orbAngle += ORB.Speed * dt
			local offset = Vector3.new(math.cos(orbAngle) * ORB.Radius, ORB.Height, math.sin(orbAngle) * ORB.Radius)
			ball.AssemblyLinearVelocity = Vector3.zero
			ball.AssemblyAngularVelocity = Vector3.zero
			ball.CFrame = CFrame.new(root.Position + offset)
		end)

		UI.Section(h, "BALL ORBIT")
		UI.Toggle(h, "Мяч крутится вокруг тебя", false, function(v)
			ORB.Enabled = v
		end)
		UI.Slider(h, "Радиус (студы)", 3, 30, ORB.Radius, 0, function(v)
			ORB.Radius = v
		end)
		UI.Slider(h, "Скорость", 0.5, 15, ORB.Speed, 1, function(v)
			ORB.Speed = v
		end)
		UI.Slider(h, "Высота", 0, 15, ORB.Height, 1, function(v)
			ORB.Height = v
		end)
		UI.Note(h, "Другие увидят орбиту, только если сервер отдал тебе физику мяча (обычно когда ты рядом с ним). Иначе мяч двигается только у тебя на экране.")

		---------------------------------------------------------
		-- УВЕДОМЛЕНИЯ И ЗВУКИ
		---------------------------------------------------------
		local DEFAULT_SOUND = "rbxasset://sounds/electronicpingshort.wav"
		local SND = { Enabled = true, Id = DEFAULT_SOUND, Volume = 1 }
		local NOTI = { Toasts = true, JoinLeave = true, Near = false, NearRadius = 30, Duration = 3 }

		do
			local old = parent:FindFirstChild("YokattaNotify")
			if old then
				old:Destroy()
			end
		end

		local NotifyGui = create("ScreenGui", {
			Name = "YokattaNotify",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 997,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		NotifyGui.Parent = parent

		local stack = create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 16),
			Size = UDim2.fromOffset(250, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
			}),
		})
		stack.Parent = NotifyGui

		local function playSound()
			if not SND.Enabled then
				return
			end
			local s = Instance.new("Sound")
			s.SoundId = SND.Id
			s.Volume = SND.Volume
			s.Parent = SoundService
			s:Play()
			Debris:AddItem(s, 6)
		end

		local toastOrder = 0
		local function notify(text, color)
			if NOTI.Toasts then
				toastOrder += 1
				local toast = create("CanvasGroup", {
					LayoutOrder = toastOrder,
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = C.Bg,
					BorderSizePixel = 0,
					GroupTransparency = 1,
				}, {
					corner(UDim.new(0, 10)),
					create("UIStroke", { Color = color or C.HeaderLine, Thickness = 2 }),
					create("TextLabel", {
						Position = UDim2.fromOffset(10, 0),
						Size = UDim2.new(1, -20, 1, 0),
						BackgroundTransparency = 1,
						Text = text,
						TextColor3 = C.TextDark,
						Font = Enum.Font.GothamMedium,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
					}),
				})
				toast.Parent = stack
				tween(toast, { GroupTransparency = 0 }, 0.2)
				task.delay(NOTI.Duration, function()
					local t = tween(toast, { GroupTransparency = 1 }, 0.3)
					t.Completed:Connect(function()
						toast:Destroy()
					end)
				end)
			end
			playSound()
		end
		shared.YokattaNotify = notify -- можно звать из других скриптов: shared.YokattaNotify("текст")

		local GREEN = Color3.fromRGB(110, 200, 140)
		local RED = Color3.fromRGB(226, 90, 130)

		Players.PlayerAdded:Connect(function(p)
			if NOTI.JoinLeave then
				notify(p.DisplayName .. " зашёл", GREEN)
			end
		end)

		local near = {}
		Players.PlayerRemoving:Connect(function(p)
			near[p] = nil
			if NOTI.JoinLeave then
				notify(p.DisplayName .. " вышел", RED)
			end
		end)

		local nearTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			if not NOTI.Near then
				return
			end
			nearTimer += dt
			if nearTimer < 0.25 then
				return
			end
			nearTimer = 0

			local _, root = getChar()
			if not root then
				return
			end
			for _, p in ipairs(Players:GetPlayers()) do
				local ch = p ~= LocalPlayer and p.Character
				local r = ch and ch:FindFirstChild("HumanoidRootPart")
				if r then
					local d = (r.Position - root.Position).Magnitude
					if d <= NOTI.NearRadius and not near[p] then
						near[p] = true
						notify(p.DisplayName .. " рядом", C.Accent)
					elseif d > NOTI.NearRadius + 5 then
						near[p] = nil
					end
				end
			end
		end)

		UI.Section(h, "УВЕДОМЛЕНИЯ И ЗВУКИ")
		UI.Toggle(h, "Всплывающие уведомления", NOTI.Toasts, function(v)
			NOTI.Toasts = v
		end)
		UI.Toggle(h, "Звук уведомлений", SND.Enabled, function(v)
			SND.Enabled = v
		end)
		UI.TextInput(h, "Свой звук (ID или путь)", "", "число или rbxassetid://…", function(t)
			local s = t:match("^%s*(.-)%s*$")
			if s == "" then
				SND.Id = DEFAULT_SOUND
			elseif s:match("^%d+$") then
				SND.Id = "rbxassetid://" .. s
			else
				SND.Id = s
			end
			return false
		end)
		UI.Slider(h, "Громкость", 0, 3, SND.Volume, 1, function(v)
			SND.Volume = v
		end)
		UI.Toggle(h, "Вход / выход игроков", NOTI.JoinLeave, function(v)
			NOTI.JoinLeave = v
		end)
		UI.Toggle(h, "Игрок подошёл близко", NOTI.Near, function(v)
			NOTI.Near = v
			if not v then
				table.clear(near)
			end
		end)
		UI.Slider(h, "Радиус «близко» (студы)", 5, 100, NOTI.NearRadius, 0, function(v)
			NOTI.NearRadius = v
		end)
		UI.Button(h, "Тест уведомления", function()
			notify("Тест уведомления", C.Accent)
		end)
		UI.Note(h, "Пустое поле звука возвращает стандартный сигнал. Пользовательский звук должен быть доступен в этой игре, иначе он не проиграется.")

		------------------------------------------------------------------
		------------------------------------------------------------------
		-- TROLL PACK
		------------------------------------------------------------------
		------------------------------------------------------------------
		do
			local player = LocalPlayer
			local Workspace = workspace

			local function cam()
				return Workspace.CurrentCamera
			end

			local S = {
				Speed = 80, -- скорость полётов / Flash / Wander
				LoongHeight = 5,
				MingleRadius = 30,
				MingleSpeed = 5,
				BankaiRadius = 50,
				BankaiDelay = 0.1,
				DashPower = 120,
				LiftSpeed = 40,
				AnchorPos = nil,
			}

			---------------------------------------------------------
			-- ХЕЛПЕРЫ
			---------------------------------------------------------
			local function getAliveChar()
				local char = player.Character
				if not char then
					return
				end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hrp and hum and hum.Health > 0 then
					return char, hrp, hum
				end
			end

			local function flat(v)
				local f = Vector3.new(v.X, 0, v.Z)
				if f.Magnitude < 1e-4 then
					return Vector3.new(0, 0, -1)
				end
				return f.Unit
			end

			local function lookCF(dir)
				local up = math.abs(dir.Y) > 0.98 and Vector3.xAxis or Vector3.yAxis
				return CFrame.lookAt(Vector3.zero, dir, up)
			end

			local TILT = CFrame.Angles(math.rad(-90), 0, 0) -- поза «супермена»

			-- Bin: сборщик мусора (соединения, объекты, функции очистки)
			local Bin = {}
			Bin.__index = Bin
			function Bin.new()
				return setmetatable({ items = {} }, Bin)
			end
			function Bin:add(x)
				table.insert(self.items, x)
				return x
			end
			function Bin:clear()
				for i = #self.items, 1, -1 do
					local x = self.items[i]
					local t = typeof(x)
					if t == "RBXScriptConnection" then
						x:Disconnect()
					elseif t == "Instance" then
						x:Destroy()
					elseif t == "function" then
						pcall(x)
					end
				end
				table.clear(self.items)
			end

			-- ввод (клавиатура + мобильный джойстик)
			local controls
			task.spawn(function()
				local ok, mod = pcall(function()
					return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
				end)
				if ok then
					local ok2, c = pcall(function()
						return mod:GetControls()
					end)
					if ok2 then
						controls = c
					end
				end
			end)

			local function getMove()
				if controls then
					local ok, v = pcall(function()
						return controls:GetMoveVector()
					end)
					if ok and v then
						return v
					end
				end
				local x = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
				local z = (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
				return Vector3.new(x, 0, z)
			end

			local function getVertical()
				local v = 0
				if UIS:IsKeyDown(Enum.KeyCode.Space) then
					v += 1
				end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
					v -= 1
				end
				return v
			end

			local function makeMover(bin, hrp, withAlign)
				local att = bin:add(Instance.new("Attachment"))
				att.Parent = hrp
				local lv = bin:add(Instance.new("LinearVelocity"))
				lv.Attachment0 = att
				lv.MaxForce = math.huge
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
				lv.RelativeTo = Enum.ActuatorRelativeTo.World
				lv.VectorVelocity = Vector3.zero
				lv.Parent = hrp
				local ao
				if withAlign then
					ao = bin:add(Instance.new("AlignOrientation"))
					ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
					ao.Attachment0 = att
					ao.MaxTorque = math.huge
					ao.MaxAngularVelocity = math.huge
					ao.Responsiveness = 60
					ao.CFrame = hrp.CFrame.Rotation
					ao.Parent = hrp
				end
				return lv, ao
			end

			local function platformStand(bin, hum)
				hum.PlatformStand = true
				bin:add(function()
					hum.PlatformStand = false
				end)
			end

			---------------------------------------------------------
			-- СИСТЕМА РЕЖИМОВ
			---------------------------------------------------------
			local Modes, Order = {}, {}
			local refreshUI = function() end

			local function defMode(name, label, exclusive, persist, start)
				Modes[name] = {
					label = label,
					exclusive = exclusive,
					persist = persist,
					on = false,
					bin = Bin.new(),
					start = start,
				}
				table.insert(Order, name)
			end

			local function setMode(name, on)
				local m = Modes[name]
				if m.on == on then
					return
				end
				if on and m.exclusive then
					for n, o in pairs(Modes) do
						if o.exclusive and o.on and n ~= name then
							setMode(n, false)
						end
					end
				end
				m.on = on
				if on then
					local ok, res = pcall(m.start, m.bin)
					if not ok or res == false then
						if not ok then
							warn("[Troll] " .. name .. ": " .. tostring(res))
						end
						m.bin:clear()
						m.on = false
					end
				else
					m.bin:clear()
				end
				refreshUI(name)
			end

			local function stopExclusive()
				for n, m in pairs(Modes) do
					if m.exclusive and m.on then
						setMode(n, false)
					end
				end
			end

			local function resetAll()
				for name, m in pairs(Modes) do
					if m.on then
						m.bin:clear()
						if not m.persist then
							m.on = false
						end
						refreshUI(name)
					end
				end
			end

			---------------------------------------------------------
			-- ПОЛЁТЫ: Superman / Admin Fly / Glider
			---------------------------------------------------------
			local function flyMode(style)
				return function(bin)
					local _, hrp, hum = getAliveChar()
					if not hrp then
						return false
					end
					platformStand(bin, hum)
					local lv, ao = makeMover(bin, hrp, true)
					local lastYaw = select(2, cam().CFrame:ToOrientation())
					local roll = 0

					bin:add(RunService.RenderStepped:Connect(function(dt)
						local cf = cam().CFrame
						if style == "glider" then
							local look = cf.LookVector
							local fl = flat(look)
							local vy = look.Y * S.Speed * 0.6 - 8
							if UIS:IsKeyDown(Enum.KeyCode.Space) then
								vy += S.Speed * 0.4
							end
							local vel = Vector3.new(fl.X * S.Speed, vy, fl.Z * S.Speed)
							lv.VectorVelocity = vel

							local yaw = select(2, cf:ToOrientation())
							local d = (yaw - lastYaw + math.pi) % (2 * math.pi) - math.pi
							lastYaw = yaw
							local targetRoll = math.clamp(d / math.max(dt, 1e-3) * 0.35, -0.9, 0.9)
							roll += (targetRoll - roll) * math.min(1, dt * 6)
							ao.CFrame = lookCF(vel.Unit) * TILT * CFrame.Angles(0, roll, 0)
						else
							local m = getMove()
							local dir = cf.RightVector * m.X + cf.LookVector * (-m.Z) + Vector3.yAxis * getVertical()
							if dir.Magnitude > 0.05 then
								dir = dir.Unit
								lv.VectorVelocity = dir * S.Speed
								if style == "superman" then
									ao.CFrame = lookCF(dir) * TILT
								else
									ao.CFrame = lookCF(flat(cf.LookVector))
								end
							else
								lv.VectorVelocity = Vector3.zero
								ao.CFrame = lookCF(flat(cf.LookVector))
							end
						end
					end))
				end
			end

			defMode("fly", "Superman Fly", true, false, flyMode("superman"))
			defMode("adminfly", "Admin Fly", true, false, flyMode("admin"))
			defMode("glider", "Glider (планер)", true, false, flyMode("glider"))

			---------------------------------------------------------
			-- LOONG STRIDES
			---------------------------------------------------------
			defMode("loong", "Loong Strides", true, false, function(bin)
				local char, hrp = getAliveChar()
				if not hrp then
					return false
				end

				local rp = RaycastParams.new()
				rp.FilterDescendantsInstances = { char }
				rp.FilterType = Enum.RaycastFilterType.Exclude
				local hit = Workspace:Raycast(hrp.Position, Vector3.new(0, -30, 0), rp)
				local groundY = hit and hit.Position.Y or (hrp.Position.Y - 3)
				local topY = groundY + S.LoongHeight

				local block = bin:add(Instance.new("Part"))
				block.Name = "LoongBlock"
				block.Size = Vector3.new(10, 1, 10)
				block.Anchored = true
				block.CanQuery = false
				block.CanTouch = false
				block.Transparency = 1
				block.CFrame = CFrame.new(hrp.Position.X, topY - 0.5, hrp.Position.Z)
				block.Parent = Workspace

				hrp.CFrame = hrp.CFrame + Vector3.new(0, S.LoongHeight, 0)
				hrp.AssemblyLinearVelocity = Vector3.zero

				bin:add(RunService.Heartbeat:Connect(function()
					local p = hrp.Position
					block.CFrame = CFrame.new(p.X, topY - 0.5, p.Z)
					if p.Y < topY - 8 then
						hrp.CFrame = hrp.CFrame + Vector3.new(0, topY + 4 - p.Y, 0)
						hrp.AssemblyLinearVelocity = Vector3.zero
					end
				end))
			end)

			---------------------------------------------------------
			-- MINGLE (карусель)
			---------------------------------------------------------
			defMode("mingle", "Mingle (карусель)", true, false, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				platformStand(bin, hum)
				makeMover(bin, hrp, false)

				local start = hrp.Position
				local center = start - Vector3.new(S.MingleRadius, 0, 0)
				local baseY = start.Y
				local ang = 0

				bin:add(RunService.Heartbeat:Connect(function(dt)
					ang += S.MingleSpeed * dt
					local r = S.MingleRadius
					local pos = Vector3.new(
						center.X + math.cos(ang) * r,
						baseY + math.sin(ang * 3) * 1.5,
						center.Z + math.sin(ang) * r
					)
					local tangent = Vector3.new(-math.sin(ang), 0, math.cos(ang))
					hrp.CFrame = CFrame.lookAt(pos, pos + tangent)
				end))
			end)

			---------------------------------------------------------
			-- BANKAI
			---------------------------------------------------------
			defMode("bankai", "Bankai", true, false, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				local camera = cam()
				local anchor = S.AnchorPos or hrp.Position
				local camCF = camera.CFrame

				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = camCF
				bin:add(function()
					camera.CameraType = Enum.CameraType.Custom
				end)
				bin:add(RunService.RenderStepped:Connect(function()
					camera.CFrame = camCF
				end))

				local ring = bin:add(Instance.new("Part"))
				ring.Shape = Enum.PartType.Cylinder
				ring.Size = Vector3.new(0.3, S.BankaiRadius * 2, S.BankaiRadius * 2)
				ring.CFrame = CFrame.new(anchor - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
				ring.Anchored = true
				ring.CanCollide = false
				ring.CanQuery = false
				ring.CanTouch = false
				ring.Material = Enum.Material.Neon
				ring.Color = Color3.fromRGB(255, 60, 60)
				ring.Transparency = 0.85
				ring.Parent = Workspace

				platformStand(bin, hum)
				makeMover(bin, hrp, false)

				local acc = 0
				bin:add(RunService.Heartbeat:Connect(function(dt)
					acc += dt
					if acc >= S.BankaiDelay then
						acc = 0
						local a = math.random() * math.pi * 2
						local d = math.sqrt(math.random()) * S.BankaiRadius
						local pos = anchor + Vector3.new(math.cos(a) * d, 0, math.sin(a) * d)
						hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.random() * math.pi * 2, 0)
					end
				end))

				bin:add(function()
					hrp.CFrame = CFrame.new(anchor)
				end)
			end)

			---------------------------------------------------------
			-- LIFT UP / SPIN LIFT
			---------------------------------------------------------
			defMode("lift", "Lift Up (вверх)", true, false, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				local lv = makeMover(bin, hrp, false)
				bin:add(RunService.Heartbeat:Connect(function()
					local md = hum.MoveDirection
					lv.VectorVelocity = Vector3.new(md.X * hum.WalkSpeed, S.LiftSpeed, md.Z * hum.WalkSpeed)
				end))
			end)

			defMode("spinlift", "Spin Lift (вверх + кручение)", true, false, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				platformStand(bin, hum)
				local lv, ao = makeMover(bin, hrp, true)
				ao.Responsiveness = 200
				local ang = 0
				bin:add(RunService.Heartbeat:Connect(function(dt)
					ang += 15 * dt
					lv.VectorVelocity = Vector3.new(0, S.LiftSpeed, 0)
					ao.CFrame = CFrame.Angles(0, ang, 0)
				end))
			end)

			---------------------------------------------------------
			-- IMMOVABLE
			---------------------------------------------------------
			defMode("immovable", "Immovable (статуя)", true, false, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				local oldSpeed = hum.WalkSpeed
				hum.WalkSpeed = 0
				bin:add(function()
					hum.WalkSpeed = oldSpeed
				end)

				local att = bin:add(Instance.new("Attachment"))
				att.Parent = hrp

				local ap = bin:add(Instance.new("AlignPosition"))
				ap.Mode = Enum.PositionAlignmentMode.OneAttachment
				ap.Attachment0 = att
				ap.Position = hrp.Position
				ap.MaxForce = math.huge
				ap.RigidityEnabled = true
				ap.Parent = hrp

				local ao = bin:add(Instance.new("AlignOrientation"))
				ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
				ao.Attachment0 = att
				ao.CFrame = hrp.CFrame.Rotation
				ao.MaxTorque = math.huge
				ao.RigidityEnabled = true
				ao.Parent = hrp
			end)

			---------------------------------------------------------
			-- RANDOM WANDER
			---------------------------------------------------------
			defMode("wander", "Random Wander (носит по карте)", true, false, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				platformStand(bin, hum)
				local lv, ao = makeMover(bin, hrp, true)
				local origin = hrp.Position
				local target = origin
				local nextPick = 0

				bin:add(RunService.Heartbeat:Connect(function()
					local diff = target - hrp.Position
					if os.clock() > nextPick or diff.Magnitude < 8 then
						nextPick = os.clock() + 1.5
						local a = math.random() * math.pi * 2
						local d = 50 + math.random() * 250
						target = origin + Vector3.new(math.cos(a) * d, math.random() * 60, math.sin(a) * d)
						diff = target - hrp.Position
					end
					local dir = diff.Unit
					lv.VectorVelocity = dir * (S.Speed * 2)
					ao.CFrame = lookCF(dir) * TILT
				end))
			end)

			---------------------------------------------------------
			-- WALLEY WEST (Flash)
			---------------------------------------------------------
			defMode("flash", "Walley West (Flash)", false, true, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				local old = hum.WalkSpeed
				bin:add(function()
					hum.WalkSpeed = old
				end)
				bin:add(RunService.Heartbeat:Connect(function()
					hum.WalkSpeed = S.Speed
				end))

				local a0 = bin:add(Instance.new("Attachment"))
				a0.Position = Vector3.new(0, 1.5, 0)
				a0.Parent = hrp
				local a1 = bin:add(Instance.new("Attachment"))
				a1.Position = Vector3.new(0, -1.5, 0)
				a1.Parent = hrp
				local tr = bin:add(Instance.new("Trail"))
				tr.Attachment0 = a0
				tr.Attachment1 = a1
				tr.Lifetime = 0.45
				tr.LightEmission = 1
				tr.Color = ColorSequence.new(Color3.fromRGB(255, 60, 30), Color3.fromRGB(255, 225, 60))
				tr.Transparency = NumberSequence.new(0, 1)
				tr.Parent = hrp
			end)

			---------------------------------------------------------
			-- NOCLIP / DOUBLE JUMP / TP TOOL / LAG SWITCH (переживают респавн)
			---------------------------------------------------------
			defMode("noclip", "Noclip (сквозь объекты)", false, true, function(bin)
				local touched = {}
				bin:add(RunService.Stepped:Connect(function()
					local char = player.Character
					if not char then
						return
					end
					for _, p in ipairs(char:GetDescendants()) do
						if p:IsA("BasePart") and p.CanCollide then
							touched[p] = true
							p.CanCollide = false
						end
					end
				end))
				bin:add(function()
					for p in pairs(touched) do
						if p.Parent then
							p.CanCollide = true
						end
					end
				end)
			end)

			defMode("doublejump", "Double Jump", false, true, function(bin)
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return false
				end
				local used = false
				bin:add(hum.StateChanged:Connect(function(_, new)
					if new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running then
						used = false
					end
				end))
				bin:add(UIS.JumpRequest:Connect(function()
					if hum:GetState() == Enum.HumanoidStateType.Freefall and not used then
						used = true
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
						local v = hrp.AssemblyLinearVelocity
						hrp.AssemblyLinearVelocity = Vector3.new(v.X, 55, v.Z)
					end
				end))
			end)

			defMode("tptool", "TP Tool", false, true, function(bin)
				local backpack = player:WaitForChild("Backpack")
				local tool = bin:add(Instance.new("Tool"))
				tool.Name = "TP Tool"
				tool.RequiresHandle = false
				tool.CanBeDropped = false
				tool.ToolTip = "Клик = телепорт в точку"
				tool.Activated:Connect(function()
					local _, hrp = getAliveChar()
					if not hrp then
						return
					end
					local hit = player:GetMouse().Hit
					hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) * hrp.CFrame.Rotation
					hrp.AssemblyLinearVelocity = Vector3.zero
				end)
				tool.Parent = backpack
			end)

			defMode("lag", "Lag Switch", false, true, function(bin)
				local _, hrp = getAliveChar()
				if not hrp then
					return false
				end
				pcall(function()
					settings().Network.IncomingReplicationLag = 0.4
				end)
				bin:add(function()
					pcall(function()
						settings().Network.IncomingReplicationLag = 0
					end)
				end)

				local alive = true
				bin:add(function()
					alive = false
					hrp.Anchored = false
				end)
				task.spawn(function()
					while alive do
						task.wait(0.6 + math.random() * 0.8)
						if not alive then
							break
						end
						hrp.Anchored = true
						task.wait(0.25 + math.random() * 0.4)
						hrp.Anchored = false
					end
				end)
			end)

			---------------------------------------------------------
			-- ОДНОРАЗОВЫЕ ДЕЙСТВИЯ
			---------------------------------------------------------
			local busy = false

			local function effect(duration, build)
				if busy then
					return
				end
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return
				end
				stopExclusive()
				busy = true

				local bin = Bin.new()
				hum.PlatformStand = true
				bin:add(function()
					hum.PlatformStand = false
					busy = false
				end)
				local lv, ao = makeMover(bin, hrp, true)
				local step = build(hrp, lv, ao)
				local t0 = os.clock()
				bin:add(RunService.Heartbeat:Connect(function()
					local t = os.clock() - t0
					if t >= duration or not hrp.Parent or hum.Health <= 0 then
						bin:clear()
						return
					end
					step(t, t / duration)
				end))
			end

			local function explosionLaunch()
				effect(1.6, function(hrp, lv, ao)
					local ex = Instance.new("Explosion")
					ex.Position = hrp.Position - Vector3.new(0, 2, 0)
					ex.BlastRadius = 12
					ex.BlastPressure = 0
					ex.DestroyJointRadiusPercent = 0
					ex.Parent = Workspace

					local a = math.random() * math.pi * 2
					local dir = Vector3.new(math.cos(a), 0, math.sin(a))
					return function(t, p)
						local horiz = dir * 100 * (1 - p * 0.6)
						local vert = 90 * (1 - p * 2)
						lv.VectorVelocity = Vector3.new(horiz.X, vert, horiz.Z)
						ao.CFrame = CFrame.Angles(t * 10, t * 7, 0)
					end
				end)
			end

			local function windBlow()
				effect(3, function(hrp, lv, ao)
					local dir = flat(-cam().CFrame.LookVector)
					local side = cam().CFrame.RightVector * (math.random() - 0.5) * 0.6
					dir = (dir + flat(side) * 0.3).Unit
					return function(t, p)
						local gust = 1 + 0.4 * math.sin(t * 9)
						local power = 90 * gust * (0.4 + 0.6 * (1 - p))
						lv.VectorVelocity = dir * power + Vector3.new(0, 6 * math.sin(t * 5) + 4, 0)
						ao.CFrame = CFrame.Angles(math.sin(t * 5) * 1.2, t * 3, math.cos(t * 4) * 1.2)
					end
				end)
			end

			local dashCd = false
			local function dash()
				if dashCd then
					return
				end
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return
				end
				dashCd = true
				local dir = hum.MoveDirection.Magnitude > 0.1 and hum.MoveDirection.Unit or flat(hrp.CFrame.LookVector)
				local bin = Bin.new()
				local lv = makeMover(bin, hrp, false)
				lv.VectorVelocity = dir * S.DashPower
				task.delay(0.22, function()
					bin:clear()
				end)
				task.delay(0.7, function()
					dashCd = false
				end)
			end

			-- команда игрока (как во вкладке Esp: значение MatchTeam)
			local function getTeam(p)
				local v = p:GetAttribute("MatchTeam")
				if v == nil then
					local mt = p:FindFirstChild("MatchTeam")
					if mt then
						if mt:IsA("ValueBase") then
							v = mt.Value
						else
							v = mt:GetAttribute("Value")
						end
					end
				end
				if typeof(v) == "Instance" then
					v = v.Name
				end
				return v ~= nil and string.lower(tostring(v)) or nil
			end

			local function gokuDodge()
				local _, hrp = getAliveChar()
				if not hrp then
					return
				end
				local mine = getTeam(player)
				local best, bestDist

				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player then
						local t = getTeam(p)
						if mine == nil or t ~= mine then
							local c = p.Character
							local eh = c and c:FindFirstChild("HumanoidRootPart")
							local ehum = c and c:FindFirstChildOfClass("Humanoid")
							if eh and ehum and ehum.Health > 0 then
								local d = (eh.Position - hrp.Position).Magnitude
								if not bestDist or d < bestDist then
									best, bestDist = eh, d
								end
							end
						end
					end
				end

				if not best then
					notify("Враг не найден")
					return
				end
				local back = (best.CFrame * CFrame.new(0, 0, 3.5)).Position
				local pos = Vector3.new(back.X, best.Position.Y, back.Z)
				hrp.CFrame = CFrame.lookAt(pos, Vector3.new(best.Position.X, pos.Y, best.Position.Z))
				hrp.AssemblyLinearVelocity = Vector3.zero
			end

			local function setAnchor()
				local _, hrp = getAliveChar()
				if not hrp then
					return
				end
				if Modes.bankai.on then
					notify("Выключи Bankai, чтобы сменить Anchor")
					return
				end
				S.AnchorPos = hrp.Position
				local p = hrp.Position
				notify(string.format("Anchor: %d, %d, %d", p.X, p.Y, p.Z))
			end

			---------------------------------------------------------
			-- feFlip: фронтфлип / бэкфлип / прыжок в воздухе
			---------------------------------------------------------
			local flipBusy = false
			local function flip(dir) -- dir = -1 вперёд, 1 назад
				if flipBusy then
					return
				end
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return
				end
				flipBusy = true
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
				task.wait()
				hum.Sit = true -- чтобы гуманоид не выравнивал тело во время кувырка

				local DURATION = 0.5
				local t0, last = os.clock(), 0
				local conn
				conn = RunService.Heartbeat:Connect(function()
					if not hrp.Parent or hum.Health <= 0 then
						conn:Disconnect()
						flipBusy = false
						return
					end
					local p = math.min((os.clock() - t0) / DURATION, 1)
					hrp.CFrame = hrp.CFrame * CFrame.Angles(dir * (p - last) * math.pi * 2, 0, 0)
					last = p
					hum.Sit = true
					if p >= 1 then
						conn:Disconnect()
						hum.Sit = false
						flipBusy = false
					end
				end)
			end

			local function frontflip()
				flip(-1)
			end

			local function backflip()
				flip(1)
			end

			local function airJump()
				local _, _, hum = getAliveChar()
				if not hum then
					return
				end
				hum:ChangeState(Enum.HumanoidStateType.Seated)
				task.wait()
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end

			---------------------------------------------------------
			-- ТП-метка: сохранить точку / вернуться на неё
			---------------------------------------------------------
			local tpSaved, tpMarker

			local function createTpMarker(position)
				if tpMarker then
					tpMarker:Destroy()
				end

				tpMarker = Instance.new("Part")
				tpMarker.Name = "TPMarker"
				tpMarker.Shape = Enum.PartType.Cylinder
				tpMarker.Size = Vector3.new(0.2, 4, 4)
				tpMarker.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
				tpMarker.Anchored = true
				tpMarker.CanCollide = false
				tpMarker.CanQuery = false
				tpMarker.CanTouch = false
				tpMarker.Material = Enum.Material.Neon
				tpMarker.Color = Color3.fromRGB(0, 170, 255)
				tpMarker.Transparency = 0.3
				tpMarker.Parent = Workspace

				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.new(0, 80, 0, 40)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = tpMarker

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = "ТП"
				label.TextColor3 = Color3.new(1, 1, 1)
				label.TextStrokeTransparency = 0
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.Parent = billboard
			end

			local function saveTpPoint()
				local _, hrp, hum = getAliveChar()
				if not hrp then
					return
				end
				tpSaved = hrp.CFrame
				createTpMarker(hrp.Position - Vector3.new(0, hrp.Size.Y / 2 + hum.HipHeight - 0.1, 0))
				notify("ТП: точка сохранена", GREEN)
			end

			local function tpToSaved()
				local _, hrp = getAliveChar()
				if not hrp then
					return
				end
				if not tpSaved then
					notify("ТП: сначала сохрани точку", RED)
					return
				end
				hrp.CFrame = tpSaved
				hrp.AssemblyLinearVelocity = Vector3.zero
			end

			---------------------------------------------------------
			-- Universal Troll: внешний скрипт (грузится по кнопке)
			-- Нажать надо ДВА раза за 5 секунд, чтобы случайно не запустить.
			---------------------------------------------------------
			local UNIVERSAL_TROLL_URL = "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/FE%20Trolling%20GUI.luau"
			local utConfirmUntil = 0

			local function loadUniversalTroll()
				if os.clock() > utConfirmUntil then
					utConfirmUntil = os.clock() + 5
					notify("Это чужой внешний скрипт. Нажми ещё раз за 5 сек, чтобы загрузить", RED)
					return
				end
				utConfirmUntil = 0
				notify("Загружаю Universal Troll…", C.Accent)
				task.spawn(function()
					local ok, err = pcall(function()
						loadstring(game:HttpGet(UNIVERSAL_TROLL_URL))()
					end)
					if not ok then
						warn("[Troll] Universal Troll: " .. tostring(err))
						notify("Не загрузился (нужен executor с loadstring / HttpGet)", RED)
					end
				end)
			end

			---------------------------------------------------------
			-- UI: НАСТРОЙКИ
			---------------------------------------------------------
			UI.Section(h, "TROLL PACK: НАСТРОЙКИ")
			UI.Slider(h, "Скорость (полёты / Flash / Wander)", 1, 500, S.Speed, 0, function(v)
				S.Speed = v
			end)
			UI.Slider(h, "Loong: высота блока", 1, 100, S.LoongHeight, 0, function(v)
				S.LoongHeight = v
			end)
			UI.Slider(h, "Mingle: радиус", 5, 200, S.MingleRadius, 0, function(v)
				S.MingleRadius = v
			end)
			UI.Slider(h, "Mingle: скорость", 0.5, 30, S.MingleSpeed, 1, function(v)
				S.MingleSpeed = v
			end)
			UI.Slider(h, "Bankai: радиус", 5, 200, S.BankaiRadius, 0, function(v)
				S.BankaiRadius = v
			end)
			UI.Slider(h, "Bankai: задержка (сек)", 0.03, 2, S.BankaiDelay, 2, function(v)
				S.BankaiDelay = v
			end)
			UI.Slider(h, "Lift: скорость", 1, 300, S.LiftSpeed, 0, function(v)
				S.LiftSpeed = v
			end)
			UI.Slider(h, "Dash: сила", 20, 400, S.DashPower, 0, function(v)
				S.DashPower = v
			end)

			---------------------------------------------------------
			-- UI: РЕЖИМЫ (переключатели)
			---------------------------------------------------------
			UI.Section(h, "TROLL PACK: РЕЖИМЫ")
			local toggles = {}
			for _, name in ipairs(Order) do
				local m = Modes[name]
				toggles[name] = UI.Toggle(h, m.label, false, function(v)
					setMode(name, v)
				end)
			end
			refreshUI = function(name)
				local t = toggles[name]
				if t then
					t.Set(Modes[name].on, true)
				end
			end

			UI.Note(h, "Полёты, Loong, Mingle, Bankai, Lift, Immovable и Wander выключают друг друга. Noclip, Double Jump, TP Tool, Lag Switch и Flash работают вместе с чем угодно. Полёт: WASD + Space (вверх), LeftCtrl / LeftShift (вниз). Для Wander лучше включить Noclip.")

			---------------------------------------------------------
			-- UI: ДЕЙСТВИЯ + БИНДЫ
			---------------------------------------------------------
			UI.Section(h, "TROLL PACK: ДЕЙСТВИЯ")
			UI.Button(h, "Anchor (точка для Bankai)", setAnchor)
			UI.Button(h, "Explosion (взрыв)", explosionLaunch)
			UI.Button(h, "Wind (сдуло ветром)", windBlow)
			UI.Button(h, "Dash", dash)
			UI.Button(h, "Goku Dodge (за спину врага)", gokuDodge)
			UI.Button(h, "Frontflip", frontflip)
			UI.Button(h, "Backflip", backflip)
			UI.Button(h, "Air Jump (прыжок в воздухе)", airJump)
			UI.Button(h, "ТП: сохранить точку", saveTpPoint)
			UI.Button(h, "ТП: телепорт на точку", tpToSaved)
			UI.Section(h, "ВНЕШНИЕ СКРИПТЫ")
			UI.Button(h, "Universal Troll (внешний, 2 клика)", loadUniversalTroll)
			UI.Note(h, "Universal Troll грузит чужой код с GitHub и запускает его с твоими правами. Автор может изменить файл в любой момент.")

			local KEYS = {
			}
			local bindButtons = {}
			local listening = nil

			local function refreshBind(id)
				local btn = bindButtons[id]
				if btn then
					btn.Text = KEYS[id] and KEYS[id].Name or "—"
				end
			end

			local function bindRow(id, label)
				local g = UI.Group(h)
				local row = create("Frame", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = C.Card,
					BorderSizePixel = 0,
				}, {
					corner(UDim.new(0, 10)),
					create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
				})
				row.Parent = g

				create("TextLabel", {
					Position = UDim2.fromOffset(14, 0),
					Size = UDim2.new(1, -140, 1, 0),
					BackgroundTransparency = 1,
					Text = label,
					TextColor3 = C.TextDark,
					Font = Enum.Font.GothamMedium,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
				}).Parent = row

				local btn = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(110, 28),
					BackgroundColor3 = C.Sidebar,
					Text = "",
					TextColor3 = C.TextDark,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					AutoButtonColor = false,
				}, { corner(UDim.new(0, 8)) })
				btn.Parent = row
				bindButtons[id] = btn
				refreshBind(id)
                				Persist.addId("bind/Troll/" .. id, "bind", function() return KEYS[id] end,
					function(k) KEYS[id] = k; refreshBind(id) end)

				btn.MouseButton1Click:Connect(function()
					if listening then
						refreshBind(listening)
					end
					listening = id
					btn.Text = "Нажми клавишу…"
				end)
			end

			bindRow("dash", "Клавиша Dash")
			bindRow("goku", "Клавиша Goku Dodge")
			bindRow("frontflip", "Клавиша Frontflip")
			bindRow("backflip", "Клавиша Backflip")
			bindRow("airjump", "Клавиша Air Jump")
			bindRow("tpsave", "Клавиша ТП: сохранить")
			bindRow("tpgo", "Клавиша ТП: телепорт")
			UI.Note(h, "Клик по кнопке, потом клавиша. Esc / Backspace — очистить.")

			local actions = {
				dash = dash,
				goku = gokuDodge,
				frontflip = frontflip,
				backflip = backflip,
				airjump = airJump,
				tpsave = saveTpPoint,
				tpgo = tpToSaved,
			}

			UIS.InputBegan:Connect(function(input, gp)
				if listening then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						local id = listening
						listening = nil
						local key = input.KeyCode
						if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
							KEYS[id] = nil
						elseif key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
							-- клавиша занята панелью
						else
							for otherId, k in pairs(KEYS) do
								if k == key and otherId ~= id then
									KEYS[otherId] = nil
									refreshBind(otherId)
								end
							end
							KEYS[id] = key
						end
						refreshBind(id)
					end
					return
				end

				if gp then
					return
				end
				for id, key in pairs(KEYS) do
					if input.KeyCode == key and actions[id] then
						task.spawn(actions[id])
						break
					end
				end
			end)

			---------------------------------------------------------
			-- РЕСПАВН
			---------------------------------------------------------
			local function onChar(char)
				local hum = char:WaitForChild("Humanoid")
				char:WaitForChild("HumanoidRootPart")
				hum.Died:Connect(resetAll)
				for _, m in pairs(Modes) do
					if m.on and m.persist then
						m.bin:clear()
						task.spawn(function()
							local ok, err = pcall(m.start, m.bin)
							if not ok then
								warn("[Troll] " .. tostring(err))
							end
						end)
					end
				end
			end

			player.CharacterAdded:Connect(onChar)
			player.CharacterRemoving:Connect(resetAll)
			if player.Character then
				task.spawn(function()
					local hum = player.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.Died:Connect(resetAll)
					end
				end)
			end
		end
	end
end

------------------------------------------------------------
-- ВКЛАДКА CUSTOM: Free Cam / Spectate / Custom Emote Wheel
--
-- КУДА ВСТАВИТЬ: целиком ПЕРЕД блоком
--     ------------------------------------------------------------
--     -- СТАРТ
--     ------------------------------------------------------------
-- (то есть после закрывающего `end` вкладки Troll).
-- Больше ничего менять не надо: блок сам добавляет переключатель
-- «Вкладка Custom» в Settings и сам скрывает/показывает вкладку в сайдбаре.
------------------------------------------------------------
do
	local LocalPlayer = Players.LocalPlayer
	local CAS = game:GetService("ContextActionService")
	local h = Holders.Custom

	if h then
		UI.ClearPlaceholder(h)

				local stopAll = function() end -- заполняется ниже
		TabHooks.Custom = function()
			stopAll()
		end

		---------------------------------------------------------
		-- ОБЩЕЕ
		---------------------------------------------------------
		local function own()
			local c = LocalPlayer.Character
			return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
		end

		local function cam()
			return workspace.CurrentCamera
		end

		local function typing()
			return UIS:GetFocusedTextBox() ~= nil
		end

		local function panelHasMouse()
			return isOpen and applied == "cursor"
		end

		local function getTeamName(p)
			local v = p:GetAttribute("MatchTeam")
			if v == nil then
				local mt = p:FindFirstChild("MatchTeam")
				if mt then
					if mt:IsA("ValueBase") then
						v = mt.Value
					else
						v = mt:GetAttribute("Value")
					end
				end
			end
			if typeof(v) == "Instance" then
				v = v.Name
			end
			return v ~= nil and string.lower(tostring(v)) or nil
		end

		local CU = { Freeze = true } -- блокировать движение своего персонажа, пока камера занята
		local FC = { Enabled = false, Speed = 60, Fast = 3, Sens = 0.3, Smooth = true }
		local SP = { Enabled = false, Target = nil, Last = nil }

		local fcToggle, spToggle, speedSlider
		local stopSpectate -- объявлена ниже
		local stopFreeCam

		-- «глушилка» WASD/Space/Shift/Ctrl, чтобы свой персонаж не бегал, пока камера летает
		local SINK = "YokattaCustomSink"
		local sinkOn = false
		local function updateSink()
			local need = CU.Freeze and (FC.Enabled or SP.Enabled)
			if need and not sinkOn then
				sinkOn = true
				CAS:BindActionAtPriority(
					SINK,
					function()
						return Enum.ContextActionResult.Sink
					end,
					false,
					Enum.ContextActionPriority.High.Value,
					Enum.KeyCode.W,
					Enum.KeyCode.A,
					Enum.KeyCode.S,
					Enum.KeyCode.D,
					Enum.KeyCode.Space,
					Enum.KeyCode.LeftShift,
					Enum.KeyCode.LeftControl,
					Enum.KeyCode.Up,
					Enum.KeyCode.Down,
					Enum.KeyCode.Left,
					Enum.KeyCode.Right
				)
			elseif not need and sinkOn then
				sinkOn = false
				CAS:UnbindAction(SINK)
			end
		end

		local function syncToggles()
			if fcToggle then
				fcToggle.Set(FC.Enabled, true)
			end
			if spToggle then
				spToggle.Set(SP.Enabled, true)
			end
		end

		---------------------------------------------------------
		-- FREE CAM
		---------------------------------------------------------
		local FC_BIND = "YokattaFreeCam"
		local fcPos, fcYaw, fcPitch, fcVel = Vector3.zero, 0, 0, Vector3.zero
		local lookBehavior = nil

		local function fcStep(dt)
			local c = cam()
			if not c then
				return
			end
			if c.CameraType ~= Enum.CameraType.Scriptable then
				c.CameraType = Enum.CameraType.Scriptable
			end

			-- взгляд: зажми ПКМ и двигай мышью
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				if lookBehavior == nil then
					lookBehavior = UIS.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition and Enum.MouseBehavior.Default
						or UIS.MouseBehavior
				end
				UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				local d = UIS:GetMouseDelta()
				fcYaw -= math.rad(d.X * FC.Sens)
				fcPitch = math.clamp(fcPitch - math.rad(d.Y * FC.Sens), -1.5, 1.5)
			elseif lookBehavior ~= nil then
				UIS.MouseBehavior = lookBehavior
				lookBehavior = nil
			end

			local rot = CFrame.fromOrientation(fcPitch, fcYaw, 0)
			local x, y, z = 0, 0, 0
			if not typing() then
				x = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
				z = (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
				y = (UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)
			end

			local dir = rot:VectorToWorldSpace(Vector3.new(x, 0, z)) + Vector3.new(0, y, 0)
			local speed = FC.Speed * (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and FC.Fast or 1)
			local target = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
			if FC.Smooth then
				fcVel = fcVel:Lerp(target, 1 - math.exp(-dt * 10))
			else
				fcVel = target
			end
			fcPos += fcVel * dt

			c.CFrame = CFrame.new(fcPos) * rot
			c.Focus = c.CFrame
		end

		local function startFreeCam()
			if FC.Enabled then
				return
			end
			stopSpectate()
			local c = cam()
			local cf = c.CFrame
			fcPos = cf.Position
			fcPitch, fcYaw = cf:ToOrientation()
			fcVel = Vector3.zero
			FC.Enabled = true
			c.CameraType = Enum.CameraType.Scriptable
			pcall(function()
				RunService:UnbindFromRenderStep(FC_BIND)
			end)
			RunService:BindToRenderStep(FC_BIND, Enum.RenderPriority.Camera.Value + 2, fcStep)
			updateSink()
			syncToggles()
		end

		stopFreeCam = function()
			if not FC.Enabled then
				return
			end
			FC.Enabled = false
			pcall(function()
				RunService:UnbindFromRenderStep(FC_BIND)
			end)
			if lookBehavior ~= nil then
				UIS.MouseBehavior = lookBehavior
				lookBehavior = nil
			end
			local c = cam()
			local _, _, hum = own()
			c.CameraType = Enum.CameraType.Custom
			if hum then
				c.CameraSubject = hum
			end
			updateSink()
			syncToggles()
		end

		-- колёсико мыши меняет скорость полёта
		UIS.InputChanged:Connect(function(input)
			if FC.Enabled and input.UserInputType == Enum.UserInputType.MouseWheel and not panelHasMouse() then
				FC.Speed = math.clamp(FC.Speed * (1.15 ^ input.Position.Z), 2, 1000)
				if speedSlider then
					speedSlider.Set(FC.Speed, true)
				end
			end
		end)

		---------------------------------------------------------
		-- SPECTATE (меняется только камера, твой персонаж остаётся на месте)
		---------------------------------------------------------
		local SP_BIND = "YokattaSpectate"
		local spStatus, listGroup

		local function playersList()
			local list = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					list[#list + 1] = p
				end
			end
			table.sort(list, function(a, b)
				return a.DisplayName:lower() < b.DisplayName:lower()
			end)
			return list
		end

		local function updateSpStatus()
			if not spStatus then
				return
			end
			if SP.Enabled and SP.Target then
				local team = getTeamName(SP.Target)
				spStatus.Text = "Смотрю: " .. SP.Target.DisplayName .. (team and (" [" .. team .. "]") or "")
			else
				spStatus.Text = "Не наблюдаю"
			end
		end

		local function rebuildList()
			if not listGroup then
				return
			end
			for _, c in ipairs(listGroup:GetChildren()) do
				if not c:IsA("UIListLayout") then
					c:Destroy()
				end
			end
			for _, p in ipairs(playersList()) do
				local team = getTeamName(p)
				local on = SP.Enabled and SP.Target == p
				UI.Button(
					listGroup,
					(on and "● " or "○ ") .. p.DisplayName .. (team and ("  [" .. team .. "]") or ""),
					function()
						if SP.Enabled and SP.Target == p then
							stopSpectate()
						else
							startSpectate(p)
						end
					end
				)
			end
		end

		local function spStep()
			local p = SP.Target
			local ch = p and p.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if not hum then
				return
			end
			local c = cam()
			if c.CameraType ~= Enum.CameraType.Custom then
				c.CameraType = Enum.CameraType.Custom
			end
			if c.CameraSubject ~= hum then
				c.CameraSubject = hum
			end
		end

		function startSpectate(p)
			if not p or p == LocalPlayer then
				return
			end
			stopFreeCam()
			SP.Target = p
			SP.Last = p
			SP.Enabled = true
			pcall(function()
				RunService:UnbindFromRenderStep(SP_BIND)
			end)
			-- до штатной камеры, чтобы она в этом же кадре уже смотрела на цель
			RunService:BindToRenderStep(SP_BIND, Enum.RenderPriority.Camera.Value - 1, spStep)
			updateSink()
			syncToggles()
			updateSpStatus()
			rebuildList()
		end

		stopSpectate = function()
			if not SP.Enabled then
				return
			end
			SP.Enabled = false
			SP.Target = nil
			pcall(function()
				RunService:UnbindFromRenderStep(SP_BIND)
			end)
			local c = cam()
			local _, _, hum = own()
			c.CameraType = Enum.CameraType.Custom
			if hum then
				c.CameraSubject = hum
			end
			updateSink()
			syncToggles()
			updateSpStatus()
			rebuildList()
		end

		local function cycleSpectate(dir)
			local list = playersList()
			if #list == 0 then
				stopSpectate()
				return
			end
			local idx = SP.Target and table.find(list, SP.Target) or (dir > 0 and 0 or #list + 1)
			idx = ((idx - 1 + dir) % #list) + 1
			startSpectate(list[idx])
		end

		Players.PlayerAdded:Connect(function()
			rebuildList()
		end)
		Players.PlayerRemoving:Connect(function(p)
			if SP.Enabled and SP.Target == p then
				task.defer(function()
					cycleSpectate(1)
				end)
			end
			task.defer(rebuildList)
		end)

		---------------------------------------------------------
		-- CUSTOM EMOTE WHEEL
		---------------------------------------------------------
		local EW = { Enabled = true, StopOnMove = true, LoopAnims = true, Deadzone = 30 }
		local SLOT_COUNT = 8

		-- slot = { label, kind = "emote" | "anim" | "stop", value }
		local SLOTS = {
			{ label = "Wave", kind = "emote", value = "wave" },
			{ label = "Point", kind = "emote", value = "point" },
			{ label = "Cheer", kind = "emote", value = "cheer" },
			{ label = "Laugh", kind = "emote", value = "laugh" },
			{ label = "Dance", kind = "emote", value = "dance" },
			{ label = "Dance2", kind = "emote", value = "dance2" },
			{ label = "Dance3", kind = "emote", value = "dance3" },
			{ label = "Stop", kind = "stop" },
		}

		local function slotText(s)
			if not s then
				return ""
			end
			if s.kind == "stop" then
				return "stop"
			elseif s.kind == "anim" then
				if s.label == "ID " .. s.value then
					return s.value
				end
				return s.label .. "=" .. s.value
			end
			return s.value
		end

		-- «Название=ID», «ID», «название эмоута», «stop», пусто = слот выключен
		local function parseSlot(text)
			text = text:match("^%s*(.-)%s*$")
			if text == "" then
				return false
			end
			local label, value = text:match("^(.-)%s*=%s*(.+)$")
			if not label or label == "" then
				label, value = nil, text
			end
			if value:lower() == "stop" then
				return { label = label or "Stop", kind = "stop" }
			end
			local id = value:match("^%d+$") or value:match("rbxassetid://(%d+)")
			if id then
				return { label = label or ("ID " .. id), kind = "anim", value = id }
			end
			return {
				label = label or (value:sub(1, 1):upper() .. value:sub(2)),
				kind = "emote",
				value = value:lower(),
			}
		end

		-- проигрывание
		local trackCache = {}
		local currentTrack, trackStart = nil, 0
		local emoteNote

		local function setEmoteStatus(t)
			if emoteNote then
				emoteNote.Text = t
			end
		end

		local function stopEmote()
			if currentTrack then
				pcall(function()
					currentTrack:Stop(0.2)
				end)
				currentTrack = nil
			end
		end

		local function playAnimId(id)
			local _, _, hum = own()
			local animator = hum and hum:FindFirstChildOfClass("Animator")
			if not animator then
				return false
			end
			stopEmote()
			local track = trackCache[id]
			if not track then
				local a = Instance.new("Animation")
				a.AnimationId = "rbxassetid://" .. id
				local ok, t = pcall(function()
					return animator:LoadAnimation(a)
				end)
				if not ok or not t then
					return false
				end
				trackCache[id] = t
				track = t
			end
			track.Priority = Enum.AnimationPriority.Action4
			track.Looped = EW.LoopAnims
			track:Play(0.15)
			currentTrack = track
			trackStart = os.clock()
			return true
		end

		local function playSlot(slot)
			if not slot then
				return
			end
			if slot.kind == "stop" then
				stopEmote()
				setEmoteStatus("Анимация остановлена (обычные эмоуты заканчиваются, когда ты двигаешься).")
				return
			end
			local _, _, hum = own()
			if not hum then
				return
			end
			stopEmote()
			if slot.kind == "anim" then
				if playAnimId(slot.value) then
					setEmoteStatus("Играет: " .. slot.label)
				else
					setEmoteStatus("Не удалось загрузить анимацию " .. slot.value .. " (ID недоступен в этой игре?)")
				end
			else
				local ok, res = pcall(function()
					return hum:PlayEmote(slot.value)
				end)
				if not ok or res == false then
					setEmoteStatus("Эмоут «" .. slot.value .. "» недоступен в этой игре.")
				else
					setEmoteStatus("Играет: " .. slot.label)
				end
			end
		end

		RunService.Heartbeat:Connect(function()
			if currentTrack and EW.StopOnMove then
				local _, _, hum = own()
				if hum and hum.MoveDirection.Magnitude > 0.1 and os.clock() - trackStart > 0.3 then
					stopEmote()
				end
			end
		end)

		LocalPlayer.CharacterAdded:Connect(function()
			table.clear(trackCache)
			currentTrack = nil
		end)

		-- GUI колеса
		do
			local old = parent:FindFirstChild("YokattaEmoteWheel")
			if old then
				old:Destroy()
			end
		end

		local WheelGui = create("ScreenGui", {
			Name = "YokattaEmoteWheel",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 1000,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Enabled = false,
		})
		WheelGui.Parent = parent

		local WHEEL = 380
		local MID = WHEEL / 2
		local RADIUS = 125

		local Wheel = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(WHEEL, WHEEL),
			BackgroundTransparency = 1,
		})
		local WScale = create("UIScale", { Scale = 0.8 })
		WScale.Parent = Wheel
		Wheel.Parent = WheelGui

		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(MID, MID),
			Size = UDim2.fromOffset(WHEEL - 20, WHEEL - 20),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.08,
		}, { round(), create("UIStroke", { Color = C.HeaderLine, Thickness = 3 }) }).Parent = Wheel

		local centerLabel
		do
			local center = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(MID, MID),
				Size = UDim2.fromOffset(104, 104),
				BackgroundColor3 = C.Header,
			}, { round(), create("UIStroke", { Color = C.Accent, Thickness = 2 }) })
			center.Parent = Wheel
			centerLabel = create("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "Эмоуты",
				TextColor3 = C.TextDark,
				TextWrapped = true,
				Font = Enum.Font.GothamBold,
				TextSize = 15,
			})
			centerLabel.Parent = center
		end

		local nodes = {}
		for i = 1, SLOT_COUNT do
			local a = -math.pi / 2 + (i - 1) * (2 * math.pi / SLOT_COUNT)
			local node = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(MID + math.cos(a) * RADIUS, MID + math.sin(a) * RADIUS),
				Size = UDim2.fromOffset(84, 84),
				BackgroundColor3 = C.Sidebar,
			}, { round(), create("UIStroke", { Color = C.Accent, Thickness = 2 }) })
			node.Parent = Wheel

			local lbl = create("TextLabel", {
				Size = UDim2.new(1, -10, 1, -10),
				Position = UDim2.fromOffset(5, 5),
				BackgroundTransparency = 1,
				Text = "",
				TextColor3 = C.TextDark,
				TextWrapped = true,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
			})
			lbl.Parent = node
			nodes[i] = { frame = node, label = lbl }
		end

		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(MID, MID),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.fromRGB(226, 60, 120),
			ZIndex = 5,
		}, { round() })
		dot.Parent = Wheel

		local function refreshWheel()
			for i = 1, SLOT_COUNT do
				local s = SLOTS[i]
				nodes[i].label.Text = s and s.label or "—"
				nodes[i].frame.BackgroundTransparency = s and 0 or 0.5
			end
		end
		refreshWheel()

		local wheelOpen, wheelVec, wheelSel, wheelPrevBehavior, wheelConn =
			false, Vector2.zero, nil, nil, nil

		local function showSelection(sel)
			for i, n in ipairs(nodes) do
				local on = i == sel
				tween(n.frame, {
					BackgroundColor3 = on and C.AccentStrong or C.Sidebar,
					Size = UDim2.fromOffset(on and 96 or 84, on and 96 or 84),
				}, 0.1)
				n.label.TextColor3 = on and Color3.new(1, 1, 1) or C.TextDark
			end
			centerLabel.Text = (sel and SLOTS[sel]) and SLOTS[sel].label or "Эмоуты"
		end

		local function sliceAt(v)
			if v.Magnitude < EW.Deadzone then
				return nil
			end
			local n = SLOT_COUNT
			local a = (math.atan2(v.Y, v.X) + math.pi / 2) % (2 * math.pi)
			return math.floor((a + math.pi / n) / (2 * math.pi / n)) % n + 1
		end

		local function closeWheel(select)
			if not wheelOpen then
				return
			end
			wheelOpen = false
			if wheelConn then
				wheelConn:Disconnect()
				wheelConn = nil
			end
			WheelGui.Enabled = false
			UIS.MouseBehavior = wheelPrevBehavior or Enum.MouseBehavior.Default
			local sel = wheelSel
			wheelSel = nil
			if select and sel then
				playSlot(SLOTS[sel])
			end
		end

		local function openWheel()
			if wheelOpen or not EW.Enabled or not TabEnabled.Custom or isOpen or typing() then
				return
			end
			wheelOpen = true
			wheelVec = Vector2.zero
			wheelSel = nil
			wheelPrevBehavior = UIS.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition and Enum.MouseBehavior.Default
				or UIS.MouseBehavior
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			dot.Position = UDim2.fromOffset(MID, MID)
			showSelection(nil)
			WScale.Scale = 0.8
			WheelGui.Enabled = true
			tween(WScale, { Scale = 1 }, 0.15, Enum.EasingStyle.Back)

			wheelConn = RunService.RenderStepped:Connect(function()
				wheelVec += UIS:GetMouseDelta()
				if wheelVec.Magnitude > 110 then
					wheelVec = wheelVec.Unit * 110
				end
				dot.Position = UDim2.fromOffset(MID + wheelVec.X, MID + wheelVec.Y)
				local sel = sliceAt(wheelVec)
				if sel and not SLOTS[sel] then
					sel = nil
				end
				if sel ~= wheelSel then
					wheelSel = sel
					showSelection(sel)
				end
			end)
		end

		---------------------------------------------------------
		-- ОБЩАЯ ОСТАНОВКА (при выключении вкладки)
		---------------------------------------------------------
		stopAll = function()
			stopFreeCam()
			stopSpectate()
			closeWheel(false)
		end

		---------------------------------------------------------
		-- БИНДЫ
		---------------------------------------------------------
		local binds = {
			freecam = {},
			spectate = {},
			spnext = {},
			spprev = {},
			wheel = {},
		}
		local listening = nil

		local function renderBind(id)
			local obj = binds[id]
			if obj.btn then
				obj.btn.Text = obj.Key and obj.Key.Name or "—"
			end
		end

		local function bindRow(id, label)
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = label,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row
			binds[id].btn = btn
			renderBind(id)
            			Persist.addId("bind/Custom/" .. id, "bind", function() return binds[id].Key end,
				function(k) binds[id].Key = k; renderBind(id) end)
					
			btn.MouseButton1Click:Connect(function()
				if listening then
					renderBind(listening)
				end
				listening = id
				btn.Text = "Нажми клавишу…"
			end)
		end

		---------------------------------------------------------
		-- UI: FREE CAM
		---------------------------------------------------------
		UI.Section(h, "FREE CAM")
		fcToggle = UI.Toggle(h, "Free Cam", false, function(v)
			if v then
				startFreeCam()
			else
				stopFreeCam()
			end
		end)
		speedSlider = UI.Slider(h, "Скорость полёта", 2, 500, FC.Speed, 0, function(v)
			FC.Speed = v
		end)
		UI.Slider(h, "Ускорение на Shift (×)", 1, 10, FC.Fast, 1, function(v)
			FC.Fast = v
		end)
		UI.Slider(h, "Чувствительность мыши", 0.05, 1, FC.Sens, 2, function(v)
			FC.Sens = v
		end)
		UI.Toggle(h, "Плавное движение", FC.Smooth, function(v)
			FC.Smooth = v
		end)
		UI.Toggle(h, "Блокировать движение моего персонажа", CU.Freeze, function(v)
			CU.Freeze = v
			updateSink()
		end)
		UI.Note(
			h,
			"WASD — лететь, Space / Ctrl — вверх / вниз, Shift — быстрее, ПКМ + мышь — смотреть, колёсико — скорость. FOV для Free Cam берётся из вкладки Esp («Камера / FOV»). Free Cam и Spectate включаются по одному (одно выключает другое)."
		)

		---------------------------------------------------------
		-- UI: SPECTATE
		---------------------------------------------------------
		UI.Section(h, "SPECTATE (только камера)")
		spToggle = UI.Toggle(h, "Spectate", false, function(v)
			if v then
				local target = SP.Last
				if not (target and target.Parent == Players) then
					target = playersList()[1]
				end
				if target then
					startSpectate(target)
				else
					syncToggles()
				end
			else
				stopSpectate()
			end
		end)
		spStatus = UI.Note(h, "Не наблюдаю")
		UI.Button(h, "◀ Предыдущий игрок", function()
			cycleSpectate(-1)
		end)
		UI.Button(h, "Следующий игрок ▶", function()
			cycleSpectate(1)
		end)
		listGroup = UI.Group(h)
		rebuildList()
		UI.Button(h, "Обновить список игроков", rebuildList)
		UI.Note(
			h,
			"Камера следует за выбранным игроком, твой персонаж не двигается. Нажми на игрока в списке, чтобы смотреть за ним; повторное нажатие — выключить. Колёсико и ПКМ крутят камеру как обычно."
		)

		---------------------------------------------------------
		-- UI: EMOTE WHEEL
		---------------------------------------------------------
		UI.Section(h, "CUSTOM EMOTE WHEEL")
		UI.Toggle(h, "Emote Wheel", EW.Enabled, function(v)
			EW.Enabled = v
			if not v then
				closeWheel(false)
			end
		end)
		UI.Toggle(h, "Прерывать анимацию при движении", EW.StopOnMove, function(v)
			EW.StopOnMove = v
		end)
		UI.Toggle(h, "Зацикливать анимации по ID", EW.LoopAnims, function(v)
			EW.LoopAnims = v
			if currentTrack then
				currentTrack.Looped = v
			end
		end)
		UI.Slider(h, "Мёртвая зона в центре (px)", 10, 80, EW.Deadzone, 0, function(v)
			EW.Deadzone = v
		end)

		UI.Section(h, "СЛОТЫ КОЛЕСА")
		for i = 1, SLOT_COUNT do
			UI.TextInput(h, "Слот " .. i, slotText(SLOTS[i]), "эмоут / ID / Имя=ID", function(t)
				SLOTS[i] = parseSlot(t)
				refreshWheel()
				return false
			end)
		end
		emoteNote = UI.Note(
			h,
			"Колесо: зажми клавишу (по умолчанию N), двигай мышь в сторону слота и отпусти клавишу. Отпустить в центре — отмена. В слот можно вписать: название обычного эмоута (wave, dance…), ID анимации, «Имя=ID» или stop. Пустой слот отключён."
		)

		---------------------------------------------------------
		-- UI: БИНДЫ
		---------------------------------------------------------
		UI.Section(h, "БИНДЫ (нажми на кнопку, затем клавишу; Esc/Backspace — очистить)")
		bindRow("freecam", "Free Cam вкл/выкл")
		bindRow("spectate", "Spectate вкл/выкл")
		bindRow("spnext", "Следующий игрок")
		bindRow("spprev", "Предыдущий игрок")
		bindRow("wheel", "Emote Wheel (держать)")

		UIS.InputBegan:Connect(function(input, gp)
			-- режим «жду клавишу для бинда»
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local id = listening
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						binds[id].Key = nil
					elseif key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
						-- клавиша занята панелью
					else
						for otherId, o in pairs(binds) do
							if o.Key == key and otherId ~= id then
								o.Key = nil
								renderBind(otherId)
							end
						end
						binds[id].Key = key
					end
					renderBind(id)
				end
				return
			end

			if gp or not TabEnabled.Custom then
				return
			end
			local key = input.KeyCode
			if key == Enum.KeyCode.Unknown then
				return
			end

			if key == binds.wheel.Key then
				openWheel()
			elseif key == binds.freecam.Key then
				fcToggle.Set(not FC.Enabled)
			elseif key == binds.spectate.Key then
				spToggle.Set(not SP.Enabled)
			elseif key == binds.spnext.Key then
				cycleSpectate(1)
			elseif key == binds.spprev.Key then
				cycleSpectate(-1)
			end
		end)

		UIS.InputEnded:Connect(function(input)
			if wheelOpen and input.KeyCode == binds.wheel.Key then
				closeWheel(true)
			end
		end)

		layoutTabs()
	end
end

------------------------------------------------------------
-- ВТОРАЯ ПРАВКА (2 минуты): конфликт клавиш в Troll Pack.
-- В твоей панели Lock-On уже занимает Z, X, C, V, а в Troll Pack я
-- по умолчанию поставил Z, C, X — они срабатывали бы одновременно.
--
-- В блоке TROLL PACK найди
--     local KEYS = {
--         dash = Enum.KeyCode.Q,
--         goku = Enum.KeyCode.R,
--         frontflip = Enum.KeyCode.Z,
--         backflip = Enum.KeyCode.C,
--         airjump = Enum.KeyCode.E,
--         tpsave = Enum.KeyCode.X,
--         tpgo = Enum.KeyCode.Five,
--     }
-- и замени на:
--
--     local KEYS = {
--         dash = Enum.KeyCode.Q,
--         goku = Enum.KeyCode.R,
--         frontflip = Enum.KeyCode.J,
--         backflip = Enum.KeyCode.K,
--         airjump = Enum.KeyCode.E,
--         tpsave = Enum.KeyCode.T,
--         tpgo = Enum.KeyCode.Five,
--     }
------------------------------------------------------------
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO DRIBBLE
-- Вставь этот блок в Yokatta ПЕРЕД разделом «СТАРТ»
-- (после вкладки Esp). Отдельный скрипт Auto Dribble больше не нужен.
-- Использует призрака из LagGhost (workspace.lagghost).
------------------------------------------------------------
do
	local function initAutoDribble()
		local h = Holders.AutoUse
		if not h then
			return
		end
		UI.ClearPlaceholder(h)

		local LocalPlayer = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local CAS = game:GetService("ContextActionService")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoDribble")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaDribbleVis")
			if v then
				v:Destroy()
			end
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil,

			-- слайд-тэкл врага
			SlideDuration = 1.0,
			ShortSpeed = 30,
			LongSpeed = 45,
			ShortStartDist = 20,
			LongStartDist = 25,
			MaxDist = 25,
			InstantDist = 18,
			FastDist = 16.9,
			ShortTravelMin = 31,
			ShortTravelMax = 38,
			LongTravelMin = 38,
			LongTravelMax = 45,
			UseMaxTravel = true,
			TackleReach = 6,
			VertTol = 8,
			MinSlideSpeed = 10,

			-- угрозы от скиллов врага
			SkillThreats = true,
			SkillRequireFlag = true,
			SkillFacingDot = 0.6,

			-- хитбокс врага и мяч
			HitboxX = 6,
			HitboxY = 7.5,
			HitboxZ = 7.65,
			HitboxRange = 25,
			BallRadius = 1,
			BallForward = 2.5,
			BallY = -2,

			-- вращение
			UseRotation = true,
			RotMult = 1,
			MaxYawRate = 25,

			-- упреждение для мяча
			BallPingMult = 1.0,
			BallBaseLead = 0.05,
			BallMaxLead = 0.5,
			BallSampleStep = 0.02,

			-- упреждение для слайда
			PingMult = 3,
			ExtraLead = 0.05,
			MaxLead = 1,
			SeeDelayMult = 0.5,
			KeyLatency = 0,

			-- заряд удара (ChargingKick)
			ChargeEnabled = true,
			ChargeRange = 45,
			ChargeHorizon = 1.0,
			ChargeStep = 0.02,
			ChargePingMult = 1.0,
			ChargeExtra = 0.03,
			ChargeMaxLead = 0.7,
			ChargeCooldown = 0.35,

			-- реакция
			ReactCooldown = 0.00001,
			KeyHold = 0.03,
			M1BlockTime = 0.1,
			UseFeint = true, -- M1 + Q, когда Q на кулдауне, а Lift свободен
			SkillRescan = 0.5,

			-- стамина
			UseSpeedBoost = true,
			LowStamina = 15,
			RestoreStamina = 40,

			-- визуал / звук (как в оригинале сфера и круг выключены)
			ShowSphere = false,
			ShowCircle = false,
			ShowBall = true,
			ShowHitboxes = false,
			HighlightSelf = true,
			HighlightEnemy = true,
			Sound = true,

			-- GUI
			GuiShown = false,
		}

		local POSSESSION_FLAG = "Possession"
		local FEINT_BLOCK_FLAGS = { "Kick", "KickCooldown" }

		-- угрозы от скиллов врага (порядок важен: берётся первое совпадение)
		local THREATS = {
			{ cd = "IceGroundCooldown", label = "Ice Ground", radius = 30, enabled = true },
			{ cd = "MegaQuakeCooldown", label = "Mega Quake", radius = 27, enabled = true },
			{ cd = "EinstazCooldown", label = "Einstaz", radius = 25, enabled = true },
			{ cd = "IgnitedStealCooldown", label = "Ignited Steal", radius = 25, enabled = true },
			{ cd = "SpinningTopCooldown", label = "Spinning Top", radius = 17, enabled = true },
			{ cd = "KillerSlideCooldown", label = "Killer Slide", radius = 15, enabled = true },
			{ cd = "SpiralDrawCooldown", label = "Spiral Draw", radius = 12.5, enabled = true },
			{ cd = "RunningBlazeCooldown", label = "Running Blaze", radius = 11.5, enabled = true },
			{ cd = "SpinningCutCooldown", label = "Spinning Cut", radius = 11.5, enabled = true },
		}

		-- скиллы для дриблинга (порядок = приоритет, сверху выше)
		local SKILLS = {
			{ name = "Roulette", enabled = true },
			{ name = "Elastico", enabled = true },
			{ name = "Illusion Ball", enabled = true },
			{ name = "Skystep", enabled = true },
			{ name = "Flurry Dash", enabled = true },
			{ name = "Chop Dribble", enabled = true, hold = 0.1 },
			{ name = "Tsunami Boost", enabled = true },
			{ name = "Zero Reset Turn", enabled = true },
		}

		------------------------------------------------------------
		-- СОСТОЯНИЕ ПЕРСОНАЖА
		------------------------------------------------------------
		local Character, HRP, InstanceVal, StaminaValue, SpeedMultiplier
		local hasLift, hasDribble = false, false -- true = на кулдауне
		local speedBoostActive = false
		local canReact = true
		local instConns = {}
		local bindToken = 0
		local lastRebind = 0

		local skills, skillSignature = {}, ""
		local onSkillsChanged = function() end

		local SelfHighlight = Instance.new("Highlight")
		SelfHighlight.FillColor = Color3.fromRGB(255, 0, 255)
		SelfHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		SelfHighlight.FillTransparency = 1
		SelfHighlight.Enabled = false

		local AlertSound = Instance.new("Sound")
		AlertSound.SoundId = "rbxassetid://9118823101"
		AlertSound.Volume = 1

		local function updateCooldowns()
			hasLift, hasDribble = false, false
			if not InstanceVal then
				return
			end
			hasLift = InstanceVal:FindFirstChild("LiftCooldown") ~= nil
			hasDribble = InstanceVal:FindFirstChild("DribbleCooldown") ~= nil
		end

		local rescanSkills -- ниже

		local function setupCharacter(char)
			bindToken += 1
			local my = bindToken
			for _, c in ipairs(instConns) do
				c:Disconnect()
			end
			table.clear(instConns)
			Character, HRP, InstanceVal, StaminaValue, SpeedMultiplier = char, nil, nil, nil, nil
			hasLift, hasDribble = false, false
			speedBoostActive = false
			if not char then
				return
			end

			task.spawn(function()
				local hrp = char:WaitForChild("HumanoidRootPart", 10)
				local iv = char:WaitForChild("InstanceValue", 10)
				local info = char:WaitForChild("PlayerInfo", 5)
				if my ~= bindToken then
					return
				end
				HRP = hrp
				InstanceVal = iv
				if info then
					StaminaValue = info:FindFirstChild("Stamina")
					SpeedMultiplier = info:FindFirstChild("SpeedMultiplier")
				end
				if iv then
					updateCooldowns()
					table.insert(instConns, iv.ChildAdded:Connect(updateCooldowns))
					table.insert(instConns, iv.ChildRemoved:Connect(updateCooldowns))
				end
				SelfHighlight.Parent = char
				if hrp then
					AlertSound.Parent = hrp
				end
				rescanSkills()
			end)
		end

		local function hasPossession()
			return InstanceVal ~= nil and InstanceVal:FindFirstChild(POSSESSION_FLAG) ~= nil
		end

		local function feintBlocked()
			if not InstanceVal then
				return false
			end
			for _, name in ipairs(FEINT_BLOCK_FLAGS) do
				if InstanceVal:FindFirstChild(name) then
					return true
				end
			end
			return false
		end

		------------------------------------------------------------
		-- СКИЛЛЫ ИЗ BACKPACK (кнопка = Slot + 1)
		------------------------------------------------------------
		local DIGITS = {
			[1] = Enum.KeyCode.One,
			[2] = Enum.KeyCode.Two,
			[3] = Enum.KeyCode.Three,
			[4] = Enum.KeyCode.Four,
			[5] = Enum.KeyCode.Five,
			[6] = Enum.KeyCode.Six,
			[7] = Enum.KeyCode.Seven,
			[8] = Enum.KeyCode.Eight,
			[9] = Enum.KeyCode.Nine,
			[0] = Enum.KeyCode.Zero,
		}

		local function readSlot(tool)
			local s = tool:FindFirstChild("Slot")
			if s and s:IsA("ValueBase") then
				return s.Value
			end
			return tool:GetAttribute("Slot")
		end

		rescanSkills = function()
			local allowed = {}
			for _, e in ipairs(SKILLS) do
				if e.enabled then
					allowed[e.name] = e
				end
			end

			local found = {}
			local function scan(container)
				if not container then
					return
				end
				for _, tool in ipairs(container:GetChildren()) do
					if tool:IsA("Tool") and allowed[tool.Name] and not found[tool.Name] then
						local slot = tonumber(readSlot(tool))
						local key = slot and DIGITS[(slot + 1) % 10]
						if key then
							found[tool.Name] = {
								name = tool.Name,
								cd = (tool.Name:gsub("%s", "")) .. "Cooldown",
								key = key,
								keyText = tostring((slot + 1) % 10),
								hold = allowed[tool.Name].hold,
							}
						end
					end
				end
			end
			scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
			scan(Character)

			local list, parts = {}, {}
			for _, e in ipairs(SKILLS) do
				local s = found[e.name]
				if s then
					table.insert(list, s)
					table.insert(parts, e.name .. ":" .. s.keyText)
				end
			end
			local sig = table.concat(parts, "|")
			skills = list
			if sig ~= skillSignature then
				skillSignature = sig
				onSkillsChanged()
			end
		end

		local function skillOnCooldown(s)
			return InstanceVal ~= nil and InstanceVal:FindFirstChild(s.cd) ~= nil
		end

		local function pickSkill()
			for _, s in ipairs(skills) do
				if not skillOnCooldown(s) then
					return s
				end
			end
			return nil
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ (статус, стамина, кулдауны)
		------------------------------------------------------------
		local DGui = create("ScreenGui", {
			Name = "YokattaAutoDribble",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 997,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		DGui.Parent = parent

		local widgetPos = { x = 12, y = 78 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(340, 132),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = DGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "Auto Dribble: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local StaminaLabel = create("TextLabel", {
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "Стамина: -",
		})
		StaminaLabel.Parent = Widget

		local InfoLabel = create("TextLabel", {
			Position = UDim2.fromOffset(12, 106),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "Слайд: нет",
		})
		InfoLabel.Parent = Widget

		local READY_COLOR = Color3.fromRGB(0, 190, 95)
		local CD_COLOR = Color3.fromRGB(220, 60, 60)
		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			blocked = Color3.fromRGB(255, 170, 0),
			idle = Color3.fromRGB(90, 160, 255),
		}

		local CHIPS_PER_ROW = 6
		local chipOrder = {}
		local skillChips = {}

		local function newChip(text)
			local chip = create("TextLabel", {
				Size = UDim2.fromOffset(50, 20),
				BackgroundColor3 = READY_COLOR,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = Color3.new(1, 1, 1),
				Text = text,
			}, { corner(UDim.new(0, 5)) })
			chip.Parent = Widget
			return chip
		end

		local liftChip = newChip("LIFT")
		local dribChip = newChip("Q")

		local function layoutWidget()
			chipOrder = { liftChip, dribChip }
			for _, s in ipairs(skills) do
				if skillChips[s.name] then
					table.insert(chipOrder, skillChips[s.name])
				end
			end
			for i, chip in ipairs(chipOrder) do
				local col = (i - 1) % CHIPS_PER_ROW
				local row = math.floor((i - 1) / CHIPS_PER_ROW)
				chip.Position = UDim2.fromOffset(12 + col * 54, 54 + row * 24)
			end
			local rows = math.max(1, math.ceil(#chipOrder / CHIPS_PER_ROW))
			local infoY = 54 + rows * 24 + 4
			InfoLabel.Position = UDim2.fromOffset(12, infoY)
			Widget.Size = UDim2.fromOffset(340, infoY + 24)
		end

		onSkillsChanged = function()
			for _, c in pairs(skillChips) do
				c:Destroy()
			end
			table.clear(skillChips)
			for _, s in ipairs(skills) do
				local short = (s.name:gsub("%s", "")):sub(1, 4):upper()
				skillChips[s.name] = newChip(short .. " " .. s.keyText)
			end
			layoutWidget()
		end
		layoutWidget()

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local lastInfo = ""
		local function setInfo(text)
			if text == lastInfo then
				return
			end
			lastInfo = text
			InfoLabel.Text = text
		end

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local function setWidgetPos(x, y, fromDrag, xSl, ySl)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		local lastStaminaText = ""
		local function refreshPanel()
			if hasLift then
				liftChip.BackgroundColor3 = CD_COLOR
			elseif S.UseFeint and feintBlocked() then
				liftChip.BackgroundColor3 = STATUS_COLORS.blocked
			else
				liftChip.BackgroundColor3 = READY_COLOR
			end
			dribChip.BackgroundColor3 = hasDribble and CD_COLOR or READY_COLOR
			for _, s in ipairs(skills) do
				local chip = skillChips[s.name]
				if chip then
					chip.BackgroundColor3 = skillOnCooldown(s) and CD_COLOR or READY_COLOR
				end
			end

			local text, color
			if StaminaValue then
				local st = math.floor(StaminaValue.Value)
				text = "Стамина: " .. st .. (speedBoostActive and "  (буст x2)" or "")
				color = st < S.LowStamina and Color3.fromRGB(220, 60, 60) or C.TextMid
			else
				text = "Стамина: -"
				color = C.TextMid
			end
			if text ~= lastStaminaText then
				lastStaminaText = text
				StaminaLabel.Text = text
			end
			StaminaLabel.TextColor3 = color
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		local xSlider, ySlider
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- ВИЗУАЛ: сфера, круг, призрачный мяч, хитбоксы врагов
		------------------------------------------------------------
		local visFolder = Instance.new("Folder")
		visFolder.Name = "YokattaDribbleVis"
		visFolder.Parent = workspace

		local function visPart(shape, size, material, color)
			local p = Instance.new("Part")
			p.Shape = shape
			p.Size = size
			p.Transparency = 1
			p.Material = material
			p.Color = color
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Parent = visFolder
			return p
		end

		local BLUE = Color3.fromRGB(0, 170, 255)
		local MAGENTA = Color3.fromRGB(255, 0, 255)
		local YELLOW = Color3.fromRGB(255, 255, 0)
		local Sphere = visPart(Enum.PartType.Ball, Vector3.new(50, 50, 50), Enum.Material.ForceField, BLUE)
		local Circle = visPart(Enum.PartType.Cylinder, Vector3.new(0.15, 50, 50), Enum.Material.Neon, BLUE)
		local GhostBall = visPart(Enum.PartType.Ball, Vector3.new(2, 2, 2), Enum.Material.Neon, YELLOW)
		GhostBall.Name = "GhostBall"

		local Hitboxes = {}
		local HIT_COLOR = Color3.fromRGB(255, 60, 60)
		local HIT_TOUCH_COLOR = MAGENTA
		local EnemyHighlights = {}
		local visActive = false

		local function applyVisualStyle(active)
			local d = S.MaxDist
			Sphere.Size = Vector3.new(d * 2, d * 2, d * 2)
			Circle.Size = Vector3.new(0.15, d * 2, d * 2)
			GhostBall.Size = Vector3.new(S.BallRadius * 2, S.BallRadius * 2, S.BallRadius * 2)
			Sphere.Transparency = (active and S.ShowSphere) and 0.8 or 1
			Circle.Transparency = (active and S.ShowCircle) and 0.3 or 1
			GhostBall.Transparency = (active and S.ShowBall) and 0.45 or 1
			for _, hb in pairs(Hitboxes) do
				hb.Transparency = (active and S.ShowHitboxes) and 0.6 or 1
			end
			if not active then
				GhostBall.Position = Vector3.new(0, -5000, 0)
			end
		end
		applyVisualStyle(false)

		local function setVisualActive(on)
			if visActive == on then
				return
			end
			visActive = on
			applyVisualStyle(on)
		end

		local function restyle()
			applyVisualStyle(visActive)
		end

		local function getHitbox(player)
			local hb = Hitboxes[player]
			if hb and hb.Parent then
				return hb
			end
			hb = visPart(Enum.PartType.Block, Vector3.new(S.HitboxX, S.HitboxY, S.HitboxZ), Enum.Material.Neon, HIT_COLOR)
			hb.Name = "EnemyHitbox"
			hb.Transparency = (visActive and S.ShowHitboxes) and 0.6 or 1
			Hitboxes[player] = hb
			return hb
		end

		local function removeHitbox(player)
			local hb = Hitboxes[player]
			if hb then
				hb:Destroy()
				Hitboxes[player] = nil
			end
		end

		local function clearHitboxes()
			for p in pairs(Hitboxes) do
				removeHitbox(p)
			end
		end

		local function clearEnemyHighlights()
			for p, hl in pairs(EnemyHighlights) do
				hl:Destroy()
				EnemyHighlights[p] = nil
			end
		end

		------------------------------------------------------------
		-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
		------------------------------------------------------------
		local function isEnemy(player)
			local my = LocalPlayer:FindFirstChild("MatchTeam")
			local his = player:FindFirstChild("MatchTeam")
			if not my or not his then
				return true
			end
			return my.Value ~= his.Value
		end

		-- нажатые нами клавиши: чтобы собственный бинд не срабатывал от виртуального нажатия
		local injecting = {}
		local function pressKey(key, hold)
			if not VIM then
				return
			end
			injecting[key] = (injecting[key] or 0) + 1
			VIM:SendKeyEvent(true, key, false, game)
			task.delay(hold or S.KeyHold, function()
				VIM:SendKeyEvent(false, key, false, game)
				task.delay(0.15, function()
					injecting[key] = (injecting[key] or 1) - 1
					if injecting[key] <= 0 then
						injecting[key] = nil
					end
				end)
			end)
		end

		-- блок M1 после дриблинга
		local m1BlockUntil = 0
		local m1Bound = false
		local M1_ACTION = "YokattaBlockM1AfterDribble"

		local function blockM1(duration)
			m1BlockUntil = os.clock() + duration
			if m1Bound then
				return
			end
			m1Bound = true

			CAS:BindActionAtPriority(M1_ACTION, function(_, state)
				if state == Enum.UserInputState.Begin and os.clock() < m1BlockUntil then
					return Enum.ContextActionResult.Sink
				end
				return Enum.ContextActionResult.Pass
			end, false, Enum.ContextActionPriority.High.Value + 1000, Enum.UserInputType.MouseButton1)

			task.spawn(function()
				while os.clock() < m1BlockUntil do
					task.wait()
				end
				CAS:UnbindAction(M1_ACTION)
				m1Bound = false
			end)
		end

		local function nothingToPress()
			if StaminaValue and StaminaValue.Value < S.LowStamina then
				return true
			end
			if hasDribble and not pickSkill() then
				return true
			end
			if not hasDribble and hasLift and (not S.UseFeint or feintBlocked()) then
				return true
			end
			return false
		end

		local function react()
			if hasDribble then
				local s = pickSkill()
				if s then
					pressKey(s.key, s.hold or S.KeyHold)
					blockM1(S.M1BlockTime)
				end
			elseif hasLift then
				-- Feint (M1 + Q): нельзя при Kick / KickCooldown
				if not S.UseFeint or feintBlocked() or not VIM then
					return
				end
				local pos = UIS:GetMouseLocation()
				VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
				pressKey(Enum.KeyCode.Q)
				task.delay(S.KeyHold, function()
					VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
				end)
			else
				pressKey(Enum.KeyCode.Q)
				blockM1(S.M1BlockTime)
			end
		end

		local function restoreSpeed()
			if not speedBoostActive then
				return
			end
			speedBoostActive = false
			if SpeedMultiplier then
				local old = SpeedMultiplier:GetAttribute("OldSpeed")
				if old ~= nil then
					SpeedMultiplier.Value = old
					SpeedMultiplier:SetAttribute("OldSpeed", nil)
				end
			end
		end

		local function updateSpeedBoost(danger)
			if not (S.UseSpeedBoost and StaminaValue and SpeedMultiplier) then
				return
			end
			if danger and StaminaValue.Value < S.LowStamina and not speedBoostActive then
				speedBoostActive = true
				SpeedMultiplier:SetAttribute("OldSpeed", SpeedMultiplier.Value)
				SpeedMultiplier.Value = 2
			elseif speedBoostActive and StaminaValue.Value >= S.RestoreStamina then
				restoreSpeed()
			end
		end

		------------------------------------------------------------
		-- ПРЕДСКАЗАНИЕ
		------------------------------------------------------------
		local function flat(v)
			return Vector3.new(v.X, 0, v.Z)
		end

		local function rotateY(v, angle)
			return CFrame.Angles(0, angle, 0):VectorToWorldSpace(v)
		end

		local function blend(speed)
			if speed <= S.ShortSpeed then
				return 0
			end
			if speed >= S.LongSpeed then
				return 1
			end
			return (speed - S.ShortSpeed) / math.max(0.001, S.LongSpeed - S.ShortSpeed)
		end

		local function getStartDist(speed)
			local d = S.ShortStartDist + (S.LongStartDist - S.ShortStartDist) * blend(speed)
			return math.min(d, S.MaxDist)
		end

		local function getTravel(speed)
			local a = blend(speed)
			local mn = S.ShortTravelMin + (S.LongTravelMin - S.ShortTravelMin) * a
			local mx = S.ShortTravelMax + (S.LongTravelMax - S.ShortTravelMax) * a
			return S.UseMaxTravel and mx or (mn + mx) / 2
		end

		local function slideType(speed)
			if speed <= S.ShortSpeed then
				return "короткий"
			end
			if speed >= S.LongSpeed then
				return "длинный"
			end
			return "средний"
		end

		local function timeToContact(r0, rv, reach, maxT)
			local c = r0:Dot(r0) - reach * reach
			if c <= 0 then
				return 0
			end
			local a = rv:Dot(rv)
			if a < 1e-4 then
				return nil
			end
			local b = 2 * r0:Dot(rv)
			local disc = b * b - 4 * a * c
			if disc < 0 then
				return nil
			end
			local t = (-b - math.sqrt(disc)) / (2 * a)
			if t < 0 or t > maxT then
				return nil
			end
			return t
		end

		local function sphereTouchesBox(center, radius, boxCF, size)
			local lp = boxCF:PointToObjectSpace(center)
			local hs = size * 0.5
			local cx = math.clamp(lp.X, -hs.X, hs.X)
			local cy = math.clamp(lp.Y, -hs.Y, hs.Y)
			local cz = math.clamp(lp.Z, -hs.Z, hs.Z)
			local dx, dy, dz = lp.X - cx, lp.Y - cy, lp.Z - cz
			return dx * dx + dy * dy + dz * dz <= radius * radius
		end

		local function getSkillThreat(folder)
			if not S.SkillThreats or not folder then
				return nil
			end
			if S.SkillRequireFlag and not folder:FindFirstChild("Skill") then
				return nil
			end
			for _, th in ipairs(THREATS) do
				if th.enabled and folder:FindFirstChild(th.cd) then
					return th.radius, th.cd
				end
			end
			return nil
		end

		local LG -- HumanoidRootPart призрака (workspace.lagghost)

		local function getLG()
			if LG and LG.Parent then
				return LG
			end
			local m = workspace:FindFirstChild("lagghost")
			LG = m and m:FindFirstChild("HumanoidRootPart") or nil
			return LG
		end

		local function isFacingLG(enemyHRP, yawAhead)
			local dir = flat(LG.Position - enemyHRP.Position)
			if dir.Magnitude < 0.001 then
				return false
			end
			local look = flat(enemyHRP.CFrame.LookVector)
			if look.Magnitude < 0.001 then
				return false
			end
			if yawAhead and yawAhead ~= 0 then
				look = rotateY(look, yawAhead)
			end
			return look.Unit:Dot(dir.Unit) > S.SkillFacingDot
		end

		local trackers, slides, yawTrackers = {}, {}, {}

		local function updateTracker(key, pos, now)
			local tr = trackers[key]
			if not tr then
				trackers[key] = { pos = pos, t = now, vel = Vector3.zero }
				return trackers[key]
			end
			local dt = now - tr.t
			if dt < 0.004 then
				return tr
			end
			local instant = (pos - tr.pos) / dt
			if instant.Magnitude > 1500 then
				tr.vel = Vector3.zero
			else
				tr.vel = tr.vel:Lerp(instant, 0.9)
			end
			tr.pos = pos
			tr.t = now
			return tr
		end

		local function updateYawRate(key, cf, now)
			local _, yaw = cf:ToOrientation()
			local tr = yawTrackers[key]
			if not tr then
				yawTrackers[key] = { yaw = yaw, t = now, rate = 0 }
				return 0
			end
			local dt = now - tr.t
			if dt < 0.004 then
				return tr.rate
			end
			local d = (yaw - tr.yaw + math.pi) % (2 * math.pi) - math.pi
			local r = d / dt
			if math.abs(r) > S.MaxYawRate then
				r = 0
			end
			tr.rate = tr.rate + (r - tr.rate) * 0.5
			tr.yaw = yaw
			tr.t = now
			return tr.rate
		end

		-- пинг
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local ping = readPing() or 0.05
		local function updatePing(dt)
			local p = readPing()
			if p then
				ping = ping + (math.clamp(p, 0, 1) - ping) * math.clamp(dt * 5, 0, 1)
			end
		end

		-- упреждающий дриблинг: время касания хитбокса врага с мячом призрака (или nil)
		local function predictContact(EnemyHRP, eVel, enemyYawRate, seeDelay, fwd, lgVel, lgYawRate, maxT, stepT, hsize)
			local enemyRot = EnemyHRP.CFrame.Rotation
			local n = math.max(1, math.ceil(maxT / math.max(0.005, stepT)))
			for i = 0, n do
				local t = maxT * i / n
				local tt = seeDelay + t
				local eCF = CFrame.new(EnemyHRP.Position + eVel * tt)
					* CFrame.Angles(0, enemyYawRate * tt, 0)
					* enemyRot
				local bPos = LG.Position
					+ lgVel * t
					+ rotateY(fwd * S.BallForward, lgYawRate * t)
					+ Vector3.new(0, S.BallY, 0)
				if sphereTouchesBox(bPos, S.BallRadius, eCF, hsize) then
					return t
				end
			end
			return nil
		end

		------------------------------------------------------------
		-- ОСНОВНОЙ ШАГ
		------------------------------------------------------------
		local panelTimer, rescanTimer, lastStep = 0, 0, 0
		local lastChargeReact = 0
		local idleDone = false

		local function cleanupIdle()
			SelfHighlight.Enabled = false
			clearEnemyHighlights()
			clearHitboxes()
			setVisualActive(false)
			Sphere.Color = BLUE
			Circle.Color = BLUE
			setInfo("Слайд: нет")
			restoreSpeed()
			table.clear(slides)
		end

		local function step(dt, force)
			local now = os.clock()
			if not force and now - lastStep < 0.004 then
				return
			end
			lastStep = now

			updatePing(dt)
			local lead = math.clamp(ping * S.PingMult + S.ExtraLead + S.KeyLatency, 0, S.MaxLead)
			local seeDelay = ping * S.SeeDelayMult
			local ballLead = math.clamp(ping * S.BallPingMult + S.BallBaseLead + S.KeyLatency, 0, S.BallMaxLead)
			local ballSamples = math.max(1, math.ceil(ballLead / math.max(0.005, S.BallSampleStep)))
			local chargeLead = math.clamp(ping * S.ChargePingMult + S.ChargeExtra + S.KeyLatency, 0, S.ChargeMaxLead)

			panelTimer += dt
			if panelTimer >= 0.1 then
				panelTimer = 0
				refreshPanel()
			end

			rescanTimer += dt
			if rescanTimer >= S.SkillRescan then
				rescanTimer = 0
				rescanSkills()
			end

			local lgOld = LG
			if not getLG() then
				if S.Enabled then
					setStatus("idle", "Нет призрака (lagghost)")
				end
				return
			end
			if LG ~= lgOld then
				trackers["lagghost"] = nil
				yawTrackers["lagghost"] = nil
			end

			local lgTracker = updateTracker("lagghost", LG.Position, now)
			local lgVel = flat(lgTracker.vel)
			local rotK = S.UseRotation and S.RotMult or 0
			local lgYawRate = updateYawRate("lagghost", LG.CFrame, now) * rotK

			if not S.Enabled then
				return
			end

			-- на случай пересоздания InstanceValue
			if InstanceVal and not InstanceVal.Parent and now - lastRebind > 1 then
				lastRebind = now
				setupCharacter(LocalPlayer.Character)
			end

			-- работаем только при наличии Possession
			if not hasPossession() then
				if not idleDone then
					idleDone = true
					cleanupIdle()
				end
				setStatus("idle", "Ждёт мяч (нет Possession)")
				return
			end
			idleDone = false
			setVisualActive(true)

			local HSIZE = Vector3.new(S.HitboxX, S.HitboxY, S.HitboxZ)

			local fwd
			if lgVel.Magnitude > 2 then
				fwd = lgVel.Unit
			else
				fwd = flat(LG.CFrame.LookVector)
				fwd = fwd.Magnitude > 0 and fwd.Unit or Vector3.new(0, 0, -1)
			end
			local ballPos = LG.Position + fwd * S.BallForward + Vector3.new(0, S.BallY, 0)
			GhostBall.Position = ballPos

			local threatened = {}
			local danger = false
			local bestT, bestRem = nil, nil
			local bestInstant, bestFast = false, false
			local ballHit, ballT = false, nil
			local skillThreatInfo, sliderInfo = nil, nil
			local touching = {}
			local chargeT, chargeInfo = nil, nil

			for _, Player in ipairs(Players:GetPlayers()) do
				if Player ~= LocalPlayer and isEnemy(Player) then
					local EnemyCharacter = Player.Character
					local EnemyHRP = EnemyCharacter and EnemyCharacter:FindFirstChild("HumanoidRootPart")

					if EnemyHRP then
						local tr = updateTracker(Player, EnemyHRP.Position, now)
						local enemyYawRate = updateYawRate(Player, EnemyHRP.CFrame, now) * rotK

						local eVelAll = flat(EnemyHRP.AssemblyLinearVelocity)
						if eVelAll.Magnitude < 1 then
							eVelAll = flat(tr.vel)
						end

						local dist0 = flat(EnemyHRP.Position - LG.Position).Magnitude

						local folder = EnemyCharacter:FindFirstChild("InstanceValue")
						local isKicking = folder ~= nil
							and (folder:FindFirstChild("Kick") ~= nil or folder:FindFirstChild("ChargingKick") ~= nil)

						-- угроза от скилла врага
						local skillRadius, skillCd = getSkillThreat(folder)
						if skillRadius and dist0 <= skillRadius and isFacingLG(EnemyHRP, enemyYawRate * seeDelay) then
							danger = true
							threatened[Player] = EnemyCharacter
							skillThreatInfo = string.format(
								"СКИЛЛ %s: %s, дист. %.1f / %.1f",
								Player.Name,
								(skillCd:gsub("Cooldown$", "")),
								dist0,
								skillRadius
							)
						end

						-- хитбокс + мяч
						if dist0 <= S.HitboxRange then
							local hb = getHitbox(Player)
							hb.Size = HSIZE
							hb.CFrame = EnemyHRP.CFrame

							local enemyRot = EnemyHRP.CFrame.Rotation
							local touchAt = nil
							for i = 0, ballSamples do
								local t = ballLead * i / ballSamples
								local tt = seeDelay + t
								local eCF = CFrame.new(EnemyHRP.Position + eVelAll * tt)
									* CFrame.Angles(0, enemyYawRate * tt, 0)
									* enemyRot
								local bPos = LG.Position
									+ lgVel * t
									+ rotateY(fwd * S.BallForward, lgYawRate * t)
									+ Vector3.new(0, S.BallY, 0)
								if sphereTouchesBox(bPos, S.BallRadius, eCF, HSIZE) then
									touchAt = t
									break
								end
							end

							if touchAt and isKicking then
								touching[Player] = true
								danger = true
								ballHit = true
								threatened[Player] = EnemyCharacter
								if not ballT or touchAt < ballT then
									ballT = touchAt
								end
							end
						else
							removeHitbox(Player)
						end

						-- упреждающий дриблинг против ChargingKick
						local charging = folder ~= nil and folder:FindFirstChild("ChargingKick") ~= nil
						if S.ChargeEnabled and charging and dist0 <= S.ChargeRange then
							local tc = predictContact(
								EnemyHRP,
								eVelAll,
								enemyYawRate,
								seeDelay,
								fwd,
								lgVel,
								lgYawRate,
								S.ChargeHorizon,
								S.ChargeStep,
								HSIZE
							)
							if tc and tc <= chargeLead then
								threatened[Player] = EnemyCharacter
								if not chargeT or tc < chargeT then
									chargeT = tc
									chargeInfo = string.format(
										"ЗАРЯД %s: контакт %.2f с (упреждение %.2f) | %d мс",
										Player.Name,
										tc,
										chargeLead,
										math.floor(ping * 1000)
									)
								end
							end
						end

						-- слайд
						local sliding = folder and folder:FindFirstChild("SlideTackle") ~= nil
						local sl = slides[Player]

						if sliding then
							if not sl then
								sl = { start = now, pos = EnemyHRP.Position, speed0 = 0 }
								slides[Player] = sl
							end
						else
							slides[Player] = nil
							sl = nil
						end

						if sl then
							local eVel = eVelAll
							local speed = eVel.Magnitude

							if now - sl.start < 0.15 and speed > sl.speed0 then
								sl.speed0 = speed
							end
							local classSpeed = sl.speed0 > 0 and sl.speed0 or speed

							if dist0 <= S.FastDist then
								danger = true
								threatened[Player] = EnemyCharacter
								bestFast = true
								bestT, bestRem = 0, 0
								bestInstant = true
							end

							if speed >= S.MinSlideSpeed then
								local delta = EnemyHRP.Position - LG.Position
								local dist = flat(delta).Magnitude
								local startDist = getStartDist(classSpeed)
								local travel = getTravel(classSpeed)
								local r0 = flat(delta) + eVel * seeDelay

								sliderInfo = string.format(
									"%s: %.0f ст/с, %s (%.0f ст), дист. %.1f",
									Player.Name,
									classSpeed,
									slideType(classSpeed),
									travel,
									dist
								)

								if dist <= startDist and math.abs(delta.Y) <= S.VertTol then
									local elapsed = (now - sl.start) + seeDelay
									local remainingT = S.SlideDuration - elapsed
									local traveled = flat(EnemyHRP.Position - sl.pos).Magnitude + speed * seeDelay
									local remainingD = travel - traveled

									if remainingT > 0 and remainingD > 0 then
										local t = timeToContact(r0, eVel - lgVel, S.TackleReach, remainingT)
										if t and speed * t <= remainingD + 1 then
											local instant = dist <= S.InstantDist
											if instant or t <= lead then
												danger = true
												threatened[Player] = EnemyCharacter
												if not bestT or t < bestT then
													bestT, bestRem = t, remainingD
													bestInstant = instant
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end

			-- 1) нажатие
			local blocked = false
			if danger then
				if nothingToPress() then
					blocked = true
				elseif canReact then
					canReact = false
					react()
					task.delay(S.ReactCooldown, function()
						canReact = true
					end)
				end
			end

			-- 1б) упреждающее нажатие по ChargingKick (одно на заряд)
			if not danger and chargeT then
				if canReact and now - lastChargeReact >= S.ChargeCooldown and not nothingToPress() then
					lastChargeReact = now
					canReact = false
					react()
					task.delay(S.ReactCooldown, function()
						canReact = true
					end)
				end
				danger = true
			end

			-- 2) визуал
			Sphere.Position = LG.Position
			Circle.CFrame = CFrame.new(LG.Position.X, LG.Position.Y - 2.9, LG.Position.Z)
				* CFrame.Angles(0, 0, math.rad(90))

			for p, hb in pairs(Hitboxes) do
				hb.Color = touching[p] and HIT_TOUCH_COLOR or HIT_COLOR
			end
			GhostBall.Color = ballHit and HIT_TOUCH_COLOR or YELLOW

			for p, char in pairs(threatened) do
				if S.HighlightEnemy and not EnemyHighlights[p] then
					local hl = Instance.new("Highlight")
					hl.FillColor = MAGENTA
					hl.OutlineColor = Color3.new(1, 1, 1)
					hl.FillTransparency = 0.3
					hl.Parent = char
					EnemyHighlights[p] = hl
				end
			end
			for p, hl in pairs(EnemyHighlights) do
				if not threatened[p] or not S.HighlightEnemy then
					hl:Destroy()
					EnemyHighlights[p] = nil
				end
			end

			if danger then
				if ballHit then
					setInfo(string.format("МЯЧ: касание через %.2f с | %d мс", ballT or 0, math.floor(ping * 1000)))
				elseif bestT then
					setInfo(string.format(
						"%s: контакт %.2f с | остаток %.0f ст | %d мс",
						bestFast and "МГНОВЕННО" or (bestInstant and "БЛИЖНЯЯ" or "Дальняя"),
						bestT,
						bestRem or 0,
						math.floor(ping * 1000)
					))
				else
					setInfo(chargeInfo or skillThreatInfo or "УГРОЗА")
				end
			else
				setInfo(sliderInfo or "Слайд: нет")
			end

			updateSpeedBoost(danger)

			if danger then
				SelfHighlight.Enabled = S.HighlightSelf
				Sphere.Color = MAGENTA
				Circle.Color = MAGENTA

				if S.Sound and not AlertSound.IsPlaying then
					AlertSound:Play()
				end

				if blocked then
					setStatus("blocked", "УГРОЗА: нет действий")
				else
					setStatus(
						"danger",
						ballHit and "УГРОЗА: мяч!"
							or (bestT and "УГРОЗА: подкат!" or (chargeT and "УГРОЗА: удар заранее!" or "УГРОЗА: скилл!"))
					)
				end
			else
				SelfHighlight.Enabled = false
				Sphere.Color = BLUE
				Circle.Color = BLUE
				setStatus("on", "Auto Dribble: ВКЛ")
			end
		end

		RunService.PreRender:Connect(function(dt)
			step(dt, false)
		end)
		RunService.Heartbeat:Connect(function(dt)
			step(dt, false)
		end)

		-- мгновенная реакция в момент начала чужого слайда
		local function hookPlayer(p)
			if p == LocalPlayer then
				return
			end
			local function hookChar(char)
				task.spawn(function()
					local folder = char:WaitForChild("InstanceValue", 10)
					if not folder then
						return
					end
					folder.ChildAdded:Connect(function(child)
						if child.Name == "SlideTackle" and S.Enabled then
							step(0, true)
						end
					end)
				end)
			end
			if p.Character then
				hookChar(p.Character)
			end
			p.CharacterAdded:Connect(hookChar)
		end
		for _, p in ipairs(Players:GetPlayers()) do
			hookPlayer(p)
		end
		Players.PlayerAdded:Connect(hookPlayer)

		Players.PlayerRemoving:Connect(function(p)
			if EnemyHighlights[p] then
				EnemyHighlights[p]:Destroy()
				EnemyHighlights[p] = nil
			end
			removeHitbox(p)
			trackers[p] = nil
			yawTrackers[p] = nil
			slides[p] = nil
		end)

		LocalPlayer.CharacterAdded:Connect(setupCharacter)
		setupCharacter(LocalPlayer.Character)

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "Auto Dribble: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			idleDone = false
			if S.Enabled then
				setStatus("on", "Auto Dribble: ВКЛ")
			else
				cleanupIdle()
				refreshOffText()
			end
		end
		refreshOffText()

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		-- сворачиваемая секция настроек
		local function foldout(title)
			local btn, g
			btn = UI.Button(h, "▸ " .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = false
			return g
		end

		-- бинд (клик -> нажми клавишу; Esc/Backspace — очистить)
		local listening = nil
		local bindBtn
		do
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = "Бинд вкл/выкл",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			bindBtn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			bindBtn.Parent = row
		end

		local function renderBind()
			bindBtn.Text = S.Key and S.Key.Name or "—"
			refreshOffText()
		end
		renderBind()
        		Persist.addId("bind/AutoDribble/Key", "bind", function() return S.Key end,
			function(k) S.Key = k; renderBind() end)

		bindBtn.MouseButton1Click:Connect(function()
			listening = true
			bindBtn.Text = "Нажми клавишу…"
		end)

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO DRIBBLE")
		local mainToggle = UI.Toggle(h, "Auto Dribble", false, setEnabled)
		-- (бинд-строка создана выше, но стоит в списке первой после секции только если порядок совпал;
		-- поэтому остальные настройки идут ниже)

		UI.Note(
			h,
			"Работает только пока у тебя в InstanceValue есть Possession и существует призрак LagGhost (workspace.lagghost). Защищает дриблингом от слайдов, скиллов врага, хитбокса врага с мячом и заряда удара. Бинд: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить)."
		)

		------------------------------------------------------------
		-- UI: ДИСТАНЦИИ СЛАЙДА
		------------------------------------------------------------
		local gSlide = foldout("Дистанции и слайд-тэкл")
		slider(gSlide, "Макс. дистанция (студы)", 5, 80, "MaxDist", 1, restyle)
		slider(gSlide, "Мгновенная дистанция", 0, 60, "InstantDist", 1)
		slider(gSlide, "Дистанция «сразу» (FAST)", 0, 60, "FastDist", 1)
		slider(gSlide, "Старт: короткий слайд", 0, 80, "ShortStartDist", 1)
		slider(gSlide, "Старт: длинный слайд", 0, 80, "LongStartDist", 1)
		slider(gSlide, "Скорость «короткого» слайда", 0, 100, "ShortSpeed", 1)
		slider(gSlide, "Скорость «длинного» слайда", 0, 150, "LongSpeed", 1)
		slider(gSlide, "Путь короткого: мин", 0, 100, "ShortTravelMin", 1)
		slider(gSlide, "Путь короткого: макс", 0, 100, "ShortTravelMax", 1)
		slider(gSlide, "Путь длинного: мин", 0, 120, "LongTravelMin", 1)
		slider(gSlide, "Путь длинного: макс", 0, 120, "LongTravelMax", 1)
		toggle(gSlide, "Брать максимальный путь слайда", "UseMaxTravel")
		slider(gSlide, "Длительность слайда (сек)", 0.2, 3, "SlideDuration", 2)
		slider(gSlide, "Радиус тэкла врага", 0, 20, "TackleReach", 1)
		slider(gSlide, "Допуск по высоте", 0, 30, "VertTol", 1)
		slider(gSlide, "Мин. скорость слайда", 0, 60, "MinSlideSpeed", 1)

		------------------------------------------------------------
		-- UI: ХИТБОКС И МЯЧ
		------------------------------------------------------------
		local gHit = foldout("Хитбокс врага и мяч")
		slider(gHit, "Хитбокс X", 0.5, 40, "HitboxX", 2)
		slider(gHit, "Хитбокс Y", 0.5, 40, "HitboxY", 2)
		slider(gHit, "Хитбокс Z", 0.5, 40, "HitboxZ", 2)
		slider(gHit, "Дистанция проверки хитбокса", 5, 100, "HitboxRange", 1)
		slider(gHit, "Радиус мяча", 0.2, 6, "BallRadius", 2, restyle)
		slider(gHit, "Мяч вперёд от призрака", -5, 10, "BallForward", 2)
		slider(gHit, "Мяч по высоте (Y)", -6, 4, "BallY", 2)
		toggle(gHit, "Учитывать вращение (призрак и враги)", "UseRotation")
		slider(gHit, "Множитель вращения", 0, 2, "RotMult", 2)
		slider(gHit, "Макс. скорость вращения (рад/с)", 1, 60, "MaxYawRate", 1)

		------------------------------------------------------------
		-- UI: УПРЕЖДЕНИЕ
		------------------------------------------------------------
		local gLead = foldout("Упреждение (пинг)")
		UI.Section(gLead, "СЛАЙД")
		slider(gLead, "Множитель пинга", 0, 10, "PingMult", 2)
		slider(gLead, "Доп. запас (сек)", -0.3, 1, "ExtraLead", 3)
		slider(gLead, "Макс. упреждение (сек)", 0.05, 2, "MaxLead", 2)
		slider(gLead, "Задержка «вижу» (× пинг)", 0, 2, "SeeDelayMult", 2)
		slider(gLead, "Задержка нажатия (сек)", -0.2, 0.5, "KeyLatency", 3)
		UI.Section(gLead, "МЯЧ / ХИТБОКС")
		slider(gLead, "Множитель пинга (мяч)", 0, 5, "BallPingMult", 2)
		slider(gLead, "Базовое упреждение (сек)", 0, 0.5, "BallBaseLead", 3)
		slider(gLead, "Макс. упреждение (сек)", 0.05, 1.5, "BallMaxLead", 2)
		slider(gLead, "Шаг проверки (сек)", 0.005, 0.1, "BallSampleStep", 3)
		UI.Section(gLead, "РЕАКЦИЯ")
		slider(gLead, "Пауза между нажатиями (сек)", 0, 1, "ReactCooldown", 4)
		slider(gLead, "Удержание клавиши (сек)", 0.01, 0.3, "KeyHold", 3)
		slider(gLead, "Блок M1 после дриблинга (сек)", 0, 1, "M1BlockTime", 2)

		------------------------------------------------------------
		-- UI: ЗАРЯД УДАРА
		------------------------------------------------------------
		local gCharge = foldout("Заряд удара (ChargingKick)")
		toggle(gCharge, "Дриблинг заранее на заряд", "ChargeEnabled")
		slider(gCharge, "Дистанция до врага", 5, 120, "ChargeRange", 1)
		slider(gCharge, "Горизонт поиска (сек)", 0.1, 3, "ChargeHorizon", 2)
		slider(gCharge, "Шаг проверки (сек)", 0.005, 0.1, "ChargeStep", 3)
		slider(gCharge, "Множитель пинга", 0, 5, "ChargePingMult", 2)
		slider(gCharge, "Доп. запас (сек)", -0.3, 1, "ChargeExtra", 3)
		slider(gCharge, "Макс. упреждение (сек)", 0.05, 2, "ChargeMaxLead", 2)
		slider(gCharge, "Кулдаун на заряд (сек)", 0.05, 2, "ChargeCooldown", 2)

		------------------------------------------------------------
		-- UI: СКИЛЛЫ ВРАГА
		------------------------------------------------------------
		local gThreat = foldout("Скиллы врага (угрозы)")
		toggle(gThreat, "Реагировать на скиллы врага", "SkillThreats")
		toggle(gThreat, "Нужен флаг «Skill» у врага", "SkillRequireFlag")
		slider(gThreat, "Враг смотрит на призрака (dot)", -1, 1, "SkillFacingDot", 2)
		for _, th in ipairs(THREATS) do
			UI.Section(gThreat, string.upper(th.label))
			UI.Toggle(gThreat, th.label .. " — включено", th.enabled, function(v)
				th.enabled = v
			end)
			UI.Slider(gThreat, th.label .. " — радиус", 0, 80, th.radius, 1, function(v)
				th.radius = v
			end)
		end

		------------------------------------------------------------
		-- UI: СКИЛЛЫ ДЛЯ ДРИБЛИНГА
		------------------------------------------------------------
		local gSkills = foldout("Скиллы для дриблинга")
		toggle(gSkills, "Feint (M1 + Q), когда Q на кулдауне", "UseFeint")
		UI.Note(
			gSkills,
			"Включённые скиллы из инвентаря используются сверху вниз (приоритет = порядок в списке). Кнопка берётся из Slot + 1."
		)

		local skillRows = UI.Group(gSkills)
		local customRows = {}

		local function addSkillRow(entry)
			local g = UI.Group(skillRows)
			UI.Toggle(g, entry.name, entry.enabled, function(v)
				entry.enabled = v
				rescanSkills()
			end)
			return g
		end
		for _, e in ipairs(SKILLS) do
			addSkillRow(e)
		end

		UI.TextInput(gSkills, "Добавить скилл", "", "Название + Enter", function(t, enter)
			if not enter then
				return false
			end
			local name = t:match("^%s*(.-)%s*$")
			if name == "" then
				return false
			end
			for _, e in ipairs(SKILLS) do
				if e.name:lower() == name:lower() then
					return true
				end
			end
			local entry = { name = name, enabled = true, custom = true }
			table.insert(SKILLS, entry)
			table.insert(customRows, { entry = entry, group = addSkillRow(entry) })
			rescanSkills()
			return true
		end)
		UI.Button(gSkills, "Удалить последний свой скилл", function()
			local r = table.remove(customRows)
			if not r then
				return
			end
			local i = table.find(SKILLS, r.entry)
			if i then
				table.remove(SKILLS, i)
			end
			r.group:Destroy()
			rescanSkills()
		end)

		------------------------------------------------------------
		-- UI: СТАМИНА
		------------------------------------------------------------
		local gStam = foldout("Стамина / буст скорости")
		toggle(gStam, "Буст скорости при низкой стамине", "UseSpeedBoost", function(v)
			if not v then
				restoreSpeed()
			end
		end)
		slider(gStam, "Низкая стамина (ниже)", 0, 100, "LowStamina", 0)
		slider(gStam, "Вернуть скорость (от)", 0, 100, "RestoreStamina", 0)

		------------------------------------------------------------
		-- UI: ВИЗУАЛ
		------------------------------------------------------------
		local gVis = foldout("Визуал и звук")
		toggle(gVis, "Призрачный мяч", "ShowBall", restyle)
		toggle(gVis, "Хитбоксы врагов", "ShowHitboxes", restyle)
		toggle(gVis, "Сфера вокруг призрака", "ShowSphere", restyle)
		toggle(gVis, "Круг на земле", "ShowCircle", restyle)
		toggle(gVis, "Подсветка меня при угрозе", "HighlightSelf")
		toggle(gVis, "Подсветка угрожающих врагов", "HighlightEnemy")
		toggle(gVis, "Звук при угрозе", "Sound")

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		local gGui = foldout("GUI Auto Dribble")
		UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
			S.GuiShown = v
			Widget.Visible = v
		end)
		UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(gGui, "Сбросить позицию GUI", function()
			setWidgetPos(12, 78)
			xSlider.Set(12, true)
			ySlider.Set(78, true)
		end)
		UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						S.Key = nil
					elseif key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
						-- клавиша занята панелью — оставляем прежний бинд
					else
						S.Key = key
					end
					renderBind()
				end
				return
			end

			if gp or not S.Key then
				return
			end
			-- игнорируем виртуальные нажатия самого скрипта (скиллы на цифрах)
			if injecting[input.KeyCode] then
				return
			end
			if input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			end
		end)

		-- отдаём наружу
		shared.AutoDribble = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoDribble)
	if not ok then
		warn("[Yokatta] AutoDribble: " .. tostring(err))
	end

end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO M1 TACKLE
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto Dribble
-- (и тоже ПЕРЕД разделом «СТАРТ»). Отдельный скрипт больше не нужен.
-- Использует призрака из LagGhost (workspace.lagghost).
------------------------------------------------------------
do
	local function initAutoTackle()
		local h = Holders.AutoUse
		if not h then
			return
		end
		-- UI.ClearPlaceholder(h) уже вызван блоком Auto Dribble.
		-- Если используешь этот блок БЕЗ Auto Dribble — раскомментируй:
		-- UI.ClearPlaceholder(h)

		local LocalPlayer = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoTackle")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaTackleBox")
			if v then
				v:Destroy()
			end
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil, -- не ставь цифры, на них у Auto Dribble висят скиллы

			-- куб-хитбокс вокруг призрака
			BoxX = 5.75,
			BoxY = 7.15,
			BoxZ = 7.15,
			BoxOffX = 0,
			BoxOffY = 0,
			BoxOffZ = 0,
			FeetOffset = 2.9,
			ShowBox = false,

			-- упреждение (сек = пинг * множитель + запас)
			PingMult = 1.5, -- ЛКМ НЕ зажата: бьём заранее
			HoldPingMult = 0.5, -- ЛКМ зажата: небольшое упреждение (0 = только когда мяч уже в кубе)
			ExtraLead = 0,
			MaxLead = 0.6,

			-- предсказание мяча
			PredictStep = 0.01,
			UseGravity = false,
			MinTrustSpeed = 0.5,

			-- вращение призрака
			UseRotation = true,
			RotMult = 1,
			MaxYawRate = 25,

			-- клик / условия
			ClickCooldown = 0.3,
			RequireEnemyPossession = true,
			IgnoreIFrames = true, -- не кликать, если у мяча есть IFrames

			-- визуал / звук
			HighlightSelf = true,
			HighlightEnemy = true,
			Sound = true,

			-- GUI
			GuiShown = false,
		}

		------------------------------------------------------------
		-- СОСТОЯНИЕ
		------------------------------------------------------------
		local LG, lgRef
		local canClick = true
		local userHolding = false -- реальное зажатие ЛКМ пользователем
		local synthetic = false -- true, пока идёт наш виртуальный клик
		local lastChar

		local SelfHighlight = Instance.new("Highlight")
		SelfHighlight.FillColor = Color3.fromRGB(255, 0, 255)
		SelfHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		SelfHighlight.FillTransparency = 1
		SelfHighlight.Enabled = false

		local AlertSound = Instance.new("Sound")
		AlertSound.SoundId = "rbxassetid://9118823101"
		AlertSound.Volume = 1

		local EnemyHighlights = {}

		local function getLG()
			if LG and LG.Parent then
				return LG
			end
			local m = workspace:FindFirstChild("lagghost")
			LG = m and m:FindFirstChild("HumanoidRootPart") or nil
			return LG
		end

		local function clearEnemyHighlights()
			for p, hl in pairs(EnemyHighlights) do
				hl:Destroy()
				EnemyHighlights[p] = nil
			end
		end

		------------------------------------------------------------
		-- ПИНГ
		------------------------------------------------------------
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local ping = readPing() or 0.05
		local function updatePing(dt)
			local p = readPing()
			if p then
				ping = ping + (math.clamp(p, 0, 1) - ping) * math.clamp(dt * 5, 0, 1)
			end
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ
		------------------------------------------------------------
		local TGui = create("ScreenGui", {
			Name = "YokattaAutoTackle",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 996,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		TGui.Parent = parent

		local widgetPos = { x = 86, y = 92 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(280, 60),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = TGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "M1 Tackle: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local InfoLabel = create("TextLabel", {
			Position = UDim2.fromOffset(12, 34),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "—",
		})
		InfoLabel.Parent = Widget

		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			idle = Color3.fromRGB(90, 160, 255),
			warn = Color3.fromRGB(255, 170, 0),
		}

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local lastInfo = ""
		local function setInfo(text)
			if text == lastInfo then
				return
			end
			lastInfo = text
			InfoLabel.Text = text
		end

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local xSlider, ySlider
		local function setWidgetPos(x, y)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- ВИЗУАЛ: куб
		------------------------------------------------------------
		local Box = Instance.new("Part")
		Box.Name = "YokattaTackleBox"
		Box.Size = Vector3.new(S.BoxX, S.BoxY, S.BoxZ)
		Box.Anchored = true
		Box.CanCollide = false
		Box.CanQuery = false
		Box.CanTouch = false
		Box.CastShadow = false
		Box.Material = Enum.Material.Neon
		Box.Color = Color3.fromRGB(0, 170, 255)
		Box.Transparency = 1
		Box.Parent = workspace

		local BLUE = Color3.fromRGB(0, 170, 255)
		local MAGENTA = Color3.fromRGB(255, 0, 255)

		local function restyle()
			Box.Size = Vector3.new(S.BoxX, S.BoxY, S.BoxZ)
			Box.Transparency = (S.Enabled and S.ShowBox) and 0.6 or 1
		end

		------------------------------------------------------------
		-- КЭШ МЯЧЕЙ
		------------------------------------------------------------
		local balls = {}
		local ballTrackers = setmetatable({}, { __mode = "k" })

		local function isBall(obj)
			if not obj:IsA("BasePart") then
				return false
			end
			return obj.Name == "Football" or obj.Name == "/e ball" or obj:FindFirstAncestor("/e ball") ~= nil
		end
		for _, obj in ipairs(workspace:GetDescendants()) do
			if isBall(obj) then
				balls[obj] = true
			end
		end
		workspace.DescendantAdded:Connect(function(obj)
			task.defer(function()
				if obj.Parent and isBall(obj) then
					balls[obj] = true
				end
			end)
		end)
		workspace.DescendantRemoving:Connect(function(obj)
			balls[obj] = nil
		end)

		------------------------------------------------------------
		-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
		------------------------------------------------------------
		local function isEnemy(player)
			local my = LocalPlayer:FindFirstChild("MatchTeam")
			local his = player:FindFirstChild("MatchTeam")
			if not my or not his then
				return true
			end
			return my.Value ~= his.Value
		end

		local function hasBall(char)
			local folder = char:FindFirstChild("InstanceValue")
			return folder ~= nil and folder:FindFirstChild("Possession") ~= nil
		end

		local function ballHasIFrames(b)
			if not b then
				return false
			end
			local root = (b.Name == "/e ball" and b) or b:FindFirstAncestor("/e ball") or b
			local folder = root:FindFirstChild("InstanceValue")
			return folder ~= nil and folder:FindFirstChild("IFrames") ~= nil
		end

		-- реальное зажатие ЛКМ пользователем (виртуальные клики игнорируем)
		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not synthetic then
				userHolding = true
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not synthetic then
				userHolding = false
			end
		end)

		local function click()
			if not VIM then
				return
			end
			synthetic = true
			local pos = UIS:GetMouseLocation()
			VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
			task.wait()
			VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
			task.delay(0.05, function()
				synthetic = false
			end)
		end

		------------------------------------------------------------
		-- ПРЕДСКАЗАНИЕ
		------------------------------------------------------------
		local lgLastPos = Vector3.zero
		local lgVel = Vector3.zero
		local lgLastYaw = 0
		local lgYawVel = 0

		local function ballVelocity(b, now)
			local tr = ballTrackers[b]
			local pos = b.Position
			if not tr then
				tr = { pos = pos, t = now, vel = Vector3.zero }
				ballTrackers[b] = tr
			elseif now > tr.t then
				local instant = (pos - tr.pos) / (now - tr.t)
				if instant.Magnitude > 1500 then
					tr.vel = Vector3.zero
				else
					tr.vel = tr.vel:Lerp(instant, 0.6)
				end
				tr.pos = pos
				tr.t = now
			end

			local v = b.AssemblyLinearVelocity
			if v.Magnitude < S.MinTrustSpeed and tr.vel.Magnitude > 1 then
				v = tr.vel
			end
			return v
		end

		-- окажется ли мяч в кубе в течение lead секунд (lead = 0 -> только сейчас)
		local function predictBallInBox(lead, now)
			local size = Vector3.new(S.BoxX, S.BoxY, S.BoxZ)
			local half = size / 2
			local lgCF = LG.CFrame
			local lgRot = lgCF.Rotation
			local boxOffset = CFrame.new(S.BoxOffX, -S.FeetOffset + size.Y / 2 + S.BoxOffY, S.BoxOffZ)
			local yawRate = S.UseRotation and (lgYawVel * S.RotMult) or 0
			local accel = S.UseGravity and Vector3.new(0, -workspace.Gravity, 0) or Vector3.zero
			local stepT = math.max(0.002, S.PredictStep)

			for b in pairs(balls) do
				if b.Parent then
					local bPos = b.Position
					local bVel = ballVelocity(b, now)
					local margin = math.max(b.Size.X, b.Size.Y, b.Size.Z) / 2

					local t = 0
					while true do
						local ballPos = bPos + bVel * t + accel * (0.5 * t * t)
						local lgAt = CFrame.new(lgCF.Position + lgVel * t) * CFrame.Angles(0, yawRate * t, 0) * lgRot
						local rel = (lgAt * boxOffset):PointToObjectSpace(ballPos)
						if
							math.abs(rel.X) <= half.X + margin
							and math.abs(rel.Y) <= half.Y + margin
							and math.abs(rel.Z) <= half.Z + margin
						then
							return true, b
						end
						if t >= lead then
							break
						end
						t = math.min(t + stepT, lead)
					end
				else
					balls[b] = nil
				end
			end
			return false, nil
		end

		------------------------------------------------------------
		-- ОСНОВНОЙ ШАГ
		------------------------------------------------------------
		local lastStep = os.clock()

		local function cleanupIdle()
			SelfHighlight.Enabled = false
			clearEnemyHighlights()
			Box.Color = BLUE
			Box.Transparency = 1
			setInfo("—")
		end

		local function step()
			local now = os.clock()
			local dt = now - lastStep
			if dt < 0.004 then
				return
			end
			lastStep = now

			updatePing(dt)

			if not getLG() then
				if S.Enabled then
					setStatus("idle", "Нет призрака (lagghost)")
				end
				return
			end

			-- скорость призрака по смещению между кадрами
			if LG ~= lgRef then
				lgRef = LG
				lgLastPos = LG.Position
				lgVel = Vector3.zero
				local _, y0 = LG.CFrame:ToOrientation()
				lgLastYaw = y0
				lgYawVel = 0
			end
			local lgPos = LG.Position
			lgVel = lgVel:Lerp((lgPos - lgLastPos) / dt, 0.5)
			lgLastPos = lgPos

			local _, yaw = LG.CFrame:ToOrientation()
			local dyaw = (yaw - lgLastYaw + math.pi) % (2 * math.pi) - math.pi
			lgLastYaw = yaw
			local rate = dyaw / dt
			if math.abs(rate) > S.MaxYawRate then
				rate = 0
			end
			lgYawVel = lgYawVel + (rate - lgYawVel) * 0.5

			if not S.Enabled then
				return
			end

			-- привязка подсветки/звука к текущему персонажу
			local char = LocalPlayer.Character
			if char and char ~= lastChar then
				lastChar = char
				SelfHighlight.Parent = char
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					AlertSound.Parent = hrp
				end
			end

			Box.Size = Vector3.new(S.BoxX, S.BoxY, S.BoxZ)
			Box.CFrame = LG.CFrame
				* CFrame.new(S.BoxOffX, -S.FeetOffset + S.BoxY / 2 + S.BoxOffY, S.BoxOffZ)
			Box.Transparency = S.ShowBox and 0.6 or 1

			-- упреждение: ЛКМ не зажата -> полный, зажата -> уменьшенный
			local mult = userHolding and S.HoldPingMult or S.PingMult
			local lead = math.clamp(ping * mult + S.ExtraLead, 0, S.MaxLead)

			local ballComing, hitBall = predictBallInBox(lead, now)

			local holders = {}
			if ballComing then
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and isEnemy(p) and hasBall(p.Character) then
						holders[p] = true
					end
				end
			end

			local danger = ballComing and (not S.RequireEnemyPossession or next(holders) ~= nil)

			for p in pairs(holders) do
				if danger and S.HighlightEnemy and not EnemyHighlights[p] then
					local hl = Instance.new("Highlight")
					hl.FillColor = MAGENTA
					hl.OutlineColor = Color3.new(1, 1, 1)
					hl.FillTransparency = 0.3
					hl.Parent = p.Character
					EnemyHighlights[p] = hl
				end
			end
			for p, hl in pairs(EnemyHighlights) do
				if not (danger and S.HighlightEnemy and holders[p]) then
					hl:Destroy()
					EnemyHighlights[p] = nil
				end
			end

			SelfHighlight.Enabled = danger and S.HighlightSelf
			Box.Color = danger and MAGENTA or BLUE

			local modeText = userHolding and "ОБЫЧНЫЙ" or "ЗАРАНЕЕ"
			setInfo(string.format("%s | упр. %d мс | пинг %d мс", modeText, math.floor(lead * 1000), math.floor(ping * 1000)))

			if danger then
				setStatus("danger", "МЯЧ В ЗОНЕ!")
				if S.Sound and not AlertSound.IsPlaying then
					AlertSound:Play()
				end
				if canClick and not (S.IgnoreIFrames and ballHasIFrames(hitBall)) then
					canClick = false
					task.spawn(click)
					task.delay(S.ClickCooldown, function()
						canClick = true
					end)
				end
			elseif not VIM then
				setStatus("warn", "Нет VirtualInputManager")
			else
				setStatus("on", "M1 Tackle: ВКЛ")
			end
		end

		-- два хука: реакция в начале кадра и после физики (защита от пропуска кадра)
		RunService.PreRender:Connect(step)
		RunService.Heartbeat:Connect(step)

		Players.PlayerRemoving:Connect(function(p)
			if EnemyHighlights[p] then
				EnemyHighlights[p]:Destroy()
				EnemyHighlights[p] = nil
			end
		end)

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "M1 Tackle: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				setStatus("on", "M1 Tackle: ВКЛ")
				restyle()
			else
				cleanupIdle()
				refreshOffText()
			end
		end
		refreshOffText()

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function foldout(title)
			local btn, g
			btn = UI.Button(h, "▸ " .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = false
			return g
		end

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO M1 TACKLE")
		local mainToggle = UI.Toggle(h, "Auto M1 Tackle", false, setEnabled)

		-- бинд (клик -> нажми клавишу; Esc/Backspace — очистить)
		local listening = nil
		local bindBtn
		do
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = "Бинд вкл/выкл",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			bindBtn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			bindBtn.Parent = row
		end

		local function renderBind()
			bindBtn.Text = S.Key and S.Key.Name or "—"
			refreshOffText()
		end
		renderBind()
        		Persist.addId("bind/AutoM1Tackle/Key", "bind", function() return S.Key end,
			function(k) S.Key = k; renderBind() end)

		bindBtn.MouseButton1Click:Connect(function()
			listening = true
			bindBtn.Text = "Нажми клавишу…"
		end)

		UI.Note(
			h,
			"Бьёт M1 (подкат), когда мяч врага с Possession окажется в кубе вокруг призрака LagGhost (workspace.lagghost) — с упреждением по пингу. Если ты сам зажал ЛКМ, используется уменьшенное упреждение (режим «ОБЫЧНЫЙ»). Бинд: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить)."
		)

		------------------------------------------------------------
		-- UI: ХИТБОКС (КУБ)
		------------------------------------------------------------
		local gBox = foldout("Хитбокс (куб)")
		slider(gBox, "Размер X", 0.5, 40, "BoxX", 2, restyle)
		slider(gBox, "Размер Y", 0.5, 40, "BoxY", 2, restyle)
		slider(gBox, "Размер Z", 0.5, 40, "BoxZ", 2, restyle)
		slider(gBox, "Смещение X", -20, 20, "BoxOffX", 2)
		slider(gBox, "Смещение Y", -20, 20, "BoxOffY", 2)
		slider(gBox, "Смещение Z (вперёд/назад)", -20, 20, "BoxOffZ", 2)
		slider(gBox, "Высота ног (от центра призрака)", 0, 8, "FeetOffset", 2)
		toggle(gBox, "Показывать куб", "ShowBox", restyle)

		------------------------------------------------------------
		-- UI: УПРЕЖДЕНИЕ
		------------------------------------------------------------
		local gLead = foldout("Упреждение (пинг)")
		UI.Section(gLead, "ЛКМ НЕ ЗАЖАТА (ЗАРАНЕЕ)")
		slider(gLead, "Множитель пинга", 0, 10, "PingMult", 2)
		UI.Section(gLead, "ЛКМ ЗАЖАТА (ОБЫЧНЫЙ)")
		slider(gLead, "Множитель пинга", 0, 10, "HoldPingMult", 2)
		UI.Section(gLead, "ОБЩЕЕ")
		slider(gLead, "Доп. запас (сек)", -0.3, 1, "ExtraLead", 3)
		slider(gLead, "Макс. упреждение (сек)", 0.05, 2, "MaxLead", 2)

		------------------------------------------------------------
		-- UI: ПРЕДСКАЗАНИЕ МЯЧА И ВРАЩЕНИЕ
		------------------------------------------------------------
		local gPred = foldout("Предсказание мяча и вращение")
		slider(gPred, "Шаг проверки (сек)", 0.002, 0.1, "PredictStep", 3)
		toggle(gPred, "Учитывать гравитацию мяча", "UseGravity")
		slider(gPred, "Порог доверия скорости мяча", 0, 10, "MinTrustSpeed", 2)
		toggle(gPred, "Учитывать вращение призрака", "UseRotation")
		slider(gPred, "Множитель вращения", 0, 2, "RotMult", 2)
		slider(gPred, "Макс. скорость вращения (рад/с)", 1, 60, "MaxYawRate", 1)

		------------------------------------------------------------
		-- UI: КЛИК И УСЛОВИЯ
		------------------------------------------------------------
		local gClick = foldout("Клик и условия")
		slider(gClick, "Кулдаун клика (сек)", 0.05, 2, "ClickCooldown", 2)
		toggle(gClick, "Только если у врага мяч (Possession)", "RequireEnemyPossession")
		toggle(gClick, "Не бить, если у мяча IFrames", "IgnoreIFrames")

		------------------------------------------------------------
		-- UI: ВИЗУАЛ И ЗВУК
		------------------------------------------------------------
		local gVis = foldout("Визуал и звук")
		toggle(gVis, "Подсветка меня при угрозе", "HighlightSelf")
		toggle(gVis, "Подсветка врага с мячом", "HighlightEnemy")
		toggle(gVis, "Звук при угрозе", "Sound")

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		local gGui = foldout("GUI M1 Tackle")
		UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
			S.GuiShown = v
			Widget.Visible = v
		end)
		UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(gGui, "Сбросить позицию GUI", function()
			setWidgetPos(86, 92)
			xSlider.Set(86, true)
			ySlider.Set(92, true)
		end)
		UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = nil
					local key = input.KeyCode
					local dribbleKey = shared.AutoDribble and shared.AutoDribble.Settings and shared.AutoDribble.Settings.Key
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						S.Key = nil
					elseif key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
						-- клавиша занята панелью — оставляем прежний бинд
					elseif dribbleKey and key == dribbleKey then
						-- клавиша занята Auto Dribble — оставляем прежний бинд
					else
						S.Key = key
					end
					renderBind()
				end
				return
			end

			if gp or not S.Key then
				return
			end
			if input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			end
		end)

		-- отдаём наружу
		shared.AutoTackle = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoTackle)
	if not ok then
		warn("[Yokatta] AutoTackle: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO SLIDE TACKLE
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto M1 Tackle
-- (и тоже ПЕРЕД разделом «СТАРТ»). Отдельный скрипт больше не нужен.
-- Целится в мяч (/e ball), а не в оппонента.
------------------------------------------------------------
do
	local function initAutoSlide()
		local h = Holders.AutoUse
		if not h then
			return
		end
		-- UI.ClearPlaceholder(h) уже вызван блоком Auto Dribble.
		-- Если используешь этот блок БЕЗ Auto Dribble — раскомментируй:
		-- UI.ClearPlaceholder(h)

		local player = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoSlide")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaSlideVis")
			if v then
				v:Destroy()
			end
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil, -- бинд вкл/выкл скрипта
			TackleKey = Enum.KeyCode.F, -- клавиша такла в игре

			-- режим и талант (переключаются ТОЛЬКО в панели)
			Mode = 1, -- 1: мяч у оппонента | 2: у оппонента или на земле
			Glide = false,

			-- слайд
			SlideSpeed = 31.5, -- студ/сек
			GlideSpeed = 38, -- студ/сек с Glide
			SlideTime = 1.0, -- сек
			HitboxSize = 6, -- сторона куба хитбокса
			SlideStartLag = 0, -- через сколько сек после нажатия персонаж реально скользит
			GroundOffset = 3, -- от центра персонажа до земли

			-- точность прицела
			Safety = 1, -- запас: мяч должен быть уверенно внутри хитбокса
			Uncertainty = 0.15, -- доля пути мяча, на которую сжимаем запас
			AbortSlack = 1, -- перед самым нажатием проверка мягче на столько студ
			TrackWindow = 0.3, -- история позиций мяча (сек)
			TrackMinSpan = 0.06, -- мин. интервал для измерения скорости мяча

			-- пинг и задержки
			PingSmooth = 1, -- 1 = без сглаживания, меньше = плавнее
			PingMin = 0,
			PingMax = 1,
			PingMult = 1,
			PingExtra = 0,
			InputFrame = 0.017,
			MaxPingRTT = 0.4, -- если пинг туда-обратно больше, не кастуем
			PreAimTime = 0.05, -- сколько сек доворачиваемся перед нажатием
			KeyHold = 0.05, -- удержание клавиши такла
			HoldExtra = 0.15, -- сколько ещё держим управление после слайда
			HoldDuringSlide = true, -- пока слайд идёт, подруливаем взглядом к мячу
			AbortCooldown = 0.1, -- пауза после отменённого каста
			FireDelay = 0.6, -- не чаще чем раз в N сек

			-- условия
			RespectIFrames = true,

			-- визуал
			ShowAim = false, -- точка встречи
			ShowHitbox = false, -- куб хитбокса на тебе во время каста

			-- GUI
			GuiShown = false,
		}

		-- если у СВОЕГО персонажа в InstanceValue есть любое из этих значений, такл не жмём
		local BLOCKING = {
			{ name = "ChargingKick", enabled = true },
			{ name = "Kick", enabled = true },
			{ name = "SlideTackle", enabled = true },
			{ name = "SlideTackleCooldown", enabled = true },
		}

		local MODES = {
			"1: мяч у оппонента",
			"2: у оппонента или на земле",
		}

		------------------------------------------------------------
		-- СОСТОЯНИЕ
		------------------------------------------------------------
		local busy = false
		local lastCast = 0
		local casts = 0
		local injecting = {}

		local function slideSpeed()
			return S.Glide and S.GlideSpeed or S.SlideSpeed
		end

		------------------------------------------------------------
		-- ПИНГ
		------------------------------------------------------------
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local pingEma = readPing() or player:GetNetworkPing()

		local function oneWay()
			return math.max(0, pingEma * S.PingMult + S.PingExtra)
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ
		------------------------------------------------------------
		local SGui = create("ScreenGui", {
			Name = "YokattaAutoSlide",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 995,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		SGui.Parent = parent

		local widgetPos = { x = 86, y = 80 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(300, 82),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = SGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "Slide Tackle: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local Info1 = create("TextLabel", {
			Position = UDim2.fromOffset(12, 34),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "—",
		})
		Info1.Parent = Widget

		local Info2 = create("TextLabel", {
			Position = UDim2.fromOffset(12, 54),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "—",
		})
		Info2.Parent = Widget

		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			idle = Color3.fromRGB(90, 160, 255),
			blocked = Color3.fromRGB(255, 170, 0),
			warn = Color3.fromRGB(255, 170, 0),
		}

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local lastI1, lastI2 = "", ""
		local function refreshInfo()
			local t1 = string.format(
				"Режим %s | Glide: %s (%s ст/с)",
				tostring(S.Mode),
				S.Glide and "ВКЛ" or "ВЫКЛ",
				tostring(math.floor(slideSpeed() * 10 + 0.5) / 10)
			)
			local t2 = string.format("пинг %d мс | касты: %d", math.floor(oneWay() * 1000 + 0.5), casts)
			if t1 ~= lastI1 then
				lastI1 = t1
				Info1.Text = t1
			end
			if t2 ~= lastI2 then
				lastI2 = t2
				Info2.Text = t2
			end
		end
		refreshInfo()

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local xSlider, ySlider
		local function setWidgetPos(x, y)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- ВИЗУАЛ: точка встречи и куб хитбокса
		------------------------------------------------------------
		local visFolder = Instance.new("Folder")
		visFolder.Name = "YokattaSlideVis"
		visFolder.Parent = workspace

		local function visPart(shape, size, color)
			local p = Instance.new("Part")
			p.Shape = shape
			p.Size = size
			p.Transparency = 1
			p.Material = Enum.Material.Neon
			p.Color = color
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Parent = visFolder
			return p
		end

		local AimPart = visPart(Enum.PartType.Ball, Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 255, 0))
		local HitPart = visPart(Enum.PartType.Block, Vector3.new(6, 6, 6), Color3.fromRGB(0, 170, 255))

		local function showAim(pos)
			if S.ShowAim and pos then
				AimPart.Position = pos
				AimPart.Transparency = 0.35
			else
				AimPart.Transparency = 1
			end
		end

		local function showHitbox(cf)
			if S.ShowHitbox and cf then
				local s = S.HitboxSize
				HitPart.Size = Vector3.new(s, s, s)
				HitPart.CFrame = cf
				HitPart.Transparency = 0.6
			else
				HitPart.Transparency = 1
			end
		end

		local function hideVisuals()
			AimPart.Transparency = 1
			HitPart.Transparency = 1
		end

		------------------------------------------------------------
		-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
		------------------------------------------------------------
		local function flat(v)
			return Vector3.new(v.X, 0, v.Z)
		end

		local function getRoot(char)
			return char and char:FindFirstChild("HumanoidRootPart")
		end

		local function getIV(char)
			return char and char:FindFirstChild("InstanceValue")
		end

		local function hasBlocking(iv)
			if not iv then
				return false
			end
			for _, e in ipairs(BLOCKING) do
				if e.enabled and iv:FindFirstChild(e.name) then
					return true
				end
			end
			return false
		end

		local function hasPossession(char)
			local iv = getIV(char)
			return iv ~= nil and iv:FindFirstChild("Possession") ~= nil
		end

		local function isOpponent(plr)
			if plr == player then
				return false
			end
			local mine = player:FindFirstChild("MatchTeam")
			local theirs = plr:FindFirstChild("MatchTeam")
			if not mine or not theirs then
				return false
			end
			return mine.Value ~= theirs.Value
		end

		-- мяч: workspace.Messi["/e ball"] (кэшируем), запасной поиск по workspace
		local ballCache, lastBallSearch = nil, 0
		local function getBall()
			if ballCache and ballCache.Parent then
				return ballCache
			end
			local now = os.clock()
			if now - lastBallSearch < 1 then
				return nil
			end
			lastBallSearch = now
			local messi = workspace:FindFirstChild("Messi")
			local b = messi and messi:FindFirstChild("/e ball")
			if not b then
				b = workspace:FindFirstChild("/e ball", true)
			end
			ballCache = b
			return b
		end

		local function getBallPart()
			local ball = getBall()
			if not ball then
				return nil
			end
			if ball:IsA("BasePart") then
				return ball
			end
			return ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart", true)
		end

		local function ballRadius(part)
			return math.max(part.Size.X, part.Size.Y, part.Size.Z) / 2
		end

		-- скорость мяча по истории позиций
		local samples = {}
		RunService.Heartbeat:Connect(function()
			local p = readPing()
			if p then
				p = math.clamp(p, S.PingMin, S.PingMax)
				pingEma = pingEma + (p - pingEma) * math.clamp(S.PingSmooth, 0.01, 1)
			end

			if not S.Enabled then
				if #samples > 0 then
					table.clear(samples)
				end
				return
			end

			local part = getBallPart()
			if not part then
				table.clear(samples)
				return
			end
			local now = os.clock()
			samples[#samples + 1] = { t = now, p = part.Position }
			while #samples > 1 and now - samples[1].t > S.TrackWindow do
				table.remove(samples, 1)
			end
		end)

		local function ballVelocity(part)
			local newest = samples[#samples]
			if newest then
				for i = #samples - 1, 1, -1 do
					local span = newest.t - samples[i].t
					if span >= S.TrackMinSpan then
						return (newest.p - samples[i].p) / span
					end
				end
			end
			return part.AssemblyLinearVelocity
		end

		local function predictBall(pos, vel, t, floorY)
			local x = pos.X + vel.X * t
			local z = pos.Z + vel.Z * t
			local y = pos.Y
			if math.abs(vel.Y) > 1 then
				y = pos.Y + vel.Y * t - 0.5 * workspace.Gravity * t * t
				y = math.max(y, math.min(pos.Y, floorY))
			end
			return Vector3.new(x, y, z)
		end

		local function solveIntercept(D, V, Sp)
			local a = V:Dot(V) - Sp * Sp
			local b = 2 * D:Dot(V)
			local c = D:Dot(D)
			if math.abs(a) < 1e-6 then
				if math.abs(b) < 1e-6 then
					return nil
				end
				local t = -c / b
				return t > 0 and t or nil
			end
			local disc = b * b - 4 * a * c
			if disc < 0 then
				return nil
			end
			local sq = math.sqrt(disc)
			local t1 = (-b - sq) / (2 * a)
			local t2 = (-b + sq) / (2 * a)
			local best
			for _, t in ipairs({ t1, t2 }) do
				if t > 0 and (not best or t < best) then
					best = t
				end
			end
			return best
		end

		-- можно ли сейчас бить по состоянию мяча и режиму
		local function ballAllowed()
			local ball = getBall()
			local ballIV = ball and ball:FindFirstChild("InstanceValue")
			if S.RespectIFrames and ballIV and ballIV:FindFirstChild("IFrames") then
				return false
			end

			local ballHeld = ballIV ~= nil and ballIV:FindFirstChild("Possession") ~= nil

			local holder
			for _, plr in ipairs(Players:GetPlayers()) do
				local ch = plr.Character
				if ch and hasPossession(ch) then
					holder = plr
					break
				end
			end

			if holder then
				if holder == player or not isOpponent(holder) then
					return false
				end
				if S.RespectIFrames then
					local iv = getIV(holder.Character)
					if iv and iv:FindFirstChild("IFrames") then
						return false
					end
				end
				return true
			end

			if ballHeld then
				return true
			end

			return S.Mode == 2
		end

		------------------------------------------------------------
		-- ПРИЦЕЛ
		------------------------------------------------------------
		local function intercept(A, part, bvel, radius, lead)
			local B = predictBall(part.Position, bvel, lead, A.Y - S.GroundOffset + radius)
			local D = flat(B - A)
			if D.Magnitude < 0.1 then
				return D, 0, B
			end
			local V = flat(bvel)
			local sigma = solveIntercept(D, V, slideSpeed())
			if not sigma then
				return nil
			end
			return D + V * sigma, sigma, B
		end

		-- возвращает направление взгляда и точку встречи (или nil)
		local function plan(root, part, preLead, relax)
			local d = oneWay()
			if d * 2 > S.MaxPingRTT then
				return nil
			end
			local slack = relax and S.AbortSlack or 0
			local HALF = S.HitboxSize / 2

			local L = S.SlideStartLag
			local lead0 = preLead + d * 2 + S.InputFrame

			local myVel = flat(root.AssemblyLinearVelocity)
			local A = root.Position + myVel * (preLead + L)

			local bvel = ballVelocity(part)
			local radius = ballRadius(part)

			local toAim, sigma = intercept(A, part, bvel, radius, lead0 + L)
			if not toAim then
				return nil
			end

			local travel = toAim.Magnitude
			local dir = (travel >= 0.1) and toAim.Unit or flat(root.CFrame.LookVector)
			if dir.Magnitude < 0.1 then
				return nil
			end

			local speed = flat(bvel).Magnitude
			local margin = HALF
				+ radius
				- S.Safety
				+ slack
				- speed * (lead0 + L + math.min(sigma, S.SlideTime)) * S.Uncertainty
			if margin <= 0 then
				return nil
			end

			if travel > slideSpeed() * S.SlideTime + margin then
				return nil
			end

			local floorY = A.Y - S.GroundOffset + radius
			local Bf = predictBall(part.Position, bvel, lead0 + L + sigma, floorY)
			local hv = HALF + radius - S.Safety + slack
			if math.abs(part.Position.Y - A.Y) > hv or math.abs(Bf.Y - A.Y) > hv then
				return nil
			end

			local p = A + toAim
			return dir, Vector3.new(p.X, floorY, p.Z)
		end

		-- подруливание во время слайда
		local function aimNow(root, part, lead)
			local bvel = ballVelocity(part)
			local radius = ballRadius(part)
			local toAim = intercept(root.Position, part, bvel, radius, lead)
			if not toAim or toAim.Magnitude < 0.1 then
				return nil
			end
			local p = root.Position + toAim
			return toAim.Unit, Vector3.new(p.X, root.Position.Y - S.GroundOffset + radius, p.Z)
		end

		------------------------------------------------------------
		-- КАСТ
		------------------------------------------------------------
		local function pressKey(key)
			if not VIM then
				return
			end
			injecting[key] = (injecting[key] or 0) + 1
			VIM:SendKeyEvent(true, key, false, game)
			task.wait(S.KeyHold)
			VIM:SendKeyEvent(false, key, false, game)
			task.delay(0.15, function()
				injecting[key] = (injecting[key] or 1) - 1
				if injecting[key] <= 0 then
					injecting[key] = nil
				end
			end)
		end

		-- 1) PRE_AIM доворачиваемся, каждый кадр перепроверяя условия
		-- 2) нажимаем такл
		-- 3) держим взгляд, пока слайд идёт на сервере
		local function cast(key)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) then
				return
			end

			busy = true
			hum.AutoRotate = false

			local startT = os.clock()
			local pressT = nil
			local currentDir = flat(root.CFrame.LookVector)
			local conn

			local function finish(aborted)
				if conn then
					conn:Disconnect()
				end
				if hum.Parent then
					hum.AutoRotate = true
				end
				if aborted then
					lastCast = os.clock() - S.FireDelay + S.AbortCooldown
				end
				hideVisuals()
				busy = false
			end

			conn = RunService.RenderStepped:Connect(function()
				local now = os.clock()
				if not root.Parent or hum.Health <= 0 or not S.Enabled then
					finish(pressT == nil)
					return
				end

				local part = getBallPart()

				-- после нажатия
				if pressT then
					local since = now - pressT
					local d = oneWay()
					if since > d + S.SlideStartLag + S.SlideTime + S.HoldExtra or hasPossession(char) then
						finish(false)
						return
					end
					if S.HoldDuringSlide and part and since > d then
						local dir, point = aimNow(root, part, d)
						if dir then
							currentDir = dir
							showAim(point)
						end
					end
					showHitbox(root.CFrame)
					root.CFrame = CFrame.lookAt(root.Position, root.Position + currentDir)
					return
				end

				-- до нажатия: перепроверяем всё
				if not part or hasBlocking(getIV(char)) or not ballAllowed() then
					finish(true)
					return
				end

				local elapsed = now - startT
				local dir, point = plan(root, part, math.max(S.PreAimTime - elapsed, 0), true)
				if not dir then
					finish(true)
					return
				end

				currentDir = dir
				showAim(point)
				root.CFrame = CFrame.lookAt(root.Position, root.Position + currentDir)

				if elapsed >= S.PreAimTime then
					pressT = now
					casts += 1
					task.spawn(pressKey, key)
				end
			end)
		end

		------------------------------------------------------------
		-- ОСНОВНОЙ ЦИКЛ
		------------------------------------------------------------
		local infoTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			infoTimer += dt
			if infoTimer >= 0.25 then
				infoTimer = 0
				refreshInfo()
			end

			if not S.Enabled then
				return
			end
			if busy then
				setStatus("danger", "Слайд: каст!")
				return
			end

			if not VIM then
				setStatus("warn", "Нет VirtualInputManager")
				return
			end

			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) or hum.Health <= 0 then
				setStatus("idle", "Нет персонажа")
				return
			end

			if hasBlocking(getIV(char)) then
				setStatus("blocked", "Слайд: заблокирован")
				return
			end

			local now = os.clock()
			if now - lastCast < S.FireDelay then
				return
			end

			if not ballAllowed() then
				setStatus("idle", "Ждёт мяч (режим " .. tostring(S.Mode) .. ")")
				hideVisuals()
				return
			end

			local part = getBallPart()
			if not part then
				setStatus("idle", "Нет мяча")
				hideVisuals()
				return
			end

			local dir, point = plan(root, part, S.PreAimTime, false)
			if dir then
				lastCast = now
				showAim(point)
				task.spawn(cast, S.TackleKey)
			else
				setStatus("on", "Slide Tackle: ВКЛ")
				hideVisuals()
			end
		end)

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "Slide Tackle: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				setStatus("on", "Slide Tackle: ВКЛ")
			else
				hideVisuals()
				refreshOffText()
			end
		end
		refreshOffText()

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function foldout(title)
			local btn, g
			btn = UI.Button(h, "▸ " .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = false
			return g
		end

		-- бинды: клик -> нажми клавишу; Esc/Backspace очищают (только у бинда вкл/выкл)
		local listening = nil -- { field, render, canClear }

		local function isReserved(key, field)
			if key == CONFIG.ToggleKey or key == CONFIG.CursorKey then
				return true
			end
			local d = shared.AutoDribble and shared.AutoDribble.Settings
			if d and d.Key == key then
				return true
			end
			local t = shared.AutoTackle and shared.AutoTackle.Settings
			if t and t.Key == key then
				return true
			end
			local other = (field == "Key") and "TackleKey" or "Key"
			if S[other] == key then
				return true
			end
			return false
		end

		local function bindRow(labelText, field, canClear)
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = labelText,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row

			local function render()
				btn.Text = S[field] and S[field].Name or "—"
			end
			render()
            			Persist.addId("bind/AutoSlide/" .. field, "bind", function() return S[field] end,
				function(k) S[field] = k; render(); refreshOffText() end)

			btn.MouseButton1Click:Connect(function()
				if listening then
					listening.render()
				end
				listening = { field = field, render = render, canClear = canClear }
				btn.Text = "Нажми клавишу…"
			end)
			return render
		end

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO SLIDE TACKLE")
		local mainToggle = UI.Toggle(h, "Auto Slide Tackle", false, setEnabled)

		local renderToggleBind = bindRow("Бинд вкл/выкл", "Key", true)
		bindRow("Клавиша такла в игре", "TackleKey", false)

		-- режим (только из панели)
		local modeBtn
		modeBtn = UI.Button(h, "Режим: " .. MODES[S.Mode], function()
			S.Mode = S.Mode % #MODES + 1
			modeBtn.Text = "Режим: " .. MODES[S.Mode]
			refreshInfo()
		end)
        		Persist.addId("AutoSlide/Mode", "choice", function() return S.Mode end, function(v)
			if MODES[v] then S.Mode = v; modeBtn.Text = "Режим: " .. MODES[v]; refreshInfo() end
		end)

		-- Glide (только из панели)
		UI.Toggle(h, "Glide (талант)", S.Glide, function(v)
			S.Glide = v
			refreshInfo()
		end)

		UI.Note(
			h,
			"Целится в мяч (/e ball) и жмёт такл с упреждением по пингу, скорости мяча и твоему движению. Режим 1 — бьёт только когда мяч у оппонента, режим 2 — ещё и когда мяч свободен на земле. Режим и Glide переключаются только здесь, горячих клавиш на них нет. Бинд: нажми кнопку справа, затем клавишу."
		)

		------------------------------------------------------------
		-- UI: СЛАЙД И ХИТБОКС
		------------------------------------------------------------
		local gSlide = foldout("Слайд и хитбокс")
		slider(gSlide, "Скорость слайда (студ/с)", 5, 100, "SlideSpeed", 1, refreshInfo)
		slider(gSlide, "Скорость слайда с Glide (студ/с)", 5, 150, "GlideSpeed", 1, refreshInfo)
		slider(gSlide, "Длительность слайда (сек)", 0.2, 3, "SlideTime", 2)
		slider(gSlide, "Размер хитбокса (куб)", 1, 30, "HitboxSize", 2)
		slider(gSlide, "Задержка старта слайда (сек)", 0, 0.5, "SlideStartLag", 3)
		slider(gSlide, "Высота центра над землёй", 0, 8, "GroundOffset", 2)

		------------------------------------------------------------
		-- UI: ТОЧНОСТЬ
		------------------------------------------------------------
		local gAim = foldout("Точность прицела")
		slider(gAim, "Запас уверенности (студы)", -3, 6, "Safety", 2)
		slider(gAim, "Сжатие по скорости мяча", 0, 1, "Uncertainty", 3)
		slider(gAim, "Мягкость перед нажатием (студы)", 0, 6, "AbortSlack", 2)
		slider(gAim, "История позиций мяча (сек)", 0.05, 1, "TrackWindow", 2)
		slider(gAim, "Мин. интервал скорости мяча (сек)", 0.01, 0.3, "TrackMinSpan", 3)

		------------------------------------------------------------
		-- UI: ПИНГ И ЗАДЕРЖКИ
		------------------------------------------------------------
		local gPing = foldout("Пинг и задержки")
		slider(gPing, "Множитель пинга", 0, 4, "PingMult", 2)
		slider(gPing, "Поправка к пингу (сек)", -0.2, 0.5, "PingExtra", 3)
		slider(gPing, "Сглаживание пинга (1 = нет)", 0.05, 1, "PingSmooth", 2)
		slider(gPing, "Мин. пинг (сек)", 0, 1, "PingMin", 3)
		slider(gPing, "Макс. пинг (сек)", 0.05, 2, "PingMax", 2)
		slider(gPing, "Задержка кадра (сек)", 0, 0.1, "InputFrame", 3)
		slider(gPing, "Макс. RTT для каста (сек)", 0.05, 1.5, "MaxPingRTT", 2)
		slider(gPing, "Доворот перед нажатием (сек)", 0, 0.3, "PreAimTime", 3)
		slider(gPing, "Удержание клавиши (сек)", 0.01, 0.3, "KeyHold", 3)
		slider(gPing, "Держать управление после слайда (сек)", 0, 0.5, "HoldExtra", 2)
		toggle(gPing, "Подруливать к мячу во время слайда", "HoldDuringSlide")
		slider(gPing, "Пауза после отмены (сек)", 0, 1, "AbortCooldown", 2)
		slider(gPing, "Мин. интервал между кастами (сек)", 0.1, 3, "FireDelay", 2)

		------------------------------------------------------------
		-- UI: УСЛОВИЯ
		------------------------------------------------------------
		local gCond = foldout("Условия и блокировки")
		toggle(gCond, "Не бить, если у мяча/держателя IFrames", "RespectIFrames")
		UI.Section(gCond, "НЕ ЖАТЬ ТАКЛ, ЕСЛИ У МЕНЯ ЕСТЬ")
		for _, e in ipairs(BLOCKING) do
			UI.Toggle(gCond, e.name, e.enabled, function(v)
				e.enabled = v
			end)
		end

		------------------------------------------------------------
		-- UI: ВИЗУАЛ
		------------------------------------------------------------
		local gVis = foldout("Визуал")
		toggle(gVis, "Точка встречи (прицел)", "ShowAim", function()
			if not S.ShowAim then
				AimPart.Transparency = 1
			end
		end)
		toggle(gVis, "Куб хитбокса во время каста", "ShowHitbox", function()
			if not S.ShowHitbox then
				HitPart.Transparency = 1
			end
		end)

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		local gGui = foldout("GUI Slide Tackle")
		UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
			S.GuiShown = v
			Widget.Visible = v
		end)
		UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(gGui, "Сбросить позицию GUI", function()
			setWidgetPos(86, 80)
			xSlider.Set(86, true)
			ySlider.Set(80, true)
		end)
		UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local l = listening
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						if l.canClear then
							S[l.field] = nil
						end
					elseif not isReserved(key, l.field) then
						S[l.field] = key
					end
					l.render()
					refreshOffText()
				end
				return
			end

			if gp or not S.Key then
				return
			end
			-- игнорируем виртуальное нажатие такла самим скриптом
			if injecting[input.KeyCode] then
				return
			end
			if input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			end
		end)

		-- отдаём наружу
		shared.AutoSlide = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoSlide)
	if not ok then
		warn("[Yokatta] AutoSlide: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO SHOT
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto Slide Tackle
-- (и тоже ПЕРЕД разделом «СТАРТ»). Отдельный скрипт больше не нужен.
-- Использует призрака из LagGhost (workspace.lagghost).
------------------------------------------------------------
do
	local function initAutoShot()
		local h = Holders.AutoUse
		if not h then
			return
		end
		-- UI.ClearPlaceholder(h) уже вызван блоком Auto Dribble.
		-- Если используешь этот блок БЕЗ Auto Dribble — раскомментируй:
		-- UI.ClearPlaceholder(h)

		local LocalPlayer = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoShot")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaShotVis")
			if v then
				v:Destroy()
			end
			pcall(function()
				RunService:UnbindFromRenderStep("YokattaShotLoft")
			end)
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil, -- бинд вкл/выкл
			LoftKey = nil, -- бинд Loft вкл/выкл

			-- хитбокс вокруг призрака (обычный)
			BoxX = 19,
			BoxY = 40,
			BoxZ = 18.5,
			ReachY = 40, -- высота досягаемости без прыжка

			-- режим потока (Flow = Galaxy)
			UseFlow = true,
			FlowX = 26,
			FlowY = 46,
			FlowZ = 26,
			FlowReachY = 46,
			FlowHoldTrim = 1, -- уменьшение полувысоты, когда Hold M1

			-- режим Inbox
			UseInbox = true,
			InboxX = 12,
			InboxY = 40,
			InboxZ = 12,
			InboxReachY = 40,
			InboxFlowX = 18.5,
			InboxFlowY = 46,
			InboxFlowZ = 18.5,
			InboxFlowReachY = 46,
			InboxHoldTrim = 1,

			-- предсказание мяча
			Horizon = 0.6,
			Step = 0.01,
			UseGravity = false,
			LeadExtra = 0,
			KickedMode = 1, -- 1: пропускать мяч с Kicked | 2: бить только с Kicked | 3: не проверять

			-- пинг
			UseRealPing = true,
			FallbackPingMs = 120,
			PingSmooth = 0.25,
			PingUpdateEvery = 0.2,
			PingMin = 0.01,
			PingMax = 0.5,
			PingOffset = 0, -- + раньше, - позже
			HitDelayMult = 1,
			EarlyNoHoldMult = 1, -- если Hold не активен, бьём раньше на пинг × это

			-- клик
			ClickCooldown = 0.15,
			RepeatCooldown = 0.5,
			RequireCharging = true, -- Hold M1 только при ChargingKick

			-- прыжок
			AutoJump = true,
			JumpPingMult = 1,
			MinLift = 0.5,
			JumpOverreach = 2.75,
			JumpHorizon = 1.0,
			JumpCooldown = 0.5,
			JumpAfterHitCooldown = 0.25,
			JumpTapTime = 0.05,
			LateTolerance = 0.03,

			-- Loft (взгляд вверх перед ударом)
			Loft = false,
			LoftPitch = 89,
			LoftPre = 0.05,
			LoftHold = 0.15,
			LoftAfterClick = 0.1,

			-- визуал
			ShowHitbox = false,

			-- GUI
			GuiShown = false,
		}

		local BALL_NAME = "Football"
		local TARGET_NAME = "lagghost"
		local VALUES_FOLDER_NAME = "InstanceValue"
		local POSSESSION_NAME = "Possession"
		local KICKED_NAME = "Kicked"
		local CHARGING_NAME = "ChargingKick"
		local FLOW_NAME = "Flow"
		local FLOW_VALUE = "Galaxy"
		local INBOX_NAME = "Inbox"

		local KICKED_MODES = {
			"1: пропускать мяч с Kicked",
			"2: бить только мяч с Kicked",
			"3: не проверять Kicked",
		}

		local NORMAL_COLOR = Color3.fromRGB(0, 170, 255)
		local HIT_COLOR = Color3.fromRGB(255, 0, 0)

		------------------------------------------------------------
		-- СОСТОЯНИЕ
		------------------------------------------------------------
		local jumpActive = false
		local jumpedAt = -10
		local jumpHitAbs = nil
		local groundY = nil
		local lastClick = -10
		local armed = true
		local m1Held = false
		local holdMode = false
		local flowActive, inboxActive = false, false
		local loftUntil = 0

		local hbSize = Vector3.new(S.BoxX, S.BoxY, S.BoxZ)
		local groundReach = S.ReachY

		local pingSec = S.FallbackPingMs / 1000
		local lastPingRead = 0
		local currentEta, currentLift, currentJumpIn = nil, nil, nil
		local shotCount = 0

		------------------------------------------------------------
		-- ПИНГ
		------------------------------------------------------------
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local function updatePing(now)
			if not S.UseRealPing then
				pingSec = S.FallbackPingMs / 1000
				return
			end
			if now - lastPingRead < S.PingUpdateEvery then
				return
			end
			lastPingRead = now
			local p = readPing()
			if p then
				p = math.clamp(p, S.PingMin, S.PingMax)
				pingSec = pingSec + (p - pingSec) * math.clamp(S.PingSmooth, 0.01, 1)
			end
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ
		------------------------------------------------------------
		local PGui = create("ScreenGui", {
			Name = "YokattaAutoShot",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 994,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		PGui.Parent = parent

		local widgetPos = { x = 14, y = 35 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(280, 128),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = PGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "Auto Shot: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local infoLabels, infoCache = {}, {}
		for i = 1, 4 do
			local l = create("TextLabel", {
				Position = UDim2.fromOffset(12, 32 + (i - 1) * 20),
				Size = UDim2.new(1, -24, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.TextMid,
				Text = "—",
			})
			l.Parent = Widget
			infoLabels[i] = l
			infoCache[i] = ""
		end

		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			idle = Color3.fromRGB(90, 160, 255),
			warn = Color3.fromRGB(255, 170, 0),
		}

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local function setInfo(i, text)
			if infoCache[i] == text then
				return
			end
			infoCache[i] = text
			infoLabels[i].Text = text
		end

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local xSlider, ySlider
		local function setWidgetPos(x, y)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		local function refreshInfo()
			if not S.Enabled then
				setInfo(1, "ETA: -  |  Lift: -")
				setInfo(2, "Jump: -  |  M1: -")
				setInfo(3, string.format("Пинг: %d мс", math.floor(pingSec * 1000 + 0.5)))
				setInfo(4, "Loft: " .. (S.Loft and "ВКЛ" or "ВЫКЛ") .. " [" .. (S.LoftKey and S.LoftKey.Name or "—") .. "]")
				return
			end
			local eta = currentEta and string.format("ETA: %.3fс", currentEta) or "ETA: -"
			local lift = currentLift and string.format("Lift: %.1f", currentLift) or "Lift: -"
			local jump
			if jumpActive then
				jump = "Jump: AIR"
			elseif currentJumpIn then
				jump = string.format("Jump in: %.3fс", math.max(currentJumpIn, 0))
			else
				jump = "Jump: -"
			end
			setInfo(1, eta .. "  |  " .. lift)
			setInfo(2, jump .. "  |  M1: " .. (holdMode and "HOLD" or "early"))
			setInfo(
				3,
				string.format("Пинг: %d мс | выстрелы: %d", math.floor(pingSec * 1000 + 0.5), shotCount)
			)
			setInfo(
				4,
				"Loft: "
					.. (S.Loft and "ВКЛ" or "ВЫКЛ")
					.. (flowActive and " | FLOW" or "")
					.. (inboxActive and " | INBOX" or "")
			)
		end

		------------------------------------------------------------
		-- ВИЗУАЛ: куб хитбокса
		------------------------------------------------------------
		local visFolder = Instance.new("Folder")
		visFolder.Name = "YokattaShotVis"
		visFolder.Parent = workspace

		local hitbox = Instance.new("Part")
		hitbox.Name = "Hitbox"
		hitbox.Size = hbSize
		hitbox.Color = NORMAL_COLOR
		hitbox.Material = Enum.Material.Neon
		hitbox.Transparency = 1
		hitbox.Anchored = true
		hitbox.CanCollide = false
		hitbox.CanTouch = false
		hitbox.CanQuery = false
		hitbox.CastShadow = false
		hitbox.Parent = visFolder

		local function restyle()
			hitbox.Transparency = (S.Enabled and S.ShowHitbox) and 0.6 or 1
		end

		------------------------------------------------------------
		-- ВВОД
		------------------------------------------------------------
		local function clickM1()
			if not VIM then
				return
			end
			local pos = UIS:GetMouseLocation()
			VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
			VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
		end

		local function tapJump()
			if not VIM then
				return
			end
			VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.delay(S.JumpTapTime, function()
				VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
			end)
		end

		-- реальное зажатие ЛКМ (свои виртуальные клики игнорируем по времени)
		local VIRTUAL_IGNORE = 0.06
		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if os.clock() - lastClick > VIRTUAL_IGNORE then
					m1Held = true
				end
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if os.clock() - lastClick > VIRTUAL_IGNORE then
					m1Held = false
				end
			end
		end)

		------------------------------------------------------------
		-- LOFT: принудительный взгляд вверх, пока не истёк loftUntil
		------------------------------------------------------------
		RunService:BindToRenderStep("YokattaShotLoft", Enum.RenderPriority.Camera.Value + 1, function()
			if os.clock() >= loftUntil then
				return
			end
			local cam = workspace.CurrentCamera
			if not cam then
				return
			end
			local cf = cam.CFrame
			local look = cf.LookVector
			local yaw = math.atan2(-look.X, -look.Z)
			local pitch = math.rad(math.clamp(S.LoftPitch, 0, 89))
			cam.CFrame = CFrame.new(cf.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
		end)

		------------------------------------------------------------
		-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
		------------------------------------------------------------
		local function getTargetPart(obj)
			if not obj then
				return nil
			end
			if obj:IsA("BasePart") then
				return obj
			end
			if obj:IsA("Model") then
				return obj.PrimaryPart
					or obj:FindFirstChild("HumanoidRootPart")
					or obj:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		local function ballHasMarker(ball, markerName)
			local current = ball
			while current and current ~= workspace do
				local vf = current:FindFirstChild(VALUES_FOLDER_NAME)
				if vf and vf:FindFirstChild(markerName) then
					return true
				end
				if current:FindFirstChild(markerName) then
					return true
				end
				current = current.Parent
			end
			return false
		end

		-- true = мяч пропускаем (не бьём)
		local function ballIsBlocked(ball)
			if ballHasMarker(ball, POSSESSION_NAME) then
				return true
			end
			if S.KickedMode == 1 then
				return ballHasMarker(ball, KICKED_NAME)
			elseif S.KickedMode == 2 then
				return not ballHasMarker(ball, KICKED_NAME)
			end
			return false
		end

		-- кэш мячей
		local balls = {}
		local ballTrackers = setmetatable({}, { __mode = "k" })

		local function isBall(obj)
			return obj:IsA("BasePart") and obj.Name == BALL_NAME
		end
		for _, obj in ipairs(workspace:GetDescendants()) do
			if isBall(obj) then
				balls[obj] = true
			end
		end
		workspace.DescendantAdded:Connect(function(obj)
			task.defer(function()
				if obj.Parent and isBall(obj) then
					balls[obj] = true
				end
			end)
		end)
		workspace.DescendantRemoving:Connect(function(obj)
			balls[obj] = nil
		end)

		local function newTracker()
			return { pos = nil, t = nil, vel = Vector3.zero }
		end

		local function updateTracker(tr, pos, now)
			if tr.pos and now > tr.t then
				local instant = (pos - tr.pos) / (now - tr.t)
				if instant.Magnitude > 1500 then
					tr.vel = Vector3.zero
				else
					tr.vel = tr.vel:Lerp(instant, 0.5)
				end
			end
			tr.pos = pos
			tr.t = now
		end

		local ghostTracker = newTracker()

		-- режимы персонажа
		local function hasInbox()
			local character = LocalPlayer.Character
			local f = character and character:FindFirstChild(VALUES_FOLDER_NAME)
			local inbox = f and f:FindFirstChild(INBOX_NAME)
			if not inbox then
				return false
			end
			local matchTeam = LocalPlayer:FindFirstChild("MatchTeam")
			if not matchTeam then
				return false
			end
			local v
			if inbox:IsA("ValueBase") then
				v = inbox.Value
			else
				v = inbox:GetAttribute("Value")
			end
			return v ~= nil and tostring(v) == tostring(matchTeam.Value)
		end

		local function isGalaxyFlow()
			local character = LocalPlayer.Character
			local f = character and character:FindFirstChild(VALUES_FOLDER_NAME)
			local flow = f and f:FindFirstChild(FLOW_NAME)
			if not flow then
				return false
			end
			if flow:IsA("ValueBase") then
				return tostring(flow.Value) == FLOW_VALUE
			end
			return tostring(flow:GetAttribute("Value")) == FLOW_VALUE
		end

		local function hasChargingKick()
			local character = LocalPlayer.Character
			local f = character and character:FindFirstChild(VALUES_FOLDER_NAME)
			return f ~= nil and f:FindFirstChild(CHARGING_NAME) ~= nil
		end

		-- размер хитбокса и высота по текущему режиму (читаем из S каждый кадр)
		local function applyMode(flow, inbox)
			flowActive, inboxActive = flow, inbox
			if inbox and flow then
				hbSize = Vector3.new(S.InboxFlowX, S.InboxFlowY, S.InboxFlowZ)
				groundReach = S.InboxFlowReachY
			elseif inbox then
				hbSize = Vector3.new(S.InboxX, S.InboxY, S.InboxZ)
				groundReach = S.InboxReachY
			elseif flow then
				hbSize = Vector3.new(S.FlowX, S.FlowY, S.FlowZ)
				groundReach = S.FlowReachY
			else
				hbSize = Vector3.new(S.BoxX, S.BoxY, S.BoxZ)
				groundReach = S.ReachY
			end
			hitbox.Size = hbSize
		end

		------------------------------------------------------------
		-- ПРЕДСКАЗАНИЕ
		------------------------------------------------------------
		local function ballRadius(part)
			return math.max(part.Size.X, part.Size.Y, part.Size.Z) / 2
		end

		local function ballPosAt(part, vel, t)
			local accel = S.UseGravity and Vector3.new(0, -workspace.Gravity, 0) or Vector3.zero
			return part.Position + vel * t + accel * (0.5 * t * t)
		end

		local function predictTimeToHit(part, vel, ghostVel)
			local cf = hitbox.CFrame
			local rotation = cf.Rotation
			local ghostPos = cf.Position
			local r = ballRadius(part)
			local half = hbSize / 2 + Vector3.new(r, r, r)
			if holdMode and (flowActive or inboxActive) then
				local trim = inboxActive and S.InboxHoldTrim or S.FlowHoldTrim
				half = Vector3.new(half.X, half.Y - trim, half.Z)
			end

			local t = 0
			while t <= S.Horizon do
				local bp = ballPosAt(part, vel, t)
				local rel = rotation:PointToObjectSpace(bp - (ghostPos + ghostVel * t))
				if math.abs(rel.X) <= half.X and math.abs(rel.Y) <= half.Y and math.abs(rel.Z) <= half.Z then
					return t
				end
				t += math.max(0.002, S.Step)
			end
			return nil
		end

		-- модель прыжка по оси Y
		local function jumpParams(humanoid)
			local g = workspace.Gravity
			local v0
			if humanoid.UseJumpPower then
				v0 = humanoid.JumpPower
			else
				v0 = math.sqrt(2 * g * humanoid.JumpHeight)
			end
			return v0 * v0 / (2 * g), v0 / g
		end

		local function timeToReach(hh, apex, T)
			local x = math.clamp(hh / apex, 0, 1)
			return T * (1 - math.sqrt(1 - x))
		end

		local function jumpHeightAt(dt, apex, T)
			if dt <= 0 or dt >= 2 * T then
				return 0
			end
			local k = 1 - dt / T
			return apex * (1 - k * k)
		end

		local function planJump(part, vel, ghostVel, humanoid, jumpLead)
			local apex, T = jumpParams(humanoid)
			local cf = hitbox.CFrame
			local rotation = cf.Rotation
			local ghostPos = cf.Position
			local r = ballRadius(part)
			local halfX = hbSize.X / 2 + r
			local halfZ = hbSize.Z / 2 + r
			local stepT = math.max(0.002, S.Step)

			local t = 0
			while t <= S.JumpHorizon do
				local bp = ballPosAt(part, vel, t)
				local rel = rotation:PointToObjectSpace(bp - (ghostPos + ghostVel * t))

				if math.abs(rel.X) <= halfX and math.abs(rel.Z) <= halfZ then
					local lift = bp.Y - (groundY + groundReach)
					if lift <= S.MinLift then
						return nil
					end
					if lift <= apex + S.JumpOverreach then
						local tau = timeToReach(math.min(lift, apex), apex, T)
						local jumpIn = t - tau - (jumpLead + S.PingOffset)
						if jumpIn >= -S.LateTolerance then
							return { hitIn = t, jumpIn = jumpIn, lift = lift }
						end
					end
				end
				t += stepT
			end
			return nil
		end

		local function replanHitInAir(part, vel, ghostVel, humanoid, now, jumpLead)
			local apex, T = jumpParams(humanoid)
			local cf = hitbox.CFrame
			local rotation = cf.Rotation
			local ghostPos = cf.Position
			local r = ballRadius(part)
			local halfX = hbSize.X / 2 + r
			local halfZ = hbSize.Z / 2 + r
			local startOffset = jumpLead + S.PingOffset
			local stepT = math.max(0.002, S.Step)

			local t = 0
			while t <= S.JumpHorizon do
				local bp = ballPosAt(part, vel, t)
				local rel = rotation:PointToObjectSpace(bp - (ghostPos + ghostVel * t))

				if math.abs(rel.X) <= halfX and math.abs(rel.Z) <= halfZ then
					local dt = now + t - jumpedAt - startOffset
					local reachY = groundY + groundReach + jumpHeightAt(dt, apex, T)
					if bp.Y <= reachY + S.JumpOverreach then
						return t
					end
				end
				t += stepT
			end
			return nil
		end

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local function resetState()
			hitbox.Transparency = 1
			hitbox.Color = NORMAL_COLOR
			currentEta, currentLift, currentJumpIn = nil, nil, nil
			jumpActive = false
			jumpHitAbs = nil
			loftUntil = 0
			armed = true
		end

		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "Auto Shot: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				setStatus("on", "Auto Shot: ВКЛ")
				restyle()
			else
				resetState()
				refreshOffText()
			end
			refreshInfo()
		end

		------------------------------------------------------------
		-- ОСНОВНОЙ ЦИКЛ
		------------------------------------------------------------
		local infoTimer = 0
		RunService.RenderStepped:Connect(function(dt)
			infoTimer += dt
			if infoTimer >= 0.1 then
				infoTimer = 0
				refreshInfo()
			end

			local now = os.clock()
			updatePing(now)

			if not S.Enabled then
				return
			end

			-- режимы: Flow = Galaxy, Inbox
			local galaxy = S.UseFlow and isGalaxyFlow() or false
			local inbox = S.UseInbox and hasInbox() or false
			applyMode(galaxy, inbox)
			hitbox.Transparency = S.ShowHitbox and 0.6 or 1

			-- Hold M1: M1 зажат (+ ChargingKick, если включено требование)
			holdMode = m1Held and (not S.RequireCharging or hasChargingKick())

			local jumpLead = pingSec * S.JumpPingMult
			currentEta, currentLift, currentJumpIn = nil, nil, nil

			local targetPart = getTargetPart(workspace:FindFirstChild(TARGET_NAME))
			if not targetPart then
				setStatus("idle", "Нет призрака (lagghost)")
				return
			end

			hitbox.CFrame = targetPart.CFrame
			updateTracker(ghostTracker, targetPart.Position, now)

			-- данные по всем мячам
			local list = {}
			for b in pairs(balls) do
				if b.Parent then
					local tr = ballTrackers[b]
					if not tr then
						tr = newTracker()
						ballTrackers[b] = tr
					end
					updateTracker(tr, b.Position, now)

					local v = b.AssemblyLinearVelocity
					if v.Magnitude < 0.5 and tr.vel.Magnitude > 1 then
						v = tr.vel
					end
					table.insert(list, { part = b, vel = v, possessed = ballIsBlocked(b) })
				else
					balls[b] = nil
				end
			end

			if #list == 0 then
				hitbox.Color = NORMAL_COLOR
				setStatus("idle", "Нет мяча")
				return
			end

			-- ближайший по времени удар среди свободных мячей
			local eta = nil
			for _, d in ipairs(list) do
				if not d.possessed then
					local e = predictTimeToHit(d.part, d.vel, ghostTracker.vel)
					if e and (not eta or e < eta) then
						eta = e
					end
				end
			end
			currentEta = eta

			-- момент клика
			local hitDelay = pingSec * S.HitDelayMult
			local early = holdMode and 0 or (pingSec * S.EarlyNoHoldMult)
			local leadTime = (pingSec + S.PingOffset) + hitDelay + S.LeadExtra + early

			-- прыжок
			local hitIn = nil
			local character = LocalPlayer.Character
			local myRoot = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if myRoot and humanoid then
				local grounded = humanoid.FloorMaterial ~= Enum.Material.Air

				if grounded and not jumpActive then
					groundY = myRoot.Position.Y
				end

				if jumpActive and ((now - jumpedAt > 0.15 and grounded) or now - jumpedAt > 2) then
					jumpActive = false
					jumpHitAbs = nil
				end

				if jumpActive then
					local bestT = nil
					if groundY then
						for _, d in ipairs(list) do
							if not d.possessed then
								local t = replanHitInAir(d.part, d.vel, ghostTracker.vel, humanoid, now, jumpLead)
								if t and (not bestT or t < bestT) then
									bestT = t
								end
							end
						end
					end
					if bestT then
						jumpHitAbs = now + bestT
					end
					if jumpHitAbs then
						hitIn = jumpHitAbs - now
					end
					currentJumpIn = 0
				else
					local cooldownOk = grounded
						and now - jumpedAt >= S.JumpCooldown
						and now - lastClick >= S.JumpAfterHitCooldown

					if S.AutoJump and groundY and cooldownOk then
						local bestPlan = nil
						for _, d in ipairs(list) do
							if not d.possessed then
								local plan = planJump(d.part, d.vel, ghostTracker.vel, humanoid, jumpLead)
								if plan and (not bestPlan or plan.hitIn < bestPlan.hitIn) then
									bestPlan = plan
								end
							end
						end

						if bestPlan then
							currentLift = bestPlan.lift
							currentJumpIn = bestPlan.jumpIn
							hitIn = bestPlan.hitIn

							if bestPlan.jumpIn <= 0 or bestPlan.hitIn <= leadTime then
								jumpActive = true
								jumpedAt = now
								jumpHitAbs = now + bestPlan.hitIn
								tapJump()
							end
						end
					end
				end
			end

			-- удар (M1)
			local effIn = hitIn or eta
			local shouldClick = effIn ~= nil and effIn <= leadTime and effIn >= -0.3
			hitbox.Color = shouldClick and HIT_COLOR or NORMAL_COLOR

			if not VIM then
				setStatus("warn", "Нет VirtualInputManager")
			elseif shouldClick then
				setStatus("danger", "УДАР!")
			elseif effIn then
				setStatus("on", "Auto Shot: цель найдена")
			else
				setStatus("on", "Auto Shot: ВКЛ")
			end

			-- Loft: за LoftPre секунд до клика смотрим вверх
			if S.Loft and armed and effIn ~= nil and effIn <= leadTime + S.LoftPre and effIn >= -0.3 then
				loftUntil = now + S.LoftHold
			end

			if shouldClick then
				if not armed and now - lastClick >= S.RepeatCooldown then
					armed = true
				end
				if armed and now - lastClick >= S.ClickCooldown then
					armed = false
					lastClick = now
					shotCount += 1
					clickM1()
					if S.Loft then
						loftUntil = now + S.LoftAfterClick
					end
				end
			elseif effIn == nil or effIn > leadTime + 0.1 then
				armed = true
			end
		end)

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function foldout(title)
			local btn, g
			btn = UI.Button(h, "▸ " .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = false
			return g
		end

		-- бинды: клик -> нажми клавишу; Esc/Backspace очищают
		local listening = nil -- { field, render }

		local function isReserved(key, field)
			if key == CONFIG.ToggleKey or key == CONFIG.CursorKey or key == Enum.KeyCode.Space then
				return true
			end
			local d = shared.AutoDribble and shared.AutoDribble.Settings
			if d and d.Key == key then
				return true
			end
			local t = shared.AutoTackle and shared.AutoTackle.Settings
			if t and t.Key == key then
				return true
			end
			local s = shared.AutoSlide and shared.AutoSlide.Settings
			if s and (s.Key == key or s.TackleKey == key) then
				return true
			end
			local other = (field == "Key") and "LoftKey" or "Key"
			if S[other] == key then
				return true
			end
			return false
		end

		local function bindRow(labelText, field)
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = labelText,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row

			local function render()
				btn.Text = S[field] and S[field].Name or "—"
			end
			render()


			btn.MouseButton1Click:Connect(function()
				if listening then
					listening.render()
				end
				listening = { field = field, render = render }
				btn.Text = "Нажми клавишу…"
			end)
			return render
		end

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO SHOT")
		local mainToggle = UI.Toggle(h, "Auto Shot", false, setEnabled)
		bindRow("Бинд вкл/выкл", "Key")

		local loftToggle = UI.Toggle(h, "Loft (взгляд вверх перед ударом)", S.Loft, function(v)
						Persist.addId("bind/AutoShot/" .. field, "bind", function() return S[field] end,
				function(k) S[field] = k; render(); refreshOffText(); refreshInfo() end)
			S.Loft = v
			if not v then
				loftUntil = 0
			end
			refreshInfo()
		end)
		bindRow("Бинд Loft", "LoftKey")

		local kickedBtn
		kickedBtn = UI.Button(h, "Kicked: " .. KICKED_MODES[S.KickedMode], function()
			S.KickedMode = S.KickedMode % #KICKED_MODES + 1
			kickedBtn.Text = "Kicked: " .. KICKED_MODES[S.KickedMode]
		end)
        		Persist.addId("AutoShot/KickedMode", "choice", function() return S.KickedMode end, function(v)
			if KICKED_MODES[v] then S.KickedMode = v; kickedBtn.Text = "Kicked: " .. KICKED_MODES[v] end
		end)

		UI.Note(
			h,
			"Бьёт M1 по свободному мячу (Football), когда он входит в хитбокс вокруг призрака LagGhost (workspace.lagghost), с упреждением по пингу. Сам прыгает за высокими мячами. Размеры хитбокса и режимы Flow/Inbox настраиваются ниже. Бинд: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить)."
		)

		------------------------------------------------------------
		-- UI: ХИТБОКС
		------------------------------------------------------------
		local gBox = foldout("Хитбокс (обычный)")
		slider(gBox, "Размер X", 1, 80, "BoxX", 2)
		slider(gBox, "Размер Y", 1, 100, "BoxY", 2)
		slider(gBox, "Размер Z", 1, 80, "BoxZ", 2)
		slider(gBox, "Высота досягаемости (Y)", 0, 100, "ReachY", 1)
		toggle(gBox, "Показывать хитбокс", "ShowHitbox", restyle)

		local gFlow = foldout("Хитбокс: Flow (Galaxy)")
		toggle(gFlow, "Использовать режим Flow", "UseFlow")
		slider(gFlow, "Размер X", 1, 80, "FlowX", 2)
		slider(gFlow, "Размер Y", 1, 100, "FlowY", 2)
		slider(gFlow, "Размер Z", 1, 80, "FlowZ", 2)
		slider(gFlow, "Высота досягаемости (Y)", 0, 100, "FlowReachY", 1)
		slider(gFlow, "Уменьшение по Y при Hold M1", 0, 10, "FlowHoldTrim", 2)

		local gInbox = foldout("Хитбокс: Inbox")
		toggle(gInbox, "Использовать режим Inbox", "UseInbox")
		UI.Section(gInbox, "ТОЛЬКО INBOX")
		slider(gInbox, "Размер X", 1, 80, "InboxX", 2)
		slider(gInbox, "Размер Y", 1, 100, "InboxY", 2)
		slider(gInbox, "Размер Z", 1, 80, "InboxZ", 2)
		slider(gInbox, "Высота досягаемости (Y)", 0, 100, "InboxReachY", 1)
		UI.Section(gInbox, "INBOX + FLOW")
		slider(gInbox, "Размер X", 1, 80, "InboxFlowX", 2)
		slider(gInbox, "Размер Y", 1, 100, "InboxFlowY", 2)
		slider(gInbox, "Размер Z", 1, 80, "InboxFlowZ", 2)
		slider(gInbox, "Высота досягаемости (Y)", 0, 100, "InboxFlowReachY", 1)
		slider(gInbox, "Уменьшение по Y при Hold M1", 0, 10, "InboxHoldTrim", 2)

		------------------------------------------------------------
		-- UI: УПРЕЖДЕНИЕ И ПИНГ
		------------------------------------------------------------
		local gPing = foldout("Упреждение и пинг")
		toggle(gPing, "Реальный пинг", "UseRealPing")
		slider(gPing, "Запасной пинг (мс)", 0, 500, "FallbackPingMs", 0)
		slider(gPing, "Сглаживание пинга", 0.01, 1, "PingSmooth", 2)
		slider(gPing, "Мин. пинг (сек)", 0, 1, "PingMin", 3)
		slider(gPing, "Макс. пинг (сек)", 0.05, 2, "PingMax", 2)
		slider(gPing, "Поправка (сек): + раньше, - позже", -0.3, 0.5, "PingOffset", 3)
		slider(gPing, "Множитель задержки удара", 0, 5, "HitDelayMult", 2)
		slider(gPing, "Раньше без Hold (× пинг)", 0, 5, "EarlyNoHoldMult", 2)
		slider(gPing, "Доп. запас (сек)", -0.3, 1, "LeadExtra", 3)

		local gPred = foldout("Предсказание мяча")
		slider(gPred, "Горизонт (сек)", 0.1, 3, "Horizon", 2)
		slider(gPred, "Шаг проверки (сек)", 0.002, 0.1, "Step", 3)
		toggle(gPred, "Учитывать гравитацию мяча", "UseGravity")

		------------------------------------------------------------
		-- UI: КЛИК
		------------------------------------------------------------
		local gClick = foldout("Клик")
		slider(gClick, "Кулдаун клика (сек)", 0.05, 2, "ClickCooldown", 2)
		slider(gClick, "Повтор по тому же мячу (сек)", 0.05, 3, "RepeatCooldown", 2)
		toggle(gClick, "Hold M1 только с ChargingKick", "RequireCharging")

		------------------------------------------------------------
		-- UI: ПРЫЖОК
		------------------------------------------------------------
		local gJump = foldout("Авто-прыжок")
		toggle(gJump, "Авто-прыжок", "AutoJump")
		slider(gJump, "Упреждение прыжка (× пинг)", 0, 5, "JumpPingMult", 2)
		slider(gJump, "Мин. высота над досягаемостью", 0, 10, "MinLift", 2)
		slider(gJump, "Запас по высоте прыжка", 0, 10, "JumpOverreach", 2)
		slider(gJump, "Горизонт прыжка (сек)", 0.1, 3, "JumpHorizon", 2)
		slider(gJump, "Кулдаун прыжка (сек)", 0.1, 3, "JumpCooldown", 2)
		slider(gJump, "Пауза после удара (сек)", 0, 2, "JumpAfterHitCooldown", 2)
		slider(gJump, "Удержание Space (сек)", 0.01, 0.3, "JumpTapTime", 3)
		slider(gJump, "Допуск опоздания (сек)", 0, 0.3, "LateTolerance", 3)

		------------------------------------------------------------
		-- UI: LOFT
		------------------------------------------------------------
		local gLoft = foldout("Loft")
		slider(gLoft, "Угол вверх (градусы)", 0, 89, "LoftPitch", 0)
		slider(gLoft, "За сколько до клика (сек)", 0, 0.5, "LoftPre", 3)
		slider(gLoft, "Запас удержания (сек)", 0.02, 0.6, "LoftHold", 3)
		slider(gLoft, "Вернуть взгляд после удара (сек)", 0.02, 0.5, "LoftAfterClick", 3)

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		local gGui = foldout("GUI Auto Shot")
		UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
			S.GuiShown = v
			Widget.Visible = v
		end)
		UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(gGui, "Сбросить позицию GUI", function()
			setWidgetPos(14, 35)
			xSlider.Set(14, true)
			ySlider.Set(35, true)
		end)
		UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")

		refreshOffText()
		refreshInfo()

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local l = listening
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						S[l.field] = nil
					elseif not isReserved(key, l.field) then
						S[l.field] = key
					end
					l.render()
					refreshOffText()
					refreshInfo()
				end
				return
			end

			if gp then
				return
			end
			if S.Key and input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			elseif S.LoftKey and input.KeyCode == S.LoftKey then
				loftToggle.Set(not loftToggle.Get())
			end
		end)

		-- отдаём наружу
		shared.AutoShot = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoShot)
	if not ok then
		warn("[Yokatta] AutoShot: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO ES / BHT
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto Shot
-- (и тоже ПЕРЕД разделом «СТАРТ»). Отдельный скрипт больше не нужен.
-- Explosive Speed + Blackhole Trap. Использует призрака LagGhost.
-- Бинд только на общий вкл/выкл. ES и BHT включаются по отдельности
-- ТОЛЬКО из меню (горячих клавиш на них нет).
------------------------------------------------------------
do
	local function initAutoEsBht()
		local h = Holders.AutoUse
		if not h then
			return
		end
		-- UI.ClearPlaceholder(h) уже вызван блоком Auto Dribble.

		local player = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoEsBht")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaEsBhtVis")
			if v then
				v:Destroy()
			end
			pcall(function()
				RunService:UnbindFromRenderStep("YokattaBhtHold")
			end)
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil, -- бинд общего вкл/выкл

			-- что использовать (переключается ТОЛЬКО в панели)
			UseES = true,
			UseBHT = true,

			-- пинг и задержки
			PingMult = 1,
			PingOffset = 0,
			PingMin = 0,
			PingMax = 1,
			MaxPingExtra = 0.4, -- если RTT больше, не кастуем
			InterpDelay = 0.05,
			ExtraLatency = -0.03,
			InputFrame = 0.017,

			-- общее
			FireDelay = 0.2, -- не чаще чем раз в N сек
			HoldExtra = 0.15, -- держим взгляд после ES
			KeyHold = 0.05,
			GroundOffset = 3, -- запасной вариант, если луч землю не нашёл
			CheckAnyPossession = true,
			PossessionNear = 8, -- мяч «у игрока», когда ближе этого к владельцу
			BallBounce = 0.6,
			BallDrag = 0,

			-- Explosive Speed
			TpDist = 37,
			HalfW = 4,
			HalfH = 1.5,
			HalfHFast = 1,
			BallFastSpeed = 60,
			MeFastSpeed = 20,
			HitboxReach = 4,
			CastDelay = 0,
			TpPingMult = 1,
			TpTimeExtra = 0,
			MinTpTime = 0.03,
			MinDist = 0,

			-- Blackhole Trap
			BhtLiftHeight = 15,
			BhtLiftTime = 0.3,
			BhtJumpHeight = 7.5,
			BhtJumpDelay = 0.2,
			BhtHoverTime = 1.1,
			BhtBoxX = 20,
			BhtBoxY = 40,
			BhtBoxZ = 20,
			BhtBoxOffY = 7.5,
			BhtMaxCatchOffset = 1.0,
			BhtMinBallHeight = 9,
			BhtJumpMinHeight = 15, -- ниже этой высоты поимки прыжок не нужен
			BhtSafety = 1,
			BhtUncertainty = 0.04,
			BhtMaxMargin = 6,
			BhtSlack = 0.03,
			BhtEvalStep = 0.0167,
			BhtWaitJumpMax = 0.25,
			BhtWaitStep = 0.05,
			BhtHoldStill = true,
			BhtStopSlide = 0.08,

			-- визуал
			ShowDebug = false,

			-- GUI
			GuiShown = false,
		}

		local ES_NAMES = { "Explosive Speed", "Exploisive Speed" }
		local BHT_NAMES = { "Blackhole Trap", "BlackholeTrap" }
		local GHOST_NAMES = { "Lagghost", "LagGhost", "lagghost", "Lag Ghost" }
		local BALL_NAMES = { ["/e ball"] = true, ["Football"] = true }
		local NUM_KEYS = { "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero" }

		-- списки состояний (в панели можно выключать отдельные пункты)
		local SELF_BLOCK = {
			{ name = "Possession", enabled = true },
			{ name = "SlideTackle", enabled = true },
			{ name = "Dribble", enabled = true },
		}
		local ES_BALL_BLOCK = {
			{ name = "Possession", enabled = true },
			{ name = "Kicked", enabled = true },
		}
		local BHT_BALL_BLOCK = {
			{ name = "Possession", enabled = true },
			{ name = "Kicked", enabled = true },
			{ name = "IFrames", enabled = true },
		}
		local BHT_SELF_BLOCK = {
			{ name = "ChargingKick", enabled = true },
			{ name = "Possession", enabled = true },
			{ name = "Dribble", enabled = true },
			{ name = "Skill", enabled = true },
		}

		------------------------------------------------------------
		-- СОСТОЯНИЕ
		------------------------------------------------------------
		local busy = false
		local castKind = nil
		local lastCast = 0
		local casts = { es = 0, bht = 0 }
		local bhtReason = "—"
		local statBalls = 0
		local injecting = {}

		------------------------------------------------------------
		-- ПИНГ
		------------------------------------------------------------
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local pingRaw = readPing() or player:GetNetworkPing()
		local function getPing()
			return math.max(0, pingRaw * S.PingMult + S.PingOffset)
		end
		local function updatePing()
			local p = readPing()
			if p then
				pingRaw = math.clamp(p, S.PingMin, S.PingMax)
			end
		end

		------------------------------------------------------------
		-- ПОМОЩНИКИ
		------------------------------------------------------------
		local function flat(v)
			return Vector3.new(v.X, 0, v.Z)
		end

		local function getRoot(char)
			return char and char:FindFirstChild("HumanoidRootPart")
		end

		local function getIV(char)
			return char and char:FindFirstChild("InstanceValue")
		end

		-- ищет первое включённое состояние из списка
		local function findAny(iv, list)
			if not iv then
				return nil
			end
			for _, e in ipairs(list) do
				if e.enabled and iv:FindFirstChild(e.name) then
					return e.name
				end
			end
			return nil
		end

		local function hasAny(iv, list)
			return findAny(iv, list) ~= nil
		end

		local function hasPossession(char)
			local iv = getIV(char)
			return iv ~= nil and iv:FindFirstChild("Possession") ~= nil
		end

		local function findSkill(names)
			local bp = player:FindFirstChildOfClass("Backpack")
			for _, name in ipairs(names) do
				local tool = bp and bp:FindFirstChild(name)
				if not tool and player.Character then
					tool = player.Character:FindFirstChild(name)
				end
				if tool then
					return tool, name
				end
			end
			return nil
		end

		local function cdName(skillName)
			return (skillName:gsub("%s", "")) .. "Cooldown"
		end

		local function readSlot(tool)
			local s = tool:FindFirstChild("Slot")
			if s and s:IsA("ValueBase") then
				return tonumber(s.Value)
			end
			return tonumber(tool:GetAttribute("Slot"))
		end

		-- состояние скилла: off (выключен в панели) | none (нет) | cd | ready
		local function skillState(names, use)
			if not use then
				return "off"
			end
			local tool, name = findSkill(names)
			if not tool then
				return "none"
			end
			local iv = getIV(player.Character)
			if iv and iv:FindFirstChild(cdName(name)) then
				return "cd"
			end
			return "ready"
		end

		-- клавиша скилла, если он есть и не на кулдауне
		local function getReadyKeyFor(char, names)
			local tool, name = findSkill(names)
			if not tool then
				return nil
			end
			local iv = getIV(char)
			if iv and iv:FindFirstChild(cdName(name)) then
				return nil
			end
			local slot = readSlot(tool)
			if not slot then
				return nil
			end
			local keyName = NUM_KEYS[slot + 1]
			return keyName and Enum.KeyCode[keyName] or nil
		end

		local function sendKey(key, hold)
			if not VIM then
				return
			end
			injecting[key] = (injecting[key] or 0) + 1
			VIM:SendKeyEvent(true, key, false, game)
			task.wait(hold or S.KeyHold)
			VIM:SendKeyEvent(false, key, false, game)
			task.delay(0.15, function()
				injecting[key] = (injecting[key] or 1) - 1
				if injecting[key] <= 0 then
					injecting[key] = nil
				end
			end)
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ
		------------------------------------------------------------
		local EGui = create("ScreenGui", {
			Name = "YokattaAutoEsBht",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 993,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		EGui.Parent = parent

		local widgetPos = { x = 86, y = 66 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(300, 124),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = EGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "ES / BHT: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local function newChip(text, x)
			local chip = create("TextLabel", {
				Position = UDim2.fromOffset(x, 34),
				Size = UDim2.fromOffset(86, 20),
				BackgroundColor3 = C.Off,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = Color3.new(1, 1, 1),
				Text = text,
			}, { corner(UDim.new(0, 5)) })
			chip.Parent = Widget
			return chip
		end
		local esChip = newChip("ES", 12)
		local bhtChip = newChip("BHT", 104)

		local Info1 = create("TextLabel", {
			Position = UDim2.fromOffset(12, 62),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "—",
		})
		Info1.Parent = Widget

		local Info2 = create("TextLabel", {
			Position = UDim2.fromOffset(12, 82),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "—",
		})
		Info2.Parent = Widget

		local Info3 = create("TextLabel", {
			Position = UDim2.fromOffset(12, 102),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextMid,
			Text = "—",
		})
		Info3.Parent = Widget

		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			idle = Color3.fromRGB(90, 160, 255),
			warn = Color3.fromRGB(255, 170, 0),
		}
		local CHIP_COLORS = {
			ready = Color3.fromRGB(0, 190, 95),
			cd = Color3.fromRGB(220, 60, 60),
			off = C.Off,
			none = Color3.fromRGB(255, 170, 0),
		}
		local CHIP_TEXT = { ready = "", cd = " КД", off = " выкл", none = " нет" }

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local function setText(label, text)
			if label.Text ~= text then
				label.Text = text
			end
		end

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local function refreshInfo()
			local es = skillState(ES_NAMES, S.UseES)
			local bht = skillState(BHT_NAMES, S.UseBHT)
			esChip.BackgroundColor3 = CHIP_COLORS[es]
			esChip.Text = "ES" .. CHIP_TEXT[es]
			bhtChip.BackgroundColor3 = CHIP_COLORS[bht]
			bhtChip.Text = "BHT" .. CHIP_TEXT[bht]

			setText(Info1, string.format("Мячей: %d | пинг %d мс", statBalls, math.floor(getPing() * 1000 + 0.5)))
			setText(Info2, string.format("Касты: ES %d | BHT %d", casts.es, casts.bht))
			setText(Info3, "BHT: " .. bhtReason)
		end

		local xSlider, ySlider
		local function setWidgetPos(x, y)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- ВИЗУАЛ (дебаг)
		------------------------------------------------------------
		local visFolder = Instance.new("Folder")
		visFolder.Name = "YokattaEsBhtVis"
		visFolder.Parent = workspace

		local function visPart(shape, color)
			local p = Instance.new("Part")
			if shape then
				p.Shape = shape
			end
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Material = Enum.Material.Neon
			p.Color = color
			p.Transparency = 1
			p.Parent = visFolder
			return p
		end

		local dbgBall = visPart(Enum.PartType.Ball, Color3.fromRGB(255, 60, 60))
		dbgBall.Size = Vector3.new(2, 2, 2)
		local dbgBox = visPart(nil, Color3.fromRGB(0, 255, 255))
		local dbgBhtBall = visPart(Enum.PartType.Ball, Color3.fromRGB(255, 160, 0))
		dbgBhtBall.Size = Vector3.new(2, 2, 2)
		local dbgBhtBox = visPart(nil, Color3.fromRGB(255, 160, 0))

		local function hideEsDebug()
			dbgBall.Transparency, dbgBox.Transparency = 1, 1
		end

		local function hideBhtDebug()
			dbgBhtBall.Transparency, dbgBhtBox.Transparency = 1, 1
		end

		local function hideAllDebug()
			hideEsDebug()
			hideBhtDebug()
		end

		local function showEsDebug(origin, dir, meet, halfH)
			if not S.ShowDebug then
				hideEsDebug()
				return
			end
			dbgBall.Position = meet
			dbgBall.Transparency = 0.2
			dbgBox.Size = Vector3.new(S.HalfW * 2, (halfH or S.HalfH) * 2, S.TpDist)
			dbgBox.CFrame = CFrame.lookAt(origin + dir * (S.TpDist / 2), origin + dir * S.TpDist)
			dbgBox.Transparency = 0.8
		end

		local function showBhtDebug(center, ballPos, look)
			if not S.ShowDebug then
				hideBhtDebug()
				return
			end
			dbgBhtBall.Position = ballPos
			dbgBhtBall.Transparency = 0.2
			dbgBhtBox.Size = Vector3.new(S.BhtBoxX, S.BhtBoxY, S.BhtBoxZ)
			dbgBhtBox.CFrame = CFrame.lookAt(center, center + look)
			dbgBhtBox.Transparency = 0.85
		end

		------------------------------------------------------------
		-- МЯЧИ (любое количество)
		------------------------------------------------------------
		local ballSet = {}

		local function registerBall(obj)
			if BALL_NAMES[obj.Name] and (obj:IsA("BasePart") or obj:IsA("Model")) then
				ballSet[obj] = true
			end
		end
		for _, obj in ipairs(workspace:GetDescendants()) do
			registerBall(obj)
		end
		workspace.DescendantAdded:Connect(registerBall)
		workspace.DescendantRemoving:Connect(function(obj)
			ballSet[obj] = nil
		end)

		local function resolvePart(inst)
			if inst:IsA("BasePart") then
				return inst
			end
			return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
		end

		local function insideCharacter(part)
			local a = part.Parent
			while a and a ~= workspace do
				if Players:GetPlayerFromCharacter(a) then
					return true
				end
				a = a.Parent
			end
			return false
		end

		local function ballRadius(part)
			return math.max(part.Size.X, part.Size.Y, part.Size.Z) / 2
		end

		local function getBalls()
			local list, seen = {}, {}
			for inst in pairs(ballSet) do
				if inst.Parent then
					local part = resolvePart(inst)
					if part and part.Parent and not seen[part] and not part.Anchored and not insideCharacter(part) then
						seen[part] = true
						list[#list + 1] = {
							inst = inst,
							part = part,
							iv = inst:FindFirstChild("InstanceValue"),
							radius = ballRadius(part),
						}
					end
				else
					ballSet[inst] = nil
				end
			end
			return list
		end

		local function getPossessors()
			local t = {}
			for _, plr in ipairs(Players:GetPlayers()) do
				local c = plr.Character
				if c and hasPossession(c) then
					t[#t + 1] = getRoot(c) or true
				end
			end
			return t
		end

		-- мяч нельзя ловить: свои флаги или он у игрока с Possession
		local function ballBlocked(entry, list, possessors, nBalls)
			if hasAny(entry.iv, list) then
				return true
			end
			if S.CheckAnyPossession and #possessors > 0 then
				if nBalls <= 1 then
					return true
				end
				for _, r in ipairs(possessors) do
					if r ~= true and (r.Position - entry.part.Position).Magnitude <= S.PossessionNear then
						return true
					end
				end
			end
			return false
		end

		-- история позиций на каждый мяч (запасной способ узнать скорость)
		local histories = setmetatable({}, { __mode = "k" })

		local function sampleBall(part)
			local hist = histories[part]
			if not hist then
				hist = {}
				histories[part] = hist
			end
			local now = os.clock()
			hist[#hist + 1] = { t = now, p = part.Position }
			while #hist > 1 and now - hist[1].t > 0.12 do
				table.remove(hist, 1)
			end
		end

		local function getBallVelocity(part)
			local v = part.AssemblyLinearVelocity
			local hist = histories[part]
			if flat(v).Magnitude < 1 and hist and #hist >= 2 then
				local a, b = hist[1], hist[#hist]
				local dt = b.t - a.t
				if dt > 0.03 then
					local m = (b.p - a.p) / dt
					return Vector3.new(m.X, v.Y, m.Z)
				end
			end
			return v
		end

		------------------------------------------------------------
		-- LAGGHOST И ЗЕМЛЯ
		------------------------------------------------------------
		local ghostRoot = nil
		local lastGhostSearch = 0
		local function getGhostRoot()
			if ghostRoot and ghostRoot.Parent then
				return ghostRoot
			end
			ghostRoot = nil
			local now = os.clock()
			if now - lastGhostSearch < 0.5 then
				return nil
			end
			lastGhostSearch = now
			for _, name in ipairs(GHOST_NAMES) do
				local obj = workspace:FindFirstChild(name, true)
				if obj then
					local r = obj:IsA("BasePart") and obj
						or obj:FindFirstChild("HumanoidRootPart", true)
						or obj.PrimaryPart
						or obj:FindFirstChildWhichIsA("BasePart", true)
					if r then
						ghostRoot = r
						return r
					end
				end
			end
			return nil
		end

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		local groundCache = { t = -1, y = nil }

		local function getGroundY(root)
			local now = os.clock()
			if groundCache.y and now - groundCache.t < 0.1 then
				return groundCache.y
			end
			local ignore = { visFolder }
			local cam = workspace.CurrentCamera
			if cam then
				ignore[#ignore + 1] = cam
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character then
					ignore[#ignore + 1] = plr.Character
				end
			end
			for inst in pairs(ballSet) do
				ignore[#ignore + 1] = inst
			end
			if ghostRoot and ghostRoot.Parent then
				local gm = ghostRoot:FindFirstAncestorOfClass("Model")
				ignore[#ignore + 1] = gm or ghostRoot
			end
			rayParams.FilterDescendantsInstances = ignore

			local res = workspace:Raycast(root.Position, Vector3.new(0, -60, 0), rayParams)
			local y = res and res.Position.Y or (root.Position.Y - S.GroundOffset)
			groundCache.t, groundCache.y = now, y
			return y
		end

		------------------------------------------------------------
		-- ФИЗИКА МЯЧА
		------------------------------------------------------------
		local function stepBall(pos, v, dt, floor, g)
			local airborne = pos.Y > floor + 0.05 or v.Y > 1
			if airborne then
				v = Vector3.new(v.X, v.Y - g * dt, v.Z)
			end
			if S.BallDrag > 0 then
				local k = math.max(0, 1 - S.BallDrag * dt)
				v = Vector3.new(v.X * k, v.Y, v.Z * k)
			end
			pos = pos + v * dt
			if pos.Y < floor then
				pos = Vector3.new(pos.X, floor, pos.Z)
				if v.Y < -3 then
					v = Vector3.new(v.X, -v.Y * S.BallBounce, v.Z)
				else
					v = Vector3.new(v.X, 0, v.Z)
				end
			end
			return pos, v
		end

		-- ES: траектория {tau, pos}, tau = время от старта телепорта (0..D)
		local function ballPath(part, vel, T0, D, floorY)
			local pos, v = part.Position, vel
			local g = workspace.Gravity
			local floor = math.min(floorY, pos.Y)
			local total = T0 + D
			local n = math.max(1, math.ceil(total / (1 / 60)))
			local dt = total / n

			local path = {}
			local time = 0
			if T0 <= 0 then
				table.insert(path, { tau = 0, pos = pos })
			end
			for _ = 1, n do
				pos, v = stepBall(pos, v, dt, floor, g)
				time += dt
				if time >= T0 - 1e-6 then
					table.insert(path, { tau = math.clamp(time - T0, 0, D), pos = pos })
				end
			end
			return path
		end

		-- BHT: траектория с фиксированным шагом, pts[1] = сейчас
		local SIM_DT = 1 / 60
		local function simulateBall(part, vel, horizon, floorY)
			local pos, v = part.Position, vel
			local g = workspace.Gravity
			local floor = math.min(floorY, pos.Y)
			local n = math.max(1, math.ceil(horizon / SIM_DT))
			local pts = { pos }
			for i = 1, n do
				pos, v = stepBall(pos, v, SIM_DT, floor, g)
				pts[i + 1] = pos
			end
			return pts
		end

		local function simAt(pts, t)
			local x = math.max(t, 0) / SIM_DT
			local i = math.floor(x)
			if i + 2 > #pts then
				return pts[#pts]
			end
			return pts[i + 1]:Lerp(pts[i + 2], x - i)
		end

		------------------------------------------------------------
		-- EXPLOSIVE SPEED: планирование
		------------------------------------------------------------
		local function serverStartIn(ping)
			return S.CastDelay + ping
		end

		local function leadTime(ping)
			return math.max(0, S.CastDelay + ping * 2 + S.InterpDelay + S.ExtraLatency)
		end

		local function tpDuration(ping)
			return math.max(S.MinTpTime, ping * S.TpPingMult + S.TpTimeExtra)
		end

		local function getHalfH(part, root)
			local ballSpeed = flat(getBallVelocity(part)).Magnitude
			local mySpeed = flat(root.AssemblyLinearVelocity).Magnitude
			local f = math.clamp(ballSpeed / math.max(0.001, S.BallFastSpeed), 0, 1)
				* math.clamp(mySpeed / math.max(0.001, S.MeFastSpeed), 0, 1)
			return S.HalfH + (S.HalfHFast - S.HalfH) * f
		end

		-- возвращает: dir, tau, позиция встречи, halfH, origin
		local function plan(root, part, elapsed)
			elapsed = elapsed or 0
			local ping = getPing()
			if ping * 2 > S.MaxPingExtra then
				return nil
			end

			local D = tpDuration(ping)
			local T0 = math.max(leadTime(ping) - elapsed, 0)

			local ghost = getGhostRoot()
			local origin
			if ghost then
				local gVel = flat(ghost.AssemblyLinearVelocity)
				origin = ghost.Position + gVel * math.max(S.CastDelay - elapsed, 0)
			else
				local myVel = flat(root.AssemblyLinearVelocity)
				origin = root.Position + myVel * math.max(serverStartIn(ping) - elapsed, 0)
			end

			local radius = ballRadius(part)
			local halfH = getHalfH(part, root)
			local floorY = origin.Y - S.GroundOffset + radius
			local path = ballPath(part, getBallVelocity(part), T0, D, floorY)
			if #path == 0 then
				return nil
			end

			local first = flat(path[1].pos - origin).Magnitude
			if first <= math.max(S.HitboxReach, S.MinDist) then
				return nil
			end

			for _, s in ipairs(path) do
				local travelled = S.TpDist * (s.tau / D)
				local rel = flat(s.pos - origin)
				local d = rel.Magnitude
				if d - travelled <= S.HitboxReach then
					if d < 0.1 then
						return nil
					end
					if math.abs(s.pos.Y - origin.Y) > halfH + radius then
						return nil
					end
					return rel.Unit, s.tau, s.pos, halfH, origin
				end
			end
			return nil
		end

		------------------------------------------------------------
		-- BLACKHOLE TRAP: планирование
		------------------------------------------------------------
		local function evalCatch(c, jump, wait)
			local sigS = wait + S.InputFrame + (jump and S.BhtJumpDelay or 0) + c.ping + S.BhtSlack
			local jumpH = jump and S.BhtJumpHeight or 0
			local activeEnd = S.BhtLiftTime + S.BhtHoverTime
			local uEnd = math.min(activeEnd, S.BhtMaxCatchOffset)
			local halfX, halfY, halfZ = S.BhtBoxX / 2, S.BhtBoxY / 2, S.BhtBoxZ / 2

			local u = 0
			while u <= uEnd + 1e-6 do
				local sigma = sigS + u
				local p = simAt(c.pts, sigma + c.seenDelay)

				if p.Y - c.groundY >= S.BhtMinBallHeight then
					local lift = S.BhtLiftHeight * math.clamp(u / math.max(0.001, S.BhtLiftTime), 0, 1)
					local cy = c.baseY + jumpH + lift + S.BhtBoxOffY

					local xz = c.holdStill and c.stillXZ or (c.ghostPos + c.ghostVel * sigma)
					local rel = flat(p) - xz

					local m = math.min(S.BhtMaxMargin, S.BhtSafety + c.speed * (sigma + c.seenDelay) * S.BhtUncertainty)
					local limX = halfX + c.radius - m
					local limZ = halfZ + c.radius - m
					local limY = halfY + c.radius - m

					if
						limX > 0
						and limY > 0
						and limZ > 0
						and math.abs(rel:Dot(c.right)) <= limX
						and math.abs(rel:Dot(c.look)) <= limZ
						and math.abs(p.Y - c.groundY - (cy - c.groundY)) <= limY
					then
						return sigma, p, Vector3.new(xz.X, cy, xz.Z)
					end
				end
				u += math.max(0.002, S.BhtEvalStep)
			end
			return nil
		end

		local function decideBHT(c)
			local sigN, pN, cN = evalCatch(c, false, 0)

			-- мяч низкий и без прыжка ловится: прыжок не нужен
			if sigN and (pN.Y - c.groundY) < S.BhtJumpMinHeight then
				return { jump = false, catch = sigN, ball = pN, center = cN }
			end

			local sig, p, center = evalCatch(c, true, 0)
			if sig then
				return { jump = true, catch = sig, ball = p, center = center }
			end

			if not sigN then
				return nil
			end

			local w = S.BhtWaitStep
			while w <= S.BhtWaitJumpMax + 1e-6 do
				if evalCatch(c, true, w) then
					if evalCatch(c, false, w) then
						return nil -- подождём: через w сек сработает вариант с прыжком
					end
					break
				end
				w += math.max(0.005, S.BhtWaitStep)
			end
			return { jump = false, catch = sigN, ball = pN, center = cN }
		end

		local function planBHT(root, hum, balls, possessors)
			local ping = getPing()
			if ping * 2 > S.MaxPingExtra then
				return nil
			end
			if hum.FloorMaterial == Enum.Material.Air then
				return nil
			end

			local groundY = getGroundY(root)
			local ghost = getGhostRoot()
			local myVel = flat(root.AssemblyLinearVelocity)

			local ghostPos, ghostVel
			if ghost then
				ghostPos, ghostVel = flat(ghost.Position), flat(ghost.AssemblyLinearVelocity)
			else
				ghostPos, ghostVel = flat(root.Position), myVel
			end

			local look = flat(root.CFrame.LookVector)
			look = look.Magnitude > 0.01 and look.Unit or Vector3.zAxis
			local right = look:Cross(Vector3.yAxis)

			local seenDelay = math.max(0, ping + S.InterpDelay + S.ExtraLatency)
			local horizon = seenDelay
				+ S.BhtWaitJumpMax
				+ S.InputFrame
				+ S.BhtJumpDelay
				+ ping
				+ S.BhtSlack
				+ math.min(S.BhtLiftTime + S.BhtHoverTime, S.BhtMaxCatchOffset)
				+ 0.2

			local best
			for _, e in ipairs(balls) do
				if not ballBlocked(e, BHT_BALL_BLOCK, possessors, #balls) then
					local vel = getBallVelocity(e.part)
					local c = {
						ping = ping,
						seenDelay = seenDelay,
						groundY = groundY,
						baseY = root.Position.Y,
						radius = e.radius,
						speed = vel.Magnitude,
						look = look,
						right = right,
						holdStill = S.BhtHoldStill,
						stillXZ = flat(root.Position + myVel * S.BhtStopSlide),
						ghostPos = ghostPos,
						ghostVel = ghostVel,
						pts = simulateBall(e.part, vel, horizon, groundY + e.radius),
					}
					local res = decideBHT(c)
					if res and (not best or res.catch < best.catch) then
						res.look = look
						best = res
					end
				end
			end
			return best
		end

		------------------------------------------------------------
		-- КАСТЫ
		------------------------------------------------------------
		local function runCast(fn, ...)
			task.spawn(function(...)
				local ok, err = pcall(fn, ...)
				if not ok then
					warn("[Yokatta] AutoEsBht: " .. tostring(err))
					busy = false
					castKind = nil
					pcall(function()
						RunService:UnbindFromRenderStep("YokattaBhtHold")
					end)
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.AutoRotate = true
					end
					hideBhtDebug()
				end
			end, ...)
		end

		-- Explosive Speed
		local function castES(dir, key, targetPart)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) then
				return
			end

			busy = true
			castKind = "ES"
			casts.es += 1
			hum.AutoRotate = false

			local ping = getPing()
			local startT = os.clock()
			local total = S.CastDelay + S.HoldExtra + ping * 2 + tpDuration(ping)
			local currentDir = dir
			local conn

			local function finish()
				if conn then
					conn:Disconnect()
				end
				if hum.Parent then
					hum.AutoRotate = true
				end
				busy = false
				castKind = nil
				hideEsDebug()
			end

			conn = RunService.RenderStepped:Connect(function()
				local elapsed = os.clock() - startT
				if elapsed > total or not root.Parent then
					finish()
					return
				end
				-- пока сервер не начал телепорт, уточняем направление по тому же мячу
				if elapsed <= S.CastDelay + ping and targetPart and targetPart.Parent then
					local newDir = plan(root, targetPart, elapsed)
					if newDir then
						currentDir = newDir
					end
				end
				root.CFrame = CFrame.lookAt(root.Position, root.Position + currentDir)
			end)

			root.CFrame = CFrame.lookAt(root.Position, root.Position + currentDir)
			task.wait()
			sendKey(key, S.KeyHold)
		end

		-- Blackhole Trap: [прыжок] -> (задержка) -> скилл -> держим на месте
		local function castBHT(jump, key)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) then
				return
			end

			busy = true
			castKind = "BHT"
			casts.bht += 1
			local finished = false

			local function finish()
				if finished then
					return
				end
				finished = true
				pcall(function()
					RunService:UnbindFromRenderStep("YokattaBhtHold")
				end)
				busy = false
				castKind = nil
				hideBhtDebug()
			end

			if S.BhtHoldStill then
				RunService:BindToRenderStep("YokattaBhtHold", Enum.RenderPriority.Last.Value, function()
					if not root.Parent or hum.Health <= 0 then
						finish()
						return
					end
					hum:Move(Vector3.zero, false)
				end)
			end

			if jump then
				task.spawn(sendKey, Enum.KeyCode.Space, 0.03)
				local t0 = os.clock()
				while os.clock() - t0 < S.BhtJumpDelay and not finished do
					RunService.Heartbeat:Wait()
				end
			end

			if not finished then
				task.spawn(sendKey, key, S.KeyHold)
				local pressT = os.clock()
				local total = S.BhtLiftTime + S.BhtHoverTime + getPing()
				while os.clock() - pressT < total and not finished do
					if not root.Parent or hum.Health <= 0 or hasPossession(char) then
						break
					end
					RunService.Heartbeat:Wait()
				end
			end
			finish()
		end

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "ES / BHT: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				setStatus("on", "ES / BHT: ВКЛ")
			else
				hideAllDebug()
				bhtReason = "—"
				refreshOffText()
			end
			refreshInfo()
		end
		refreshOffText()

		------------------------------------------------------------
		-- ОСНОВНОЙ ЦИКЛ
		------------------------------------------------------------
		local statTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			updatePing()

			local balls = getBalls()
			for _, e in ipairs(balls) do
				sampleBall(e.part)
			end
			statBalls = #balls

			statTimer += dt
			if statTimer >= 0.25 then
				statTimer = 0
				refreshInfo()
			end

			if not S.Enabled then
				return
			end

			if not VIM then
				setStatus("warn", "Нет VirtualInputManager")
				return
			end

			if busy then
				setStatus("danger", "Каст: " .. tostring(castKind))
				return
			end

			if not S.UseES and not S.UseBHT then
				setStatus("warn", "ES и BHT выключены в меню")
				return
			end

			if #balls == 0 then
				setStatus("idle", "Нет мяча")
				return
			end

			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) or hum.Health <= 0 then
				setStatus("idle", "Нет персонажа")
				return
			end

			if hasAny(getIV(char), SELF_BLOCK) then
				setStatus("warn", "Заблокирован: " .. tostring(findAny(getIV(char), SELF_BLOCK)))
				return
			end

			setStatus("on", "ES / BHT: ВКЛ")

			local now = os.clock()
			if now - lastCast < S.FireDelay then
				return
			end

			local possessors = getPossessors()

			-- 1) Explosive Speed: берём мяч, который догоним раньше
			local esKey = S.UseES and getReadyKeyFor(char, ES_NAMES) or nil
			if esKey then
				local bestDir, bestPart, bestTau, bMeet, bHalfH, bOrigin
				for _, e in ipairs(balls) do
					if not ballBlocked(e, ES_BALL_BLOCK, possessors, #balls) then
						local dir, tau, meet, halfH, origin = plan(root, e.part, 0)
						if dir and (not bestTau or tau < bestTau) then
							bestDir, bestPart, bestTau, bMeet, bHalfH, bOrigin = dir, e.part, tau, meet, halfH, origin
						end
					end
				end
				if bestDir then
					showEsDebug(bOrigin, bestDir, bMeet, bHalfH)
					lastCast = now
					runCast(castES, bestDir, esKey, bestPart)
					return
				end
			end

			-- 2) Blackhole Trap: высокие мячи
			if S.UseBHT then
				local badState = findAny(getIV(char), BHT_SELF_BLOCK)
				if badState then
					bhtReason = "заблокирован: " .. badState
				else
					local bhtKey = getReadyKeyFor(char, BHT_NAMES)
					if bhtKey then
						bhtReason = "—"
						local res = planBHT(root, hum, balls, possessors)
						if res then
							showBhtDebug(res.center, res.ball, res.look)
							lastCast = now
							runCast(castBHT, res.jump, bhtKey)
						end
					else
						bhtReason = "нет скилла / кулдаун"
					end
				end
			else
				bhtReason = "выключен в меню"
			end
		end)

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function foldout(title)
			local btn, g
			btn = UI.Button(h, "▸ " .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = false
			return g
		end

		local function listToggles(holder, list)
			for _, e in ipairs(list) do
				UI.Toggle(holder, e.name, e.enabled, function(v)
					e.enabled = v
				end)
			end
		end

		-- бинд (клик -> нажми клавишу; Esc/Backspace — очистить)
		local listening = nil
		local bindBtn
		do
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = "Бинд вкл/выкл",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			bindBtn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			bindBtn.Parent = row
		end

		local function renderBind()
			bindBtn.Text = S.Key and S.Key.Name or "—"
			refreshOffText()
		end
		renderBind()
        		Persist.addId("bind/AutoESBHT/Key", "bind", function() return S.Key end,
			function(k) S.Key = k; renderBind() end)

		bindBtn.MouseButton1Click:Connect(function()
			listening = true
			bindBtn.Text = "Нажми клавишу…"
		end)

		-- клавиша занята другими скриптами/панелью?
		local function isReserved(key)
			if key == CONFIG.ToggleKey or key == CONFIG.CursorKey or key == Enum.KeyCode.Space then
				return true
			end
			local d = shared.AutoDribble and shared.AutoDribble.Settings
			if d and d.Key == key then
				return true
			end
			local t = shared.AutoTackle and shared.AutoTackle.Settings
			if t and t.Key == key then
				return true
			end
			local sl = shared.AutoSlide and shared.AutoSlide.Settings
			if sl and (sl.Key == key or sl.TackleKey == key) then
				return true
			end
			local sh = shared.AutoShot and shared.AutoShot.Settings
			if sh and (sh.Key == key or sh.LoftKey == key) then
				return true
			end
			return false
		end

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO ES / BHT")
		local mainToggle = UI.Toggle(h, "Auto ES / BHT", false, setEnabled)

		UI.Toggle(h, "Explosive Speed (ES)", S.UseES, function(v)
			S.UseES = v
			refreshInfo()
		end)
		UI.Toggle(h, "Blackhole Trap (BHT)", S.UseBHT, function(v)
			S.UseBHT = v
			if not v then
				bhtReason = "выключен в меню"
				hideBhtDebug()
			end
			refreshInfo()
		end)

		UI.Note(
			h,
			"ES — телепорт к мячу с прогнозом по пингу от позиции призрака LagGhost. BHT — ловит высокие мячи хитбоксом вокруг призрака, с прыжком или без. ES и BHT включаются по отдельности только здесь, горячих клавиш на них нет. Бинд на общий вкл/выкл: нажми кнопку выше, затем клавишу (Esc/Backspace — очистить). Скиллы берутся из Backpack, кнопка = Slot + 1."
		)

		------------------------------------------------------------
		-- UI: ПИНГ И ЗАДЕРЖКИ
		------------------------------------------------------------
		local gPing = foldout("Пинг и задержки")
		slider(gPing, "Множитель пинга", 0, 4, "PingMult", 2)
		slider(gPing, "Поправка к пингу (сек)", -0.2, 0.5, "PingOffset", 3)
		slider(gPing, "Мин. пинг (сек)", 0, 1, "PingMin", 3)
		slider(gPing, "Макс. пинг (сек)", 0.05, 2, "PingMax", 2)
		slider(gPing, "Макс. RTT для каста (сек)", 0.05, 1.5, "MaxPingExtra", 2)
		slider(gPing, "Задержка интерполяции (сек)", 0, 0.3, "InterpDelay", 3)
		slider(gPing, "Доп. задержка (сек)", -0.2, 0.3, "ExtraLatency", 3)
		slider(gPing, "Задержка кадра (сек)", 0, 0.1, "InputFrame", 3)

		------------------------------------------------------------
		-- UI: ОБЩЕЕ
		------------------------------------------------------------
		local gGen = foldout("Общее")
		slider(gGen, "Мин. интервал между кастами (сек)", 0.05, 3, "FireDelay", 2)
		slider(gGen, "Удержание клавиши (сек)", 0.01, 0.3, "KeyHold", 3)
		slider(gGen, "Держать взгляд после ES (сек)", 0, 0.6, "HoldExtra", 2)
		slider(gGen, "Высота центра над землёй (запас)", 0, 8, "GroundOffset", 2)
		toggle(gGen, "Не ловить мяч, если он у игрока", "CheckAnyPossession")
		slider(gGen, "Дистанция «мяч у игрока»", 1, 30, "PossessionNear", 1)
		slider(gGen, "Отскок мяча", 0, 1, "BallBounce", 2)
		slider(gGen, "Сопротивление мяча", 0, 2, "BallDrag", 3)

		------------------------------------------------------------
		-- UI: EXPLOSIVE SPEED
		------------------------------------------------------------
		local gEs = foldout("Explosive Speed")
		slider(gEs, "Дальность телепорта (студы)", 5, 100, "TpDist", 1)
		slider(gEs, "Полуширина хитбокса", 0.5, 20, "HalfW", 2)
		slider(gEs, "Полувысота хитбокса", 0.5, 20, "HalfH", 2)
		slider(gEs, "Полувысота при быстром мяче", 0.5, 20, "HalfHFast", 2)
		slider(gEs, "Быстрый мяч (студ/с)", 1, 200, "BallFastSpeed", 0)
		slider(gEs, "Быстрый я (студ/с)", 1, 100, "MeFastSpeed", 0)
		slider(gEs, "Досягаемость (студы)", 0, 15, "HitboxReach", 2)
		slider(gEs, "Мин. дистанция до мяча", 0, 30, "MinDist", 1)
		slider(gEs, "Задержка каста (сек)", 0, 0.5, "CastDelay", 3)
		slider(gEs, "Длительность ТП (× пинг)", 0, 4, "TpPingMult", 2)
		slider(gEs, "Доп. время ТП (сек)", -0.2, 0.5, "TpTimeExtra", 3)
		slider(gEs, "Мин. время ТП (сек)", 0.01, 0.5, "MinTpTime", 3)
		UI.Section(gEs, "НЕ ЛОВИТЬ МЯЧ, ЕСЛИ У НЕГО")
		listToggles(gEs, ES_BALL_BLOCK)

		------------------------------------------------------------
		-- UI: BLACKHOLE TRAP
		------------------------------------------------------------
		local gBht = foldout("Blackhole Trap: хитбокс и подъём")
		slider(gBht, "Хитбокс X", 1, 80, "BhtBoxX", 2)
		slider(gBht, "Хитбокс Y", 1, 100, "BhtBoxY", 2)
		slider(gBht, "Хитбокс Z", 1, 80, "BhtBoxZ", 2)
		slider(gBht, "Смещение хитбокса по Y", -20, 30, "BhtBoxOffY", 2)
		slider(gBht, "Высота подъёма скиллом", 0, 40, "BhtLiftHeight", 1)
		slider(gBht, "Время подъёма (сек)", 0.05, 2, "BhtLiftTime", 2)
		slider(gBht, "Время зависания (сек)", 0, 4, "BhtHoverTime", 2)
		slider(gBht, "Высота прыжка", 0, 20, "BhtJumpHeight", 2)
		slider(gBht, "Прыжок → скилл (сек)", 0, 0.6, "BhtJumpDelay", 3)

		local gBhtAim = foldout("Blackhole Trap: точность")
		slider(gBhtAim, "Макс. смещение поимки (сек)", 0.1, 3, "BhtMaxCatchOffset", 2)
		slider(gBhtAim, "Мин. высота мяча при поимке", 0, 40, "BhtMinBallHeight", 1)
		slider(gBhtAim, "Прыгать, если мяч выше", 0, 50, "BhtJumpMinHeight", 1)
		slider(gBhtAim, "Запас по размеру (студы)", -3, 8, "BhtSafety", 2)
		slider(gBhtAim, "Сжатие по скорости мяча", 0, 0.3, "BhtUncertainty", 3)
		slider(gBhtAim, "Макс. сжатие (студы)", 0, 15, "BhtMaxMargin", 1)
		slider(gBhtAim, "Запас по времени (сек)", 0, 0.3, "BhtSlack", 3)
		slider(gBhtAim, "Шаг проверки (сек)", 0.004, 0.1, "BhtEvalStep", 3)
		slider(gBhtAim, "Макс. ожидание прыжка (сек)", 0, 1, "BhtWaitJumpMax", 2)
		slider(gBhtAim, "Шаг ожидания (сек)", 0.01, 0.3, "BhtWaitStep", 2)
		toggle(gBhtAim, "Стоять на месте во время BHT", "BhtHoldStill")
		slider(gBhtAim, "Скольжение после остановки (сек)", 0, 0.4, "BhtStopSlide", 3)

		------------------------------------------------------------
		-- UI: УСЛОВИЯ И БЛОКИРОВКИ
		------------------------------------------------------------
		local gCond = foldout("Условия и блокировки")
		UI.Section(gCond, "НЕ ЖАТЬ ES/BHT, ЕСЛИ У МЕНЯ ЕСТЬ")
		listToggles(gCond, SELF_BLOCK)
		UI.Section(gCond, "НЕ ЖАТЬ BHT, ЕСЛИ У МЕНЯ ЕСТЬ")
		listToggles(gCond, BHT_SELF_BLOCK)
		UI.Section(gCond, "BHT: НЕ ЛОВИТЬ МЯЧ, ЕСЛИ У НЕГО")
		listToggles(gCond, BHT_BALL_BLOCK)

		------------------------------------------------------------
		-- UI: ВИЗУАЛ
		------------------------------------------------------------
		local gVis = foldout("Визуал")
		toggle(gVis, "Дебаг (точка встречи и хитбоксы)", "ShowDebug", function(v)
			if not v then
				hideAllDebug()
			end
		end)

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		local gGui = foldout("GUI ES / BHT")
		UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
			S.GuiShown = v
			Widget.Visible = v
		end)
		UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(gGui, "Сбросить позицию GUI", function()
			setWidgetPos(86, 66)
			xSlider.Set(86, true)
			ySlider.Set(66, true)
		end)
		UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")

		refreshInfo()

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						S.Key = nil
					elseif not isReserved(key) then
						S.Key = key
					end
					renderBind()
				end
				return
			end

			if gp or not S.Key then
				return
			end
			-- игнорируем виртуальные нажатия самого скрипта
			if injecting[input.KeyCode] then
				return
			end
			if input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			end
		end)

		-- отдаём наружу
		shared.AutoEsBht = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoEsBht)
	if not ok then
		warn("[Yokatta] AutoEsBht: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO DEFENCE SKILLS
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto ES / BHT
-- (и тоже ПЕРЕД разделом «СТАРТ»). Отдельный скрипт Auto Skills больше не нужен.
-- Призрак НЕ создаётся: берётся готовый workspace.lagghost (его делает LagGhost).
-- Горячих клавиш G (показ призрака) и H (Gate) больше нет: Gate — только в панели.
-- Всё настраивается из панели: радиусы, список и приоритет скиллов, хитбоксы, GUI.
------------------------------------------------------------
do
	local function initAutoDefence()
		local h = Holders.AutoUse
		if not h then
			return
		end
		-- UI.ClearPlaceholder(h) уже вызван блоком Auto Dribble.

		local player = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoDefence")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaDefenceVis")
			if v then
				v:Destroy()
			end
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil, -- бинд вкл/выкл
			JumpKey = nil, -- бинд Jump-макроса
			-- ModeKey = nil (М занята панелью; режим можно менять кнопкой или своим биндом)

			Mode = 1, -- режим проверки цели (см. MODES)
			UseJump = true, -- Jump-макрос для Ice Ground
			ManualAssist = true, -- если ты сам нажал скилл, скрипт берёт управление (поворот/движение)

			-- призрак (workspace.lagghost) и Gate
			Gate = true, -- жать скилл только когда призрак (= сервер) уже смотрит туда же
			GateTol = 0.985, -- совпадение взгляда (dot, 0.985 ≈ 10°)
			GateMax = 0.35, -- макс. ожидание призрака (сек)

			-- пинг и задержки
			PingMult = 1,
			PingOffset = 0,
			PingMin = 0,
			PingMax = 1,
			PingSmooth = 1,
			InputFrame = 0.017,
			OppUploadExtra = 0,
			MaxPingExtra = 0.4, -- если RTT больше, box-скиллы не кастуем

			-- клавиши
			KeyHold = 0.05,
			IceKeyHold = 0.03,

			-- box-скиллы (общее)
			CharHalf = 2,
			BoxHalfY = 2,
			CharHalfY = 2.5,
			BoxSafety = 2,
			CornerAngle = 45,
			BoxHoldExtra = 0.15,
			BoxSearchExtra = 8,
			BoxStopSlide = 0.08,
			SpinMoveLag = 0.1,

			-- chase-скиллы (общее)
			ClosingSpeed = 10,
			MaxInterceptT = 1.5,

			-- визуал
			ShowHitbox = false,

			-- GUI
			GuiShown = false,
		}

		------------------------------------------------------------
		-- СКИЛЛЫ (порядок в массиве = приоритет, меняется в панели)
		------------------------------------------------------------
		local STEAL = {
			kind = "steal", id = "steal", name = "Ignited Steal", short = "STEAL",
			enabled = true, radius = 45, fireDelay = 0.6,
			speed = 45, margin = 2, faceTime = 0.25,
		}
		local ICE = {
			kind = "ice", id = "ice", name = "Ice Ground", short = "ICE",
			enabled = true, radius = 40, fireDelay = 1.5,
			length = 31.5, width = 9.5, startOffset = 0,
			safetyF = 2, safetySide = 0.8,
			castDelay = 0.6, castDelayJump = 0.5,
			reaim = 0.5, holdExtra = 0.3, maxPredict = 1.2, moveFactor = 1,
		}
		local function box(t)
			t.kind = "box"
			t.enabled = true
			return t
		end
		local TOP = box({
			id = "top", name = "Spinning Top", short = "TOP",
			radius = 29.2, fireDelay = 2.5, castDelay = 0.3, activeTime = 1.0,
			half = 15, uncertainty = 0.15, moveSpeed = 0, maxDist = 0,
		})
		local RUNNING = box({
			id = "running", name = "Running Blaze", short = "BLAZE",
			radius = 22.1, fireDelay = 1.5, castDelay = 0.5, activeTime = 0,
			half = 10, uncertainty = 0.1, moveSpeed = 0, maxDist = 0,
		})
		local SPINCUT = box({
			id = "spincut", name = "Spinning Cut", short = "CUT",
			radius = 22.1, fireDelay = 1.5, castDelay = 0.5, activeTime = 0,
			half = 10, uncertainty = 0.1, moveSpeed = 8, maxDist = 0,
		})
		local EINSTAZ = box({
			id = "einstaz", name = "Einstaz", short = "EINS", dash = true,
			radius = 65, fireDelay = 2.5, castDelay = 0.5, activeTime = 0,
			half = 4, uncertainty = 0.15, moveSpeed = 0, maxDist = 0,
			dashDist = 50, extend = 5, dashTime = 0.3,
		})
		local MEGA = box({
			id = "mega", name = "Mega Quake", short = "MEGA",
			radius = 43.4, fireDelay = 2.0, castDelay = 1.0, activeTime = 0,
			half = 25, uncertainty = 0.25, moveSpeed = 0, maxDist = 20,
		})
		local KILLER = {
			kind = "chase", id = "killer", name = "Killer Slide", short = "KILL",
			enabled = true, radius = 20, fireDelay = 2.5,
			duration = 2, minDist = 0, speedMult = 0,
			back = 8, stop = 12, flee = 20,
		}
		local SPIRAL = {
			kind = "chase", id = "spiral", name = "Spiral Draw", short = "SPIR",
			enabled = true, radius = 130, fireDelay = 4.5,
			duration = 3.75, minDist = 10, speedMult = 10,
			back = 18, stop = 24, flee = 50,
		}

		local SKILLS = { STEAL, ICE, TOP, RUNNING, SPINCUT, EINSTAZ, MEGA, KILLER, SPIRAL }
		for _, cfg in ipairs(SKILLS) do
			cfg.last = 0
			cfg.step = "YokattaDef_" .. cfg.id
			pcall(function()
				RunService:UnbindFromRenderStep(cfg.step)
			end)
		end

		-- если у СВОЕГО персонажа есть любое из этих значений, скиллы не жмём
		local BLOCKING = {
			{ name = "ChargingKick", enabled = true },
			{ name = "Possession", enabled = true },
			{ name = "SlideTackle", enabled = true },
		}

		-- если у цели есть готовый скилл из списка (и включён режим), не кастуем
		local OPP = {
			{ name = "Exploisive Speed", enabled = true },
			{ name = "Explosive Speed", enabled = true },
			{ name = "Tsunami Boost", enabled = true },
			{ name = "Chop Dribble", enabled = true },
			{ name = "Flurry Dash", enabled = true },
			{ name = "Skystep", enabled = true },
			{ name = "Elastico", enabled = true },
			{ name = "Zero Reset Turn", enabled = true },
			{ name = "Illusion Ball", enabled = true },
			{ name = "Roulette", enabled = true },
		}

		local MODES = {
			{ name = "1: Всё", checkSkills = true, checkDribble = true },
			{ name = "2: Без дриблинга", checkSkills = true, checkDribble = false },
			{ name = "3: Без скиллов", checkSkills = false, checkDribble = true },
			{ name = "4: Без дриблинга/скиллов", checkSkills = false, checkDribble = false },
		}

		local NUM_KEYS = { "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero" }
		local SQRT2 = math.sqrt(2)

		------------------------------------------------------------
		-- СОСТОЯНИЕ
		------------------------------------------------------------
		local busy = false
		local castName = nil
		local lastCast = nil
		local casts = 0
		local castToken = 0
		local conns = {}
		local injecting = {}

		------------------------------------------------------------
		-- ПИНГ
		------------------------------------------------------------
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local pingSec = readPing() or player:GetNetworkPing()

		local function getPing()
			return math.max(0, pingSec * S.PingMult + S.PingOffset)
		end

		RunService.Heartbeat:Connect(function()
			local p = readPing()
			if p then
				p = math.clamp(p, S.PingMin, S.PingMax)
				pingSec = pingSec + (p - pingSec) * math.clamp(S.PingSmooth, 0.01, 1)
			end
		end)

		------------------------------------------------------------
		-- ПРИЗРАК (workspace.lagghost — создаётся другим скриптом)
		------------------------------------------------------------
		local LG
		local function getLG()
			if LG and LG.Parent then
				return LG
			end
			local m = workspace:FindFirstChild("lagghost")
			LG = m and m:FindFirstChild("HumanoidRootPart") or nil
			return LG
		end

		local function gateActive()
			return S.Gate and getLG() ~= nil
		end

		-- задержка от решения до отправки клавиши: кадр + (Gate) ожидание призрака ≈ пинг
		local function pressDelay()
			return S.InputFrame + (gateActive() and getPing() or 0)
		end

		-- через сколько секунд оппонент окажется там, где его увидит каст на сервере
		local function oppLead(castDelay)
			return pressDelay() + getPing() * 2 + S.OppUploadExtra + (castDelay or 0)
		end

		------------------------------------------------------------
		-- ПОМОЩНИКИ
		------------------------------------------------------------
		local function flat(v)
			return Vector3.new(v.X, 0, v.Z)
		end

		local function getRoot(char)
			return char and char:FindFirstChild("HumanoidRootPart")
		end

		local function getIV(char)
			return char and char:FindFirstChild("InstanceValue")
		end

		local function cdName(skillName)
			return (skillName:gsub("%s", "")) .. "Cooldown"
		end

		local function onCooldown(char, skillName)
			local iv = getIV(char)
			return iv ~= nil and iv:FindFirstChild(cdName(skillName)) ~= nil
		end

		local function hasPossession(char)
			local iv = getIV(char)
			return iv ~= nil and iv:FindFirstChild("Possession") ~= nil
		end

		local function findBlocking(char)
			local iv = getIV(char)
			if not iv then
				return nil
			end
			for _, e in ipairs(BLOCKING) do
				if e.enabled and iv:FindFirstChild(e.name) then
					return e.name
				end
			end
			return nil
		end

		local function getTool(plr, name)
			local bp = plr:FindFirstChild("Backpack")
			local tool = bp and bp:FindFirstChild(name)
			if not tool and plr.Character then
				tool = plr.Character:FindFirstChild(name)
			end
			return tool
		end

		local function isOpponent(plr)
			if plr == player then
				return false
			end
			local mine = player:FindFirstChild("MatchTeam")
			local theirs = plr:FindFirstChild("MatchTeam")
			if not mine or not theirs then
				return false
			end
			return mine.Value ~= theirs.Value
		end

		local function readSlot(tool)
			local s = tool:FindFirstChild("Slot")
			if s and s:IsA("ValueBase") then
				return tonumber(s.Value)
			end
			return tonumber(tool:GetAttribute("Slot"))
		end

		-- KeyCode скилла, если он есть и не на кулдауне
		local function getReadySkillKey(char, skillName)
			local tool = getTool(player, skillName)
			if not tool then
				return nil
			end
			if onCooldown(char, skillName) then
				return nil
			end
			local slot = readSlot(tool)
			if not slot then
				return nil
			end
			local keyName = NUM_KEYS[slot + 1]
			return keyName and Enum.KeyCode[keyName] or nil
		end

		local function opponentHasReadySkill(plr)
			for _, e in ipairs(OPP) do
				if e.enabled and getTool(plr, e.name) and not onCooldown(plr.Character, e.name) then
					return true
				end
			end
			return false
		end

		local function dribbleAvailable(char)
			local iv = getIV(char)
			if not iv then
				return true
			end
			local dribbleCd = iv:FindFirstChild("DribbleCooldown")
			local feintCd = iv:FindFirstChild("FeintCooldown")
			local liftCd = iv:FindFirstChild("LiftCooldown")
			local safe = dribbleCd ~= nil or (feintCd ~= nil and liftCd ~= nil)
			return not safe
		end

		-- мяч: workspace.Messi["/e ball"] (кэшируем)
		local ballCache
		local function getBall()
			if ballCache and ballCache.Parent then
				return ballCache
			end
			local messi = workspace:FindFirstChild("Messi") or workspace:FindFirstChild("Messi", true)
			ballCache = messi and messi:FindFirstChild("/e ball")
			return ballCache
		end

		local function getBallPart()
			local ball = getBall()
			if not ball then
				return nil
			end
			if ball:IsA("BasePart") then
				return ball
			end
			return ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart", true)
		end

		local function ballHasIFrames()
			local ball = getBall()
			local ballIV = ball and ball:FindFirstChild("InstanceValue")
			return ballIV ~= nil and ballIV:FindFirstChild("IFrames") ~= nil
		end

		local function hasIFrames(char)
			if ballHasIFrames() then
				return true
			end
			local iv = getIV(char)
			return iv ~= nil and iv:FindFirstChild("IFrames") ~= nil
		end

		local function targetPasses(target)
			local m = MODES[S.Mode]
			if m.checkSkills and opponentHasReadySkill(target) then
				return false
			end
			if m.checkDribble and dribbleAvailable(target.Character) then
				return false
			end
			if hasIFrames(target.Character) then
				return false
			end
			return true
		end

		local function findPossessionTarget(root, radius)
			local target, targetRoot, bestDist
			for _, plr in ipairs(Players:GetPlayers()) do
				if isOpponent(plr) and plr.Character then
					local r = getRoot(plr.Character)
					if r and hasPossession(plr.Character) then
						local d = (r.Position - root.Position).Magnitude
						if d <= radius and (not bestDist or d < bestDist) then
							target, targetRoot, bestDist = plr, r, d
						end
					end
				end
			end
			return target, targetRoot, bestDist
		end

		local function predictPos(targetRoot, t)
			return targetRoot.Position + flat(targetRoot.AssemblyLinearVelocity) * t
		end

		local function solveIntercept(D, V, Sp)
			local a = V:Dot(V) - Sp * Sp
			local b = 2 * D:Dot(V)
			local c = D:Dot(D)
			if math.abs(a) < 1e-6 then
				if math.abs(b) < 1e-6 then
					return nil
				end
				local t = -c / b
				return t > 0 and t or nil
			end
			local disc = b * b - 4 * a * c
			if disc < 0 then
				return nil
			end
			local sq = math.sqrt(disc)
			local t1 = (-b - sq) / (2 * a)
			local t2 = (-b + sq) / (2 * a)
			local best
			for _, t in ipairs({ t1, t2 }) do
				if t > 0 and (not best or t < best) then
					best = t
				end
			end
			return best
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ
		------------------------------------------------------------
		local DGui = create("ScreenGui", {
			Name = "YokattaAutoDefence",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 992,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		DGui.Parent = parent

		local widgetPos = { x = 14, y = 55 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(372, 150),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = DGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "Auto Defence: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			idle = Color3.fromRGB(90, 160, 255),
			blocked = Color3.fromRGB(255, 170, 0),
			warn = Color3.fromRGB(255, 170, 0),
		}
		local CHIP_COLORS = {
			ready = Color3.fromRGB(0, 190, 95),
			cd = Color3.fromRGB(220, 60, 60),
			off = C.Off,
			none = Color3.fromRGB(255, 170, 0),
		}
		local CHIP_TEXT = { ready = "", cd = " КД", off = " выкл", none = " нет" }

		local chips = {}
		for _, cfg in ipairs(SKILLS) do
			local chip = create("TextLabel", {
				Size = UDim2.fromOffset(66, 20),
				BackgroundColor3 = CHIP_COLORS.off,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = Color3.new(1, 1, 1),
				Text = cfg.short,
			}, { corner(UDim.new(0, 5)) })
			chip.Parent = Widget
			chips[cfg] = chip
		end

		local infos = {}
		for i = 1, 3 do
			local l = create("TextLabel", {
				Size = UDim2.new(1, -24, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.TextMid,
				Text = "—",
			})
			l.Parent = Widget
			infos[i] = l
		end

		local CHIPS_PER_ROW = 5
		local function layoutWidget()
			for i, cfg in ipairs(SKILLS) do
				local col = (i - 1) % CHIPS_PER_ROW
				local row = math.floor((i - 1) / CHIPS_PER_ROW)
				chips[cfg].Position = UDim2.fromOffset(12 + col * 70, 34 + row * 24)
			end
			local rows = math.ceil(#SKILLS / CHIPS_PER_ROW)
			local y = 34 + rows * 24 + 4
			for i, l in ipairs(infos) do
				l.Position = UDim2.fromOffset(12, y + (i - 1) * 18)
			end
			Widget.Size = UDim2.fromOffset(372, y + #infos * 18 + 8)
		end
		layoutWidget()

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local function setText(label, text)
			if label.Text ~= text then
				label.Text = text
			end
		end

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		-- off | none | cd | ready
		local function skillState(cfg)
			if not cfg.enabled then
				return "off"
			end
			if not getTool(player, cfg.name) then
				return "none"
			end
			if onCooldown(player.Character, cfg.name) then
				return "cd"
			end
			return "ready"
		end

		local function refreshWidget()
			for _, cfg in ipairs(SKILLS) do
				local st = skillState(cfg)
				local chip = chips[cfg]
				chip.BackgroundColor3 = CHIP_COLORS[st]
				setText(chip, cfg.short .. CHIP_TEXT[st])
			end
			local gateText = "ВЫКЛ"
			if S.Gate then
				gateText = getLG() and "ВКЛ" or "нет призрака"
			end
			setText(
				infos[1],
				string.format("Режим %d | Jump: %s | Gate: %s", S.Mode, S.UseJump and "ВКЛ" or "ВЫКЛ", gateText)
			)
			setText(infos[2], string.format("пинг %d мс | касты: %d", math.floor(getPing() * 1000 + 0.5), casts))
			setText(infos[3], "Последний: " .. (lastCast or "—"))
		end

		local xSlider, ySlider
		local function setWidgetPos(x, y)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- ВИЗУАЛ: хитбокс скилла и точка прицела
		------------------------------------------------------------
		local visFolder = Instance.new("Folder")
		visFolder.Name = "YokattaDefenceVis"
		visFolder.Parent = workspace

		local function visPart(shape, color)
			local p = Instance.new("Part")
			if shape then
				p.Shape = shape
			end
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.Material = Enum.Material.Neon
			p.Color = color
			p.Transparency = 1
			p.Parent = visFolder
			return p
		end

		local dbgBox = visPart(nil, Color3.fromRGB(0, 255, 255))
		local dbgBall = visPart(Enum.PartType.Ball, Color3.fromRGB(255, 160, 0))
		dbgBall.Size = Vector3.new(2, 2, 2)

		local function dbgHide()
			dbgBox.Transparency = 1
			dbgBall.Transparency = 1
		end

		local function dbgShow(cf, size, point)
			if not S.ShowHitbox then
				dbgHide()
				return
			end
			if cf then
				dbgBox.Size = size
				dbgBox.CFrame = cf
				dbgBox.Transparency = 0.8
			else
				dbgBox.Transparency = 1
			end
			if point then
				dbgBall.Position = point
				dbgBall.Transparency = 0.2
			else
				dbgBall.Transparency = 1
			end
		end

		------------------------------------------------------------
		-- ВВОД / СБРОС КАСТОВ
		------------------------------------------------------------
		local function pressKey(key, hold)
			if not VIM then
				return
			end
			injecting[key] = (injecting[key] or 0) + 1
			VIM:SendKeyEvent(true, key, false, game)
			task.wait(hold or S.KeyHold)
			VIM:SendKeyEvent(false, key, false, game)
			task.delay(0.15, function()
				injecting[key] = (injecting[key] or 1) - 1
				if injecting[key] <= 0 then
					injecting[key] = nil
				end
			end)
		end

		local function drive(hum, state, moveDir)
			hum:Move(state == "idle" and Vector3.zero or moveDir, false)
		end

		local function resetCasts()
			castToken += 1
			for c in pairs(conns) do
				c:Disconnect()
				conns[c] = nil
			end
			for _, cfg in ipairs(SKILLS) do
				pcall(function()
					RunService:UnbindFromRenderStep(cfg.step)
				end)
			end
			busy = false
			castName = nil
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					hum:Move(Vector3.zero, false)
				end)
				hum.AutoRotate = true
			end
			dbgHide()
		end

		local function beginCast(cfg)
			busy = true
			castName = cfg.name
			lastCast = cfg.name
			casts += 1
			return castToken
		end

		-- запуск каста с защитой: при ошибке сбрасываем busy, чтобы скрипт не завис
		local function runCast(fn, ...)
			task.spawn(function(...)
				local ok, err = pcall(fn, ...)
				if not ok then
					warn("[Yokatta] AutoDefence: " .. tostring(err))
					resetCasts()
				end
			end, ...)
		end

		------------------------------------------------------------
		-- Ignited Steal
		------------------------------------------------------------
		local function planSteal(cfg, root, targetRoot)
			local pd = pressDelay()
			local myVel = flat(root.AssemblyLinearVelocity)
			local oppVel = flat(targetRoot.AssemblyLinearVelocity)

			local myStart = root.Position + myVel * pd
			local oppStart = targetRoot.Position + oppVel * oppLead(0)

			local D = flat(oppStart - myStart)
			local t = solveIntercept(D, oppVel, cfg.speed)
			if not (t and t <= 1) then
				return nil
			end

			local aimPoint = oppStart + oppVel * t
			local aimDir = flat(aimPoint - myStart)
			if aimDir.Magnitude > cfg.radius + cfg.margin then
				return nil
			end
			if aimDir.Magnitude < 0.1 then
				return nil
			end
			return aimDir.Unit
		end

		local function waitGhostSynced(root, dir)
			if not gateActive() then
				return
			end
			local t0 = os.clock()
			local maxWait = math.min(getPing() * 2 + 0.05, S.GateMax)
			repeat
				if dir and root.Parent then
					root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
				end
				local g = getLG()
				if g then
					local want = flat(root.CFrame.LookVector)
					local have = flat(g.CFrame.LookVector)
					if
						have.Magnitude > 0.01
						and want.Magnitude > 0.01
						and have.Unit:Dot(want.Unit) >= S.GateTol
					then
						return
					end
				end
				RunService.Heartbeat:Wait()
			until os.clock() - t0 >= maxWait
		end

		local function castSteal(cfg, dir, keyCode)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not root then
				return
			end

			local tok = beginCast(cfg)
			if hum then
				hum.AutoRotate = false
			end

			local startT = os.clock()
			local pressT = nil
			local conn
			conn = RunService.RenderStepped:Connect(function()
				local now = os.clock()
				if
					tok ~= castToken
					or not root.Parent
					or now - startT > 3
					or (pressT and now - pressT > cfg.faceTime + getPing())
				then
					conn:Disconnect()
					conns[conn] = nil
					if tok == castToken then
						busy = false
						dbgHide()
						if hum and hum.Parent then
							hum.AutoRotate = true
						end
					end
					return
				end
				root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
				dbgShow(
					CFrame.lookAt(root.Position + dir * (cfg.radius / 2), root.Position + dir * cfg.radius),
					Vector3.new(4, 4, cfg.radius),
					nil
				)
			end)
			conns[conn] = true

			root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
			task.wait()
			waitGhostSynced(root, dir)
			if tok ~= castToken then
				return
			end
			pressT = os.clock()
			pressKey(keyCode, S.KeyHold)
		end

		------------------------------------------------------------
		-- Ice Ground
		------------------------------------------------------------
		local function hitsIce(cfg, origin, dir, point)
			local rel = flat(point - origin)
			local f = rel:Dot(dir)
			local lateral = (rel - dir * f).Magnitude
			local minF = cfg.startOffset - S.CharHalf + cfg.safetyF
			local maxF = cfg.startOffset + cfg.length + S.CharHalf - cfg.safetyF
			local maxL = cfg.width / 2 + S.CharHalf - cfg.safetySide
			return f >= minF and f <= maxF and lateral <= maxL
		end

		local function canReachIce(cfg, origin, point)
			local rel = flat(point - origin)
			if rel.Magnitude < 0.1 then
				return false, nil
			end
			local dir = rel.Unit
			return hitsIce(cfg, origin, dir, point), dir
		end

		local function iceDelay(cfg)
			return S.UseJump and cfg.castDelayJump or cfg.castDelay
		end

		local function planIce(cfg, root, targetRoot)
			local castDelay = iceDelay(cfg)
			local t = oppLead(castDelay)
			if t > cfg.maxPredict then
				return nil
			end
			local myVel = flat(root.AssemblyLinearVelocity)
			local origin = root.Position + myVel * (pressDelay() + castDelay) * cfg.moveFactor
			local future = predictPos(targetRoot, t)
			local ok, dir = canReachIce(cfg, origin, future)
			if not ok then
				return nil
			end
			return dir
		end

		local function castIce(cfg, targetRoot, dir, keyCode)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not root then
				return
			end

			local tok = beginCast(cfg)
			if hum then
				hum.AutoRotate = false
			end

			local castDelay = iceDelay(cfg)
			local currentDir = dir

			root.CFrame = CFrame.lookAt(root.Position, root.Position + currentDir)
			task.wait()
			waitGhostSynced(root, currentDir)
			if tok ~= castToken then
				return
			end

			local pressT = os.clock()
			pressKey(keyCode, S.IceKeyHold)

			-- макрос: сразу прыжок (заряд 0.5 вместо 0.6)
			if S.UseJump then
				pressKey(Enum.KeyCode.Space, S.IceKeyHold)
			end
			if tok ~= castToken then
				return
			end

			local conn
			conn = RunService.Heartbeat:Connect(function()
				local ping = getPing()
				local elapsed = os.clock() - pressT

				if
					tok ~= castToken
					or elapsed > castDelay + cfg.holdExtra + ping
					or not root.Parent
					or not targetRoot.Parent
				then
					conn:Disconnect()
					conns[conn] = nil
					if tok == castToken then
						if hum and hum.Parent then
							hum.AutoRotate = true
						end
						busy = false
						dbgHide()
					end
					return
				end

				-- в окне довода: если оппонент сменил направление, смотрим в его новую позицию
				local future = nil
				if elapsed <= cfg.reaim then
					local left = math.max(castDelay - elapsed, 0)
					local remain = left + ping * 2 + S.OppUploadExtra
					future = predictPos(targetRoot, remain)
					local origin = root.Position + flat(root.AssemblyLinearVelocity) * left * cfg.moveFactor

					if not hitsIce(cfg, origin, currentDir, future) then
						local ok, newDir = canReachIce(cfg, origin, future)
						if ok then
							currentDir = newDir
						end
					end
				end

				root.CFrame = CFrame.lookAt(root.Position, root.Position + currentDir)
				dbgShow(
					CFrame.lookAt(
						root.Position + currentDir * (cfg.startOffset + cfg.length / 2),
						root.Position + currentDir * (cfg.startOffset + cfg.length)
					),
					Vector3.new(cfg.width, 4, cfg.length),
					future
				)
			end)
			conns[conn] = true
		end

		------------------------------------------------------------
		-- CHASE: Spiral Draw / Killer Slide
		------------------------------------------------------------
		local function castChase(cfg, keyCode)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) then
				return
			end

			local tok = beginCast(cfg)
			hum.AutoRotate = false
			local baseWalk = hum.WalkSpeed

			if keyCode then
				pressKey(keyCode, S.KeyHold)
				if tok ~= castToken then
					return
				end
			end

			local startT = os.clock()
			local duration = cfg.duration + getPing()
			local finished = false

			local function finish()
				if finished then
					return
				end
				finished = true
				pcall(function()
					RunService:UnbindFromRenderStep(cfg.step)
				end)
				if tok == castToken then
					drive(hum, "idle", Vector3.zero)
					if hum.Parent then
						hum.AutoRotate = true
					end
					busy = false
				end
			end

			pcall(function()
				RunService:UnbindFromRenderStep(cfg.step)
			end)
			RunService:BindToRenderStep(cfg.step, Enum.RenderPriority.Last.Value, function()
				if
					tok ~= castToken
					or os.clock() - startT > duration
					or not root.Parent
					or hum.Health <= 0
					or hasPossession(char)
				then
					finish()
					return
				end

				local part = getBallPart()
				if not part then
					drive(hum, "idle", Vector3.zero)
					return
				end

				local ping = getPing()
				local rtt = ping * 2
				local myVel = flat(root.AssemblyLinearVelocity)
				local ballVel = flat(part.AssemblyLinearVelocity)

				local myPos = root.Position + myVel * ping
				local ballPos = part.Position + ballVel * (rtt + S.OppUploadExtra)

				local toBall = flat(ballPos - myPos)
				local dist = toBall.Magnitude
				if dist < 0.1 then
					drive(hum, "idle", Vector3.zero)
					return
				end
				local dirToBall = toBall.Unit

				root.CFrame = CFrame.lookAt(root.Position, root.Position + dirToBall)

				local state, moveDir = "idle", Vector3.zero

				if ballHasIFrames() then
					local closing = ballVel:Dot(-dirToBall)
					if (closing > S.ClosingSpeed and dist < cfg.flee) or dist < cfg.back then
						state, moveDir = "back", -dirToBall
					elseif dist > cfg.stop then
						state, moveDir = "fwd", dirToBall
					end
				else
					local speed
					if cfg.speedMult and cfg.speedMult > 0 then
						speed = (hum.WalkSpeed >= baseWalk * 5) and hum.WalkSpeed or baseWalk * cfg.speedMult
					else
						speed = math.max(hum.WalkSpeed, myVel.Magnitude)
					end
					local aimDir = dirToBall
					local t = solveIntercept(toBall, ballVel, speed)
					if t and t <= S.MaxInterceptT then
						local aimVec = flat(ballPos + ballVel * t - myPos)
						if aimVec.Magnitude > 0.1 then
							aimDir = aimVec.Unit
						end
					end
					state, moveDir = "fwd", aimDir
				end

				drive(hum, state, moveDir)
			end)
		end

		------------------------------------------------------------
		-- BOX: Spinning Top / Running Blaze / Spinning Cut / Einstaz / Mega Quake
		------------------------------------------------------------
		local function activeOf(cfg)
			if cfg.dash then
				return cfg.dashTime * (1 + cfg.extend / math.max(1, cfg.dashDist))
			end
			return cfg.activeTime
		end

		local function cornerLook(dir, sign)
			local a = math.rad(S.CornerAngle) * sign
			return CFrame.Angles(0, a, 0):VectorToWorldSpace(dir)
		end

		local function hitsBox(me, look, point, half, margin)
			local rel = flat(point - me)
			local right = look:Cross(Vector3.yAxis)
			local lim = half + margin
			return math.abs(rel:Dot(look)) <= lim and math.abs(rel:Dot(right)) <= lim
		end

		-- Einstaz: рывок по прямой с постоянной скоростью, целимся в точку встречи
		local function einstazIntercept(cfg, me, targetRoot, lead)
			local speed = cfg.dashDist / math.max(0.01, cfg.dashTime)
			local vel = flat(targetRoot.AssemblyLinearVelocity)
			local p0 = targetRoot.Position + vel * lead
			local tau = solveIntercept(flat(p0 - me), vel, speed)
			if not tau then
				return nil
			end
			local aim = p0 + vel * tau
			return flat(aim - me), tau, vel
		end

		local function planEinstaz(cfg, root, targetRoot)
			local ping = getPing()
			if ping * 2 > S.MaxPingExtra then
				return false
			end
			local lead = oppLead(cfg.castDelay)

			local myVel = flat(root.AssemblyLinearVelocity)
			local me = root.Position + myVel * S.BoxStopSlide

			local toAim, tau, vel = einstazIntercept(cfg, me, targetRoot, lead)
			if not toAim or toAim.Magnitude < 0.1 then
				return false
			end

			local future = predictPos(targetRoot, lead)
			if math.abs(future.Y - me.Y) > cfg.half + S.CharHalfY then
				return false
			end

			local margin = cfg.half + S.CharHalf - S.BoxSafety - vel.Magnitude * (lead + tau) * cfg.uncertainty
			if margin <= 0 then
				return false
			end

			return toAim.Magnitude <= cfg.dashDist + cfg.extend + margin
		end

		local function planBox(cfg, root, targetRoot)
			if cfg.dash then
				return planEinstaz(cfg, root, targetRoot)
			end
			local ping = getPing()
			if ping * 2 > S.MaxPingExtra then
				return false
			end
			local t = oppLead(cfg.castDelay)

			if cfg.maxDist and cfg.maxDist > 0 and flat(targetRoot.Position - root.Position).Magnitude > cfg.maxDist then
				return false
			end

			local myVel = flat(root.AssemblyLinearVelocity)
			local origin = root.Position + myVel * S.BoxStopSlide
			local future = predictPos(targetRoot, t)
			local oppVel = flat(targetRoot.AssemblyLinearVelocity)

			local me = origin
			if cfg.moveSpeed > 0 then
				local toFuture = flat(future - origin)
				if toFuture.Magnitude > 0.1 then
					local travel = math.min(cfg.moveSpeed * math.max(cfg.castDelay - S.SpinMoveLag, 0), toFuture.Magnitude)
					me = origin + toFuture.Unit * travel
				end
			end

			if math.abs(future.Y - me.Y) > S.BoxHalfY + S.CharHalfY then
				return false
			end

			local toTarget = flat(future - me)
			if toTarget.Magnitude < 0.1 then
				return true
			end

			local look = cornerLook(toTarget.Unit, 1)
			local margin = S.CharHalf - S.BoxSafety - oppVel.Magnitude * t * cfg.uncertainty
			return hitsBox(me, look, future, cfg.half, margin)
		end

		local function getAimPoint(root, cfg, remain)
			local _, tRoot = findPossessionTarget(root, cfg.radius + S.BoxSearchExtra)
			if tRoot then
				return predictPos(tRoot, remain)
			end
			local part = getBallPart()
			if part then
				return part.Position + flat(part.AssemblyLinearVelocity) * remain
			end
			return nil
		end

		-- keyCode == nil: игрок сам нажал скилл, мы только берём управление
		local function castBox(cfg, keyCode)
			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) then
				return
			end

			local tok = beginCast(cfg)
			hum.AutoRotate = false

			local startT = os.clock()
			local pressT = (keyCode == nil) and startT or nil
			local sign = nil
			local active = activeOf(cfg)
			local finished = false

			local function finish()
				if finished then
					return
				end
				finished = true
				pcall(function()
					RunService:UnbindFromRenderStep(cfg.step)
				end)
				if tok == castToken then
					drive(hum, "idle", Vector3.zero)
					if hum.Parent then
						hum.AutoRotate = true
					end
					busy = false
					dbgHide()
				end
			end

			local function step()
				if tok ~= castToken then
					finish()
					return
				end
				local now = os.clock()
				local ping = getPing()
				local elapsed = pressT and (now - pressT) or nil
				local total = cfg.castDelay + active + S.BoxHoldExtra + ping

				if
					(elapsed and elapsed > total)
					or (now - startT > total + 2)
					or not root.Parent
					or hum.Health <= 0
					or hasPossession(char)
				then
					finish()
					return
				end

				local remain
				if elapsed then
					remain = math.max(cfg.castDelay - elapsed, 0) + ping * 2 + S.OppUploadExtra
				else
					remain = oppLead(cfg.castDelay)
				end

				if cfg.dash then
					local _, tRoot = findPossessionTarget(root, cfg.radius + S.BoxSearchExtra)
					local dir
					if tRoot then
						local dashing = elapsed and elapsed >= cfg.castDelay
						local lead = dashing and ping or remain
						local toHit = einstazIntercept(cfg, root.Position, tRoot, lead)
						if toHit and toHit.Magnitude > 0.1 then
							dir = toHit.Unit
						end
					end
					if not dir then
						local fallback = getAimPoint(root, cfg, remain)
						if fallback then
							local v = flat(fallback - root.Position)
							if v.Magnitude > 0.1 then
								dir = v.Unit
							end
						end
					end
					if dir then
						root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
						local L = cfg.dashDist + cfg.extend
						dbgShow(
							CFrame.lookAt(root.Position + dir * (L / 2), root.Position + dir * L),
							Vector3.new(cfg.half * 2, 4, L),
							nil
						)
					end
					drive(hum, "idle", Vector3.zero)
					return
				end

				local aim = getAimPoint(root, cfg, remain)

				local toAim = Vector3.zero
				if aim then
					toAim = flat(aim - root.Position)
					if toAim.Magnitude > 0.1 then
						local dir = toAim.Unit
						if not sign then
							local cur = flat(root.CFrame.LookVector)
							local a = cornerLook(dir, 1)
							local b = cornerLook(dir, -1)
							sign = (cur:Dot(a) >= cur:Dot(b)) and 1 or -1
						end
						local look = cornerLook(dir, sign)
						root.CFrame = CFrame.lookAt(root.Position, root.Position + look)
					end
				end
				dbgShow(root.CFrame, Vector3.new(cfg.half * 2, S.BoxHalfY * 2, cfg.half * 2), aim)

				-- двигаться можно только в Spinning Cut, и только после нажатия
				if cfg.moveSpeed > 0 and elapsed and elapsed >= S.SpinMoveLag and toAim.Magnitude >= 1 then
					drive(hum, "fwd", toAim.Unit)
				else
					drive(hum, "idle", Vector3.zero)
				end
			end

			pcall(function()
				RunService:UnbindFromRenderStep(cfg.step)
			end)
			RunService:BindToRenderStep(cfg.step, Enum.RenderPriority.Last.Value, step)

			-- сразу повернуться углом к цели ещё до нажатия
			step()
			if finished or tok ~= castToken then
				return
			end

			if keyCode then
				waitGhostSynced(root)
				if finished or tok ~= castToken then
					return
				end
				pressT = os.clock()
				pressKey(keyCode, S.KeyHold)
			end
		end

		------------------------------------------------------------
		-- ПОПЫТКИ КАСТА (по типам скиллов)
		------------------------------------------------------------
		local function trySteal(cfg, char, root, now)
			local key = getReadySkillKey(char, cfg.name)
			if not key then
				return false
			end
			local target, targetRoot = findPossessionTarget(root, cfg.radius)
			if not target or not targetPasses(target) then
				return false
			end
			local dir = planSteal(cfg, root, targetRoot)
			if not dir then
				return false
			end
			cfg.last = now
			runCast(castSteal, cfg, dir, key)
			return true
		end

		local function tryIce(cfg, char, root, now)
			local key = getReadySkillKey(char, cfg.name)
			if not key then
				return false
			end
			local target, targetRoot = findPossessionTarget(root, cfg.radius)
			if not target or not targetPasses(target) then
				return false
			end
			local dir = planIce(cfg, root, targetRoot)
			if not dir then
				return false
			end
			cfg.last = now
			runCast(castIce, cfg, targetRoot, dir, key)
			return true
		end

		local function tryBox(cfg, char, root, now)
			if hasPossession(char) then
				return false
			end
			local key = getReadySkillKey(char, cfg.name)
			if not key then
				return false
			end
			local target, targetRoot = findPossessionTarget(root, cfg.radius)
			if target and targetPasses(target) and planBox(cfg, root, targetRoot) then
				cfg.last = now
				runCast(castBox, cfg, key)
				return true
			end
			return false
		end

		local function tryChase(cfg, char, root, now)
			if hasPossession(char) then
				return false
			end
			local key = getReadySkillKey(char, cfg.name)
			if not key then
				return false
			end

			local lead = oppLead(0)
			local target, bestDist
			for _, plr in ipairs(Players:GetPlayers()) do
				if isOpponent(plr) and plr.Character and hasPossession(plr.Character) then
					local r = getRoot(plr.Character)
					if r then
						local predicted = r.Position + flat(r.AssemblyLinearVelocity) * lead
						local d = flat(predicted - root.Position).Magnitude
						if d <= cfg.radius and (not bestDist or d < bestDist) then
							target, bestDist = plr, d
						end
					end
				end
			end
			if not target or bestDist < cfg.minDist then
				return false
			end
			if not targetPasses(target) then
				return false
			end

			cfg.last = now
			runCast(castChase, cfg, key)
			return true
		end

		local TRY = { steal = trySteal, ice = tryIce, box = tryBox, chase = tryChase }

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "Auto Defence: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				setStatus("on", "Auto Defence: ВКЛ")
			else
				resetCasts()
				refreshOffText()
			end
			refreshWidget()
		end
		refreshOffText()

		------------------------------------------------------------
		-- ОСНОВНОЙ ЦИКЛ (скиллы проверяются по приоритету сверху вниз)
		------------------------------------------------------------
		local infoTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			infoTimer += dt
			if infoTimer >= 0.25 then
				infoTimer = 0
				refreshWidget()
			end

			if not S.Enabled then
				return
			end
			if not VIM then
				setStatus("warn", "Нет VirtualInputManager")
				return
			end
			if busy then
				setStatus("danger", "Каст: " .. tostring(castName))
				return
			end

			local char = player.Character
			local root = getRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) or hum.Health <= 0 then
				setStatus("idle", "Нет персонажа")
				return
			end

			local blockedBy = findBlocking(char)
			if blockedBy then
				setStatus("blocked", "Заблокирован: " .. blockedBy)
				return
			end

			setStatus("on", "Auto Defence: ВКЛ")

			local now = os.clock()
			for _, cfg in ipairs(SKILLS) do
				if cfg.enabled and now - cfg.last >= cfg.fireDelay then
					if TRY[cfg.kind](cfg, char, root, now) then
						return
					end
				end
			end
		end)

		-- респавн: сбрасываем касты
		player.CharacterAdded:Connect(resetCasts)
		player.CharacterRemoving:Connect(resetCasts)

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		-- слайдер на поле конкретного скилла
		local function cs(holder, cfg, key, text, min, max, decimals)
			return UI.Slider(holder, text, min, max, cfg[key], decimals, function(v)
				cfg[key] = v
			end)
		end

		local function foldout(title, open)
			local btn, g
			btn = UI.Button(h, (open and "▾ " or "▸ ") .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = open == true
			return g
		end

		local function listToggles(holder, list)
			for _, e in ipairs(list) do
				UI.Toggle(holder, e.name, e.enabled, function(v)
					e.enabled = v
				end)
			end
		end

		-- бинды: клик -> нажми клавишу; Esc/Backspace очищают
		local listening = nil -- { field, render }

		local function isReserved(key, field)
			if key == CONFIG.ToggleKey or key == CONFIG.CursorKey or key == Enum.KeyCode.Space then
				return true
			end
			for _, name in ipairs({ "AutoDribble", "AutoTackle", "AutoSlide", "AutoShot", "AutoEsBht" }) do
				local st = shared[name] and shared[name].Settings
				if st then
					for _, f in ipairs({ "Key", "LoftKey", "TackleKey" }) do
						if st[f] == key then
							return true
						end
					end
				end
			end
			for _, f in ipairs({ "Key", "JumpKey", "ModeKey" }) do
				if f ~= field and S[f] == key then
					return true
				end
			end
			return false
		end

		local function bindRow(labelText, field)
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = labelText,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row

			local function render()
				btn.Text = S[field] and S[field].Name or "—"
			end
			render()
            			Persist.addId("bind/AutoDefence/" .. field, "bind", function() return S[field] end,
				function(k) S[field] = k; render(); refreshOffText(); refreshWidget() end)

			btn.MouseButton1Click:Connect(function()
				if listening then
					listening.render()
				end
				listening = { field = field, render = render }
				btn.Text = "Нажми клавишу…"
			end)
			return render
		end

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO DEFENCE SKILLS")
		local mainToggle = UI.Toggle(h, "Auto Defence Skills", false, setEnabled)
		bindRow("Бинд вкл/выкл", "Key")

		local jumpToggle = UI.Toggle(h, "Jump-макрос (Ice Ground)", S.UseJump, function(v)
			S.UseJump = v
			refreshWidget()
		end)
		bindRow("Бинд Jump-макроса", "JumpKey")

		local modeBtn
		modeBtn = UI.Button(h, "Режим цели: " .. MODES[S.Mode].name, function()
			S.Mode = S.Mode % #MODES + 1
			modeBtn.Text = "Режим цели: " .. MODES[S.Mode].name
			refreshWidget()
		end)
        		Persist.addId("AutoDefence/Mode", "choice", function() return S.Mode end, function(v)
			if MODES[v] then S.Mode = v; modeBtn.Text = "Режим цели: " .. MODES[v].name; refreshWidget() end
		end)
		bindRow("Бинд смены режима", "ModeKey")

		toggle(h, "Ручной каст: перехватывать управление", "ManualAssist")
		toggle(h, "Gate: ждать призрака перед нажатием", "Gate", refreshWidget)

		UI.Note(
			h,
			"Защитные скиллы против соперника с мячом (Possession). Скилл жмётся с упреждением по пингу от позиции призрака LagGhost (workspace.lagghost) — сам призрак здесь не создаётся. Скиллы проверяются сверху вниз по приоритету (список ниже). Режим цели: 1 — не кастовать, если у соперника есть готовый скилл или дриблинг; 2 — только скиллы; 3 — только дриблинг; 4 — без проверок. Ручной каст: если ты сам нажал Box/Chase-скилл, скрипт берёт на себя поворот и движение. Бинды: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить)."
		)

		------------------------------------------------------------
		-- UI: ПРИОРИТЕТ И СПИСОК СКИЛЛОВ
		------------------------------------------------------------
		local gOrder = foldout("Приоритет и список скиллов", true)
		UI.Note(
			gOrder,
			"Сверху — самый высокий приоритет. ▲/▼ меняют порядок, кнопка ВКЛ/ВЫКЛ разрешает или запрещает скилл. Радиус и параметры каждого скилла — в разделах «Скилл: …» ниже."
		)

		local orderHolder
		local rebuildOrder

		local function moveSkill(i, d)
			local j = i + d
			if j < 1 or j > #SKILLS then
				return
			end
			SKILLS[i], SKILLS[j] = SKILLS[j], SKILLS[i]
			rebuildOrder()
			layoutWidget()
			refreshWidget()
		end

		rebuildOrder = function()
			if orderHolder then
				orderHolder:Destroy()
			end
			orderHolder = UI.Group(gOrder)
			for i, cfg in ipairs(SKILLS) do
				local row = create("Frame", {
					LayoutOrder = i,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundColor3 = C.Card,
					BorderSizePixel = 0,
				}, {
					corner(UDim.new(0, 10)),
					create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
				})
				row.Parent = orderHolder

				create("TextLabel", {
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -150, 1, 0),
					BackgroundTransparency = 1,
					Text = i .. ". " .. cfg.name,
					TextColor3 = C.TextDark,
					Font = Enum.Font.GothamMedium,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				}).Parent = row

				local function mini(text, w, off, onClick)
					local b = create("TextButton", {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -off, 0.5, 0),
						Size = UDim2.fromOffset(w, 24),
						BackgroundColor3 = C.Sidebar,
						Text = text,
						TextColor3 = C.TextDark,
						Font = Enum.Font.GothamBold,
						TextSize = 12,
						AutoButtonColor = false,
					}, { corner(UDim.new(0, 8)) })
					b.Parent = row
					b.MouseButton1Click:Connect(onClick)
					return b
				end

				mini("▼", 30, 10, function()
					moveSkill(i, 1)
				end)
				mini("▲", 30, 46, function()
					moveSkill(i, -1)
				end)
				local tgl
				tgl = mini(cfg.enabled and "ВКЛ" or "ВЫКЛ", 48, 82, function()
					cfg.enabled = not cfg.enabled
					tgl.Text = cfg.enabled and "ВКЛ" or "ВЫКЛ"
					tgl.BackgroundColor3 = cfg.enabled and CHIP_COLORS.ready or CHIP_COLORS.off
					refreshWidget()
				end)
				tgl.TextColor3 = Color3.new(1, 1, 1)
				tgl.BackgroundColor3 = cfg.enabled and CHIP_COLORS.ready or CHIP_COLORS.off
			end
		end
		rebuildOrder()
        		Persist.addId("AutoDefence/skills", "data", function()
			local t = {}
			for _, c in ipairs(SKILLS) do t[#t + 1] = { id = c.id, on = c.enabled } end
			return t
		end, function(t)
			local byId, used, new = {}, {}, {}
			for _, c in ipairs(SKILLS) do byId[c.id] = c end
			for _, e in ipairs(t) do
				local c = byId[e.id]
				if c and not used[c] then c.enabled = e.on ~= false; used[c] = true; new[#new + 1] = c end
			end
			for _, c in ipairs(SKILLS) do if not used[c] then new[#new + 1] = c end end
			for i, c in ipairs(new) do SKILLS[i] = c end
			rebuildOrder(); layoutWidget(); refreshWidget()
		end)

		------------------------------------------------------------
		-- UI: УСЛОВИЯ И БЛОКИРОВКИ
		------------------------------------------------------------
		do
			local gCond = foldout("Условия и блокировки")
			UI.Section(gCond, "НЕ ЖАТЬ СКИЛЛЫ, ЕСЛИ У МЕНЯ ЕСТЬ")
			listToggles(gCond, BLOCKING)
			UI.Section(gCond, "У ЦЕЛИ ГОТОВЫЙ СКИЛЛ (УЧИТЫВАЕТСЯ В РЕЖИМАХ 1 И 2)")
			listToggles(gCond, OPP)
		end

		------------------------------------------------------------
		-- UI: ПИНГ, ПРИЗРАК, КЛАВИШИ
		------------------------------------------------------------
		do
			local gPing = foldout("Пинг и задержки")
			slider(gPing, "Множитель пинга", 0, 4, "PingMult", 2)
			slider(gPing, "Поправка к пингу (сек)", -0.2, 0.5, "PingOffset", 3)
			slider(gPing, "Сглаживание пинга (1 = нет)", 0.05, 1, "PingSmooth", 2)
			slider(gPing, "Мин. пинг (сек)", 0, 1, "PingMin", 3)
			slider(gPing, "Макс. пинг (сек)", 0.05, 2, "PingMax", 2)
			slider(gPing, "Задержка кадра (сек)", 0, 0.1, "InputFrame", 3)
			slider(gPing, "Доп. задержка оппонента (сек)", 0, 0.5, "OppUploadExtra", 3)
			slider(gPing, "Макс. RTT для box-скиллов (сек)", 0.05, 1.5, "MaxPingExtra", 2)
			slider(gPing, "Удержание клавиши скилла (сек)", 0.01, 0.3, "KeyHold", 3)
			slider(gPing, "Удержание клавиши Ice / прыжка (сек)", 0.01, 0.3, "IceKeyHold", 3)

			local gGate = foldout("Призрак и Gate")
			toggle(gGate, "Gate: ждать призрака", "Gate", refreshWidget)
			slider(gGate, "Совпадение взгляда (dot)", 0.5, 1, "GateTol", 3)
			slider(gGate, "Макс. ожидание призрака (сек)", 0.05, 1, "GateMax", 2)
			UI.Note(gGate, "Призрак берётся из workspace.lagghost (создаётся другим скриптом). Без призрака Gate не ждёт.")
		end

		------------------------------------------------------------
		-- UI: ОБЩИЕ ПАРАМЕТРЫ BOX / CHASE
		------------------------------------------------------------
		do
			local gBoxG = foldout("Box-скиллы: общее (хитбокс)")
			slider(gBoxG, "Половина размера персонажа (XZ)", 0, 6, "CharHalf", 2)
			slider(gBoxG, "Полувысота box-хитбокса", 0.5, 20, "BoxHalfY", 2)
			slider(gBoxG, "Полувысота персонажа", 0, 8, "CharHalfY", 2)
			slider(gBoxG, "Запас безопасности (студы)", -2, 8, "BoxSafety", 2)
			slider(gBoxG, "Угол поворота (градусы)", 0, 90, "CornerAngle", 0)
			slider(gBoxG, "Держать управление после каста (сек)", 0, 1, "BoxHoldExtra", 2)
			slider(gBoxG, "Доп. радиус поиска цели (студы)", 0, 40, "BoxSearchExtra", 1)
			slider(gBoxG, "Скольжение после остановки (сек)", 0, 0.4, "BoxStopSlide", 3)
			slider(gBoxG, "Задержка движения Spinning Cut (сек)", 0, 0.5, "SpinMoveLag", 3)

			local gChaseG = foldout("Chase-скиллы: общее")
			slider(gChaseG, "Скорость сближения мяча (студ/с)", 0, 60, "ClosingSpeed", 1)
			slider(gChaseG, "Макс. время перехвата (сек)", 0.2, 5, "MaxInterceptT", 2)
		end

		------------------------------------------------------------
		-- UI: ПАРАМЕТРЫ КАЖДОГО СКИЛЛА (радиус, хитбокс, тайминги)
		------------------------------------------------------------
		do
			-- по умолчанию порядок разделов = исходный порядок скиллов
			local order = { STEAL, ICE, TOP, RUNNING, SPINCUT, EINSTAZ, MEGA, KILLER, SPIRAL }
			for _, cfg in ipairs(order) do
				local g = foldout("Скилл: " .. cfg.name)
				cs(g, cfg, "radius", "Радиус применения (студы)", 1, 200, 1)
				cs(g, cfg, "fireDelay", "Мин. интервал между кастами (сек)", 0.1, 10, 2)

				if cfg.kind == "steal" then
					cs(g, cfg, "speed", "Скорость скилла (студ/с)", 5, 150, 1)
					cs(g, cfg, "margin", "Запас по хитбоксу (студы)", 0, 10, 1)
					cs(g, cfg, "faceTime", "Держать поворот после нажатия (сек)", 0, 1, 2)
				elseif cfg.kind == "ice" then
					UI.Section(g, "ХИТБОКС ЛЬДА")
					cs(g, cfg, "length", "Длина (студы)", 5, 80, 1)
					cs(g, cfg, "width", "Ширина (студы)", 1, 40, 1)
					cs(g, cfg, "startOffset", "Начало льда от персонажа", -10, 20, 1)
					cs(g, cfg, "safetyF", "Запас по длине", -2, 8, 2)
					cs(g, cfg, "safetySide", "Запас по ширине", -2, 8, 2)
					UI.Section(g, "ТАЙМИНГИ")
					cs(g, cfg, "castDelay", "Задержка каста (сек)", 0.1, 2, 2)
					cs(g, cfg, "castDelayJump", "Задержка каста с прыжком (сек)", 0.1, 2, 2)
					cs(g, cfg, "reaim", "Окно доворота (сек)", 0, 2, 2)
					cs(g, cfg, "holdExtra", "Держать поворот после каста (сек)", 0, 1, 2)
					cs(g, cfg, "maxPredict", "Макс. упреждение (сек)", 0.2, 3, 2)
					cs(g, cfg, "moveFactor", "Учёт моего движения (0 = стою)", 0, 2, 2)
				elseif cfg.kind == "box" then
					UI.Section(g, "ХИТБОКС")
					cs(g, cfg, "half", "Половина стороны (студы)", 1, 60, 2)
					cs(g, cfg, "uncertainty", "Сжатие по скорости цели", 0, 1, 3)
					if cfg.maxDist ~= nil and cfg.id == "mega" then
						cs(g, cfg, "maxDist", "Макс. дистанция до цели (0 = выкл)", 0, 80, 1)
					end
					UI.Section(g, "ТАЙМИНГИ")
					cs(g, cfg, "castDelay", "Задержка каста (сек)", 0.05, 3, 2)
					if cfg.dash then
						cs(g, cfg, "dashDist", "Дальность рывка (студы)", 5, 150, 1)
						cs(g, cfg, "extend", "Запас дальности рывка (студы)", 0, 30, 1)
						cs(g, cfg, "dashTime", "Длительность рывка (сек)", 0.05, 2, 3)
					else
						cs(g, cfg, "activeTime", "Время действия (сек)", 0, 5, 2)
					end
					if cfg.id == "spincut" then
						cs(g, cfg, "moveSpeed", "Скорость движения (студ/с)", 0, 60, 1)
					end
				elseif cfg.kind == "chase" then
					cs(g, cfg, "duration", "Длительность (сек)", 0.5, 10, 2)
					cs(g, cfg, "minDist", "Мин. дистанция до цели", 0, 60, 1)
					cs(g, cfg, "back", "Отходить, если ближе (студы)", 0, 60, 1)
					cs(g, cfg, "stop", "Идти вперёд, если дальше (студы)", 0, 80, 1)
					cs(g, cfg, "flee", "Отходить при сближении ближе (студы)", 0, 120, 1)
					if cfg.id == "spiral" then
						cs(g, cfg, "speedMult", "Множитель скорости (0 = выкл)", 0, 20, 1)
					end
				end
			end
		end

		------------------------------------------------------------
		-- UI: ВИЗУАЛ
		------------------------------------------------------------
		do
			local gVis = foldout("Визуал (хитбокс)")
			toggle(gVis, "Показывать хитбокс скилла и точку прицела", "ShowHitbox", function(v)
				if not v then
					dbgHide()
				end
			end)
			UI.Note(gVis, "Хитбокс и точка показываются только во время каста.")
		end

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		do
			local gGui = foldout("GUI Auto Defence")
			UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
				S.GuiShown = v
				Widget.Visible = v
			end)
			UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
				WScale.Scale = v
			end)
			xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
				setWidgetPos(v, widgetPos.y)
			end)
			ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
				setWidgetPos(widgetPos.x, v)
			end)
			UI.Button(gGui, "Сбросить позицию GUI", function()
				setWidgetPos(14, 55)
				xSlider.Set(14, true)
				ySlider.Set(55, true)
			end)
			UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")
		end

		refreshWidget()

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local l = listening
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						S[l.field] = nil
					elseif not isReserved(key, l.field) then
						S[l.field] = key
					end
					l.render()
					refreshOffText()
					refreshWidget()
				end
				return
			end

			if gp then
				return
			end
			-- игнорируем виртуальные нажатия самого скрипта
			if injecting[input.KeyCode] then
				return
			end

			-- ручной каст: игрок нажал скилл сам, скрипт берёт управление
			if S.Enabled and S.ManualAssist and not busy then
				local char = player.Character
				if char and not findBlocking(char) then
					for _, cfg in ipairs(SKILLS) do
						if cfg.enabled and (cfg.kind == "box" or cfg.kind == "chase") then
							local k = getReadySkillKey(char, cfg.name)
							if k and input.KeyCode == k then
								cfg.last = os.clock()
								runCast(cfg.kind == "box" and castBox or castChase, cfg, nil)
								return
							end
						end
					end
				end
			end

			if S.Key and input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			elseif S.JumpKey and input.KeyCode == S.JumpKey then
				jumpToggle.Set(not jumpToggle.Get())
			elseif S.ModeKey and input.KeyCode == S.ModeKey then
				S.Mode = S.Mode % #MODES + 1
				modeBtn.Text = "Режим цели: " .. MODES[S.Mode].name
				refreshWidget()
			end
		end)

		-- отдаём наружу
		shared.AutoDefence = {
			Settings = S,
			Skills = SKILLS,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoDefence)
	if not ok then
		warn("[Yokatta] AutoDefence: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO GOAL (W.I.P)
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto Defence Skills
-- (и тоже ПЕРЕД разделом «СТАРТ»). Отдельный скрипт AutoGoal больше не нужен.
-- Режимы: AIM (только наводит камеру) / SEMI (наводит и отпускает M1 по Power)
--         / AUTO (мяч в хитбоксе -> сам зажимает M1, наводит и отпускает).
-- Крученые удары (LEFT / RIGHT) с самообучением, память: AutoGoal_<UserId>.json
-- Сфера-цель по глубине: смещается НАЗАД (в сторону задней стенки ворот),
-- направление и величина настраиваются в панели («Сфера-цель»).
------------------------------------------------------------
do
	local function initAutoGoal()
		local h = Holders.AutoUse
		if not h then
			return
		end
		-- UI.ClearPlaceholder(h) уже вызван блоком Auto Dribble.

		local player = Players.LocalPlayer
		local HttpService = game:GetService("HttpService")
		local okVim, VIM = pcall(function()
			return game:GetService("VirtualInputManager")
		end)
		if not okVim then
			VIM = nil
		end

		-- чистим остатки старой версии
		do
			local o = parent:FindFirstChild("YokattaAutoGoal")
			if o then
				o:Destroy()
			end
			local v = workspace:FindFirstChild("YokattaGoalVis")
			if v then
				v:Destroy()
			end
			pcall(function()
				RunService:UnbindFromRenderStep("YokattaAutoGoal")
			end)
		end

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Mode = 1, -- 1: AIM | 2: SEMI | 3: AUTO
			GoalChoice = 1, -- 1: AUTO (противоположная MatchTeam) | 2: RED | 3: BLUE
			CurveIdx = 1, -- 1: OFF | 2: LEFT | 3: RIGHT

			-- бинды (Esc/Backspace очищают)
			Key = nil, -- вкл/выкл
			ModeKey = nil, -- смена режима
			GoalKey = nil, -- смена цели
			CurveKey = nil, -- смена закрутки
			GoalAddKey = nil, -- +1 гол вручную
			GoalSubKey = nil, -- -1 гол (H занят Auto M1 Tackle)

			-- мяч и условия
			BallName = "Football",
			RequirePossession = false,
			HitboxX = 14,
			HitboxY = 12,
			HitboxZ = 14,

			-- удар
			ShotPower = 100,
			MaxHold = 3,
			ShotCooldown = 1.0,
			AimAfter = 0.15,
			AimCamera = true,

			-- ворота
			GoalYOffset = 5,
			GoalW = 39,
			GoalH = 16,
			GoalDepth = 2,

			-- сфера-цель
			InsetH = 2.5,
			FarInsetH = 3,
			NearSideShift = 9,
			NearDepthShift = 5, -- насколько сфера уходит в глубину при остром угле
			DepthInvert = true, -- true: глубина «назад» (от стрелка, к задней стенке)
			InsetVNear = 2,
			InsetVFar = 5,
			BlockRadius = 10,
			RangeSafety = 0.92,

			-- крутка
			CurveTurn = 45,
			CurveRefDist = 150,
			CurvePower = 1.6,
			CurveLearnGain = 0.5,
			CurveMaxStep = 8,
			CurveTurnMin = 5,
			CurveTurnMax = 90,
			CurveOtherWeight = 0.25,

			-- самообучение
			Learn = true,
			ShotWindow = 6,
			TuneBandwidth = 25,
			TuneLatBandwidth = 0.3,
			PriorWeight = 2,
			MaxCorrection = 8,
			MaxOffCorrection = 8,
			MaxSamples = 300,
			OutlierY = 20,

			-- визуал
			ShowSpheres = true,
			ShowBestOnly = false,
			SphereSize = 2,
			SphereTransp = 0.2,
			ShowHitbox = true,
			HitboxTransp = 0.9,
			ShowGoalBox = true,
			GoalBoxTransp = 0.85,
			ShowPath = true,

			-- GUI
			GuiShown = false,
		}

		local MODES = { "AIM", "SEMI", "AUTO" }
		local MODE_DESC = {
			"AIM: ты заряжаешь M1, скрипт наводит",
			"SEMI: ты зажимаешь M1, скрипт отпускает",
			"AUTO: всё делает скрипт",
		}
		local GOAL_CHOICES = { "AUTO", "RED", "BLUE" }
		local CURVES = {
			{ name = "OFF", cv = 0 },
			{ name = "LEFT", cv = 1 },
			{ name = "RIGHT", cv = -1 },
		}

		local VALUES_FOLDER = "InstanceValue"
		local INFO_FOLDER = "PlayerInfo"
		local SAVE_FILE = "AutoGoal_" .. tostring(player.UserId) .. ".json"
		local LEGACY_FILE = "AutoGoal_tune.json"

		local FIELDS = {
			BIG = {
				RED = Vector3.new(-17524.4, 793.8, 241.9),
				BLUE = Vector3.new(-18516, 793.8, 241.9),
			},
			SMALL = {
				RED = Vector3.new(-20316.6, 1.2, 708.5),
				BLUE = Vector3.new(-20808.0, 1.2, 708.5),
			},
		}
		local ARC = { { 0, 0 }, { 40, 2 }, { 80, 6 }, { 120, 12 }, { 160, 20 } }
		local RANGE = { { 0, 156 }, { 22.5, 167.5 }, { 30, 179 }, { 45, 163.5 }, { 60, 135 } }

		------------------------------------------------------------
		-- УТИЛИТЫ
		------------------------------------------------------------
		local function interp(tbl, x)
			if x <= tbl[1][1] then
				return tbl[1][2]
			end
			for i = 2, #tbl do
				local a, b = tbl[i - 1], tbl[i]
				if x <= b[1] then
					return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1])
				end
			end
			return tbl[#tbl][2]
		end

		local function distToSegment(p, a, b)
			local ab = b - a
			local t = math.clamp((p - a):Dot(ab) / math.max(ab:Dot(ab), 1e-6), 0, 1)
			return (p - (a + ab * t)).Magnitude
		end

		local function valuesFolder()
			local c = player.Character
			return (c and c:FindFirstChild(VALUES_FOLDER)) or player:FindFirstChild(VALUES_FOLDER)
		end

		local function flag(parentObj, name)
			local o = parentObj and parentObj:FindFirstChild(name)
			if not o then
				return false
			end
			if o:IsA("BoolValue") then
				return o.Value
			end
			return true
		end

		local function readInfo(name)
			local c = player.Character
			local pi = player:FindFirstChild(INFO_FOLDER) or (c and c:FindFirstChild(INFO_FOLDER))
			local v = pi and pi:FindFirstChild(name)
			if v and v:IsA("ValueBase") then
				return v.Value
			end
			return nil
		end

		local function myColor()
			local mt = player:FindFirstChild("MatchTeam")
			return mt and string.upper(tostring(mt.Value)) or nil
		end

		local function roundTo(x, n)
			local m = 10 ^ (n or 2)
			return math.floor(x * m + 0.5) / m
		end

		------------------------------------------------------------
		-- ВОРОТА
		------------------------------------------------------------
		local GOALS, ALL = {}, {}
		for fname, f in pairs(FIELDS) do
			local g = {}
			for color, pos in pairs(f) do
				g[color] = { field = fname, color = color, base = pos, pos = pos }
			end
			for color, gl in pairs(g) do
				local other = g[color == "RED" and "BLUE" or "RED"]
				local d = other.base - gl.base
				gl.forward = Vector3.new(d.X, 0, d.Z).Unit
				gl.right = gl.forward:Cross(Vector3.yAxis)
				table.insert(ALL, gl)
			end
			GOALS[fname] = g
		end

		local function applyGoalOffset()
			for _, g in ipairs(ALL) do
				g.pos = g.base + Vector3.new(0, S.GoalYOffset, 0)
			end
		end
		applyGoalOffset()

		local function pickGoal(origin)
			local nearest, nd
			for _, g in ipairs(ALL) do
				local d = (g.pos - origin).Magnitude
				if not nd or d < nd then
					nearest, nd = g, d
				end
			end
			local field = GOALS[nearest.field]
			local choice = GOAL_CHOICES[S.GoalChoice]
			if choice ~= "AUTO" then
				return field[choice]
			end
			local mc = myColor()
			if mc == "RED" then
				return field.BLUE
			end
			if mc == "BLUE" then
				return field.RED
			end
			return nearest
		end

		------------------------------------------------------------
		-- САМООБУЧЕНИЕ: данные (отдельный файл на каждого игрока)
		------------------------------------------------------------
		local tune = { version = 4, name = player.Name, samples = {}, goals = 0, shots = 0, curveTurn = {} }

		local function save()
			pcall(function()
				if writefile then
					writefile(SAVE_FILE, HttpService:JSONEncode(tune))
				end
			end)
		end

		local function loadFile(path)
			local ok, d = pcall(function()
				if isfile and isfile(path) then
					return HttpService:JSONDecode(readfile(path))
				end
			end)
			if ok and type(d) == "table" and type(d.samples) == "table" then
				return d
			end
			return nil
		end

		do
			local d = loadFile(SAVE_FILE)
			local migrated = false
			if not d then
				d = loadFile(LEGACY_FILE)
				migrated = d ~= nil
			end
			if d then
				tune.samples, tune.goals, tune.shots = d.samples, d.goals or 0, d.shots or 0
				if type(d.curveTurn) == "table" then
					tune.curveTurn = d.curveTurn
				end
				if migrated then
					save()
				end
			end
		end

		local function kernel(s, dist, lat, absLat)
			local kd = (dist - s.dist) / S.TuneBandwidth
			local sl = s.lat
			local kl = 0
			if sl then
				if absLat then
					kl = (math.abs(sl) - math.abs(lat)) / S.TuneLatBandwidth
				else
					kl = (sl - lat) / S.TuneLatBandwidth
				end
			end
			return math.exp(-(kd * kd + kl * kl)) * (s.w or 1)
		end

		local function arcComp(dist, lat, cv)
			local base = interp(ARC, dist)
			if not S.Learn then
				return base
			end
			local wsum, vsum = S.PriorWeight, base * S.PriorWeight
			for _, s in ipairs(tune.samples) do
				if s.arc then
					local w = kernel(s, dist, lat, true)
					if (s.cv or 0) ~= cv then
						w *= S.CurveOtherWeight
					end
					wsum += w
					vsum += s.arc * w
				end
			end
			return vsum / wsum
		end

		-- боковая поправка только для ПРЯМЫХ ударов
		local function offComp(dist, lat, cv)
			if not S.Learn or cv ~= 0 then
				return 0
			end
			local wsum, vsum = S.PriorWeight, 0
			for _, s in ipairs(tune.samples) do
				if s.off and (s.cv or 0) == 0 then
					local w = kernel(s, dist, lat, false)
					wsum += w
					vsum += s.off * w
				end
			end
			return vsum / wsum
		end

		------------------------------------------------------------
		-- КРУТКА
		------------------------------------------------------------
		local function curveTurn(cv)
			if cv == 0 then
				return 0
			end
			return tune.curveTurn[tostring(cv)] or S.CurveTurn
		end

		local function turnAt(cv, turnDeg, u)
			return cv * math.rad(turnDeg) * (u / S.CurveRefDist) ^ S.CurvePower
		end

		local function curveSolve(cv, turnDeg, d)
			if cv == 0 then
				return 0, d
			end
			local function chord(s)
				local X, Y = 0, 0
				local n = 24
				local ds = s / n
				for i = 1, n do
					local th = turnAt(cv, turnDeg, (i - 0.5) * ds)
					X += math.sin(th) * ds
					Y += math.cos(th) * ds
				end
				return X, Y
			end
			local lo, hi = d, d * 1.8
			for _ = 1, 14 do
				local mid = (lo + hi) / 2
				local X, Y = chord(mid)
				if math.sqrt(X * X + Y * Y) < d then
					lo = mid
				else
					hi = mid
				end
			end
			local s = (lo + hi) / 2
			local X, Y = chord(s)
			return math.atan2(X, Y), s
		end

		------------------------------------------------------------
		-- ВРАГИ
		------------------------------------------------------------
		local function enemyRoots()
			local list = {}
			local myTeam = player:FindFirstChild("MatchTeam")
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Character then
					local root = p.Character:FindFirstChild("HumanoidRootPart")
					if root then
						local mt = p:FindFirstChild("MatchTeam")
						local same = myTeam and mt and tostring(mt.Value) == tostring(myTeam.Value)
						if not same then
							table.insert(list, root)
						end
					end
				end
			end
			return list
		end

		------------------------------------------------------------
		-- ОЦЕНКА УГЛОВ
		------------------------------------------------------------
		local function evaluate(origin, goal, foes, cv)
			local rel0 = origin - goal.pos
			local lateral = rel0:Dot(goal.right)
			local dGoal = Vector3.new(rel0.X, 0, rel0.Z).Magnitude
			local lat = math.clamp(lateral / math.max(dGoal, 1), -1, 1)
			local steep = math.abs(lat)
			local vInset = interp({ { 0, S.InsetVNear }, { 150, S.InsetVFar } }, dGoal)
			local farK = math.clamp(dGoal / 150, 0, 1)
			local turn = curveTurn(cv)

			-- forward смотрит от ворот в поле. DepthInvert = true -> сфера уходит НАЗАД
			-- (от стрелка, к задней стенке ворот), false -> старое поведение (вперёд).
			local depthSign = S.DepthInvert and 1 or -1

			local keeper, kd = nil, 30
			for _, r in ipairs(foes) do
				local d = r.Position - goal.pos
				d = Vector3.new(d.X, 0, d.Z).Magnitude
				if d < kd then
					keeper, kd = r, d
				end
			end

			local halfW = S.GoalW / 2
			local result = {}
			for _, side in ipairs({ -1, 1 }) do
				local near = lateral * side > 0
				local inner = S.InsetH + farK * S.FarInsetH
				local depth = 0
				if near then
					inner += steep * S.NearSideShift
					depth = steep * S.NearDepthShift
				end

				local y = S.GoalH / 2 - vInset
				local lp0 = side * (halfW - inner)
				local pt0 = goal.pos + goal.right * lp0 + Vector3.yAxis * y + goal.forward * depth * depthSign
				local dist0 = (pt0 - origin).Magnitude

				local off = offComp(dist0, lat, cv)
				local lim = halfW - 1
				local lp = math.clamp(lp0 + off, -lim, lim)
				off = lp - lp0

				local pt = goal.pos + goal.right * lp + Vector3.yAxis * y + goal.forward * depth * depthSign
				local v = pt - origin
				local dist = v.Magnitude
				local flatLen = Vector3.new(v.X, 0, v.Z).Magnitude
				local flat = Vector3.new(v.X, 0, v.Z).Unit

				local phi, sArc = curveSolve(cv, turn, flatLen)
				local right = flat:Cross(Vector3.yAxis)
				local left = -right
				local flatAim = flat * math.cos(phi) + right * math.sin(phi)

				local arc = arcComp(dist, lat, cv)
				local pitch = math.deg(math.asin(math.clamp(v.Y / dist, -1, 1))) + arc
				local dir = flatAim * math.cos(math.rad(pitch)) + Vector3.yAxis * math.sin(math.rad(pitch))
				local reach = interp(RANGE, math.clamp(pitch, 0, 60)) * S.RangeSafety
				local pathDist = dist * (sArc / math.max(flatLen, 1))

				local so = (origin - goal.pos):Dot(goal.forward)
				local sp = (pt - goal.pos):Dot(goal.forward)
				local planePt = pt
				if so > 0 and sp < so then
					local t = so / (so - sp)
					planePt = origin + (pt - origin) * t
				end

				local score = -math.huge
				if pathDist <= reach then
					score = 100 - dist * 0.2
					for _, r in ipairs(foes) do
						if distToSegment(r.Position, origin, pt) < S.BlockRadius then
							score -= 40
						end
					end
					if keeper then
						score += math.min((keeper.Position - pt).Magnitude, 30)
					end
					score -= math.deg(math.acos(math.clamp(math.abs(flat:Dot(goal.forward)), 0, 1))) * 0.3
					score -= math.abs(math.deg(phi)) * 0.15
				end
				table.insert(result, {
					pt = pt, planePt = planePt, dir = dir, dist = dist, arc = arc,
					off = off, lat = lat, score = score, goal = goal, near = near,
					cv = cv, turn = turn, phi = phi, sArc = sArc, flatAim = flatAim, left = left,
				})
			end
			table.sort(result, function(a, b)
				return a.score > b.score
			end)
			return result
		end

		------------------------------------------------------------
		-- ВИЗУАЛ
		------------------------------------------------------------
		local visFolder = Instance.new("Folder")
		visFolder.Name = "YokattaGoalVis"
		visFolder.Parent = workspace

		local function makePart(shape, size)
			local p = Instance.new("Part")
			p.Shape = shape
			p.Size = size
			p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
			p.Material = Enum.Material.Neon
			p.Transparency = 1
			p.Parent = visFolder
			return p
		end

		local spheres = {
			makePart(Enum.PartType.Ball, Vector3.one * 2),
			makePart(Enum.PartType.Ball, Vector3.one * 2),
		}
		local hitBox = makePart(Enum.PartType.Block, Vector3.new(S.HitboxX, S.HitboxY, S.HitboxZ))
		hitBox.Color = Color3.fromRGB(0, 170, 255)
		local goalBox = makePart(Enum.PartType.Block, Vector3.new(S.GoalW, S.GoalH, S.GoalDepth))
		goalBox.Color = Color3.fromRGB(255, 220, 60)

		local PATH_DOTS = 14
		local pathDots = {}
		for i = 1, PATH_DOTS do
			local p = makePart(Enum.PartType.Ball, Vector3.one * 1.2)
			p.Color = Color3.fromRGB(255, 255, 255)
			pathDots[i] = p
		end

		local function hideVisuals()
			for _, s in ipairs(spheres) do
				s.Transparency = 1
			end
			for _, d in ipairs(pathDots) do
				d.Transparency = 1
			end
			hitBox.Transparency = 1
			goalBox.Transparency = 1
		end

		local function showPath(origin, aim)
			local n = PATH_DOTS
			local ds = aim.sArc / n
			local pos = origin
			local heading = aim.flatAim
			local left = Vector3.yAxis:Cross(heading)
			for i = 1, n do
				local th = turnAt(aim.cv, aim.turn, (i - 0.5) * ds)
				local step = (heading * math.cos(th) + left * math.sin(th)) * ds
				pos += Vector3.new(step.X, 0, step.Z)
				local k = i / n
				pathDots[i].Position = Vector3.new(pos.X, origin.Y + (aim.pt.Y - origin.Y) * k, pos.Z)
				pathDots[i].Transparency = 0.3
			end
		end

		------------------------------------------------------------
		-- GUI-ВИДЖЕТ
		------------------------------------------------------------
		local GGui = create("ScreenGui", {
			Name = "YokattaAutoGoal",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 991,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		GGui.Parent = parent

		local widgetPos = { x = 86, y = 40 } -- проценты экрана
		local WStroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		local WScale = create("UIScale", { Scale = 1 })

		local Widget = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100),
			Size = UDim2.fromOffset(300, 128),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = S.GuiShown,
		}, { corner(UDim.new(0, 12)), WStroke })
		WScale.Parent = Widget
		Widget.Parent = GGui

		local Dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Off,
			BorderSizePixel = 0,
		}, { round() })
		Dot.Parent = Widget

		local StatusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = "Auto Goal: ВЫКЛ",
		})
		StatusLabel.Parent = Widget

		local infoLabels, infoCache = {}, {}
		for i = 1, 4 do
			local l = create("TextLabel", {
				Position = UDim2.fromOffset(12, 32 + (i - 1) * 20),
				Size = UDim2.new(1, -24, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.TextMid,
				Text = "—",
			})
			l.Parent = Widget
			infoLabels[i] = l
			infoCache[i] = ""
		end

		local STATUS_COLORS = {
			off = C.Off,
			on = Color3.fromRGB(0, 200, 100),
			danger = Color3.fromRGB(230, 40, 150),
			idle = Color3.fromRGB(90, 160, 255),
			warn = Color3.fromRGB(255, 170, 0),
		}

		local currentStatus, lastStatusText = nil, ""
		local function setStatus(name, text)
			if currentStatus == name and lastStatusText == text then
				return
			end
			currentStatus, lastStatusText = name, text
			StatusLabel.Text = text
			Dot.BackgroundColor3 = STATUS_COLORS[name]
			WStroke.Color = STATUS_COLORS[name]
		end

		local function setInfo(i, text)
			if infoCache[i] == text then
				return
			end
			infoCache[i] = text
			infoLabels[i].Text = text
		end

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local xSlider, ySlider
		local function setWidgetPos(x, y)
			widgetPos.x = math.clamp(x, 0, 100)
			widgetPos.y = math.clamp(y, 0, 100)
			Widget.Position = UDim2.fromScale(widgetPos.x / 100, widgetPos.y / 100)
		end

		-- перетаскивание виджета мышью (панель открыта и курсор свободен)
		do
			local dragging, startMouse, startPct
			Widget.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					startMouse = Vector2.new(input.Position.X, input.Position.Y)
					startPct = { x = widgetPos.x, y = widgetPos.y }
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local cam = workspace.CurrentCamera
					if not cam then
						return
					end
					local vp = cam.ViewportSize
					local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
					setWidgetPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
					if xSlider then
						xSlider.Set(widgetPos.x, true)
					end
					if ySlider then
						ySlider.Set(widgetPos.y, true)
					end
				end
			end)
		end

		------------------------------------------------------------
		-- УДАРЫ: слежение за мячом и обучение
		------------------------------------------------------------
		local shot = nil

		local function startShot(aim, root)
			local ball, bd = nil, 30
			for _, p in ipairs(workspace:GetPartBoundsInRadius(root.Position, 30)) do
				if p.Name == S.BallName then
					local d = (p.Position - root.Position).Magnitude
					if d < bd then
						ball, bd = p, d
					end
				end
			end
			if not ball then
				return
			end
			tune.shots += 1
			shot = {
				t = os.clock(), goal = aim.goal, pt = aim.pt, planePt = aim.planePt,
				dist = aim.dist, arc = aim.arc, off = aim.off, lat = aim.lat,
				cv = aim.cv, turn = aim.turn, phi = aim.phi, left = aim.left,
				ball = ball, resolved = false,
			}
		end

		local function resolveShot(isGoal, errY, errLat, errLeft)
			if not shot or shot.resolved then
				return
			end
			shot.resolved = true
			if isGoal then
				tune.goals += 1
			end

			if S.Learn then
				local arc, off = shot.arc, shot.off
				local cv = shot.cv or 0
				local valid = true
				if errY then
					if math.abs(errY) > S.OutlierY or (errLat and math.abs(errLat) > S.GoalW) then
						valid = false
					else
						local corr = math.deg(math.atan(errY / math.max(shot.dist, 10)))
						arc -= math.clamp(corr, -S.MaxCorrection, S.MaxCorrection)

						if cv == 0 then
							if errLat then
								off -= math.clamp(errLat, -S.MaxOffCorrection, S.MaxOffCorrection)
							end
						elseif errLeft then
							local e = math.deg(math.atan(errLeft / math.max(shot.dist, 10)))
							local phiDeg = math.abs(math.deg(shot.phi))
							if shot.turn > 0 and phiDeg > 0.5 then
								local k = phiDeg / shot.turn
								local dT = cv * e / k * S.CurveLearnGain
								dT = math.clamp(dT, -S.CurveMaxStep, S.CurveMaxStep)
								local nt = math.clamp(shot.turn + dT, S.CurveTurnMin, S.CurveTurnMax)
								tune.curveTurn[tostring(cv)] = roundTo(nt, 2)
							end
						end
					end
				end
				if valid then
					table.insert(tune.samples, {
						dist = roundTo(shot.dist, 1), lat = roundTo(shot.lat, 3),
						arc = roundTo(arc, 2), off = (cv == 0) and roundTo(off, 2) or nil,
						cv = cv, w = isGoal and 2 or 1,
					})
					while #tune.samples > S.MaxSamples do
						table.remove(tune.samples, 1)
					end
				end
			end
			save()
		end

		local function updateShot(now)
			if not shot or shot.resolved then
				return
			end
			if now - shot.t > S.ShotWindow or not shot.ball.Parent then
				shot.resolved = true
				return
			end
			local g = shot.goal
			local pos = shot.ball.Position
			local s = (pos - g.pos):Dot(g.forward)
			if shot.prevS and shot.prevS > 0 and s <= 0 then
				local t = shot.prevS / math.max(shot.prevS - s, 1e-6)
				local cross = shot.prevPos:Lerp(pos, t)
				local rel = cross - g.pos
				local inGoal = math.abs(rel:Dot(g.right)) <= S.GoalW / 2 and math.abs(rel.Y) <= S.GoalH / 2
				local errY = cross.Y - shot.planePt.Y
				local errLat = (cross - shot.planePt):Dot(g.right)
				local errLeft = shot.left and (cross - shot.planePt):Dot(shot.left) or errLat
				resolveShot(inGoal, errY, errLat, errLeft)
			end
			shot.prevS = s
			shot.prevPos = pos
		end

		------------------------------------------------------------
		-- ВВОД
		------------------------------------------------------------
		local holding = false
		local released = false
		local holdStart, lastShot = 0, -10
		local aimUntil, aimDir = 0, nil
		local wasCharging, lastAim, lastAimT = false, nil, 0

		local function mouseButton(down)
			if not VIM then
				return
			end
			local pos = UIS:GetMouseLocation()
			VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, down, game, 0)
		end

		local function releaseHold()
			if holding then
				holding = false
				mouseButton(false)
			end
		end

		local function ballInBox(cf)
			for _, part in ipairs(workspace:GetPartBoundsInBox(cf, Vector3.new(S.HitboxX, S.HitboxY, S.HitboxZ))) do
				if part.Name == S.BallName then
					return true
				end
			end
			return false
		end

		------------------------------------------------------------
		-- ВКЛ / ВЫКЛ
		------------------------------------------------------------
		local lastInfoRefresh = 0
		local function refreshOffText()
			if not S.Enabled then
				setStatus("off", "Auto Goal: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				setStatus("on", "Auto Goal: ВКЛ")
			else
				releaseHold()
				released = false
				aimDir = nil
				lastAim = nil
				hideVisuals()
				refreshOffText()
				for i = 1, 4 do
					setInfo(i, i == 1 and "—" or "")
				end
			end
		end
		refreshOffText()

		------------------------------------------------------------
		-- ОСНОВНОЙ ЦИКЛ
		------------------------------------------------------------
		RunService:BindToRenderStep("YokattaAutoGoal", Enum.RenderPriority.Camera.Value + 1, function()
			local now = os.clock()
			updateShot(now)

			if not S.Enabled then
				return
			end

			local mode = MODES[S.Mode]
			local curve = CURVES[S.CurveIdx]
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			for _, s in ipairs(spheres) do
				s.Transparency = 1
			end
			for _, d in ipairs(pathDots) do
				d.Transparency = 1
			end
			hitBox.Transparency = 1
			goalBox.Transparency = 1

			if not root then
				releaseHold()
				setStatus("idle", "Нет персонажа")
				return
			end

			local origin = root.Position
			local goal = pickGoal(origin)
			local list = evaluate(origin, goal, enemyRoots(), curve.cv)
			local best = list[1]
			local ok = best.score > -math.huge

			if S.ShowSpheres then
				for i, c in ipairs(list) do
					if c.score > -math.huge and (not S.ShowBestOnly or i == 1) then
						spheres[i].Size = Vector3.one * S.SphereSize
						spheres[i].Position = c.pt
						spheres[i].Color = (i == 1) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
						spheres[i].Transparency = S.SphereTransp
					end
				end
			end
			if S.ShowHitbox then
				hitBox.Size = Vector3.new(S.HitboxX, S.HitboxY, S.HitboxZ)
				hitBox.CFrame = root.CFrame
				hitBox.Transparency = S.HitboxTransp
			end
			if S.ShowGoalBox then
				goalBox.Size = Vector3.new(S.GoalW, S.GoalH, S.GoalDepth)
				goalBox.CFrame = CFrame.fromMatrix(goal.pos, goal.right, Vector3.yAxis)
				goalBox.Transparency = S.GoalBoxTransp
			end
			if S.ShowPath and ok and curve.cv ~= 0 then
				showPath(origin, best)
			end

			local charging = flag(valuesFolder(), "ChargingKick")
			local power = tonumber(readInfo("Power")) or 0

			if ok and (charging or holding) then
				aimDir = best.dir
				aimUntil = now + S.AimAfter
				lastAim, lastAimT = best, now
			end

			if wasCharging and not charging and lastAim and now - lastAimT < 0.5 then
				startShot(lastAim, root)
				lastAim = nil
			end
			wasCharging = charging

			if mode == "SEMI" then
				if charging and ok and power >= S.ShotPower and not released then
					released = true
					mouseButton(false)
					lastShot = now
				end
				if not charging then
					released = false
				end
			elseif mode == "AUTO" then
				if holding then
					if power >= S.ShotPower or now - holdStart > S.MaxHold or not ok then
						holding = false
						mouseButton(false)
						lastShot = now
					end
				elseif
					ok
					and not charging
					and now - lastShot > S.ShotCooldown
					and ballInBox(root.CFrame)
					and (not S.RequirePossession or flag(valuesFolder(), "Possession"))
				then
					holding = true
					holdStart = now
					mouseButton(true)
				end
			else
				releaseHold()
			end

			if S.AimCamera and aimDir and now < aimUntil then
				local cam = workspace.CurrentCamera
				local p = cam.CFrame.Position
				cam.CFrame = CFrame.lookAt(p, p + aimDir)
			end

			-- статус и инфо
			if not VIM and mode ~= "AIM" then
				setStatus("warn", "Нет VirtualInputManager")
			elseif holding or charging then
				setStatus("danger", ok and "Удар: цель наведена" or "Удар: цель вне досягаемости")
			elseif not ok then
				setStatus("idle", "Цель вне досягаемости")
			else
				setStatus("on", "Auto Goal: " .. mode)
			end

			if now - lastInfoRefresh >= 0.1 then
				lastInfoRefresh = now
				setInfo(1, string.format("%s | цель: %s | крутка: %s", mode, GOAL_CHOICES[S.GoalChoice], curve.name))
				setInfo(2, string.format("Ворота: %s (%s) | Power %d", goal.color, goal.field, math.floor(power)))
				setInfo(
					3,
					ok
						and string.format(
							"Дист %.0f | Arc %.1f | Off %.1f%s",
							best.dist,
							best.arc,
							best.off,
							curve.cv ~= 0 and string.format(" | Yaw %.1f", math.deg(best.phi)) or ""
						)
						or "Дист: —"
				)
				setInfo(4, string.format("Голы %d / удары %d | выборка %d", tune.goals, tune.shots, #tune.samples))
			end
		end)

		Players.PlayerRemoving:Connect(function(p)
			if p == player then
				save()
			end
		end)

		------------------------------------------------------------
		-- UI-ХЕЛПЕРЫ
		------------------------------------------------------------
		local function slider(holder, text, min, max, key, decimals, after)
			return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function toggle(holder, text, key, after)
			return UI.Toggle(holder, text, S[key], function(v)
				S[key] = v
				if after then
					after(v)
				end
			end)
		end

		local function foldout(title)
			local btn, g
			btn = UI.Button(h, "▸ " .. title, function()
				g.Visible = not g.Visible
				btn.Text = (g.Visible and "▾ " or "▸ ") .. title
			end)
			g = UI.Group(h)
			g.Visible = false
			return g
		end

		-- бинды: клик -> нажми клавишу; Esc/Backspace очищают
		local listening = nil -- { field, render }
		local OWN_FIELDS = { "Key", "ModeKey", "GoalKey", "CurveKey", "GoalAddKey", "GoalSubKey" }

		local function isReserved(key, field)
			if key == CONFIG.ToggleKey or key == CONFIG.CursorKey or key == Enum.KeyCode.Space then
				return true
			end
			for _, name in ipairs({
				"AutoDribble", "AutoTackle", "AutoSlide", "AutoShot", "AutoEsBht", "AutoDefence",
			}) do
				local st = shared[name] and shared[name].Settings
				if st then
					for _, f in ipairs({ "Key", "LoftKey", "TackleKey", "JumpKey", "ModeKey" }) do
						if st[f] == key then
							return true
						end
					end
				end
			end
			for _, f in ipairs(OWN_FIELDS) do
				if f ~= field and S[f] == key then
					return true
				end
			end
			return false
		end

		local function bindRow(labelText, field)
			local g = UI.Group(h)
			local row = create("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = C.Card,
				BorderSizePixel = 0,
			}, {
				corner(UDim.new(0, 10)),
				create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
			})
			row.Parent = g

			create("TextLabel", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = labelText,
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = row

			local btn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 28),
				BackgroundColor3 = C.Sidebar,
				Text = "",
				TextColor3 = C.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false,
			}, { corner(UDim.new(0, 8)) })
			btn.Parent = row

			local function render()
				btn.Text = S[field] and S[field].Name or "—"
			end
			render()

			btn.MouseButton1Click:Connect(function()
				if listening then
					listening.render()
				end
				listening = { field = field, render = render }
				btn.Text = "Нажми клавишу…"
			end)
			return render
		end

		------------------------------------------------------------
		-- UI: ГЛАВНОЕ
		------------------------------------------------------------
		UI.Section(h, "AUTO GOAL (W.I.P)")
		local mainToggle = UI.Toggle(h, "Auto Goal", false, setEnabled)
		bindRow("Бинд вкл/выкл", "Key")

		local modeBtn, goalBtn, curveBtn
		modeBtn = UI.Button(h, "Режим: " .. MODE_DESC[S.Mode], function()
			S.Mode = S.Mode % #MODES + 1
			modeBtn.Text = "Режим: " .. MODE_DESC[S.Mode]
			if MODES[S.Mode] ~= "AUTO" then
				releaseHold()
			end
		end)
		bindRow("Бинд смены режима", "ModeKey")

		goalBtn = UI.Button(h, "Цель: " .. GOAL_CHOICES[S.GoalChoice], function()
			S.GoalChoice = S.GoalChoice % #GOAL_CHOICES + 1
			goalBtn.Text = "Цель: " .. GOAL_CHOICES[S.GoalChoice]
		end)
		bindRow("Бинд смены цели", "GoalKey")

		curveBtn = UI.Button(h, "Закрутка: " .. CURVES[S.CurveIdx].name, function()
			S.CurveIdx = S.CurveIdx % #CURVES + 1
			curveBtn.Text = "Закрутка: " .. CURVES[S.CurveIdx].name
		end)
		bindRow("Бинд смены закрутки", "CurveKey")

		bindRow("Бинд +1 гол", "GoalAddKey")
		bindRow("Бинд -1 гол", "GoalSubKey")
        			Persist.addId("bind/AutoGoal/" .. field, "bind", function() return S[field] end,
				function(k) S[field] = k; render(); refreshOffText() end)

		UI.Note(
			h,
			"AIM — ты сам заряжаешь и отпускаешь M1, скрипт только наводит камеру. SEMI — ты зажимаешь M1, скрипт отпускает при нужной силе (Power). AUTO — мяч в хитбоксе -> скрипт сам зажимает M1, наводит и отпускает. Цель AUTO = ворота, противоположные твоей MatchTeam. Закрутку ставь так же, как бьёшь в игре. Бинды: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить). Режим, цель и закрутку можно менять и кнопками выше."
		)

		------------------------------------------------------------
		-- UI: УДАР
		------------------------------------------------------------
		local gShot = foldout("Удар")
		slider(gShot, "Сила для отпускания (Power)", 1, 100, "ShotPower", 0)
		slider(gShot, "Макс. удержание M1 (сек)", 0.5, 6, "MaxHold", 2)
		slider(gShot, "Кулдаун между ударами (сек)", 0.1, 3, "ShotCooldown", 2)
		slider(gShot, "Держать наводку после заряда (сек)", 0, 0.6, "AimAfter", 3)
		toggle(gShot, "Наводить камеру", "AimCamera")
		toggle(gShot, "AUTO только с Possession", "RequirePossession")
		UI.Section(gShot, "ХИТБОКС МЯЧА (ТРИГГЕР ДЛЯ AUTO)")
		slider(gShot, "Размер X", 1, 60, "HitboxX", 1)
		slider(gShot, "Размер Y", 1, 60, "HitboxY", 1)
		slider(gShot, "Размер Z", 1, 60, "HitboxZ", 1)

		------------------------------------------------------------
		-- UI: ВОРОТА
		------------------------------------------------------------
		local gGoal = foldout("Ворота")
		slider(gGoal, "Высота центра над землёй (студы)", -10, 30, "GoalYOffset", 1, applyGoalOffset)
		slider(gGoal, "Ширина ворот", 10, 100, "GoalW", 1)
		slider(gGoal, "Высота ворот", 4, 60, "GoalH", 1)
		slider(gGoal, "Толщина зоны (визуал)", 0.5, 20, "GoalDepth", 1)

		------------------------------------------------------------
		-- UI: СФЕРА-ЦЕЛЬ
		------------------------------------------------------------
		local gAim = foldout("Сфера-цель")
		toggle(gAim, "Глубина НАЗАД (от стрелка, в сторону задней стенки)", "DepthInvert")
		slider(gAim, "Сдвиг по глубине при остром угле", -30, 30, "NearDepthShift", 1)
		slider(gAim, "Отступ от штанги (близкий)", 0, 15, "InsetH", 2)
		slider(gAim, "Доп. отступ на дальней дистанции", 0, 15, "FarInsetH", 2)
		slider(gAim, "Сдвиг у ближней штанги при угле", 0, 25, "NearSideShift", 1)
		slider(gAim, "Отступ от перекладины (близко)", 0, 8, "InsetVNear", 2)
		slider(gAim, "Отступ от перекладины (далеко)", 0, 8, "InsetVFar", 2)
		slider(gAim, "Радиус блока врагами (студы)", 0, 30, "BlockRadius", 1)
		slider(gAim, "Запас дальности (множитель)", 0.5, 1.2, "RangeSafety", 2)
		UI.Note(
			gAim,
			"Если сфера смещается не в ту сторону по глубине — переключи «Глубина НАЗАД» или поставь отрицательный сдвиг. 0 = сфера строго на линии ворот."
		)

		------------------------------------------------------------
		-- UI: КРУТКА
		------------------------------------------------------------
		local gCurve = foldout("Крутка")
		slider(gCurve, "Поворот мяча на опорной дистанции (град)", 5, 90, "CurveTurn", 1)
		slider(gCurve, "Опорная дистанция (студы)", 30, 400, "CurveRefDist", 0)
		slider(gCurve, "Степень (1 = ровная дуга, >1 = в конце круче)", 1, 4, "CurvePower", 2)
		slider(gCurve, "Мин. поворот (град)", 1, 45, "CurveTurnMin", 1)
		slider(gCurve, "Макс. поворот (град)", 10, 150, "CurveTurnMax", 1)
		slider(gCurve, "Сила обучения крутки", 0, 1, "CurveLearnGain", 2)
		slider(gCurve, "Макс. шаг обучения (град)", 0.5, 20, "CurveMaxStep", 1)
		slider(gCurve, "Вес ударов с другой круткой", 0, 1, "CurveOtherWeight", 2)

		------------------------------------------------------------
		-- UI: САМООБУЧЕНИЕ
		------------------------------------------------------------
		local gLearn = foldout("Самообучение")
		toggle(gLearn, "Обучаться по результатам ударов", "Learn")
		slider(gLearn, "Окно слежения за ударом (сек)", 1, 15, "ShotWindow", 1)
		slider(gLearn, "Ширина по дистанции", 5, 100, "TuneBandwidth", 1)
		slider(gLearn, "Ширина по углу", 0.05, 1, "TuneLatBandwidth", 2)
		slider(gLearn, "Вес базовой таблицы", 0.1, 10, "PriorWeight", 2)
		slider(gLearn, "Макс. поправка высоты (град)", 1, 20, "MaxCorrection", 1)
		slider(gLearn, "Макс. боковая поправка (студы)", 1, 20, "MaxOffCorrection", 1)
		slider(gLearn, "Макс. записей", 20, 1000, "MaxSamples", 0)
		slider(gLearn, "Порог выбросов по высоте", 5, 60, "OutlierY", 0)

		local resetAt = -10
		local resetBtn
		resetBtn = UI.Button(gLearn, "Стереть обучение (нажми дважды)", function()
			local now = os.clock()
			if now - resetAt < 2 then
				tune.samples, tune.goals, tune.shots, tune.curveTurn = {}, 0, 0, {}
				save()
				resetAt = -10
				resetBtn.Text = "Стереть обучение (нажми дважды)"
			else
				resetAt = now
				resetBtn.Text = "Точно? Нажми ещё раз"
				task.delay(2, function()
					if resetAt == now then
						resetBtn.Text = "Стереть обучение (нажми дважды)"
					end
				end)
			end
		end)
		UI.Button(gLearn, "Сохранить обучение сейчас", save)

		------------------------------------------------------------
		-- UI: ВИЗУАЛ
		------------------------------------------------------------
		local gVis = foldout("Визуал (сферы и хитбоксы)")
		toggle(gVis, "Сферы-цели", "ShowSpheres")
		toggle(gVis, "Только лучшая сфера", "ShowBestOnly")
		slider(gVis, "Размер сфер", 0.5, 8, "SphereSize", 1)
		slider(gVis, "Прозрачность сфер", 0, 1, "SphereTransp", 2)
		toggle(gVis, "Хитбокс мяча (куб вокруг меня)", "ShowHitbox")
		slider(gVis, "Прозрачность хитбокса", 0, 1, "HitboxTransp", 2)
		toggle(gVis, "Куб ворот", "ShowGoalBox")
		slider(gVis, "Прозрачность куба ворот", 0, 1, "GoalBoxTransp", 2)
		toggle(gVis, "Путь мяча при крутке (белые точки)", "ShowPath")

		------------------------------------------------------------
		-- UI: GUI
		------------------------------------------------------------
		local gGui = foldout("GUI Auto Goal")
		UI.Toggle(gGui, "Показывать GUI", S.GuiShown, function(v)
			S.GuiShown = v
			Widget.Visible = v
		end)
		UI.Slider(gGui, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			WScale.Scale = v
		end)
		xSlider = UI.Slider(gGui, "Позиция X (%)", 0, 100, widgetPos.x, 1, function(v)
			setWidgetPos(v, widgetPos.y)
		end)
		ySlider = UI.Slider(gGui, "Позиция Y (%)", 0, 100, widgetPos.y, 1, function(v)
			setWidgetPos(widgetPos.x, v)
		end)
		UI.Button(gGui, "Сбросить позицию GUI", function()
			setWidgetPos(86, 40)
			xSlider.Set(86, true)
			ySlider.Set(40, true)
		end)
		UI.Note(gGui, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local l = listening
					listening = nil
					local key = input.KeyCode
					if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
						S[l.field] = nil
					elseif not isReserved(key, l.field) then
						S[l.field] = key
					end
					l.render()
					refreshOffText()
				end
				return
			end

			if gp then
				return
			end
			local k = input.KeyCode
			if S.Key and k == S.Key then
				mainToggle.Set(not mainToggle.Get())
			elseif S.ModeKey and k == S.ModeKey then
				S.Mode = S.Mode % #MODES + 1
				modeBtn.Text = "Режим: " .. MODE_DESC[S.Mode]
				if MODES[S.Mode] ~= "AUTO" then
					releaseHold()
				end
			elseif S.GoalKey and k == S.GoalKey then
				S.GoalChoice = S.GoalChoice % #GOAL_CHOICES + 1
				goalBtn.Text = "Цель: " .. GOAL_CHOICES[S.GoalChoice]
			elseif S.CurveKey and k == S.CurveKey then
				S.CurveIdx = S.CurveIdx % #CURVES + 1
				curveBtn.Text = "Закрутка: " .. CURVES[S.CurveIdx].name
			elseif S.GoalAddKey and k == S.GoalAddKey then
				if shot and not shot.resolved then
					resolveShot(true, nil, nil, nil)
				else
					tune.goals += 1
					save()
				end
			elseif S.GoalSubKey and k == S.GoalSubKey then
				tune.goals = math.max(0, tune.goals - 1)
				save()
			end
		end)

		-- отдаём наружу
		shared.AutoGoal = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoGoal)
	if not ok then
		warn("[Yokatta] AutoGoal: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: MACRO KIT (общие функции для 3 блоков ниже)
-- Вставь этот блок в Yokatta сразу ПОСЛЕ блока Auto Goal
-- (и ПЕРЕД разделом «СТАРТ»). Дальше вставь блоки Auto Call Pass,
-- Flick Macros и Head-Tap Macros в этом же порядке.
------------------------------------------------------------
do
	local Kit = {}
	shared.YokattaMacroKit = Kit

	local StatsService = game:GetService("Stats")
	local okVim, VIM = pcall(function()
		return game:GetService("VirtualInputManager")
	end)
	if not okVim then
		VIM = nil
	end
	Kit.VIM = VIM
	Kit.listening = nil
	Kit.swallowed = nil

	------------------------------------------------------------
	-- ПИНГ
	------------------------------------------------------------
	local function readPing()
		local ok, ms = pcall(function()
			return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and ms and ms > 0 then
			return ms / 1000
		end
		return nil
	end

	local ping = readPing() or 0.05
	RunService.Heartbeat:Connect(function(dt)
		local p = readPing()
		if p then
			ping = ping + (math.clamp(p, 0, 1) - ping) * math.clamp(dt * 5, 0, 1)
		end
	end)

	function Kit.ping()
		return ping
	end

	-- rtt по настройкам конкретного блока (S.PingMult, S.PingOffset)
	function Kit.rtt(S)
		return math.max(0, ping * S.PingMult + S.PingOffset)
	end

	------------------------------------------------------------
	-- ПОМОЩНИКИ
	------------------------------------------------------------
	function Kit.flat(v)
		return Vector3.new(v.X, 0, v.Z)
	end

	function Kit.hasAny(iv, list)
		if not iv then
			return nil
		end
		for _, e in ipairs(list) do
			if e.enabled and iv:FindFirstChild(e.name) then
				return e.name
			end
		end
		return nil
	end

	function Kit.isOpponent(plr)
		local me = Players.LocalPlayer
		if plr == me then
			return false
		end
		local mine = me:FindFirstChild("MatchTeam")
		local theirs = plr:FindFirstChild("MatchTeam")
		if not mine or not theirs then
			return true
		end
		return mine.Value ~= theirs.Value
	end

	local LG
	function Kit.getLG()
		if LG and LG.Parent then
			return LG
		end
		local m = workspace:FindFirstChild("lagghost")
		LG = m and m:FindFirstChild("HumanoidRootPart") or nil
		return LG
	end

	local ballCache, lastDeep = nil, 0
	function Kit.getFootball()
		if ballCache and ballCache.Parent then
			return ballCache
		end
		ballCache = nil
		local m = workspace:FindFirstChild("Messi")
		local b = m and m:FindFirstChild("/e ball")
		local f = b and b:FindFirstChild("Football")
		if not f and os.clock() - lastDeep > 1 then
			lastDeep = os.clock()
			f = workspace:FindFirstChild("Football", true)
		end
		if f then
			if f:IsA("BasePart") then
				ballCache = f
			else
				ballCache = f.PrimaryPart or f:FindFirstChildWhichIsA("BasePart", true)
			end
		end
		return ballCache
	end

	function Kit.tapKey(key, hold)
		if not VIM then
			return
		end
		VIM:SendKeyEvent(true, key, false, game)
		task.wait(hold or 0.03)
		VIM:SendKeyEvent(false, key, false, game)
	end

	function Kit.curveEmpty(v)
		if v == nil then
			return true
		end
		local s = string.lower(tostring(v))
		return s:match("^%s*$") ~= nil or s == "none" or s == "nil" or s == "null"
	end

	------------------------------------------------------------
	-- ЗАНЯТЫЕ КЛАВИШИ
	------------------------------------------------------------
	local SHARED_NAMES = {
		"AutoDribble", "AutoTackle", "AutoSlide", "AutoShot", "AutoEsBht",
		"AutoDefence", "AutoGoal", "AutoCallout", "FlickMacro", "HeadTap",
	}
	local KEY_FIELDS = {
		"Key", "LoftKey", "TackleKey", "JumpKey", "ModeKey",
		"GoalKey", "CurveKey", "GoalAddKey", "GoalSubKey",
	}

	function Kit.isReserved(key, S, field)
		if key == CONFIG.ToggleKey or key == CONFIG.CursorKey or key == Enum.KeyCode.Space then
			return true
		end
		for _, name in ipairs(SHARED_NAMES) do
			local st = shared[name] and shared[name].Settings
			if st then
				for _, f in ipairs(KEY_FIELDS) do
					if not (st == S and f == field) and st[f] == key then
						return true
					end
				end
			end
		end
		return false
	end

	-- единый обработчик «нажми клавишу» для всех строк-биндов Kit
	UIS.InputBegan:Connect(function(input)
		local l = Kit.listening
		if not l or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		Kit.listening = nil
		Kit.swallowed = input
		local key = input.KeyCode
		if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
			if l.canClear then
				l.S[l.field] = nil
			end
		elseif l.noReserve or not Kit.isReserved(key, l.S, l.field) then
			l.S[l.field] = key
		end
		l.render()
		if l.onChange then
			l.onChange()
		end
	end)

	------------------------------------------------------------
	-- UI-ХЕЛПЕРЫ
	------------------------------------------------------------
	function Kit.slider(holder, S, text, min, max, key, decimals, after)
		return UI.Slider(holder, text, min, max, S[key], decimals, function(v)
			S[key] = v
			if after then
				after(v)
			end
		end)
	end

	function Kit.toggle(holder, S, text, key, after)
		return UI.Toggle(holder, text, S[key], function(v)
			S[key] = v
			if after then
				after(v)
			end
		end)
	end

	function Kit.foldout(h, title)
		local btn, g
		btn = UI.Button(h, "▸ " .. title, function()
			g.Visible = not g.Visible
			btn.Text = (g.Visible and "▾ " or "▸ ") .. title
		end)
		g = UI.Group(h)
		g.Visible = false
		return g
	end

	function Kit.listToggles(holder, list)
		for _, e in ipairs(list) do
			UI.Toggle(holder, e.name, e.enabled, function(v)
				e.enabled = v
			end)
		end
	end

	-- opts: { canClear = bool, noReserve = bool, onChange = fn }
	function Kit.bindRow(h, labelText, S, field, opts)
		opts = opts or {}
		local g = UI.Group(h)
		local row = create("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = C.Card,
			BorderSizePixel = 0,
		}, {
			corner(UDim.new(0, 10)),
			create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.5 }),
		})
		row.Parent = g

		create("TextLabel", {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -140, 1, 0),
			BackgroundTransparency = 1,
			Text = labelText,
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		local btn = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(110, 28),
			BackgroundColor3 = C.Sidebar,
			Text = "",
			TextColor3 = C.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			AutoButtonColor = false,
		}, { corner(UDim.new(0, 8)) })
		btn.Parent = row

		local function render()
			btn.Text = S[field] and S[field].Name or "—"
		end
		render()
        		Persist.add(h, labelText, "bind", function() return S[field] end, function(k)
			S[field] = k
			render()
			if opts.onChange then
				opts.onChange()
			end
		end)

		btn.MouseButton1Click:Connect(function()
			if Kit.listening then
				Kit.listening.render()
			end
			Kit.listening = {
				S = S, field = field, render = render,
				canClear = opts.canClear, noReserve = opts.noReserve, onChange = opts.onChange,
			}
			btn.Text = "Нажми клавишу…"
		end)
		return render
	end

	------------------------------------------------------------
	-- GUI-ВИДЖЕТ
	-- o = { name, order, x, y, w, lines, offText }
	------------------------------------------------------------
	local STATUS_COLORS = {
		off = C.Off,
		on = Color3.fromRGB(0, 200, 100),
		danger = Color3.fromRGB(230, 40, 150),
		idle = Color3.fromRGB(90, 160, 255),
		warn = Color3.fromRGB(255, 170, 0),
	}

	function Kit.widget(o)
		local old = parent:FindFirstChild(o.name)
		if old then
			old:Destroy()
		end
		local gui = create("ScreenGui", {
			Name = o.name,
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = o.order,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		gui.Parent = parent

		local W = { pos = { x = o.x, y = o.y }, defX = o.x, defY = o.y }
		local stroke = create("UIStroke", { Color = C.HeaderLine, Thickness = 2 })
		W.scale = create("UIScale", { Scale = 1 })
		W.frame = create("Frame", {
			Name = "Widget",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(o.x / 100, o.y / 100),
			Size = UDim2.fromOffset(o.w, 40 + o.lines * 20),
			BackgroundColor3 = C.Bg,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
		}, { corner(UDim.new(0, 12)), stroke })
		W.scale.Parent = W.frame
		W.frame.Parent = gui
        W.frame.Visible = false

		local dot = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = STATUS_COLORS.off,
			BorderSizePixel = 0,
		}, { round() })
		dot.Parent = W.frame

		local statusLabel = create("TextLabel", {
			Position = UDim2.fromOffset(32, 6),
			Size = UDim2.new(1, -40, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.TextDark,
			Text = o.offText,
		})
		statusLabel.Parent = W.frame

		local infoLabels, infoCache = {}, {}
		for i = 1, o.lines do
			local l = create("TextLabel", {
				Position = UDim2.fromOffset(12, 32 + (i - 1) * 20),
				Size = UDim2.new(1, -24, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = C.TextMid,
				Text = "—",
			})
			l.Parent = W.frame
			infoLabels[i], infoCache[i] = l, ""
		end

		local curName, curText = nil, ""
		function W.setStatus(name, text)
			if curName == name and curText == text then
				return
			end
			curName, curText = name, text
			statusLabel.Text = text
			dot.BackgroundColor3 = STATUS_COLORS[name]
			stroke.Color = STATUS_COLORS[name]
		end

		function W.setInfo(i, text)
			if infoCache[i] == text then
				return
			end
			infoCache[i] = text
			infoLabels[i].Text = text
		end

		function W.setPos(x, y)
			W.pos.x = math.clamp(x, 0, 100)
			W.pos.y = math.clamp(y, 0, 100)
			W.frame.Position = UDim2.fromScale(W.pos.x / 100, W.pos.y / 100)
		end

		-- перетаскивание мышью (панель открыта и курсор свободен)
		local dragging, startMouse, startPct
		W.frame.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragging = true
				startMouse = Vector2.new(input.Position.X, input.Position.Y)
				startPct = { x = W.pos.x, y = W.pos.y }
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				local cam = workspace.CurrentCamera
				if not cam then
					return
				end
				local vp = cam.ViewportSize
				local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
				W.setPos(startPct.x + delta.X / vp.X * 100, startPct.y + delta.Y / vp.Y * 100)
				if W.xSlider then
					W.xSlider.Set(W.pos.x, true)
				end
				if W.ySlider then
					W.ySlider.Set(W.pos.y, true)
				end
			end
		end)

		return W
	end

	-- секция «GUI» в панели
	function Kit.guiFoldout(h, title, W)
		local g = Kit.foldout(h, title)
		UI.Toggle(g, "Показывать GUI", W.frame.Visible, function(v)
			W.frame.Visible = v
		end)
		UI.Slider(g, "Размер GUI", 0.5, 2.5, 1, 2, function(v)
			W.scale.Scale = v
		end)
		W.xSlider = UI.Slider(g, "Позиция X (%)", 0, 100, W.pos.x, 1, function(v)
			W.setPos(v, W.pos.y)
		end)
		W.ySlider = UI.Slider(g, "Позиция Y (%)", 0, 100, W.pos.y, 1, function(v)
			W.setPos(W.pos.x, v)
		end)
		UI.Button(g, "Сбросить позицию GUI", function()
			W.setPos(W.defX, W.defY)
			W.xSlider.Set(W.defX, true)
			W.ySlider.Set(W.defY, true)
		end)
		UI.Note(g, "GUI можно таскать мышью, пока открыта панель (M) и включён режим курсора.")
		return g
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO CALL PASS
-- Вставь сразу ПОСЛЕ блока Macro Kit.
-- Спамит кнопку вызова паса (T), пока нет CalloutCooldown.
------------------------------------------------------------
do
	local function initCallout()
		local h = Holders.AutoUse
		local Kit = shared.YokattaMacroKit
		if not h or not Kit then
			return
		end

		local player = Players.LocalPlayer
		local VIM = Kit.VIM

		local S = {
			Enabled = false,
			Key = nil, -- бинд вкл/выкл
			SpamKey = Enum.KeyCode.T, -- что жмём в игре

			PressesPerSec = 20, -- нажатий в секунду
			MaxPerFrame = 5, -- лимит нажатий за один кадр
			WaitCooldown = true, -- не жать, пока есть CalloutCooldown
			SkipWhenTyping = true, -- не жать, пока открыт чат
		}

		local COOLDOWN_FLAG = "CalloutCooldown"
		local BLOCK = {
			{ name = "Possession", enabled = true },
		}

		local acc, total, lastPress = 0, 0, -10
		local state = "выкл"

		local W = Kit.widget({
			name = "YokattaAutoCallout", order = 990, x = 86, y = 54, w = 300, lines = 2,
			offText = "Call Pass: ВЫКЛ",
		})

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local function refreshOffText()
			if not S.Enabled then
				W.setStatus("off", "Call Pass: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			acc = 0
			if S.Enabled then
				W.setStatus("on", "Call Pass: ВКЛ")
			else
				state = "выкл"
				refreshOffText()
			end
		end
		refreshOffText()

		local function press(key)
			lastPress = os.clock()
			VIM:SendKeyEvent(true, key, false, game)
			VIM:SendKeyEvent(false, key, false, game)
		end

		local infoTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			infoTimer += dt
			if infoTimer >= 0.2 then
				infoTimer = 0
				W.setInfo(1, string.format("Скорость: %d/сек | кнопка %s", math.floor(S.PressesPerSec), S.SpamKey and S.SpamKey.Name or "—"))
				W.setInfo(2, string.format("Нажатий всего: %d | %s", total, state))
			end

			if not S.Enabled then
				return
			end
			if not VIM then
				W.setStatus("warn", "Нет VirtualInputManager")
				return
			end
			if not S.SpamKey then
				W.setStatus("warn", "Не выбрана кнопка спама")
				return
			end

			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local iv = char and char:FindFirstChild("InstanceValue")
			if not (char and hum and iv) or hum.Health <= 0 then
				state = "нет персонажа"
				W.setStatus("idle", "Call Pass: нет персонажа")
				acc = 0
				return
			end

			local blocked = Kit.hasAny(iv, BLOCK)
			if blocked then
				state = "блок: " .. blocked
				W.setStatus("warn", "Call Pass: " .. blocked .. ", не спамим")
				acc = 0
				return
			end

			if S.SkipWhenTyping and UIS:GetFocusedTextBox() then
				state = "ввод текста"
				W.setStatus("idle", "Call Pass: открыт ввод текста")
				acc = 0
				return
			end

			if S.WaitCooldown and iv:FindFirstChild(COOLDOWN_FLAG) then
				state = "кулдаун"
				W.setStatus("idle", "Call Pass: кулдаун, ждём")
				acc = 0
				return
			end

			state = "спамим"
			W.setStatus("danger", "Call Pass: спамим " .. S.SpamKey.Name)
			acc = math.min(acc + dt * S.PressesPerSec, S.MaxPerFrame + 1)
			local n = math.min(math.floor(acc), S.MaxPerFrame)
			acc -= n
			for _ = 1, n do
				total += 1
				press(S.SpamKey)
			end
		end)

		------------------------------------------------------------
		-- UI
		------------------------------------------------------------
		UI.Section(h, "AUTO CALL PASS")
		local mainToggle = UI.Toggle(h, "Auto Call Pass", false, setEnabled)
		Kit.bindRow(h, "Бинд вкл/выкл", S, "Key", { canClear = true, onChange = refreshOffText })
		Kit.bindRow(h, "Кнопка вызова пасса в игре", S, "SpamKey", { noReserve = true })
		Kit.slider(h, S, "Нажатий в секунду", 1, 120, "PressesPerSec", 0)

		UI.Note(
			h,
			"Пока включено, быстро жмёт кнопку вызова пасса (по умолчанию T), пока в InstanceValue нет CalloutCooldown. Если есть Possession — не жмёт. Бинд: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить)."
		)

		local gSet = Kit.foldout(h, "Условия и лимиты")
		Kit.slider(gSet, S, "Макс. нажатий за кадр", 1, 20, "MaxPerFrame", 0)
		Kit.toggle(gSet, S, "Ждать, пока есть CalloutCooldown", "WaitCooldown")
		Kit.toggle(gSet, S, "Не жать при открытом чате", "SkipWhenTyping")
		UI.Section(gSet, "НЕ СПАМИТЬ, ЕСЛИ У МЕНЯ ЕСТЬ")
		Kit.listToggles(gSet, BLOCK)

		Kit.guiFoldout(h, "GUI Call Pass", W)

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if gp or Kit.listening or Kit.swallowed == input or not S.Key then
				return
			end
			if S.SpamKey == input.KeyCode and os.clock() - lastPress < 0.25 then
				return
			end
			if input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			end
		end)

		shared.AutoCallout = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initCallout)
	if not ok then
		warn("[Yokatta] AutoCallout: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: FLICK MACROS
-- Вставь сразу ПОСЛЕ блока Auto Call Pass.
-- Зажим M1 до нужного Power, (опционально) камера вверх,
-- авто-закрутка, после удара смотрим на мяч.
-- Bolo включается ТОЛЬКО в панели. Кнопка запускает / отменяет макрос.
------------------------------------------------------------
do
	local function initFlick()
		local h = Holders.AutoUse
		local Kit = shared.YokattaMacroKit
		if not h or not Kit then
			return
		end

		local player = Players.LocalPlayer
		local VIM = Kit.VIM
		local flat = Kit.flat

		pcall(function()
			RunService:UnbindFromRenderStep("YokattaFlickCamera")
		end)
		pcall(function()
			RunService:UnbindFromRenderStep("YokattaFlickFace")
		end)

		local S = {
			Enabled = true, -- разрешить макрос (мастер-переключатель в панели)
			Key = nil, -- запуск / отмена макроса
			GameCurveKey = Enum.KeyCode.R, -- смена закрутки в игре

			-- режим (только из панели)
			Bolo = false,

			-- сила
			NormalLo = 65,
			NormalHi = 70,
			BoloLo = 55,
			BoloHi = 60,
			TargetFrac = 0.5, -- 0 = низ диапазона, 1 = верх
			ChargingMaxPower = 60, -- если уже ChargingKick и Power выше, не запускаем

			-- камера
			MoveCamera = true, -- false = камеру вообще не трогаем
			CamPitch = 80,
			CamPre = 0, -- (не используется в Flick, оставлено = 0) держим камеру вверху до отпускания
			CamExtra = 0.05,
			CamLookBall = true, -- после удара камера смотрит на мяч
			CamBallTime = 0.1,

			-- персонаж
			FaceBall = true,
			FaceTime = 0.5,
			FaceLeadMult = 1,

			-- закрутка
			AutoCurve = true,
			CurveMaxPresses = 4,
			CurveWait = 0.25,
			CurveRadius = 70,
			CurveBehind = 5,
			CurveDefaultRight = true,
			CurveInvert = false,

			-- пинг
			PingMult = 1,
			PingOffset = 0,
			InputFrame = 0.017,
			ReleaseExtra = 0, -- + отпускать раньше

			-- скорость набора Power
			DefaultPowerRate = 50,
			RateMinSpan = 0.1,
			MinHold = 0.05,
			HoldTimeout = 4,
		}

		local BLOCK = {
			{ name = "Kick", enabled = true },
			{ name = "Dribbling", enabled = true },
		}

		local running, cancelled = false, false
		local status = "готов"

		local W = Kit.widget({
			name = "YokattaFlickMacro", order = 989, x = 14, y = 72, w = 320, lines = 3,
			offText = "Flick Macro: ВЫКЛ",
		})

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local function range()
			if S.Bolo then
				return S.BoloLo, S.BoloHi
			end
			return S.NormalLo, S.NormalHi
		end

		local function refreshWidget()
			local char = player.Character
			local info = char and char:FindFirstChild("PlayerInfo")
			local pw = info and info:FindFirstChild("Power")
			local cv = info and info:FindFirstChild("Curve")
			local lo, hi = range()
			if not S.Enabled then
				W.setStatus("off", "Flick Macro: ВЫКЛ" .. keyHint())
			elseif running then
				W.setStatus("danger", "Flick: " .. status)
			else
				W.setStatus("on", "Flick Macro: " .. status)
			end
			W.setInfo(1, string.format("Режим: %s %d–%d | камера: %s", S.Bolo and "Bolo" or "Normal", lo, hi, S.MoveCamera and "двигаем" or "не трогаем"))
			W.setInfo(2, string.format("Power: %s | Curve: %s", pw and math.floor(pw.Value + 0.5) or "-", cv and (tostring(cv.Value) ~= "" and tostring(cv.Value) or "пусто") or "-"))
			W.setInfo(3, string.format("Пинг: %d мс", math.floor(Kit.ping() * 1000 + 0.5)))
		end

		local infoTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			infoTimer += dt
			if infoTimer >= 0.1 then
				infoTimer = 0
				refreshWidget()
			end
		end)

		-- выбор закрутки: уводим мяч в сторону, где меньше оппонентов
		local function chooseCurve(look)
			local lg = Kit.getLG()
			local origin = lg and lg.Position
			if not origin then
				local c = player.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				origin = r and r.Position
			end
			local default = S.CurveDefaultRight and "right" or "left"
			if not origin then
				return default
			end

			local right = look:Cross(Vector3.yAxis)
			local lead = Kit.rtt(S)
			local score = { left = 0, right = 0 }
			for _, plr in ipairs(Players:GetPlayers()) do
				if Kit.isOpponent(plr) and plr.Character then
					local r = plr.Character:FindFirstChild("HumanoidRootPart")
					if r then
						local pos = r.Position + flat(r.AssemblyLinearVelocity) * lead
						local rel = flat(pos - origin)
						local dist = rel.Magnitude
						if dist <= S.CurveRadius and dist > 0.1 and rel:Dot(look) > -S.CurveBehind then
							local w = 1 / (dist + 5)
							if rel:Dot(right) >= 0 then
								score.right += w
							else
								score.left += w
							end
						end
					end
				end
			end

			local want
			if math.abs(score.left - score.right) < 1e-6 then
				want = default
			elseif score.left > score.right then
				want = "right"
			else
				want = "left"
			end
			if S.CurveInvert then
				want = (want == "left") and "right" or "left"
			end
			return want
		end

		------------------------------------------------------------
		-- МАКРОС
		------------------------------------------------------------
		local function runMacro()
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local info = char and char:FindFirstChild("PlayerInfo")
			local iv = char and char:FindFirstChild("InstanceValue")
			local powerV = info and info:FindFirstChild("Power")
			if not (root and hum and iv and powerV) or hum.Health <= 0 then
				status = "нет данных персонажа"
				return
			end
			local blocked = Kit.hasAny(iv, BLOCK)
			if blocked then
				status = "заблокировано (" .. blocked .. ")"
				return
			end
			local charging = iv:FindFirstChild("ChargingKick") ~= nil
			if charging and powerV.Value > S.ChargingMaxPower then
				status = "уже заряжен выше " .. S.ChargingMaxPower
				return
			end

			running, cancelled = true, false

			local camera = workspace.CurrentCamera
			local mouseDown = false
			local mousePos = UIS:GetMouseLocation()
			local camTouched = false
			local prevCamType = camera.CameraType
			local powerConn = nil

			local function mouseUp()
				if mouseDown then
					mouseDown = false
					VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
				end
			end

			local function restoreCamera()
				pcall(function()
					RunService:UnbindFromRenderStep("YokattaFlickCamera")
				end)
				if camTouched then
					camTouched = false
					camera.CameraType = prevCamType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or prevCamType
				end
			end

			local function cleanup()
				mouseUp()
				restoreCamera()
				pcall(function()
					RunService:UnbindFromRenderStep("YokattaFlickFace")
				end)
				if powerConn then
					powerConn:Disconnect()
					powerConn = nil
				end
				if hum and hum.Parent then
					hum.AutoRotate = true
				end
				running = false
			end

			local function waitFor(seconds)
				local t0 = os.clock()
				while os.clock() - t0 < seconds and not cancelled do
					RunService.Heartbeat:Wait()
				end
				return not cancelled
			end

			local ok, err = pcall(function()
				-- 1) направление взгляда и (опционально) камера вверх
				camera = workspace.CurrentCamera
				local look = flat(camera.CFrame.LookVector)
				if look.Magnitude < 0.01 then
					look = flat(root.CFrame.LookVector)
				end
				if look.Magnitude < 0.01 then
					look = Vector3.new(0, 0, -1)
				end
				look = look.Unit
				local yaw = math.atan2(-look.X, -look.Z)
				local camOffset = camera.CFrame.Position - root.Position
				local camOnBall = false

				if S.MoveCamera then
					prevCamType = camera.CameraType
					camera.CameraType = Enum.CameraType.Scriptable
					camTouched = true
					local function camStep()
						local camPos = root.Position + camOffset
						if camOnBall then
							local ball = Kit.getFootball()
							if ball and (ball.Position - camPos).Magnitude > 0.5 then
								camera.CFrame = CFrame.lookAt(camPos, ball.Position)
								return
							end
						end
						camera.CFrame = CFrame.new(camPos) * CFrame.fromEulerAnglesYXZ(math.rad(S.CamPitch), yaw, 0)
					end
					RunService:BindToRenderStep("YokattaFlickCamera", Enum.RenderPriority.Last.Value, camStep)
					camStep()
				end

				-- 2) закрутка: меняем ТОЛЬКО если Curve пустой
				local curveV = info:FindFirstChild("Curve")
				if S.AutoCurve and curveV and Kit.curveEmpty(curveV.Value) then
					status = "выбор закрутки"
					local want = chooseCurve(look)
					for _ = 1, S.CurveMaxPresses do
						local before = tostring(curveV.Value)
						Kit.tapKey(S.GameCurveKey, 0.03)
						local t0 = os.clock()
						local limit = Kit.rtt(S) + S.CurveWait
						while os.clock() - t0 < limit and not cancelled and tostring(curveV.Value) == before do
							RunService.Heartbeat:Wait()
						end
						if cancelled then
							return
						end
						local now = tostring(curveV.Value)
						if not Kit.curveEmpty(now) and string.find(string.lower(now), want, 1, true) then
							break
						end
					end
				end
				if cancelled then
					return
				end

				-- 3) зажим M1 до нужного Power
				local lo, hi = range()
				local target = lo + (hi - lo) * S.TargetFrac

				local t0 = os.clock()
				local samples = { { t = t0, p = powerV.Value } }
				local pLast, tLast = powerV.Value, t0
				powerConn = powerV.Changed:Connect(function(v)
					local t = os.clock()
					pLast, tLast = v, t
					samples[#samples + 1] = { t = t, p = v }
					while #samples > 2 and t - samples[1].t > 0.8 do
						table.remove(samples, 1)
					end
				end)

				local function rate()
					local n = #samples
					local newest = samples[n]
					for i = n - 1, 1, -1 do
						local span = newest.t - samples[i].t
						if span >= S.RateMinSpan then
							local r = (newest.p - samples[i].p) / span
							return r > 0 and r or S.DefaultPowerRate
						end
					end
					return S.DefaultPowerRate
				end

				status = "зарядка"
				if not charging then
					mousePos = UIS:GetMouseLocation()
					mouseDown = true
					VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
				else
					mouseDown = true -- игрок уже держит M1, отпустим сами
				end
				local tStart = os.clock()

				while true do
					RunService.Heartbeat:Wait()
					if cancelled or not root.Parent or hum.Health <= 0 then
						return
					end
					local now = os.clock()
					local ahead = math.min(now - tLast, 0.3) + Kit.rtt(S) + S.InputFrame + S.ReleaseExtra
					local predicted = pLast + rate() * ahead
					local held = now - tStart
					if (held >= S.MinHold and predicted >= target) or pLast >= hi or held > S.HoldTimeout then
						status = string.format("отпуск: Power %.0f -> ~%.0f", pLast, predicted)
						break
					end
				end

				-- 4) отпускание M1
				mouseUp()

				-- 5) ждём, пока сервер получит отпускание
				if not waitFor(Kit.rtt(S) * 0.5 + S.CamExtra) then
					return
				end

				-- 6) смотрим на мяч
				status = "смотрим на мяч"
				camOnBall = S.CamLookBall
				if S.FaceBall then
					hum.AutoRotate = false
					RunService:BindToRenderStep("YokattaFlickFace", Enum.RenderPriority.Last.Value, function()
						local ball = Kit.getFootball()
						if not ball or not root.Parent then
							return
						end
						local t3 = ball.Position + flat(ball.AssemblyLinearVelocity) * (Kit.rtt(S) * S.FaceLeadMult)
						local dir = flat(t3 - root.Position)
						if dir.Magnitude > 0.1 then
							root.CFrame = CFrame.lookAt(root.Position, root.Position + dir.Unit)
						end
					end)
				end

				if S.MoveCamera then
					if not waitFor(math.min(S.CamBallTime, S.FaceTime)) then
						return
					end
					restoreCamera()
					waitFor(math.max(S.FaceTime - S.CamBallTime, 0))
				else
					waitFor(S.FaceTime)
				end
			end)

			if not ok then
				warn("[Yokatta] FlickMacro: " .. tostring(err))
			end
			cleanup()
			status = cancelled and "отменено" or "готово"
		end

		local function trigger()
			if not S.Enabled or not VIM then
				return
			end
			if running then
				cancelled = true
			else
				task.spawn(runMacro)
			end
		end

		------------------------------------------------------------
		-- UI
		------------------------------------------------------------
		UI.Section(h, "FLICK MACROS")
		UI.Toggle(h, "Разрешить макрос", S.Enabled, function(v)
			S.Enabled = v
			if not v then
				cancelled = true
			end
			refreshWidget()
		end)
		Kit.bindRow(h, "Бинд запуска / отмены", S, "Key", { canClear = true })
		UI.Button(h, "Запустить / отменить сейчас", trigger)
		UI.Toggle(h, "Bolo режим (только здесь)", S.Bolo, function(v)
			S.Bolo = v
			refreshWidget()
		end)

		UI.Note(
			h,
			"Зажимает M1 до нужного Power (с поправкой на пинг), опционально поднимает камеру вверх, при необходимости выбирает закрутку и после удара смотрит на мяч. Повторное нажатие бинда во время работы отменяет макрос. Режим Bolo переключается только в этой панели. Если выключить «Двигать камеру», камера не трогается вообще."
		)

		local gPow = Kit.foldout(h, "Сила (Power)")
		UI.Section(gPow, "NORMAL")
		Kit.slider(gPow, S, "Normal: от", 1, 100, "NormalLo", 0)
		Kit.slider(gPow, S, "Normal: до", 1, 100, "NormalHi", 0)
		UI.Section(gPow, "BOLO")
		Kit.slider(gPow, S, "Bolo: от", 1, 100, "BoloLo", 0)
		Kit.slider(gPow, S, "Bolo: до", 1, 100, "BoloHi", 0)
		UI.Section(gPow, "ОБЩЕЕ")
		Kit.slider(gPow, S, "Позиция в диапазоне (0 = низ, 1 = верх)", 0, 1, "TargetFrac", 2)
		Kit.slider(gPow, S, "Не запускать, если Power уже выше", 0, 100, "ChargingMaxPower", 0)
		Kit.slider(gPow, S, "Скорость набора (запасная, ед/сек)", 5, 300, "DefaultPowerRate", 0)
		Kit.slider(gPow, S, "Мин. удержание (сек)", 0, 1, "MinHold", 2)
		Kit.slider(gPow, S, "Таймаут удержания (сек)", 0.5, 10, "HoldTimeout", 1)

		local gCam = Kit.foldout(h, "Камера")
		Kit.toggle(gCam, S, "Двигать камеру (выкл = не трогать)", "MoveCamera", refreshWidget)
		Kit.slider(gCam, S, "Угол вверх (градусы)", 0, 89.9, "CamPitch", 1)
		Kit.slider(gCam, S, "Держать после отпускания (сек)", 0, 0.5, "CamExtra", 3)
		Kit.toggle(gCam, S, "После удара камера смотрит на мяч", "CamLookBall")
		Kit.slider(gCam, S, "Сколько смотреть на мяч (сек)", 0, 2, "CamBallTime", 2)

		local gFace = Kit.foldout(h, "Взгляд персонажа")
		Kit.toggle(gFace, S, "После удара персонаж смотрит на мяч", "FaceBall")
		Kit.slider(gFace, S, "Сколько секунд смотреть", 0, 2, "FaceTime", 2)
		Kit.slider(gFace, S, "Упреждение по мячу (× rtt)", 0, 3, "FaceLeadMult", 2)

		local gCurve = Kit.foldout(h, "Закрутка")
		Kit.toggle(gCurve, S, "Авто-выбор закрутки (если Curve пустой)", "AutoCurve")
		Kit.toggle(gCurve, S, "При равенстве: вправо (выкл = влево)", "CurveDefaultRight")
		Kit.toggle(gCurve, S, "Инвертировать стороны", "CurveInvert")
		Kit.slider(gCurve, S, "Макс. нажатий смены", 1, 8, "CurveMaxPresses", 0)
		Kit.slider(gCurve, S, "Ожидание обновления Curve (сек)", 0, 1, "CurveWait", 2)
		Kit.slider(gCurve, S, "Радиус учёта оппонентов", 10, 200, "CurveRadius", 0)
		Kit.slider(gCurve, S, "Оппонент «сзади» до (студы)", 0, 30, "CurveBehind", 1)
		Kit.bindRow(gCurve, "Кнопка закрутки в игре", S, "GameCurveKey", { noReserve = true })

		local gPing = Kit.foldout(h, "Пинг и задержки")
		Kit.slider(gPing, S, "Множитель пинга", 0, 4, "PingMult", 2)
		Kit.slider(gPing, S, "Поправка к rtt (сек)", -0.2, 0.5, "PingOffset", 3)
		Kit.slider(gPing, S, "Задержка кадра (сек)", 0, 0.1, "InputFrame", 3)
		Kit.slider(gPing, S, "Отпускать раньше на (сек)", -0.2, 0.3, "ReleaseExtra", 3)

		local gCond = Kit.foldout(h, "Условия и блокировки")
		UI.Section(gCond, "НЕ ЗАПУСКАТЬ, ЕСЛИ У МЕНЯ ЕСТЬ")
		Kit.listToggles(gCond, BLOCK)

		Kit.guiFoldout(h, "GUI Flick Macro", W)

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if gp or Kit.listening or Kit.swallowed == input or not S.Key then
				return
			end
			if input.KeyCode == S.Key then
				trigger()
			end
		end)

		player.CharacterRemoving:Connect(function()
			if running then
				cancelled = true
			end
		end)

		refreshWidget()

		shared.FlickMacro = {
			Settings = S,
			Run = trigger,
		}
	end

	local ok, err = pcall(initFlick)
	if not ok then
		warn("[Yokatta] FlickMacro: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: HEAD-TAP MACROS
-- Вставь сразу ПОСЛЕ блока Flick Macros (и ПЕРЕД разделом «СТАРТ»).
-- 1) сброс закрутки  2) зажим M1 до Power  3) (опц.) камера вверх, удар
-- 4) идём к точке падения мяча  5) после исчезновения Kick прыжок + второй удар.
-- Кнопка запускает / отменяет макрос.
------------------------------------------------------------
do
	local function initHeadTap()
		local h = Holders.AutoUse
		local Kit = shared.YokattaMacroKit
		if not h or not Kit then
			return
		end

		local player = Players.LocalPlayer
		local VIM = Kit.VIM
		local flat = Kit.flat

		pcall(function()
			RunService:UnbindFromRenderStep("YokattaHeadTapCamera")
		end)

		local S = {
			Enabled = true, -- разрешить макрос
			Key = nil, -- запуск / отмена
			GameCurveKey = Enum.KeyCode.R, -- смена закрутки в игре

			-- первый удар
			PowerTarget = 100,
			ResetCurve = true, -- жать R, пока Curve не станет пустым
			CurveMaxPresses = 4,
			CurveWait = 0.25,

			-- камера
			MoveCamera = true, -- false = камеру вообще не трогаем
			CamPitch = 89.9,
			CamPre = 0.05, -- камера уже вверху за N сек до отпускания
			CamExtra = 0.05, -- держим камеру вверху после отпускания

			-- второй удар (прыжок + заряд)
			JumpDelay = 0.6, -- через сколько после исчезновения Kick прыгаем
			SecondPower = 10, -- Power, при котором отпускаем M1 на втором ударе
			SecondTimeout = 1.0,
			ChargeTime = 0.4, -- запасное время зарядки
			M1StartExtra = 0, -- начать зажимать M1 раньше на N сек (+ раньше, - позже)
			KickWithJump = true, -- true: удар в момент прыжка; false: в верхней точке
			JumpSyncOffset = 0, -- (только KickWithJump) + удар позже прыжка
			JumpHeight = 5,
			JumpApexTime = 0, -- 0 = считается из высоты и гравитации
			JumpLag = 0.03,
			HitYOffset = 0,
			TimingExtra = 0, -- + позже
			SyncToBall = false, -- подгонять верх прыжка под мяч
			KickAppearTimeout = 1.0,
			KickGoneTimeout = 6,
			BallSyncTimeout = 8,

			-- мяч / точка падения
			LaunchVY = 20,
			GroundOffset = 3,
			WalkToLanding = true,
			ArriveRadius = 1.5,
			MaxWalkDist = 100,
			ShowMarker = true,

			-- пинг
			PingMult = 1,
			PingOffset = 0,
		}

		local BLOCK = {
			{ name = "Kick", enabled = true },
			{ name = "Dribbling", enabled = true },
		}

		local running, cancelled = false, false
		local status = "готов"

		local W = Kit.widget({
			name = "YokattaHeadTap", order = 988, x = 14, y = 88, w = 320, lines = 3,
			offText = "Head-Tap: ВЫКЛ",
		})

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local function refreshWidget()
			local char = player.Character
			local info = char and char:FindFirstChild("PlayerInfo")
			local pw = info and info:FindFirstChild("Power")
			local cv = info and info:FindFirstChild("Curve")
			if not S.Enabled then
				W.setStatus("off", "Head-Tap: ВЫКЛ" .. keyHint())
			elseif running then
				W.setStatus("danger", "Head-Tap: " .. status)
			else
				W.setStatus("on", "Head-Tap: " .. status)
			end
			W.setInfo(1, string.format("Power1: %d | Power2: %d | прыжок +%.2fс", S.PowerTarget, S.SecondPower, S.JumpDelay))
			W.setInfo(2, string.format("Power: %s | Curve: %s", pw and math.floor(pw.Value + 0.5) or "-", cv and (tostring(cv.Value) ~= "" and tostring(cv.Value) or "пусто") or "-"))
			W.setInfo(3, string.format("Пинг: %d мс | камера: %s", math.floor(Kit.ping() * 1000 + 0.5), S.MoveCamera and "двигаем" or "не трогаем"))
		end

		local infoTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			infoTimer += dt
			if infoTimer >= 0.1 then
				infoTimer = 0
				refreshWidget()
			end
		end)

		------------------------------------------------------------
		-- МАКРОС
		------------------------------------------------------------
		local function runMacro()
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local info = char and char:FindFirstChild("PlayerInfo")
			local iv = char and char:FindFirstChild("InstanceValue")
			local powerV = info and info:FindFirstChild("Power")
			if not (root and hum and iv and powerV) or hum.Health <= 0 then
				status = "нет данных персонажа"
				return
			end
			local blocked = Kit.hasAny(iv, BLOCK)
			if blocked then
				status = "заблокировано (" .. blocked .. ")"
				return
			end
			local charging = iv:FindFirstChild("ChargingKick") ~= nil

			running, cancelled = true, false

			local mouseDown = false
			local mousePos = UIS:GetMouseLocation()

			local camera = workspace.CurrentCamera
			local savedType = camera.CameraType
			local savedRot = camera.CFrame.Rotation
			local savedOffset = camera.CFrame.Position - root.Position
			local camMode = "up"
			local camTouched = false

			local state = { launched = false, landing = nil, hitT = nil, stamp = 0, walk = S.WalkToLanding }
			local tracking = false
			local trackConn = nil
			local marker = nil

			local function mouseUp()
				if mouseDown then
					mouseDown = false
					VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
				end
			end

			local function restoreCamera(immediate)
				if not camTouched then
					return
				end
				camMode = "restore"
				if not immediate then
					RunService.Heartbeat:Wait()
				end
				pcall(function()
					RunService:UnbindFromRenderStep("YokattaHeadTapCamera")
				end)
				camera.CameraType = savedType
				camTouched = false
			end

			local function cleanup()
				mouseUp()
				restoreCamera(true)
				tracking = false
				if trackConn then
					trackConn:Disconnect()
					trackConn = nil
				end
				if marker then
					marker:Destroy()
					marker = nil
				end
				if hum and hum.Parent then
					pcall(function()
						hum:Move(Vector3.zero, false)
					end)
				end
				running = false
			end

			local function waitFor(seconds)
				local t0 = os.clock()
				while os.clock() - t0 < seconds and not cancelled do
					RunService.Heartbeat:Wait()
				end
				return not cancelled
			end

			local function waitUntil(t)
				while os.clock() < t and not cancelled do
					RunService.Heartbeat:Wait()
				end
				return not cancelled
			end

			local ok, err = pcall(function()
				-- 1) Curve должен быть пустым
				local curveV = info:FindFirstChild("Curve")
				if S.ResetCurve and curveV and not Kit.curveEmpty(curveV.Value) then
					status = "сброс закрутки"
					for _ = 1, S.CurveMaxPresses do
						local before = tostring(curveV.Value)
						Kit.tapKey(S.GameCurveKey, 0.03)
						local t0 = os.clock()
						local limit = Kit.rtt(S) + S.CurveWait
						while os.clock() - t0 < limit and not cancelled and tostring(curveV.Value) == before do
							RunService.Heartbeat:Wait()
						end
						if cancelled then
							return
						end
						if Kit.curveEmpty(curveV.Value) then
							break
						end
					end
				end
				if cancelled then
					return
				end

				-- 2) зажим M1 до PowerTarget (+ замер скорости набора)
				status = "зарядка до " .. S.PowerTarget
				if not charging then
					mousePos = UIS:GetMouseLocation()
					mouseDown = true
					VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
				else
					mouseDown = true
				end

				local chargeRate = nil
				local tStart = os.clock()
				local p0 = powerV.Value
				while powerV.Value < S.PowerTarget do
					RunService.Heartbeat:Wait()
					if cancelled or not root.Parent or hum.Health <= 0 then
						return
					end
					if os.clock() - tStart > 6 then
						status = "Power не дошёл до " .. S.PowerTarget
						return
					end
				end
				local dtCharge = os.clock() - tStart
				if dtCharge > 0.1 and powerV.Value - p0 > 10 then
					chargeRate = (powerV.Value - p0) / dtCharge
				end

				-- 3) (опц.) камера вверх -> отпускание M1
				status = S.MoveCamera and "камера вверх, отпускание" or "отпускание"
				if S.MoveCamera then
					local look = flat(savedRot.LookVector)
					if look.Magnitude < 0.01 then
						look = flat(root.CFrame.LookVector)
					end
					if look.Magnitude < 0.01 then
						look = Vector3.new(0, 0, -1)
					end
					look = look.Unit
					local yaw = math.atan2(-look.X, -look.Z)

					local function camStep()
						local pos = root.Position + savedOffset
						if camMode == "restore" then
							camera.CFrame = CFrame.new(pos) * savedRot
						else
							camera.CFrame = CFrame.new(pos) * CFrame.fromEulerAnglesYXZ(math.rad(S.CamPitch), yaw, 0)
						end
					end

					camera.CameraType = Enum.CameraType.Scriptable
					camTouched = true
					RunService:BindToRenderStep("YokattaHeadTapCamera", Enum.RenderPriority.Last.Value, camStep)
					camStep()
				end

				if not waitFor(S.CamPre) then
					return
				end
				mouseUp()

				-- ловим мяч сразу после отпускания
				tracking = true
				trackConn = RunService.Heartbeat:Connect(function()
					if not tracking then
						return
					end
					local ball = Kit.getFootball()
					if not ball or not root.Parent then
						return
					end
					local v = ball.AssemblyLinearVelocity
					if not state.launched then
						if v.Y > S.LaunchVY then
							state.launched = true
						else
							return
						end
					end

					local lg = Kit.getLG()
					local refY = lg and lg.Position.Y or root.Position.Y
					local g = workspace.Gravity
					local p = ball.Position
					local radius = math.max(ball.Size.X, ball.Size.Y, ball.Size.Z) / 2
					local floorY = refY - S.GroundOffset + radius

					local disc = v.Y * v.Y + 2 * g * (p.Y - floorY)
					if disc >= 0 then
						local tl = (v.Y + math.sqrt(disc)) / g
						state.landing = Vector3.new(p.X + v.X * tl, floorY, p.Z + v.Z * tl)
					end

					local hitY = refY + S.JumpHeight + S.HitYOffset
					local d2 = v.Y * v.Y - 2 * g * (hitY - p.Y)
					state.hitT = d2 >= 0 and (v.Y + math.sqrt(d2)) / g or nil
					state.stamp = os.clock()

					if S.ShowMarker and state.landing then
						if not marker then
							marker = Instance.new("Part")
							marker.Shape = Enum.PartType.Ball
							marker.Size = Vector3.new(2, 2, 2)
							marker.Anchored = true
							marker.CanCollide = false
							marker.CanQuery = false
							marker.CanTouch = false
							marker.Material = Enum.Material.Neon
							marker.Color = Color3.fromRGB(255, 160, 0)
							marker.Transparency = 0.3
							marker.Parent = workspace
						end
						marker.Position = state.landing
					elseif marker and not S.ShowMarker then
						marker:Destroy()
						marker = nil
					end

					if state.walk and state.landing and hum.Parent then
						local delta = flat(state.landing - root.Position)
						if delta.Magnitude > S.ArriveRadius and delta.Magnitude <= S.MaxWalkDist then
							hum:Move(delta.Unit, false)
						else
							hum:Move(Vector3.zero, false)
						end
					end
				end)

				-- 4) держим камеру, пока сервер не получит отпускание, потом возвращаем
				if not waitFor(Kit.rtt(S) * 0.5 + S.CamExtra) then
					return
				end
				restoreCamera(false)

				-- 5) ждём Kick -> исчезновение Kick
				status = "ждём Kick"
				local tw = os.clock()
				local appearLimit = S.KickAppearTimeout + Kit.rtt(S)
				while not iv:FindFirstChild("Kick") and os.clock() - tw < appearLimit and not cancelled do
					RunService.Heartbeat:Wait()
				end
				if cancelled then
					return
				end
				if not iv:FindFirstChild("Kick") then
					status = "Kick не появился, второй удар отменён"
					return
				end

				status = "Kick есть, ждём исчезновения"
				local tg = os.clock()
				while iv:FindFirstChild("Kick") and os.clock() - tg < S.KickGoneTimeout and not cancelled do
					RunService.Heartbeat:Wait()
				end
				if cancelled then
					return
				end
				if iv:FindFirstChild("Kick") then
					status = "Kick не исчез, второй удар отменён"
					return
				end
				local tGone = os.clock()

				-- 6) расписание второго удара
				local g = workspace.Gravity
				local tApex = S.JumpApexTime > 0 and S.JumpApexTime or math.sqrt(2 * S.JumpHeight / g)

				local chargeT = S.ChargeTime
				if chargeRate and chargeRate > 0 then
					chargeT = S.SecondPower / chargeRate
				end

				local lead = S.KickWithJump and S.JumpSyncOffset or (tApex + S.JumpLag)
				local fixedRel = tGone + S.JumpDelay - Kit.rtt(S) + lead + S.TimingExtra

				local relWant = fixedRel
				if S.SyncToBall then
					status = "подгон под мяч"
					local tSync = os.clock()
					while not cancelled do
						RunService.Heartbeat:Wait()
						local now = os.clock()
						if not state.hitT or now - tSync > S.BallSyncTimeout then
							relWant = fixedRel
							break
						end
						local relBall = state.stamp + state.hitT - Kit.rtt(S) + S.TimingExtra
						relWant = math.max(relBall, fixedRel)
						if now >= relWant - chargeT - S.M1StartExtra - 0.008 then
							break
						end
					end
					if cancelled then
						return
					end
				end

				local now = os.clock()
				local tRel = math.max(relWant, now + chargeT)
				local tDown = tRel - chargeT - S.M1StartExtra
				local tJump = tRel - lead

				local events = {
					{ t = tDown, kind = "down", o = 1 },
					{ t = tJump, kind = "jump", o = 2 },
					{ t = tRel, kind = "up", o = 3 },
				}
				table.sort(events, function(a, b)
					if a.t ~= b.t then
						return a.t < b.t
					end
					return a.o < b.o
				end)

				status = "второй удар"
				for _, ev in ipairs(events) do
					if not waitUntil(ev.t) then
						return
					end

					if state.walk then
						state.walk = false
						pcall(function()
							hum:Move(Vector3.zero, false)
						end)
					end

					if ev.kind == "down" then
						mousePos = UIS:GetMouseLocation()
						mouseDown = true
						VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
					elseif ev.kind == "jump" then
						task.spawn(Kit.tapKey, Enum.KeyCode.Space, 0.03)
					else
						local twp = os.clock()
						while powerV.Value < S.SecondPower and os.clock() - twp < S.SecondTimeout and not cancelled do
							RunService.Heartbeat:Wait()
						end
						if cancelled then
							return
						end
						mouseUp()
					end
				end

				status = "готово"
				waitFor(0.2)
			end)

			if not ok then
				warn("[Yokatta] HeadTap: " .. tostring(err))
				status = "ошибка (см. консоль)"
			elseif cancelled then
				status = "отменено"
			end
			cleanup()
		end

		local function trigger()
			if not S.Enabled or not VIM then
				return
			end
			if running then
				cancelled = true
			else
				task.spawn(runMacro)
			end
		end

		------------------------------------------------------------
		-- UI
		------------------------------------------------------------
		UI.Section(h, "HEAD-TAP MACROS")
		UI.Toggle(h, "Разрешить макрос", S.Enabled, function(v)
			S.Enabled = v
			if not v then
				cancelled = true
			end
			refreshWidget()
		end)
		Kit.bindRow(h, "Бинд запуска / отмены", S, "Key", { canClear = true })
		UI.Button(h, "Запустить / отменить сейчас", trigger)

		UI.Note(
			h,
			"Первый удар: зажим M1 до Power (по умолчанию 100), мяч летит вверх, макрос идёт к точке падения. Второй удар: когда исчезает Kick, через «Прыжок после Kick» прыгает и бьёт (M1 отпускается в момент прыжка или в верхней точке). Повторное нажатие бинда отменяет макрос. Если выключить «Двигать камеру», камера не трогается."
		)

		local gPow = Kit.foldout(h, "Сила (Power)")
		Kit.slider(gPow, S, "Power первого удара", 10, 100, "PowerTarget", 0)
		Kit.slider(gPow, S, "Power второго удара", 1, 100, "SecondPower", 0)
		Kit.slider(gPow, S, "Макс. ожидание Power на втором (сек)", 0.1, 3, "SecondTimeout", 2)
		Kit.slider(gPow, S, "Запасное время зарядки (сек)", 0.05, 2, "ChargeTime", 2)

		local gJump = Kit.foldout(h, "Прыжок и второй удар (тайминги)")
		Kit.slider(gJump, S, "Прыжок после исчезновения Kick (сек)", 0, 3, "JumpDelay", 2)
		Kit.slider(gJump, S, "Начать M1 раньше на (сек)", -0.5, 1, "M1StartExtra", 3)
		Kit.toggle(gJump, S, "Удар в момент прыжка (выкл = в верхней точке)", "KickWithJump")
		Kit.slider(gJump, S, "Сдвиг удара от прыжка (сек)", -0.5, 0.5, "JumpSyncOffset", 3)
		Kit.slider(gJump, S, "Поправка момента отпускания (сек, + позже)", -0.5, 0.5, "TimingExtra", 3)
		Kit.slider(gJump, S, "Высота прыжка (студы)", 1, 20, "JumpHeight", 1)
		Kit.slider(gJump, S, "Время до верха прыжка (0 = авто)", 0, 1, "JumpApexTime", 3)
		Kit.slider(gJump, S, "Лаг от пробела до отрыва (сек)", 0, 0.3, "JumpLag", 3)
		Kit.slider(gJump, S, "Высота удара относительно центра", -5, 5, "HitYOffset", 2)
		Kit.toggle(gJump, S, "Подгонять верх прыжка под мяч", "SyncToBall")
		Kit.slider(gJump, S, "Макс. ожидание подгона (сек)", 1, 15, "BallSyncTimeout", 1)
		Kit.slider(gJump, S, "Ждать появления Kick (сек)", 0.2, 3, "KickAppearTimeout", 2)
		Kit.slider(gJump, S, "Ждать исчезновения Kick (сек)", 1, 15, "KickGoneTimeout", 1)

		local gCam = Kit.foldout(h, "Камера")
		Kit.toggle(gCam, S, "Двигать камеру (выкл = не трогать)", "MoveCamera", refreshWidget)
		Kit.slider(gCam, S, "Угол вверх (градусы)", 0, 89.9, "CamPitch", 1)
		Kit.slider(gCam, S, "Камера вверху за N сек до отпускания", 0, 0.5, "CamPre", 3)
		Kit.slider(gCam, S, "Держать вверху после отпускания (сек)", 0, 0.5, "CamExtra", 3)

		local gBall = Kit.foldout(h, "Мяч и ходьба")
		Kit.toggle(gBall, S, "Идти к точке падения мяча", "WalkToLanding")
		Kit.toggle(gBall, S, "Показывать маркер падения", "ShowMarker")
		Kit.slider(gBall, S, "Скорость вверх = «мяч ударен»", 1, 100, "LaunchVY", 0)
		Kit.slider(gBall, S, "Высота центра над землёй", 0, 8, "GroundOffset", 2)
		Kit.slider(gBall, S, "Радиус прибытия (студы)", 0.2, 10, "ArriveRadius", 1)
		Kit.slider(gBall, S, "Макс. дистанция ходьбы (студы)", 10, 300, "MaxWalkDist", 0)

		local gCurve = Kit.foldout(h, "Закрутка")
		Kit.toggle(gCurve, S, "Сбрасывать закрутку (жать R до пустого)", "ResetCurve")
		Kit.slider(gCurve, S, "Макс. нажатий", 1, 8, "CurveMaxPresses", 0)
		Kit.slider(gCurve, S, "Ожидание обновления Curve (сек)", 0, 1, "CurveWait", 2)
		Kit.bindRow(gCurve, "Кнопка закрутки в игре", S, "GameCurveKey", { noReserve = true })

		local gPing = Kit.foldout(h, "Пинг")
		Kit.slider(gPing, S, "Множитель пинга", 0, 4, "PingMult", 2)
		Kit.slider(gPing, S, "Поправка к rtt (сек)", -0.2, 0.5, "PingOffset", 3)

		local gCond = Kit.foldout(h, "Условия и блокировки")
		UI.Section(gCond, "НЕ ЗАПУСКАТЬ, ЕСЛИ У МЕНЯ ЕСТЬ")
		Kit.listToggles(gCond, BLOCK)

		Kit.guiFoldout(h, "GUI Head-Tap", W)

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if gp or Kit.listening or Kit.swallowed == input or not S.Key then
				return
			end
			if input.KeyCode == S.Key then
				trigger()
			end
		end)

		player.CharacterRemoving:Connect(function()
			if running then
				cancelled = true
			end
		end)

		refreshWidget()

		shared.HeadTap = {
			Settings = S,
			Run = trigger,
		}
	end

	local ok, err = pcall(initHeadTap)
	if not ok then
		warn("[Yokatta] HeadTap: " .. tostring(err))
	end
end
------------------------------------------------------------
-- ВКЛАДКА AUTOUSE: AUTO DIVE
-- Вставь в САМЫЙ КОНЕЦ, после блока Head-Tap Macros
-- (и ПЕРЕД разделом «СТАРТ»). Нужен блок Macro Kit выше.
-- Призрак НЕ создаётся: берётся workspace.lagghost (делает LagGhost).
-- Если призрака нет, можно брать реального персонажа (настройка).
-- Всё выключено по умолчанию, GUI скрыт по умолчанию.
------------------------------------------------------------
do
	local function initAutoDive()
		local h = Holders.AutoUse
		local Kit = shared.YokattaMacroKit
		if not h or not Kit then
			return
		end

		local player = Players.LocalPlayer
		local StatsService = game:GetService("Stats")
		local VIM = Kit.VIM

		------------------------------------------------------------
		-- НАСТРОЙКИ (всё меняется из панели)
		------------------------------------------------------------
		local S = {
			Enabled = false,
			Key = nil, -- бинд вкл/выкл

			-- клавиши в игре
			GameDive = Enum.KeyCode.Q,
			GameLeft = Enum.KeyCode.A,
			GameRight = Enum.KeyCode.D,
			GameJump = Enum.KeyCode.Space,

			-- детекция мяча
			BallName = "Football",
			Radius = 85,
			MinSpeed = 64,
			Dot = 0.42,
			MinFwd = 0.9,
			NearLimit = 24, -- макс. дистанция траектории до цели (студы)
			HighY = 3.2, -- выше этого мяч считается высоким (прыжок)
			SimSteps = 35,
			SimDt = 0.04,

			-- скорость реакции
			MinT = 0.08, -- не нырять, если до мяча меньше (сек)
			MaxT = 0.75, -- не нырять, если до мяча больше (сек)
			Cooldown = 0.10, -- пауза между дайвами (сек)
			SideLead = 0.02, -- боковая клавиша за N сек до дайва
			JumpGap = 0.015, -- пауза между дайвом и прыжком
			DiveHold = 0.02, -- удержание клавиши дайва

			-- пинг
			UseRealPing = true,
			FallbackPingMs = 120,
			PingSmooth = 0.25, -- 1 = без сглаживания
			PingMin = 0,
			PingMax = 1,
			PingMult = 1, -- 1 = полный пинг, 0.5 = односторонний
			PingOffset = 0, -- + раньше, - позже

			-- поворот и прыжок
			UseJump = true,
			LockRotation = true, -- держать персонажа лицом по камере во время дайва
			LockTime = 0.8,
			UseRealIfNoGhost = true,

			-- GUI (по умолчанию скрыт)
			GuiShown = false,
		}

		------------------------------------------------------------
		-- ПИНГ
		------------------------------------------------------------
		local function readPing()
			local ok, ms = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and ms and ms > 0 then
				return ms / 1000
			end
			return nil
		end

		local pingSec = S.FallbackPingMs / 1000
		local function updatePing()
			if not S.UseRealPing then
				pingSec = S.FallbackPingMs / 1000
				return
			end
			local p = readPing()
			if p then
				p = math.clamp(p, S.PingMin, S.PingMax)
				pingSec = pingSec + (p - pingSec) * math.clamp(S.PingSmooth, 0.01, 1)
			end
		end

		local function getLead()
			return math.max(0, pingSec * S.PingMult + S.PingOffset)
		end

		------------------------------------------------------------
		-- СОСТОЯНИЕ
		------------------------------------------------------------
		local busy = false
		local lastDive = -10
		local dives = 0
		local lastKind = "—"
		local lockUntil = 0
		local injecting = {}
		local lastT, lastLead = nil, 0
		local usingGhost = false

		local W = Kit.widget({
			name = "YokattaAutoDive", order = 987, x = 86, y = 28, w = 300, lines = 3,
			offText = "Auto Dive: ВЫКЛ",
		})
		W.frame.Visible = false

		local function keyHint()
			return S.Key and (" [" .. S.Key.Name .. "]") or ""
		end

		local function refreshOffText()
			if not S.Enabled then
				W.setStatus("off", "Auto Dive: ВЫКЛ" .. keyHint())
			end
		end

		local function setEnabled(v)
			S.Enabled = v and true or false
			if S.Enabled then
				W.setStatus("on", "Auto Dive: ВКЛ")
			else
				refreshOffText()
			end
		end
		refreshOffText()

		------------------------------------------------------------
		-- ПРИЗРАК
		------------------------------------------------------------
		local function getOrigin(char)
			local lg = Kit.getLG()
			if lg then
				usingGhost = true
				return lg.CFrame, lg.Parent
			end
			usingGhost = false
			if S.UseRealIfNoGhost then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					return hrp.CFrame, nil
				end
			end
			return nil, nil
		end

		------------------------------------------------------------
		-- ТРАЕКТОРИЯ (относительно призрака)
		------------------------------------------------------------
		local function trajectory(pos, vel, origin)
			local best, bestD, bestH = nil, 1e9, -999
			local g = Vector3.new(0, -workspace.Gravity, 0)
			local p, v = pos, vel
			for _ = 1, math.max(1, math.floor(S.SimSteps)) do
				local dd = (p - origin).Magnitude
				if dd < bestD then
					bestD, best, bestH = dd, p, p.Y - origin.Y
				end
				v = v + g * S.SimDt
				p = p + v * S.SimDt
				if p.Y < -80 then
					break
				end
			end
			return best, bestD, bestH
		end

		------------------------------------------------------------
		-- ВВОД
		------------------------------------------------------------
		local function kd(k)
			if not k then
				return
			end
			injecting[k] = (injecting[k] or 0) + 1
			pcall(function()
				VIM:SendKeyEvent(true, k, false, game)
			end)
		end

		local function ku(k)
			if not k then
				return
			end
			pcall(function()
				VIM:SendKeyEvent(false, k, false, game)
			end)
			task.delay(0.15, function()
				injecting[k] = (injecting[k] or 1) - 1
				if injecting[k] <= 0 then
					injecting[k] = nil
				end
			end)
		end

		local function wt(t)
			local s = os.clock()
			while os.clock() - s < t do
				RunService.Heartbeat:Wait()
			end
		end

		local function doDive(char, toRight, jump)
			busy = true
			if S.LockRotation then
				lockUntil = os.clock() + S.LockTime
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.AutoRotate = false
				end
			end

			local sideKey = toRight and S.GameRight or S.GameLeft
			local ok, err = pcall(function()
				kd(sideKey)
				wt(S.SideLead)
				kd(S.GameDive)
				if jump then
					wt(S.JumpGap)
					kd(S.GameJump)
					wt(S.DiveHold)
					ku(S.GameDive)
					ku(S.GameJump)
				else
					wt(S.DiveHold)
					ku(S.GameDive)
				end
			end)
			-- гарантированно отпускаем всё
			ku(S.GameDive)
			ku(S.GameJump)
			ku(S.GameLeft)
			ku(S.GameRight)
			if not ok then
				warn("[Yokatta] AutoDive: " .. tostring(err))
			end

			lastDive = os.clock()
			dives += 1
			lastKind = jump and "DIVE+JUMP" or "DIVE"
			busy = false
		end

		-- фиксируем поворот по камере, пока идёт дайв
		RunService.RenderStepped:Connect(function()
			if lockUntil == 0 then
				return
			end
			local char = player.Character
			if os.clock() >= lockUntil then
				lockUntil = 0
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.AutoRotate = true
				end
				return
			end
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if not hrp or not cam then
				return
			end
			local f = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			if f.Magnitude > 0.1 then
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + f.Unit)
			end
		end)

		------------------------------------------------------------
		-- ОСНОВНОЙ ЦИКЛ
		------------------------------------------------------------
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude

		local infoTimer = 0
		RunService.Heartbeat:Connect(function(dt)
			updatePing()

			infoTimer += dt
			if infoTimer >= 0.2 then
				infoTimer = 0
				W.setInfo(1, string.format("Пинг %d мс | упреждение %d мс", math.floor(pingSec * 1000 + 0.5), math.floor(getLead() * 1000 + 0.5)))
				W.setInfo(2, string.format("Дайвов: %d | последний: %s", dives, lastKind))
				W.setInfo(3, string.format("Цель: %s | до мяча: %s", usingGhost and "lagghost" or "персонаж", lastT and string.format("%.2f с", lastT) or "—"))
			end

			if not S.Enabled then
				return
			end
			if not VIM then
				W.setStatus("warn", "Нет VirtualInputManager")
				return
			end
			if busy then
				W.setStatus("danger", "Дайв!")
				return
			end

			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (char and hum) or hum.Health <= 0 then
				W.setStatus("idle", "Нет персонажа")
				return
			end

			local cf, ghostModel = getOrigin(char)
			if not cf then
				W.setStatus("idle", "Нет призрака (lagghost)")
				return
			end

			W.setStatus("on", "Auto Dive: ВКЛ")

			if os.clock() - lastDive < S.Cooldown then
				return
			end

			local origin, look, right = cf.Position, cf.LookVector, cf.RightVector
			local lead = getLead()

			local ignore = { char }
			if ghostModel then
				ignore[2] = ghostModel
			end
			params.FilterDescendantsInstances = ignore

			lastT = nil
			for _, o in ipairs(workspace:GetPartBoundsInRadius(origin, S.Radius, params)) do
				if o:IsA("BasePart") and (o.Name == S.BallName or (o.Parent and o.Parent.Name == S.BallName)) then
					local vel = o.AssemblyLinearVelocity
					local sp = vel.Magnitude
					local to = origin - o.Position
					local dist = to.Magnitude
					if sp >= S.MinSpeed and dist <= S.Radius and dist > 0.1 then
						if vel.Unit:Dot(to.Unit) >= S.Dot then
							local fwd = vel:Dot(look)
							if math.abs(fwd) >= S.MinFwd then
								local t = to:Dot(look) / fwd
								local tAdj = t - lead -- жмём раньше на величину пинга
								lastT = tAdj
								if tAdj >= S.MinT and tAdj <= S.MaxT then
									local point, near, height = trajectory(o.Position, vel, origin)
									if point and near <= S.NearLimit then
										local side = right:Dot(point - origin)
										local jump = S.UseJump and height >= S.HighY
										task.spawn(doDive, char, side >= 0, jump)
										break
									end
								end
							end
						end
					end
				end
			end
		end)

		------------------------------------------------------------
		-- UI
		------------------------------------------------------------
		UI.Section(h, "AUTO DIVE")
		local mainToggle = UI.Toggle(h, "Auto Dive", false, setEnabled)
		Kit.bindRow(h, "Бинд вкл/выкл", S, "Key", { canClear = true, onChange = refreshOffText })

		UI.Note(
			h,
			"Ныряет за быстрым мячом (Football), летящим на призрака LagGhost (workspace.lagghost), с упреждением по пингу. Высокие мячи берёт с прыжком. Если призрака нет, может брать реального персонажа. Бинд: нажми кнопку справа, затем клавишу (Esc/Backspace — очистить). Скорость реакции настраивается в «Реакция и тайминги» и «Пинг»."
		)

		local gKeys = Kit.foldout(h, "Клавиши в игре")
		Kit.bindRow(gKeys, "Дайв", S, "GameDive", { noReserve = true })
		Kit.bindRow(gKeys, "Влево", S, "GameLeft", { noReserve = true })
		Kit.bindRow(gKeys, "Вправо", S, "GameRight", { noReserve = true })
		Kit.bindRow(gKeys, "Прыжок", S, "GameJump", { noReserve = true })

		local gReact = Kit.foldout(h, "Реакция и тайминги")
		Kit.slider(gReact, S, "Мин. время до мяча (сек)", 0, 0.5, "MinT", 3)
		Kit.slider(gReact, S, "Макс. время до мяча (сек)", 0.1, 2, "MaxT", 2)
		Kit.slider(gReact, S, "Пауза между дайвами (сек)", 0, 1, "Cooldown", 2)
		Kit.slider(gReact, S, "Боковая клавиша заранее (сек)", 0, 0.2, "SideLead", 3)
		Kit.slider(gReact, S, "Пауза дайв → прыжок (сек)", 0, 0.2, "JumpGap", 3)
		Kit.slider(gReact, S, "Удержание дайва (сек)", 0.01, 0.2, "DiveHold", 3)

		local gPing = Kit.foldout(h, "Пинг")
		Kit.toggle(gPing, S, "Реальный пинг", "UseRealPing")
		Kit.slider(gPing, S, "Запасной пинг (мс)", 0, 500, "FallbackPingMs", 0)
		Kit.slider(gPing, S, "Сглаживание (1 = нет)", 0.01, 1, "PingSmooth", 2)
		Kit.slider(gPing, S, "Множитель пинга", 0, 4, "PingMult", 2)
		Kit.slider(gPing, S, "Поправка (сек): + раньше, - позже", -0.3, 0.5, "PingOffset", 3)
		Kit.slider(gPing, S, "Мин. пинг (сек)", 0, 1, "PingMin", 3)
		Kit.slider(gPing, S, "Макс. пинг (сек)", 0.05, 2, "PingMax", 2)

		local gDet = Kit.foldout(h, "Детекция мяча")
		Kit.slider(gDet, S, "Радиус поиска (студы)", 10, 200, "Radius", 0)
		Kit.slider(gDet, S, "Мин. скорость мяча (студ/с)", 0, 200, "MinSpeed", 0)
		Kit.slider(gDet, S, "Направление на меня (dot)", -1, 1, "Dot", 2)
		Kit.slider(gDet, S, "Мин. скорость вдоль взгляда", 0, 5, "MinFwd", 2)
		Kit.slider(gDet, S, "Макс. промах траектории (студы)", 1, 60, "NearLimit", 1)
		Kit.slider(gDet, S, "Высота «высокого» мяча", 0, 15, "HighY", 1)
		Kit.slider(gDet, S, "Шагов симуляции", 5, 100, "SimSteps", 0)
		Kit.slider(gDet, S, "Шаг симуляции (сек)", 0.01, 0.1, "SimDt", 3)

		local gMove = Kit.foldout(h, "Прыжок и поворот")
		Kit.toggle(gMove, S, "Прыгать за высокими мячами", "UseJump")
		Kit.toggle(gMove, S, "Держать поворот по камере во время дайва", "LockRotation")
		Kit.slider(gMove, S, "Время фиксации поворота (сек)", 0.1, 2, "LockTime", 2)
		Kit.toggle(gMove, S, "Без призрака брать реального персонажа", "UseRealIfNoGhost")

		Kit.guiFoldout(h, "GUI Auto Dive", W)

		------------------------------------------------------------
		-- КЛАВИШИ
		------------------------------------------------------------
		UIS.InputBegan:Connect(function(input, gp)
			if gp or Kit.listening or Kit.swallowed == input or not S.Key then
				return
			end
			if injecting[input.KeyCode] then
				return
			end
			if input.KeyCode == S.Key then
				mainToggle.Set(not mainToggle.Get())
			end
		end)

		player.CharacterRemoving:Connect(function()
			lockUntil = 0
		end)

		shared.AutoDive = {
			Settings = S,
			SetEnabled = function(v)
				mainToggle.Set(v)
			end,
		}
	end

	local ok, err = pcall(initAutoDive)
	if not ok then
		warn("[Yokatta] AutoDive: " .. tostring(err))
	end
end
------------------------------------------------------------
-- СТАРТ
------------------------------------------------------------
selectTab(CONFIG.Tabs[1])
Persist.load()
task.spawn(function()
	while Gui.Parent do
		task.wait(3)
		Persist.save()
	end
end)
task.wait(0.1)
openPanel()

local API = {
	Gui = Gui,
	Colors = C,
	Look = Look, -- Look.SetTheme("black") / Look.SetLang("en")
	Pages = Holders, -- API.Pages.Stats / .Utilities / .Esp / .AutoUse / .Troll / .Settings
	Open = openPanel,
	Close = closePanel,
	Toggle = togglePanel,
	SelectTab = selectTab,
	UI = UI, -- компоненты для вкладок: Section / Note / Toggle / Choice / Slider / Button
	LagGhost = LagGhost,
}

if getgenv then
	getgenv().Yokatta = API
end

return API
