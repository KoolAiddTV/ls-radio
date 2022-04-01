ESX.RegisterUsableItem('radio', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('ls-radio:use', source)
end)
