KuafuGuildCollectTaxesView = KuafuGuildCollectTaxesView or BaseClass(BaseView)

local Max_Type_Count = 6
local Max_Item_Count = 3

-- index对应配表的索引转换
local IndexChange = 
{
	[1] = 1, -- 火
	[2] = 0, -- 皇
	[3] = 2, -- 金
	[4] = 3, -- 木
	[5] = 4, -- 水
	[6] = 5, -- 土
}

-- index对应领取标志的索引转换
local IndexChange_2 = 
{
	[1] = 2,
	[2] = 1,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
}


function KuafuGuildCollectTaxesView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/kuafuliujie_prefab", "GuildCollectTaxes"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.cur_index = 1
	self.data_list = {}
	self.item_list = {}
end

function KuafuGuildCollectTaxesView:__delete()

end

function KuafuGuildCollectTaxesView:ReleaseCallBack()
	self.data_list = {}
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function KuafuGuildCollectTaxesView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(946, 590, 0)
	self.node_list["Txt"].text.text = Language.GuildBattle.CollectTaxesLog

	self:InitData()
	self:CreateTypeList()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnTaxes"].button:AddClickListener(BindTool.Bind(self.OnClickToGetReward, self))

end

-- 初始化Data
function KuafuGuildCollectTaxesView:InitData()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	if info and info.kf_battle_list then
		self.data_list = TableCopy(info.kf_battle_list)
	end
end

-- 检查是否可以收税
function KuafuGuildCollectTaxesView:CheckCanGetReward()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	local my_guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local is_get_reward = false
	if nil == next(info) and info.kf_battle_list == nil then return end

	self.data_list = TableCopy(info.kf_battle_list)

	for k, v in pairs(self.data_list) do 
		if v.guild_id == my_guild_id and my_guild_id ~= 0 then
			is_get_reward = info.daily_reward_flag[33 - IndexChange_2[k]] ~= 1
			if is_get_reward then
				self.cur_index = k
				return
			end
		end
	end

	self.cur_index = 2
end

-- 根据索引检查是否可以收税
function KuafuGuildCollectTaxesView:CheckCanGetRewardByIndex(index)
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	local my_guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local is_get_reward = false
	local can_get_reward = false
	if nil == next(info) and info.kf_battle_list == nil then return end

	self.data_list = TableCopy(info.kf_battle_list)
	can_get_reward = self.data_list[index].guild_id == my_guild_id and my_guild_id ~= 0
	is_get_reward = info.daily_reward_flag[33 - IndexChange_2[index]] == 1

	return can_get_reward , is_get_reward
end


-- 设置当前可以收税城的奖励
function KuafuGuildCollectTaxesView:SetRewardItem(index)
	local cfg = KuafuGuildBattleData.Instance:GetDailtyReward(IndexChange[index]).reward_item
	-- local list = ItemData.Instance:GetGiftItemList(cfg[1].item_id)
	for i = 1, Max_Item_Count do
		if self.item_list[i] == nil then
			self.item_list[i] = ItemCell.New()
			self.item_list[i]:SetShowOrangeEffect(true)
			self.item_list[i]:SetInstanceParent(self.node_list["NodeItem" .. i])
		end
		if cfg[i - 1] then
			self.item_list[i]:SetData(cfg[i - 1])
			self.item_list[i]:SetParentActive(true)
		else
			self.item_list[i]:SetParentActive(false)
		end
	end
end

function KuafuGuildCollectTaxesView:OpenCallBack()
	self:Flush()
end

function KuafuGuildCollectTaxesView:CreateTypeList()
	for i = 1, Max_Type_Count do
		self.node_list["TypeToggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickRankType, self, i))
	end
end

--点击排行榜回调
function KuafuGuildCollectTaxesView:OnClickRankType(index)

	if nil == index then
		return
	end
	self.cur_index = index   -- list回调
	self:SetRewardItem(self.cur_index)
	self:FlushRewardPanel()
end

function KuafuGuildCollectTaxesView:OnFlush()

	self:CheckCanGetReward()
	self:SetRewardItem(self.cur_index)

	self.node_list["TypeToggle" .. self.cur_index].toggle.isOn = true
	if IndexChange_2[self.cur_index] == 1 then
		self.node_list["LeftList"].scroll_rect.normalizedPosition = Vector2(0, 1)
	elseif IndexChange_2[self.cur_index] == Max_Type_Count then
		self.node_list["LeftList"].scroll_rect.normalizedPosition = Vector2(0, 0)
	else
		self.node_list["LeftList"].scroll_rect.normalizedPosition = Vector2(0, 1 - (IndexChange_2[self.cur_index] / Max_Type_Count))
	end
	self:FlushRewardPanel()

	for i = 1 ,6 do
		local is_show_redpoint = KuafuGuildBattleData.Instance:IsShowTaxesItemRedPoint(i)
		self.node_list["RedPoint" .. IndexChange_2[i]]:SetActive(is_show_redpoint)
	end
end

function KuafuGuildCollectTaxesView:FlushRewardPanel()
	local index = IndexChange_2[self.cur_index]
	self.node_list["TxtDesc"].text.text = string.format(Language.GuildBattle.FieldOccupy,Language.RecordRank.TaxesPlace[index])

	local can_get_reward, is_get_reward = self:CheckCanGetRewardByIndex(self.cur_index)

	self.node_list["TxtRemind"]:SetActive(can_get_reward)
	self.node_list["TxtNoOccupy"]:SetActive(not can_get_reward)

	if can_get_reward and is_get_reward then
		self.node_list["TxtTaxes"].text.text = Language.PersonalGoal.HasFetch
	elseif can_get_reward and not is_get_reward then
		self.node_list["TxtTaxes"].text.text = Language.PersonalGoal.Fetch
	elseif not can_get_reward then
		self.node_list["TxtTaxes"].text.text = Language.PersonalGoal.Fetch
	end

	UI:SetButtonEnabled(self.node_list["BtnTaxes"], can_get_reward and not is_get_reward)
end


function KuafuGuildCollectTaxesView:OnClickToGetReward()
	local can_get_reward, is_get_reward = self:CheckCanGetRewardByIndex(self.cur_index)
	if can_get_reward and is_get_reward then
		TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.RewardHasGet)
	elseif can_get_reward and not is_get_reward then
		KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_GET_DAILY_REWARD, IndexChange[self.cur_index])
	end

end

