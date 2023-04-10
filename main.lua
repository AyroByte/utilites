--[[
    DOCUMENTATION:
        utilities:isAlive(Model character)
            -> Returns true if the character is alive (self-explanatory).
        
        utilities:worldToScreenPoint(Part object)
            -> Returns the 2D screen location of an object in the world, the depth of it from the screen and whether it is visible. Accounts for the GUI inset.
        
        utilities:worldToViewportPoint(Part object)
            -> Returns the 2D screen location of an object in the world, but does not account for the GUI inset.

        utilities:getClosestPlayerFromCursor(boolean teamCheck)
            -> Returns the closest player to your cursor. If the team check is enabled, it will skip over players on your team.

        utilites:moveMouseToObject(Part object)
            -> Moves your mouse to the object that is passed through.
        
        utilities:isVisible(Part object, table ignorelist)
            -> Returns true if the object is visible in your line of sight. The ignoreList parameter is used to ignore certain models, parts, etc.
]]

-- << set up services >> --
local services = setmetatable({}, {
    __index = function(self, value)
        local success, service = pcall(game.FindService, game, value)
        if success and service then
            self[value] = service;
            return service;
        end;
    end;
});

-- << service variables >> --
local players = services.Players;
local userInputService = services.UserInputService;

-- << player variables >> --
local localPlayer = players.LocalPlayer;

-- << workspace variables >> --
local currentCamera = workspace.CurrentCamera;

-- << micro optimizations >> --
local getPartsObscuringTarget = currentCamera.GetPartsObscuringTarget;
local worldToScreenPoint = currentCamera.WorldToScreenPoint;
local worldToViewportPoint = currentCamera.WorldToViewportPoint;
local findFirstChildOfClass = game.FindFirstChildOfClass;
local getPlayers = players.GetPlayers;
local getMouseLocation = userInputService.GetMouseLocation;
local isA = game.IsA;
local vector2 = Vector2.new;

local utilites = {} do
    function utilites:isAlive(character)
        if not character then return false; end;
        if not isA(character, "Model") then return false; end;
        if not findFirstChildOfClass(character, "Humanoid") then return false; end;
        
        local humanoid = findFirstChildOfClass(character, "Humanoid");
        return humanoid.Health > 0;
    end;

    function utilites:worldToScreenPoint(object)
        local point3D, onScreen = worldToScreenPoint(currentCamera, object.Position);
        local point2D = vector2(point3D.X, point3D.Y);

        return point2D, onScreen;
    end;
   
    function utilites:worldToViewportPoint(object)
        local point3D, onScreen = worldToViewportPoint(currentCamera, object.Position);
        local point2D = vector2(point3D.X, point3D.Y);

        return point2D, onScreen;
    end;
    
    function utilites:getClosestPlayerFromCursor(teamCheck)
        local closestPlayer = nil;
        local lastDistance = math.huge;
        local currentPlayers = getPlayers(players);
        
        for index, player in next, currentPlayers do
            if player == localPlayer then continue; end;
            if teamCheck and player.Team == localPlayer.Team then continue end;
            if not self:isAlive(player.Character) then continue end;

            local character = player.Character;
            local humanoidRootPart = character.HumanoidRootPart;
            local point2D, onScreen = self:worldToScreenPoint(humanoidRootPart)
            if not onScreen then continue; end;

            local mouseLocation = getMouseLocation(userInputService);
            local distanceFromMouse = (mouseLocation - point2D).Magnitude;

            if distanceFromMouse < lastDistance then
                closestPlayer = player;
                lastDistance = distanceFromMouse;
            end;
        end;

        return closestPlayer;
    end;
    
    function utilites:moveMouseToObject(object)
        -- // TODO: ADD A SMOOTHING OPTION
        local point2D, onScreen = self:worldToViewportPoint(object)
        if not onScreen then return end;

        local mouseLocation = getMouseLocation(userInputService);
        local relativePosition = (point2D - mouseLocation);
        mousemoverel(relativePosition.X, relativePosition.Y);
    end;
    
    function utilites:isVisible(object, ignoreList)
        -- // TODO: ADD A RAYCASTING VARIATION;
        return #getPartsObscuringTarget(currentCamera, {object.Position}, ignoreList or {}) == 0;
    end;
end;

return utilites, services;
