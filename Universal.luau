local runService = game:GetService('RunService')
local plrs = game:GetService('Players')
local lplr = plrs.LocalPlayer

local wind = shared.wind
local library = wind.library
local playerSection = wind.playerSection
local miscSection = wind.miscSection

local function runFunction(func) func() end

local function isAlive(plr, headCheck)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChildOfClass('Humanoid')) and plr.Character:FindFirstChild('HumanoidRootPart') and (headCheck and plr.Character:FindFirstChild('Head') or not headCheck)) then
        return true
    else
        return false
    end
end

local function getCharacter()
    return lplr.Character
end

local function getRoot()
    if not isAlive() then return end
    return getCharacter().HumanoidRootPart
end

local function getHumanoid()
    if not isAlive() then return end
    return getCharacter().Humanoid
end

local oldSpeed
runFunction(function()
    local speed = {Value = 16}
    speed = playerSection:CreateSlider({
        Name = 'Walk speed',
        Min = 1,
        Max = 100,
        Default = 16,
        Callback = function(v)
            getHumanoid().WalkSpeed = v
        end
    })

    if isAlive() then
        oldSpeed = getHumanoid().WalkSpeed
    end

    table.insert(shared.wind.connections, runService.RenderStepped:Connect(function(dt)
        if not isAlive() then return end
        local velocity = getHumanoid().MoveDirection * (speed.Value * 5) * dt
        getCharacter():TranslateBy(Vector3.new(velocity.X / 10, 0, velocity.Z / 10))
    end))
end)

playerSection:CreateSlider({
    Name = 'Jump power',
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(v)
        getHumanoid().JumpPower = v
    end
})

playerSection:CreateButton({
    Name = 'Reset character',
    Callback = function()
        getHumanoid().Health = 0
    end
})

-- // miscSection
--[[
miscSection:CreateButton({
    Name = 'Copy discord',
    CallbackText = 'Discord copied',
    Callback = function()
        toclipboard('https://discord.gg/CEMMRSvXek')
    end
})
]]

miscSection:CreateButton({
    Name = 'Uninject',
    Callback = function()
        library:Destruct()
        if isAlive() then
            getHumanoid().WalkSpeed = oldSpeed
        end
    end
})