local cameraViews = {
	false, -- Обычная камера
	DriftView,
	CockpitView
}
local currentCameraViewIndex = 1
local currentCameraView

local function startCameraView(cameraView)
	if currentCameraView then
		currentCameraView.stop()
	end
	if cameraView and localPlayer.vehicle.controller == localPlayer then
		cameraView.start()
		currentCameraView = cameraView
	else
		setCameraTarget(localPlayer)
		setCameraMatrix(0, 0, 0)
		setCameraTarget(localPlayer)
		currentCameraView = nil

		if localPlayer.vehicle then
			setCameraViewMode(2)
		end		
	end
	return true
end

toggleControl("change_camera", false)
bindKey("change_camera","down", function ()
	if localPlayer:getData("activeUI") then
		return
	end
	if not localPlayer.vehicle then
		startCameraView()
		return
	end
	currentCameraViewIndex = currentCameraViewIndex + 1
	if currentCameraViewIndex > #cameraViews then
		currentCameraViewIndex = 1
	end
	startCameraView(cameraViews[currentCameraViewIndex])
end)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function ()
	startCameraView(cameraViews[currentCameraViewIndex])
end)

addEventHandler("onClientVehicleEnter", root, function (player)
	if player ~= localPlayer then
		return
	end
	startCameraView(cameraViews[currentCameraViewIndex])
end)

addEventHandler("onClientVehicleStartExit", root, function (player)
	if player ~= localPlayer then
		return
	end
	startCameraView()
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
	if localPlayer.vehicle then
		startCameraView(cameraViews[currentCameraViewIndex])
	end
	toggleControl("change_camera", false)
end)

addEventHandler("onClientResourceStop", resourceRoot, function ()
	if currentCameraView then
		currentCameraView.stop()
	end
end)