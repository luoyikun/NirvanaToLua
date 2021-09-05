-- 预加载
local TypeUnityMaterial = typeof(UnityEngine.Material)

PreloadManager = PreloadManager or BaseClass()

function PreloadManager:__init()
	if PreloadManager.Instance ~= nil then
		print_error("PreloadManager to create singleton twice!")
	end
	PreloadManager.Instance = self

	self.complete = false
	self.loadcfg = {
		{"misc/material", "UI-NormalGrey", TypeUnityMaterial},
		
		{"scenes_prefab", "CameraFollow"},

		{"uis/views/miscpreload_prefab", "FollowUi"},
		{"uis/views/miscpreload_prefab", "SceneObjName"},
		{"uis/views/miscpreload_prefab", "SceneRoleObjName"},
		{"uis/views/miscpreload_prefab", "MonsterHP"},
		{"uis/views/miscpreload_prefab", "RoleHP"},

		{"uis/views/miscpreload_prefab", "RichButton"},						-- 聊天有点击事件的按钮
		{"uis/views/miscpreload_prefab", "RichButtonNotTarget"},			-- 聊天无点击事件的按钮
		{"uis/views/miscpreload_prefab", "RichButtonUnderLine"},			-- 聊天有点击事件的按钮
		{"uis/views/miscpreload_prefab", "RichButtonNotTargetUnderLine"},	-- 聊天无点击事件的按钮

		{"uis/views/miscpreload_prefab", "RichImage"},
		{"uis/views/miscpreload_prefab", "VioceButtonLeft"},				-- 语音左按钮
		{"uis/views/miscpreload_prefab", "VioceButtonRight"},				-- 语音右按钮
		{"uis/views/miscpreload_prefab", "ContentLeft"},					-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "ContentRight"},					-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeContentLeft"},			-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeContentRight"},			-- 预加载聊天框

		-- {"uis/views/chatroom_prefab", "ContentRight"},					-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "LeisureBubble"},					-- 预加载场景框

		{"uis/views/miscpreload_prefab", "BubbleSlotRight"},				-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "BubbleSlotLeft"},					-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeBubbleSlotLeft"},		-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeBubbleSlotRight"},		-- 预加载聊天框

		{"uis/views/miscpreload_prefab", "BigfaceSlot"},					-- 大表情容器
		{"uis/views/miscpreload_prefab", "BigfaceSlotSmall"},				-- 大表情容器
		{"uis/views/miscpreload_prefab", "NormalfaceSlot"},					-- 普通表情容器
		{"uis/views/miscpreload_prefab", "NormalfaceSlotSmall"},			-- 普通表情容器

		{"uis/views/commonwidgets_prefab", "UIScene"},						-- UI场景预制体
		{"uis/views/commonwidgets_prefab", "ItemCell"},						-- 预加载格子
		{"uis/views/commonwidgets_prefab", "RichOutlineText"},
		{"uis/views/commonwidgets_prefab", "RichShadowText"},
		{"uis/views/commonwidgets_prefab", "RichTextImage"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},				-- 通用全屏底板1
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},				-- 通用全屏底板2
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},				-- 通用全屏底板3
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},				-- 通用二级底板
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},			-- 通用二级底板1
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},			-- 通用二级底板2
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},			-- 通用二级底板3
		{"uis/views/commonwidgets_prefab", "BaseFullPanelSideTab"},			-- 通用标签按钮1
		{"uis/views/commonwidgets_prefab", "BaseFullPanelTopTab"},			-- 通用标签按钮1
		{"uis/views/commonwidgets_prefab", "BaseSecondPanelTab"},			-- 通用标签按钮2
		{"uis/views/commonwidgets_prefab", "BaseSecondPanelTopTab"},		-- 通用标签按钮3

		{"uis/views/miscpreload_prefab", "BaseFullPanelSideTab"},			-- 结婚标签按钮1
		{"uis/views/miscpreload_prefab", "BaseFullPanelTopTab"},			-- 结婚标签按钮2
		{"uis/views/miscpreload_prefab", "BaseFullPanelTopTab_Start"},		-- 结婚标签按钮3
		{"uis/views/miscpreload_prefab", "BaseFullPanelTopTab_End"},		-- 结婚标签按钮4
		
		{"uis/views/miscpreload_prefab", "RichImage_Small"},
		{"uis/views/miscpreload_prefab", "MainuiIconSmall"},				-- 主界面图标
		{"uis/views/miscpreload_prefab", "MainuiIconNormal"},				-- 主界面图标
		{"uis/views/miscpreload_prefab", "MainuiIconBig"},					-- 主界面图标

		{"uis/views/miscpreload_prefab", "PieceItem"},						-- 预加载格子
		{"uis/views/miscpreload_prefab", "ChatCell"},						-- 预加载聊天cell
		{"uis/views/miscpreload_prefab", "GuildchuanwenItemText"},			-- 预加载江湖传闻cell
		{"uis/views/miscpreload_prefab", "PurchaseItemText"},				-- 预加收购cell
		{"uis/views/miscpreload_prefab", "TianXiangItem"},					-- 预加载天象格子
		{"uis/views/miscpreload_prefab", "FallItemText"},					-- 预加载掉落格子
		{"uis/views/miscpreload_prefab", "drop_weapon"},					-- 掉落特效
		{"uis/views/miscpreload_prefab", "FightPower2"},					-- 战斗力UI
		{"uis/views/miscpreload_prefab", "FightPower3"},					-- 战斗力UI
		{"uis/views/miscpreload_prefab", "PaintingEffect"},					-- 预加载名将变身

		{"uis/views/commonwidgets/itemcellchild_prefab", "GodQuality"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "Grade"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "HasGet"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "InlaySlot"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "PropDes"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "PropName"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "RepairImage"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "RoleProf"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ShenGeLevel"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ShenYinName"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "TainShenEquipLabel"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "StarLevel"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "Strength"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "TimeLimit"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "TopLeft"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "UpQuality"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "JueBan"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "RomeNumImage"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "LevelNoEnough"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "UpArrow"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "Gray"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "RedPoint"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "StarsGroup"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ShengYinLock"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ShengYinGrade"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ShengYinEffect"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "SuitText"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "LuoShuProf"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ZhuanShu"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "DecorationTAG"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "LimitUse"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "BestEquipTip"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "LingHunLevel"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "SuitItemName"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "ImgDouqi"},
		{"effects/prefab/tongyong/chuansongmen_01_prefab", "chuansongmen_01"},
		{"effects/prefab/tongyong/chuansongmen_02_prefab", "chuansongmen_02"},
		{"uis/views/commonwidgets/itemcellchild_prefab", "NewItem"},
	}

	self.load_index = 0
	self.complete_index = 0
	self.loaded_callback = nil
end

function PreloadManager:__delete()
	if self.main_open_event then
		GlobalEventSystem:UnBind(self.main_open_event)
		self.main_open_event = nil
	end
	self.loaded_callback = nil
	PreloadManager.Instance = nil
end

function PreloadManager:GetLoadListCfg()
	return self.loadcfg
end

function PreloadManager:Start()
	self.complete = false
	self.total_count = #self.loadcfg
	PushCtrl(self)
end

function PreloadManager:WaitComplete(loaded_callback)
	if self.complete then
		loaded_callback(1)
	else
		self.loaded_callback = loaded_callback
	end
end

function PreloadManager:Update()
	if self.load_index < #self.loadcfg then
		for i = 1, 10 do
			self.load_index = self.load_index + 1
			if self.load_index <= #self.loadcfg then
				local cfg = self.loadcfg[self.load_index]

				if cfg[3] == TypeUnityMaterial then
					ResPoolMgr:GetMaterial(cfg[1], cfg[2], BindTool.Bind(self.OnLoadComplete, self, self.load_index), false)
				else
					ResPoolMgr:GetPrefab(cfg[1], cfg[2], BindTool.Bind(self.OnLoadComplete, self, self.load_index), false)
				end
			end
		end
	else
		PopCtrl(self)
	end
end

function PreloadManager:OnLoadComplete(load_index, prefab)
	self.complete_index = self.complete_index + 1
	if nil ~= self.loaded_callback then
		self.loaded_callback(self.complete_index / self.total_count)
	end

	if self.complete_index >= self.total_count then
		self.complete = true
		self.loaded_callback = nil
	end
end