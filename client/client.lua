local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local started = false
local displayed = false
local progress = 0
local CurrentVehicle 
local pause = false
local selection = 0
local quality = 0
local LastCar
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
ESX = nil

function startUI(time, text) 
	SendNUIMessage({
		type = "ui",
		display = true,
		time = time,
		text = text
	})
end

AddEventHandler('meth:hasEnteredMarker', function(zone)
  if zone == 'make_lab' then
    CurrentAction     = 'start_makinglab'
    CurrentActionMsg  = (_U('assemble_lab'))
    CurrentActionData = {}
  end
  if zone == 'meth_process' then
    CurrentAction     = 'meth_processing'
    CurrentActionMsg  = (_U('meth_processing'))
    CurrentActionData = {}
  end
end)

AddEventHandler('meth:hasExitedMarker', function(zone)
  CurrentAction = nil
end)

Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)
    local playerPed = GetPlayerPed(-1)
    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
      if IsControlJustReleased(0, Keys['E']) then
        if CurrentAction == 'start_makinglab' then
			TriggerEvent('meth:hasExitedMarker')
			TriggerServerEvent('meth:check_inv')
        end
		if CurrentAction == 'meth_processing' then
			TriggerEvent('meth:hasExitedMarker')
			TriggerServerEvent('meth:meth_processing')
        end
      end
	end
end	
end)

RegisterNetEvent('meth:maakLab')
AddEventHandler('meth:maakLab', function ()
	local playerPed = PlayerPedId()
	TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
	startUI(25000, (_U"make_lab_bar"))
	Citizen.Wait(25000)
	ClearPedTasksImmediately(playerPed)
	TriggerServerEvent('meth:geefLab')
end)

RegisterNetEvent('meth:processmeth')
AddEventHandler('meth:processmeth', function ()
	local playerPed = PlayerPedId()
	TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
	startUI(4000, (_U"make_meth_bags"))
	Citizen.Wait(4000)
	ClearPedTasksImmediately(playerPed)
	TriggerServerEvent('meth:geefmeth')
end)

RegisterNetEvent('meth:methloop')
AddEventHandler('meth:methloop', function ()
	TriggerServerEvent('meth:meth_processing')
end)

Citizen.CreateThread(function ()
  while true do
    Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    for k,v in pairs(Config.Zones) do
      if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
      end
    end
  end
end)

Citizen.CreateThread(function ()
  while true do
    Wait(0)
    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil
    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
        isInMarker  = true
        currentZone = k
      end
    end
    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('meth:hasEnteredMarker', currentZone)
    end
    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('meth:hasExitedMarker', LastZone)
    end
  end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_methcar:stop')
AddEventHandler('esx_methcar:stop', function()
	started = false
	DisplayHelpText(_U("production_stop"))
	FreezeEntityPosition(LastCar, false)
end)

RegisterNetEvent('esx_methcar:stopfreeze')
AddEventHandler('esx_methcar:stopfreeze', function(id)
	FreezeEntityPosition(id, false)
end)

RegisterNetEvent('esx_methcar:notify')
AddEventHandler('esx_methcar:notify', function(message)
	ESX.ShowNotification(message)
end)

RegisterNetEvent('esx_methcar:startprod')
AddEventHandler('esx_methcar:startprod', function()
	DisplayHelpText(_U("start_production"))
	started = true
	FreezeEntityPosition(CurrentVehicle,true)
	displayed = false
	print(_U('started_print'))
	ESX.ShowNotification(_U("started_notifi"))	
	SetPedIntoVehicle(GetPlayerPed(-1), CurrentVehicle, 3)
	SetVehicleDoorOpen(CurrentVehicle, 2)
end)

RegisterNetEvent('esx_methcar:blowup')
AddEventHandler('esx_methcar:blowup', function(posx, posy, posz)
	AddExplosion(posx, posy, posz + 2,23, 20.0, true, false, 1.0, true)
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Citizen.Wait(1)
		end
	end
	SetPtfxAssetNextCall("core")
	local fire = StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", posx, posy, posz-0.8 , 0.0, 0.0, 0.0, 0.8, false, false, false, false)
	Citizen.Wait(6000)
	StopParticleFxLooped(fire, 0)
end)

RegisterNetEvent('esx_methcar:smoke')
AddEventHandler('esx_methcar:smoke', function(posx, posy, posz, bool)
	if bool == 'a' then
		if not HasNamedPtfxAssetLoaded("core") then
			RequestNamedPtfxAsset("core")
			while not HasNamedPtfxAssetLoaded("core") do
				Citizen.Wait(1)
			end
		end
		SetPtfxAssetNextCall("core")
		local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", posx, posy, posz + 1.7, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
		SetParticleFxLoopedAlpha(smoke, 0.8)
		SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
		Citizen.Wait(22000)
		StopParticleFxLooped(smoke, 0)
	else
		StopParticleFxLooped(smoke, 0)
	end
end)

RegisterNetEvent('esx_methcar:drugged')
AddEventHandler('esx_methcar:drugged', function()
	SetTimecycleModifier("drug_drive_blend01")
	SetPedMotionBlur(GetPlayerPed(-1), true)
	SetPedMovementClipset(GetPlayerPed(-1), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
	SetPedIsDrunk(GetPlayerPed(-1), true)
	Citizen.Wait(30000)
	ClearTimecycleModifier()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(GetPlayerPed(-1))
		if IsPedInAnyVehicle(playerPed) then
			CurrentVehicle = GetVehiclePedIsUsing(PlayerPedId())
			car = GetVehiclePedIsIn(playerPed, false)
			LastCar = GetVehiclePedIsUsing(playerPed)
			local model = GetEntityModel(CurrentVehicle)
			local modelName = GetDisplayNameFromVehicleModel(model)
			if modelName == 'JOURNEY' and car then
					if GetPedInVehicleSeat(car, -1) == playerPed then
						if started == false then
							if displayed == false then
								DisplayHelpText(_U("start_making"))
								displayed = true
							end
						end
						if IsControlJustReleased(0, Keys['G']) then
							if pos.y >= 3500 then
								if IsVehicleSeatFree(CurrentVehicle, 3) then
									TriggerServerEvent('esx_methcar:start')	
									progress = 0
									pause = false
									selection = 0
									quality = 0
								else
									DisplayHelpText(_U('car_occupied'))
								end
							else
								ESX.ShowNotification(_U('close_to_city'))
							end
						end
					end
				end
			else
				if started then
					started = false
					displayed = false
					TriggerEvent('esx_methcar:stop')
					print(_U('stopped_drugs'))
					FreezeEntityPosition(LastCar,false)
				end
			end
			if started == true then
				if progress < 96 then
					Citizen.Wait(6000)
					if not pause and IsPedInAnyVehicle(playerPed) then
						progress = progress +  1
						ESX.ShowNotification(_U('progress_making') .. progress .. '%')
						Citizen.Wait(6000) 
					end
					if progress > 22 and progress < 24 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('leak_question'))	
							ESX.ShowNotification(_U('fix_tape'))
							ESX.ShowNotification(_U('fix_ignore'))
							ESX.ShowNotification(_U('fix_replace'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('tape_kinda'))
							quality = quality - 3
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('big_boom'))
							TriggerServerEvent('esx_methcar:blow', pos.x, pos.y, pos.z)
							SetVehicleEngineHealth(CurrentVehicle, 0.0)
							quality = 0
							started = false
							displayed = false
							ApplyDamageToPed(GetPlayerPed(-1), 10, false)
							print(_U('stopped_drugs'))
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('replace_pipe'))
							pause = false
							quality = quality + 5
						end
					end
					if progress > 30 and progress < 32 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('acetone_ground'))	
							ESX.ShowNotification(_U('windows_open'))
							ESX.ShowNotification(_U('ignore_spill'))
							ESX.ShowNotification(_U('gasmask'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('windows_opened'))
							quality = quality - 2
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('acetone_high'))
							pause = false
							TriggerEvent('esx_methcar:drugged')
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('gasmask_on'))
							SetPedPropIndex(playerPed, 1, 26, 7, true)
							pause = false
						end
					end
					if progress > 38 and progress < 40 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('meth_solid'))	
							ESX.ShowNotification(_U('pressure_high'))
							ESX.ShowNotification(_U('more_temp'))
							ESX.ShowNotification(_U('lower_temp'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('pressure_raised'))
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('raised_temp'))
							quality = quality + 5
							pause = false
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('lower_worse'))
							pause = false
							quality = quality -4
						end
					end
					if progress > 41 and progress < 43 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('much_acetone'))	
							ESX.ShowNotification(_U('ignore_acetone'))
							ESX.ShowNotification(_U('sucking_out'))
							ESX.ShowNotification(_U('balance'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('smelling_acetone'))
							quality = quality - 3
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('too_much'))
							pause = false
							quality = quality - 1
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('balanced_chems'))
							pause = false
							quality = quality + 3
						end
					end
					if progress > 46 and progress < 49 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('coloring'))	
							ESX.ShowNotification(_U('add_coloring'))
							ESX.ShowNotification(_U('put_away'))
							ESX.ShowNotification(_U('drink_it'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('good_idea'))
							quality = quality + 3
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('taste_meth'))
							quality = quality + 1
							pause = false
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('dizzy'))
							pause = false
						end
					end
					if progress > 55 and progress < 58 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('clogged_filter'))	
							ESX.ShowNotification(_U('comressed_air'))
							ESX.ShowNotification(_U('filter_replace'))
							ESX.ShowNotification(_U('tooth_brush'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('spilled_meth'))
							quality = quality - 6
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('replacing_filter'))
							pause = false
							quality = quality + 3
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('still_dirty'))
							pause = false
							quality = quality - 2
						end
					end
					if progress > 58 and progress < 60 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('acetone_ground'))
							ESX.ShowNotification(_U('windows_open'))
							ESX.ShowNotification(_U('ignore_spill'))
							ESX.ShowNotification(_U('gasmask'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('windows_opened'))
							quality = quality - 1
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('acetone_high'))
							pause = false
							TriggerEvent('esx_methcar:drugged')
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('gasmask_on'))
							SetPedPropIndex(playerPed, 1, 26, 7, true)
							pause = false
						end
					end
					if progress > 63 and progress < 65 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('meth_solid'))
							ESX.ShowNotification(_U('fix_tape'))
							ESX.ShowNotification(_U('fix_ignore'))
							ESX.ShowNotification(_U('fix_replace'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('tape_kinda'))
							quality = quality - 3
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('big_boom'))
							TriggerServerEvent('esx_methcar:blow', pos.x, pos.y, pos.z)
							SetVehicleEngineHealth(CurrentVehicle, 0.0)
							quality = 0
							started = false
							displayed = false
							ApplyDamageToPed(GetPlayerPed(-1), 10, false)
							print(_U('stopped_drugs'))
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('replace_pipe'))
							pause = false
							quality = quality + 5
						end
					end
					if progress > 71 and progress < 73 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('clogged_filter'))	
							ESX.ShowNotification(_U('comressed_air'))
							ESX.ShowNotification(_U('filter_replace'))
							ESX.ShowNotification(_U('tooth_brush'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('spilled_meth'))
							quality = quality - 2
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('replacing_filter'))
							pause = false
							quality = quality + 3
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('still_dirty'))
							pause = false
							quality = quality - 1
						end
					end
					if progress > 76 and progress < 78 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('much_acetone'))	
							ESX.ShowNotification(_U('ignore_acetone'))
							ESX.ShowNotification(_U('sucking_out'))
							ESX.ShowNotification(_U('balance'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('smelling_acetone'))
							quality = quality - 3
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('too_much'))
							pause = false
							quality = quality - 1
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('balanced_chems'))
							pause = false
							quality = quality + 3
						end
					end
					if progress > 82 and progress < 84 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('take_a_shit'))	
							ESX.ShowNotification(_U('hold_it'))
							ESX.ShowNotification(_U('take_shit'))
							ESX.ShowNotification(_U('shit_inside'))
							ESX.ShowNotification(_U('press_number'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('shit_later'))
							quality = quality + 1
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('glass_fell'))
							pause = false
							quality = quality - 2
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('shit_meth'))
							pause = false
							quality = quality - 5
						end
					end
					if progress > 88 and progress < 90 then
						pause = true
						if selection == 0 then
							ESX.ShowNotification(_U('glassin_meth'))	
							ESX.ShowNotification(_U('yes'))
							ESX.ShowNotification(_U('no'))
							ESX.ShowNotification(_U('meth_toglass'))
							ESX.ShowNotification(_U('press_number'))
						end
						if selection == 1 then
							print(_U("sel_1"))
							ESX.ShowNotification(_U('more_crystals'))
							quality = quality + 1
							pause = false
						end
						if selection == 2 then
							print(_U("sel_2"))
							ESX.ShowNotification(_U('high_quality'))
							pause = false
							quality = quality + 1
						end
						if selection == 3 then
							print(_U("sel_3"))
							ESX.ShowNotification(_U('too_much'))
							pause = false
							quality = quality - 1
						end
					end
				if IsPedInAnyVehicle(playerPed) then
					TriggerServerEvent('esx_methcar:make', pos.x,pos.y,pos.z)
					if pause == false then
						selection = 0
						quality = quality + 1
						progress = progress +  math.random(1, 2)
						ESX.ShowNotification(_U('progress_making') .. progress .. '%')
					end
				else
					TriggerEvent('esx_methcar:stop')
				end
			else
				TriggerEvent('esx_methcar:stop')
				progress = 100
				ESX.ShowNotification(_U('progress_making') .. progress .. '%')
				ESX.ShowNotification(_U('finished'))
				TriggerServerEvent('esx_methcar:finish', quality)
				FreezeEntityPosition(LastCar, false)
			end	
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if IsPedInAnyVehicle(GetPlayerPed(-1)) then
		else
			if started then
				started = false
				displayed = false
				TriggerEvent('esx_methcar:stop')
				print(_U('stopped_drugs'))
				FreezeEntityPosition(LastCar,false)
			end		
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)		
		if pause == true then
			if IsControlJustReleased(0, Keys['1']) then
				selection = 1
				ESX.ShowNotification(_U('selected_1'))
			end
			if IsControlJustReleased(0, Keys['2']) then
				selection = 2
				ESX.ShowNotification(_U('selected_2'))
			end
			if IsControlJustReleased(0, Keys['3']) then
				selection = 3
				ESX.ShowNotification(_U('selected_3'))
			end
		end

	end
end)