TipShowTreasureView = TipShowTreasureView or BaseClass(BaseView)

local ROW = 10
local COLUMN = 5
local MAX_NUM = 80
local OFFTIME = 1

local PANEL_HEIGHT = {
	[1] = 550,
	[2] = 550,
	[3] = 550,
	[4] = 620,
	[5] = 700,
	[6] = 700,
	[7] = 700,
	[8] = 700,
}

local LIST_POSITON = {
	[1] = -190,
	[2] = -140,
	[3] = -90,
	[4] = -40,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 0,
}

local TREASURE_TYPE =
{
	XUNBAO = 1,
	JING_LING = 2,
	MOKA = 3,
	PET = 4,
	SWORD = 5,
	RUNE = 6,
	RUNE_BAOXIANG = 7,
	SHEN_GE_BLESS = 8,
	ERNIE_BLESS = 9,			-- 摇奖机
	NORMAL = 10,				-- 通用普通类型
	JINYINTA = 11,				-- 金银塔抽奖
	JINYINTA_REWARD = 12,		-- 金银塔累计抽奖
	SPIRIT_HOME_QUICK = 13,		-- 精灵家园加速
	GUAJITA_REWARD = 14,		-- 副本塔扫荡
    ZHUANZHUANLE = 15,			--转转乐抽奖
	ZHUANZHUANLE_REWARD = 16,	-- 转转乐累计抽奖
	PUSH_FB_STAR_REWARD = 17,	-- 推图星星奖励
	FANFANZHUAN = 18,			-- 翻翻转奖励
	LUCK_CHESS = 19,			-- 幸运棋奖励
	HAPPY_RECHARGE = 20,		-- 充值大乐透
	LUCKLY_TURNTABLE = 21,		-- 转盘
	WA_BAO = 22, 				-- 挖宝
	SYMBOL = 23, 				-- 元素之心
	SYMBOL_NIUDAN = 24, 		-- 元素之心扭蛋
	HUNQI_BAOZANG = 25,			--魂器宝藏
	LITTLE_PET = 26,			--小宠物
	
	Happy_Hit_Egg = 27,			-- 欢乐砸蛋
	ZHONGQIUHAPPYERNIE = 29,    --欢乐摇奖
	GuaGuaLe = 30, 				--刮刮乐
	MIJINGXUNBAO3 = 31,			--秘境寻宝
	HAPPYERNIE = 32,			--欢乐摇奖
	XIAOFEILINGJIANG = 33,		--消费领奖
	GENERAL = 34,				--变身请神
	LUCKYWISHING = 35,			--幸运许愿
	WEEKENDHAPPY = 36,			--周末狂欢
	SMALLHELPER = 37,			--小助手

	TIAN_SHENHUTI_BOX = 38,		--周末装备宝箱抽奖
	TIAN_SHENHUTI_GET_EQUIP = 99,-- 周末装备的合成和转化
	TIAN_SHENHUTI_GET_EQUIP_ONE_KEY = 100,	--周末装备一键合成
}

function TipShowTreasureView:__init()
	self.ui_config = {{"uis/views/tips/showtreasuretips_prefab", "ShowTreasureTips"}}
	TipShowTreasureView.Instance = self
	self.current_grid_index = -1
	self.chest_shop_mode = nil
	self.play_audio = true
	self.contain_cell_list = {}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.play_time = 0
end

function TipShowTreasureView:__delete()
	TipShowTreasureView.Instance = nil
end

function TipShowTreasureView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TreasureReward)
	end

	if self.play_quest_down then
		GlobalTimerQuest:CancelQuest(self.play_quest_down)
		self.play_quest_down = nil
	end

	for k, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
	self.show_toggle_list = nil
	self.show_one_btn = nil
end

function TipShowTreasureView:LoadCallBack()
	self.root_node:AddComponent(typeof(UnityEngine.CanvasGroup))
	self.contain_cell_list = {}
	self.list_view = self.node_list["list_view"]
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseTipsClick, self))
	self.node_list["BackWareHouseBtn"].button:AddClickListener(BindTool.Bind(self.OnBackWareHouseClick, self))
	self.node_list["BtnAgainBtn"].button:AddClickListener(BindTool.Bind(self.OnAgainClick, self))
	self.node_list["BtnOneBtn"].button:AddClickListener(BindTool.Bind(self.OneClick, self))

	self.show_toggle_list = {}
	for i = 1, 9 do
		self.show_toggle_list[i] = self.node_list["page_toggle_" .. i]
	end
	self:InitListView()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TreasureReward, BindTool.Bind(self.GetUiCallBack, self))
end

--判断能否播放动画
function TipShowTreasureView:IsPlayAni()

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 and MagicCardData.Instance:GetIsNoAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30 then
		return not TreasureData.Instance:GetIsShield()
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50) and SpiritData.Instance:IsNoPlayAni() then
		return false
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10) and RuneData.Instance:IsStopPlayAni() then
		return false
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10) and ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD	then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN	then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then 
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_10 then
		return not HunQiData.Instance:GetIsShield()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_30 then
		return not LuckWishingData.Instance:GetIsShield()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_10 then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_30 then
		return ZhuangZhuangLeData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_SCORE or self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_1 or self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_10 then
		return TianshenhutiData.Instance:GetPlayAniState()
	end
	return true
end

function TipShowTreasureView:CheckToPlayAni()
	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end
	if self:IsPlayAni() then
		self.star_ani = false
		self.root_node.transform:Find("Root"):GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 0
		self.node_list["BackWareHouseBtn"]:SetActive(false)
		self.node_list["BtnAgainBtn"]:SetActive(false)
		self.node_list["BtnOneBtn"]:SetActive(false)
		-- self.node_list["NodePageButtons"]:SetActive(false)
		self.node_list["NodeBlock"]:SetActive(true)
		-- --开始播放获取特效
		if self.play_quest_down == nil then
			self.play_quest_down = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.StartPlayEffect, self), 0.5)
		end
	else
		self.root_node.transform:Find("Root"):GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
		self.node_list["BackWareHouseBtn"]:SetActive(not self.show_one_btn)
		self.node_list["BtnAgainBtn"]:SetActive(not self.show_one_btn)
		self.node_list["BtnOneBtn"]:SetActive(self.show_one_btn)
		-- self.node_list["NodePageButtons"]:SetActive(true)
		self.node_list["NodeBlock"]:SetActive(false)
		local num = self:GetShowCount()
		local page = math.ceil(num / 10)
		self.node_list["Content"].transform.localPosition = Vector3(0, LIST_POSITON[page], 0)
		self.node_list["VictoryPanel"].rect.sizeDelta = Vector3(1092, PANEL_HEIGHT[page], 0)
		for k, v in pairs(self.contain_cell_list) do
			for i = 1, 10 do
				v:SetAlpha(i, 1)
			end
		end
	end
end

function TipShowTreasureView:OpenCallBack()
	self:ChangeBtnCount()
	self:SetTreasureType()
	self.node_list["page_toggle_1"]:SetActive(true)
	-- self.node_list["text_frame"].animator:SetBool("is_open", true)
	for i = 1, 9 do
		self.show_toggle_list[i]:SetActive(true)
	end
	local count = self:GetShowCount()
	local page = math.ceil(count / 10)
	-- if count <= 10 then
	-- 	self:SetToggleActiveFalse(1,9)
	-- elseif count > 10 and count <= 20 then
	-- 	self:SetToggleActiveFalse(3,9)
	-- elseif count > 20 and count <= 30 then
	-- 	self:SetToggleActiveFalse(4,9)
	-- elseif count > 30 and count <= 40 then
	-- 	self:SetToggleActiveFalse(5,9)
	-- elseif count > 40 and count <= 50 then
	-- 	self:SetToggleActiveFalse(6,9)
	-- elseif count > 50 and count <= 60 then
	-- 	self:SetToggleActiveFalse(7,9)
	-- elseif count > 60 and count <= 70 then
	-- 	self:SetToggleActiveFalse(8,9)
	-- elseif count > 70 and count <= 80 then
	-- 	self:SetToggleActiveFalse(9,9)
	-- end
	self.list_view.scroller:ReloadData(0)
	if self.treasure_type == TREASURE_TYPE.NORMAL then
		self.node_list["VictoryPanel"].rect.sizeDelta = Vector3(1092, 500, 0)
	else
		self.node_list["VictoryPanel"].rect.sizeDelta = Vector3(1092, PANEL_HEIGHT[page], 0)
	end

	self.node_list["TopPanel"]:SetActive(page < 5)
	self:CheckToPlayAni()
end

function TipShowTreasureView:OnFlush()
	self:SetTreasureType()
	self.node_list["page_toggle_1"]:SetActive(true)
	-- self.node_list["text_frame"].animator:SetBool("is_open", true)
	-- for i = 1, 9 do
	-- 	self.show_toggle_list[i]:SetActive(true)
	-- end
	local count = self:GetShowCount()
	-- if count <= 10 then
	-- 	self:SetToggleActiveFalse(1,9)
	-- elseif count > 10 and count <= 20 then
	-- 	self:SetToggleActiveFalse(3,9)
	-- elseif count > 20 and count <= 30 then
	-- 	self:SetToggleActiveFalse(4,9)
	-- elseif count > 30 and count <= 40 then
	-- 	self:SetToggleActiveFalse(5,9)
	-- elseif count > 50 and count <= 60 then
	-- 	self:SetToggleActiveFalse(7,9)
	-- elseif count > 60 and count <= 70 then
	-- 	self:SetToggleActiveFalse(8,9)
	-- elseif count > 70 and count <= 80 then
	-- 	self:SetToggleActiveFalse(9,9)
	-- end

	local servertime = TimeCtrl.Instance:GetServerTime()
	if servertime >= OFFTIME + self.play_time then
		for _, v in pairs(self.contain_cell_list) do
			v:SetIsNeedShowEffect(true)
		end
		self.play_time = servertime
	end
	self.list_view.scroller:ReloadData(0)
	local num = self:GetShowCount()
	local page = math.ceil(num / 10)
	self.node_list["TopPanel"]:SetActive(page < 5)
	self.node_list["Content"].transform.localPosition = Vector3(0, LIST_POSITON[page], 0)
	self.node_list["VictoryPanel"].rect.sizeDelta = Vector3(1092, PANEL_HEIGHT[page], 0)
end

function TipShowTreasureView:LoadEffect(item_num, group_cell, obj)
	if not obj then
		return
	end
	if not group_cell or group_cell:IsNil() then
		ResMgr:Destroy(obj)
		return
	end
	local transform = obj.transform
	transform:SetParent(group_cell:GetTransForm(item_num), false)
	local function Free()
		if IsNil(obj) then
			return
		end
		ResMgr:Destroy(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end

function TipShowTreasureView:PlayTime(group_cell, count, page, elapse_time, total_time)
	if not self:IsOpen() then
		return
	end

	if self.step >= count or elapse_time >= total_time then
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		local num = self:GetShowCount()
		if page < math.ceil(num / 10) then
			page = page + 1
			for k, v in pairs(self.contain_cell_list) do
				if v:GetPage() == page and not v:IsNil() and self.play_count_down == nil then
					--创建计时器分步显示item
					self.step = 0
					self.node_list["Content"].transform.localPosition = Vector3(0, LIST_POSITON[page], 0)
					local count = (num - (page - 1) * 10) % 10
					local last_count = count <= 10 and 10 or count
					self.play_count_down = CountDown.Instance:AddCountDown(10, 0.05, BindTool.Bind(self.PlayTime, self, v, last_count, page))
				end
			end
			return
		end
		self.node_list["BackWareHouseBtn"]:SetActive(not self.show_one_btn)
		self.node_list["BtnAgainBtn"]:SetActive(not self.show_one_btn)
		self.node_list["BtnOneBtn"]:SetActive(self.show_one_btn)
		-- self.node_list["NodePageButtons"]:SetActive(true)
		self.node_list["NodeBlock"]:SetActive(false)
		return
	end
	self.step = self.step + 1

	local item_num = self.step

	local async_loader = AllocAsyncLoader(self, "effect_loader_" .. self.step)
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
	async_loader:Load(bundle_name, 
		asset_name, 
		function(obj)
			if not IsNil(obj) then
				self:LoadEffect(item_num, group_cell, obj)
			end
		end)

	group_cell:SetAlpha(self.step, 1)
end

function TipShowTreasureView:StartPlayEffect()
	self.root_node.transform:Find("Root"):GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
	for k, v in pairs(self.contain_cell_list) do
		--只有第一页有动画
		local count = self:GetShowCount()
		for i = 1, 10 do
			v:SetAlpha(i, 0)
		end
		if v:GetPage() == 1 and not v:IsNil() and self.play_count_down == nil then
			--先隐藏item
			self.star_ani = true
			--创建计时器分步显示item
			self.step = 0
			local page = v:GetPage()
			local num = count > 10 and 10 or count
			self.node_list["Content"].transform.localPosition = Vector3(0, LIST_POSITON[page], 0)
			self.play_count_down = CountDown.Instance:AddCountDown(10, 0.05, BindTool.Bind(self.PlayTime, self, v, num, page))
		end
	end
	if not self.star_ani then
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		self.node_list["BackWareHouseBtn"]:SetActive(not self.show_one_btn)
		self.node_list["BtnAgainBtn"]:SetActive(not self.show_one_btn)
		self.node_list["BtnOneBtn"]:SetActive(self.show_one_btn)
		-- self.node_list["NodePageButtons"]:SetActive(true)
		self.node_list["NodeBlock"]:SetActive(false)
	end
	self.play_quest_down = nil
end

function TipShowTreasureView:GetTreasureType()
	return self.treasure_type
end

--是否只展示一个按钮
function TipShowTreasureView:ChangeBtnCount()
	self.show_one_btn = false
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		self.show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self.show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		self.show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self.show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD then
		self.show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE then
		self.show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE then
		self.show_one_btn = true
	end	

	-- if self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
	-- 	self.show_one_btn = true
	-- end

	if self.chest_shop_mode == CHEST_SHOP_MODE.WA_BAO then
		self.show_one_btn = true
	end


	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		self.show_one_btn = true
	end
end

function TipShowTreasureView:SetTreasureType()
	local btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
	local btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	self.node_list["BackWareHouseBtn"]:SetActive(true)
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30 then
		self.treasure_type = TREASURE_TYPE.XUNBAO
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50 then
		self.treasure_type = TREASURE_TYPE.JING_LING
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10 then
		self.treasure_type = TREASURE_TYPE.JING_LING
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		self.treasure_type = TREASURE_TYPE.MOKA
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		self.treasure_type = TREASURE_TYPE.MOKA
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		self.treasure_type = TREASURE_TYPE.MOKA
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PET_10 then
		self.treasure_type = TREASURE_TYPE.PET
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10 then
		self.treasure_type = TREASURE_TYPE.SWORD
		btn_text_1_value = Language.RechargeChouChouLe.Back
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 then
		self.treasure_type = TREASURE_TYPE.RUNE
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10 then
		self.treasure_type = TREASURE_TYPE.RUNE
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE then
		self.treasure_type = TREASURE_TYPE.RUNE_BAOXIANG
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		self.treasure_type = TREASURE_TYPE.GUAJITA_REWARD -- zcz
		btn_text_1_value = Language.RechargeChouChouLe.Sure
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 then
		self.treasure_type = TREASURE_TYPE.SHEN_GE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then
		self.treasure_type = TREASURE_TYPE.SHEN_GE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 then
		self.treasure_type = TREASURE_TYPE.ERNIE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10 then
		self.treasure_type = TREASURE_TYPE.ERNIE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 then
		self.treasure_type = TREASURE_TYPE.JINYINTA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10 then
		self.treasure_type = TREASURE_TYPE.JINYINTA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainThirty
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.JINYINTA_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_30 then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		self.treasure_type = TREASURE_TYPE.NORMAL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD then
		self.treasure_type = TREASURE_TYPE.SPIRIT_HOME_QUICK
		btn_text_2_value = Language.JingLing.AgainQuick
		btn_text_1_value = Language.Common.Confirm
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD then
		self.treasure_type = TREASURE_TYPE.PUSH_FB_STAR_REWARD
		btn_text_1_value = Language.RechargeChouChouLe.Sure
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.FANFANZHUAN
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.FANFANZHUAN
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
		btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.LUCK_CHESS
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.HAPPY_RECHARGE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.LUCKLY_TURNTABLE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.WA_BAO then
		self.treasure_type = TREASURE_TYPE.WA_BAO
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.SYMBOL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.SYMBOL_NIUDAN
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_1 then
		self.treasure_type = TREASURE_TYPE.HUNQI_BAOZANG
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_10 then
		self.treasure_type = TREASURE_TYPE.HUNQI_BAOZANG
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
		self.treasure_type = TREASURE_TYPE.LITTLE_PET
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		self.treasure_type = TREASURE_TYPE.LITTLE_PET
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.GuaGuaLe
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1) or (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10) or (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30) then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.HappyErnie.TreasureHunt[self.chest_shop_mode]
		self.treasure_type = TREASURE_TYPE.ZHONGQIUHAPPYERNIE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.HappyErnie.TreasureHunt[self.chest_shop_mode]
		self.treasure_type = TREASURE_TYPE.HAPPYERNIE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.MiJingXunBao3Text[self.chest_shop_mode]
		self.treasure_type = TREASURE_TYPE.MIJINGXUNBAO3
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.Happy_Hit_Egg
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.Happy_Hit_Egg
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.Happy_Hit_Egg
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_XIAOFEILINGJIANG_MODE_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.XIAOFEILINGJIANG
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50 then
		self.treasure_type = TREASURE_TYPE.GENERAL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_1 then
		btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.LUCKYWISHING
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.LUCKYWISHING	
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_1 then
		btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.WEEKENDHAPPY
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_10 then
		btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
		self.treasure_type = TREASURE_TYPE.WEEKENDHAPPY
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE then
		self.treasure_type = TREASURE_TYPE.SMALLHELPER
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_SCORE then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.TIAN_SHENHUTI_BOX
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_1 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.TIAN_SHENHUTI_BOX
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.TIAN_SHENHUTI_BOX
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GET_EQUIP then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.TIAN_SHENHUTI_GET_EQUIP
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GET_EQUIP_ONE_KEY then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.TIAN_SHENHUTI_GET_EQUIP_ONE_KEY
	end
	self.node_list["TxtBackWareHouse"].text.text = btn_text_1_value
	self.node_list["TxtAgainBtn"].text.text = btn_text_2_value
end

function TipShowTreasureView:GetData()
	local data = {}
	if self.treasure_type == TREASURE_TYPE.XUNBAO then
		data = TreasureData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.JING_LING then
		data = SpiritData.Instance:GetHuntSpiritItemList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.Happy_Hit_Egg then 					--欢乐砸蛋
		data = HappyHitEggData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.MOKA then
		data = MagicCardData.Instance:GetLottoData()--[index]
	elseif self.treasure_type == TREASURE_TYPE.XIAOFEILINGJIANG then 					--消费领奖
		data = ExpenseGiftData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKYWISHING then 						--幸运许愿
		data = LuckWishingData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.RUNE then
		data = RuneData.Instance:GetTreasureList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.RUNE_BAOXIANG then
		data = RuneData.Instance:GetBaoXiangList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.GUAJITA_REWARD then
		data = GuaJiTaData.Instance:GetAutoRewardData()--[index]
	elseif self.treasure_type == TREASURE_TYPE.MIJINGXUNBAO3 then 					--秘境寻宝
		data = SecretTreasureHuntingData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.SHEN_GE_BLESS then
		data = ShenGeData.Instance:GetShenGeBlessRewardDataList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.ERNIE_BLESS then
		data = ShengXiaoData.Instance:GetErnieBlessRewardDataList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.NORMAL then
		data = ItemData.Instance:GetNormalRewardList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA then
		data = JinYinTaData.Instance:GetLevelLotteryRewardList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA_REWARD then
		data = JinYinTaData.Instance:GetLeiJiRewardList()--[index - 1]
	elseif self.treasure_type == TREASURE_TYPE.WEEKENDHAPPY then
		data = WeekendHappyData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.SMALLHELPER then
		data = SmallHelperData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.SPIRIT_HOME_QUICK then
		local cfg = SpiritData.Instance:GetQuickGetList()
		if cfg ~= nil and cfg.item_list ~= nil then
			if cfg.item_list[41] ~= nil then
				table.remove(cfg.item_list, 41)
			end
			data = cfg.item_list--[index]
		end
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE then
		data = ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()--[index]
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE_REWARD then
		local seq = ZhuangZhuangLeData.Instance:GetLinRewardSeq()
		data = ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)--[index]

	elseif self.treasure_type == TREASURE_TYPE.PUSH_FB_STAR_REWARD then
		data = FuBenData.Instance:GetPushFbFetchShowStarReward()--[index]
	elseif self.treasure_type == TREASURE_TYPE.FANFANZHUAN then
		data = FanFanZhuanData.Instance:GetTreasureItemList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCK_CHESS then
		data = LuckyChessData.Instance:GetTreasureViewShowList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.HAPPY_RECHARGE then
		data = HappyRechargeData.Instance:GetRewardListInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKLY_TURNTABLE then
		data = HefuActivityData.Instance:GetRollResult()--[index]

	elseif self.treasure_type == TREASURE_TYPE.WA_BAO then
		data = WaBaoData.Instance:GetRewardItems()--[index] or {}
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL then
		data = SymbolData.Instance:GetElementProductListInfo()--[index] or {}
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL_NIUDAN then
		data = SymbolData.Instance:GetElementHeartRewardList()--[index] or {}
	elseif self.treasure_type == TREASURE_TYPE.HUNQI_BAOZANG then
		data = ItemData.Instance:GetNormalRewardList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.LITTLE_PET then
		data = LittlePetData.Instance:GetChouJiangRewardDataList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.HAPPYERNIE then 					--欢乐摇奖
		data = HappyErnieData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.ZHONGQIUHAPPYERNIE then 				--欢乐摇奖
		data = KaifuActivityData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.GuaGuaLe then 					--刮刮乐
		data = ScratchTicketData.Instance:GetChestShopItemInfo()--[index]
	elseif self.treasure_type == TREASURE_TYPE.GENERAL then
		data = BianShenData.Instance:GetItemList()--[index]
	elseif self.treasure_type == TREASURE_TYPE.TIAN_SHENHUTI_BOX then
		data = TianshenhutiData.Instance:GetBoxChouJiangResult()
	elseif self.treasure_type == TREASURE_TYPE.TIAN_SHENHUTI_GET_EQUIP then
		data = TianshenhutiData.Instance:GetTianshenhutiResult()
	elseif self.treasure_type == TREASURE_TYPE.TIAN_SHENHUTI_GET_EQUIP_ONE_KEY then
		data = TianshenhutiData.Instance:GetTianshenhutiOneKeyResult()
	end
	-- local separate_data = {}
	-- for k,v in pairs(data) do
	-- 	if v and v.num > 1 then
	-- 		if ItemData.Instance:GetItemIsInVirtual(v.item_id) then
	-- 			table.insert(separate_data, v)
	-- 		else
	-- 			for i = 1, v.num do
	-- 				local temp_data = TableCopy(v)
	-- 				temp_data.num = 1
	-- 				table.insert(separate_data, temp_data)
	-- 			end
	-- 		end
	-- 	elseif v and v.item_id > 0 then
	-- 		table.insert(separate_data, v)
	-- 	end
	-- end
	return data
end

function TipShowTreasureView:GetShowCount()
	local count = 0
	if self.treasure_type == TREASURE_TYPE.JING_LING then
		count = #SpiritData.Instance:GetHuntSpiritItemList()
	elseif self.treasure_type == TREASURE_TYPE.XUNBAO then
		count = #TreasureData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.MOKA then
		count = #MagicCardData.Instance:GetLottoData()
	elseif self.treasure_type == TREASURE_TYPE.Happy_Hit_Egg then 				--欢乐砸蛋
		count = #HappyHitEggData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.XIAOFEILINGJIANG then 				--消费领奖
		count = #ExpenseGiftData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.LUCKYWISHING then 						--幸运许愿
		count = #LuckWishingData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.RUNE then
		count = #RuneData.Instance:GetTreasureList()
	elseif self.treasure_type == TREASURE_TYPE.RUNE_BAOXIANG then
		count = #RuneData.Instance:GetBaoXiangList()
	elseif self.treasure_type == TREASURE_TYPE.GUAJITA_REWARD then
		count = #GuaJiTaData.Instance:GetAutoRewardData()
	elseif self.treasure_type == TREASURE_TYPE.MIJINGXUNBAO3 then 				--秘境寻宝
		count = #SecretTreasureHuntingData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.SHEN_GE_BLESS then
		count = #ShenGeData.Instance:GetShenGeBlessRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.ERNIE_BLESS then
		count = #ShengXiaoData.Instance:GetErnieBlessRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.NORMAL then
		count = #ItemData.Instance:GetNormalRewardList()
	elseif self.treasure_type == TREASURE_TYPE.HUNQI_BAOZANG then
		count = #ItemData.Instance:GetNormalRewardList()
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA then
		count = #JinYinTaData.Instance:GetLevelLotteryRewardList()
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA_REWARD then
		count = #JinYinTaData.Instance:GetLeiJiRewardList()
	elseif self.treasure_type == TREASURE_TYPE.SPIRIT_HOME_QUICK then
		local cfg = SpiritData.Instance:GetQuickGetList()
		if cfg ~= nil and cfg.item_list ~= nil then
			count = #cfg.item_list >= 40 and 40 or #cfg.item_list
		end
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE then
		count = #ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE_REWARD then
		local seq = ZhuangZhuangLeData.Instance:GetLinRewardSeq()
		count = #ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)
	elseif self.treasure_type == TREASURE_TYPE.PUSH_FB_STAR_REWARD then
		local seq = FuBenData.Instance:GetPushFbFetchShowStarReward()
		count = #ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)
	elseif self.treasure_type == TREASURE_TYPE.FANFANZHUAN then
		count = #FanFanZhuanData.Instance:GetTreasureItemList()
	elseif self.treasure_type == TREASURE_TYPE.LUCK_CHESS then
		count = #LuckyChessData.Instance:GetTreasureViewShowList()
	elseif self.treasure_type == TREASURE_TYPE.HAPPY_RECHARGE then
		count = #HappyRechargeData.Instance:GetRewardListInfo()
	elseif self.treasure_type == TREASURE_TYPE.LUCKLY_TURNTABLE then
		count = #HefuActivityData.Instance:GetRollResult()
	elseif self.treasure_type == TREASURE_TYPE.WA_BAO then
		count = #WaBaoData.Instance:GetRewardItems()
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL then
		count = #SymbolData.Instance:GetElementProductListInfo()
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL_NIUDAN then
		count = #SymbolData.Instance:GetElementHeartRewardList()
	elseif self.treasure_type == TREASURE_TYPE.LITTLE_PET then
		count = #LittlePetData.Instance:GetChouJiangRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.HAPPYERNIE then 				--欢乐摇奖
		count = #HappyErnieData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.ZHONGQIUHAPPYERNIE then 				--欢乐摇奖
		count = #KaifuActivityData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.GuaGuaLe then 				--刮刮乐
		count = #ScratchTicketData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.WEEKENDHAPPY then
		count = #WeekendHappyData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.SMALLHELPER then
		count = #SmallHelperData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.GENERAL then
		count = #BianShenData.Instance:GetItemList()
	elseif self.treasure_type == TREASURE_TYPE.TIAN_SHENHUTI_BOX then
		count = #TianshenhutiData.Instance:GetBoxChouJiangResult()
	elseif self.treasure_type == TREASURE_TYPE.TIAN_SHENHUTI_GET_EQUIP then
		count = #TianshenhutiData.Instance:GetTianshenhutiResult()
	elseif self.treasure_type == TREASURE_TYPE.TIAN_SHENHUTI_GET_EQUIP_ONE_KEY then
		count = #TianshenhutiData.Instance:GetTianshenhutiOneKeyResult()
	end

	-- count = #self:GetData() or 0
	return count
end

-- function TipShowTreasureView:SetToggleActiveFalse(first,the_end)
-- 	local page = first - 1
-- 	page = page < 1 and 1 or page
-- 	self.page = page
-- 	self.list_view.list_page_scroll:SetPageCount(page)
-- 	for i=first,the_end do
-- 		self.show_toggle_list[i]:SetActive(false)
-- 	end
-- end

function TipShowTreasureView:SetCloseCallBack(call_back)
	self.close_call_back = call_back
end

function TipShowTreasureView:GetPageCount()
	return self.page or 0
end

function TipShowTreasureView:CloseCallBack()
	self.show_toggle_list[1].toggle.isOn = true--重置toggle的显示
	SpiritData.Instance:ClearData()
	TreasureData.Instance:ClearData()
	self.current_grid_index = nil
	-- self.node_list["text_frame"].animator:SetBool("is_open", false)
	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end
	for _, v in pairs(self.contain_cell_list) do
		v:SetPage(0)
		v:SetIsNeedShowEffect(true)
	end

	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function TipShowTreasureView:SetChestMode(chest_shop_mode)
	self.chest_shop_mode = chest_shop_mode
end

function TipShowTreasureView:InitListView()
	self.list_view = self.node_list["list_view"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipShowTreasureView:GetNumberOfCells()
	local count = self:GetShowCount()
	local show_count = 0
	if count <= 10 then
		show_count = 1
	elseif count > 10 and count <= 20 then
		show_count = 2
	elseif count > 20 and count <= 30 then
		show_count = 3
	elseif count > 30 and count <= 40 then
		show_count = 4
	elseif count > 40 and count <= 50 then
		show_count = 5
	elseif count > 50 and count <= 60 then
		show_count = 6
	elseif count > 60 and count <= 70 then
		show_count = 7
	elseif count > 70 and count <= 80 then
		show_count = 8
	elseif count > 80 and count <= 90 then
		show_count = 9
	end
	return show_count
end

function TipShowTreasureView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShowTreasureContain.New(cell.gameObject)
		contain_cell.parent_view = self
		self.contain_cell_list[cell] = contain_cell
	end

	--改变排列方式
	-- contain_cell:ChangeLayoutGroup()

	local page = cell_index + 1
	contain_cell:SetPage(page)
	for i = 1, ROW do
		local index = page * 10 - (ROW - i)
		local data = nil
		data = self:GetData()[index] or {}

		contain_cell:SetToggleGroup(i, self.list_view.toggle_group)
		contain_cell:SetData(i, data)
		--contain_cell:ShowHighLight(i, next(data) ~= nil)
		contain_cell:ListenClick(i, BindTool.Bind(self.OnClickItem, self, contain_cell, i, index, data))
	end
end

function TipShowTreasureView:GetCurrentGridIndex()
	return self.current_grid_index
end

function TipShowTreasureView:SetCurrentGridIndex(current_grid_index)
	self.current_grid_index = current_grid_index
end

function TipShowTreasureView:OnCloseTipsClick()
	self:Close()
end

function TipShowTreasureView:OnBackWareHouseClick()
	self:Close()

	if self.chest_shop_mode >= CHEST_SHOP_MODE.CHEST_SHOP_MODE_MAX then
		return
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1 or
   		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10 or
   		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50 or
   		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_1 or
   		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_30 or 
		-- self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 or
		-- self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_1 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_10 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
		ViewManager.Instance:Open(ViewName.TipsTreasureWarehouseView)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30 then
		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then

		self:Close()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		ViewManager.Instance:Open(ViewName.LittlePetWarehouseView)	--跳到小宠物仓库
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1 
			or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10 
			or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50 then
		ViewManager.Instance:Open(ViewName.BianShenWarehouseView)
		self:Close()
	else
		SpiritCtrl.Instance.spirit_view:OpenWarehouse()
	end
end

function TipShowTreasureView:OneClick()
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self:Close()
	end
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SMALL_HELPER_MODE then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.WA_BAO then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_SCORE then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_1 then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_10 then
		self:Close()
	end

end

function TipShowTreasureView:OnAgainClick()
	self.show_toggle_list[1].toggle.isOn = true
	local delay_function = function ()
		if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)

		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE1_30, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
			HefuActivityData.Instance:SetLucklyTurnClick(true)
			HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL, CSA_ROLL_OPERA.CSA_ROLL_OPERA_ROLL)
			if not HefuActivityData.Instance:GetLucklyTurnToggle() then
				self:Close()
			end

		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30 then
			TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30)
			TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE2_30, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP2) 
				----------------------------------------------------------欢乐砸蛋-------------------------------------------------------------------------
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_10)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_30)
			----------------------------------------------------------刮刮乐------------------------------------------------------------------
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1 then
			ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_ONE_TIME)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10 then
			ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_TEN_TIMES)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50 then
			ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_THIRTY_TIMES)

		-- 仙宠猎取抽取仙宠
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 then
			SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10 then
			SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50 then
			SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)

		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1 then
			local other_cfg = BianShenData.Instance:GetOtherCfg()
			BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_1_DRAW, self:CheckIsAutoBuy(other_cfg.draw_1_item_id))
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10 then
			local other_cfg = BianShenData.Instance:GetOtherCfg()
			BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_10_DRAW, self:CheckIsAutoBuy(other_cfg.draw_10_item_id))
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50 then
			local other_cfg = BianShenData.Instance:GetOtherCfg()
			BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_50_DRAW, self:CheckIsAutoBuy(other_cfg.draw_50_item_id))

		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 then
			if MagicCardData.Instance:GetBagCardNum() <= 120 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,1)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 then
			if MagicCardData.Instance:GetBagCardNum() <= 115 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,5)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 then
			if MagicCardData.Instance:GetBagCardNum() <= 110 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,10)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 then
			if MagicCardData.Instance:GetBagCardNum() <= 120 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,1)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 then
			if MagicCardData.Instance:GetBagCardNum() <= 115 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,5)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 then
			if MagicCardData.Instance:GetBagCardNum() <= 110 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,10)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 then
			if MagicCardData.Instance:GetBagCardNum() <= 120 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,1)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 then
			if MagicCardData.Instance:GetBagCardNum() <= 115 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,5)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 then
			if MagicCardData.Instance:GetBagCardNum() <= 110 then
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,10)
				MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PET_10 then
			PetAchieveView.Instance:OnTenClick()
			----------------------------------------------------------欢乐摇奖-------------------------------------------------------------------------
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_1 then
			HappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_1)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPYERNIE, RA_HUANLE_YAOJIANG_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_TYPE_TAO, RA_HAPPYERNIE_CHOU_TYPE.RA_HAPPYERNIE_CHOU_TYPE_1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_10 then
			HappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_10)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPYERNIE, RA_HUANLE_YAOJIANG_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_TYPE_TAO, RA_HAPPYERNIE_CHOU_TYPE.RA_HAPPYERNIE_CHOU_TYPE_10)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_30 then
			HappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_30)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPYERNIE, RA_HUANLE_YAOJIANG_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_TYPE_TAO, RA_HAPPYERNIE_CHOU_TYPE.RA_HAPPYERNIE_CHOU_TYPE_30)
			
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_XIAOFEILINGJIANG_MODE_10 then
			ExpenseGiftData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_XIAOFEILINGJIANG_MODE_10)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL_TEN)
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_GIFT, RA_CONSUM_GIFT_OPERA_TYPE.RA_CONSUM_GIFT_OPERA_TYPE_ROLL_REWARD_TEN)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_1 then
			LuckWishingCtrl.Instance:SendAllInfoReq(RA_LUCKY_WISH_OPERA_TYPE.RA_LUCKY_WISH_OPERA_TYPE_WISH, 1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_30 then
			LuckWishingCtrl.Instance:SendAllInfoReq(RA_LUCKY_WISH_OPERA_TYPE.RA_LUCKY_WISH_OPERA_TYPE_WISH, 30)
			--秘境寻宝
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1 then
			SecretTreasureHuntingData.Instance:SetChestShopModeByTreasureView(CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1)
			SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10 then
			SecretTreasureHuntingData.Instance:SetChestShopModeByTreasureView(CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10)
			SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_10)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30 then
			SecretTreasureHuntingData.Instance:SetChestShopModeByTreasureView(CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30)
			SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_30)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1 then
			SwordArtOnlineView.Instance:SetLottoType(CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1)
			MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,SwordArtOnlineView.Instance:GetCurSelectIndex(),3)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1 then
			SwordArtOnlineView.Instance:SetLottoType(CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1)
			MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,SwordArtOnlineView.Instance:GetCurSelectIndex(),1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10 then
			SwordArtOnlineView.Instance:SetLottoType(CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10)
			MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,SwordArtOnlineView.Instance:GetCurSelectIndex(),2)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 then
			local other_cfg = RuneData.Instance:GetOtherCfg()
			local item_id = other_cfg.xunbao_consume_itemid
			local one_consume_num = other_cfg.xunbao_one_consume_num
			local num = ItemData.Instance:GetItemNumInBagById(item_id)
			if num >= one_consume_num then
				--物品充足
				local type = RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE
				self:RuneAutoAnaly(one_consume_num, type)
			else
				--物品不足
				local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
				if not shop_data then
					return
				end
				local function ok_callback()
					local type = RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE
					self:RuneAutoAnaly(one_consume_num, type, 1)
				end
				local differ_num = one_consume_num - num
				local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
				local color = item_cfg.color or 1
				local color_str = ITEM_COLOR[color]
				local name = item_cfg.name or ""
				local cost = shop_data.gold * differ_num
				local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
				TipsCtrl.Instance:ShowCommonAutoView("rune_one_xunbao", des, ok_callback)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10 then
			local other_cfg = RuneData.Instance:GetOtherCfg()
			local item_id = other_cfg.xunbao_consume_itemid
			local ten_consume_num = other_cfg.xunbao_ten_consume_num
			local num = ItemData.Instance:GetItemNumInBagById(item_id)
			if num >= ten_consume_num then
				--物品充足
				local type = RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN
				self:RuneAutoAnaly(ten_consume_num, type)
			else
				--物品不足
				local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
				if not shop_data then
					return
				end
				local function ok_callback()
					local type = RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN
					self:RuneAutoAnaly(10, type, 1)
				end
				local differ_num = ten_consume_num - num
				local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
				local color = item_cfg.color or 1
				local color_str = ITEM_COLOR[color]
				local name = item_cfg.name or ""
				local cost = shop_data.gold * differ_num
				local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
				TipsCtrl.Instance:ShowCommonAutoView("rune_ten_xunbao", des, ok_callback)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE then -- zcz 再来一次
			local item_id = RuneData.Instance:GetBaoXiangId()
			local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
			if have_num > 0 then
				RuneData.Instance:SetBaoXiangId(item_id)
				local index = ItemData.Instance:GetItemIndex(item_id)
				PackageCtrl.Instance:SendUseItem(index, 1)
			else
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				if item_cfg then
					local des = string.format(Language.Rune.NumNotEnough, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
					SysMsgCtrl.Instance:ErrorRemind(des)
				end
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1)
			if not ShenGeData.Instance:GetBlessAniState() then
				return
			end
			self:Close()
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10)
			if not ShenGeData.Instance:GetBlessAniState() then
				return
			end	
			self:Close()
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 0)
			if not ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
				self:Close()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10 then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 1)
			if not ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
				self:Close()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 then
			-- 抽一次之前的层级
	 		local old_level = JinYinTaData.Instance:GetLotteryCurLevel()
	 		JinYinTaData.Instance:SetOldLevel(old_level)
	 		-- 玩家钻石数量
			local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
			local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
			-- 刷新抽奖励需要的钻石数
			local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
			if role_gold >= need_gold then
				local bags_grid_num = ItemData.Instance:GetEmptyNum()
		 		if bags_grid_num > 0 then
		 			JinYinTaData.Instance:SetPlayNotClick(false)
		 		end
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_ONE)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10 then
			local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
			-- 刷新抽奖励需要的钻石数
			local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
			local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
			local bags_grid_num = ItemData.Instance:GetEmptyNum()

			-- 有足够的钻石
			if role_gold >= need_gold or bags_grid_num > 0 then
				JinYinTaData.Instance:SetTenNotClick(false)
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_THIRTY)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD then
			local cfg = SpiritData.Instance:GetQuickGetList()
			if cfg ~= nil and cfg.index ~= nil then
				local spirit_data = SpiritData.Instance:GetSpiritHomeInfoByIndex(cfg.index)
				if spirit_data ~= nil and spirit_data.reward_times ~= nil then
					local limlit_time = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit") or 0
					if spirit_data.reward_times >= limlit_time then
						SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritHomeQuickLimlit)
						self:Close()
						return
					end
				end
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_QUICK, main_role_vo.role_id, cfg.index - 1)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_30 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,30)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 then
			local cur_level = FanFanZhuanData.Instance:GetCurLevel()
			local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
			if randact_cfg == nil or next(randact_cfg) == nil then return end
			local gold = 0
			if cur_level == 0 then
				gold = randact_cfg.other[1].king_draw_chuji_once_gold
			elseif cur_level == 1 then
				gold = randact_cfg.other[1].king_draw_zhongji_once_gold
			elseif cur_level == 2 then
				gold = randact_cfg.other[1].king_draw_gaoji_once_gold
			end
			local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
			if role_gold >= gold * 10 then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 10)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 then
			local cur_level = FanFanZhuanData.Instance:GetCurLevel()
			local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
			if randact_cfg == nil or next(randact_cfg) == nil then return end

			local gold = 0
			if cur_level == 0 then
				gold = randact_cfg.other[1].king_draw_chuji_once_gold
			elseif cur_level == 1 then
				gold = randact_cfg.other[1].king_draw_zhongji_once_gold
			elseif cur_level == 2 then
				gold = randact_cfg.other[1].king_draw_gaoji_once_gold
			end

			local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
			local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
			local is_auto_use_item = cur_level == 2 and item_num > 0
			-- 有足够的钻石
			if role_gold >= gold * 50 or is_auto_use_item then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 50)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP,
															RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 30)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_1 then
			if ItemData.Instance:GetEmptyNum() >= 1 then
				HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
					RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 1)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_10 then
			if ItemData.Instance:GetEmptyNum() >= 10 then
				HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
					RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 10)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
			if ItemData.Instance:GetEmptyNum() >= 10 then
				SymbolCtrl.Instance:SendChoujiangElementHeartReqAgain()
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Tips.BeiBaoYiMan)
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_1 then
			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, 1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_1 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY, RA_LOTTERY_1_OPERA_TYPE.RA_LOTTERY_1_OPERA_TYPE_DO_LOTTERY, 1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_Weekend_HAPPY_MODE_10 then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY, RA_LOTTERY_1_OPERA_TYPE.RA_LOTTERY_1_OPERA_TYPE_DO_LOTTERY, 2)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_10 then
			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, 10)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
			local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
			local param1 = LITTLE_PET_CHOUJIANG_TYPE.ONE
			LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1)
			if LittlePetData.Instance:GetChouJiangAniState() then
				self:Close()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
			local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
			local param1 = LITTLE_PET_CHOUJIANG_TYPE.TEN
			LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1)
			if LittlePetData.Instance:GetChouJiangAniState() then
				self:Close()
			end
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1 then
			KaifuActivityData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO, RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10 then
			KaifuActivityData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO, RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_10)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30 then
			KaifuActivityData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO, RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_30)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_SCORE then
			TianshenhutiCtrl.SendTianshenhutiRoll(1)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_1 then
			TianshenhutiCtrl.SendTianshenhutiRoll(2)
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.TIAN_SHEN_HUTI_BOX_GOID_10 then
			TianshenhutiCtrl.SendTianshenhutiRoll(3)
		end
	end

	if self:IsPlayAni() then
		self:Close()
		GlobalTimerQuest:AddDelayTimer(function ()
			delay_function()
		end, 0.3)
		-- if self.play_count_down then
		-- 	CountDown.Instance:RemoveCountDown(self.play_count_down)
		-- 	self.play_count_down = nil
		-- end
		-- if self.play_quest_down == nil then
		-- 	self.play_quest_down = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.StartPlayEffect, self), 0.5)
		-- end
	else
		delay_function()
	end
end

function TipShowTreasureView:RuneAutoAnaly(num, type, index)
	local count = RuneData.Instance:GetBagNum()
	if count < num then
		local des = Language.Rune.describe
		local function dis_callback()
			local list_data = RuneData.Instance:GetAnalyList()
			local data_list = {}
			for k, v in ipairs(list_data) do
				if v.type == GameEnum.RUNE_JINGHUA_TYPE or v.quality == 0 or v.quality == 1 then
					if not data_list[v.index] then
						data_list[v.index] = v
					end
				end
			end

			if not next(data_list) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Rune.NotSelectRune)
				return
			end

			local tbl = {}
			for k, v in pairs(data_list) do
				table.insert(tbl, k)
			end
			SortTools.SortAsc(tbl)
			local max_count = #tbl
			RuneCtrl.Instance:SendOneKeyAnalyze(max_count, tbl)
			RuneCtrl.Instance:RuneSystemReq(type, index)
		end
		TipsCtrl.Instance:ShowCommonAutoView("rune_ten", des, dis_callback, nil,nil, nil, nil, nil, true)
	else
		RuneCtrl.Instance:RuneSystemReq(type, index)
	end
end

function TipShowTreasureView:SetToggleActive(is_on)
	for k,v in pairs(self.contain_cell_list) do
		v:SetToggleActive(self.current_grid_index, is_on)
	end
end

function TipShowTreasureView:OnClickItem(group, group_index, index, data)
	local item_cfg, _ = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg and item_cfg.use_type and item_cfg.use_type == GameEnum.TIANSHENHUTI_EQUIP_USE_TYPE then  -- 周末装备的显示处理
		local equip_cfg = TianshenhutiData.Instance:GetEquipCfgByItemId(data.item_id)
		if not equip_cfg then return end
		local item_data = {}
		item_data.item_id = equip_cfg.item_id
		item_data.suit_id = equip_cfg.equip_id
		item_data.index = data.index
		TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.FROM_TIANSHENHUTI_EQUIP)
	else
		self.current_grid_index = index
		if group_index then
			group:SetToggle(group_index, index == self.current_grid_index)
			local close_call_back = function()
				group:SetToggle(group_index, false)
			end
			TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)
		end
	end
end

function TipShowTreasureView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.BackWarehouseBtn then
		if self.node_list["BackWareHouseBtn"] then
			return self.node_list["BackWareHouseBtn"], BindTool.Bind(self.OnBackWareHouseClick, self)
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function TipShowTreasureView:CheckIsAutoBuy(item_id)
	return TipsCommonBuyView.AUTO_LIST[item_id] and 1 or 0
end

----------------------------------------------------------
ShowTreasureContain = ShowTreasureContain  or BaseClass(BaseCell)

function ShowTreasureContain:__init()
	self.parent_view = nil
	self.treasure_contain_list = {}
	for i = 1, 10 do
		self.treasure_contain_list[i] = GiftItemCell.New(self.node_list["item_" .. i])
	end
end

function ShowTreasureContain:__delete()
	self.parent_view = nil
	for k, v in pairs(self.treasure_contain_list) do
		v:DeleteMe()
	end
	self.treasure_contain_list = {}
end

function ShowTreasureContain:SetPage(page)
	self.page = page
end

function ShowTreasureContain:GetPage()
	return self.page
end

function ShowTreasureContain:SetToggleGroup(i, toggle_group)
	self.treasure_contain_list[i]:SetToggleGroup(toggle_group)
end

function ShowTreasureContain:SetData(i, data)
	self.treasure_contain_list[i]:SetData(data)
	-- if self.page == 1 then
		self.treasure_contain_list[i]:PlayEffect()
	-- end
end

function ShowTreasureContain:SetIsNeedShowEffect(is_need_show_effect)
	for k,v in pairs(self.treasure_contain_list) do
		v:SetIsNeedShowEffect(is_need_show_effect)
	end
end

function ShowTreasureContain:ListenClick(i, handler)
	self.treasure_contain_list[i]:ListenClick(handler)
end

function ShowTreasureContain:ShowHighLight(i, enable)
	self.treasure_contain_list[i]:ShowHighLight(enable)
end

function ShowTreasureContain:SetToggle(i, enable)
	if self.treasure_contain_list and self.treasure_contain_list[i] then
		self.treasure_contain_list[i]:SetToggle(enable)
	end
end

function ShowTreasureContain:SetAlpha(i, value)
	self.treasure_contain_list[i]:SetAlpha(value)
end

function ShowTreasureContain:GetTransForm(i)
	return self.treasure_contain_list[i]:GetTransForm()
end

-- --改变排列方式
-- function ShowTreasureContain:ChangeLayoutGroup()
-- 	if self.parent_view then
-- 		local page_count = self.parent_view:GetPageCount()
-- 		local enum = 0
-- 		if page_count > 1 then
-- 			enum = UnityEngine.TextAnchor.UpperLeft
-- 		else
-- 			enum = UnityEngine.TextAnchor.MiddleCenter
-- 		end
-- 		self.root_node.grid_layout_group.childAlignment = enum
-- 	end
-- end

----------------------------------------------------------
GiftItemCell = GiftItemCell  or BaseClass(BaseRender)

function GiftItemCell:__init()
	self.treasure_item = ItemCell.New()
	self.treasure_item:SetFromView(TipsFormDef.FROM_XUNBAO_QUCHU)
	self.treasure_item:SetInstanceParent(self.node_list["item"])
	self.is_need_show_effect = true
end

function GiftItemCell:PlayEffect()
	if self.is_need_show_effect then
		self.is_need_show_effect = false
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
		self.node_list["item"]:SetActive(false)
		self.node_list["item"]:SetActive(true)
		EffectManager.Instance:PlayAtTransform(
			bundle_name,
			asset_name,
			self.node_list["item"].transform,
			OFFTIME, Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), Vector3(0.5, 0.5, 0.5))
	end
end

function GiftItemCell:SetIsNeedShowEffect(is_need_show_effect)
	self.is_need_show_effect = is_need_show_effect
end

function GiftItemCell:GetLocalPos(Obj)
	if Obj.transform ~= nil then
		return 
	end
end

function GiftItemCell:__delete()
	if self.treasure_item then
		self.treasure_item:DeleteMe()
	end
	self.treasure_item = nil
	self.is_need_show_effect = true
end

function GiftItemCell:SetToggleGroup(toggle_group)
	self.treasure_item:SetToggleGroup(toggle_group)
end

function GiftItemCell:SetData(data)
	if not next(data) then
		self:SetActive(false)
	else
		self:SetActive(true)
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if TipShowTreasureView.Instance:GetTreasureType() == TREASURE_TYPE.SWORD then
		if not next(data) then
			return
		end
		self.node_list["ImgSwordBG"]:SetActive(true)
		self.node_list["ImgSword"]:SetActive(true)
		local star_str = "star_bg_"..data.star_count
		self.node_list["ImgSwordBG"].image:LoadSprite("uis/views/swordartonline",star_str .. ".png")
		  local sword_str = "sword_" .. data.res_id
		self.node_list["ImgSword"].image:LoadSprite("uis/views/swordartonline",sword_str .. ".png")
	else
		self.node_list["ImgSwordBG"]:SetActive(false)
		self.node_list["ImgSword"]:SetActive(false)
		self.treasure_item:SetData(data)
		if item_cfg then
			if item_cfg.color == GameEnum.ITEM_COLOR_ORANGE then
				self.treasure_item:ShowZhuanzhiEquipOrangeEffect(true)
			end
		end

	end
end

function GiftItemCell:ListenClick(handler)
	self.treasure_item:ListenClick(handler)
end

function GiftItemCell:ShowHighLight(enable)
	self.treasure_item:ShowHighLight(enable)
end

function GiftItemCell:SetToggle(enable)
	self.treasure_item:SetToggle(enable)
end

function GiftItemCell:SetAlpha(value)
	if self.root_node.canvas_group and not IsNil(self.root_node.canvas_group) then
		self.root_node.canvas_group.alpha = value
	end
end

function GiftItemCell:IsNil()
	return not self.root_node or not self.root_node.gameObject.activeInHierarchy
end

function GiftItemCell:GetTransForm()
	return self.root_node.transform
end

