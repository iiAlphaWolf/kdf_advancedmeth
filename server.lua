print('Started KDF AdvancedMeth By: KleurenDoof')
local playersProcessingMeth = {}
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('meth:check_inv')
AddEventHandler('meth:check_inv', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('methlab').count >= 1 then
		xPlayer.showNotification(('U hebt al een methlab bij, u kan er niet nog een dragen!'))
	else
		if xPlayer.getInventoryItem('slang').count >= 2 and xPlayer.getInventoryItem('glas_fles').count >= 1 and xPlayer.getInventoryItem('campingstove').count >= 1 and xPlayer.getInventoryItem('tube').count >= 2 and xPlayer.getInventoryItem('propanebottle').count >= 1 then
			xPlayer.removeInventoryItem('slang', 2)
			xPlayer.removeInventoryItem('glas_fles', 1)
			xPlayer.removeInventoryItem('campingstove', 1)
			xPlayer.removeInventoryItem('tube', 2)
			xPlayer.removeInventoryItem('propanebottle', 1)
			TriggerClientEvent('meth:maakLab', source)
		else
			xPlayer.showNotification(('U hebt niet genoeg spullen om een lab in elkaar te zetten!'))
		end
	end
end)

RegisterServerEvent('meth:geefLab')
AddEventHandler('meth:geefLab', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addInventoryItem('methlab', 1)
end)

RegisterServerEvent('meth:geefmeth')
AddEventHandler('meth:geefmeth', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.addInventoryItem('packed_meth', 1)
	TriggerClientEvent('meth:methloop', source)
end)

RegisterServerEvent('meth:meth_processing')
AddEventHandler('meth:meth_processing', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('meth').count >= 1 and xPlayer.getInventoryItem('zakje').count >= 1 then
		xPlayer.removeInventoryItem('meth', 1)
		xPlayer.removeInventoryItem('zakje', 1)
		TriggerClientEvent('meth:processmeth', source)
	else
		xPlayer.showNotification(('U hebt niet genoeg zakjes of meth!'))
	end
end)

RegisterServerEvent('esx_methcar:start')
AddEventHandler('esx_methcar:start', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('acetone').count >= 5 and xPlayer.getInventoryItem('lithium').count >= 2 and xPlayer.getInventoryItem('methlab').count >= 1 then
		if xPlayer.getInventoryItem('meth').count >= 30 then
			TriggerClientEvent('esx_methcar:notify', _source, "~r~~h~You cant hold more meth")
		else
			TriggerClientEvent('esx_methcar:startprod', _source)
			xPlayer.removeInventoryItem('acetone', 5)
			xPlayer.removeInventoryItem('lithium', 2)
		end
	else
		TriggerClientEvent('esx_methcar:notify', _source, "~r~~h~Not enough supplies to start producing Meth")
	end
end)

RegisterServerEvent('esx_methcar:stopf')
AddEventHandler('esx_methcar:stopf', function(id)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	local xPlayer = ESX.GetPlayerFromId(_source)
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('esx_methcar:stopfreeze', xPlayers[i], id)
	end
	
end)

RegisterServerEvent('esx_methcar:make')
AddEventHandler('esx_methcar:make', function(posx,posy,posz)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('methlab').count >= 1 then
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			TriggerClientEvent('esx_methcar:smoke',xPlayers[i],posx,posy,posz, 'a') 
		end
	else
		TriggerClientEvent('esx_methcar:stop', _source)
	end
end)

RegisterServerEvent('esx_methcar:finish')
AddEventHandler('esx_methcar:finish', function(qualtiy)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	print(qualtiy)
	local rnd = math.random(-5, 5)
	TriggerEvent('KLevels:addXP', _source, 20)
	xPlayer.addInventoryItem('meth', math.floor(qualtiy / 2) + rnd)
end)

RegisterServerEvent('esx_methcar:blow')
AddEventHandler('esx_methcar:blow', function(posx, posy, posz)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	local xPlayer = ESX.GetPlayerFromId(_source)
	for i=1, #xPlayers, 1 do
		TriggerClientEvent('esx_methcar:blowup', xPlayers[i],posx, posy, posz)
	end
	xPlayer.removeInventoryItem('methlab', 1)
end)

