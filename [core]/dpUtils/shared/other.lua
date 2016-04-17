function defaultValue(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

-- http://stackoverflow.com/a/2421746
function capitalizeString(str)
    return (str:gsub("^%l", string.upper))
end

function clearChat(...)
	for i = 1, 30 do
		outputChatBox(" ", ...)
	end
end