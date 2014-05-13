--[[等级开放功能]]
local Config_Open = {
	["equip"] = {1 , 3},
	["equip_strenthen"] = {1 , 3},
	["fb_equip"] = {3 , 4},
	["fb_hero"] = {4 , 3},
	["forge"] = {4 , 9},
	["byexp"] = {5 , 8},
	["pet"] = {6 , 1},
	["hatch"] = {6 , 1},
	["fb_pet"] = {6 , 2},
	["forge_pet"] = {6 , 3},
	["friend"] = {6 , 4},
	["helper"] = {2 , 6},
	["athletics"] = {6 , 8},
	["skill"] = {7 , 1},
	["fb_skill"] = {7 , 5},
	["fb_rob"] = {7 , 8},
	["gang"] = {8 , 5},		-- 联盟
	["pulse"] = {9 , 1},
	["forge_pool"] = {9 , 5},
	["uplevel"] = {9 , 8},
	["diggings"] = {10 , 6},
	


	["1-3"]  = { text = "装备系统开放啦,终于不用裸奔了!在装备系统中可以强化装备的等级。"        , id = "equip"			, guide_step = 200 } ,
	["2-1"]  = { text = "无兄弟不唐门！在英雄系统中可以选择上场战斗的英雄和调整阵型。"          , id = "formation" 		, guide_step = 300 } ,
	["2-6"]  = { text = "助手精灵出现！有什么不明白的，赶紧去查查看！" 							, id = "helper"			, guide_step = 4100 } ,
	["3-4"]  = { text = "开启藏宝楼副本，小手抖一抖，装备搞到手！挑战装备副本获得精美装备。"    , id = "fb_equip"		, guide_step = 800 } ,
	["4-3"]  = { text = "开启英雄殿副本，进入副本多多兑换获得英雄，可使基友遍天下！"            , id = "fb_hero"		, guide_step = 3000 } ,
	["4-9"]  = { text = "开启英雄打造系统，可以进行英雄的合成，提高英雄的星级！"                , id = "forge" 			, guide_step = 1500 } ,
	["5-8"]  = { text = "开启英雄传功,英雄之间可以互相转换经验，妈妈再也不担心经验的浪费!"      , id = "byexp" } ,
	["6-1"]  = { text = "开启幻兽孵化，幻兽蛋可以变成可爱的幻兽宝宝了！"						, id = "pet" 			, guide_step = 400 } ,
	["6-2"]  = { text = "开启狩猎副本，各种高级精美的幻兽等你拿。"  							, id = "fb_pet"			, guide_step = 3100 } ,
	["6-4"]  = { text = "好友系统开放，从此可以好友互动啦！" 		 							, id = "friend"			, guide_step = 3600 } ,
	["6-8"]  = { text = "开启竞技系统，可以在竞技场与其他玩家PK格斗，天上地下，唯你独尊！"      , id = "athletics" } ,
	["7-1"]  = { text = "开启英雄技能系统，英雄光有好皮囊可不够，还要学一身好武艺！"            , id = "skill"			, guide_step = 700 } ,
	["7-5"]  = { text = "开启如意阁副本，获得更多更好的技能，大量提升英雄的战斗力！"            , id = "fb_skill"		, guide_step = 3200 } ,
	["7-8"]  = { text = "夺宝系统开启啦，每天都可以去别人家抢夺英雄、武器、将魂和碎片咯！"		, id = "fb_rob"			, guide_step = 3300 } ,
	["8-5"]  = { text = "帮会开启！招呼自己的兄弟打造自己的唐门吧！"							, id = "gang" 			, guide_step = 3500 } ,
	["9-1"]  = { text = "开启经脉宝石系统，宝石可以让你更快！更强！更有力！"                  	, id = "pulse" } ,
	["9-5"]  = { text = "幻兽升阶方法开放，获得符文丹就可以炼化出神秘的进化符了哦。"			, id = "forge_pool"		, guide_step = 3400 } ,
	["9-8"]  = { text = "英雄升阶开放！提升英雄等级上限！增加英雄的基本属性！"					, id = "uplevel" } ,
	["10-6"] = { text = "在矿山中挖矿可获得大量银两，还可以邀请好友一起采矿哦"					, id = "diggings" } ,
	["11-5"] = { text = "小助手的入口更换位置啦，以后需要在更多里面找到助手了。"				, id = "helper"			, guide_step = 4200 , not_new = true } ,

	["2-6"]  = { text = "前方会有更加强大的敌人，强化装备增强自己能力吧。"						, id = "equip_strenthen"	, guide_step = 4000	, not_new = true } ,
	["3-8"]  = { text = "前方会有更加强大的敌人，强化装备增强自己能力吧。"						, id = "equip_strenthen"	, guide_step = 4000	, not_new = true } ,
	["4-5"]  = { text = "前方会有更加强大的敌人，强化装备增强自己能力吧。"						, id = "equip_strenthen"	, guide_step = 4000	, not_new = true } ,
	["5-5"]  = { text = "前方会有更加强大的敌人，强化装备增强自己能力吧。"						, id = "equip_strenthen"	, guide_step = 4000	, not_new = true } ,
}


return Config_Open