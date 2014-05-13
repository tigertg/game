--[[

普通攻击

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local effectLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/effectLayer")


--[[执行]]
function M:run( type , data )
	-- 攻击方
	local atk_data = data["atk"][1]		-- 普通攻击，肯定只有一个攻击者
	local atk_hero = heroCell:get( atk_data["group"] , atk_data["index"] )
	
	
	

	
--	local t = 1
--	local shuffle = CCShuffleTiles:create(25, ccg(50,50), t)
--	local shuffle = CCShatteredTiles3D:create(10,  false , ccg(50,50) , t)
--	local shuffle_back = shuffle:reverse()
--	local delay = CCDelayTime:create(2)

--	local array = CCArray:create()
--	array:addObject(shuffle)
--	array:addObject(shuffle_back)
--	array:addObject(delay)
--	atk_hero:runAction( CCSequence:create(array) )

	-- 被攻击方
	local be_atk_data = data["be_atk"][1]	-- 普通攻击，肯定只有一个被攻击者
	local be_atk_hero = heroCell:get( be_atk_data["group"] , be_atk_data["index"] )
	

	--[[播放动画]]
	local heroAction_move = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/move")
	local heroAction_attack = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/attack")
	local heroAction_be_attack = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/be_attack")

	heroAction_move:move(atk_hero , be_atk_hero , {
		-- 移动过去后的回调
		onComplete = function()
			-- 挥舞动作
			heroAction_attack:wave( atk_hero , {
				onComplete = function()
					-- 受击
					--[[
					heroAction_be_attack:normal( be_atk_hero , {

					})
					]]

					-- 掉血
					effectLayer:actions( data )
					audio.playSound(IMG_PATH .. "sound/atk.mp3")

					-- 回来
					heroAction_move:moveback( atk_hero , {
						onComplete = function()
							-- 恢复战斗进程
							logic:resume()
						end,
					})
				end
			})

			-- 攻击效果(刀光)
			heroAction_attack:normal( atk_hero )
		end
	})


end


return M
