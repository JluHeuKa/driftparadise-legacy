function isPlayerLoggedIn(...)
	return Users.isPlayerLoggedIn(...)
end

function userExists(username)
	local users = Users.getByUsername(username, {"username"})
	return type(users) == "table" and #users > 0
end

function getUserAccount(username)
	local users = Users.getByUsername(username, {})
	if type(users) ~= "table" or #users == 0 then
		return false
	end
	return users[1]
end

function updateUserAccount(username, fields)
	return Users.update(username, fields)
end

function getUserPlayer(username)
	return Users.getPlayerByUsername(username)
end

function givePlayerMoney(player, money)
	if not isElement(player) then
		return false
	end
	if type(money) ~= "number" then
		return false
	end
	money = math.floor(money)
	local currentMoney = player:getData("money")
	if type(currentMoney) ~= "number" then
		return false
	end
	player:setData("money", math.max(0, currentMoney + money))
	return true
end