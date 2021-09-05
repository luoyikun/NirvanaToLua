KuafuLiuJieInfoView = KuafuLiuJieInfoView or BaseClass(BaseRender)
local MAX_CITY_NUM = 6
local READY_TIME = 120

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


function KuafuLiuJieInfoView:__init()

	
end

function KuafuLiuJieInfoView:LoadCallBack()
	self.item_list ={}
	for i = 1, MAX_CITY_NUM do
		self.item_list[i] = KuafuGuildItemRender.New(self.node_list["ImgCityTitle" .. i])
		self.node_list["PlaceName" .. i].text.text = Language.RecordRank.PlaceName[i]
		self.item_list[i]:SetIndex(i)
	end

	self.node_list["CrossBtn"].button:AddClickListener(BindTool.Bind(self.OnEnterCross, self))
	self.node_list["DescBtn"].button:AddClickListener(BindTool.Bind(self.ClickKfBattleDesc, self))
	self.node_list["BattleBtn"].button:AddClickListener(BindTool.Bind(self.ClickKuafuGuildBattle, self))
	self.node_list["TaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTask, self))
	self.node_list["DrawBtn"].button:AddClickListener(BindTool.Bind(self.OnClickDraw, self))
	self.node_list["BtnTaxes"].button:AddClickListener(BindTool.Bind(self.OnClickTaxesView, self))
	self.node_list["JiTiReward"].button:AddClickListener(BindTool.Bind(self.ClickJiTiReward, self))
	self:InitData()

end

function KuafuLiuJieInfoView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.rewards_list) do
		v:DeleteMe()
	end
	
	self.rewards_list = {}
	self.item_list = nil
end

function KuafuLiuJieInfoView:InitData()
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.KF_GUILDBATTLE)
	if act_info then
		-- local time_des = ActivityData.Instance:GetChineseWeek(act_info) or ""
		local text = ActivityData.Instance:GetLimintOpenDayTextByActId(ACTIVITY_TYPE.KF_GUILDBATTLE, act_info)
		self.node_list["TipsTxt"].text.text = string.format(Language.KuafuGuildBattle.KfBattleTip, text)
	end
	self.rewards_list = {}

	-- local cfg = KuafuGuildBattleData.Instance:GetReward()
	-- local list = ItemData.Instance:GetGiftItemList(cfg.item_id)
	local act_id = ACTIVITY_TYPE.KF_GUILDBATTLE
	local act_info = ActivityData.Instance:GetActivityInfoById(act_id)
	if act_info then
		-- local length = #list
		local tab_list = Split(act_info.item_label, ":")
		for i = 1, 4 do
			local item_cell = ItemCell.New()
			item_cell:SetShowOrangeEffect(true)
			item_cell:SetInstanceParent(self.node_list["CellRewards"])
			-- item_cell:SetData(list[i])
			if tab_list[i] then
				tab_list[i] = tonumber(tab_list[i])
			end
			if act_info["reward_item" .. i] and act_info["reward_item" .. i].item_id > 0 then
				item_cell:SetData(act_info["reward_item" .. i])
				item_cell:SetActive(true)
				if tab_list[i]then
					item_cell:SetShowZhuanShu(tab_list[i] == 1)
				end
			else
				item_cell:SetActive(false)
			end
			table.insert(self.rewards_list,item_cell)
		end
	end
end

function KuafuLiuJieInfoView:ClickKfBattleDesc()
	local tips_id = 224
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuafuLiuJieInfoView:ClickKuafuGuildBattle()
	KuafuGuildBattleCtrl.Instance:OpenRecordPanle()
end

function KuafuLiuJieInfoView:ClickJiTiReward()
	local activity_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.KF_GUILDBATTLE)
	if activity_cfg and activity_cfg.team_reward_item then
		local team_main_reward_list = {}
		for i = 1, activity_cfg.team_reward_item[0].num do
			team_main_reward_list[i] = {item_id = activity_cfg.team_reward_item[0].item_id, num = 1, is_bind = activity_cfg.team_reward_item[0].is_bind}
		end
		local team_other_reward_list = {{item_id = activity_cfg.team_reward_item[0].item_id, num = 1, is_bind = activity_cfg.team_reward_item[0].is_bind}}
		TipsCtrl.Instance:OpenJiTiRewardTip(team_main_reward_list, team_other_reward_list, ACTIVITY_TYPE.KF_GUILDBATTLE)
	end
end

function KuafuLiuJieInfoView:OnClickDraw()
	ViewManager.Instance:Open(ViewName.ShenShou, TabIndex.shenshou_huanling)
end

function KuafuLiuJieInfoView:OnClickTaxesView()
	ViewManager.Instance:Open(ViewName.KuafuGuildCollectTaxesView)
end

-- 进入跨服帮派战
function KuafuLiuJieInfoView:OnEnterCross()
	-- 背包满了不让进
	-- local empty_num = ItemData.Instance:GetEmptyNum()
	-- if empty_num == 0 then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.BagRemind)
	-- 	return
	-- end
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE)  or ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_GUILDBATTLE)
	local is_limit_flag = true
	if TimeCtrl.Instance:GetCurOpenServerDay() > 5 then
		is_limit_flag = ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.KF_GUILDBATTLE)
	end
	if is_open and is_limit_flag then
		KuafuGuildBattleData.Instance:SetEnterType(LIUJIE_ENTER_TYPE.LIUJIE_ENTER)
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_GUILDBATTLE, KuafuGuildBattleData.Instance:GetSceneIdByIndex())
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.KuafuGuildBattle.NotOpen)
	end
end

function KuafuLiuJieInfoView:OnClickTask()
	ViewManager.Instance:Open(ViewName.KuafuTaskRecordView)
end

function KuafuLiuJieInfoView:OnFlush()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	local residue_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.KF_GUILDBATTLE)

	if self.item_list and info and info.kf_battle_list then
		local data_list = TableCopy(info.kf_battle_list)
		for i,v in ipairs(self.item_list) do
			v:SetData(data_list[i])
		end
	end

	local active_flag = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE) or (ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_GUILDBATTLE) and (residue_time <= READY_TIME))
	local is_limit_flag = true
	if TimeCtrl.Instance:GetCurOpenServerDay() > 5 then
		is_limit_flag = ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.KF_GUILDBATTLE)
	end
	self.node_list["NodeEffect"]:SetActive(active_flag and is_limit_flag)
	self.node_list["NodeBtnEffect"]:SetActive(active_flag and is_limit_flag)
	self.node_list["TxtBattleField"]:SetActive(active_flag and is_limit_flag)
	self.node_list["TipsTxt"]:SetActive(not (active_flag and is_limit_flag))
	self.node_list["CrossBtn"]:SetActive(active_flag and is_limit_flag)

	local score = ShenShouData.Instance:GetHuanLingScore()
	self.node_list["ScoreTxt"].text.text = string.format(Language.XiuLuo.Score, score)
	self.node_list["taskImg"]:SetActive(KuafuGuildBattleData.Instance:HasGuildBattleTask() > 0)

	local can_get_reward = KuafuGuildBattleData.Instance:CheckCanCollectTaxes()
	self.node_list["BtnTaxes"].animator.enabled = false
	self.node_list["ImgTaxRedPoint"]:SetActive(can_get_reward)
end

--------------------------KuafuGuildItemRender------------------------------
KuafuGuildItemRender = KuafuGuildItemRender or BaseClass(BaseRender)
function KuafuGuildItemRender:LoadCallBack()
	self.index = 0
	self.node_list["MapImg"].toggle:AddClickListener(BindTool.Bind(self.OnImgBoxHandler, self))
	self.node_list["LIujieImg"].button:AddClickListener(BindTool.Bind(self.OnImgBoxHandler, self))
	-- self.node_list["CityReward"].button:AddClickListener(BindTool.Bind(self.OnClickToGetReward, self))
	self.server_id = GameVoManager.Instance:GetMainRoleVo().server_id
end

function KuafuGuildItemRender:__delete()

end

function KuafuGuildItemRender:OnClickToGetReward()

	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	local is_get_reward = info.daily_reward_flag[33 - IndexChange_2[self.index]] == 1
	local my_guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if self.data ~= nil and next(self.data) then 
		if self.data.guild_id > 0 and my_guild_id ~= 0 then
			if self.data.guild_id == my_guild_id and not is_get_reward then 
				KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_GET_DAILY_REWARD, IndexChange[self.index])
			elseif self.data.guild_id == my_guild_id and is_get_reward then
				TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.RewardHasGet)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.OccupyFirst)
			end
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.OccupyFirst)
		end
	end
end


function KuafuGuildItemRender:OnImgBoxHandler()
	--领主界面地图不可点击
	local flag_bool = KuafuGuildBattleData.Instance:GetGuildRewardFlag(self.data.index)

	local data = KuafuGuildBattleData.Instance:GetOwnReward(self.data.index - 1)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id or 0
	local post = GuildData.Instance:GetGuildPost(main_role_id)
	local reward_list = {}
	local last_reward_list = {}
	if data then
		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
			if data.guild_boss_reward_item then
				for k,v in pairs(data.guild_boss_reward_item) do
					table.insert(reward_list, v)
				end
			end
		else
			if data.guild_reward_item then
				for k,v in pairs(data.guild_reward_item) do
					table.insert(reward_list, v)
				end
			end
		end
		for i = 1,3 do
			if reward_list[i] then
				last_reward_list[i - 1] = reward_list[i]
			end
		end
		local act_type = ACTIVITY_TYPE.KF_FAKE_LIUJIE
		TipsCtrl.Instance:OpenRewardTip(last_reward_list, false, nil, false, data.title_name, self.data.index, act_type)
	end
end

function KuafuGuildItemRender:OnFlush()
	if not self:IsOpen() then
		return
	end

	if nil == self.data then return end
	if self.data.guild_id > 0 then 
		self.node_list["TxtNor"].text.text = string.format(Language.KuafuGuildBattle.KfGuildMengzhu, self.data.guild_tuanzhang_name)
		self.node_list["Txt"].text.text = string.format(Language.KuafuGuildBattle.KfGuildServe, self.data.guild_name, self.data.server_id)
		self.node_list["ImgShadow"]:SetActive(true)
		-- 如果是同一个服的公会占领那么显示同样区块颜色
		if self.server_id == self.data.server_id then
			self.node_list["ImgShadow"].image.color = Color.New(255, 230, 0, 130) 		--(255, 230, 0, 130)(1, 0.90, 0, 0.51)
		else
			self.node_list["ImgShadow"].image.color = Color.New(1, 0.76, 0.76, 1)			--(255, 0, 0, 130)(1, 0, 0, 0.51)
		end
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if self.node_list["Flag"] and self.node_list["Flag"].SetActive then
			self.node_list["Flag"]:SetActive(self.data.guild_id == vo.guild_id)
		end
	else
		self.node_list["TxtNor"].text.text = Language.KuafuGuildBattle.KfNoOccupy
		if self.node_list["Flag"] and self.node_list["Flag"].SetActive then
			self.node_list["Flag"]:SetActive(false)
		end
		self.node_list["Txt"].text.text = Language.KuafuGuildBattle.KfNoOccupy

		if self.node_list["ImgShadow"] and self.node_list["ImgShadow"].SetActive then
			self.node_list["ImgShadow"]:SetActive(false)
		end
		self.node_list["ImgShadow"].image.color = Color.New(255, 255, 255, 255)			--(255, 255, 255, 255)(1, 1, 1, 1)
		-- if self.node_list["CityReward"].animator then
		-- 	self.node_list["CityReward"].animator.enabled = false
		-- end
	end
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	local is_get_reward = info.daily_reward_flag[33 - IndexChange_2[self.index]] == 1
	local my_guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id

	-- if self.node_list["CityReward"] and self.node_list["CityReward"].SetActive then
	-- 	self.node_list["CityReward"]:SetActive(false)
	-- end

	-- if self.data.guild_id > 0 and my_guild_id ~= 0 then 
	-- 	if self.data.guild_id == my_guild_id and not is_get_reward then
	-- 		self.node_list["CityReward"].image:LoadSprite("uis/views/kuafuliujie/images_atlas", "box_close")
	-- 		self.node_list["CityReward"].animator.enabled = true
	-- 		self.node_list["CityReward"]:SetActive(true)
	-- 	elseif self.data.guild_id == my_guild_id and is_get_reward then
	-- 		self.node_list["CityReward"].image:LoadSprite("uis/views/kuafuliujie/images_atlas", "box_open")
	-- 		self.node_list["CityReward"].animator.enabled = false
	-- 		self.node_list["CityReward"]:SetActive(true)
	-- 	end
	-- end


	local this_bool = KuafuGuildBattleData.Instance:GetCurItemIsthisServer(self.data.index)
	-- local str = this_bool and "kf_this_occupy" or "kf_he_occupy"

	local flag_bool = KuafuGuildBattleData.Instance:GetGuildRewardFlag(self.data.index)
	local str = 1 

	local is_guild_bool = KuafuGuildBattleData.Instance:GetIsGuildOwn(self.data.index)	
end

function KuafuGuildItemRender:SetData(data)
	self.data = data
	self:Flush()
end

function KuafuGuildItemRender:GetIndex()
	return self.index
end

function KuafuGuildItemRender:SetIndex(index)
	self.index = index
end