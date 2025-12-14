Config = {}
Config.Locations = {} -- DO NOT TOUCH.

---------------------------------------------------------------
--[[ General Settings ]]--
---------------------------------------------------------------

-- The wait time for checking nearby objects.
Config.WaitTime = 2000 -- Time in milliseconds.

---------------------------------------------------------------
--[[ Functions ]]--
---------------------------------------------------------------

function InsertData(data)
    table.insert(Config.Locations, data)
end

/*
Flag 1572897 - default flag
Flag 1572865 - this Flag open Doors so they can be use
*/