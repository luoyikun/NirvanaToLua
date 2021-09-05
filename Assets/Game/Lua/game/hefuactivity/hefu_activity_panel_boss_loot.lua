BossLoot = BossLoot or BaseClass(BaseRender)

local NEED_KILL_BOSS_NUM = 3

function BossLoot:__init()
end

function BossLoot:__delete()
	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.is_show_list = {}
	self.item_cell_obj_list = {}

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function BossLoot:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	self.kill_boss_count = HefuActivityData.Instance:GetKillBossCount()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
	self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS)
	self.node_list["TxtLastTime"].text.text = TimeUtil.FormatSecond(rest_time, 13)--self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self.node_list["TxtLastTime"].text.text = TimeUtil.FormatSecond(rest_time, 13)--self:SetTime(rest_time)
		end)

	self.is_show_list = {}
	self.item_cell_list = {}
	self.item_cell_obj_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self.node_list["CellItem_" .. i]
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
		self.is_show_list[i] = self.node_list["CellItem_" .. i]
	end

	self.reward_info = HefuActivityData.Instance:GetBoosLootRewardInfo()
	local reward_list = ItemData.Instance:GetItemConfig(self.reward_info.item_id)
	if nil == reward_list.item_1_id then
		self.item_cell_list[1]:SetData({item_id = reward_list.id , num = 1, is_bind = 1})
		self.is_show_list[1]:SetActive(true)
		for i = 2, 4 do
			self.is_show_list[i]:SetActive(false)
		end
	else
		for i = 1, 4 do
			local reward_item_list = {}
			if nil == reward_list["item_" .. i .. "_id"] then
				self.is_show_list[i]:SetActive(false)
			else
				self.is_show_list[i]:SetActive(true)
				reward_item_list[i] = {
				item_id = reward_list["item_" .. i .. "_id"],
				num = reward_list["item_" .. i .. "_num"],
				is_bind = reward_list["is_bind_" .. i],}
				self.item_cell_list[i]:SetData(reward_item_list[i])
			end
		end
	end

	self.node_list["BtnLingqu"].button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnHelpClick, self))
	self.node_list["BtnGotoKill"].button:AddClickListener(BindTool.Bind(self.ClickGoFight, self))

	local kill_text = self.kill_boss_count ~= 3 and string.format(Language.Common.ShowRedStr, self.kill_boss_count) or self.kill_boss_count
	self.node_list["SliderProgress"].slider.value = self.kill_boss_count / 3
	KaifuActivityData.Instance:OutLineRichText(self.kill_boss_count, 3, self.node_list["TxtHaveLoot"], 1)
	--self.node_list["TxtHaveLoot"].text.text = string.format(Language.HefuActivity.Boss, kill_text)
	self.node_list["TxtLeijiKill"].text.text = self.kill_boss_count
	self.node_list["Effect"]:SetActive(self.kill_boss_count >= 3)
end

function BossLoot:SetTime(rest_time)
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	-- local temp = {}
	-- for k,v in pairs(time_tab) do
	-- 	if k ~= "day" then
	-- 		if v < 10 then
	-- 			v = tostring('0' .. v)
	-- 		end
	-- 	end
	-- 	temp[k] = v
	-- end
	-- str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min ,temp.s)
	-- if temp.day < 0 then
	-- 	str = string.format("%02d:%02d:%02d", time_tab.hour, time_tab.min, time_tab.s)
	-- end
	local str = TimeUtil.FormatSecond(rest_time, 13)
	return str
end

function BossLoot:OnFlush()
	self.kill_boss_count = HefuActivityData.Instance:GetKillBossCount()
	local kill_text = self.kill_boss_count ~= 3 and string.format(Language.Common.ShowRedStr, self.kill_boss_count) or self.kill_boss_count
	self.node_list["SliderProgress"].slider.value = self.kill_boss_count / 3
	KaifuActivityData.Instance:OutLineRichText(self.kill_boss_count, 3, self.node_list["TxtHaveLoot"], 1)
	self.node_list["TxtLeijiKill"].text.text = self.kill_boss_count
	self.node_list["Effect"]:SetActive(self.kill_boss_count >= NEED_KILL_BOSS_NUM)
	--self.node_list["BtnLingqu"]:SetActive(self.kill_boss_count  == NEED_KILL_BOSS_NUM)
	UI:SetButtonEnabled(self.node_list["BtnLingqu"], self.kill_boss_count >= NEED_KILL_BOSS_NUM)
end

function BossLoot:ClickGetReward()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS)
end

function BossLoot:OnHelpClick()
	local tips_id = 324
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossLoot:ClickGoFight()
	HefuActivityCtrl.Instance.view:Close()
	ViewManager.Instance:OpenByCfg("Boss#miku_boss")
end