local library = {
    windows = {}
}

local userInputService = game:GetService('UserInputService')
local tweenService = game:GetService('TweenService')
local players = game:GetService('Players')
local lplr = players.LocalPlayer
local coreGui

local connections = shared.wind and shared.wind.connections or {}

local suc, res = pcall(function()
    return game:GetService('CoreGui')
end)
coreGui = suc and res or lplr.playerGui

local screenGui = Instance.new('ScreenGui', coreGui)

function library:addUICorner(obj, radius, scale)
    local uiCorner = Instance.new('UICorner', obj)
    uiCorner.CornerRadius = UDim.new(scale or 0, radius)
    return uiCorner
end

function library:addUIListLayout(obj)
    local uiList = Instance.new('UIListLayout', obj)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    return uiList
end

function library:drag(gui, button)
	task.spawn(function()
		local dragging, dragInput, startPos
        local dragStart, button = Vector3.new(0, 0, 0), button or gui
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			tweenService:Create(gui, TweenInfo.new(0.2), {Position = Position}):Play()
		end
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, dragStart, startPos = true, input.Position, gui.Position

				input.Changed:Connect(function()
                    dragging = not input.UserInputState == Enum.UserInputState.End
				end)
			end
		end)
		button.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		userInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

function library:Destruct()
    for _, connection in next, connections do
        connection:Disconnect()
    end
    screenGui:Destroy()
end

-- // theme system
local pallet = {
    main = Color3.fromRGB(60, 60, 60),
    secondary = Color3.fromRGB(50, 50, 50),
    third = Color3.fromRGB(100, 100, 100),
    color = Color3.fromRGB(62, 204, 211),
    mainText = Color3.fromRGB(255, 255, 255),
    secondaryText = Color3.fromRGB(230, 230, 230),
    buttonText = Color3.fromRGB(0, 0, 0),
    font = Enum.Font.Cartoon
}

function pallet:dark(color, value)
    local h, s, v = color:ToHSV()
    return Color3.fromRGB(h * 255, s * 255, (v - value) * 255)
end

function pallet:light(color, value)
    local h, s, v = color:ToHSV()
    return Color3.fromRGB(h * 255, s * 255, (v + value) * 255)
end


--[[

current todo:
make tabs minimize

]]

function library:CreateWindow(name)
    shared.manaLibrary = shared.manaLibrary or {
        screen = screenGui
    }
    local window = {
        name = name,
        sections = {}
    }
    table.insert(self.windows, window)
    local background = Instance.new('Frame', screenGui)
    background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    background.BorderSizePixel = 0
    background.Position = UDim2.fromOffset(10 + (#self.windows - 1 ) * 190, 10)
    background.Size = UDim2.fromOffset(180, 25)
    library:addUICorner(background, 4)
    local title = Instance.new('TextLabel', background)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Size = UDim2.fromOffset(180, 25)
    title.Font = pallet.font
    title.Text = ' '..name
    title.TextColor3 = pallet.mainText
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    library:drag(background, title)
    local close = Instance.new('TextButton', background)
    close.Name = 'close'
    close.BackgroundTransparency = 1
    close.BorderSizePixel = 0
    close.Position = UDim2.fromOffset(155, 0)
    close.Size = UDim2.fromOffset(25, 20)
    close.Font = pallet.font
    close.Text = '-'
    close.TextColor3 = pallet.mainText
    close.TextSize = 30
    local container = Instance.new('Frame', background)
    container.Name = 'container'
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Position = UDim2.fromOffset(0, 26)
    container.Size = UDim2.fromOffset(0, 0)
    local uiList = library:addUIListLayout(container)

    function window:ReSize()
        local y = uiList.AbsoluteContentSize.Y
        background.Size = UDim2.fromOffset(180, y + 25 + 3)
        container.Size = UDim2.fromOffset(180, y)
    end

    table.insert(connections, uiList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(window.ReSize))

    function window:CreateSection(name)
        local section = {
            Name = name,
            Expanded = false,
            expanded = false,
            options = {}
        }
        table.insert(window.sections, section)
        local frame = Instance.new('TextLabel', container)
        frame.Name = name
        frame.BackgroundColor3 = pallet.secondary
        frame.BorderSizePixel = 0
        frame.Size = UDim2.fromOffset(180, 25)
        frame.Font = pallet.font
        frame.Text = ' '..name
        frame.TextColor3 = pallet.mainText
        frame.TextSize = 18
        frame.TextXAlignment = Enum.TextXAlignment.Left
        frame.LayoutOrder = #window.sections
        local expand = Instance.new('TextButton', frame)
        expand.Name = 'expand'
        expand.BackgroundTransparency = 1
        expand.BorderSizePixel = 0
        expand.Position = UDim2.fromOffset(155, 0)
        expand.Rotation = 90
        expand.Size = UDim2.fromOffset(25, 25)
        expand.Font = pallet.font
        expand.Text = '<'
        expand.TextColor3 = pallet.mainText
        expand.TextSize = 20
        local container = Instance.new('Frame', container)
        container.Name = 'container'
        container.BackgroundColor3 = pallet.secondary
        container.BorderSizePixel = 0
        container.Position = UDim2.fromScale(0, 1)
        container.Size = UDim2.fromOffset(180, 0)
        container.Visible = false
        container.LayoutOrder = #window.sections
        local uiList = library:addUIListLayout(container)

        function section:Expand(bool)
            if bool == nil then bool = not self.expanded end
            if bool == self.expanded then return end
            self.Expanded = bool
            self.expanded = bool
            container.Visible = bool
            expand.Text = bool and '>' or '<'
            window:ReSize()
        end

        function section:expand(bool)
            return section:Expand(bool)
        end

        function section:GetContainer()
            return container
        end

        function section:getContainer()
            return container
        end

        table.insert(connections, expand.MouseButton1Click:Connect(section.expand))
        table.insert(connections, uiList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            container.Size = UDim2.fromOffset(180, uiList.AbsoluteContentSize.Y)
            window:ReSize()
        end))

        -- // ONLY FOR DEV TIME
        --section:Expand()

        function section:CreateToggle(argstable)
            local name = argstable.Name
            local default = argstable.Default or false
            local callback = argstable.Callback or function() end
            local toggle = {
                name = name,
                Enabled = false,
                callback = callback,
                tween = nil,
            }
            table.insert(section.options, toggle)
            local background = Instance.new('Frame', container)
            background.Name = name
            background.BackgroundTransparency = 1
            background.BorderSizePixel = 0
            background.Size = UDim2.fromOffset(180, 26)
            background.LayoutOrder = #section.options
            toggle.container = background
            local text = Instance.new('TextLabel', background)
            text.Name = 'text'
            text.BackgroundTransparency = 1
            text.BorderSizePixel = 0
            text.Size = UDim2.fromOffset(140, 26)
            text.Font = pallet.font
            text.Text = ' '..tostring(name)
            text.TextColor3 = pallet.secondaryText
            text.TextSize = 18
            text.TextXAlignment = Enum.TextXAlignment.Left
            local frame = Instance.new('Frame', background)
            frame.BackgroundColor3 = pallet.third
            frame.BorderSizePixel = 0
            frame.Position = UDim2.fromOffset(152, 3)
            frame.Size = UDim2.fromOffset(20, 20)
            library:addUICorner(frame, 4)
            local button = Instance.new('TextButton', frame)
            button.BackgroundColor3 = pallet.main
            button.BorderSizePixel = 0
            button.Position = UDim2.fromOffset(2, 2)
            button.Size = UDim2.fromOffset(16, 16)
            button.Font = pallet.font
            button.Text = ''
            button.TextColor3 = pallet.secondaryText
            button.TextSize = 16
            button.TextYAlignment = Enum.TextYAlignment.Top
            library:addUICorner(button, 3)

            function toggle:Toggle(bool)
                if bool == nil then bool = not self.Enabled end
                if bool == self.Enabled then return end
                task.spawn(function()
                    if self.tween then self.tween:Cancel() end
                    self.Enabled = bool
                    self.tween = tweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = bool and pallet.color or pallet.main})
                    self.tween:Play()
                end)
                task.spawn(function()
                    callback(bool)
                end)
            end

            function toggle:toggle(bool)
                return toggle:Toggle(bool)
            end

            table.insert(connections, button.MouseButton1Click:Connect(toggle.toggle))
            toggle:Toggle(default)

            return toggle
        end

        function section:CreateButton(argstable)
            local name = argstable.Name
            local callbackText = argstable.CallbackText or name
            local callback = argstable.Callback or function() end
            local button = {
                Name = name,
                Callback = callback
            }
            table.insert(section.options, button)
            local background = Instance.new('Frame', container)
            background.Name = name
            background.BackgroundTransparency = 1
            background.BorderSizePixel = 0
            background.Size = UDim2.fromOffset(180, 26)
            background.LayoutOrder = #section.options
            button.container = background
            local realButton = Instance.new('TextButton', background)
            realButton.Name = 'button'
            realButton.BackgroundColor3 = pallet.color
            realButton.BorderSizePixel = 0
            realButton.Position = UDim2.fromOffset(20, 3)
            realButton.Size = UDim2.fromOffset(140, 20)
            realButton.Font = pallet.font
            realButton.Text = tostring(name)
            realButton.TextColor3 = pallet.buttonText
            realButton.TextSize = 18
            library:addUICorner(realButton, 4)
            table.insert(connections, realButton.MouseButton1Click:Connect(function()
                task.spawn(callback)
                realButton.Text = tostring(callbackText)
                task.wait(2)
                realButton.Text = tostring(name)
            end))
            return button
        end

        function section:CreateSlider(argstable)
            local name = argstable.Name
            local min, max = argstable.Min, argstable.Max
            local decimal = argstable.Decimal or 0
            local default = argstable.Default or min
            local callback = argstable.Callback or function() end
            local slider = {
                Name = name,
                Min = min,
                Max = max,
                Default = default,
                Callback = callback,
                lineTween = nil,
                knobPositionTween = nil,
                knobTransparencyTween = nil,
            }
            table.insert(section.options, slider)
            local background = Instance.new('Frame', container)
            background.BackgroundTransparency = 1
            background.BorderSizePixel = 0
            background.Size = UDim2.fromOffset(180, 40)
            background.LayoutOrder = #section.options
            slider.container = background
            local text = Instance.new('TextLabel', background)
            text.Name = 'text'
            text.BackgroundTransparency = 1
            text.BorderSizePixel = 0
            text.Size = UDim2.fromOffset(125, 26)
            text.Font = pallet.font
            text.Text = ' '..tostring(name)
            text.TextColor3 = pallet.secondaryText
            text.TextSize = 18
            text.TextXAlignment = Enum.TextXAlignment.Left
            local textboxOutline = Instance.new('Frame', background)
            textboxOutline.BackgroundColor3 = pallet.third
            textboxOutline.BorderSizePixel = 0
            textboxOutline.Position = UDim2.fromOffset(137, 3)
            textboxOutline.Size = UDim2.fromOffset(35, 20)
            library:addUICorner(textboxOutline, 4)
            local textbox = Instance.new('TextBox', textboxOutline)
            textbox.BackgroundColor3 = pallet.secondary
            textbox.BorderSizePixel = 0
            textbox.Position = UDim2.fromOffset(2, 2)
            textbox.Size = UDim2.fromOffset(31, 16)
            textbox.Font = pallet.font
            textbox.Text = ''
            textbox.TextColor3 = pallet.secondaryText
            textbox.TextSize = 14
            library:addUICorner(textbox, 3)
            local lineBackground = Instance.new('TextButton', background)
            lineBackground.AutoButtonColor = false
            lineBackground.Name = 'lineBackground'
            lineBackground.BackgroundColor3 = pallet.third
            lineBackground.BorderSizePixel = 0
            lineBackground.Position = UDim2.fromOffset(10, 29)
            lineBackground.Size = UDim2.fromOffset(160, 4)
            lineBackground.Text = ""
            library:addUICorner(lineBackground, 4)
            local line = Instance.new('TextButton', lineBackground)
            line.AutoButtonColor = false
            line.Name = 'line'
            line.BackgroundColor3 = pallet.color
            line.BorderSizePixel = 0
            line.Size = UDim2.fromScale(0, 1)
            line.Text = ''
            library:addUICorner(line, 4)
            local knob = Instance.new('TextButton', lineBackground)
            knob.AutoButtonColor = false
            knob.Name = 'knob'
            knob.BackgroundTransparency = 1
            knob.BorderSizePixel = 0
            knob.Position = UDim2.new(0, -6, -0.75, 0)
            knob.Size = UDim2.fromOffset(12, 12)
            knob.ZIndex = 3
            knob.Text = ''
            library:addUICorner(knob, 0, 1)

            function slider:Set(value)
                if self.lineTween then self.lineTween:Cancel() end
                if self.knobPositionTween then self.knobPositionTween:Cancel() end
                value = value or min
                local sizeValue = math.floor((math.clamp(value, min, max) * (10 ^ decimal)) + 0.5) / (10 ^ decimal)
                self.Value = sizeValue
                local tween = tweenService:Create(line, TweenInfo.new(0.2), {Size = UDim2.fromScale((sizeValue - min) / (max - min), 1)}):Play()
                self.lineTween = tween
                local tween = tweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new((sizeValue - min) / (max - min), -6, -0.75, 0)}):Play()
                self.knobPositionTween = tween
                textbox.PlaceholderText = tostring(value)
                callback(value)
            end

            local function slide(input)
                if self.lineTween then self.lineTween:Cancel() end
                if self.knobPositionTween then self.knobPositionTween:Cancel() end
                local sizeX = math.clamp((input.Position.X - lineBackground.AbsolutePosition.X) / lineBackground.AbsoluteSize.X, 0, 1)
                local value = math.floor(((((max - min) * sizeX) + min) * (10 ^ decimal)) + 0.5) / (10 ^ decimal)
                self.Value = value
                local tween = tweenService:Create(line, TweenInfo.new(0.2), {Size = UDim2.fromScale(sizeX, 1)}):Play()
                self.lineTween = tween
                local tween = tweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(sizeX, -6, -0.75, 0)}):Play()
                self.knobPositionTween = tween
                textbox.PlaceholderText = tostring(value)
                callback(value)
            end

            table.insert(connections, textbox.FocusLost:Connect(function(enterPressed)
                if not enterPressed then return end
                slider:Set(tonumber(textbox.Text))
                textbox.Text = ''
            end))

            local sliding, hovering, lastSlide = false, false, tick()
            local function delayTween()
                task.delay(2, function()
                    if tick() - lastSlide > 2 and not sliding and not hovering then --tick() - 2 > lastSlide
                        local tween = tweenService:Create(knob, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                        slider.knobTween = tween
                    end
                end)
            end
            local function hookDrag(obj)
                table.insert(connections, obj.InputBegan:Connect(function(input)
                    local tween = tweenService:Create(knob, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                    slider.knobTransparencyTween = tween
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding, hovering, lastSlide = true, true, tick()
                        slide(input)
                    end
                    delayTween()
                end))

                table.insert(connections, obj.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding, hovering = false, false
                    end
                    delayTween()
                end))

                table.insert(connections, userInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        hovering, lastSlide = true, tick()
                        slide(input)
                        delayTween()
                    end
                end))
            end

            hookDrag(lineBackground)
            hookDrag(line)
            hookDrag(knob)
            slider:Set(default)

            return slider
        end

        function section:CreateDropdown(argstable)
            local name = argstable.Name
            local list = argstable.List
            local value = argstable.Default or list[1]
            local callback = argstable.Callback or function() end
            local dropdown = {
                Name = name,
                List = list,
                Value = value,
                Expanded = false,
                Callback = callback
            }
            table.insert(section.options, dropdown)
            local background = Instance.new('Frame', container)
            background.Name = name
            background.BackgroundTransparency = 1
            background.BorderSizePixel = 0
            background.Size = UDim2.fromOffset(180, 26)
            background.LayoutOrder = #section.options
            dropdown.container = background
            local text = Instance.new('TextLabel', background)
            text.Name = 'text'
            text.BackgroundTransparency = 1
            text.BorderSizePixel = 0
            text.Size = UDim2.fromOffset(160, 26)
            text.Font = pallet.font
            text.Text = ' '..tostring(name)..': '..tostring(value)
            text.TextColor3 = pallet.secondaryText
            text.TextSize = 18
            text.TextXAlignment = Enum.TextXAlignment.Left
            local expand = Instance.new('TextButton', background)
            expand.Name = 'expand'
            expand.BackgroundTransparency = 1
            expand.BorderSizePixel = 0
            expand.Position = UDim2.fromOffset(155, 0)
            expand.Size = UDim2.fromOffset(25, 25)
            expand.Font = pallet.font
            expand.Text = '>'
            expand.TextColor3 = pallet.mainText
            expand.TextSize = 20
            local optionsFrame = Instance.new('ScrollingFrame', background)
            optionsFrame.Name = 'options'
            optionsFrame.BackgroundColor3 = pallet.secondary
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Position = UDim2.fromOffset(200, 0)
            optionsFrame.Size = UDim2.fromOffset(120, 0)
            optionsFrame.CanvasSize = UDim2.fromScale(0, 0)
            optionsFrame.ScrollBarThickness = 1
            optionsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            optionsFrame.Visible = false
            library:addUICorner(optionsFrame, 4)
            local uiList = library:addUIListLayout(optionsFrame)

            function dropdown:Set(newValue)
                if not table.find(list, newValue) then return end
                value = newValue
                self.Value = value
                text.Text = ' '..tostring(name)..': '..tostring(value)
                task.spawn(function()
                    callback(value)
                end)
                task.spawn(function()
                    for _, option in next, optionsFrame:GetChildren() do
                        if option:IsA('TextButton') then
                            option.Visible = option.Name ~= value
                        end
                    end
                end)
            end

            function dropdown:Expand(bool)
                if bool == nil then bool = not self.Expanded end
                if bool == self.Expanded then return end
                self.Expanded = bool
                expand.Text = bool and '<' or '>'
                optionsFrame.Visible = bool
            end

            function dropdown:expand(bool)
                return dropdown:Expand(bool)
            end

            local function createOption(name)
                local option = Instance.new('TextButton', optionsFrame)
                option.Name = name
                option.BackgroundTransparency = 1
                option.BorderSizePixel = 0
                option.Size = UDim2.fromOffset(120, 25)
                option.Font = pallet.font
                option.Text = ' '..tostring(name)
                option.TextColor3 = pallet.secondaryText
                option.TextSize = 18
                option.TextXAlignment = Enum.TextXAlignment.Left

                table.insert(connections, option.MouseButton1Click:Connect(function()
                    dropdown:Set(name)
                    dropdown:expand()
                end))
            end

            for _, option in next, list do
                createOption(option)
            end
            dropdown:Set(value)

            table.insert(connections, expand.MouseButton1Click:Connect(dropdown.expand))
            table.insert(connections, uiList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                local y = uiList.AbsoluteContentSize.Y
                optionsFrame.Size = UDim2.fromOffset(120, y > 100 and 100 or y)
                optionsFrame.CanvasSize = UDim2.fromOffset(120, y)
            end))

            return dropdown
        end

        function section:CreateMultiDropdown(argstable)
            local name = argstable.Name
            local list = argstable.List
            local choosedList = argstable.DefaultList or {}
            local callback = argstable.Callback or function() end
            local dropdown = {
                Name = name,
                List = list,
                ChoosedList = choosedList,
                Expanded = false,
                Callback = callback,
                tweens = {}
            }
            table.insert(section.options, dropdown)
            local background = Instance.new('Frame', container)
            background.Name = name
            background.BackgroundTransparency = 1
            background.BorderSizePixel = 0
            background.Size = UDim2.fromOffset(180, 26)
            background.LayoutOrder = #section.options
            dropdown.container = background
            local text = Instance.new('TextLabel', background)
            text.Name = 'text'
            text.BackgroundTransparency = 1
            text.BorderSizePixel = 0
            text.Size = UDim2.fromOffset(160, 26)
            text.Font = pallet.font
            text.Text = ' '..tostring(name)..': '..tostring(#choosedList == 0 and 'none' or #choosedList == 1 and choosedList[1] or '...')
            text.TextColor3 = pallet.secondaryText
            text.TextSize = 18
            text.TextXAlignment = Enum.TextXAlignment.Left
            local expand = Instance.new('TextButton', background)
            expand.Name = 'expand'
            expand.BackgroundTransparency = 1
            expand.BorderSizePixel = 0
            expand.Position = UDim2.fromOffset(155, 0)
            expand.Size = UDim2.fromOffset(25, 25)
            expand.Font = pallet.font
            expand.Text = '>'
            expand.TextColor3 = pallet.mainText
            expand.TextSize = 20
            local optionsFrame = Instance.new('ScrollingFrame', background)
            optionsFrame.Name = 'options'
            optionsFrame.BackgroundColor3 = pallet.secondary
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Position = UDim2.fromOffset(200, 0)
            optionsFrame.Size = UDim2.fromOffset(120, 0)
            optionsFrame.CanvasSize = UDim2.fromScale(0, 0)
            optionsFrame.ScrollBarThickness = 1
            optionsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            optionsFrame.Visible = false
            library:addUICorner(optionsFrame, 4)
            local uiList = library:addUIListLayout(optionsFrame)

            function dropdown:Set(value)
                if not table.find(list, value) then return end
                if self.tweens[value] then self.tweens[value]:Cancel() end
                local bool = true
                if table.find(choosedList, value) then bool = false end
                local option = optionsFrame:FindFirstChild(value)
                if bool then
                    if table.find(choosedList, value) then return end
                    table.insert(choosedList, value)
                else
                    if not table.find(choosedList, value) then return end
                    table.remove(choosedList, table.find(choosedList, value))
                end
                if option then
                    self.tweens[value] = tweenService:Create(option, TweenInfo.new(0.2), {BackgroundColor3 = bool and pallet.color or pallet.secondary}):Play()
                else
                end
                text.Text = ' '..tostring(name)..': '..tostring(#choosedList == 0 and 'none' or #choosedList == 1 and choosedList[1] or '...')
                self.ChoosedList = choosedList
                task.spawn(function()
                    callback(value, bool)
                end)
            end

            function dropdown:Expand(bool)
                if bool == nil then bool = not self.Expanded end
                if bool == self.Expanded then return end
                self.Expanded = bool
                expand.Text = bool and '<' or '>'
                optionsFrame.Visible = bool
            end

            function dropdown:expand(bool)
                return dropdown:Expand(bool)
            end

            local function createOption(name)
                local option = Instance.new('TextButton', optionsFrame)
                option.Name = name
                option.BackgroundColor3 = pallet.secondary
                option.BorderSizePixel = 0
                option.Size = UDim2.fromOffset(120, 25)
                option.Font = pallet.font
                option.Text = ' '..tostring(name)
                option.TextColor3 = pallet.secondaryText
                option.TextSize = 18
                option.TextXAlignment = Enum.TextXAlignment.Left

                table.insert(connections, option.MouseButton1Click:Connect(function()
                    dropdown:Set(name, table.find(choosedList, name) and false or true)
                end))
            end

            for _, option in next, list do
                createOption(option)
            end
            for _, v in next, choosedList do
                dropdown:Set(v, true)
            end

            table.insert(connections, expand.MouseButton1Click:Connect(dropdown.expand))
            table.insert(connections, uiList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                local y = uiList.AbsoluteContentSize.Y
                optionsFrame.Size = UDim2.fromOffset(120, y > 100 and 100 or y)
                optionsFrame.CanvasSize = UDim2.fromOffset(120, y)
            end))

            return dropdown
        end
        return section
    end
    return window
end

return library