
--[[ ------------------------------------------------
   Functions
]]---------------------------------------------------

-- @GetTableLength returns the length of a table.
local GetTableLength = function(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end

local LoadModel = function(inputModel)
   local model = GetHashKey(inputModel)

   RequestModel(model)

   while not HasModelLoaded(model) do RequestModel(model)
       Citizen.Wait(10)
   end
end

local RemoveEntityProperly = function(entity, objectHash)
	DeleteEntity(entity)
	DeletePed(entity)

	SetEntityAsNoLongerNeeded( entity )

	if objectHash then
		SetModelAsNoLongerNeeded(objectHash)
	end
   
end

--[[ ------------------------------------------------
   Base Events
]]---------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
   if (GetCurrentResourceName() ~= resourceName) then
       return
   end

   if GetTableLength(Config.Locations) > 0 then

      for _, location in pairs (Config.Locations) do

         if location.EntityHandler then
            RemoveEntityProperly(location.EntityHandler, GetHashKey(location.Object) )
            location.EntityHandler = nil
         end
  
      end
      
   end

end)

--[[ ------------------------------------------------
   Threads
]]---------------------------------------------------

Citizen.CreateThread(function()

   while true do
   
      Wait(Config.WaitTime)

      local player = PlayerPedId()
			
      if GetTableLength(Config.Locations) > 0 then

         local coords     = GetEntityCoords(player)
         local coordsDist = vector3(coords.x, coords.y, coords.z)

         for _, location in pairs(Config.Locations) do

            local locCoords   = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
            local distance    = #(coordsDist - locCoords)

            if not location.RemoveExistingObject then
               if distance > location.ObjectRenderDistance and location.EntityHandler then

                  RemoveEntityProperly(location.EntityHandler, GetHashKey(location.Object) )
                  location.EntityHandler = nil
               end
   
               if distance <= location.ObjectRenderDistance and location.EntityHandler == nil then
   

                  LoadModel( location.Object )

                  local doorState = location.IsDoor and true or false
   
                  local toVec  = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
                  local object = CreateObjectNoOffset(GetHashKey(location.Object), toVec, false, false, doorState, false, false)
   
                  SetEntityVisible(object, true)
                  SetEntityRotation(object, location.Coords.pitch, location.Coords.roll, location.Coords.yaw, 2)
                  SetEntityCoords(object, location.Coords.x, location.Coords.y, location.Coords.z)
   
                  if location.PlaceObjectOnGroundProperly then
                    PlaceObjectOnGroundProperly(object, true)
                  end

                  SetEntityCollision(object, true)
   
                  SetEntityFadeIn(object, true)

                  FreezeEntityPosition(object, true)

                  if location.IsDoor then 
                     FreezeEntityPosition(object, false)
                     AddDoorToSystemNew(3077286490)
                  end


                  location.EntityHandler = object
   
               end

            else

               if distance <= location.ObjectRenderDistance and location.EntityHandler == nil then

                  local coords = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
   
                  local objects = GetGamePool("CObject")
                  for _, obj in pairs(objects) do
            
                     local entityCoords = GetEntityCoords(obj)
                     local model = GetEntityModel(obj)
   
                     if #(entityCoords - coords) <= 1.0 then
   
                        if model == GetHashKey(location.Object) then
                           DeleteObject(obj)
                        end
                        
                     end
   
                  end
   
                  location.EntityHandler = handle
               end
   
               if distance > location.ObjectRenderDistance and location.EntityHandler then
   
                  location.EntityHandler = nil
               end

            end

         end

      end

   end

end)
