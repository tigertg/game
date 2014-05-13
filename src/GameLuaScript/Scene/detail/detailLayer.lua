local PATH = IMG_PATH .. "image/scene/detail/"
local SCENECOMMON = IMG_PATH .. "image/scene/common/"
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local infoLayer = requires(IMG_PATH , "GameLuaScript/Scene/common/infolayer")


local detailLayer = {
	layer,
	info_layer,
	detailLayer,
}

function detailLayer:new(detail_name , params)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()

	-- 背景
	local bg = display.newSprite(COMMONPATH .. "dark_bg.png")
	setAnchPos(bg , 0 , 88)						-- 70 是底部公用导航栏的高度
	this.layer:addChild(bg)

	this.info_layer = infoLayer:new("detail" , 0 , {
		tail_hide = true,
		title_text = PATH .. "title.png",
		closeCallback = function()
			popScene()

			if params.backCallback then
				params.backCallback()
			end
		end
	})

	--将当前层传入，在popScene时可以进行更新	
	params["main"] = {this, detail_name, params}
	this:createLayer(detail_name, params)
	
	this.layer:addChild(this.info_layer:getLayer())
	return this
end

function detailLayer:createLayer(detail_name, params)
	if self.detailLayer then
		self.layer:removeChild(self.detailLayer:getLayer(), true)
	end
	
	-- 添加对应的 详情层
	local DetailName = nil
	if detail_name == "pet" then
		DetailName = requires(IMG_PATH , "GameLuaScript/Scene/detail/petdetail")
	elseif detail_name == "general" or detail_name == "hero" then
		DetailName = requires(IMG_PATH , "GameLuaScript/Scene/detail/herodetail")
	elseif detail_name == "prop" then
		DetailName = requires(IMG_PATH , "GameLuaScript/Scene/detail/propdetail")
	elseif detail_name == "skill" then
		DetailName = requires(IMG_PATH , "GameLuaScript/Scene/detail/skilldetail")
	elseif detail_name == "petskill" then
		DetailName = requires(IMG_PATH , "GameLuaScript/Scene/detail/petskilldetail")
	elseif detail_name == "equip" then
		DetailName = requires(IMG_PATH , "GameLuaScript/Scene/detail/equipdetail")
	end

	
	self.detailLayer = DetailName:new(params)
	self.layer:addChild(self.detailLayer:getLayer())
end

function detailLayer:getLayer()
	return self.layer
end


return detailLayer
