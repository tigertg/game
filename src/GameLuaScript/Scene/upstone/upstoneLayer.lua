local upstoneLayer = {layer}

function upstoneLayer:new(x,y)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()

	local bg = display.newSprite(IMG_PATH.."image/common/common_bg.jpg")
	setAnchPos(bg,x,y)
	this.layer:addChild(bg)

	local line = display.newSprite(IMG_PATN .. "image/common/separator.png")
	setAnchPos(line,7,770)
	this.layer:addChild(line)

	local line1 = display.newSprite(IMG_PATN .. "image/common/separator.png")
	setAnchPos(line1,7,600)
	this.layer:addChild(line1)

	local stonebg = display.newSprite(IMG_PATH.."image/scene/Culture/5.png")
	setAnchPos(stonebg,180,670)
	this.layer:addChild(stonebg)

	local stone = display.newSprite(IMG_PATH.."image/scene/mosaic/16.png")
	setAnchPos(stone,203,688)
	this.layer:addChild(stone)

	local label_name = CCLabelTTF:create("名字",FONT,20)
	setAnchPos(label_name ,210,648)
	this.layer:addChild(label_name )

	local cur = display.newSprite(IMG_PATH.."image/scene/mosaic/2.png")
	setAnchPos(cur,30,620)
	this.layer:addChild(cur)

	local label_cur = CCLabelTTF:create("当前",FONT,20)
	setAnchPos(label_cur ,110,630)
	this.layer:addChild(label_cur )

	local next_cur = display.newSprite(IMG_PATH.."image/scene/mosaic/3.png")
	setAnchPos(next_cur,280,620)
	this.layer:addChild(next_cur)

	local label_cur = CCLabelTTF:create("下一个",FONT,20)
	setAnchPos(label_cur ,370,630)
	this.layer:addChild(label_cur )

	local KNBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")--require("GameLuaScript/Common/KNBar")
	this.layer:addChild(KNBar:new("updata" , 70 , 260 , {maxValue=100 , curValue=20}))

	local upbg = display.newSprite(IMG_PATH.."image/scene/mosaic/6.png")
	setAnchPos(upbg,0,180)
	this.layer:addChild(upbg)


	--摘取
	local btn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require"GameLuaScript/Common/KNBtn"
	local ok_bt = btn:new(IMG_PATH.."image/buttonUI/updata/pick",{"def.png","pre.png"},40,100,
	  		{
				--parent = sv,
	  			highLight = true,
	  			--scale = true,
	   		callback=
	   			function()

	   			 end
	   	 })
	this.layer:addChild(ok_bt:getLayer())

	local btn =  requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require"GameLuaScript/Common/KNBtn"
	local up_bt = btn:new(IMG_PATH.."image/buttonUI/updata/upgrade",{"def.png","pre.png"},300,100,
	  		{
				--parent = sv,
	  			highLight = true,
	  			--scale = true,
	   		callback=
	   			function()

	   			 end
	   	 })
	this.layer:addChild(up_bt:getLayer())

	local stoneInfo = requires(IMG_PATH,"GameLuaScript/Scene/upstone/stoneInfo")--require"GameLuaScript/Scene/upstone/stoneInfo"

	local temp = stoneInfo:new(1,7,210,{callback = function(stone) print("1") end})
	this.layer:addChild(temp:getLayer())

	local temp = stoneInfo:new(1,7+temp:get_width()/2,210,{ callback = function(stone) print("2") end})
	this.layer:addChild(temp:getLayer())

	local temp = stoneInfo:new(1,temp:get_width(),210,{ callback = function(stone) print("3") end})
	this.layer:addChild(temp:getLayer())

	local temp = stoneInfo:new(1,temp:get_width()+temp:get_width()/2,210,{ callback = function(stone) print("4") end})
	this.layer:addChild(temp:getLayer())

	local temp = stoneInfo:new(1,temp:get_width()+temp:get_width(),210,{ callback = function(stone) print("5") end})
	this.layer:addChild(temp:getLayer())

	local temp = stoneInfo:new(1,7,210-temp:get_height()/2,{ callback = function(stone) print("6") end})
	this.layer:addChild(temp:getLayer())

	return this
end

function upstoneLayer:getLayer()
	return self.layer
end

return upstoneLayer
