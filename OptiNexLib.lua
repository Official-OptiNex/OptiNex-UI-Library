-- Services
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
-- Variables
local viewport = workspace.CurrentCamera.ViewportSize
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut) -- tween shortcut
local dragging = false -- Locals variables for draggable frame
local dragInput -- Locals variables for draggable frame
local dragStart -- Locals variables for draggable frame
local startPos -- Locals variables for draggable frame
local isMainVisible = true
local GUI = {
	CurrentTab = nil
}

-- Function to toggle visibility of nested elements in Main, including setting Main's background transparency
local function setNestedElementsVisibility(visible)
	for _, child in ipairs(GUI["2"]:GetChildren()) do
		-- Exclude the TopBar, dragHandle, and DropShadow from being hidden
		if child:IsA("GuiObject") and child ~= GUI["6"] and child.Name ~= "DragHandle" then
			child.Visible = visible
		end
	end
	-- Set the transparency of the Main frame to fully transparent when hiding, and back to opaque when showing
	GUI["2"].BackgroundTransparency = visible and 0 or 1
end
local function toggleMainUI()
	if isMainVisible then
		-- Hide all elements in Main except for the top bar, drag handle, and dropshadow
		setNestedElementsVisibility(false)
	else
		-- Show all elements in Main again
		setNestedElementsVisibility(true)
	end
	isMainVisible = not isMainVisible
end
-- Makes the frame "Main" draggable (function referenced in "GUI Structure in whole" -> "Main UI")
local function makeDraggable(frame, targetFrame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Checking for nil in options, if nil present, use the default value for said value. (function referenced in "GUI Structure in whole" -> "Main UI" and "Tab Creation")
function GUI:validate(defaults, options)
	for i, v in pairs(defaults) do
		if options[i] == nil then
			options[i] = v
		end
	end
	return options
end

-- tween service shortcut for easier development. (function referenced in "GUI Structure in whole" -> "Main UI")
function GUI:tween(object, goal, callback)
	local tween = tweenService:Create(object, tweenInfo, goal)
	tween.Completed:Connect(callback or function() end)
	tween:Play()
end

-- Adjust ScrollingFrame CanvasSize only if the content exceeds the visible frame size. (function referenced in "GUI Structure in whole -> Main UI")
local function updateCanvasSize(scrollingFrame, listLayout)
	local totalHeight = 0
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			totalHeight = totalHeight + child.AbsoluteSize.Y + listLayout.Padding.Offset -- Add padding
		end
	end

	if totalHeight > scrollingFrame.AbsoluteSize.Y then
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	else
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.AbsoluteSize.Y)
	end
end

--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~ GUI Structure in whole --~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~
function GUI:init(options)	
	---------------------- Main UI 
	do
		---------------------------------------------------------------- DEFAULTS for Main Gui 
		local options = options or {}
		options = GUI:validate({
			Name = "OptiNex UI Library",
			Color = "82, 82, 82" -- accent color
		}, options or {}) -- If Options == nil, uses these default values above

		-- Split the Color string to RGB values
		local rgbValues = string.split(options.Color, ",")
		local red = tonumber(rgbValues[1]) or 255
		local green = tonumber(rgbValues[2]) or 255
		local blue = tonumber(rgbValues[3]) or 255

		-- MyLibrary
		GUI["1"] = Instance.new("ScreenGui", runService:IsStudio() and players.LocalPlayer:WaitForChild("PlayerGui") or coreGui);
		GUI["1"]["Name"] = [[MyLibrary]];
		GUI["1"]["IgnoreGuiInset"] = true


		-- Main UI Frame
		GUI["2"] = Instance.new("Frame", GUI["1"]);
		GUI["2"]["BorderSizePixel"] = 0;
		GUI["2"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 49);
		GUI["2"]["AnchorPoint"] = Vector2.new(0, 0);
		GUI["2"]["Size"] = UDim2.new(0, 400, 0, 300);
		GUI["2"]["Position"] = UDim2.fromOffset((viewport.X/2) - GUI["2"].Size.X.Offset /2, (viewport.Y/2) - GUI["2"].Size.Y.Offset /2);
		GUI["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["2"]["Name"] = [[Main]];
		local dragHandle = Instance.new("Frame", GUI["2"]) -- create the draggable part of top of UI
		dragHandle.Size = UDim2.new(1, 0, 0, 30)  -- Full width, 30 pixels height
		dragHandle.Position = UDim2.new(0, 0, 0, 0)  -- Positioned at the top of the main frame
		dragHandle.BackgroundTransparency = 1  -- Make it invisible
		dragHandle.Name = "DragHandle"
		makeDraggable(dragHandle, GUI["2"])

		-- Main UI Corners
		GUI["3"] = Instance.new("UICorner", GUI["2"]);
		GUI["3"]["CornerRadius"] = UDim.new(0, 10);


		-- Main UI DropshadowHolder
		GUI["4"] = Instance.new("Frame", GUI["2"]);
		GUI["4"]["ZIndex"] = 0;
		GUI["4"]["BorderSizePixel"] = 0;
		GUI["4"]["Size"] = UDim2.new(1, 0, 1, 0);
		GUI["4"]["Name"] = [[DropShadowHolder]];
		GUI["4"]["BackgroundTransparency"] = 1;


		-- Main UI Dropshadow
		GUI["5"] = Instance.new("ImageLabel", GUI["4"]);
		GUI["5"]["ZIndex"] = 0;
		GUI["5"]["BorderSizePixel"] = 0;
		GUI["5"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
		GUI["5"]["ScaleType"] = Enum.ScaleType.Slice;
		GUI["5"]["ImageTransparency"] = 0.5;
		GUI["5"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["5"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
		GUI["5"]["Image"] = [[rbxassetid://6014261993]];
		GUI["5"]["Size"] = UDim2.new(1, 47, 1, 47);
		GUI["5"]["BackgroundTransparency"] = 1;
		GUI["5"]["Name"] = [[DropShadow]];
		GUI["5"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


		-- Main UI TopBar
		GUI["6"] = Instance.new("Frame", GUI["2"]);
		GUI["6"]["BorderSizePixel"] = 0;
		GUI["6"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		GUI["6"]["Size"] = UDim2.new(1, 0, 0, 30);
		GUI["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["6"]["Name"] = [[TopBar]];


		-- Main UI TopBar Corners
		GUI["7"] = Instance.new("UICorner", GUI["6"]);
		GUI["7"]["CornerRadius"] = UDim.new(0, 10);


		-- Main UI TopBar Extension
		GUI["8"] = Instance.new("Frame", GUI["6"]);
		GUI["8"]["BorderSizePixel"] = 0;
		GUI["8"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		GUI["8"]["AnchorPoint"] = Vector2.new(0, 1);
		GUI["8"]["Size"] = UDim2.new(1, 0, 0.5, 0);
		GUI["8"]["Position"] = UDim2.new(0, 0, 1, 0);
		GUI["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["8"]["Name"] = [[Extension]];


		-- Main UI TopBar Title
		GUI["9"] = Instance.new("TextLabel", GUI["6"]);
		GUI["9"]["BorderSizePixel"] = 0;
		GUI["9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		GUI["9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["9"]["TextSize"] = 14;
		GUI["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		GUI["9"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["9"]["BackgroundTransparency"] = 1;
		GUI["9"]["Size"] = UDim2.new(0.5, 0, 1, 0);
		GUI["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["9"]["Text"] = options["Name"];
		GUI["9"]["Name"] = [[Title]];


		-- Main UI TopBar Title Padding
		GUI["a"] = Instance.new("UIPadding", GUI["9"]);
		GUI["a"]["PaddingTop"] = UDim.new(0, 1);
		GUI["a"]["PaddingLeft"] = UDim.new(0, 8);


		-- Main UI TopBar Exit Button
		GUI["b"] = Instance.new("ImageLabel", GUI["6"]);
		GUI["b"]["BorderSizePixel"] = 0;
		GUI["b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["b"]["AnchorPoint"] = Vector2.new(1, 0.5);
		GUI["b"]["Image"] = [[rbxassetid://120463651952860]];
		GUI["b"]["Size"] = UDim2.new(0, 15, 0, 15);
		GUI["b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["b"]["BackgroundTransparency"] = 1;
		GUI["b"]["Name"] = [[ExitBtn]];
		GUI["b"]["Position"] = UDim2.new(1, -6, 0.5, 0);
		GUI["b"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				toggleMainUI()  -- Toggle the main UI visibility
			end
		end)

		-- Main UI TopBar Accent Line
		GUI["c"] = Instance.new("Frame", GUI["6"]);
		GUI["c"]["BorderSizePixel"] = 0;
		GUI["c"]["BackgroundColor3"] = Color3.fromRGB(red,green,blue); -- accent line color
		GUI["c"]["AnchorPoint"] = Vector2.new(0, 1);
		GUI["c"]["Size"] = UDim2.new(1, 0, 0, 1);
		GUI["c"]["Position"] = UDim2.new(0, 0, 1, 0);
		GUI["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["c"]["Name"] = [[Line]];


		-- Main UI Content Container
		GUI["22"] = Instance.new("Frame", GUI["2"]);
		GUI["22"]["BorderSizePixel"] = 0;
		GUI["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["22"]["AnchorPoint"] = Vector2.new(1, 0);
		GUI["22"]["Size"] = UDim2.new(1, -133, 1, -42);
		GUI["22"]["Position"] = UDim2.new(1, -6, 0, 36);
		GUI["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["22"]["Name"] = [[ContentContainer]];
		GUI["22"]["BackgroundTransparency"] = 1;

		-- StarterGui.MyLibrary.Main.ContentContainer.Fade
		GUI["75"] = Instance.new("Frame", GUI["22"]);
		GUI["75"]["Visible"] = false;
		GUI["75"]["ZIndex"] = 10;
		GUI["75"]["BorderSizePixel"] = 0;
		GUI["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["75"]["Size"] = UDim2.new(1, 0, 0, 30);
		GUI["75"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["75"]["Name"] = [[Fade]];


		-- StarterGui.MyLibrary.Main.ContentContainer.Fade.UIGradient
		GUI["76"] = Instance.new("UIGradient", GUI["75"]);
		GUI["76"]["Rotation"] = 90;
		GUI["76"]["Transparency"] = NumberSequence.new{NumberSequenceKeypoint.new(0.000, 0),NumberSequenceKeypoint.new(0.339, 0.25),NumberSequenceKeypoint.new(1.000, 1)};
		GUI["76"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 41)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(41, 41, 41))};
	end


	---------------------- Navigation UI 
	do
		-- Split the Color string to RGB values
		local rgbValues = string.split(options.Color, ",")
		local red = tonumber(rgbValues[1]) or 255
		local green = tonumber(rgbValues[2]) or 255
		local blue = tonumber(rgbValues[3]) or 255

		-- Main UI Navigation
		GUI["d"] = Instance.new("Frame", GUI["2"]);
		GUI["d"]["BorderSizePixel"] = 0;
		GUI["d"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
		GUI["d"]["Size"] = UDim2.new(0, 120, 1, -31);
		GUI["d"]["Position"] = UDim2.new(0, 0, 0, 31);
		GUI["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["d"]["Name"] = [[Navigation]];


		-- Main UI Navigation Corners
		GUI["e"] = Instance.new("UICorner", GUI["d"]);
		GUI["e"]["CornerRadius"] = UDim.new(0, 10);


		-- Main UI Navigation Corner Cover
		GUI["f"] = Instance.new("Frame", GUI["d"]);
		GUI["f"]["BorderSizePixel"] = 0;
		GUI["f"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
		GUI["f"]["Size"] = UDim2.new(1, 0, 0, 20);
		GUI["f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["f"]["Name"] = [[Hide]];


		-- Main UI Navigation Corner Cover 2
		GUI["10"] = Instance.new("Frame", GUI["d"]);
		GUI["10"]["BorderSizePixel"] = 0;
		GUI["10"]["BackgroundColor3"] = Color3.fromRGB(66, 66, 66);
		GUI["10"]["AnchorPoint"] = Vector2.new(1, 0);
		GUI["10"]["Size"] = UDim2.new(0, 20, 1, 0);
		GUI["10"]["Position"] = UDim2.new(1, 0, 0, 0);
		GUI["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["10"]["Name"] = [[Hide2]];


		-- Main UI Navigation Button Holder
		GUI["11"] = Instance.new("ScrollingFrame", GUI["d"]);
		GUI["11"]["BorderSizePixel"] = 0;
		GUI["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["11"]["Size"] = UDim2.new(1, 0, 0.932, 0);
		GUI["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["11"]["Name"] = [[ButtonHolder]];
		GUI["11"]["BackgroundTransparency"] = 1;
		GUI["11"]["Selectable"] = false;
		GUI["11"]["ScrollBarThickness"] = 0;
		GUI["11"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;


		-- Main UI Navigation Button Holder Padding
		GUI["12"] = Instance.new("UIPadding", GUI["11"]);
		GUI["12"]["PaddingTop"] = UDim.new(0, 8);
		GUI["12"]["PaddingBottom"] = UDim.new(0, 8);


		-- Main UI Navigation Button Holder UI List Layout
		GUI["13"] = Instance.new("UIListLayout", GUI["11"]);
		GUI["13"]["Padding"] = UDim.new(0, 1);
		GUI["13"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


		-- Main UI Navigation Accent Line
		GUI["1a"] = Instance.new("Frame", GUI["d"]);
		GUI["1a"]["BorderSizePixel"] = 0;
		GUI["1a"]["BackgroundColor3"] = Color3.fromRGB(red,green,blue); -- accent line color
		GUI["1a"]["Size"] = UDim2.new(0, 1, 1, 0);
		GUI["1a"]["Position"] = UDim2.new(1, 0, 0, 0);
		GUI["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["1a"]["Name"] = [[Line]];


		-- Main UI Navigation Credits
		GUI["1b"] = Instance.new("Frame", GUI["d"]);
		GUI["1b"]["BorderSizePixel"] = 0;
		GUI["1b"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		GUI["1b"]["AnchorPoint"] = Vector2.new(1, 0);
		GUI["1b"]["Size"] = UDim2.new(0, 120, 0.068, 0);
		GUI["1b"]["Position"] = UDim2.new(1, 0, 0.933, 0);
		GUI["1b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["1b"]["Name"] = [[Credits]];


		-- Main UI Navigation Corner
		GUI["1c"] = Instance.new("UICorner", GUI["1b"]);
		GUI["1c"]["CornerRadius"] = UDim.new(0, 10);


		-- Main UI Navigation Corner Cover
		GUI["1d"] = Instance.new("Frame", GUI["1b"]);
		GUI["1d"]["BorderSizePixel"] = 0;
		GUI["1d"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		GUI["1d"]["AnchorPoint"] = Vector2.new(1, 0);
		GUI["1d"]["Size"] = UDim2.new(0, 120, 0.47271, 0);
		GUI["1d"]["Position"] = UDim2.new(1, 0, -0.014, 0);
		GUI["1d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["1d"]["Name"] = [[CHide]];


		-- Main UI Navigation Corner Cover 2
		GUI["1e"] = Instance.new("Frame", GUI["1b"]);
		GUI["1e"]["BorderSizePixel"] = 0;
		GUI["1e"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		GUI["1e"]["AnchorPoint"] = Vector2.new(1, 0);
		GUI["1e"]["Size"] = UDim2.new(-0.925, 120, 0.991, 0);
		GUI["1e"]["Position"] = UDim2.new(1, 0, -0.014, 0);
		GUI["1e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["1e"]["Name"] = [[CHide2]];


		-- Main UI Navigation Accent Line
		GUI["1f"] = Instance.new("Frame", GUI["1b"]);
		GUI["1f"]["ZIndex"] = 4;
		GUI["1f"]["BorderSizePixel"] = 0;
		GUI["1f"]["BackgroundColor3"] = Color3.fromRGB(red,green,blue); -- accent line color
		GUI["1f"]["Size"] = UDim2.new(1, 0, 0, 1);
		GUI["1f"]["Position"] = UDim2.new(0, 0, 0.0049, 0);
		GUI["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["1f"]["Name"] = [[Line]];


		-- Main UI Navigation Credits Name
		GUI["20"] = Instance.new("TextLabel", GUI["1b"]);
		GUI["20"]["BorderSizePixel"] = 0;
		GUI["20"]["TextXAlignment"] = Enum.TextXAlignment.Center;
		GUI["20"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["20"]["TextSize"] = 14;
		GUI["20"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		GUI["20"]["TextColor3"] = Color3.fromRGB(171, 171, 171);
		GUI["20"]["BackgroundTransparency"] = 1;
		GUI["20"]["Size"] = UDim2.new(1, 0, 1, 0);
		GUI["20"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["20"]["Text"] = [[OptiNex UI]];
		GUI["20"]["Name"] = [[CName]];


		-- Main UI Navigation Credits Name Padding
		GUI["21"] = Instance.new("UIPadding", GUI["20"]);
		GUI["21"]["PaddingTop"] = UDim.new(0, 1);
		GUI["21"]["PaddingLeft"] = UDim.new(0, 0);
		updateCanvasSize(GUI["11"], GUI["13"]) -- Updates navigation bar to Auto fit canvas to only scroll when buttons exceed visual canvas size
	end


	---------------------------------------------------------------------- Tab Creation + UI Elements 
	function GUI:NewTab(options)
		-- Defaults for TAB config.
		options = GUI:validate({
			Name = "Example tab",
			Icon = "rbxassetid://73138253932616"
		}, options or {})

		local Tab = {
			Hover = false,
			Active = false
		}


		-------- Tab Render
		do
			-- Navigation Button
			Tab["17"] = Instance.new("TextLabel", GUI["11"]);
			Tab["17"]["BorderSizePixel"] = 0;
			Tab["17"]["TextXAlignment"] = Enum.TextXAlignment.Left;
			Tab["17"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Tab["17"]["TextSize"] = 12;
			Tab["17"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			Tab["17"]["TextColor3"] = Color3.fromRGB(162, 162, 162);
			Tab["17"]["BackgroundTransparency"] = 1;
			Tab["17"]["Size"] = UDim2.new(1, 0, 0, 24);
			Tab["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["17"]["Text"] = options.Name; -- Visual Button Name
			Tab["17"]["Name"] = [[Inactive]];

			-- Navigation Button Corners
			Tab["zen"] = Instance.new("UICorner", Tab["17"]);
			Tab["zen"]["CornerRadius"] = UDim.new(0, 10);

			-- Navigation Button Padding
			Tab["18"] = Instance.new("UIPadding", Tab["17"]);
			Tab["18"]["PaddingLeft"] = UDim.new(0, 28);


			-- Navigation Button Icon
			Tab["19"] = Instance.new("ImageLabel", Tab["17"]);
			Tab["19"]["BorderSizePixel"] = 0;
			Tab["19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Tab["19"]["ImageColor3"] = Color3.fromRGB(162, 162, 162);
			Tab["19"]["AnchorPoint"] = Vector2.new(0, 0.5);
			Tab["19"]["Image"] = options.Icon; -- Button Icon
			Tab["19"]["Size"] = UDim2.new(0, 20, 0, 20);
			Tab["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["19"]["BackgroundTransparency"] = 1;
			Tab["19"]["Name"] = [[Icon]];
			Tab["19"]["Position"] = UDim2.new(0, -24, 0.5, 0);

			-- Main UI ContentContainer HomeTab (elements are created here)
			Tab["23"] = Instance.new("ScrollingFrame", GUI["22"]);
			Tab["23"]["BorderSizePixel"] = 0;
			Tab["23"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Tab["23"]["Name"] = [[HomeTab]];
			Tab["23"]["Selectable"] = false;
			Tab["23"]["Size"] = UDim2.new(1, 0, 1, 0);
			Tab["23"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["23"]["ScrollBarThickness"] = 0;
			Tab["23"]["BackgroundTransparency"] = 1;
			Tab["23"]["Visible"] = false

			-- HomeTab UI List Layout
			Tab["31"] = Instance.new("UIListLayout", Tab["23"]);
			Tab["31"]["Padding"] = UDim.new(0, 6);
			Tab["31"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

			-- HomeTab Padding
			Tab["2a"] = Instance.new("UIPadding", Tab["23"]);
			Tab["2a"]["PaddingTop"] = UDim.new(0, 1);
			Tab["2a"]["PaddingRight"] = UDim.new(0, 1);
			Tab["2a"]["PaddingLeft"] = UDim.new(0, 1);
			Tab["2a"]["PaddingBottom"] = UDim.new(0, 1);
			
		end


		-------- Tab Methods
		do
			function Tab:Activate()
				if not Tab.Active then
					if GUI.CurrentTab ~= nil then
						GUI.CurrentTab:Deactivate()
					end

					Tab.Active = true
					GUI:tween(Tab["17"], {TextColor3 = Color3.fromRGB(255,255,255)})
					GUI:tween(Tab["19"], {ImageColor3 = Color3.fromRGB(255,255,255)})
					GUI:tween(Tab["17"], {BackgroundTransparency = 0.8})
					Tab["23"].Visible = true
					GUI.CurrentTab = Tab
				end
			end

			function Tab:Deactivate()
				if Tab.Active then
					Tab.Active = false
					Tab.Hover = false
					GUI:tween(Tab["17"], {TextColor3 = Color3.fromRGB(200,200,200)})
					GUI:tween(Tab["19"], {ImageColor3 = Color3.fromRGB(200,200,200)})  	
					GUI:tween(Tab["17"], {BackgroundTransparency = 1})
					Tab["23"].Visible = false
				end
			end
		end

		-------- Tab Logic
		do
			Tab["17"].MouseEnter:Connect(function()
				Tab.Hover = true

				if not Tab.Active then
					GUI:tween(Tab["17"], {TextColor3 = Color3.fromRGB(255,255,255)})
					GUI:tween(Tab["19"], {ImageColor3 = Color3.fromRGB(255,255,255)})
				end
			end)

			Tab["17"].MouseLeave:Connect(function()
				Tab.Hover = false

				if not Tab.Active then
					GUI:tween(Tab["17"], {TextColor3 = Color3.fromRGB(200,200,200)})
					GUI:tween(Tab["19"], {ImageColor3 = Color3.fromRGB(200,200,200)})
				end
			end)


			uis.InputBegan:Connect(function(input,gpe)
				if gpe then return end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if Tab.Hover then
						Tab:Activate()
					end
				end
			end)

			if GUI.CurrentTab == nil then
				Tab.Activate()
			end
		end
		---------------------------------------------------------------------- UI ELEMENTS 

		---------------------------------------------------------------------- BUTTON CREATION
		function Tab:Button(options)
			options = GUI:validate({
				Name = "Example Button",
				callback = function() print("Example Button Function") end
			}, options or {})

			local Button = {
				Hover = false,
				MouseDown = false
			}

			-- Button Render
			do
				-- Button Frame
				Button["24"] = Instance.new("Frame", Tab["23"]);
				Button["24"]["BorderSizePixel"] = 0;
				Button["24"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 27);
				Button["24"]["Size"] = UDim2.new(1, 0, 0, 32);
				Button["24"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Button["24"]["Name"] = [[Button]];


				-- Button Corner
				Button["25"] = Instance.new("UICorner", Button["24"]);
				Button["25"]["CornerRadius"] = UDim.new(0, 5);


				-- Button Stroke
				Button["26"] = Instance.new("UIStroke", Button["24"]);
				Button["26"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Button["26"]["Color"] = Color3.fromRGB(82, 82, 82);


				-- Button Title
				Button["27"] = Instance.new("TextLabel", Button["24"]);
				Button["27"]["BorderSizePixel"] = 0;
				Button["27"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Button["27"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Button["27"]["TextSize"] = 14;
				Button["27"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Button["27"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Button["27"]["BackgroundTransparency"] = 1;
				Button["27"]["Size"] = UDim2.new(1, -20, 1, 0);
				Button["27"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Button["27"]["Text"] = options.Name;
				Button["27"]["Name"] = [[Title]];


				-- Button Padding
				Button["28"] = Instance.new("UIPadding", Button["24"]);
				Button["28"]["PaddingTop"] = UDim.new(0, 6);
				Button["28"]["PaddingRight"] = UDim.new(0, 6);
				Button["28"]["PaddingLeft"] = UDim.new(0, 6);
				Button["28"]["PaddingBottom"] = UDim.new(0, 6);


				-- Button Icon
				Button["29"] = Instance.new("ImageLabel", Button["24"]);
				Button["29"]["BorderSizePixel"] = 0;
				Button["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Button["29"]["AnchorPoint"] = Vector2.new(1, 0);
				Button["29"]["Image"] = [[rbxassetid://99964162522981]];
				Button["29"]["Size"] = UDim2.new(0, 20, 0, 20);
				Button["29"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Button["29"]["BackgroundTransparency"] = 1;
				Button["29"]["Name"] = [[Icon]];
				Button["29"]["Position"] = UDim2.new(1, 0, 0, 0);
				updateCanvasSize(Tab["23"], Tab["31"]) -- Updates HomeTab section to Auto fit canvas to only scroll when buttons exceed visual canvas size
			end

			-- Button Methods
			do
				function Button:SetText(text)
					Button["27"].Text = text
					options.Name = text
				end

				function Button:SetCallBack(callback)
					options.callback = callback
				end
			end			

			-- Button Logic
			do
				Button["24"].MouseEnter:Connect(function()	
					Button.Hover = true
					GUI:tween(Button["26"], {Color = Color3.fromRGB(152,152,152)})
				end)

				Button["24"].MouseLeave:Connect(function()
					Button.Hover = false

					if not Button.MouseDown then
						GUI:tween(Button["26"], {Color = Color3.fromRGB(82,82,82)})
					end
				end)

				uis.InputBegan:Connect(function(input, gpe)
					if gpe then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 and Button.Hover then
						Button.MouseDown = true
						GUI:tween(Button["24"], {BackgroundColor3 = Color3.fromRGB(57,57,57)})
						GUI:tween(Button["26"], {Color = Color3.fromRGB(200,200,200)})
						options.callback()
					end
				end)

				uis.InputEnded:Connect(function(input, gpe)
					if gpe then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Button.MouseDown = false

						if Button.Hover then
							-- hover state
							GUI:tween(Button["24"], {BackgroundColor3 = Color3.fromRGB(27,27,27)})
							GUI:tween(Button["26"], {Color = Color3.fromRGB(102,102,102)})
						else
							-- reset
							GUI:tween(Button["24"], {BackgroundColor3 = Color3.fromRGB(27,27,27)})
							GUI:tween(Button["26"], {Color = Color3.fromRGB(82,82,82)})
						end
					end
				end)
			end


			return Button
		end

		---------------------------------------------------------------------- WARNING LABEL CREATION
		function Tab:Warning(options)
			options = GUI:validate({
				Message = "Previw Warning Text",
			}, options or {})

			local Warning = {}

			-- Warning Render
			do
				-- Warning Frame
				Warning["2b"] = Instance.new("Frame", Tab["23"]);
				Warning["2b"]["BorderSizePixel"] = 0;
				Warning["2b"]["BackgroundColor3"] = Color3.fromRGB(44, 37, 4);
				Warning["2b"]["Size"] = UDim2.new(1, 0, 0, 26);
				Warning["2b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Warning["2b"]["Name"] = [[Warning]];


				-- Warning Corner
				Warning["2c"] = Instance.new("UICorner", Warning["2b"]);
				Warning["2c"]["CornerRadius"] = UDim.new(0, 5);


				-- Warning Stroke
				Warning["2d"] = Instance.new("UIStroke", Warning["2b"]);
				Warning["2d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Warning["2d"]["Color"] = Color3.fromRGB(166, 138, 12);


				-- Warning Title
				Warning["2e"] = Instance.new("TextLabel", Warning["2b"]);
				Warning["2e"]["BorderSizePixel"] = 0;
				Warning["2e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Warning["2e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Warning["2e"]["TextSize"] = 14;
				Warning["2e"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Warning["2e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Warning["2e"]["BackgroundTransparency"] = 1;
				Warning["2e"]["Size"] = UDim2.new(1, -20, 1, 0);
				Warning["2e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Warning["2e"]["Text"] = options.Message;
				Warning["2e"]["Name"] = [[Title]];
				Warning["2e"]["TextWrapped"] = true;
				Warning["2e"]["TextYAlignment"] = Enum.TextYAlignment.Top

				-- Warning Padding
				Warning["2f"] = Instance.new("UIPadding", Warning["2b"]);
				Warning["2f"]["PaddingTop"] = UDim.new(0, 6);
				Warning["2f"]["PaddingRight"] = UDim.new(0, 6);
				Warning["2f"]["PaddingLeft"] = UDim.new(0, 6);
				Warning["2f"]["PaddingBottom"] = UDim.new(0, 6);


				-- Warning Icon
				Warning["30"] = Instance.new("ImageLabel", Warning["2b"]);
				Warning["30"]["BorderSizePixel"] = 0;
				Warning["30"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Warning["30"]["ImageColor3"] = Color3.fromRGB(199, 165, 14);
				Warning["30"]["AnchorPoint"] = Vector2.new(1, 0);
				Warning["30"]["Image"] = [[rbxassetid://110064348366580]];
				Warning["30"]["Size"] = UDim2.new(0, 20, 0, 20);
				Warning["30"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Warning["30"]["BackgroundTransparency"] = 1;
				Warning["30"]["Name"] = [[Icon]];
				Warning["30"]["Position"] = UDim2.new(1, 0, 0, -3);
			end

			-- Warning Methods
			do
				function Warning:SetText(Message)
					options.Message = Message
					Warning:_update()
				end


				function Warning:_update()
					-- Set the message
					Warning["2e"].Text = options.Message
					-- Temporarily set the text size to calculate TextBounds
					Warning["2e"].Size = UDim2.new(Warning["2e"].Size.X.Scale, Warning["2e"].Size.X.Offset, 0, math.huge)
					-- Wait for the TextBounds to update
					task.wait()
					-- Calculate the final size of the text
					Warning["2e"].Size = UDim2.new(Warning["2e"].Size.X.Scale, Warning["2e"].Size.X.Offset, 0, Warning["2e"].TextBounds.Y)
					-- Calculate the target size for the background frame
					local targetBackgroundSize = UDim2.new(Warning["2b"].Size.X.Scale, Warning["2b"].Size.X.Offset, 0, Warning["2e"].TextBounds.Y + 12)
					-- Tween the frame size (dropdown expansion)
					GUI:tween(Warning["2b"], { Size = targetBackgroundSize })
					-- UPDATE SCROLLING FRAME SIZE
					wait(0.2)
					updateCanvasSize(Tab["23"], Tab["31"])
					updateCanvasSize(GUI["11"], GUI["13"])
				end
				Warning:_update()
				return Warning
			end
		end

		---------------------------------------------------------------------- INFO LABEL CREATION
		function Tab:Info(options)
			options = GUI:validate({
				Message = "Previw Info Text",
			}, options or {})

			local Info = {}

			-- Info Render
			do
				-- Info Frame
				Info["32"] = Instance.new("Frame", Tab["23"]);
				Info["32"]["BorderSizePixel"] = 0;
				Info["32"]["BackgroundColor3"] = Color3.fromRGB(3, 44, 37);
				Info["32"]["Size"] = UDim2.new(1, 0, 0, 26);
				Info["32"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Info["32"]["Name"] = [[Info]];


				-- Info Corner
				Info["33"] = Instance.new("UICorner", Info["32"]);
				Info["33"]["CornerRadius"] = UDim.new(0, 5);


				-- Info Stroke
				Info["34"] = Instance.new("UIStroke", Info["32"]);
				Info["34"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Info["34"]["Color"] = Color3.fromRGB(0, 166, 147);


				-- Info Title
				Info["35"] = Instance.new("TextLabel", Info["32"]);
				Info["35"]["BorderSizePixel"] = 0;
				Info["35"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Info["35"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Info["35"]["TextSize"] = 14;
				Info["35"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Info["35"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Info["35"]["BackgroundTransparency"] = 1;
				Info["35"]["Size"] = UDim2.new(1, -20, 1, 0);
				Info["35"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Info["35"]["Text"] = options.Message;
				Info["35"]["Name"] = [[Warning]];
				Info["35"]["TextWrapped"] = true;
				Info["35"]["TextYAlignment"] = Enum.TextYAlignment.Top

				-- Info Padding
				Info["36"] = Instance.new("UIPadding", Info["32"]);
				Info["36"]["PaddingTop"] = UDim.new(0, 6);
				Info["36"]["PaddingRight"] = UDim.new(0, 6);
				Info["36"]["PaddingLeft"] = UDim.new(0, 6);
				Info["36"]["PaddingBottom"] = UDim.new(0, 6);


				-- Info Icon
				Info["37"] = Instance.new("ImageLabel", Info["32"]);
				Info["37"]["BorderSizePixel"] = 0;
				Info["37"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Info["37"]["ImageColor3"] = Color3.fromRGB(0, 199, 176);
				Info["37"]["AnchorPoint"] = Vector2.new(1, 0);
				Info["37"]["Image"] = [[rbxassetid://107588405418549]];
				Info["37"]["Size"] = UDim2.new(0, 20, 0, 20);
				Info["37"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Info["37"]["BackgroundTransparency"] = 1;
				Info["37"]["Name"] = [[Icon]];
				Info["37"]["Position"] = UDim2.new(1, 0, 0, -3);

			end

			-- Info Methods
			do
				function Info:SetText(Message)
					options.Message = Message
					Info:_update()
				end


				function Info:_update()
					-- Set the message
					Info["35"].Text = options.Message
					-- Temporarily set the text size to calculate TextBounds
					Info["35"].Size = UDim2.new(Info["35"].Size.X.Scale, Info["35"].Size.X.Offset, 0, math.huge)
					-- Wait for the TextBounds to update
					task.wait()
					-- Calculate the final size of the text
					Info["35"].Size = UDim2.new(Info["35"].Size.X.Scale, Info["35"].Size.X.Offset, 0, Info["35"].TextBounds.Y)
					-- Calculate the target size for the background frame
					local targetBackgroundSize = UDim2.new(Info["32"].Size.X.Scale, Info["32"].Size.X.Offset, 0, Info["35"].TextBounds.Y + 12)
					-- Tween the frame size (dropdown expansion)
					GUI:tween(Info["32"], { Size = targetBackgroundSize })
					-- UPDATE SCROLLING FRAME SIZE
					wait(0.2)
					updateCanvasSize(Tab["23"], Tab["31"])
					updateCanvasSize(GUI["11"], GUI["13"])
				end
				Info:_update()
				return Info
			end
		end

		---------------------------------------------------------------------- TEXT LABEL CREATION
		function Tab:Label(options)
			options = GUI:validate({
				Message = "Previw Label Text",
			}, options or {})

			local Label = {}

			-- Label Render
			do
				-- Label Frame
				Label["38"] = Instance.new("Frame", Tab["23"]);
				Label["38"]["BorderSizePixel"] = 0;
				Label["38"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 27);
				Label["38"]["Size"] = UDim2.new(1, 0, 0, 26);
				Label["38"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["38"]["Name"] = [[Label]];


				-- Label Corner
				Label["39"] = Instance.new("UICorner", Label["38"]);
				Label["39"]["CornerRadius"] = UDim.new(0, 5);


				-- Label Stroke
				Label["3a"] = Instance.new("UIStroke", Label["38"]);
				Label["3a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Label["3a"]["Color"] = Color3.fromRGB(82, 82, 82);


				-- Label Title
				Label["3b"] = Instance.new("TextLabel", Label["38"]);
				Label["3b"]["BorderSizePixel"] = 0;
				Label["3b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Label["3b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Label["3b"]["TextSize"] = 14;
				Label["3b"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Label["3b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Label["3b"]["BackgroundTransparency"] = 1;
				Label["3b"]["Size"] = UDim2.new(1, -20, 1, 0);
				Label["3b"]["Text"] = options.Message;
				Label["3b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["3b"]["Name"] = [[Title]];
				Label["3b"]["TextWrapped"] = true;
				Label["3b"]["TextYAlignment"] = Enum.TextYAlignment.Top

				-- Label Padding
				Label["3c"] = Instance.new("UIPadding", Label["38"]);
				Label["3c"]["PaddingTop"] = UDim.new(0, 6);
				Label["3c"]["PaddingRight"] = UDim.new(0, 6);
				Label["3c"]["PaddingLeft"] = UDim.new(0, 6);
				Label["3c"]["PaddingBottom"] = UDim.new(0, 6);


				-- Label icon
				Label["3d"] = Instance.new("ImageLabel", Label["38"]);
				Label["3d"]["BorderSizePixel"] = 0;
				Label["3d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Label["3d"]["AnchorPoint"] = Vector2.new(1, 0);
				Label["3d"]["Image"] = [[rbxassetid://114316707969697]];
				Label["3d"]["Size"] = UDim2.new(0, 20, 0, 20);
				Label["3d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["3d"]["BackgroundTransparency"] = 1;
				Label["3d"]["Name"] = [[Icon]];
				Label["3d"]["Position"] = UDim2.new(1, 0, 0, -3);

			end

			-- Info Methods
			do
				function Label:SetText(Message)
					options.Message = Message
					Label:_update()
				end


				function Label:_update()
					-- Set the message
					Label["3b"].Text = options.Message
					-- Temporarily set the text size to calculate TextBounds
					Label["3b"].Size = UDim2.new(Label["3b"].Size.X.Scale, Label["3b"].Size.X.Offset, 0, math.huge)
					-- Wait for the TextBounds to update
					task.wait()
					-- Calculate the final size of the text
					Label["3b"].Size = UDim2.new(Label["3b"].Size.X.Scale, Label["3b"].Size.X.Offset, 0, Label["3b"].TextBounds.Y)
					-- Calculate the target size for the background frame
					local targetBackgroundSize = UDim2.new(Label["38"].Size.X.Scale, Label["38"].Size.X.Offset, 0, Label["3b"].TextBounds.Y + 12)
					-- Tween the frame size (dropdown expansion)
					GUI:tween(Label["38"], { Size = targetBackgroundSize })
					-- UPDATE SCROLLING FRAME SIZE
					wait(0.2)
					updateCanvasSize(Tab["23"], Tab["31"])
					updateCanvasSize(GUI["11"], GUI["13"])
				end
				Label:_update()
				return Label
			end
		end

		---------------------------------------------------------------------- TOGGLE CREATION
		function Tab:Toggle(options)
			options = GUI:validate({
				Name = "Example Toggle",
				callback = function(v) print(v) end
			}, options or {})

			local Toggle = {
				Hover = false,
				MouseDown = false,
				State = false
			}

			-- Toggle Render
			do
				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive
				Toggle["5a"] = Instance.new("Frame", Tab["23"]);
				Toggle["5a"]["BorderSizePixel"] = 0;
				Toggle["5a"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 27);
				Toggle["5a"]["Size"] = UDim2.new(1, 0, 0, 32);
				Toggle["5a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["5a"]["Name"] = [[ToggleInactive]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.UICorner
				Toggle["5b"] = Instance.new("UICorner", Toggle["5a"]);
				Toggle["5b"]["CornerRadius"] = UDim.new(0, 5);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.UIStroke
				Toggle["5c"] = Instance.new("UIStroke", Toggle["5a"]);
				Toggle["5c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Toggle["5c"]["Color"] = Color3.fromRGB(82, 82, 82);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.Title
				Toggle["5d"] = Instance.new("TextLabel", Toggle["5a"]);
				Toggle["5d"]["BorderSizePixel"] = 0;
				Toggle["5d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Toggle["5d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["5d"]["TextSize"] = 14;
				Toggle["5d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Toggle["5d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["5d"]["BackgroundTransparency"] = 1;
				Toggle["5d"]["Size"] = UDim2.new(1, -26, 1, 0);
				Toggle["5d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["5d"]["Text"] = options.Name;
				Toggle["5d"]["Name"] = [[Title]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.UIPadding
				Toggle["5e"] = Instance.new("UIPadding", Toggle["5a"]);
				Toggle["5e"]["PaddingTop"] = UDim.new(0, 6);
				Toggle["5e"]["PaddingRight"] = UDim.new(0, 6);
				Toggle["5e"]["PaddingLeft"] = UDim.new(0, 6);
				Toggle["5e"]["PaddingBottom"] = UDim.new(0, 6);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.CheckmarkHolder
				Toggle["5f"] = Instance.new("Frame", Toggle["5a"]);
				Toggle["5f"]["BorderSizePixel"] = 0;
				Toggle["5f"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 51);
				Toggle["5f"]["AnchorPoint"] = Vector2.new(1, 0.5);
				Toggle["5f"]["Size"] = UDim2.new(0, 16, 0, 16);
				Toggle["5f"]["Position"] = UDim2.new(1, -3, 0.5, 0);
				Toggle["5f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["5f"]["Name"] = [[CheckmarkHolder]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.CheckmarkHolder.UICorner
				Toggle["60"] = Instance.new("UICorner", Toggle["5f"]);
				Toggle["60"]["CornerRadius"] = UDim.new(0, 2);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.CheckmarkHolder.UIStroke
				Toggle["61"] = Instance.new("UIStroke", Toggle["5f"]);
				Toggle["61"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Toggle["61"]["Color"] = Color3.fromRGB(82, 82, 82);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.ToggleInactive.CheckmarkHolder.Checkmark
				Toggle["62"] = Instance.new("ImageLabel", Toggle["5f"]);
				Toggle["62"]["BorderSizePixel"] = 0;
				Toggle["62"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["62"]["ImageTransparency"] = 1;
				Toggle["62"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
				Toggle["62"]["Image"] = [[rbxassetid://79072703275000]];
				Toggle["62"]["Size"] = UDim2.new(1, -2, 1, -2);
				Toggle["62"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["62"]["BackgroundTransparency"] = 1;
				Toggle["62"]["Name"] = [[Checkmark]];
				Toggle["62"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
				updateCanvasSize(Tab["23"], Tab["31"])
			end

			-- Toggle Methods
			do
				function Toggle:Status(b)
					if b == nil then
						Toggle.State = not Toggle.State
					else
						Toggle.State = b
					end

					if Toggle.State then
						GUI:tween(Toggle["5f"], {BackgroundColor3 = Color3.fromRGB(82, 192, 82)})
						GUI:tween(Toggle["62"],{ImageTransparency = 0})
					else
						GUI:tween(Toggle["5f"], {BackgroundColor3 = Color3.fromRGB(51, 51, 51)})
						GUI:tween(Toggle["62"],{ImageTransparency = 1})
					end

					
					options.callback(Toggle.State)
				end

				function Toggle:SetText(text)
					Toggle["5d"].Text = text
					options.Name = text
				end
			end

			-- Toggle Logic
			do
				Toggle["5a"].MouseEnter:Connect(function()	
					Toggle.Hover = true

					GUI:tween(Toggle["5c"], {Color = Color3.fromRGB(152,152,152)})
				end)

				Toggle["5a"].MouseLeave:Connect(function()
					Toggle.Hover = false

					if not Toggle.MouseDown then
						GUI:tween(Toggle["5c"], {Color = Color3.fromRGB(82,82,82)})
					end
				end)

				uis.InputBegan:Connect(function(input, gpe)
					if gpe then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggle.Hover then
						Toggle.MouseDown = true
						GUI:tween(Toggle["5a"], {BackgroundColor3 = Color3.fromRGB(57,57,57)})
						GUI:tween(Toggle["5c"], {Color = Color3.fromRGB(200,200,200)})
						Toggle:Status()
					end
				end)

				uis.InputEnded:Connect(function(input, gpe)
					if gpe then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Toggle.MouseDown = false

						if Toggle.Hover then
							GUI:tween(Toggle["5a"], {BackgroundColor3 = Color3.fromRGB(27, 27, 27)})
							GUI:tween(Toggle["5c"], {Color = Color3.fromRGB(152,152,152)})
						else
							GUI:tween(Toggle["5a"], {BackgroundColor3 = Color3.fromRGB(27, 27, 27)})
							GUI:tween(Toggle["5c"], {Color = Color3.fromRGB(82, 82, 82)})
						end
					end
				end)
			end

			return Toggle
		end

		---------------------------------------------------------------------- SLIDER CREATION
		function Tab:Slider(options)
			options = GUI:validate({
				Text = "Example Slider",
				Min = 0,
				Max = 100,
				Default = 50,
				callback = function(v) print(v) end
			}, options or {})

			local Slider = {
				MouseDown = false,
				Hover = false,
				Connection = nil
			}

			-- Slider Render
			do
				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider
				Slider["3e"] = Instance.new("Frame", Tab["23"]);
				Slider["3e"]["BorderSizePixel"] = 0;
				Slider["3e"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 27);
				Slider["3e"]["Size"] = UDim2.new(1, 0, 0, 38);
				Slider["3e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["3e"]["Name"] = [[Slider]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.UICorner
				Slider["3f"] = Instance.new("UICorner", Slider["3e"]);
				Slider["3f"]["CornerRadius"] = UDim.new(0, 5);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.UIStroke
				Slider["40"] = Instance.new("UIStroke", Slider["3e"]);
				Slider["40"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Slider["40"]["Color"] = Color3.fromRGB(82, 82, 82);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.Title
				Slider["41"] = Instance.new("TextLabel", Slider["3e"]);
				Slider["41"]["BorderSizePixel"] = 0;
				Slider["41"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Slider["41"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["41"]["TextSize"] = 14;
				Slider["41"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Slider["41"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["41"]["BackgroundTransparency"] = 1;
				Slider["41"]["Size"] = UDim2.new(1, -24, 1, -10);
				Slider["41"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["41"]["Text"] = options.Text;
				Slider["41"]["Name"] = [[Title]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.UIPadding
				Slider["42"] = Instance.new("UIPadding", Slider["3e"]);
				Slider["42"]["PaddingTop"] = UDim.new(0, 6);
				Slider["42"]["PaddingRight"] = UDim.new(0, 6);
				Slider["42"]["PaddingLeft"] = UDim.new(0, 6);
				Slider["42"]["PaddingBottom"] = UDim.new(0, 6);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.Value
				Slider["43"] = Instance.new("TextLabel", Slider["3e"]);
				Slider["43"]["BorderSizePixel"] = 0;
				Slider["43"]["TextXAlignment"] = Enum.TextXAlignment.Right;
				Slider["43"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["43"]["TextSize"] = 14;
				Slider["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Slider["43"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["43"]["BackgroundTransparency"] = 1;
				Slider["43"]["AnchorPoint"] = Vector2.new(1, 0);
				Slider["43"]["Size"] = UDim2.new(0, 24, 1, -10);
				Slider["43"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["43"]["Text"] = tostring(options.Default);
				Slider["43"]["Name"] = [[Value]];
				Slider["43"]["Position"] = UDim2.new(1, 0, 0, 0);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.SliderBack
				Slider["44"] = Instance.new("Frame", Slider["3e"]);
				Slider["44"]["BorderSizePixel"] = 0;
				Slider["44"]["BackgroundColor3"] = Color3.fromRGB(13, 13, 13);
				Slider["44"]["AnchorPoint"] = Vector2.new(0, 1);
				Slider["44"]["Size"] = UDim2.new(1, 0, 0, 4);
				Slider["44"]["Position"] = UDim2.new(0, 0, 1, 0);
				Slider["44"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["44"]["Name"] = [[SliderBack]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.SliderBack.UICorner
				Slider["45"] = Instance.new("UICorner", Slider["44"]);
				Slider["45"]["CornerRadius"] = UDim.new(0, 5);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.SliderBack.UIStroke
				Slider["46"] = Instance.new("UIStroke", Slider["44"]);
				Slider["46"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Slider["46"]["Color"] = Color3.fromRGB(78, 78, 78);


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.SliderBack.Draggable
				Slider["47"] = Instance.new("Frame", Slider["44"]);
				Slider["47"]["BorderSizePixel"] = 0;
				Slider["47"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 51);
				Slider["47"]["Size"] = UDim2.new(0.5, 0, 1, 0);
				Slider["47"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["47"]["Name"] = [[Draggable]];


				-- StarterGui.MyLibrary.Main.ContentContainer.HomeTab.Slider.SliderBack.Draggable.UICorner
				Slider["48"] = Instance.new("UICorner", Slider["47"]);
				Slider["48"]["CornerRadius"] = UDim.new(0, 5);
				updateCanvasSize(Tab["23"], Tab["31"])
			end

			-- Slider Methods
			do
				function Slider:SetText(text)
					Slider["41"].Text = text
					options.Text = text
				end

				function Slider:SetValue(v) -- handles slider movment + value output
					if v == nil then
						local percentage = math.clamp((mouse.X - Slider["44"].AbsolutePosition.X) / (Slider["44"].AbsoluteSize.X), 0, 1)
						local value = math.floor(((options.Max - options.Min) * percentage) + options.Min)

						Slider["43"].Text = tostring(value)
						Slider["47"].Size = UDim2.fromScale(percentage, 1) 
					else
						Slider["43"].Text = tostring(v)
						Slider["47"].Size = UDim2.fromScale(((v - options.Min) / (options.Max - options.Min)), 1)
					end
					options.callback(Slider:GetValue())
				end


				function Slider:GetValue()
					return tonumber(Slider["43"].Text)
				end

			end

			-- Slider Logic
			do
				Slider["3e"].MouseEnter:Connect(function()	
					Slider.Hover = true
					GUI:tween(Slider["40"], {Color = Color3.fromRGB(152,152,152)})
					GUI:tween(Slider["46"], {Color = Color3.fromRGB(152,152,152)})
					GUI:tween(Slider["47"], {BackgroundColor3 = Color3.fromRGB(152,152,152)})
				end)

				Slider["3e"].MouseLeave:Connect(function()
					Slider.Hover = false

					if not Slider.MouseDown then
						GUI:tween(Slider["40"], {Color = Color3.fromRGB(82,82,82)})
						GUI:tween(Slider["46"], {Color = Color3.fromRGB(82,82,82)})
						GUI:tween(Slider["47"], {BackgroundColor3 = Color3.fromRGB(82,82,82)})
					end
				end)

				uis.InputBegan:Connect(function(input, gpe)
					if gpe then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 and Slider.Hover then
						Slider.MouseDown = true
						-- GUI:tween(Slider["3e"], {BackgroundColor3 = Color3.fromRGB(57,57,57)})
						-- GUI:tween(Slider["40"], {Color = Color3.fromRGB(200,200,200)})
						GUI:tween(Slider["46"], {Color = Color3.fromRGB(200,200,200)})
						GUI:tween(Slider["47"], {BackgroundColor3 = Color3.fromRGB(200,200,200)})
						if not Slider.Connection then
							Slider.Connection = runService.RenderStepped:Connect(function()
								Slider:SetValue()
							end)
						end
					end
				end)

				uis.InputEnded:Connect(function(input, gpe)
					if gpe then return end

					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Slider.MouseDown = false

						if Slider.Hover then
							-- hover state
							-- GUI:tween(Slider["3e"], {BackgroundColor3 = Color3.fromRGB(27,27,27)})
							-- GUI:tween(Slider["40"], {Color = Color3.fromRGB(102,102,102)})
							GUI:tween(Slider["46"], {Color = Color3.fromRGB(102,102,102)})
							GUI:tween(Slider["47"], {BackgroundColor3 = Color3.fromRGB(102,102,102)})
						else
							-- reset
							-- GUI:tween(Slider["3e"], {BackgroundColor3 = Color3.fromRGB(27,27,27)})
							-- GUI:tween(Slider["40"], {Color = Color3.fromRGB(82,82,82)})
							GUI:tween(Slider["46"], {Color = Color3.fromRGB(82,82,82)})
							GUI:tween(Slider["47"], {BackgroundColor3 = Color3.fromRGB(82,82,82)})
						end

						if Slider.Connection then Slider.Connection:Disconnect() end
						Slider.Connection = nil
					end
				end)
			end
			Slider:SetValue(options.Default)
			return Slider
		end

		
		return Tab
	end

	
	return GUI
end
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~
