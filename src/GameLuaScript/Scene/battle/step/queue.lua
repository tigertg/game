--[[

列阵

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local backHeroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroInfo")

--[[执行]]
function M:run( type , data )
	heroCell:init()
	backHeroCell:init()
	
	local hero		-- 英雄
	local hero_layer = logic:getLayer("hero")

	-- 英雄点击事件
	local function hero_click(_data)
		infoLayer:new( _data , 2 )
		
--		logic:pause("heroinfo")
--		KNMsg.getInstance():boxShow(_data["name"] .. "\n血:" .. _data["org_hp"] .. "  攻:" .. _data["atk"] .. "  防:" .. _data["def"] .. "  敏:" .. _data["agi"] , {
--			confirmFun = function()
--				logic:resume("heroinfo")
----				logic:resume("skip")
--			end
--		})
	end

	-- 创建已方英雄队列
	local agile = { self = 0 , foe = 0 }	--统计双方敏捷值
	
	local p1_total_time = 0
	for i = 1 , #data.p1 do
		hero = heroCell.new( data.p1[i] , { click = hero_click } )

		heroLayer:setOneHero(hero , hero:getData("_group") , hero:getData("_index"))
		p1_total_time = p1_total_time + 0.2
		agile.self = agile.self + data.p1[i].agi
	end
	
	--设置自己和敌人的代表人物
	logic:setSelfAgent( data.p1[1].cid )
	logic:setfoeAgent( data.p2[1].cid or data.p2[1].npc_id )
	
	-- 已方替补英雄
	local back_hero
	for i = 1 , #data.p1_back do
		back_hero = backHeroCell.new( data.p1_back[i] )
		heroLayer:setBackOneHero(back_hero , back_hero:getData("_group") , back_hero:getData("_index") )
		back_hero:setEnabled( true )
		agile.self = agile.self + data.p1_back[i].agi
	end
	-- 创建对方英雄队列
	local total_time = 0
	for i = 1 , #data.p2 do
		hero = heroCell.new( data.p2[i] , { click = hero_click } )
		heroLayer:setOneHero(hero , hero:getData("_group") , hero:getData("_index"))

		total_time = total_time + 0.2
		agile.foe = agile.foe + data.p2[i].agi
	end

	-- total_time = total_time + p1_total_time
	total_time = 0.2


	--敌方替补
	for i = 1 , #data.p2_back do
		
		back_hero = backHeroCell.new( data.p2_back[i] )
		heroLayer:setBackOneHero(back_hero , back_hero:getData("_group") , back_hero:getData("_index") )
		back_hero:setEnabled( false )
		
		agile.foe = agile.foe + data.p2_back[i].agi
	end

	logic:setAgile( agile )
	
	-- 延迟执行下一步
	local handle
	local function callback()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil

		logic:resume()
	end
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, total_time, false)

end


return M
