-- https://imgur.com/a/QJSEriq


local difficiculty = 4


local core       = {hp=0,dmg=0}
local firewall   = {hp=0,dmg=0}
local antiVirus  = {hp=0,dmg=0}
local healer     = {hp=0,dmg=0}
local suppressor = {hp=0,dmg=0}

if (difficiculty==4) then
core       = {hp=90,dmg=10}
firewall   = {hp=90,dmg=20}
antiVirus  = {hp=60,dmg=40}
healer     = {hp=80,dmg=10}
suppressor = {hp=60,dmg=15}
elseif (difficiculty==3) then
core       = {hp=70,dmg=10}
firewall   = {hp=80,dmg=20}
antiVirus  = {hp=50,dmg=40}
healer     = {hp=80,dmg=10}
elseif (difficiculty==2) then
core       = {hp=70,dmg=10}
firewall   = {hp=60,dmg=20}
antiVirus  = {hp=30,dmg=40}
elseif (difficiculty==1) then
core       = {hp=50,dmg=10}
firewall   = {hp=40,dmg=20}
antiVirus  = {hp=30,dmg=30}
end

local map = {}

local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()
local COLNUM = 10
local ROWNUM = 9
local DX = WIDTH/(COLNUM+1)
local DY = HEIGHT/(ROWNUM+1.5)
local RADIUS = 20

local status = "setSpawn"
local spawnNode = nil

for x=1,10 do
    local col = {}
    for y=1,9 do
        local d = (y%2 == 0) and DX*0.25 or DX*-0.25

        local neighbors = {}
        if (x>1)    then table.insert(neighbors, {x=x-1,y=y+0}) end -- -o
        if (y>1)    then table.insert(neighbors, {x=x+0,y=y-1}) end -- \o/
        if (x<COLNUM) then table.insert(neighbors, {x=x+1,y=y+0}) end --  o-
        if (y<ROWNUM) then table.insert(neighbors, {x=x+0,y=y+1}) end --  /o\

        if (y%2==1) then
            if (x>1 and y<ROWNUM)      then table.insert(neighbors, {x=x-1,y=y+1}) end -- /o
            if (x>1 and y>1)           then table.insert(neighbors, {x=x-1,y=y-1}) end -- \o
        else
            if (x<COLNUM and y<ROWNUM) then table.insert(neighbors, {x=x+1,y=y+1}) end -- o\
            if (x<COLNUM and y>1)           then table.insert(neighbors, {x=x+1,y=y-1}) end -- o/
        end
        local node = 
        {
            numOfNeighbors = 6,
            isWall = false,
            distanceFromSpawn = 99,
            x = x*DX+d,
            y = y*DY,
            neighbors = neighbors,
            type = "normal",
            isBlocked = false,
            isPossibleGood = false,
        }
        table.insert(col,node)
    end
    table.insert(map,col)
end

function love.update(dt)
end

function setNodeColor(node)
    
    if (node.distanceFromSpawn==0) then --spawn
        love.graphics.setColor(0.3,0.3,1,1) 
    elseif (node.distanceFromSpawn==1) then
        love.graphics.setColor(0,0.7,0.7,1)
    elseif (node.distanceFromSpawn==99) then -- no path here ??
        love.graphics.setColor(0.1,0.1,0.1,1)
    elseif (node.distanceFromSpawn>=8) then -- possible core (brighter)
        if (node.numOfNeighbors==3) then
            love.graphics.setColor(1,0,1,1)
        elseif (node.numOfNeighbors==6) then
            love.graphics.setColor(0,1,0,1)
        else
            love.graphics.setColor(1,1,0,1) 
        end
    else -- there is no core (darker)
        if (node.numOfNeighbors==3) then --possible white
            love.graphics.setColor(0.5,0,0.5,1) 
        elseif (node.numOfNeighbors==6) then
            love.graphics.setColor(0,0.5,0,1)
        else
            love.graphics.setColor(0.4,0.4,0.4,1) -- default
        end
    end
end

function drawExtra(node)
    if (node.type == "normal") then
        --
    elseif (tonumber(node.type)) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(node.type,node.x-RADIUS/2,node.y-RADIUS,0,3,3)
    elseif (node.type == "enemy") then
        love.graphics.setColor(1,0,0,1)
        love.graphics.circle("fill",node.x,node.y,RADIUS/2)
    elseif (node.type == "white") then
        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill",node.x,node.y,RADIUS/2)
    end

    if (node.isBlocked) then
        love.graphics.setColor(0,0,0,0.7)
        love.graphics.circle("fill",node.x,node.y,RADIUS+1)
    end

    if (node.isPossibleGood) then
        love.graphics.setColor(1,0.7,0,0.7)
        love.graphics.circle("fill",node.x,node.y,RADIUS/4)
    end

end

function love.draw()
    love.graphics.setColor(1,1,1,1)
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do

            if (not node.isWall) then
                setNodeColor(node)
                love.graphics.circle("line",node.x,node.y,RADIUS)

    
                for i,n in ipairs(node.neighbors) do
                    local nodeB = map[n.x][n.y]
                    if (not nodeB.isWall) then
                        local dx = (node.x-nodeB.x)/2
                        local dy = (node.y-nodeB.y)/2
                        love.graphics.line(node.x,node.y,nodeB.x+dx,nodeB.y+dy)
                    end
                end

                drawExtra(node)
            else
                love.graphics.setColor(0.1,0.1,0.1,1)
                love.graphics.circle("line",node.x,node.y,RADIUS)
            end

        end
    end
end

function setStatus()

    if (not spawnNode) then return end

    --reset numbers
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do
            node.distanceFromSpawn = 99
            node.numOfNeighbors = 0
        end
    end


    local notVisited = {}

    spawnNode.distanceFromSpawn = 0
    table.insert(notVisited,spawnNode)

    while (#notVisited>0) do
        local node = table.remove(notVisited,1)

        for i,n in ipairs(node.neighbors) do
            local nodeB = map[n.x][n.y]

            if (not nodeB.isWall) then
                node.numOfNeighbors = node.numOfNeighbors + 1
                if (nodeB.distanceFromSpawn == 99) then
                    nodeB.distanceFromSpawn = node.distanceFromSpawn + 1
                    table.insert(notVisited,nodeB)
                end
            end
        end
    end
end

function getNodesFromDistance(node,distance)
    local notVisited = {}
    local ret = {ok={},nok={}}

    --reset numbers
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do
            node._extraData_distance = 99
        end
    end

    node._extraData_distance = 0
    table.insert(notVisited,node)
    table.insert(ret.nok,node)

    while (#notVisited>0) do
        local node = table.remove(notVisited,1)

        for i,n in ipairs(node.neighbors) do
            local nodeB = map[n.x][n.y]

            if (not nodeB.isWall) then
                if (nodeB._extraData_distance == 99) then
                    nodeB._extraData_distance = node._extraData_distance + 1
                    if (nodeB._extraData_distance == distance) then
                        table.insert(ret.ok,nodeB)
                    else
                        table.insert(ret.nok,nodeB)
                        table.insert(notVisited,nodeB)
                    end
                end
            end
        end

    end

    return ret
end

function getPossibleGood()

    --reset numbers
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do
            node.isPossibleGood = false
        end
    end

    local list = {}
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do
            if (tonumber(node.type)) then
                local pg = getNodesFromDistance(node,node.type)
                for i,node in ipairs(pg.ok) do
                    node.isPossibleGood = true
                end

            end
        end
    end
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do
            if (tonumber(node.type)) then
                local pg = getNodesFromDistance(node,node.type)
                for i,node in ipairs(pg.nok) do
                    node.isPossibleGood = false
                end

            end
        end
    end
end

function nodeClicked(node,button)

    if (status=="setSpawn") then
        spawnNode = node
        status="run"
        setStatus()
        return
    end

    if (node.type == "normal") then
        node.type = "wall"
        node.isWall = true
    elseif (node.type == "wall") then
        node.type = 5
        node.isWall = false
        getPossibleGood(node,node.type)
    elseif (tonumber(node.type) and tonumber(node.type)>0 and tonumber(node.type)<6) then
        node.type = node.type - 1
        if (node.type==0) then 
            node.type = "white"
        end
        getPossibleGood(node,node.type)
    elseif (node.type == "white") then
        node.type = "enemy"
        for i,n in ipairs(node.neighbors) do
            local nodeB = map[n.x][n.y]
            nodeB.isBlocked = true
        end
    elseif (node.type == "enemy") then
        node.type = "normal"
        for i,n in ipairs(node.neighbors) do
            local nodeB = map[n.x][n.y]
            nodeB.isBlocked = false
        end
    end

    setStatus()
end

function love.mousepressed(cx, cy, button, istouch, presses)
    for x,col in ipairs(map) do
        for y,node in ipairs(col) do
            if math.abs(node.x-cx)+math.abs(node.y-cy) < RADIUS then 
                nodeClicked(node,button)
            end
        end
    end
end