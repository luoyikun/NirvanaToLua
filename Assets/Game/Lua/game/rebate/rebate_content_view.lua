RebateContentView = RebateContentView or BaseClass(BaseRender)

function RebateContentView:__init(instance)
	RebateContentView.Instance = self
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
	self.node_list["invest_btn"].button:AddClickListener(BindTool.Bind(self.OnGoClick, self))
	self.item_list = {}
	local item_info_list = RebateData.Instance:GetGiftInfoList()
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
		self.item_list[i]:SetShowOrangeEffect(true)
		self.item_list[i]:SetData(item_info_list[i])
	end

	UI:SetGraphicGrey(self.node_list["invest_btn"], not (RebateCtrl.Instance.is_buy))
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	local data = RebateData.Instance:GetBaiBeiItemCfg()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local res_id = RebateData.Instance:GetFashionResId((main_role_vo.prof % 10) .. main_role_vo.sex, data.index, SHIZHUANG_TYPE.BODY)
	local weapon_res_id = RebateData.Instance:GetFashionResId((main_role_vo.prof % 10) .. main_role_vo.sex, data.index_2, SHIZHUANG_TYPE.WUQI)
	if weapon_res_id then
		if (main_role_vo.prof % 10) == GameEnum.ROLE_PROF_3 then
			local weapon_param_t = Split(weapon_res_id, ",")
			self.model:SetWeaponResid(weapon_param_t[1])
			self.model:SetWeapon2Resid(weapon_param_t[2])
		else
			self.model:SetWeaponResid(weapon_res_id)
		end
	end
	if res_id then
		self.model:SetMainAsset(ResPath.GetRoleModel(res_id))
		self.model:ShowRest()
	end
	
	if self.fight_text and self.fight_text.text and data and data.power then
		self.fight_text.text.text = data.power
	end

	self:Flush()
end

function RebateContentView:OnFlush()
	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
	local count_down_time = RebateCtrl.Instance:GetCloseTime() - TimeCtrl.Instance:GetServerTime()
	if count_down_time > 0 then
		local time = TimeUtil.FormatSecond(count_down_time, 10)		
		self.node_list["TimeText"].text.text = Language.Activity.ActivityTime7 .. "<color=#89f201>" .. time .. "</color>"
	else
		self.node_list["TimeText"].text.text = ""
		ViewManager.Instance:Close(ViewName.RebateView)
	end
	if self.count_down_timer == nil and count_down_time > 0 then
		self.count_down_timer = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.UpdateTimerCallback, self), BindTool.Bind(self.CompleteTimerCallback, self))
	end	
end

function RebateContentView:UpdateTimerCallback(elapse_time, total_time)
	if self.node_list and self.node_list["TimeText"] and self.node_list["TimeText"].text and self.node_list["TimeText"].text.text then
		local time = TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 10)
		self.node_list["TimeText"].text.text = Language.Activity.ActivityTime7 .. "<color=#89f201>" .. time .. "</color>"
	end
end

function RebateContentView:CompleteTimerCallback()
	if self.node_list and self.node_list["TimeText"] and self.node_list["TimeText"].text and self.node_list["TimeText"].text.text then
		self.node_list["TimeText"].text.text = ""
		ViewManager.Instance:Close(ViewName.RebateView)
	end
end

function RebateContentView:__delete()
	self.node_list["TxtInvestBtn"] = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.fight_text = nil

	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function RebateContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function RebateContentView:OnGoClick()
	local price = RebateData.Instance:GetBaiBeiItemCfg().baibeifanli_price
	local level_limit = RebateData.Instance:GetBaiBeiItemCfg().baibeifanli_level_limit
	local role_money = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	local func = function ()
		if role_money >= price then
			if role_level >= level_limit then
				if bags_grid_num >= 4 then
					RebateCtrl.Instance:SendBaiBeiFanLiBuy()
					UI:SetGraphicGrey(self.node_list["invest_btn"], false)
					UI:SetGraphicGrey(self.node_list["TxtInvestBtn"], false)
					RebateCtrl.Instance.is_buy = false
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
				end
			else
				TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.BuyNeedLevle, level_limit))
			end
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.RebateTips, price))
end

function RebateContentView:SetModelState()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local vect = Vector3(0, 0, 0)
	if main_role_vo.prof == GameEnum.ROLE_PROF_1 then
		vect = Vector3(0, 0, 0)
	elseif main_role_vo.prof == GameEnum.ROLE_PROF_2 then
		vect = Vector3(0, 0, 0)
	elseif main_role_vo.prof == GameEnum.ROLE_PROF_3  then
		vect = Vector3(0, 0, 0)
	elseif main_role_vo.prof == GameEnum.ROLE_PROF_4 then
		vect = Vector3(0, -45, 0)
	else
		vect = Vector3(0, 0, 0)
	end
	self.model:SetRotation(vect)
	self.model:SetBool("fight", true)
end
