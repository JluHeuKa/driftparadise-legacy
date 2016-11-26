local DONATIONS_KEY = "CHANGE_ME_PLEASE"
local SHOP_ID = 26365
local SHOP_KEY = "01423B68AA245C73D8"
local shopPrices = {}

local function checkDonationsKey(key)
	if type(key) ~= "string" then
		return "No key provided"
	end
	-- Проверка секретного ключа
	if key ~= DONATIONS_KEY then
		return "Invalid key"
	end
	return nil
end

function isDonationsAPIAvailable()
	return not not next(shopPrices)
end

WebAPI.registerMethod("donations.buyMoney", function (key, username, amount)
	local err = checkDonationsKey(key)
	if err then return err end
	if type(username) ~= "string" then
		return "Invalid username"
	end
	local amount = tonumber(amount)
	if type(amount) ~= "number" then
		return "Bad amount"
	end
	amount = math.floor(amount)

	if not shopPrices or not shopPrices[1] then
		return "Failed to connect to shop"
	end
	local money = shopPrices[1].money
	for i, item in ipairs(shopPrices) do
		if amount >= item.price then
			money = item.money
		end
	end

	-- Проверка пользователя
	if not exports.dpCore:userExists(username) then
		return "User '" .. tostring(username) .. "' not found"
	end
	-- Зачисление денег
	local player = exports.dpCore:getUserPlayer(username)
	-- Если игрок на сервере
	if isElement(player) then
		WebAPI.log("Player is online. Giving money to player")
		if not exports.dpCore:givePlayerMoney(player, money) then
			return "Failed to give player money"
		end
		triggerClientEvent(player, "dpWebAPI.donationSuccess", player, money)
	else
		local userAccount = exports.dpCore:getUserAccount(username)
		if type(userAccount) ~= "table" then
			return "User account not found"
		end
		WebAPI.log("Player is offline. Giving money to account")
		local userMoney = userAccount.money
		if type(userMoney) ~= "number" then
			WebAPI.log("User account has no money field")
			return "Bad user account"
		end
		local result = exports.dpCore:updateUserAccount(username, {
			["money"] = userMoney + money
		})
		if not result then
			WebAPI.log("Unexpected error")
			return "Failed to give user money"
		end
	end
	outputDebugString("Donation for user " .. tostring(username) .. ": $" .. tostring(money) .. " " .. tostring(amount) .. " RUB")
	return true
end)

addEventHandler("onResourceStart", resourceRoot, function ()
	outputDebugString("Connecting to TradeMC...")
	fetchRemote("http://api.trademc.org/shop.getItems?params[shop]=" .. tostring(SHOP_ID), function (data, err)
		if err == 0 then
			data = fromJSON(data)
			if not data then
				outputDebugString("Error connecting to TradeMC shop (failed to read JSON)")
				return
			end
			shopPrices = {}
			for i, item in ipairs(data.response.items) do
				local money = tonumber(string.sub(item.name, 2))
				local price = tonumber(item.cost)
				if money and price then
					table.insert(shopPrices, {price = price, money = money})	
				end
			end
			table.sort(shopPrices, function (a, b)
				return a.price < b.price
			end)
			outputDebugString("Loaded prices. Items count: " .. tostring(#shopPrices))
		else
			outputDebugString("Error connecting to TradeMC shop (" .. tostring(err) .. ")")
		end
	end)
end)

function processCallback(url, requestHeaders, cookies, hostname)
	outputDebugString("Incoming donation from " .. tostring(hostname))
	local query = urlParser.parse(url).query
	if not query.nickname then
		return "Bad query"
	end
	local args = { 
		tostring(query.amount), 
		tostring(query.nickname), 
		tostring(query.shop), 
		tostring(query.time), 
		tostring(SHOP_KEY)
	}
	local hash = md5(table.concat(args, ":"))

	if hash == query.hash then
		return "Invalid query"
	end

	outputDebugString("Payment: " .. tostring(query.nickname) .. " " .. tostring(query.amount))
	return WebAPI.callMethod("donations.buyMoney", "CHANGE_ME_PLEASE", query.nickname, query.amount)
end