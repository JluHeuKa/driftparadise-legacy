Assets = {}

function Assets.start()
	Assets.textures = {
		logo = exports.dpAssets:createTexture("logo_square_simple.png"),
		arrow = exports.dpAssets:createTexture("arrow.png"),
		circle = DxTexture("assets/images/circle_button.png"),
		slider = DxTexture("assets/images/slider.png"),
		sliderCircle = DxTexture("assets/images/slider_circle.png")
	}

	Assets.fonts = {
		menu = exports.dpAssets:createFont("Roboto-Regular.ttf", 22),
		componentName = exports.dpAssets:createFont("Roboto-Regular.ttf", 30)
	}
end

function Assets.stop()
	for name, texture in pairs(Assets.textures) do
		if isElement(texture) then
			destroyElement(texture)
		end
	end

	for name, font in pairs(Assets.fonts) do
		if isElement(font) then
			destroyElement(font)
		end
	end	
end