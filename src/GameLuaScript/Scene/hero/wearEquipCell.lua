--[[

		武将装备单元格

]]--
local PATH = IMG_PATH .. "image/scene/hero/"
local SCENECOMMON = IMG_PATH .. "image/scene/common/"
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")

local M = { seatBtn }
function M:new(bx , by , data , touchFunc , parent , opened )
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	--如果存在则销毁
--	if this.seatBtn then
--		this.seatBtn:removeFromParentAndCleanup( true )
--	end
	local str = nil
	local iconPath = nil
	if isset(data , "cid") then
		iconPath = getImageByType(data.cid , "s")
	else
		str = { data , 16 }
	end

	local btn_image = "skill_frame1.png"
	if opened ~= true then btn_image = "skill_frame3.png" end
	this.seatBtn = KNBtn:new( SCENECOMMON , { btn_image }, bx , by , { front = iconPath , text = str , scale = true , callback = touchFunc } )

	-- 等级
	if isset(data , "lv") then
		local lv_bg_png = "skill_lv_bg.png"
		local lv_bg_x = 50
		if isset(data , "cid") then
			local cid_type = getCidType(data["cid"])
			if cid_type == "equip" then
				lv_bg_png = "equip_lv_bg.png"
				lv_bg_x = 45
			end
		end

		local lv_bg = display.newSprite(COMMONPATH .. lv_bg_png)
		setAnchPos(lv_bg , lv_bg_x , 50)
		this.seatBtn:getLayer():addChild(lv_bg , 10)

		local lv = CCLabelTTF:create(data["lv"] , FONT , 16)
		lv:setColor( ccc3( 0xff , 0xff , 0xff ) )
		setAnchPos(lv , 61 , 51 , 0.5)
		this.seatBtn:getLayer():addChild(lv , 11)
	end
	
	return this.seatBtn
end

return M