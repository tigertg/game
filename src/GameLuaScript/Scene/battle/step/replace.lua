--[[

		替补上阵

]]--
local M = {}
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroLayer")
local backHeroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
local heroCell = requires(IMG_PATH, "GameLuaScript/Scene/battle/heroCell" )
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroInfo")


function M:run( type , data )
	logic:pause("repalce")
	local tempBackHeroData = {}		--临时存放替补的英雄数据
	--获取对应英雄和替补英雄
	local hero
	local handle = {}
	local replace_total = #data	--同时替换人数
	local instantIndex = 0	--同时发送请求编号
	for i , v  in pairs(data) do
		--替补动画
		local function replaceAction( backHero , targetHero )
			--取得替补英雄数据
			local backHeroData = backHero:getData()
			local backSize= backHero:getBackSize()
			local actionTime = 0.5
			--目标英雄大小
			local targetSize = targetHero:getContentSize()
			--动作
			local actions = CCArray:create()
			actions:addObject( CCMoveTo:create( actionTime , ccp( targetHero.x + targetSize.width / 2 - backSize.width , targetHero.y + targetSize.height / 2 - backSize.height ) ) )
			actions:addObject( CCScaleTo:create( actionTime , 2))
			--附加回调的动作列
			local additionFunActions = CCArray:create()
			additionFunActions:addObject( CCSpawn:create( actions ) )
			additionFunActions:addObject( CCCallFunc:create( function()
																targetHero:setVisible( true )
																backHeroCell:clear( backHeroData._group , backHeroData._index )
																replace_total = replace_total - 1
																if replace_total == 0 then
																	logic:resume("repalce")
																	logic:resume()
																end
															end
															) )

			backHero:runAction( CCSequence:create( additionFunActions ) )
		end
		--替换死亡队友
		local function teamReply()
			--取得替补英雄对象
			local backHeroObj = backHeroCell:get( data[i].group , "replace" , instantIndex )
			instantIndex = instantIndex + 1
			if backHeroObj == nil then
				logic:resume()
				logic:resume("heroinfo")
				return
			end
			--存诸替补英雄数据
			tempBackHeroData[ data[i].group .. data[i].index ] = clone( backHeroObj:getData() )
			--修改为目标位置英雄数据
			tempBackHeroData[ data[i].group .. data[i].index ]["_index"] = data[i]["index"]
			--生成要替补的英雄对像
		 	hero = heroCell.new( tempBackHeroData[ data[i].group .. data[i].index ] )
		 	hero:setVisible( false )
	 		-- 英雄点击事件
			local function hero_click(_data)
				infoLayer:new( _data , 2 )
			end

		 	--设置生成英雄的位置并显示
		 	heroLayer:setOneHero(hero , hero:getData("_group") , hero:getData("_index") , hero_click )

		 	replaceAction( backHeroObj , hero )
		end


		local function delayRealize()
			local death = heroCell:get( data[i].group , data[i].index )
			if death == nil then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle[i])
				handle[i] = nil
			 	teamReply()
			end
		end
		handle[i] = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.1 , false)
	end

end


return M
