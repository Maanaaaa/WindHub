local colors = {
    Red = 'Really red',
    Blue = 'Bright blue',
    Yellow = 'New Yeller',
    Orange = 'Bright orange',
    Green = 'Lime green',
    Pink = 'Hot pink',
    Purple = 'Royal purple',
    White = 'White',
    Gray = 'Medium stone grey',
    DarkGray = 'Dark stone grey',
    Black = 'Black',
}

function colors:toRGB(color: string)
    color = colors[color]
    if not color then return Color3.fromRGB(255, 255, 255) end
    local brickColor = BrickColor.new(color)
    local c = brickColor.Color
    return Color3.fromRGB(math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

return colors