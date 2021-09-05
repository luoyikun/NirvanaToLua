CityContend = CityContend or BaseClass(BaseRender)
-- ³ÇÖ÷Õù¶á
local Max_Reward_Num = 2

function CityContend:__delete()
	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.winner_id = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
end

function CityContend:OpenCallBack()
	self.main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	self.other_cfg = CityCombatData.Instance:GetOtherConfig()
	self.cz_fashion_yifu_id = self.other_cfg.cz_fashion_yifu_id
	self.yifu_item_data = ItemData.Instance:GetItemConfig(self.cz_fashion_yifu_id)
	self.gcz_chengzhu_reward, self.gcz_camp_reward = HefuActivityData.Instance:GetCityContendRewardInfo()

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)

	self.node_list["BtnGoToAttack"].button:AddClickListener(BindTool.Bind(self.ClickFight, self))
	self.item_cell_list = {}

	for i = 1, Max_Reward_Num do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["CellItem" .. i])
	end
	self.item_cell_list[1]:SetData(self.gcz_chengzhu_reward)
	self.item_cell_list[2]:SetData(self.gcz_camp_reward)
	local bundle, asset = ResPath.GetTitleIcon(self.other_cfg.cz_chenghao)
	self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
	TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], self.other_cfg.cz_chenghao, true)
	self.winner_id = HefuActivityData.Instance:GetCityContendWinnerInfo()
	if self.winner_id ~= 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.winner_id)
		self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))
	else
		self:FlushModel()
	end
end

function CityContend:FlushTuanZhangModel(role_id, role_info)
	if role_id == self.winner_id then
		self.node_list["TxtWinName"].text.text = role_info.role_name
		self:FlushModel(role_info)
	end
end

function CityContend:FlushModel(role_info)
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.node_list["DisplayModel"].ui3d_display)
	end

	local role_vo = {}

	if nil ~= role_info then
		role_vo.prof = role_info.prof
		role_vo.sex = role_info.sex
	else
		role_vo.prof = self.main_role_vo.prof
		role_vo.sex = self.main_role_vo.sex
	end

	role_vo.appearance = {}
	role_vo.appearance.fashion_wuqi = 1
	role_vo.appearance.fashion_body = self.yifu_item_data.param2
	self.model:SetModelResInfo(role_vo, true, true, true, true)
end

function CityContend:SetTime(rest_time)
	local time_str = ""
	if rest_time > 3600 * 24 then
		time_str = ToColorStr(TimeUtil.FormatSecond(rest_time, 6), TEXT_COLOR.GREEN_4)
	else
		time_str = ToColorStr(TimeUtil.FormatSecond(rest_time, 0), TEXT_COLOR.GREEN_4)
	end
	self.node_list["TxtRestTime"].text.text = string.format(Language.HefuActivity.ActLastTime, time_str)
end

function CityContend:OnFlush()
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.winner_id)
	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))
end

function CityContend:ClickFight()
	HefuActivityCtrl.Instance.view:Close()
	ViewManager.Instance:Open(ViewName.CityCombatView)
end