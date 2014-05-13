local SkillLayer = {layer,gid,array_id,mode}
local skillinfo = requires(IMG_PATH,"GameLuaScript/Scene/strengthen/skillInfo")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
function SkillLayer:new(param)
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	this.array_id = {}
	this.gid = param.gid
	this.mode = param.mode
	this.layer = display.newLayer()
	local bg = display.newSprite(IMG_PATH.."image/scene/common/bg.png")
	setAnchPos(bg,x,60)
	this.layer:addChild(bg)
	
	local cu_bg = display.newSprite(IMG_PATH.."image/common/dark_bg.png")
	setAnchPos(cu_bg,0,86)
	this.layer:addChild(cu_bg)
	
	local box = display.newSprite(IMG_PATH.."image/scene/strengthen/strong_box.png")
	setAnchPos(box,(this.layer:getContentSize().width - box:getContentSize().width)/2,105)
	this.layer:addChild(box)
	
	local font = display.newSprite(IMG_PATH.."image/scene/strengthen/skill_font.png")
	setAnchPos(font,30,670)
	this.layer:addChild(font)
	
	local title_font = display.newSprite(IMG_PATH.."image/scene/strengthen/title_font.png")
	setAnchPos(title_font,(this.layer:getContentSize().width - title_font:getContentSize().width)/2,720)
	this.layer:addChild(title_font)
	
	local infoLayer = nil 
	infoLayer = skillinfo:new(this.gid,this)
	this.layer:addChild(infoLayer:getLayer())
	
	local updata_btn = KNBtn:new(IMG_PATH .. "image/common" , {"btn_bg_red.png","btn_bg_red_pre.png"} , 275,120 , {
		front = IMG_PATH.."image/scene/mosaic/font_updata1.png",
		scale = true,
		noHide = true,
		callback = function()
			if next(this.array_id) == nil then
				KNMsg.getInstance():flashShow("没有选择被消耗的技能书")
				return
			end

			local sortFunc = function(a, b) 
				return b > a 
			end
			table.sort(this.array_id, sortFunc)
			local str = ""
			for k,v in pairs(this.array_id) do
				if k == 1 then
					str = v
				else
					str = str .. ","..v
				end
			end
			local type_skill = 3
			if this.mode == "heroskill" then
				type_skill = 3
			else
				type_skill = 4
			end
			
			--local type_skill =  math.modf(DATA_Bag:get("pet" , this.gid)["skill_k"]/1000) 
			if type_skill  == 3 then
				HTTP:call("skill" , "heroskill_up" , {
					target = this.gid,
					destroy = str
				} , {
					success_callback = function(d)
						KNMsg.getInstance():flashShow("技能增加经验" .. d.exp_add .. (d.old_lv ~= d.new_lv and ",升级成功" or "") )
						
						this.array_id = {}
						if infoLayer ~= nil then
							this.layer:removeChild(infoLayer:getLayer(),true)
							infoLayer = skillinfo:new(this.gid,this)
							this.layer:addChild(infoLayer:getLayer())
						end
					end
				})
			elseif type_skill  == 4 then
				if this.mode == "petskill" then
					HTTP:call("skill" , "petnatskill_up" , {
						pet_id = this.gid,
						destroy = str
					} , {
						success_callback = function(d)
							KNMsg.getInstance():flashShow("技能增加经验" .. d.exp_add .. (d.old_lv ~= d.new_lv and ",升级成功" or "") )

							this.array_id = {}
							if infoLayer ~= nil then
								this.layer:removeChild(infoLayer:getLayer(),true)
								infoLayer = skillinfo:new(this.gid,this)
								this.layer:addChild(infoLayer:getLayer())
							end
						end
					})
				elseif this.mode == "petplainskill" then
					HTTP:call("skill" , "petbagskill_up" , {
						target = this.gid,
						destroy = str
					} , {
						success_callback = function(d)
							KNMsg.getInstance():flashShow("技能增加经验" .. d.exp_add .. (d.old_lv ~= d.new_lv and ",升级成功" or "") )

							this.array_id = {}
							if infoLayer ~= nil then
								this.layer:removeChild(infoLayer:getLayer(),true)
								infoLayer = skillinfo:new(this.gid,this)
								this.layer:addChild(infoLayer:getLayer())
							end
						end
					})
				end
			end
		end
	})
	this.layer:addChild(updata_btn:getLayer())
	
	local stornieren = KNBtn:new(IMG_PATH .. "image/common" , {"btn_bg_red.png","btn_bg_red_pre.png"} , 60,120 , {
		front = IMG_PATH.."image/common/cancel.png",
		scale = true,
		noHide = true,
		callback = function()
			if next(this.array_id) == nil then
				KNMsg.getInstance():flashShow("没有选择被消耗的技能书")
				return
			end

			this.array_id = {}
			if infoLayer ~= nil then
				this.layer:removeChild(infoLayer:getLayer(),true)
				infoLayer = skillinfo:new(this.gid,this)
				this.layer:addChild(infoLayer:getLayer())
			end
		end
	})
	this.layer:addChild(stornieren:getLayer())
	
	return this
end
function SkillLayer:set_array(id)
	self.array_id[#self.array_id + 1] = id
	--dump(self.array_id)
end

function SkillLayer:remove_array(id)
	for k,v in pairs(self.array_id) do
		if tonumber(v) == tonumber(id) then
			table.remove(self.array_id,k)
		end
	end
	--dump(self.array_id)
end
function SkillLayer:getLayer()
	return self.layer
end

return SkillLayer
