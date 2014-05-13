local Mosaiclayer = {layer,array}
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local chipLayer = requires(IMG_PATH,"GameLuaScript/Scene/mosaic/moduleChip")
--[[筋脉]]
function Mosaiclayer:new(x,y,parm)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.layer = display.newLayer()
	local gid = parm.gid
	local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,60)
	this.layer:addChild(bg)
	this.array = {}
	local cu_bg = display.newSprite(IMG_PATH.."image/common/dark_bg.png")
	setAnchPos(cu_bg,0,86)
	this.layer:addChild(cu_bg)
	
	local context_bg = display.newSprite(IMG_PATH.."image/scene/mosaic/ston_bg.png")
	setAnchPos(context_bg,17,110)
	this.layer:addChild(context_bg)
	
	--[[local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,y)
	this.layer:addChild(bg)
	
	local context_bg = display.newSprite(IMG_PATH.."image/common/list_bg.png")
	setAnchPos(context_bg,15,87)
	this.layer:addChild(context_bg)
	
	local title = display.newSprite(IMG_PATH.."image/common/list_title.png")
	setAnchPos(title,15+(context_bg:getContentSize().width - title:getContentSize().width)/2,80+context_bg:getContentSize().height)
	this.layer:addChild(title)
	
	
	
	local close = KNBtn:new(IMG_PATH .. "image/common" , {"close.png"} , 15+(context_bg:getContentSize().width )-50,70+context_bg:getContentSize().height , {
		upSelect = true,
		noHide = true,
		callback = function()
			switchScene("pulse",gid)
		end
	})
	this.layer:addChild(close:getLayer())
	]]
	--[[if parm.mode == 1 then
		--镶嵌
		local title_font = display.newSprite(IMG_PATH.."image/common/title/stone_text.png")
		setAnchPos(title_font,15+(context_bg:getContentSize().width - title_font:getContentSize().width)/2,85+context_bg:getContentSize().height)
		this.layer:addChild(title_font)
		
		local mosai_data = DATA_Bag:getTable("prop")--DATA_Bag:get("prop",index , key)--BagLayer:getDataFile("prop")
		local y_select = 104
		local sv = KNScrollView:new(28,104,420,630,10,false)	
		for k,v in pairs(mosai_data) do
			if v["type"] == "stone" then
				local info = infoLayer:new(v,0,70,{gid = parm.gid,index = parm.index},{ callback = function(thiscard) end})
				sv:addChild(info:getLayer(),info)
			end
		end
		this.layer:addChild(sv:getLayer())
	elseif parm.mode == 2 then]]
		--升级
		--[[local title_font = display.newSprite(IMG_PATH.."image/common/title/Sehnen.png")
		setAnchPos(title_font,15+(context_bg:getContentSize().width - title_font:getContentSize().width)/2,85+context_bg:getContentSize().height)
		this.layer:addChild(title_font)]]
		local info = chipLayer:new(0,70,{gid = parm.gid,index = parm.index,mode = parm.mode},this)
		this.layer:addChild(info:getLayer())
		
		---升级
		local updata_btn = KNBtn:new(IMG_PATH .. "image/common" , {"btn_bg_red.png","btn_bg_red_pre.png"} , 275,120 , {
			front = IMG_PATH.."image/scene/mosaic/font_updata1.png",
			scale = true,
			noHide = true,
			callback = function()
				local send_array = this.array
				--dump(send_array)
				local num = 0
				local stone_str = nil
				if send_array ~= nil then
					for k,v in pairs(send_array) do
						if k == 1 and v["num"] > 0 then
							stone_str = v["id"]..":"..v["num"]
						elseif v["num"] > 0 then
							stone_str = stone_str..","..v["id"]..":"..v["num"]
						end
					end
							
				end
				print(stone_str)
				if stone_str ~= nil then
					HTTP:call("pulse" , "feed" , {
						id = parm.gid,
						index = parm.index,
						stone = stone_str
					} , {
						success_callback = function()
							this.array = {}
							if info ~= nil then
								this.layer:removeChild(info:getLayer(),true)
							end
							info = chipLayer:new(0,70,{gid = parm.gid,index = parm.index,mode = parm.mode},this)
							this.layer:addChild(info:getLayer())
							--switchScene("pulse" , parm.gid)
						end
					})
				elseif is_stone == true then
					KNMsg:getInstance():flashShow("请点击添加石头")
				else
					KNMsg:getInstance():flashShow("通过任务，副本，商场购买宝石")
				end
				
			end
		})
		this.layer:addChild(updata_btn:getLayer())
		
		---取消
		local stornieren = KNBtn:new(IMG_PATH .. "image/common" , {"btn_bg_red.png","btn_bg_red_pre.png"} , 60,120 , {
			front = IMG_PATH.."image/common/cancel.png",
			scale = true,
			noHide = true,
			callback = function()
				this.array = {}
				if info ~= nil then
					this.layer:removeChild(info:getLayer(),true)
				end
				info = chipLayer:new(0,70,{gid = parm.gid,index = parm.index,mode = parm.mode},this)
				this.layer:addChild(info:getLayer())
				--[[this.lv_bar:setCurValue(this.the_pulse["cur_exp"])
				this.the_exp = this.the_pulse["cur_exp"]
				if this.updata ~= nil then
					this.layer:removeChild(this.updata:getLayer(),true)
					this.updata = stonelist:new(this,0,0,{cid = this.the_pulse["cid"],data = DATA_Bag:getTable("prop")})
					this.layer:addChild(this.updata:getLayer())
				else
					KNMsg:getInstance():flashShow("没有添加石头")
				end]]
			end
		})
		this.layer:addChild(stornieren:getLayer())
		
	--end
	
return this
end

function Mosaiclayer:getLayer()
	return self.layer
end

return Mosaiclayer
