local plrs = game:GetService('Players')
local lplr = plrs.LocalPlayer

local mana = shared.wind
local library = mana.library
local universalSection = mana.universalSection
local miscSection = mana.miscSection

local function getCharacter()
    return lplr.Character
end

local function getRootPart()
    return getCharacter().HumanoidRootPart
end

local function getHumanoid()
    return getCharacter().Humanoid
end

universalSection:CreateSlider({
    Name = 'Walk speed',
    Min = 1,
    Max = 100,
    Default = 16,
    Callback = function(v)
        getHumanoid().WalkSpeed = v
    end
})

universalSection:CreateSlider({
    Name = 'Jump power',
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(v)
        getHumanoid().JumpPower = v
    end
})

universalSection:CreateButton({
    Name = 'Reset character',
    Callback = function()
        getHumanoid().Health = 0
    end
})

-- // miscSection
miscSection:CreateButton({
    Name = 'Copy discord',
    CallbackText = 'Discord copied',
    Callback = function()
        toclipboard('https://discord.gg/CEMMRSvXek')
    end
})

miscSection:CreateButton({
    Name = 'Uninject',
    Callback = function()
        library:Destruct()
    end
})

--[[
miscSection:Label("made with <3\nby Maanaaaa",{
    TextSize = 15,
    TextColor = Color3.fromRGB(255, 255, 255),
    BgColor = Color3.fromRGB(67, 67, 67)
})
]]