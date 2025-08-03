if getgenv().ByteForgeGUILoaded == true then
	print("script is already started")
	return
end
getgenv().ByteForgeGUILoaded = true
local ByteForgeGUI = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Constants
local UI_DEFAULTS = {
	CORNER_RADIUS = UDim.new(0, 12),
	ANIMATION_SPEED = 0.25,
	SPACING = 10,
	ELEMENT_HEIGHT = 50
}

-- Global flag to track if any slider is active
local isSliderActive = false

-- Utility Functions
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not isSliderActive then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function createTween(object, properties, speed)
	return TweenService:Create(
		object, 
		TweenInfo.new(speed or UI_DEFAULTS.ANIMATION_SPEED, Enum.EasingStyle.Quint), 
		properties
	)
end

-- Theme Management
local function applyTheme(element, theme, properties)
	for prop, value in pairs(properties) do
		if prop == "BackgroundColor3" or prop == "TextColor3" or prop == "BorderColor3" or prop == "ScrollBarImageColor3" then
			if element[prop] ~= nil then
				element[prop] = (typeof(value) == "string" and theme[value]) or value
			end
		else
			element[prop] = value
		end
	end
end

-- Main Window
function ByteForgeGUI:CreateWindow(config)
	local window = {
		Config = {
			Title = config.Title or "ByteForgeGUI",
			Size = config.Size or UDim2.new(0, 600, 0, 450),
			Theme = config.Theme or {
				Primary = Color3.fromRGB(25, 25, 30),
				Secondary = Color3.fromRGB(35, 35, 40),
				Accent = Color3.fromRGB(80, 140, 245),
				Hover = Color3.fromRGB(100, 160, 255),
				Text = Color3.fromRGB(230, 230, 230),
				Disabled = Color3.fromRGB(80, 80, 85)
			},
			Keybind = config.Keybind or Enum.KeyCode.RightShift
		},
		State = {
			Visible = true,
			Tabs = {},
			Notifications = {}
		}
	}

	-- ScreenGui Setup
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ByteForgeGUI_" .. window.Config.Title:gsub("%s+", "_")
	screenGui.Parent = game.CoreGui
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Position = UDim2.new(
		0.5, -window.Config.Size.X.Offset/2,
		0.5, -window.Config.Size.Y.Offset/2
	)
	applyTheme(mainFrame, window.Config.Theme, {BackgroundColor3 = "Primary"})
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	window.MainFrame = mainFrame

	Instance.new("UICorner", mainFrame).CornerRadius = UI_DEFAULTS.CORNER_RADIUS
	makeDraggable(mainFrame)
	createTween(mainFrame, {Size = window.Config.Size}, 0.5):Play()

	-- Title Bar
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	applyTheme(titleBar, window.Config.Theme, {BackgroundColor3 = "Accent"})
	titleBar.Parent = mainFrame
	Instance.new("UICorner", titleBar).CornerRadius = UI_DEFAULTS.CORNER_RADIUS

	local titleLabel = Instance.new("TextLabel")
	applyTheme(titleLabel, window.Config.Theme, {
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.fromOffset(UI_DEFAULTS.SPACING, 0),
		BackgroundTransparency = 1,
		Text = window.Config.Title,
		TextColor3 = "Text",
		TextSize = 22,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	titleLabel.Parent = titleBar

	-- Window Controls
	local function createControlButton(text, offset, color, callback)
		local button = Instance.new("TextButton")
		applyTheme(button, window.Config.Theme, {
			Size = UDim2.fromOffset(35, 35),
			Position = UDim2.new(1, offset, 0, 7),
			BackgroundColor3 = color,
			Text = text,
			TextColor3 = "Text",
			TextSize = 16,
			Font = Enum.Font.GothamBold
		})
		button.Parent = titleBar

		button.MouseEnter:Connect(function()
			createTween(button, {BackgroundColor3 = window.Config.Theme.Hover}):Play()
		end)
		button.MouseLeave:Connect(function()
			createTween(button, {BackgroundColor3 = color}):Play()
		end)
		button.MouseButton1Click:Connect(callback)
		return button
	end

	createControlButton("-", -85, Color3.fromRGB(255, 180, 50), function()
		window.State.Visible = not window.State.Visible
		createTween(mainFrame, {
			Size = window.State.Visible and window.Config.Size or UDim2.new(0, window.Config.Size.X.Offset, 0, 50)
		}):Play()
	end)

	createControlButton("×", -40, Color3.fromRGB(255, 100, 100), function()
		createTween(mainFrame, {Size = UDim2.new()}):Play()
		getgenv().ByteForgeGUILoaded = false
		wait(UI_DEFAULTS.ANIMATION_SPEED, screenGui:Destroy(), screenGui)
	end)

	-- Tab System
	local tabContainer = Instance.new("Frame")
	applyTheme(tabContainer, window.Config.Theme, {
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 50),
		BackgroundColor3 = "Secondary"
	})
	tabContainer.Parent = mainFrame

	local tabContent = Instance.new("Frame")
	tabContent.Size = UDim2.new(1, 0, 1, -90)
	tabContent.Position = UDim2.fromOffset(0, 90)
	tabContent.BackgroundTransparency = 1
	tabContent.Parent = mainFrame

	-- Tab Creation
	function window:AddTab(tabConfig)
		local tab = {
			Name = tabConfig.Name or "Tab",
			Content = Instance.new("ScrollingFrame"),
			Sections = {}
		}

		local tabButton = Instance.new("TextButton")
		applyTheme(tabButton, window.Config.Theme, {
			Size = UDim2.new(0, 120, 1, 0),
			Position = UDim2.fromOffset(#window.State.Tabs * 120, 0),
			BackgroundColor3 = "Secondary",
			Text = tab.Name,
			TextColor3 = "Text",
			TextSize = 16,
			Font = Enum.Font.GothamSemibold
		})
		tabButton.Parent = tabContainer

		tab.Content.Size = UDim2.new(1, -20, 1, -10)
		tab.Content.Position = UDim2.fromOffset(UI_DEFAULTS.SPACING, 5)
		tab.Content.BackgroundTransparency = 1
		tab.Content.ScrollBarThickness = 3
		applyTheme(tab.Content, window.Config.Theme, {ScrollBarImageColor3 = "Accent"})
		tab.Content.Parent = tabContent
		tab.Content.Visible = #window.State.Tabs == 0

		local function switchTab()
			for _, otherTab in pairs(window.State.Tabs) do
				otherTab.Content.Visible = false
				createTween(otherTab.Button, {BackgroundColor3 = window.Config.Theme.Secondary}):Play()
			end
			tab.Content.Visible = true
			createTween(tabButton, {BackgroundColor3 = window.Config.Theme.Accent}):Play()
		end

		tabButton.MouseButton1Click:Connect(switchTab)
		tabButton.MouseEnter:Connect(function()
			if not tab.Content.Visible then
				createTween(tabButton, {BackgroundColor3 = window.Config.Theme.Hover}):Play()
			end
		end)
		tabButton.MouseLeave:Connect(function()
			if not tab.Content.Visible then
				createTween(tabButton, {BackgroundColor3 = window.Config.Theme.Secondary}):Play()
			end
		end)
		tab.Button = tabButton

		if #window.State.Tabs == 0 then
			tabButton.BackgroundColor3 = window.Config.Theme.Accent
		end

		-- Section System
		function tab:AddSection(sectionConfig)
			local section = {
				Name = sectionConfig.Name or "Section",
				Expanded = sectionConfig.Expanded ~= false,
				Elements = {},
				Content = Instance.new("Frame")
			}

			local sectionButton = Instance.new("TextButton")
			applyTheme(sectionButton, window.Config.Theme, {
				Size = UDim2.new(0, 280, 0, 40),
				BackgroundColor3 = "Secondary",
				Text = section.Name .. (section.Expanded and " ▼" or " ►"),
				TextColor3 = "Text",
				TextSize = 16,
				Font = Enum.Font.GothamSemibold
			})
			sectionButton.Parent = tab.Content

			section.Content.Size = UDim2.new(0, 280, 0, 0)
			section.Content.BackgroundTransparency = 1
			section.Content.ClipsDescendants = true
			section.Content.Parent = tab.Content

			local function updateLayout()
				local yOffset = UI_DEFAULTS.SPACING
				for i, sec in ipairs(tab.Sections) do
					sec.Button.Position = UDim2.fromOffset(UI_DEFAULTS.SPACING, yOffset)
					sec.Content.Position = UDim2.fromOffset(UI_DEFAULTS.SPACING, yOffset + 40)
					yOffset = yOffset + 45 + (sec.Expanded and #sec.Elements * UI_DEFAULTS.ELEMENT_HEIGHT or 0)
				end
				tab.Content.CanvasSize = UDim2.fromOffset(0, yOffset + UI_DEFAULTS.SPACING)
			end

			sectionButton.MouseButton1Click:Connect(function()
				section.Expanded = not section.Expanded
				sectionButton.Text = section.Name .. (section.Expanded and " ▼" or " ►")
				createTween(section.Content, {
					Size = UDim2.new(0, 280, 0, section.Expanded and #section.Elements * UI_DEFAULTS.ELEMENT_HEIGHT or 0)
				}):Play()
				updateLayout()
			end)

			-- Element Creators
			function section:AddButton(btnConfig)
				local button = Instance.new("TextButton")
				applyTheme(button, window.Config.Theme, {
					Size = UDim2.new(1, -20, 0, UI_DEFAULTS.ELEMENT_HEIGHT - 10),
					Position = UDim2.fromOffset(10, #section.Elements * UI_DEFAULTS.ELEMENT_HEIGHT),
					BackgroundColor3 = "Accent",
					Text = btnConfig.Text or "Button",
					TextColor3 = "Text",
					TextSize = 16,
					Font = Enum.Font.GothamSemibold
				})
				button.Parent = section.Content

				button.MouseButton1Click:Connect(function()
					if btnConfig.Callback then btnConfig.Callback() end
					local tween = createTween(button, {Size = UDim2.new(1, -25, 0, UI_DEFAULTS.ELEMENT_HEIGHT - 15)}, 0.1)
					tween:Play()
					tween.Completed:Wait()
					createTween(button, {Size = UDim2.new(1, -20, 0, UI_DEFAULTS.ELEMENT_HEIGHT - 10)}, 0.1):Play()
				end)

				button.MouseEnter:Connect(function()
					createTween(button, {BackgroundColor3 = window.Config.Theme.Hover}):Play()
				end)
				button.MouseLeave:Connect(function()
					createTween(button, {BackgroundColor3 = window.Config.Theme.Accent}):Play()
				end)

				table.insert(section.Elements, button)
				updateLayout()
				return button
			end

			function section:AddToggle(tglConfig)
				local toggle = Instance.new("Frame")
				toggle.Size = UDim2.new(1, -20, 0, UI_DEFAULTS.ELEMENT_HEIGHT)
				toggle.Position = UDim2.fromOffset(10, #section.Elements * UI_DEFAULTS.ELEMENT_HEIGHT)
				toggle.BackgroundTransparency = 1
				toggle.Parent = section.Content

				local label = Instance.new("TextLabel")
				applyTheme(label, window.Config.Theme, {
					Size = UDim2.new(0, 180, 1, 0),
					BackgroundTransparency = 1,
					Text = tglConfig.Text or "Toggle",
					TextColor3 = "Text",
					TextSize = 16,
					Font = Enum.Font.GothamSemibold
				})
				label.Parent = toggle

				local state = tglConfig.Default or false
				local toggleBtn = Instance.new("TextButton")
				applyTheme(toggleBtn, window.Config.Theme, {
					Size = UDim2.fromOffset(60, 30),
					Position = UDim2.new(1, -70, 0, 10),
					BackgroundColor3 = state and "Accent" or "Disabled",
					Text = state and "ON" or "OFF",
					TextColor3 = "Text",
					TextSize = 14,
					Font = Enum.Font.GothamBold
				})
				toggleBtn.Parent = toggle

				toggleBtn.MouseButton1Click:Connect(function()
					state = not state
					createTween(toggleBtn, {BackgroundColor3 = state and window.Config.Theme.Accent or window.Config.Theme.Disabled}):Play()
					toggleBtn.Text = state and "ON" or "OFF"
					if tglConfig.Callback then tglConfig.Callback(state) end
				end)

				table.insert(section.Elements, toggle)
				updateLayout()
				return toggle
			end

			function section:AddSlider(sliderConfig)
				local slider = Instance.new("Frame")
				slider.Size = UDim2.new(1, -20, 0, UI_DEFAULTS.ELEMENT_HEIGHT)
				slider.Position = UDim2.fromOffset(10, #section.Elements * UI_DEFAULTS.ELEMENT_HEIGHT)
				slider.BackgroundTransparency = 1
				slider.Parent = section.Content

				local label = Instance.new("TextLabel")
				applyTheme(label, window.Config.Theme, {
					Size = UDim2.new(0, 180, 0, 20),
					BackgroundTransparency = 1,
					Text = sliderConfig.Text or "Slider",
					TextColor3 = "Text",
					TextSize = 16,
					Font = Enum.Font.GothamSemibold
				})
				label.Parent = slider

				local sliderBar = Instance.new("Frame")
				applyTheme(sliderBar, window.Config.Theme, {
					Size = UDim2.new(1, -20, 0, 10),
					Position = UDim2.new(0, 10, 0, 30),
					BackgroundColor3 = "Disabled"
				})
				sliderBar.Parent = slider

				local fill = Instance.new("Frame")
				applyTheme(fill, window.Config.Theme, {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = "Accent"
				})
				fill.Parent = sliderBar

				local valueLabel = Instance.new("TextLabel")
				applyTheme(valueLabel, window.Config.Theme, {
					Size = UDim2.new(0, 60, 0, 20),
					Position = UDim2.new(1, -70, 0, 5),
					BackgroundTransparency = 1,
					Text = tostring(sliderConfig.Default or 0),
					TextColor3 = "Text",
					TextSize = 14,
					Font = Enum.Font.Gotham
				})
				valueLabel.Parent = slider

				local minValue = sliderConfig.Min or 0
				local maxValue = sliderConfig.Max or 100
				local currentValue = sliderConfig.Default or minValue
				local dragging = false

				-- Set initial value
				local initialPercent = (currentValue - minValue) / (maxValue - minValue)
				fill.Size = UDim2.new(initialPercent, 0, 1, 0)

				sliderBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						isSliderActive = true -- Disable window dragging
					end
				end)

				sliderBar.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						isSliderActive = false -- Re-enable window dragging
					end
				end)

				RunService.RenderStepped:Connect(function()
					if dragging then
						local mouseX = UserInputService:GetMouseLocation().X
						local barX = sliderBar.AbsolutePosition.X
						local barWidth = sliderBar.AbsoluteSize.X
						local percent = math.clamp((mouseX - barX) / barWidth, 0, 1)
						currentValue = minValue + (maxValue - minValue) * percent
						fill.Size = UDim2.new(percent, 0, 1, 0)
						valueLabel.Text = math.floor(currentValue + 0.5) -- Round to nearest integer
						if sliderConfig.Callback then
							sliderConfig.Callback(currentValue)
						end
					end
				end)

				table.insert(section.Elements, slider)
				updateLayout()
				return slider
			end

			table.insert(tab.Sections, section)
			section.Button = sectionButton
			updateLayout()
			return section
		end

		table.insert(window.State.Tabs, tab)
		return tab
	end

	-- Notification System
	function window:Notify(config)
		local notif = Instance.new("Frame")
		applyTheme(notif, window.Config.Theme, {
			Size = UDim2.fromOffset(300, 100),
			Position = UDim2.new(1, 310, 1, -110 - (#window.State.Notifications * 110)),
			BackgroundColor3 = "Primary",
			BorderSizePixel = 1,
			BorderColor3 = "Accent"
		})
		notif.Parent = screenGui

		local title = Instance.new("TextLabel")
		applyTheme(title, window.Config.Theme, {
			Size = UDim2.new(1, 0, 0, 25),
			BackgroundTransparency = 1,
			Text = config.Title or "Notification",
			TextColor3 = "Accent",
			TextSize = 16,
			Font = Enum.Font.GothamBold
		})
		title.Parent = notif

		local message = Instance.new("TextLabel")
		applyTheme(message, window.Config.Theme, {
			Size = UDim2.new(1, -20, 0, 75),
			Position = UDim2.fromOffset(10, 25),
			BackgroundTransparency = 1,
			Text = config.Text or "Message",
			TextColor3 = "Text",
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		message.Parent = notif

		table.insert(window.State.Notifications, notif)
		local tweenIn = createTween(notif, {Position = UDim2.new(1, -310, 1, -110 - (#window.State.Notifications - 1) * 110)}, 0.4)
		tweenIn:Play()

		task.delay(config.Duration or 3, function()
			local tweenOut = createTween(notif, {Position = UDim2.new(1, 310, 1, notif.Position.Y.Offset)})
			tweenOut:Play()
			tweenOut.Completed:Connect(function()
				table.remove(window.State.Notifications, table.find(window.State.Notifications, notif))
				notif:Destroy()
				for i, remaining in ipairs(window.State.Notifications) do
					createTween(remaining, {Position = UDim2.new(1, -310, 1, -110 - (i - 1) * 110)}):Play()
				end
			end)
		end)
	end

	-- Keybind Handling
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == window.Config.Keybind then
			window.State.Visible = not window.State.Visible
			createTween(mainFrame, {
				Size = window.State.Visible and window.Config.Size or UDim2.new(0, window.Config.Size.X.Offset, 0, 50)
			}):Play()
		end
	end)

	return window
end
return ByteForgeGUI
