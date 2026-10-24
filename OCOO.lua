--!nocheck
--[[
	Frozen Client 1.0.0 - UI library for Roblox (Luau)
	Theme: Frost | Single-file module

	Usage:
		local Library = loadstring(game:HttpGet("RAW_URL"))()
		local Window = Library:CreateWindow({ Name = "Frozen Client", SaveConfig = true })
		local Tab = Window:CreateTab("Home")
		local Section = Tab:CreateSection("Main")
		Section:CreateButton({ Name = "Hello", Callback = function() print("hi") end })

	It can also be used as a ModuleScript (the file returns the library table).
]]

----------------------------------------------------------------------
-- Services
----------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------
local ASSETS = {
	Background = "rbxassetid://111437124063372",
	MobileButton = "rbxassetid://133727818261470",
	Home = "rbxassetid://279461710",
	Settings = "rbxassetid://9405931578",
	Config = "rbxassetid://17269884884",
}
local WHITE = Color3.new(1, 1, 1)
local TAB_DIM = Color3.fromRGB(205, 215, 240)
local SIDEBAR_W = 56
local SIDEBAR_GAP = 10

local Theme = {
	Background = Color3.fromRGB(14, 22, 44),
	Panel = Color3.fromRGB(78, 100, 150),
	Topbar = Color3.fromRGB(24, 36, 66),
	TopbarA = Color3.fromRGB(46, 70, 120),
	TopbarB = Color3.fromRGB(20, 32, 60),
	Sidebar = Color3.fromRGB(30, 44, 80),
	Element = Color3.fromRGB(12, 22, 46),
	ElementHover = Color3.fromRGB(28, 46, 88),
	Stroke = Color3.fromRGB(96, 128, 190),
	Track = Color3.fromRGB(40, 60, 100),
	Accent = Color3.fromRGB(96, 165, 250),
	AccentDark = Color3.fromRGB(59, 130, 246),
	AccentSoft = Color3.fromRGB(52, 84, 150),
	AccentText = Color3.fromRGB(186, 224, 255),
	Accent2 = Color3.fromRGB(165, 243, 252),
	Accent3 = Color3.fromRGB(196, 181, 253),
	Text = Color3.fromRGB(244, 250, 255),
	SubText = Color3.fromRGB(170, 190, 222),
	OnAccent = Color3.fromRGB(255, 255, 255),
	Success = Color3.fromRGB(74, 222, 128),
	Warning = Color3.fromRGB(251, 191, 36),
	Danger = Color3.fromRGB(248, 113, 113),
}
Theme.Gradient = ColorSequence.new(Theme.Accent, Theme.Accent2)
Theme.Ring = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.Accent),
	ColorSequenceKeypoint.new(0.35, Theme.Accent2),
	ColorSequenceKeypoint.new(0.7, Theme.Accent3),
	ColorSequenceKeypoint.new(1, Theme.Accent),
})

local FONT = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local TI_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_INSTANT = TweenInfo.new(0)
local TI_BACK = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TI_POP = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local MAX_NOTIFICATIONS = 5

----------------------------------------------------------------------
-- Generic helpers
----------------------------------------------------------------------
local function fail(message, level)
	error("[Frozen Client] " .. message, (level or 1) + 1)
end

local function normalizeCfg(cfg, caller, stringKey)
	if cfg == nil then
		return {}
	end
	if typeof(cfg) == "string" then
		return { [stringKey or "Name"] = cfg }
	end
	if typeof(cfg) ~= "table" then
		fail(caller .. " expects a table (got " .. typeof(cfg) .. ")", 3)
	end
	return cfg
end

local function opt(cfg, key, expected, default)
	local value = cfg[key]
	if value == nil then
		return default
	end
	if typeof(value) ~= expected then
		fail(string.format("option '%s' must be of type %s (got %s)", key, expected, typeof(value)), 4)
	end
	return value
end

local function fire(fn, ...)
	if typeof(fn) ~= "function" then
		return
	end
	task.spawn(function(...)
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[Frozen Client] callback error: " .. tostring(err))
		end
	end, ...)
end

local function isFinite(n)
	return typeof(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function decimalsOf(n)
	local text = string.format("%.10g", n)
	local frac = text:match("%.(%d+)$")
	return frac and #frac or 0
end

local function toImage(value)
	if typeof(value) == "number" then
		return "rbxassetid://" .. tostring(math.floor(value))
	end
	if typeof(value) == "string" and value ~= "" then
		if value:match("^%d+$") then
			return "rbxassetid://" .. value
		end
		return value
	end
	return ""
end

local function getViewport(gui)
	local size = gui and gui.AbsoluteSize or Vector2.new(0, 0)
	if size.X < 2 or size.Y < 2 then
		local camera = workspace.CurrentCamera
		size = camera and camera.ViewportSize or Vector2.new(1280, 720)
	end
	return size
end

----------------------------------------------------------------------
-- Instance helpers
----------------------------------------------------------------------
local function create(class, props, children)
	local inst = Instance.new(class)
	local parent
	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		else
			inst[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function tween(inst, goal, info)
	local t = TweenService:Create(inst, info or TI_MED, goal)
	t:Play()
	return t
end

local function corner(inst, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = inst })
end

local function stroke(inst, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst,
	})
end

local function padding(inst, top, right, bottom, left)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		Parent = inst,
	})
end

local function gradient(inst, rotation, sequence)
	return create("UIGradient", {
		Color = sequence or Theme.Gradient,
		Rotation = rotation or 0,
		Parent = inst,
	})
end

local function newLabel(props)
	local base = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}
	for key, value in pairs(props) do
		base[key] = value
	end
	return create("TextLabel", base)
end

local function newButton(props)
	local base = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Theme.Text,
	}
	for key, value in pairs(props) do
		base[key] = value
	end
	return create("TextButton", base)
end

local function hoverColor(trigger, target, normal, hovered)
	trigger.MouseEnter:Connect(function()
		tween(target, { BackgroundColor3 = hovered }, TI_FAST)
		local outline = target:FindFirstChildOfClass("UIStroke")
		if outline then
			tween(outline, { Color = Theme.Accent }, TI_MED)
		end
	end)
	trigger.MouseLeave:Connect(function()
		tween(target, { BackgroundColor3 = normal }, TI_FAST)
		local outline = target:FindFirstChildOfClass("UIStroke")
		if outline then
			tween(outline, { Color = Theme.Stroke }, TI_MED)
		end
	end)
end

local function candidateParents()
	local list = {}
	if type(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and typeof(result) == "Instance" then
			table.insert(list, result)
		end
	end
	table.insert(list, CoreGui)
	local player = Players.LocalPlayer
	if player then
		local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
		if playerGui then
			table.insert(list, playerGui)
		end
	end
	return list
end

local function createScreenGui(name)
	local parents = candidateParents()
	-- Remove stale instances left by a previous execution with the same name.
	for _, parent in ipairs(parents) do
		pcall(function()
			for _, child in ipairs(parent:GetChildren()) do
				if child:GetAttribute("KopoLibName") == name then
					child:Destroy()
				end
			end
		end)
	end
	local gui = create("ScreenGui", {
		Name = "FrozenClient",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
	})
	gui:SetAttribute("KopoLibName", name)
	for _, parent in ipairs(parents) do
		local ok = pcall(function()
			gui.Parent = parent
		end)
		if ok and gui.Parent == parent then
			return gui
		end
	end
	gui:Destroy()
	fail("could not parent the interface to gethui/CoreGui/PlayerGui", 3)
end

----------------------------------------------------------------------
-- File system layer (executor APIs, checked before use)
----------------------------------------------------------------------
local FS = {
	writefile = type(writefile) == "function" and writefile or nil,
	readfile = type(readfile) == "function" and readfile or nil,
	isfile = type(isfile) == "function" and isfile or nil,
	makefolder = type(makefolder) == "function" and makefolder or nil,
	isfolder = type(isfolder) == "function" and isfolder or nil,
	listfiles = type(listfiles) == "function" and listfiles or nil,
	delfile = type(delfile) == "function" and delfile or nil,
}
FS.supported = (FS.writefile ~= nil and FS.readfile ~= nil and FS.isfile ~= nil)

local function sanitizeName(name, fallback)
	local text = tostring(name or "")
	text = text:gsub("[^%w%-%_ ]", "_")
	text = text:gsub("^%s+", "")
	text = text:gsub("%s+$", "")
	if #text > 64 then
		text = text:sub(1, 64)
	end
	if text == "" then
		return fallback
	end
	return text
end

local function sanitizeFolder(folder, fallback)
	local text = tostring(folder or "")
	text = text:gsub("\\", "/")
	text = text:gsub("%.%.", "_")
	text = text:gsub("[^%w%-%_ /]", "_")
	text = text:gsub("/+", "/")
	text = text:gsub("^/", "")
	text = text:gsub("/$", "")
	if text == "" then
		return fallback
	end
	return text
end

local function ensureFolder(folder)
	if not FS.makefolder then
		return true
	end
	local built = ""
	for segment in folder:gmatch("[^/]+") do
		built = (built == "") and segment or (built .. "/" .. segment)
		local exists = false
		if FS.isfolder then
			local ok, result = pcall(FS.isfolder, built)
			exists = ok and result == true
		end
		if not exists then
			local ok, err = pcall(FS.makefolder, built)
			if not ok then
				return false, tostring(err)
			end
		end
	end
	return true
end

local function quote(text)
	local escaped = text:gsub('[%c"\\]', function(char)
		return string.format("\\%03d", char:byte())
	end)
	return '"' .. escaped .. '"'
end

local function luaLiteral(value)
	local kind = typeof(value)
	if kind == "boolean" then
		return tostring(value)
	elseif kind == "number" then
		if not isFinite(value) then
			return nil
		end
		return string.format("%.14g", value)
	elseif kind == "string" then
		return quote(value)
	elseif kind == "table" then
		local parts = {}
		for _, item in ipairs(value) do
			if typeof(item) ~= "string" then
				return nil
			end
			table.insert(parts, quote(item))
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	end
	return nil
end

-- Only data written by KopoLib itself passes this gate: after removing string
-- literals, nothing but braces, brackets, numbers, commas, '=', and the words
-- return/true/false may remain (no calls, loops or identifiers).
local function isSafeLuaConfig(source)
	if #source > 262144 then
		return false
	end
	local out = {}
	local i, n = 1, #source
	while i <= n do
		local ch = source:sub(i, i)
		if ch == '"' then
			i = i + 1
			local closed = false
			while i <= n do
				local c2 = source:sub(i, i)
				if c2 == "\\" then
					i = i + 2
				elseif c2 == '"' then
					closed = true
					i = i + 1
					break
				else
					i = i + 1
				end
			end
			if not closed then
				return false
			end
			table.insert(out, " ")
		else
			table.insert(out, ch)
			i = i + 1
		end
	end
	local rest = table.concat(out)
	rest = rest:gsub("%f[%w]return%f[%W]", "")
	rest = rest:gsub("%f[%w]true%f[%W]", "")
	rest = rest:gsub("%f[%w]false%f[%W]", "")
	if rest:find("[^%s%[%]{}=,%d%.%-%+eE]") then
		return false
	end
	return true
end

local function parseKey(raw)
	if raw == nil then
		return true, nil
	end
	if typeof(raw) == "EnumItem" then
		if raw.EnumType ~= Enum.KeyCode then
			return false
		end
		if raw == Enum.KeyCode.Unknown then
			return true, nil
		end
		return true, raw
	end
	if typeof(raw) == "string" then
		if raw == "" or raw == "None" then
			return true, nil
		end
		local ok, key = pcall(function()
			return Enum.KeyCode[raw]
		end)
		if ok and key and key ~= Enum.KeyCode.Unknown then
			return true, key
		end
	end
	return false
end

----------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------
local KopoLib = {}
KopoLib.__index = KopoLib
KopoLib.Version = "1.0.0"
KopoLib.Windows = {}
KopoLib.FileSupport = FS.supported

local WindowClass = {}
WindowClass.__index = WindowClass
local TabClass = {}
TabClass.__index = TabClass
local SectionClass = {}
SectionClass.__index = SectionClass
local ElementClass = {}
ElementClass.__index = ElementClass

----------------------------------------------------------------------
-- Element (shared methods)
----------------------------------------------------------------------
function ElementClass:SetVisible(visible)
	self.Visible = not not visible
	self.Frame.Visible = self.Visible
	return self
end

function ElementClass:SetName(text)
	self.Name = tostring(text)
	if self._title then
		self._title.Text = self.Name
	end
	return self
end

function ElementClass:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	for _, cleanup in ipairs(self._cleanups) do
		pcall(cleanup)
	end
	self.Window:_unregister(self)
	self.Frame:Destroy()
end

----------------------------------------------------------------------
-- Section
----------------------------------------------------------------------
function SectionClass:_nextOrder()
	self._order = self._order + 1
	return self._order
end

function SectionClass:_base(kind, cfg, caller, opts)
	opts = opts or {}
	local window = self.Window
	window:_assertAlive(caller)
	local c = normalizeCfg(cfg, caller)

	local name
	if opts.noName then
		name = opt(c, "Name", "string", "")
	else
		name = opt(c, "Name", "string")
		if not name or name == "" then
			fail(caller .. " requires a non-empty 'Name' string", 3)
		end
	end
	local desc = opt(c, "Description", "string")
	if desc == "" then
		desc = nil
	end

	local baseHeight = desc and 46 or 34
	local totalHeight = baseHeight + (opts.extra or 0)

	local el = setmetatable({
		Kind = kind,
		Name = name,
		Section = self,
		Window = window,
		Visible = true,
		BaseHeight = baseHeight,
		Height = totalHeight,
		_cleanups = {},
		_destroyed = false,
	}, ElementClass)

	if opts.flag then
		local explicit = opt(c, "Flag", "string")
		el.Save = opt(c, "Save", "boolean", true)
		el.Flag = window:_claimFlag(explicit, string.format("%s/%s/%s", self.Tab.Name, self.Name, name), el)
	end
	el.NotifyOverride = opt(c, "Notify", "boolean")
	el.CallOnInit = opt(c, "CallOnInit", "boolean", false)

	local frame
	if opts.bare then
		frame = create("Frame", {
			Name = kind,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, opts.bareHeight or 0),
			AutomaticSize = opts.bareHeight and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
			LayoutOrder = self:_nextOrder(),
			Parent = self.Container,
		})
	else
		frame = create("Frame", {
			Name = kind,
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, totalHeight),
			ClipsDescendants = true,
			LayoutOrder = self:_nextOrder(),
			Parent = self.Container,
		})
		corner(frame, 6)
		stroke(frame, Theme.Stroke, 1)
		local reserve = opts.rightReserve or 0
		local compact = opts.compact or desc ~= nil
		el._title = newLabel({
			Name = "Title",
			Text = name,
			Position = UDim2.fromOffset(12, compact and 6 or 0),
			Size = UDim2.new(1, -(24 + reserve), 0, compact and 18 or 34),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
		if desc then
			el._desc = newLabel({
				Name = "Description",
				Text = desc,
				Font = FONT,
				TextSize = 11,
				TextColor3 = Theme.SubText,
				Position = UDim2.fromOffset(12, 24),
				Size = UDim2.new(1, -(24 + reserve), 0, 14),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = frame,
			})
		end
	end
	el.Frame = frame

	table.insert(self.Elements, el)
	table.insert(window._elements, el)
	return el, c
end

function SectionClass:CreateLabel(cfg)
	local c0 = normalizeCfg(cfg, "CreateLabel", "Text")
	local el, c = self:_base("Label", c0, "CreateLabel", { noName = true, bare = true })
	local text = opt(c, "Text", "string", c.Name or "")
	padding(el.Frame, 2, 0, 2, 0)
	el._title = newLabel({
		Name = "Text",
		Text = text,
		Font = FONT,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = el.Frame,
	})
	function el:SetText(value)
		return self:SetName(value)
	end
	function el:Get()
		return self.Name
	end
	el.Name = text
	return el
end

function SectionClass:CreateDivider(cfg)
	local c0 = normalizeCfg(cfg, "CreateDivider", "Text")
	local el, c = self:_base("Divider", c0, "CreateDivider", { noName = true, bare = true, bareHeight = 16 })
	local text = opt(c, "Text", "string")
	create("Frame", {
		Name = "Line",
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = el.Frame,
	})
	if text and text ~= "" then
		local label = newLabel({
			Name = "Text",
			Text = text,
			Font = FONT_BOLD,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			BackgroundTransparency = 0,
			BackgroundColor3 = Theme.Background,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 0, 0, 14),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = el.Frame,
		})
		padding(label, 0, 8, 0, 8)
		el._title = label
	end
	return el
end

function SectionClass:CreateButton(cfg)
	local el, c = self:_base("Button", cfg, "CreateButton", { rightReserve = 8 })
	local callback = opt(c, "Callback", "function")
	local frame = el.Frame

	local hit = newButton({ Name = "Hit", Size = UDim2.fromScale(1, 1), Parent = frame })
	local chevron = create("TextLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		Text = ">",
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Theme.Accent,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(12, 16),
		Parent = frame,
	})
	hoverColor(hit, frame, Theme.Element, Theme.ElementHover)
	local press = create("UIScale", { Scale = 1, Parent = frame })
	hit.MouseEnter:Connect(function()
		tween(chevron, { Position = UDim2.new(1, -8, 0.5, 0) }, TI_BACK)
	end)
	hit.MouseLeave:Connect(function()
		tween(chevron, { Position = UDim2.new(1, -12, 0.5, 0) }, TI_BACK)
		tween(press, { Scale = 1 }, TI_BACK)
	end)
	hit.MouseButton1Down:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.AccentSoft }, TI_FAST)
		tween(press, { Scale = 0.97 }, TI_FAST)
	end)
	hit.MouseButton1Up:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.ElementHover }, TI_FAST)
		tween(press, { Scale = 1 }, TI_BACK)
	end)
	hit.MouseButton1Click:Connect(function()
		fire(callback)
	end)

	function el:SetCallback(fn)
		if typeof(fn) ~= "function" then
			fail("Button:SetCallback expects a function", 2)
		end
		callback = fn
		return self
	end
	function el:Fire()
		fire(callback)
		return self
	end
	return el
end

function SectionClass:CreateToggle(cfg)
	local el, c = self:_base("Toggle", cfg, "CreateToggle", { flag = true, rightReserve = 52 })
	local window = el.Window
	local callback = opt(c, "Callback", "function")
	local value = opt(c, "Default", "boolean", false)
	local frame = el.Frame

	local track = create("Frame", {
		Name = "Track",
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(36, 18),
		Parent = frame,
	})
	corner(track, 9)
	local trackFill = create("Frame", {
		Name = "Fill",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = track,
	})
	corner(trackFill, 9)
	gradient(trackFill, 0)
	local knob = create("Frame", {
		Name = "Knob",
		BackgroundColor3 = Theme.OnAccent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Parent = track,
	})
	corner(knob, 7)
	local hit = newButton({ Name = "Hit", Size = UDim2.fromScale(1, 1), Parent = frame })
	hoverColor(hit, frame, Theme.Element, Theme.ElementHover)

	local function render(instant)
		tween(trackFill, { BackgroundTransparency = value and 0 or 1 }, instant and TI_INSTANT or TI_MED)
		tween(knob, { Position = value and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, instant and TI_INSTANT or TI_BACK)
	end

	local function setValue(v, source)
		local changed = v ~= value
		value = v
		render(false)
		if source ~= "silent" and (changed or source == "config") then
			fire(callback, value)
		end
		if changed then
			window:_changed(source)
		end
		return changed
	end

	hit.MouseButton1Click:Connect(function()
		if setValue(not value, "user") then
			window:_notifyChange(el, el.Name .. ": " .. (value and "Enabled" or "Disabled"), value and "Success" or "Info")
		end
	end)

	function el:Get()
		return value
	end
	function el:Set(v, silent)
		if typeof(v) ~= "boolean" then
			fail("Toggle:Set expects a boolean", 2)
		end
		setValue(v, silent and "silent" or "api")
		return self
	end
	function el:Toggle(silent)
		return self:Set(not value, silent)
	end
	el._serialize = function()
		return value
	end
	el._apply = function(raw)
		if typeof(raw) ~= "boolean" then
			return false
		end
		setValue(raw, "config")
		return true
	end
	el._initCall = function()
		fire(callback, value)
	end

	render(true)
	window:_finishElement(el)
	return el
end

function SectionClass:CreateSlider(cfg)
	local el, c = self:_base("Slider", cfg, "CreateSlider", { flag = true, compact = true, extra = 18, rightReserve = 84 })
	local window = el.Window
	local frame = el.Frame
	local min = opt(c, "Min", "number", 0)
	local max = opt(c, "Max", "number", 100)
	local inc = opt(c, "Increment", "number", 1)
	local suffix = opt(c, "Suffix", "string", "")
	local callback = opt(c, "Callback", "function")
	if not isFinite(min) or not isFinite(max) or min >= max then
		fail("CreateSlider: 'Min' must be a finite number lower than 'Max'", 2)
	end
	if not isFinite(inc) or inc <= 0 then
		fail("CreateSlider: 'Increment' must be a positive number", 2)
	end
	local decimals = math.max(decimalsOf(inc), decimalsOf(min), decimalsOf(max))
	decimals = math.min(decimals, 8)

	local function snap(v)
		v = math.clamp(v, min, max)
		v = min + math.floor((v - min) / inc + 0.5) * inc
		v = math.clamp(v, min, max)
		return tonumber(string.format("%." .. decimals .. "f", v))
	end
	local function format(v)
		return string.format("%." .. decimals .. "f", v) .. suffix
	end

	local defaultValue = opt(c, "Default", "number", min)
	if not isFinite(defaultValue) then
		fail("CreateSlider: 'Default' must be a finite number", 2)
	end
	local value = snap(defaultValue)

	local valueLabel = newLabel({
		Name = "Value",
		Text = format(value),
		TextColor3 = Theme.AccentText,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 6),
		Size = UDim2.fromOffset(72, 18),
		Parent = frame,
	})
	local barY = el.Height - 16
	local track = create("Frame", {
		Name = "Track",
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, barY),
		Size = UDim2.new(1, -24, 0, 6),
		Parent = frame,
	})
	corner(track, 3)
	local fill = create("Frame", {
		Name = "Fill",
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = track,
	})
	corner(fill, 3)
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	gradient(fill, 0)
	local knob = create("Frame", {
		Name = "Knob",
		BackgroundColor3 = Theme.OnAccent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(12, 12),
		Parent = fill,
	})
	corner(knob, 6)
	stroke(knob, Theme.Accent, 2)
	local hit = newButton({
		Name = "Hit",
		Position = UDim2.new(0, 6, 0, barY - 10),
		Size = UDim2.new(1, -12, 0, 26),
		Parent = frame,
	})

	local function render()
		valueLabel.Text = format(value)
		tween(fill, { Size = UDim2.fromScale((value - min) / (max - min), 1) }, TI_FAST)
	end

	local function setValue(v, source)
		v = snap(v)
		local changed = v ~= value
		value = v
		render()
		if source ~= "silent" and (changed or source == "config") then
			fire(callback, value)
		end
		if changed then
			window:_changed(source)
		end
		return changed
	end

	local dragConns = {}
	local dragging = false
	local changedWhileDragging = false
	local function setScrolling(enabled)
		local page = el.Section.Tab.Page
		if page then
			page.ScrollingEnabled = enabled
		end
	end
	local function stopDrag()
		for _, conn in ipairs(dragConns) do
			conn:Disconnect()
		end
		table.clear(dragConns)
		if dragging then
			dragging = false
			setScrolling(true)
			if changedWhileDragging then
				window:_notifyChange(el, el.Name .. ": " .. format(value), "Info")
			end
			changedWhileDragging = false
		end
	end
	local function updateFromX(x)
		local width = math.max(track.AbsoluteSize.X, 1)
		local rel = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
		if setValue(min + (max - min) * rel, "user") then
			changedWhileDragging = true
		end
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			stopDrag()
			dragging = true
			setScrolling(false)
			updateFromX(input.Position.X)
			table.insert(dragConns, UserInputService.InputChanged:Connect(function(changed)
				if dragging and (changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch) then
					updateFromX(changed.Position.X)
				end
			end))
			table.insert(dragConns, UserInputService.InputEnded:Connect(function(ended)
				if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
					stopDrag()
				end
			end))
		end
	end)
	table.insert(el._cleanups, stopDrag)

	function el:Get()
		return value
	end
	function el:Set(v, silent)
		if not isFinite(v) then
			fail("Slider:Set expects a finite number", 2)
		end
		setValue(v, silent and "silent" or "api")
		return self
	end
	el._serialize = function()
		return value
	end
	el._apply = function(raw)
		if not isFinite(raw) then
			return false
		end
		setValue(raw, "config")
		return true
	end
	el._initCall = function()
		fire(callback, value)
	end

	fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
	window:_finishElement(el)
	return el
end

local function copyOptions(list, caller)
	if typeof(list) ~= "table" then
		fail(caller .. ": 'Options' must be an array of strings", 3)
	end
	local out, seen = {}, {}
	for _, item in ipairs(list) do
		if typeof(item) ~= "string" then
			fail(caller .. ": every option must be a string (got " .. typeof(item) .. ")", 3)
		end
		if not seen[item] then
			seen[item] = true
			table.insert(out, item)
		end
	end
	return out
end

function SectionClass:CreateDropdown(cfg)
	local el, c = self:_base("Dropdown", cfg, "CreateDropdown", { flag = true, rightReserve = 140 })
	local window = el.Window
	local frame = el.Frame
	local options = copyOptions(opt(c, "Options", "table", {}), "CreateDropdown")
	local multi = opt(c, "Multi", "boolean", false)
	local callback = opt(c, "Callback", "function")
	local headerH = el.BaseHeight

	local optionSet = {}
	for _, item in ipairs(options) do
		optionSet[item] = true
	end
	local selection = {}
	local open = false
	local token = 0
	local buttons = {}

	local function ordered()
		local out = {}
		for _, item in ipairs(options) do
			if selection[item] then
				table.insert(out, item)
			end
		end
		return out
	end
	local function getValue()
		local list = ordered()
		if multi then
			return list
		end
		return list[1]
	end
	local function displayText()
		local list = ordered()
		if #list == 0 then
			return "None"
		end
		return table.concat(list, ", ")
	end
	local function listHeight()
		return math.min(#options * 26 + 6, 150)
	end

	-- Returns a selection set, or nil when the raw value is invalid.
	local function normalizeValue(raw)
		local set = {}
		if raw == nil or raw == "" then
			return set
		end
		if typeof(raw) == "string" then
			if optionSet[raw] then
				set[raw] = true
				return set
			end
			return nil
		end
		if typeof(raw) == "table" then
			if #raw == 0 then
				return set
			end
			local any = false
			for _, item in ipairs(raw) do
				if typeof(item) == "string" and optionSet[item] then
					any = true
					if multi or next(set) == nil then
						set[item] = true
					end
				end
			end
			if not any then
				return nil
			end
			if not multi then
				-- keep only the first option (in Options order)
				for _, item in ipairs(options) do
					if set[item] then
						return { [item] = true }
					end
				end
			end
			return set
		end
		return nil
	end

	local header = newButton({ Name = "Header", Size = UDim2.new(1, 0, 0, headerH), Parent = frame })
	hoverColor(header, frame, Theme.Element, Theme.ElementHover)
	local valueLabel = newLabel({
		Name = "Value",
		Text = "None",
		Font = FONT,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 0),
		Size = UDim2.new(0, 110, 0, headerH),
		Parent = frame,
	})
	local arrow = create("TextLabel", {
		Name = "Arrow",
		BackgroundTransparency = 1,
		Text = ">",
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Theme.Accent,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(14, headerH),
		Parent = frame,
	})
	local list = create("ScrollingFrame", {
		Name = "List",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, headerH + 4),
		Size = UDim2.new(1, -16, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = frame,
	})
	corner(list, 6)
	padding(list, 3, 3, 3, 3)
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local function updateVisuals()
		valueLabel.Text = displayText()
		for item, button in pairs(buttons) do
			local selected = selection[item] == true
			tween(button, {
				BackgroundColor3 = selected and Theme.AccentSoft or Theme.Element,
				TextColor3 = selected and Theme.AccentText or Theme.Text,
			}, TI_FAST)
		end
	end

	local function setOpen(state)
		open = state
		token = token + 1
		local mine = token
		if state then
			list.Visible = true
			list.Size = UDim2.new(1, -16, 0, listHeight())
			tween(frame, { Size = UDim2.new(1, 0, 0, headerH + 8 + listHeight()) }, TI_MED)
			tween(arrow, { Rotation = 90 }, TI_MED)
		else
			tween(frame, { Size = UDim2.new(1, 0, 0, headerH) }, TI_MED)
			tween(arrow, { Rotation = 0 }, TI_MED)
			task.delay(0.22, function()
				if token == mine and not el._destroyed then
					list.Visible = false
				end
			end)
		end
	end

	local function applySet(set, source)
		local before = table.concat(ordered(), "\31")
		selection = set
		local changed = before ~= table.concat(ordered(), "\31")
		updateVisuals()
		if source ~= "silent" and (changed or source == "config") then
			fire(callback, getValue())
		end
		if changed then
			window:_changed(source)
		end
		return changed
	end

	local function onPick(item)
		local set = {}
		if multi then
			for key in pairs(selection) do
				set[key] = true
			end
			set[item] = (not set[item]) or nil
		else
			set[item] = true
		end
		if applySet(set, "user") then
			window:_notifyChange(el, el.Name .. ": " .. displayText(), "Info")
		end
		if not multi then
			setOpen(false)
		end
	end

	local function buildOptions()
		for _, button in pairs(buttons) do
			button:Destroy()
		end
		table.clear(buttons)
		for index, item in ipairs(options) do
			local button = newButton({
				Name = "Option",
				Text = item,
				Font = FONT_MED,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Element,
				Size = UDim2.new(1, 0, 0, 24),
				LayoutOrder = index,
				Parent = list,
			})
			corner(button, 5)
			padding(button, 0, 6, 0, 8)
			button.MouseButton1Click:Connect(function()
				onPick(item)
			end)
			buttons[item] = button
		end
	end

	header.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)

	local defaultRaw = c.Default
	if defaultRaw ~= nil then
		local set = normalizeValue(defaultRaw)
		if not set then
			fail("CreateDropdown: 'Default' is not part of 'Options'", 2)
		end
		selection = set
	end
	buildOptions()
	updateVisuals()

	function el:Get()
		return getValue()
	end
	function el:Set(v, silent)
		local set = normalizeValue(v)
		if not set then
			fail("Dropdown:Set received a value that is not part of the options", 2)
		end
		applySet(set, silent and "silent" or "api")
		return self
	end
	function el:Clear(silent)
		applySet({}, silent and "silent" or "api")
		return self
	end
	function el:Refresh(newOptions, keepSelection)
		options = copyOptions(newOptions, "Dropdown:Refresh")
		optionSet = {}
		for _, item in ipairs(options) do
			optionSet[item] = true
		end
		local set = {}
		if keepSelection ~= false then
			for key in pairs(selection) do
				if optionSet[key] then
					set[key] = true
				end
			end
		end
		buildOptions()
		applySet(set, "api")
		if open then
			setOpen(true)
		end
		return self
	end
	el._serialize = function()
		local current = getValue()
		if multi then
			return current
		end
		return current or ""
	end
	el._apply = function(raw)
		local set = normalizeValue(raw)
		if not set then
			return false
		end
		applySet(set, "config")
		return true
	end
	el._initCall = function()
		if next(selection) ~= nil then
			fire(callback, getValue())
		end
	end

	window:_finishElement(el)
	return el
end

function SectionClass:CreateInput(cfg)
	local el, c = self:_base("Input", cfg, "CreateInput", { flag = true, rightReserve = 160 })
	local window = el.Window
	local frame = el.Frame
	local callback = opt(c, "Callback", "function")
	local placeholder = opt(c, "Placeholder", "string", "Type here...")
	local clearOnFocus = opt(c, "ClearOnFocus", "boolean", false)
	local numbersOnly = opt(c, "NumbersOnly", "boolean", false)
	local maxLength = opt(c, "MaxLength", "number")
	if maxLength ~= nil and (not isFinite(maxLength) or maxLength < 1) then
		fail("CreateInput: 'MaxLength' must be a positive number", 2)
	end
	local defaultRaw = c.Default
	if defaultRaw ~= nil and typeof(defaultRaw) ~= "string" and typeof(defaultRaw) ~= "number" then
		fail("CreateInput: 'Default' must be a string or number", 2)
	end

	local function sanitize(text)
		text = tostring(text)
		if numbersOnly then
			text = text:gsub("[^%d%.%-]", "")
		end
		if maxLength then
			local len = utf8.len(text)
			if len and len > maxLength then
				text = text:sub(1, utf8.offset(text, math.floor(maxLength) + 1) - 1)
			end
		end
		return text
	end

	local box = create("TextBox", {
		Name = "Box",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(150, 24),
		Font = FONT,
		TextSize = 12,
		TextColor3 = Theme.Text,
		PlaceholderText = placeholder,
		PlaceholderColor3 = Theme.SubText,
		ClearTextOnFocus = clearOnFocus,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
		Text = "",
		Parent = frame,
	})
	corner(box, 5)
	padding(box, 0, 6, 0, 6)
	local boxStroke = stroke(box, Theme.Stroke, 1)

	local value = defaultRaw ~= nil and sanitize(defaultRaw) or ""
	if numbersOnly and value ~= "" and tonumber(value) == nil then
		fail("CreateInput: 'Default' is not a valid number", 2)
	end
	box.Text = value

	local function callbackArg()
		if numbersOnly then
			return tonumber(value)
		end
		return value
	end

	local function setValue(text, source)
		text = sanitize(text)
		if numbersOnly and text ~= "" and tonumber(text) == nil then
			return false
		end
		local changed = text ~= value
		value = text
		if box.Text ~= text then
			box.Text = text
		end
		if source ~= "silent" and (changed or source == "config") then
			fire(callback, callbackArg())
		end
		if changed then
			window:_changed(source)
		end
		return changed
	end

	local sanitizing = false
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if sanitizing then
			return
		end
		local clean = sanitize(box.Text)
		if clean ~= box.Text then
			sanitizing = true
			box.Text = clean
			sanitizing = false
		end
	end)
	box.Focused:Connect(function()
		tween(boxStroke, { Color = Theme.Accent }, TI_FAST)
	end)
	box.FocusLost:Connect(function()
		tween(boxStroke, { Color = Theme.Stroke }, TI_FAST)
		local text = sanitize(box.Text)
		if numbersOnly and text ~= "" and tonumber(text) == nil then
			box.Text = value
			return
		end
		if setValue(text, "user") then
			window:_notifyChange(el, el.Name .. " updated", "Info")
		end
		box.Text = value
	end)

	function el:Get()
		return callbackArg()
	end
	function el:GetText()
		return value
	end
	function el:Set(v, silent)
		if typeof(v) ~= "string" and typeof(v) ~= "number" then
			fail("Input:Set expects a string or number", 2)
		end
		if not setValue(tostring(v), silent and "silent" or "api") and numbersOnly and tonumber(tostring(v)) == nil then
			fail("Input:Set received a non-numeric value for a NumbersOnly input", 2)
		end
		return self
	end
	el._serialize = function()
		return value
	end
	el._apply = function(raw)
		if typeof(raw) ~= "string" then
			return false
		end
		local clean = sanitize(raw)
		if numbersOnly and clean ~= "" and tonumber(clean) == nil then
			return false
		end
		setValue(clean, "config")
		return true
	end
	el._initCall = function()
		if value ~= "" then
			fire(callback, callbackArg())
		end
	end

	window:_finishElement(el)
	return el
end

function SectionClass:CreateKeybind(cfg)
	local el, c = self:_base("Keybind", cfg, "CreateKeybind", { flag = true, rightReserve = 108 })
	local window = el.Window
	local frame = el.Frame
	local callback = opt(c, "Callback", "function")
	local changedCallback = opt(c, "ChangedCallback", "function")
	local allowNone = opt(c, "AllowNone", "boolean", true)

	local okDefault, value = parseKey(c.Default)
	if not okDefault then
		fail("CreateKeybind: 'Default' must be an Enum.KeyCode or a valid key name", 2)
	end
	el.Value = value
	el._callback = callback

	local button = newButton({
		Name = "Key",
		Text = value and value.Name or "None",
		Font = FONT_MED,
		TextSize = 12,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Background,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(92, 24),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})
	corner(button, 5)
	local buttonStroke = stroke(button, Theme.Stroke, 1)
	hoverColor(button, frame, Theme.Element, Theme.ElementHover)

	local function render()
		if window._listening == el then
			button.Text = "..."
			tween(buttonStroke, { Color = Theme.Accent }, TI_FAST)
		else
			button.Text = el.Value and el.Value.Name or "None"
			tween(buttonStroke, { Color = Theme.Stroke }, TI_FAST)
		end
	end
	el._render = render

	local function setKey(key, source)
		local changed = key ~= el.Value
		el.Value = key
		render()
		if source ~= "silent" and (changed or source == "config") then
			fire(changedCallback, key or Enum.KeyCode.Unknown)
		end
		if changed then
			window:_changed(source)
		end
		return changed
	end

	el._capture = function(key)
		window:_setListening(nil)
		if key == Enum.KeyCode.Escape then
			return
		end
		if key == Enum.KeyCode.Backspace then
			if allowNone and setKey(nil, "user") then
				window:_notifyChange(el, el.Name .. ": None", "Info")
			end
			return
		end
		if key == Enum.KeyCode.Unknown then
			return
		end
		if setKey(key, "user") then
			window:_notifyChange(el, el.Name .. ": " .. key.Name, "Info")
		end
	end

	button.MouseButton1Click:Connect(function()
		if window._listening == el then
			window:_setListening(nil)
		else
			window:_setListening(el)
		end
	end)

	table.insert(window._keybinds, el)

	function el:Get()
		return self.Value
	end
	function el:Set(key, silent)
		local ok, parsed = parseKey(key)
		if not ok or (parsed == nil and not allowNone) then
			fail("Keybind:Set expects an Enum.KeyCode or a valid key name", 2)
		end
		setKey(parsed, silent and "silent" or "api")
		return self
	end
	el._serialize = function()
		return el.Value and el.Value.Name or "None"
	end
	el._apply = function(raw)
		if typeof(raw) ~= "string" then
			return false
		end
		local ok, parsed = parseKey(raw)
		if not ok or (parsed == nil and not allowNone) then
			return false
		end
		setKey(parsed, "config")
		return true
	end

	window:_finishElement(el)
	return el
end

----------------------------------------------------------------------
-- Tab
----------------------------------------------------------------------
function TabClass:CreateSection(cfg)
	self.Window:_assertAlive("CreateSection")
	local c = normalizeCfg(cfg, "CreateSection")
	local name = opt(c, "Name", "string")
	if not name or name == "" then
		fail("CreateSection requires a non-empty 'Name' string", 2)
	end
	self._sectionOrder = self._sectionOrder + 1
	local frame = create("Frame", {
		Name = "Section",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._sectionOrder,
		Parent = self.Page,
	})
	create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
	local header = newLabel({
		Name = "Header",
		Text = string.upper(name),
		Font = FONT_BOLD,
		TextSize = 11,
		TextColor3 = Theme.AccentText,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 0,
		Parent = frame,
	})
	padding(header, 0, 0, 0, 12)
	local headerBar = create("Frame", {
		Name = "Bar",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -10, 0.5, 0),
		Size = UDim2.fromOffset(3, 12),
		Parent = header,
	})
	corner(headerBar, 2)
	gradient(headerBar, 90)

	local section = setmetatable({
		Name = name,
		Tab = self,
		Window = self.Window,
		Container = frame,
		Header = header,
		Elements = {},
		_order = 0,
	}, SectionClass)
	table.insert(self.Sections, section)
	return section
end

function TabClass:Select()
	self.Window:SelectTab(self)
	return self
end

function TabClass:_setSelected(selected)
	self.Selected = selected
	local tint = selected and WHITE or TAB_DIM
	tween(self.Button, { BackgroundTransparency = selected and 0.12 or 1 }, TI_MED)
	tween(self.Glow, { Transparency = selected and 0 or 1 }, TI_MED)
	tween(self.Scale, { Scale = selected and 1.08 or 1 }, TI_POP)
	if self.IconLabel then
		tween(self.IconLabel, { ImageColor3 = tint }, TI_MED)
	end
	if self.Letter then
		tween(self.Letter, { TextColor3 = tint }, TI_MED)
	end
	if selected then
		self.Window:_setTitle(self.Title)
		self.Page.Position = UDim2.fromOffset(0, 14)
		self.Page.Visible = true
		tween(self.Page, { Position = UDim2.fromOffset(0, 0) }, TI_SLOW)
	else
		self.Page.Visible = false
	end
end

----------------------------------------------------------------------
-- Window: construction
----------------------------------------------------------------------
function WindowClass:_assertAlive(caller)
	if self._destroyed then
		fail(caller .. " was called on a destroyed window", 3)
	end
end

function WindowClass:_connect(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(self._conns, conn)
	return conn
end

function WindowClass:_claimFlag(explicit, auto, el)
	local flag
	if explicit then
		if explicit == "" then
			fail("'Flag' cannot be an empty string", 4)
		end
		if self.Flags[explicit] then
			fail("duplicate Flag '" .. explicit .. "'", 4)
		end
		flag = explicit
	else
		flag = auto
		local n = 2
		while self.Flags[flag] do
			flag = auto .. " (" .. n .. ")"
			n = n + 1
		end
	end
	self.Flags[flag] = el
	return flag
end

function WindowClass:_unregister(el)
	if el.Flag and self.Flags[el.Flag] == el then
		self.Flags[el.Flag] = nil
	end
	local index = table.find(self._keybinds, el)
	if index then
		table.remove(self._keybinds, index)
	end
	if self._listening == el then
		self._listening = nil
	end
	index = table.find(self._elements, el)
	if index then
		table.remove(self._elements, index)
	end
	index = table.find(el.Section.Elements, el)
	if index then
		table.remove(el.Section.Elements, index)
	end
end

function WindowClass:_finishElement(el)
	local applied = false
	if el.Flag and el.Save and el._apply and self._pending[el.Flag] ~= nil then
		local raw = self._pending[el.Flag]
		self._pending[el.Flag] = nil
		self._applying = true
		local ok, result = pcall(el._apply, raw)
		self._applying = false
		applied = ok and result == true
	end
	if not applied and el.CallOnInit and el._initCall then
		el._initCall()
	end
end

function WindowClass:_changed(source)
	if source == "config" or self._applying then
		return
	end
	self:_queueSave()
end

function WindowClass:_setListening(el)
	local previous = self._listening
	self._listening = el
	if previous and previous ~= el and previous._render then
		previous._render()
	end
	if el and el._render then
		el._render()
	end
end

function WindowClass:_buildLoader()
	local loader = create("Frame", {
		Name = "Loader",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(280, 196),
		ZIndex = 20,
		Parent = self.Gui,
	})
	corner(loader, 12)
	local loaderStroke = stroke(loader, Color3.new(1, 1, 1), 1.5)
	local loaderRing = gradient(loaderStroke, 0, Theme.Ring)
	self._loaderSpin = TweenService:Create(
		loaderRing,
		TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{ Rotation = 360 }
	)
	self._loaderSpin:Play()
	local scale = create("UIScale", { Scale = 1, Parent = loader })
	local icon = create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = self.Icon,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 56),
		Size = UDim2.fromOffset(60, 60),
		Parent = loader,
	})
	local nameLabel = newLabel({
		Name = "Name",
		Text = self.Name,
		Font = FONT_BOLD,
		TextSize = 18,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 10, 0, 94),
		Size = UDim2.new(1, -20, 0, 24),
		Parent = loader,
	})
	gradient(nameLabel, 0, Theme.Ring)
	local text = newLabel({
		Name = "Status",
		Text = "",
		Font = FONT_MED,
		TextSize = 14,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 10, 0, 122),
		Size = UDim2.new(1, -20, 0, 28),
		TextWrapped = true,
		Parent = loader,
	})
	local barBack = create("Frame", {
		Name = "BarBack",
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, -22),
		Size = UDim2.new(1, -40, 0, 4),
		Parent = loader,
	})
	corner(barBack, 2)
	local barFill = create("Frame", {
		Name = "Fill",
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = barBack,
	})
	corner(barFill, 2)
	barFill.BackgroundColor3 = Color3.new(1, 1, 1)
	gradient(barFill, 0)

	self.Loader = loader
	self.LoaderScale = scale
	self.LoaderIcon = icon
	self.LoaderText = text
	self.LoaderFill = barFill
	self._pulse = TweenService:Create(
		icon,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Size = UDim2.fromOffset(70, 70) }
	)
	self._pulse:Play()
end

function WindowClass:_setLoaderText(message, color, progress)
	if not self.Loader or self._destroyed then
		return
	end
	local label = self.LoaderText
	tween(label, { TextTransparency = 1 }, TI_FAST)
	task.wait(0.13)
	if self._destroyed then
		return
	end
	label.Text = message
	label.TextColor3 = color or Theme.AccentText
	tween(label, { TextTransparency = 0 }, TI_FAST)
	if progress then
		tween(self.LoaderFill, { Size = UDim2.fromScale(progress, 1) }, TI_SLOW)
	end
end

function WindowClass:_track(t, isFx)
	table.insert(self._tweens, t)
	if isFx then
		table.insert(self._fxTweens, t)
	end
	return t
end

function WindowClass:_spin(grad, seconds)
	local t = TweenService:Create(
		grad,
		TweenInfo.new(seconds, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{ Rotation = 360 }
	)
	t:Play()
	return self:_track(t, true)
end

-- Pauses / resumes the ambient effects (snow, rotating borders) while the window is hidden.
function WindowClass:_setFx(playing)
	self._fxOn = playing
	for _, t in ipairs(self._fxTweens) do
		pcall(function()
			if playing then
				t:Play()
			else
				t:Pause()
			end
		end)
	end
end

function WindowClass:_setTitle(text)
	local label = self.TitleLabel
	if not label or label.Text == text then
		return
	end
	self._titleToken = self._titleToken + 1
	local token = self._titleToken
	tween(label, { TextTransparency = 1 }, TI_FAST)
	task.delay(0.12, function()
		if token == self._titleToken and label.Parent then
			label.Text = text
			tween(label, { TextTransparency = 0 }, TI_FAST)
		end
	end)
end

function WindowClass:_showTip(button, text)
	local tip = self._tip
	if not tip or self._destroyed then
		return
	end
	self._tipToken = self._tipToken + 1
	tip.Label.Text = text
	local ratio = self.Scale.Scale
	if ratio <= 0 then
		ratio = 1
	end
	local y = (button.AbsolutePosition.Y - self.Main.AbsolutePosition.Y + button.AbsoluteSize.Y / 2) / ratio
	tip.Frame.Position = UDim2.fromOffset(SIDEBAR_W - 4, y)
	tip.Frame.Visible = true
	tween(tip.Frame, { Position = UDim2.fromOffset(SIDEBAR_W + 6, y), BackgroundTransparency = 0.1 }, TI_BACK)
	tween(tip.Label, { TextTransparency = 0 }, TI_FAST)
	tween(tip.Stroke, { Transparency = 0.2 }, TI_FAST)
end

function WindowClass:_hideTip()
	local tip = self._tip
	if not tip or self._destroyed then
		return
	end
	self._tipToken = self._tipToken + 1
	local token = self._tipToken
	tween(tip.Frame, { BackgroundTransparency = 1 }, TI_FAST)
	tween(tip.Label, { TextTransparency = 1 }, TI_FAST)
	tween(tip.Stroke, { Transparency = 1 }, TI_FAST)
	task.delay(0.14, function()
		if token == self._tipToken and tip.Frame.Parent then
			tip.Frame.Visible = false
		end
	end)
end

function WindowClass:_buildSnow(container)
	local count = self.Options.SnowCount
	if not self.Options.Snow or count <= 0 then
		return
	end
	local rng = Random.new()
	for _ = 1, count do
		local size = rng:NextInteger(2, 4)
		local startX = rng:NextNumber(0.02, 0.98)
		local endX = math.clamp(startX + rng:NextNumber(-0.08, 0.08), 0, 1)
		local duration = rng:NextNumber(7, 14)
		local flake = create("Frame", {
			Name = "Flake",
			BackgroundColor3 = WHITE,
			BackgroundTransparency = rng:NextNumber(0.2, 0.55),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(size, size),
			Position = UDim2.new(startX, 0, 0, -8),
			ZIndex = 3,
			Parent = container,
		})
		corner(flake, 2)
		local fall = TweenService:Create(
			flake,
			TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{ Position = UDim2.new(endX, 0, 1, 8) }
		)
		self:_track(fall, true)
		task.delay(rng:NextNumber(0, duration), function()
			if flake.Parent and not self._destroyed then
				fall:Play()
				if self._fxOn == false then
					fall:Pause()
				end
			end
		end)
	end
end

function WindowClass:_buildUI()
	local gui = self.Gui
	self._baseSize = self.Options.Size

	-- Root: sidebar + panel. Everything moves, scales and hides together.
	local main = create("Frame", {
		Name = "Main",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(self._baseSize.X, self._baseSize.Y),
		Position = UDim2.fromOffset(0, 0),
		Visible = false,
		Parent = gui,
	})
	local scale = create("UIScale", { Scale = 0.92, Parent = main })
	self.Main = main
	self.Scale = scale

	-- Glass panel -------------------------------------------------------------
	local panelX = SIDEBAR_W + SIDEBAR_GAP
	local panel = create("Frame", {
		Name = "Panel",
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(panelX, 0),
		Size = UDim2.new(1, -panelX, 1, 0),
		ClipsDescendants = true,
		Parent = main,
	})
	corner(panel, 16)
	gradient(panel, 90, ColorSequence.new(WHITE, Color3.fromRGB(170, 186, 224)))
	local panelStroke = stroke(panel, WHITE, 1.5)
	self._ringSpin = self:_spin(gradient(panelStroke, 0, Theme.Ring), 8)
	self.Panel = panel

	-- Title (also the drag handle)
	local dragBar = create("Frame", {
		Name = "DragBar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		ZIndex = 6,
		Parent = panel,
	})
	self.TitleLabel = newLabel({
		Name = "Title",
		Text = "Home Tab",
		Font = FONT_BOLD,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = dragBar,
	})

	-- Footer
	newLabel({
		Name = "Footer",
		Text = self.Name .. " " .. self.Version,
		Font = FONT_BOLD,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 0, 1, -30),
		Size = UDim2.new(1, 0, 0, 30),
		ZIndex = 6,
		Parent = panel,
	})

	-- Content: background image + readability veil + snow + pages ---------------
	local content = create("Frame", {
		Name = "Content",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(14, 34),
		Size = UDim2.new(1, -28, 1, -68),
		Parent = panel,
	})
	corner(content, 12)
	stroke(content, Theme.Stroke, 1, 0.45)
	local background = create("ImageLabel", {
		Name = "Background",
		BackgroundTransparency = 1,
		Image = ASSETS.Background,
		ScaleType = Enum.ScaleType.Crop,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.12, 1.12),
		ZIndex = 1,
		Parent = content,
	})
	self.BackgroundImage = background
	self:_track(
		TweenService:Create(
			background,
			TweenInfo.new(22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Position = UDim2.fromScale(0.465, 0.48) }
		),
		true
	):Play()
	create("Frame", {
		Name = "Veil",
		BackgroundColor3 = Color3.fromRGB(8, 14, 34),
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = content,
	})
	local snow = create("Frame", {
		Name = "Snow",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = content,
	})
	self:_buildSnow(snow)
	self.Content = content

	-- Floating sidebar (icons only) ---------------------------------------------
	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.22,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(0, SIDEBAR_W, 1, -32),
		Parent = main,
	})
	corner(sidebar, 18)
	gradient(sidebar, 90, ColorSequence.new(Color3.fromRGB(150, 128, 232), Color3.fromRGB(104, 146, 226)))
	local sidebarStroke = stroke(sidebar, WHITE, 1.5)
	self:_spin(gradient(sidebarStroke, 90, Theme.Ring), 8)

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.new(1, 0, 1, -72),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	})
	padding(tabList, 4, 0, 4, 0)
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = tabList,
	})
	self.Sidebar = sidebar
	self.TabList = tabList

	-- Close button (bottom of the sidebar)
	local closeButton = newButton({
		Name = "Close",
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(58, 36, 128),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -10),
		Size = UDim2.fromOffset(38, 38),
		Parent = sidebar,
	})
	corner(closeButton, 10)
	local closeStroke = stroke(closeButton, Theme.Accent3, 1.5, 0.35)
	local closeScale = create("UIScale", { Scale = 1, Parent = closeButton })
	for _, rotation in ipairs({ 45, -45 }) do
		local bar = create("Frame", {
			Name = "Bar",
			BackgroundColor3 = Color3.fromRGB(110, 140, 255),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = rotation,
			Size = UDim2.fromOffset(18, 3),
			Parent = closeButton,
		})
		corner(bar, 2)
	end
	closeButton.MouseEnter:Connect(function()
		tween(closeButton, { BackgroundColor3 = Theme.Danger }, TI_FAST)
		tween(closeStroke, { Transparency = 0 }, TI_FAST)
		tween(closeScale, { Scale = 1.1 }, TI_BACK)
	end)
	closeButton.MouseLeave:Connect(function()
		tween(closeButton, { BackgroundColor3 = Color3.fromRGB(58, 36, 128) }, TI_MED)
		tween(closeStroke, { Transparency = 0.35 }, TI_MED)
		tween(closeScale, { Scale = 1 }, TI_BACK)
	end)
	closeButton.MouseButton1Down:Connect(function()
		tween(closeScale, { Scale = 0.92 }, TI_FAST)
	end)
	closeButton.MouseButton1Click:Connect(function()
		if self.Settings.HideCloseAlert then
			self:Close()
		else
			self:_showCloseConfirm(true)
		end
	end)

	-- Tab tooltip (shared)
	local tipFrame = create("Frame", {
		Name = "Tooltip",
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		ZIndex = 40,
		Parent = main,
	})
	corner(tipFrame, 8)
	local tipStroke = stroke(tipFrame, Theme.Accent, 1, 1)
	padding(tipFrame, 0, 10, 0, 10)
	local tipLabel = newLabel({
		Name = "Text",
		Font = FONT_BOLD,
		TextSize = 12,
		TextTransparency = 1,
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 41,
		Parent = tipFrame,
	})
	self._tip = { Frame = tipFrame, Label = tipLabel, Stroke = tipStroke }

	-- Close confirmation (above everything in the panel)
	local overlay = create("Frame", {
		Name = "CloseOverlay",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Active = true,
		Visible = false,
		ZIndex = 50,
		Parent = panel,
	})
	local dialog = create("Frame", {
		Name = "Dialog",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(270, 124),
		Parent = overlay,
	})
	corner(dialog, 12)
	stroke(dialog, Theme.Stroke, 1)
	local dialogScale = create("UIScale", { Scale = 1, Parent = dialog })
	newLabel({
		Name = "Message",
		Text = "Are you sure you want to close?",
		Font = FONT_BOLD,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(14, 16),
		Size = UDim2.new(1, -28, 0, 44),
		Parent = dialog,
	})
	local function dialogButton(text, xScale, primary)
		local button = newButton({
			Name = text,
			Text = text,
			Font = FONT_BOLD,
			TextSize = 13,
			TextColor3 = primary and Theme.OnAccent or Theme.Text,
			BackgroundTransparency = 0,
			BackgroundColor3 = primary and Theme.AccentDark or Theme.Element,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(xScale, 0, 1, -14),
			Size = UDim2.fromOffset(112, 32),
			Parent = dialog,
		})
		corner(button, 8)
		if not primary then
			stroke(button, Theme.Stroke, 1)
		end
		hoverColor(button, button, primary and Theme.AccentDark or Theme.Element, primary and Theme.Accent or Theme.ElementHover)
		return button
	end
	local confirmButton = dialogButton("Confirm", 0.27, true)
	local cancelButton = dialogButton("Cancel", 0.73, false)
	confirmButton.MouseButton1Click:Connect(function()
		self:_showCloseConfirm(false)
		self:Close()
	end)
	cancelButton.MouseButton1Click:Connect(function()
		self:_showCloseConfirm(false)
	end)
	self.CloseOverlay = overlay
	self.DialogScale = dialogScale

	-- Notifications container
	self.NoteHolder = create("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 280, 1, -32),
		ZIndex = 10,
		Parent = gui,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Parent = self.NoteHolder,
	})

	-- Mobile button: opens / closes the UI. Visibility is decided by _updateMini
	-- (PC: never shown, mobile: always shown). Tap = toggle, drag = move it.
	local viewport = getViewport(gui)
	local mini = create("ImageButton", {
		Name = "MobileButton",
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Image = ASSETS.MobileButton,
		ScaleType = Enum.ScaleType.Crop,
		AutoButtonColor = false,
		Position = UDim2.fromOffset(14, math.floor(viewport.Y / 2) - 28),
		Size = UDim2.fromOffset(56, 56),
		Visible = false,
		ZIndex = 30,
		Parent = gui,
	})
	corner(mini, 28)
	local miniStroke = stroke(mini, WHITE, 2)
	self:_spin(gradient(miniStroke, 0, Theme.Ring), 5)
	local miniScale = create("UIScale", { Scale = 1, Parent = mini })
	self:_track(
		TweenService:Create(
			miniScale,
			TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Scale = 1.07 }
		),
		true
	):Play()
	self.MiniButton = mini

	local miniDragging, miniMoved = false, false
	local miniStart, miniOrigin = Vector2.new(0, 0), Vector2.new(0, 0)
	mini.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			miniDragging = true
			miniMoved = false
			miniStart = Vector2.new(input.Position.X, input.Position.Y)
			miniOrigin = Vector2.new(mini.Position.X.Offset, mini.Position.Y.Offset)
			local ended
			ended = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					miniDragging = false
					if ended then
						ended:Disconnect()
					end
					if not miniMoved then
						self:Toggle()
					end
				end
			end)
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if miniDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - miniStart
			if delta.Magnitude > 8 then
				miniMoved = true
			end
			if miniMoved then
				local vp = getViewport(self.Gui)
				mini.Position = UDim2.fromOffset(
					math.clamp(miniOrigin.X + delta.X, 4, math.max(vp.X - 60, 4)),
					math.clamp(miniOrigin.Y + delta.Y, 4, math.max(vp.Y - 60, 4))
				)
			end
		end
	end)

	self:_bindDrag(dragBar)
	self:_bindDrag(sidebar)
	self:_connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
		self:_fit()
	end)
	self:_connect(UserInputService:GetPropertyChangedSignal("KeyboardEnabled"), function()
		self:_updateMini()
	end)
	self:_connect(UserInputService:GetPropertyChangedSignal("TouchEnabled"), function()
		self:_updateMini()
	end)
	self:_connect(gui.Destroying, function()
		self:Destroy()
	end)
	self:_fit()
end

-- Layout is fully relative (sidebar fixed width, panel fills the rest).
function WindowClass:_applyLayout() end

function WindowClass:_setPosition(x, y)
	local viewport = getViewport(self.Gui)
	local size = self._size or self._baseSize
	local margin = 80
	local topInset = GuiService:GetGuiInset().Y
	local minX = -(size.X - margin)
	local maxX = viewport.X - margin
	local minY = math.min(topInset, math.max(viewport.Y - 42, 0))
	local maxY = math.max(viewport.Y - 42, minY)
	x = math.clamp(x, math.min(minX, maxX), math.max(minX, maxX))
	y = math.clamp(y, minY, maxY)
	self.Main.Position = UDim2.fromOffset(x, y)
end

function WindowClass:_center()
	local viewport = getViewport(self.Gui)
	local size = self._size or self._baseSize
	self:_setPosition(math.floor((viewport.X - size.X) / 2), math.floor((viewport.Y - size.Y) / 2))
end

function WindowClass:_fit()
	if self._destroyed or not self.Main then
		return
	end
	local viewport = getViewport(self.Gui)
	local width = math.max(200, math.min(self._baseSize.X, viewport.X - 24))
	local height = math.max(200, math.min(self._baseSize.Y, viewport.Y - 24))
	self._size = Vector2.new(width, height)
	self.Main.Size = UDim2.fromOffset(width, height)
	self:_applyLayout()
	if not self._positioned then
		self._positioned = true
		self:_center()
	else
		self:_setPosition(self.Main.Position.X.Offset, self.Main.Position.Y.Offset)
	end
end

function WindowClass:_bindDrag(handle)
	local dragging = false
	local dragStart = Vector2.new(0, 0)
	local startPos = Vector2.new(0, 0)
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = Vector2.new(self.Main.Position.X.Offset, self.Main.Position.Y.Offset)
			local ended
			ended = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if ended then
						ended:Disconnect()
					end
				end
			end)
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			self:_setPosition(startPos.X + delta.X, startPos.Y + delta.Y)
		end
	end)
end

function WindowClass:_bindInput()
	self:_connect(UserInputService.InputBegan, function(input, processed)
		if self._destroyed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local listening = self._listening
		if listening then
			listening._capture(input.KeyCode)
			return
		end
		if processed then
			return
		end
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
			return
		end
		for _, keybind in ipairs(self._keybinds) do
			if keybind.Value ~= nil and keybind.Value == input.KeyCode then
				fire(keybind._callback)
			end
		end
	end)
end

function WindowClass:_showCloseConfirm(show)
	if self._destroyed then
		return
	end
	if show then
		self.DialogScale.Scale = 0.9
		self.CloseOverlay.Visible = true
		tween(self.DialogScale, { Scale = 1 }, TI_MED)
	else
		self.CloseOverlay.Visible = false
	end
end

-- The mobile button follows the device: PC (keyboard present) never shows it,
-- touch-only devices always show it (it toggles the UI, also while it is open).
local function isMobileDevice()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function WindowClass:_updateMini()
	local mini = self.MiniButton
	if not mini then
		return
	end
	local mode = self.Options.MobileButton
	local show
	if mode == "Always" then
		show = true
	elseif mode == "Never" then
		show = false
	else
		show = isMobileDevice()
	end
	mini.Visible = show and self._revealed == true and not self._destroyed
end

----------------------------------------------------------------------
-- Window: loading sequence
----------------------------------------------------------------------
function WindowClass:_preloadAssets()
	local targets = {}
	for _, inst in ipairs({ self.BackgroundImage, self.MiniButton, self.LoaderIcon }) do
		if inst then
			table.insert(targets, inst)
		end
	end
	for _, tab in ipairs(self.Tabs) do
		if tab.IconLabel then
			table.insert(targets, tab.IconLabel)
		end
	end
	local done = false
	task.spawn(function()
		pcall(ContentProvider.PreloadAsync, ContentProvider, targets)
		done = true
	end)
	local started = os.clock()
	while not done and os.clock() - started < 4 and not self._destroyed do
		task.wait(0.05)
	end
end

function WindowClass:_initModules()
	if self.Options.SaveConfig and FS.supported then
		local ok, err = ensureFolder(self.ConfigFolder)
		if not ok then
			error("could not create config folder: " .. tostring(err))
		end
	end
end

function WindowClass:_runLoader()
	local animate = self.Options.LoadingScreen
	local steps = {
		{
			"Loading. . .",
			function()
				assert(self.Main and self.Gui and self.Gui.Parent, "interface was not created")
			end,
		},
		{ "Loading Module. . .", function() self:_initModules() end },
		{ "Loading UI. . .", function() self:_buildDefaultTabs() end },
		{ "Loading Assest. . .", function() self:_preloadAssets() end },
		{ "Success!", function() end },
	}
	local errors = {}
	for index, step in ipairs(steps) do
		if self._destroyed then
			return
		end
		if animate then
			self:_setLoaderText(step[1], Theme.Text, index / #steps)
		end
		local ok, err = pcall(step[2])
		if not ok then
			table.insert(errors, tostring(err))
			warn("[Frozen Client] initialization step '" .. step[1] .. "' failed: " .. tostring(err))
			if animate then
				self:_setLoaderText("Error: " .. tostring(err):sub(1, 80), Theme.Danger)
				task.wait(2.2)
			end
		end
		if animate and index < #steps then
			task.wait(0.5)
		end
	end
	if animate and not self._destroyed then
		task.wait(0.45)
	end
	self:_reveal()
	if #errors > 0 then
		self:Notify({
			Title = "Initialization warning",
			Content = errors[1]:sub(1, 120),
			Type = "Warning",
			Duration = 6,
			Force = true,
		})
	end
end

function WindowClass:_reveal()
	if self._destroyed or self._revealed then
		return
	end
	self._revealed = true
	if self._pulse then
		self._pulse:Cancel()
		self._pulse = nil
	end
	if self._loaderSpin then
		self._loaderSpin:Cancel()
		self._loaderSpin = nil
	end
	if self.Loader then
		local loader = self.Loader
		tween(self.LoaderScale, { Scale = 0.9 }, TI_MED)
		task.delay(0.2, function()
			if loader.Parent then
				loader:Destroy()
			end
		end)
		self.Loader = nil
	end
	self.Visible = true
	self.Main.Visible = true
	self.Scale.Scale = 0.85
	tween(self.Scale, { Scale = 1 }, TI_POP)
	if not self.ActiveTab and self.Tabs[1] then
		self:SelectTab(self.Tabs[1])
	end
	self:_updateMini()

	if self.Options.SaveConfig then
		local ok, message, code = self:LoadConfig(nil, nil)
		if ok then
			self:Notify({ Title = "Config", Content = message, Type = "Success", Duration = 3 })
		elseif code ~= "missing" and code ~= "unsupported" then
			self:Notify({ Title = "Config", Content = message, Type = "Error", Duration = 6, Force = true })
		end
	end
	for _, fn in ipairs(self._onLoaded) do
		fire(fn, self)
	end
	table.clear(self._onLoaded)
end

----------------------------------------------------------------------
-- Window: public API
----------------------------------------------------------------------
function WindowClass:OnLoaded(fn)
	if typeof(fn) ~= "function" then
		fail("OnLoaded expects a function", 2)
	end
	if self._revealed then
		fire(fn, self)
	else
		table.insert(self._onLoaded, fn)
	end
	return self
end

function WindowClass:_makeTab(name, icon, order)
	local button = newButton({
		Name = "Tab_" .. name,
		BackgroundColor3 = Theme.AccentSoft,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(42, 42),
		LayoutOrder = order,
		Parent = self.TabList,
	})
	corner(button, 12)
	local glow = stroke(button, Theme.Accent2, 1.5, 1)
	local btnScale = create("UIScale", { Scale = 1, Parent = button })
	local iconLabel, letter
	local image = toImage(icon)
	if image ~= "" then
		iconLabel = create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Image = image,
			ImageColor3 = TAB_DIM,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(24, 24),
			Parent = button,
		})
	else
		letter = newLabel({
			Name = "Letter",
			Text = string.upper(string.sub(name, 1, 1)),
			Font = FONT_BOLD,
			TextSize = 16,
			TextColor3 = TAB_DIM,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = button,
		})
	end
	local page = create("ScrollingFrame", {
		Name = "Page_" .. name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 5,
		Parent = self.Content,
	})
	padding(page, 10, 12, 10, 10)
	create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })

	local tab = setmetatable({
		Name = name,
		Title = name .. " Tab",
		Window = self,
		Button = button,
		Glow = glow,
		Scale = btnScale,
		IconLabel = iconLabel,
		Letter = letter,
		Page = page,
		Sections = {},
		Selected = false,
		_sectionOrder = 0,
	}, TabClass)

	button.MouseEnter:Connect(function()
		self:_showTip(button, name)
		if not tab.Selected then
			tween(button, { BackgroundTransparency = 0.55 }, TI_FAST)
			tween(btnScale, { Scale = 1.1 }, TI_BACK)
		end
	end)
	button.MouseLeave:Connect(function()
		self:_hideTip()
		if not tab.Selected then
			tween(button, { BackgroundTransparency = 1 }, TI_FAST)
			tween(btnScale, { Scale = 1 }, TI_BACK)
		end
	end)
	button.MouseButton1Down:Connect(function()
		tween(btnScale, { Scale = 0.92 }, TI_FAST)
	end)
	button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
		tween(btnScale, { Scale = tab.Selected and 1.08 or 1 }, TI_BACK)
	end)

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self:SelectTab(tab)
	end
	return tab
end

function WindowClass:CreateTab(cfg)
	self:_assertAlive("CreateTab")
	local c = normalizeCfg(cfg, "CreateTab")
	local name = opt(c, "Name", "string")
	if not name or name == "" then
		fail("CreateTab requires a non-empty 'Name' string", 2)
	end
	if name == "Home" and self.Home then
		return self.Home
	end
	self._tabOrder = self._tabOrder + 1
	return self:_makeTab(name, c.Icon, self._tabOrder)
end

function WindowClass:SelectTab(tabOrName)
	local target = tabOrName
	if typeof(tabOrName) == "string" then
		target = nil
		for _, tab in ipairs(self.Tabs) do
			if tab.Name == tabOrName then
				target = tab
				break
			end
		end
	end
	if not target or getmetatable(target) ~= TabClass then
		fail("SelectTab: tab not found", 2)
	end
	if self.ActiveTab == target then
		return self
	end
	local previous = self.ActiveTab
	self.ActiveTab = target
	if previous then
		previous:_setSelected(false)
	end
	target:_setSelected(true)
	return self
end

function WindowClass:SetVisible(visible)
	if self._destroyed or not self._revealed then
		return self
	end
	visible = not not visible
	if visible == self.Visible then
		return self
	end
	self.Visible = visible
	self._visibleToken = self._visibleToken + 1
	local token = self._visibleToken
	if visible then
		self.Main.Visible = true
		self:_setFx(true)
		self.Scale.Scale = 0.9
		tween(self.Scale, { Scale = 1 }, TI_POP)
	else
		self:_setListening(nil)
		tween(self.Scale, { Scale = 0.94 }, TI_FAST)
		task.delay(0.14, function()
			if token == self._visibleToken and not self._destroyed then
				self.Main.Visible = false
				self:_setFx(false)
			end
		end)
	end
	self:_updateMini()
	return self
end

function WindowClass:Toggle()
	return self:SetVisible(not self.Visible)
end

function WindowClass:IsVisible()
	return self.Visible == true
end

function WindowClass:SetToggleKey(key)
	local ok, parsed = parseKey(key)
	if not ok or parsed == nil then
		fail("SetToggleKey expects an Enum.KeyCode", 2)
	end
	self.ToggleKey = parsed
	if self._toggleKeyElement then
		self._toggleKeyElement:Set(parsed, true)
	end
	return self
end

function WindowClass:SetSetting(key, value)
	if typeof(self.Settings[key]) ~= "boolean" or typeof(value) ~= "boolean" then
		fail("SetSetting: valid keys are Notifications, NotifyOnChange, HideCloseAlert, AutoSave (boolean values)", 2)
	end
	self.Settings[key] = value
	local el = self._settingElements[key]
	if el then
		el:Set(value, true)
	end
	return self
end

function WindowClass:GetFlag(flag)
	local el = self.Flags[flag]
	if not el or not el.Get then
		return nil
	end
	return el:Get()
end

function WindowClass:SetFlag(flag, value, silent)
	local el = self.Flags[flag]
	if not el or not el.Set then
		fail("SetFlag: unknown flag '" .. tostring(flag) .. "'", 2)
	end
	el:Set(value, silent)
	return self
end

function WindowClass:Close()
	if self._destroyed or self._closing then
		return
	end
	self._closing = true
	if self.Main and self.Scale then
		tween(self.Scale, { Scale = 0.9 }, TI_MED)
	end
	task.delay(0.2, function()
		self:Destroy()
	end)
end

function WindowClass:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._saveToken = self._saveToken + 1
	for _, el in ipairs(table.clone(self._elements)) do
		for _, cleanup in ipairs(el._cleanups) do
			pcall(cleanup)
		end
	end
	for _, conn in ipairs(self._conns) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(self._conns)
	for _, spin in ipairs({ self._pulse, self._loaderSpin, self._ringSpin }) do
		pcall(function()
			spin:Cancel()
		end)
	end
	for _, t in ipairs(self._tweens) do
		pcall(function()
			t:Cancel()
		end)
	end
	table.clear(self._tweens)
	table.clear(self._fxTweens)
	for _, note in ipairs(table.clone(self._notes)) do
		note.dismissed = true
	end
	table.clear(self._notes)
	local gui = self.Gui
	self.Gui = nil
	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end
	table.clear(self.Flags)
	table.clear(self._keybinds)
	table.clear(self._elements)
	local index = table.find(KopoLib.Windows, self)
	if index then
		table.remove(KopoLib.Windows, index)
	end
end

----------------------------------------------------------------------
-- Window: notifications
----------------------------------------------------------------------
function WindowClass:Notify(cfg)
	if self._destroyed or not self.NoteHolder then
		return nil
	end
	if typeof(cfg) == "string" then
		cfg = { Content = cfg }
	end
	local c = normalizeCfg(cfg, "Notify")
	local force = opt(c, "Force", "boolean", false)
	if not self.Settings.Notifications and not force then
		return nil
	end
	local title = opt(c, "Title", "string", self.Name)
	local content = opt(c, "Content", "string", opt(c, "Description", "string", ""))
	local duration = opt(c, "Duration", "number", 4)
	local ntype = opt(c, "Type", "string", "Info")
	if not isFinite(duration) or duration < 0 then
		fail("Notify: 'Duration' must be a number >= 0 (0 keeps it until dismissed)", 2)
	end
	local styles = {
		Info = { Theme.Accent2, "i" },
		Success = { Theme.Success, "OK" },
		Warning = { Theme.Warning, "!" },
		Error = { Theme.Danger, "x" },
	}
	local style = styles[ntype] or styles.Info
	local color, glyph = style[1], style[2]

	self._noteId = self._noteId + 1
	local holder = create("Frame", {
		Name = "Note",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._noteId,
		Parent = self.NoteHolder,
	})
	local card = create("Frame", {
		Name = "Card",
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(1, 60, 0, 0),
		ClipsDescendants = true,
		Active = true,
		Parent = holder,
	})
	corner(card, 10)
	local cardStroke = stroke(card, color, 1.5, 0)
	local cardScale = create("UIScale", { Scale = 0.86, Parent = card })
	gradient(card, 0, ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 184, 214)))

	local badge = create("Frame", {
		Name = "Badge",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(26, 26),
		Size = UDim2.fromOffset(26, 26),
		Parent = card,
	})
	corner(badge, 13)
	local badgeScale = create("UIScale", { Scale = 0, Parent = badge })
	newLabel({
		Name = "Glyph",
		Text = glyph,
		Font = FONT_BOLD,
		TextSize = #glyph > 1 and 10 or 15,
		TextColor3 = Color3.fromRGB(20, 16, 36),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = badge,
	})

	local body = create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	padding(body, 11, 12, 15, 50)
	create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })
	newLabel({
		Name = "Title",
		Text = title,
		Font = FONT_BOLD,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 1,
		Parent = body,
	})
	if content ~= "" then
		newLabel({
			Name = "Content",
			Text = content,
			Font = FONT,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Parent = body,
		})
	end
	local bar
	if duration > 0 then
		bar = create("Frame", {
			Name = "Progress",
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 3),
			ZIndex = 2,
			Parent = card,
		})
	end

	local note = { dismissed = false }
	local function dismiss()
		if note.dismissed then
			return
		end
		note.dismissed = true
		local index = table.find(self._notes, note)
		if index then
			table.remove(self._notes, index)
		end
		if card.Parent then
			tween(card, { Position = UDim2.new(1, 60, 0, 0) }, TI_MED)
			tween(cardScale, { Scale = 0.9 }, TI_MED)
		end
		task.delay(0.25, function()
			if holder.Parent then
				holder:Destroy()
			end
		end)
	end
	note.Dismiss = dismiss
	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dismiss()
		end
	end)
	card.MouseEnter:Connect(function()
		tween(cardStroke, { Transparency = 0 }, TI_FAST)
	end)
	card.MouseLeave:Connect(function()
		tween(cardStroke, { Transparency = 0.55 }, TI_MED)
	end)

	table.insert(self._notes, note)
	while #self._notes > MAX_NOTIFICATIONS do
		self._notes[1].Dismiss()
	end

	-- Entrance: slide in with overshoot, glow flash on the border, badge pops.
	tween(card, { Position = UDim2.new(0, 0, 0, 0) }, TI_POP)
	tween(cardScale, { Scale = 1 }, TI_POP)
	tween(cardStroke, { Transparency = 0.55 }, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	task.delay(0.14, function()
		if not note.dismissed and badge.Parent then
			tween(badgeScale, { Scale = 1 }, TI_POP)
		end
	end)
	if bar then
		tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))
		task.delay(duration, dismiss)
	end
	return note
end

function WindowClass:_notifyChange(el, text, ntype)
	if self._destroyed or not self._revealed then
		return
	end
	if not self.Settings.NotifyOnChange then
		return
	end
	local override = el.NotifyOverride
	if override == false then
		return
	end
	if override == nil and el.Kind ~= "Toggle" then
		return
	end
	self:Notify({ Title = "Setting changed", Content = text, Type = ntype or "Info", Duration = 2.5 })
end

----------------------------------------------------------------------
-- Window: configuration (save / load)
----------------------------------------------------------------------
function WindowClass:_configPath(name, format)
	local cleanName = sanitizeName(name or self.ConfigName, "default")
	local fmt = format or self.ConfigFormat
	if fmt ~= "lua" then
		fmt = "json"
	end
	return self.ConfigFolder .. "/" .. cleanName .. "." .. fmt, cleanName, fmt
end

function WindowClass:_collect()
	local flags = {}
	for flag, el in pairs(self.Flags) do
		if el.Save and el._serialize then
			local ok, value = pcall(el._serialize)
			if ok and value ~= nil then
				flags[flag] = value
			end
		end
	end
	return flags
end

function WindowClass:_encode(format)
	local flags = self:_collect()
	if format == "lua" then
		local keys = {}
		for key in pairs(flags) do
			table.insert(keys, key)
		end
		table.sort(keys)
		local lines = { "return {", '\t["version"] = 1,', '\t["flags"] = {' }
		for _, key in ipairs(keys) do
			local literal = luaLiteral(flags[key])
			if literal then
				table.insert(lines, "\t\t[" .. quote(key) .. "] = " .. literal .. ",")
			end
		end
		table.insert(lines, "\t},")
		table.insert(lines, "}")
		return true, table.concat(lines, "\n") .. "\n"
	end
	local ok, result = pcall(HttpService.JSONEncode, HttpService, { version = 1, flags = flags })
	if not ok then
		return false, "JSON encode failed: " .. tostring(result)
	end
	return true, result
end

function WindowClass:_decode(text, format)
	if typeof(text) ~= "string" or text == "" then
		return false, "config content is empty"
	end
	local data
	if format == "lua" then
		if type(loadstring) ~= "function" then
			return false, "loadstring is unavailable; Lua config files cannot be loaded here"
		end
		if not isSafeLuaConfig(text) then
			return false, "Lua config rejected: it contains unexpected content"
		end
		local fn, err = loadstring(text, "=KopoConfig")
		if not fn then
			return false, "Lua config syntax error: " .. tostring(err)
		end
		pcall(setfenv, fn, {})
		local ok, result = pcall(fn)
		if not ok then
			return false, "Lua config failed to run: " .. tostring(result)
		end
		data = result
	else
		local ok, result = pcall(HttpService.JSONDecode, HttpService, text)
		if not ok then
			return false, "invalid JSON: " .. tostring(result)
		end
		data = result
	end
	if typeof(data) ~= "table" or typeof(data.flags) ~= "table" then
		return false, "config structure is invalid (missing 'flags')"
	end
	return true, data
end

function WindowClass:_applyData(flags)
	local applied, skipped = 0, 0
	self._applying = true
	for flag, raw in pairs(flags) do
		if typeof(flag) == "string" then
			local el = self.Flags[flag]
			if el and el.Save and el._apply then
				local ok, result = pcall(el._apply, raw)
				if ok and result == true then
					applied = applied + 1
				else
					skipped = skipped + 1
				end
			elseif not el then
				self._pending[flag] = raw
			end
		end
	end
	self._applying = false
	return applied, skipped
end

function WindowClass:SaveConfig(name, format)
	if not FS.supported then
		return false, "file API unavailable (writefile/readfile/isfile missing in this environment)", "unsupported"
	end
	local path, cleanName, fmt = self:_configPath(name, format)
	if fmt == "lua" and type(loadstring) ~= "function" then
		return false, "Lua format needs loadstring to be loaded back; use json here", "unsupported"
	end
	local okEncode, content = self:_encode(fmt)
	if not okEncode then
		return false, content, "encode"
	end
	local okFolder, folderErr = ensureFolder(self.ConfigFolder)
	if not okFolder then
		return false, "could not create folder: " .. tostring(folderErr), "io"
	end
	local ok, err = pcall(FS.writefile, path, content)
	if not ok then
		return false, "could not write file: " .. tostring(err), "io"
	end
	return true, string.format("Saved '%s' (%s)", cleanName, fmt), "ok"
end

function WindowClass:LoadConfig(name, format)
	if not FS.supported then
		return false, "file API unavailable (writefile/readfile/isfile missing in this environment)", "unsupported"
	end
	local first, cleanName, fmt = self:_configPath(name, format)
	local candidates = { { first, fmt } }
	if format == nil then
		local alt = fmt == "json" and "lua" or "json"
		table.insert(candidates, { (self:_configPath(name, alt)), alt })
	end
	local path, usedFormat
	for _, candidate in ipairs(candidates) do
		local ok, exists = pcall(FS.isfile, candidate[1])
		if ok and exists == true then
			path, usedFormat = candidate[1], candidate[2]
			break
		end
	end
	if not path then
		return false, "config file not found: " .. first, "missing"
	end
	local okRead, text = pcall(FS.readfile, path)
	if not okRead then
		return false, "could not read file: " .. tostring(text), "io"
	end
	local okDecode, data = self:_decode(text, usedFormat)
	if not okDecode then
		return false, data, "decode"
	end
	local applied, skipped = self:_applyData(data.flags)
	return true, string.format("Loaded '%s' (%d applied, %d skipped)", cleanName, applied, skipped), "ok"
end

function WindowClass:ListConfigs()
	local names, seen = {}, {}
	if not FS.listfiles then
		return names
	end
	local ok, files = pcall(FS.listfiles, self.ConfigFolder)
	if not ok or typeof(files) ~= "table" then
		return names
	end
	for _, path in ipairs(files) do
		if typeof(path) == "string" then
			local base = path:match("([^/\\]+)$")
			if base then
				local stem, ext = base:match("^(.*)%.(%w+)$")
				if stem and (ext == "json" or ext == "lua") and not seen[stem] then
					seen[stem] = true
					table.insert(names, stem)
				end
			end
		end
	end
	table.sort(names)
	return names
end

function WindowClass:DeleteConfig(name, format)
	if not FS.supported or not FS.delfile then
		return false, "delfile is unavailable in this environment", "unsupported"
	end
	local path, cleanName = self:_configPath(name, format)
	local okExists, exists = pcall(FS.isfile, path)
	if not okExists or exists ~= true then
		return false, "config file not found: " .. path, "missing"
	end
	local ok, err = pcall(FS.delfile, path)
	if not ok then
		return false, "could not delete file: " .. tostring(err), "io"
	end
	return true, "Deleted '" .. cleanName .. "'", "ok"
end

function WindowClass:ExportConfig()
	local ok, content = self:_encode("json")
	if not ok then
		return nil, content
	end
	return content
end

function WindowClass:ImportConfig(text)
	local ok, data = self:_decode(text, "json")
	if not ok then
		return false, data
	end
	local applied, skipped = self:_applyData(data.flags)
	return true, string.format("Imported (%d applied, %d skipped)", applied, skipped)
end

function WindowClass:_queueSave()
	if not self.Settings.AutoSave or self._applying or not self._revealed or not FS.supported or self._destroyed then
		return
	end
	self._saveToken = self._saveToken + 1
	local mine = self._saveToken
	task.delay(0.6, function()
		if mine ~= self._saveToken or self._destroyed then
			return
		end
		local ok, message, code = self:SaveConfig()
		if not ok and code ~= "unsupported" then
			self:Notify({ Title = "Auto save failed", Content = message, Type = "Error", Duration = 5, Force = true })
		end
	end)
end

----------------------------------------------------------------------
-- Window: built-in Config and Settings tabs
----------------------------------------------------------------------
function WindowClass:_buildConfigTab(tab)
	local status = tab:CreateSection("Status")
	if FS.supported then
		status:CreateLabel("File API available. Folder: " .. self.ConfigFolder .. (FS.listfiles and "" or " (listing configs is not supported here)"))
	else
		status:CreateLabel("File API is not available in this environment. Saving to disk is disabled; use Export / Import below.")
	end

	local profile = tab:CreateSection("Profile")
	local nameInput = profile:CreateInput({
		Name = "Config Name",
		Default = self.ConfigName,
		Placeholder = "default",
		Save = false,
		Callback = function(text)
			self.ConfigName = sanitizeName(text, "default")
		end,
	})
	local formats = { "json" }
	if type(loadstring) == "function" then
		table.insert(formats, "lua")
	end
	profile:CreateDropdown({
		Name = "Format",
		Options = formats,
		Default = table.find(formats, self.ConfigFormat) and self.ConfigFormat or "json",
		Save = false,
		Callback = function(value)
			self.ConfigFormat = value
		end,
	})
	local listDropdown = profile:CreateDropdown({
		Name = "Saved Configs",
		Options = self:ListConfigs(),
		Save = false,
		Callback = function(value)
			if value and value ~= "" then
				nameInput:Set(value)
			end
		end,
	})

	local function report(ok, message, success)
		self:Notify({
			Title = "Config",
			Content = message,
			Type = ok and (success or "Success") or "Error",
			Duration = ok and 3 or 5,
			Force = not ok,
		})
	end
	profile:CreateButton({
		Name = "Save Config",
		Callback = function()
			local ok, message = self:SaveConfig()
			report(ok, message)
			if ok then
				listDropdown:Refresh(self:ListConfigs())
			end
		end,
	})
	profile:CreateButton({
		Name = "Load Config",
		Callback = function()
			local ok, message = self:LoadConfig(nil, self.ConfigFormat)
			report(ok, message)
		end,
	})
	profile:CreateButton({
		Name = "Delete Config",
		Callback = function()
			local ok, message = self:DeleteConfig()
			report(ok, message, "Info")
			if ok then
				listDropdown:Refresh(self:ListConfigs())
			end
		end,
	})
	profile:CreateButton({
		Name = "Refresh List",
		Callback = function()
			listDropdown:Refresh(self:ListConfigs())
		end,
	})

	local behavior = tab:CreateSection("Behavior")
	self._settingElements.AutoSave = behavior:CreateToggle({
		Name = "Auto Save",
		Description = "Save automatically when an option changes.",
		Default = self.Settings.AutoSave,
		Save = false,
		Notify = false,
		Callback = function(value)
			self.Settings.AutoSave = value
		end,
	})

	local transfer = tab:CreateSection("Transfer")
	transfer:CreateButton({
		Name = "Export to Clipboard",
		Callback = function()
			local json, err = self:ExportConfig()
			if not json then
				report(false, tostring(err))
				return
			end
			if type(setclipboard) == "function" and pcall(setclipboard, json) then
				report(true, "Config copied to the clipboard.")
			else
				print("[Frozen Client] exported config:\n" .. json)
				report(true, "Clipboard unavailable; the JSON was printed to the console.", "Info")
			end
		end,
	})
	local importBox = transfer:CreateInput({
		Name = "Import JSON",
		Placeholder = "Paste JSON here",
		Save = false,
	})
	transfer:CreateButton({
		Name = "Import",
		Callback = function()
			local ok, message = self:ImportConfig(importBox:GetText())
			report(ok, message)
		end,
	})
end

function WindowClass:_buildSettingsTab(tab)
	local ui = tab:CreateSection("Interface")
	self._toggleKeyElement = ui:CreateKeybind({
		Name = "Toggle UI Key",
		Description = "Key used to hide and show the interface.",
		Default = self.ToggleKey,
		AllowNone = false,
		Flag = "Frozen.ToggleKey",
		ChangedCallback = function(key)
			if key and key ~= Enum.KeyCode.Unknown then
				self.ToggleKey = key
			end
		end,
	})
	self._settingElements.HideCloseAlert = ui:CreateToggle({
		Name = "Hide Close Alert",
		Description = "Close without asking for confirmation.",
		Default = self.Settings.HideCloseAlert,
		Flag = "Frozen.HideCloseAlert",
		Notify = false,
		Callback = function(value)
			self.Settings.HideCloseAlert = value
		end,
	})
	ui:CreateButton({
		Name = "Reset Window Position",
		Callback = function()
			self:_center()
		end,
	})

	local notes = tab:CreateSection("Notifications")
	self._settingElements.Notifications = notes:CreateToggle({
		Name = "Notifications",
		Description = "Master switch for all notifications.",
		Default = self.Settings.Notifications,
		Flag = "Frozen.Notifications",
		Notify = false,
		Callback = function(value)
			self.Settings.Notifications = value
		end,
	})
	self._settingElements.NotifyOnChange = notes:CreateToggle({
		Name = "Change Notifications",
		Description = "Notify when an option is enabled or disabled.",
		Default = self.Settings.NotifyOnChange,
		Flag = "Frozen.NotifyOnChange",
		Notify = false,
		Callback = function(value)
			self.Settings.NotifyOnChange = value
		end,
	})
	notes:CreateButton({
		Name = "Test Notification",
		Callback = function()
			self:Notify({ Title = "Frozen Client", Content = "This is a test notification.", Duration = 3 })
		end,
	})

	local win = tab:CreateSection("Window")
	win:CreateButton({
		Name = "Destroy UI",
		Callback = function()
			self:Close()
		end,
	})
end

function WindowClass:_buildDefaultTabs()
	local settingsTab = self:_makeTab("Settings", ASSETS.Settings, 10000)
	local configTab = self:_makeTab("Config", ASSETS.Config, 10001)
	self:_buildConfigTab(configTab)
	self:_buildSettingsTab(settingsTab)
end

----------------------------------------------------------------------
-- Library
----------------------------------------------------------------------
function KopoLib:CreateWindow(cfg)
	local c = normalizeCfg(cfg, "CreateWindow")
	local name = opt(c, "Name", "string", "Frozen Client")
	local saveConfig = opt(c, "SaveConfig", "boolean", false)
	local toggleKey = opt(c, "ToggleKey", "EnumItem", Enum.KeyCode.RightControl)
	if toggleKey.EnumType ~= Enum.KeyCode then
		fail("CreateWindow: 'ToggleKey' must be an Enum.KeyCode", 2)
	end
	local size = opt(c, "Size", "Vector2", Vector2.new(660, 440))
	if size.X < 300 or size.Y < 240 then
		fail("CreateWindow: 'Size' must be at least 300x240", 2)
	end
	local format = opt(c, "ConfigFormat", "string", "json")
	if format ~= "json" and format ~= "lua" then
		fail("CreateWindow: 'ConfigFormat' must be 'json' or 'lua'", 2)
	end
	local iconId = c.Icon
	if iconId ~= nil and typeof(iconId) ~= "string" and typeof(iconId) ~= "number" then
		fail("CreateWindow: 'Icon' must be an asset id (number/string)", 2)
	end

	local mobileMode = opt(c, "MobileButton", "string", "Auto")
	if mobileMode ~= "Auto" and mobileMode ~= "Always" and mobileMode ~= "Never" then
		fail("CreateWindow: 'MobileButton' must be \"Auto\", \"Always\" or \"Never\"", 2)
	end
	local snowCount = opt(c, "SnowCount", "number", 18)
	if not isFinite(snowCount) then
		fail("CreateWindow: 'SnowCount' must be a finite number", 2)
	end

	local options = {
		Name = name,
		Snow = opt(c, "Snow", "boolean", true),
		SnowCount = math.clamp(math.floor(snowCount), 0, 60),
		MobileButton = mobileMode,
		Subtitle = opt(c, "Subtitle", "string", ""),
		SaveConfig = saveConfig,
		Size = size,
		LoadingScreen = opt(c, "LoadingScreen", "boolean", true),
	}

	local window = setmetatable({
		Options = options,
		Name = name,
		Subtitle = options.Subtitle,
		Icon = iconId ~= nil and toImage(iconId) or ASSETS.MobileButton,
		Version = opt(c, "Version", "string", "v2"),
		ToggleKey = toggleKey,
		ConfigFolder = sanitizeFolder(opt(c, "ConfigFolder", "string", "FrozenClient"), "FrozenClient"),
		ConfigName = sanitizeName(opt(c, "ConfigFile", "string", "default"), "default"),
		ConfigFormat = format,
		Settings = {
			Notifications = opt(c, "Notifications", "boolean", true),
			NotifyOnChange = opt(c, "NotifyOnChange", "boolean", true),
			HideCloseAlert = opt(c, "HideCloseAlert", "boolean", false),
			AutoSave = opt(c, "AutoSave", "boolean", saveConfig),
		},
		Flags = {},
		Tabs = {},
		Visible = false,
		_conns = {},
		_tweens = {},
		_fxTweens = {},
		_titleToken = 0,
		_tipToken = 0,
		_pending = {},
		_elements = {},
		_keybinds = {},
		_notes = {},
		_onLoaded = {},
		_settingElements = {},
		_noteId = 0,
		_tabOrder = 0,
		_saveToken = 0,
		_visibleToken = 0,
		_destroyed = false,
		_revealed = false,
		_applying = false,
	}, WindowClass)

	window.Gui = createScreenGui(name)
	table.insert(KopoLib.Windows, window)

	if options.LoadingScreen then
		window:_buildLoader()
	end
	local ok, err = pcall(function()
		window:_buildUI()
		window:_bindInput()
		window.Home = window:_makeTab("Home", ASSETS.Home, 0)
	end)
	if not ok then
		warn("[Frozen Client] failed to build the interface: " .. tostring(err))
		if window.Loader then
			window:_setLoaderText("Error: " .. tostring(err):sub(1, 80), Theme.Danger)
			task.delay(3, function()
				window:Destroy()
			end)
		else
			window:Destroy()
		end
		fail("failed to build the interface: " .. tostring(err), 2)
	end

	-- The sequence starts on the next resumption cycle, so components created
	-- synchronously right after CreateWindow exist before the config is loaded.
	task.defer(function()
		local okRun, errRun = pcall(function()
			window:_runLoader()
		end)
		if not okRun then
			warn("[Frozen Client] loader failed: " .. tostring(errRun))
			window:_reveal()
		end
	end)
	-- Watchdog: never stay stuck on the loading screen.
	task.delay(25, function()
		if not window._destroyed and not window._revealed then
			warn("[Frozen Client] initialization timed out; showing the interface anyway")
			window:_reveal()
		end
	end)

	return window
end

function KopoLib:Notify(cfg)
	local window = KopoLib.Windows[#KopoLib.Windows]
	if not window then
		warn("[Frozen Client] Notify called without an active window")
		return nil
	end
	return window:Notify(cfg)
end

function KopoLib:Destroy()
	for _, window in ipairs(table.clone(KopoLib.Windows)) do
		window:Destroy()
	end
end

-- Exposed for advanced users who want to type-check classes.
KopoLib.Classes = {
	Window = WindowClass,
	Tab = TabClass,
	Section = SectionClass,
	Element = ElementClass,
}

return KopoLib
