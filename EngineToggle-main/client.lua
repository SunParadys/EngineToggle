-----------------------------------------------------------------------------------
------------------------------------Motor toggle - Heli/F1 First Person------------
-----------------------------------------------------------------------------------

local keyToggle = 20 -- "Z", Motor an/aus zum ändern: https://docs.fivem.net/docs/game-references/controls/#controls
Config.helis = true -- Heli First Person
Config.f1 = true -- Formel 1 First Person
CreateThread(function()
    while true do
        Wait(2)
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		local engineStatus		
		local heli = IsPedInAnyHeli(ped)
		local vehiclehash = GetEntityModel(GetVehiclePedIsIn(ped, false))
		local driver = GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
		
		if IsPedGettingIntoAVehicle(ped) then
			engineStatus = (GetIsVehicleEngineRunning(vehicle)) -- wahr oder falsch
			if not (engineStatus) then 
				SetVehicleEngineOn(vehicle, false, true, true) -- stellt sicher, dass der Motor ausgeschaltet ist
				DisableControlAction(2, 71, true) -- 71 Taste "W" sorgt dafür, dass der Spieler das Auto beim Einsteigen nicht automatisch startet
			end
		end
		
		if IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) and (not GetIsVehicleEngineRunning(vehicle)) then
			DisableControlAction(2, 71, true) -- allgemeines Deaktivieren des automatischen Startens des Fahrzeugs, wenn der Spieler bereits im Fahrzeug sitzt
		end
		
		if (IsControlJustReleased(0, keyToggle) or IsDisabledControlJustReleased(0, keyToggle)) and vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
			toggleEngine()
			if not (engineStatus) then
				engineStatus = true -- kehrt engineStatus um, da er falsch war
				DisableControlAction(2, 71, false)
			else
				engineStatus = false -- kehrt engineStatus um, da es wahr war
				DisableControlAction(2, 71, true)
			end
        end
		
		if Config.helis then -- Heli First Person
			if driver then
				if heli then
					SetCamViewModeForContext(6, 4)
					SetFollowVehicleCamViewMode(4)
				end
			end
		end
		
		if Config.f1 then -- Formel 1 First Person
			if IsVehicleModel(GetVehiclePedIsIn(PlayerPedId(), false), GetHashKey("openwheel1")) then -- https://wiki.rage.mp/wiki/Vehicles
				SetVehicleLights(GetVehiclePedIsIn(PlayerPedId(), false), GetHashKey("openwheel1"), 0)
				local viewMode = GetFollowVehicleCamViewMode()
				if viewMode == 0 or viewMode == 1 or viewMode == 2 or viewMode == 3 then
					SetFollowVehicleCamViewMode(4)
				end
			end
		end
		
		if IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) then -- 75 Taste "F"
			if (GetIsVehicleEngineRunning(vehicle)) then
				Wait(150) -- Fahrer Zeit, wichtig zur Ausführung der folgender Befehle
				SetVehicleEngineOn(vehicle, true, true, false) -- startet den Automotor neu
				TaskLeaveVehicle(ped, vehicle, 0) --TaskLeaveVehicle(ped, vehicle, 64)
			else
				TaskLeaveVehicle(ped, vehicle, 0) --TaskLeaveVehicle(ped, vehicle, 64)
			end
		end
    end
end)

function toggleEngine()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
        SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
    end
end

-- TaskLeaveVehicle Flags:  
-- 0 = normales Aussteigen und schließt die Tür 
-- 1 = normales Aussteigen und schließt die Tür 
-- 16 = teleportiert dich nach draußen, Tür bleibt geschlossen
-- 64 = normales Aussteigen und schließt die Tür, vielleicht etwas langsamere Animation als 0
-- 256 = normales Aussteigen, schließt aber nicht die Tür
-- 4160 = Fahrer wirft sich heraus, auch wenn das Fahrzeug stillsteht
-- 262144 = Fahrer geht zuerst auf den Beifahrersitz, steigt dann normal aus

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------