COLOR = {
	WHITE = "#ffffff",				-- 白
	GREY = "#808080",				-- 灰
	GREEN = "#00ff47ff",			-- 绿
	BLUE = "#a9d3fe",				-- 蓝
	PURPLE = "#cb74d0",				-- 紫
	ORANGE = "#f7710f",				-- 橙
	RED = "#f9463b", 				-- 红
	GOLD = "#d0cb74", 				-- 金
	YELLOW = "#ffd493", 			-- 黄
	LightBlue = "#d0d8ff",			-- 属性描述淡蓝
}

TEXT_COLOR = {
	WHITE = "#ffffff",			-- 白(按钮字/小标签字)
	RED = "#F9463B",			-- 红(提醒/不足)
	GOLD = "#ffff00",			-- 金(有关金币)
	GREEN = "#89F201",			-- 绿(有关数字)
	YELLOW = "#ffff00",			-- 黄
	BLUE = "#00ffff",			-- 浅蓝(按钮下的小提示)
	PURPLE = "#ff00fd",			-- 紫
	ORANGE = "#f7710f",			-- 橙
	GRAY = "#636363ff",			-- 灰
	GRAY_BLUE = "#83b2e7ff",	-- 灰蓝
	GRAY_WHITE = "#B7D3F9FF",	-- 灰白（属性）
	LOWGREEN = "#2dcecfff",		-- 提醒
	GREEN_1 = "#40f466",		-- 通用描述数字颜色(浅绿)
	GREEN_2 = "#3fbc88",		-- 通用描述文字颜色(浅绿)
	GREEN_3 = "#33e45d",		-- 镉绿色(任务面板)
	BLUE_1 = "#b7d3f9",			-- 通用描述数字颜色(浅蓝)
	BLUE_2 = "#6098cb",			-- 通用描述文字颜色(浅蓝)
	BLUE_3 = "#2899f9",			-- 物品文字品质(浅蓝)
	PURPLE_1 = "#c56aff",		-- 通用描述数字颜色(浅紫)
	PURPLE_2 = "#934fc6",		-- 通用描述文字颜色(浅紫)
	PURPLE_3 = "#f12fea",		-- 物品文字品质(浅紫)
	ORANGE_1 = "#ff8247",		-- 通用描述数字颜色(浅橙)
	ORANGE_2 = "#ba5f35",		-- 通用描述文字颜色(浅橙)
	ORANGE_3 = "#f7710f",		-- 物品文字品质(浅橙)
	RED_1 = "#ff3838",			-- 通用描述数字颜色(浅红)
	RED_2 = "#e75959",			-- 通用描述文字颜色(浅红)
	RED_3 = "#eb3434",			-- 物品文字品质(浅红)
	GRAY_1 = "#735c32",			-- 描述颜色(灰)
	--新项目文字颜色
	LOWBLUE = "#d0d8ff",		-- 新项目描述颜色(淡蓝)
	DARKYELLOW = "#614515",		-- 新项目描述暗黄
	LIGHTYELLOW = "#fde45c",	-- 新项目描述亮黄
	RED_4 = "#f9463b",            --新项目套装浅红色描述
	BLUE_4 = "#34acf3",         --新项目浅蓝色秒速
	GREEN_4 ="#89F201",			--新項目绿色
	PINK = "#FF8AD1FF",			--新项目粉色
	PURERED = "#ff0000",			--纯红
	ORANGE_4 = "#31FF01FF", 		-- 新橘色(结婚属性用)
	ORANGE_5 = "#FDAD00FF",
}

-- 颜色从品质低到高
SOUL_NAME_COLOR = {
	"#89F201",					-- 绿色
	"#00ffff",					-- 蓝色
	"#ff00fdff",				-- 紫色
	"#f7710fFF",				-- 橙色
	"#ff0000",					-- 红色
	"#FF8AD1FF",				-- 粉色
	"#FFFF00",					-- 金色
}

-- 品质颜色
ORDER_COLOR = {
	"#89F201",					-- 绿色
	"#34acf3",					-- 蓝色
	"#ca62ff",					-- 紫色
	"#ff9e0e",					-- 橙色
	"#f9463b",					-- 红色
	"#FF8AD1FF",				-- 粉色
	"#fde45c",					-- 金色
}

-- 精灵资质颜色
SPIRIT_ADDITION_NAME_COLOR = {
	"#ffffff",					-- 无色 对应 无称号
	"#33e45d",					-- 绿色
	"#2899f9",					-- 蓝色
	"#f12fea",                  -- 紫色
	"#ffe76d",                  -- 金色
}

-- 神印套装颜色
SHENYIN_TIPS_SUIT_COLOR = {
	[1] = "#00ff06",
	[2] = "#0000f1",
	[3] = "#fc00f3",
	[4] = "#fc4d00",
	[5] = "#e40000",
}

--鱼名字的颜色
FISH_NAME_COLOR = {
	[0] = TEXT_COLOR.GREEN,
	[1] = TEXT_COLOR.BLUE,
	[2] = TEXT_COLOR.PURPLE,
	[3] = TEXT_COLOR.RED,
}

ITEM_TIP_COLOR = {
	[GameEnum.EQUIP_COLOR_GREEN] = TEXT_COLOR.GREEN,		-- 绿
	[GameEnum.EQUIP_COLOR_BLUE] = TEXT_COLOR.BLUE,			-- 蓝
	[GameEnum.EQUIP_COLOR_PURPLE] = TEXT_COLOR.PURPLE,		-- 紫
	[GameEnum.EQUIP_COLOR_ORANGE] = TEXT_COLOR.ORANGE,		-- 橙
	[GameEnum.EQUIP_COLOR_RED] = TEXT_COLOR.RED,			-- 红
	[GameEnum.EQUIP_COLOR_PINK] = TEXT_COLOR.PINK,			-- 粉
}

--频道文字描边颜色
CHANEL_TEXT_OUTLINE_COLOR = {
	[CHANNEL_TYPE.WORLD] = Color(0.5019,0.1764,0,1),
	[CHANNEL_TYPE.GUILD] = Color(0.0156,0.4117,0,1),
	[CHANNEL_TYPE.TEAM] = Color(0.4117,0.0549,0.6431,1),
	[CHANNEL_TYPE.SYSTEM] = Color(0.0431,0.2509,0.5333,1),
	[CHANNEL_TYPE.SPEAKER] = Color(0.5019,0.1764,0,1),
}

-- 头衔颜色
JINGJIE_COLOR = {
	[0] = Color(0,0,0,1),							-- 黑色
	Color(1/255,165/255,12/255,1),					-- 绿色
	Color(0,92/255,255/255,1),						-- 蓝色
	Color(255/255,0,228/255,1),						-- 紫色
	Color(255/255,84/255,0,1),                 	 	-- 橙色
	Color(255/255,0,0,1),                  			-- 红色
	Color(255/255,115/255,115/255,1),               -- 粉色
}

QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_WHITE] = "Quality_White",				--白色
	[GameEnum.ITEM_COLOR_GREEN] = "bg_item_quality_green",		--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "bg_item_quality_blue",		--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "bg_item_quality_purple", 	--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "bg_item_quality_orange",	--橙色
	[GameEnum.ITEM_COLOR_RED] = "bg_item_quality_red"	,		--红色
	[GameEnum.ITEM_COLOR_PINK] = "bg_item_quality_pink",		--粉色
	[GameEnum.ITEM_COLOR_GLOD] = "bg_item_quality_gold",		--金色
}

MOUNT_QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_GREEN] = "Grade_Green",		--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "Grade_Blue",			--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "Grade_Purple", 		--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "Grade_Orange"	,	--橙色
	[GameEnum.ITEM_COLOR_RED] = "Grade_Red"	,			--红色
}

ITEM_COLOR = {
	[GameEnum.ITEM_COLOR_WHITE] = TEXT_COLOR.WHITE,		-- 白
	[GameEnum.ITEM_COLOR_GREEN] = TEXT_COLOR.GREEN,		-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = TEXT_COLOR.BLUE,		-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = TEXT_COLOR.PURPLE,	-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = TEXT_COLOR.ORANGE_3,	-- 橙
	[GameEnum.ITEM_COLOR_RED] = TEXT_COLOR.PURERED,			-- 红
	[GameEnum.ITEM_COLOR_GLOD] = TEXT_COLOR.GOLD,		-- 金
	[GameEnum.ITEM_COLOR_PINK]= TEXT_COLOR.PINK,		-- 粉
}

--符文品质字体颜色
RUNE_COLOR = {
	[GameEnum.RUNE_COLOR_WHITE] = TEXT_COLOR.WHITE,			--白
	[GameEnum.RUNE_COLOR_BLUE] = TEXT_COLOR.BLUE_3,			--蓝
	[GameEnum.RUNE_COLOR_PURPLE] = TEXT_COLOR.PURPLE_3,		--紫
	[GameEnum.RUNE_COLOR_ORANGE] = TEXT_COLOR.ORANGE_3,		--橙
	[GameEnum.RUNE_COLOR_RED] = TEXT_COLOR.RED_3,			--红
}

BUTTON_BG_NAME = {
	[GameEnum.ITEM_COLOR_WHITE] = "link_green",			-- 白
	[GameEnum.ITEM_COLOR_GREEN] = "link_green",			-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = "link_blue",			-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = "link_purple",		-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = "link_orange",		-- 橙
	[GameEnum.ITEM_COLOR_RED] = "link_red",				-- 红
	[GameEnum.ITEM_COLOR_GLOD] = "link_green",			-- 金
}

--职业颜色
PROF_COLOR = {										-- 职业
	[GameEnum.ROLE_PROF_1] = TEXT_COLOR.RED,		-- 太渊红色
	[GameEnum.ROLE_PROF_2] = TEXT_COLOR.PURPLE,		-- 孤影紫色
	[GameEnum.ROLE_PROF_3] = TEXT_COLOR.BLUE,		-- 绝弦蓝色
	[GameEnum.ROLE_PROF_4] = TEXT_COLOR.GOLD,		-- 无极金色
}

--羽翼坐骑颜色
GRADE_COCOR = {
	[0] = COLOR.GOLD,							--特殊羽翼金色
	[1] = COLOR.GREEN,							-- 绿
	[2] = COLOR.GREEN,
	[3] = COLOR.BLUE,							-- 蓝
	[4] = COLOR.BLUE,
	[5] = COLOR.BLUE,							-- 紫
	[6] = COLOR.BLUE,
	[7] = COLOR.PURPLE,							-- 橙
	[8] = COLOR.PURPLE,
	[9] = COLOR.PURPLE,							-- 红
	[10] = COLOR.ORANGE,
	[11] = COLOR.ORANGE,
	[12] = COLOR.RED,
	[13] = COLOR.RED,
	[14] = COLOR.RED,
	[15] = COLOR.RED,
}

SEX_COLOR = {
	[GameEnum.MALE] = COLOR.BLUE,			-- 男性蓝色
	[GameEnum.FEMALE] = COLOR.PURPLE,		-- 女性粉色
}

CAMP_COLOR = {
	[GameEnum.ROLE_CAMP_0] = COLOR.WHITE,				-- 白色
	[GameEnum.ROLE_CAMP_1] = COLOR.ORANGE,				-- 橙
	[GameEnum.ROLE_CAMP_2] = COLOR.GREEN,				-- 绿
	[GameEnum.ROLE_CAMP_3] = COLOR.BLUE,				-- 蓝
}
Common_Five_Rank_Color = {
	"green",                        --绿
	"blue",							--蓝
	"purple",						--紫
	"orange",						--橙
	"red",							--红
	"pink",						--粉
}

SPRITE_SKILL_LEVEL_COLOR = {
	[1] = TEXT_COLOR.GREEN,
	[2] = TEXT_COLOR.BLUE,
	[3] = TEXT_COLOR.PURPLE,
	[4] = TEXT_COLOR.ORANGE,
	[5] = TEXT_COLOR.RED,
	[6] = TEXT_COLOR.PINK,
}

SPRITE_SKILL_LEVEL_COLOR_TWO = {
	[1] = TEXT_COLOR.BLUE,
	[2] = TEXT_COLOR.PURPLE,
	[3] = TEXT_COLOR.ORANGE,
	[4] = TEXT_COLOR.RED,
	[5] = TEXT_COLOR.PINK
}

SHENYIN_COLOR = {
	[0] = COLOR.BLUE,
	[1] = COLOR.PURPLE,
	[2] = COLOR.ORANGE,
	[3] = COLOR.RED,
}

BAOJU_COLOR = {
	[1] = COLOR.GREEN,
	[2] = COLOR.BLUE,
	[3] = COLOR.PURPLE,
	[4] = COLOR.ORANGE,
	[5] = COLOR.RED,
}

PET_COLOR = {
	[0] = COLOR.WHITE,
	[1] = COLOR.GREEN,
	[2] = COLOR.BLUE,
	[3] = COLOR.PURPLE,
	[4] = COLOR.ORANGE,
	[5] = COLOR.RED,
	[6] = COLOR.GOLD,
	[7] = COLOR.GOLD,
}

GATHER_COLOR = {
	[1] = TEXT_COLOR.WHITE,
	[2] = TEXT_COLOR.GREEN,
	[3] = TEXT_COLOR.BLUE,
	[4] = TEXT_COLOR.PURPLE,
	[5] = TEXT_COLOR.ORANGE,
	[6] = TEXT_COLOR.RED,
	[7] = TEXT_COLOR.PINK,
}

-- 竞技场角色名称颜色
ARENA_NAME_COLOR = {
	[0] = TEXT_COLOR.WHITE,
	[1] = TEXT_COLOR.GREEN,
	[2] = TEXT_COLOR.BLUE,
	[3] = TEXT_COLOR.PURPLE,
	[4] = TEXT_COLOR.ORANGE,
	[5] = TEXT_COLOR.RED,
}

-- 宝宝颜色
BAOBAO_COLOR = {
	TEXT_COLOR.BLUE,
	TEXT_COLOR.PURPLE,
	TEXT_COLOR.ORANGE,
}
-- 宝宝守护精灵从品质低到高
BAOBAO_SPRITE_COLOR = {
	TEXT_COLOR.GREEN,
	TEXT_COLOR.BLUE,
	TEXT_COLOR.PURPLE,
	TEXT_COLOR.ORANGE,
}


function ToColorStr(str, color)
	str = str or ""
	color = color or COLOR.WHITE
	local color_str = "<color=%s>%s</color>"
	return string.format(color_str, color, str)
end

function StrToColor(str)
	if nil == str or string.len(str) < 6 then
		print_error("StrToColor")
		return TEXT_COLOR.WHITE
	end

	return Color.New((tonumber(string.sub(str, 1, 2), 16) or 255) / 255,
		(tonumber(string.sub(str, 3, 4), 16) or 255) / 255,
		(tonumber(string.sub(str, 5, 6), 16) or 255) / 255,
		(tonumber(string.sub(str, 7, 8), 16) or 255) / 255)
end

function GetRightColor(str,flag,satisfy_color,lack_color)
	local dispose_str = str
	if flag(str) then
		dispose_str = ToColorStr(str,satisfy_color)
	else
		dispose_str = ToColorStr(str,lack_color)
	end
	return dispose_str
end


-------------------------- 聊天和传闻的绿要纯绿
CHAT_COLOR = {
	GREEN = "#00ff00",			-- 纯绿
}

CHAT_TEXT_COLOR = {
	GREEN = "#00ff00",			-- 纯绿
	RED = "#F9463B",			-- 红(提醒/不足)
	BLUE = "#00ffff",			-- 浅蓝(按钮下的小提示)
	PURPLE = "#ff00fd",			-- 紫
	ORANGE = "#f7710f",			-- 橙
	PINK = "#FF8AD1FF",			--新项目粉色
	WHITE = "#ffffff",			-- 白(按钮字/小标签字)
	PURPLE_3 = "#f12fea",		-- 物品文字品质(浅紫)
	ORANGE_3 = "#f7710f",		-- 物品文字品质(浅橙)
	GOLD = "#ffff00",			-- 金(有关金币)
	PURERED = "#ff0000",			--纯红
	RAND_RED = "#fb1212ff",
}

CHAT_SOUL_NAME_COLOR = {
	"#00ff00",					-- 纯绿
	"#00ffff",					-- 蓝色
	"#ff00fdff",				-- 紫色
	"#f7710fFF",				-- 橙色
	"#ff0000",					-- 红色
	"#FF8AD1FF",				-- 粉色
	"#FFFF00",					-- 金色
}

CHAT_ITEM_TIP_COLOR = {
	[GameEnum.EQUIP_COLOR_GREEN] = CHAT_TEXT_COLOR.GREEN,		-- 纯绿
	[GameEnum.EQUIP_COLOR_BLUE] = CHAT_TEXT_COLOR.BLUE,			-- 蓝
	[GameEnum.EQUIP_COLOR_PURPLE] = CHAT_TEXT_COLOR.PURPLE,		-- 紫
	[GameEnum.EQUIP_COLOR_ORANGE] = CHAT_TEXT_COLOR.ORANGE,		-- 橙
	[GameEnum.EQUIP_COLOR_RED] = CHAT_TEXT_COLOR.RED,			-- 红
	[GameEnum.EQUIP_COLOR_PINK] = CHAT_TEXT_COLOR.PINK,			-- 粉
}

CHAT_ITEM_COLOR = {
	[GameEnum.ITEM_COLOR_WHITE] = CHAT_TEXT_COLOR.WHITE,		-- 白
	[GameEnum.ITEM_COLOR_GREEN] = CHAT_TEXT_COLOR.GREEN,		-- 纯绿
	[GameEnum.ITEM_COLOR_BLUE] = CHAT_TEXT_COLOR.BLUE,		-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = CHAT_TEXT_COLOR.PURPLE,	-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = CHAT_TEXT_COLOR.ORANGE_3,	-- 橙
	[GameEnum.ITEM_COLOR_RED] = CHAT_TEXT_COLOR.PURERED,			-- 红
	[GameEnum.ITEM_COLOR_GLOD] = CHAT_TEXT_COLOR.GOLD,		-- 金
	[GameEnum.ITEM_COLOR_PINK]= CHAT_TEXT_COLOR.PINK,		-- 粉
}

CHAT_CAMP_COLOR = {
	[GameEnum.ROLE_CAMP_0] = COLOR.WHITE,				-- 白色
	[GameEnum.ROLE_CAMP_1] = COLOR.ORANGE,				-- 橙
	[GameEnum.ROLE_CAMP_2] = CHAT_COLOR.GREEN,				-- 纯绿
	[GameEnum.ROLE_CAMP_3] = COLOR.BLUE,				-- 蓝
}

ITEMCELL_IMG = {
	[GameEnum.EQUIP_COLOR_GREEN] = "bg_corner_tag_green",			-- 绿
	[GameEnum.EQUIP_COLOR_BLUE] = "bg_corner_tag_blue",				-- 蓝
	[GameEnum.EQUIP_COLOR_PURPLE] = "bg_corner_tag_purple",			-- 紫
	[GameEnum.EQUIP_COLOR_ORANGE] = "bg_corner_tag_orange",			-- 橙
	[GameEnum.EQUIP_COLOR_RED] = "bg_corner_tag_red",				-- 红
	[GameEnum.EQUIP_COLOR_PINK] = "bg_corner_tag_pink",				-- 粉
}


