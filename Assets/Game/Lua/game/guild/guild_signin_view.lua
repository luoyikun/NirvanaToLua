GuildSigninView = GuildSigninView or BaseClass(BaseView)

function GuildSigninView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/guildview_prefab", "GuildSigninView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.title_id = 4004
end

function GuildSigninView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(800,512,0)
	self.node_list["AfterBtn"].button:AddClickListener(BindTool.Bind(self.OnClickSignin, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.Guild.PanelName


	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.node_list["reward_cell"])



	-- 格子创建
	--获取组件
	self.item_list = {}
	self.text_limit_list = {}
	for i = 1, GuildData.SigninRewardNum do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["item_cell_" .. i])
		item:SetData(nil)
		table.insert(self.item_list, item)
		item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		self.text_limit_list[i] = self.node_list["BoxAmount" .. i]
	end
end

function GuildSigninView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.text_limit_list = {}

	self.reward_cell = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTittle"])
end

function GuildSigninView:CloseCallBack()

end

function GuildSigninView:OpenCallBack()
	GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_ALL_INFO)
	self:Flush()
end

function GuildSigninView:OnFlush()
	-- 格子数据刷新
	local signin_cfg = GuildData.Instance:GetSigninCfg()
	local last_data_cfg = signin_cfg[#signin_cfg] or {}
	local signin_data = GuildData.Instance:GetSigninData()
	local signin_title_cfg = GuildData.Instance:GetSigninTitleOneCfg(signin_data.signin_count_month)
	for i = 1, GuildData.SigninRewardNum do
		local data_index = i - 1
		local data = signin_cfg[data_index]
		local cell = self.item_list[i]
		cell:SetData(data.reward_item)
		self.text_limit_list[i].text.text = string.format(Language.Guild.NeedPeople, data.need_count)

		-- 格子根据状态不同做不同的显示
		cell:ShowGetEffect(false)
		cell:ShowHasGet(false)
		local get_reward_state = GuildData.Instance:GetSigninRewardState(data.index)
		if get_reward_state == GuildData.SinginRewardState.CanGetReward then
			cell:ShowGetEffect(true)
		elseif get_reward_state == GuildData.SinginRewardState.HasGetReward then
			cell:ShowHasGet(true)
		end
	end

	-- 当前签到进度
	local max_limit = last_data_cfg.need_count
	self.node_list["TextPro"].text.text = string.format(Language.Guild.GuildSigninNum, signin_data.guild_signin_count_today .. "/" .. max_limit)

	--累计签到
	self.node_list["TextTodayDay"].text.text = string.format(Language.Guild.GuildSigninLieji, signin_data.signin_count_month)

	-- 称号显示
	self.node_list["TextTittle"].text.text = signin_title_cfg.name


	-- 进度条刷新(每段大小不是平均的，但显示上要平均，故需要分段显示)
	-- 当前处于进度条阶段
	local cur_grade_cfg, last_grade_cfg = GuildData.Instance:GetCurAndLastSigninGrade()
	if next(cur_grade_cfg) then
		local cur_grade = cur_grade_cfg.index
		local one_grade_percent = 1 / GuildData.SigninRewardNum
		local laset_cfg_need_count = last_grade_cfg.need_count or 0
		-- 当前所处阶段的比例 + 每小段所处的比例
		local percent = cur_grade * one_grade_percent + (signin_data.guild_signin_count_today - laset_cfg_need_count) / (cur_grade_cfg.need_count - laset_cfg_need_count) * one_grade_percent
		self.node_list["progress"].slider:DOValue(percent, 0.5, false)
	else
		-- 取不到配置 表示进度条已满
		self.node_list["progress"].slider:DOValue(1, 0.5, false)
	end

	-- 签到奖励格子
	local personal_reward = GuildData.Instance:GetPersonalSigninReward()
	self.reward_cell:SetData(personal_reward)
	UI:SetButtonEnabled(self.node_list["AfterBtn"], signin_data.is_signin_today <= 0)

	local text = nil
	if signin_data.is_signin_today <= 0 then
		text = Language.Guild.Signin
	else
		text = Language.Guild.HasSignin
	end

	self.node_list["TextSignIn"].text.text = text

	-- 称号展示
	local bundle, asset = ResPath.GetTitleIcon(self.title_id)
	self.node_list["ImgTittle"].image:LoadSprite(bundle, asset .. ".png")
	TitleData.Instance:LoadTitleEff(self.node_list["ImgTittle"], self.title_id, true)

	local title_cfg = TitleData.Instance:GetTitleCfg(self.title_id)
	self.node_list["TextTittleCap"].text.text = CommonDataManager.GetCapability(title_cfg)
end

function GuildSigninView:OnClickSignin()
	GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_TYPE_SIGNIN)
end

function GuildSigninView:ItemClick(cell_index)
	local data_index = cell_index - 1

	local get_reward_state = GuildData.Instance:GetSigninRewardState(data_index)
	if get_reward_state == GuildData.SinginRewardState.CanGetReward then
		GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_TYPE_FETCH_REWARD, data_index)
	else
		local cell = self.item_list[cell_index]
		ItemCell.OnClickItemCell(cell)
	end
end