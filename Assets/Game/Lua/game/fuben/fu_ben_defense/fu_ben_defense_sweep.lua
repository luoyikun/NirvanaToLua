DefenseSweepView = DefenseSweepView or BaseClass(BaseView)

local SWEEP_BOSS_MAX_NUM = 10    ------最大召唤boss数量
function DefenseSweepView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "DefenseFBClearTips"}}

	self.is_modal = true
	self.is_any_click_close = true
end

function DefenseSweepView:__delete()

end

function DefenseSweepView:ReleaseCallBack()
	if self.saodang_cell then
		self.saodang_cell:DeleteMe()
		self.saodang_cell = nil
	end

end

function DefenseSweepView:LoadCallBack()
	self.node_list["ButtonPlus"].button:AddClickListener(BindTool.Bind(self.OnGoldPlus, self))
	self.node_list["ButtonReduce"].button:AddClickListener(BindTool.Bind(self.OnGoldReduce, self))
	self.node_list["GoldInputField"].button:AddClickListener(BindTool.Bind(self.OnClickGoldInput, self))

	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickCancel, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCancel, self))
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClinkOkHandler, self))
	self.node_list["BtnMax"].button:AddClickListener(BindTool.Bind(self.OnClickMax, self))
	self.sweep_boss_num = SWEEP_BOSS_MAX_NUM
end

function DefenseSweepView:ShowIndexCallBack()
	self:Flush()
end

function DefenseSweepView:SceneStateFuben()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Defensefb then
		return true
	end

	return false
end

function DefenseSweepView:OnFlush()
	-- local other_cfg = FuBenData.Instance:GetDefenseTowerOtherCfg()
	-- self.saodang_cell:SetData({item_id = other_cfg.sweep_item_id, is_bind = 1})

	-- local item_num = ItemData.Instance:GetItemNumInBagById(other_cfg.sweep_item_id)
	-- self.node_t_list.lbl_item_num.node:setString(item_num .. "/" .. other_cfg.sweep_item_num)
	-- self.node_t_list.lbl_item_num.node:setColor(item_num >= other_cfg.sweep_item_num and COLOR3B.WHITE or COLOR3B.DARK_RED)
	local str = ""
	if self:SceneStateFuben() then
		str = string.format(Language.DefenseFb.BuyBossNumber, "")
		self.sweep_boss_num = 1
	else
		str = string.format(Language.DefenseFb.BuyBossNumber, Language.DefenseFb.SweepState)
	end
	self.node_list["TextDec"].text.text = str

	self:SetCheckBoxText()
end

function DefenseSweepView:OnClinkOkHandler()
	local tf_cfg_other = FuBenData.Instance:GetDefenseTowerOtherCfg()
	local tf_fb_buy_num = FuBenData.Instance:GetBuildTowerBuyTimes() or 0
	local tf_fb_join_num = FuBenData.Instance:GetBuildTowerEnterTimes() or 0
	local left_times = tf_cfg_other.enter_free_times + tf_fb_buy_num - tf_fb_join_num
	local can_buy_count = VipPower.Instance:GetParam(VipPowerId.build_tower_fb_buy_times) - tf_fb_buy_num

	if self:SceneStateFuben() then
		local ok_fun = function ()
			FuBenCtrl.Instance:SendBuildTowerReq(BUILD_TOWER_OPERA_TYPE.BUILD_TOWER_OPERA_TYPE_CALL, self.sweep_boss_num)
			self:OnClickCancel()
		end

		local cost = tf_cfg_other.extra_call_gold
		local cfg = string.format(Language.DefenseFb.DefenseBossGold, cost * self.sweep_boss_num, self.sweep_boss_num)
		if self.sweep_boss_num > 0 then
			TipsCtrl.Instance:ShowCommonAutoView("DefenseSweep", cfg, ok_fun)
		end
		return
	end

	if left_times == 0 and can_buy_count > 0 then
		local ok_fun = function ()
			FuBenCtrl.Instance:SendBuildTowerBuyTimes()
		end

		local cost = tf_cfg_other.buy_times_gold
		local cfg = string.format(Language.TowerDefend.BuyTip, cost)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	elseif left_times == 0 and can_buy_count <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.DefenseFb.LeftSweepTimes)
		self:OnClickCancel()
	else
		local ok_fun = function ()
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DEFENSE_FB, self.sweep_boss_num)
			if left_times <= 1 then
				self:Close()
			end
		end

		local cost = tf_cfg_other.extra_call_gold
		local cfg = string.format(Language.DefenseFb.DefenseBossGold, cost * self.sweep_boss_num, self.sweep_boss_num)
		if self.sweep_boss_num > 0 then
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
		else
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DEFENSE_FB, self.sweep_boss_num)
			if left_times <= 1 then
				self:Close()
			end
		end
	end
end

function DefenseSweepView:OnClickCancel()
	self:Close()
end

function DefenseSweepView:OnGoldPlus()

	self.sweep_boss_num = self.sweep_boss_num + 1
	if(self.sweep_boss_num > SWEEP_BOSS_MAX_NUM) then
		self.sweep_boss_num = SWEEP_BOSS_MAX_NUM
		SysMsgCtrl.Instance:ErrorRemind(Language.DefenseFb.BuyMaxBoss)
	end

	local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
	if defense_info ~= nil and next(defense_info) ~= nil and self:SceneStateFuben() then 
		if defense_info and next(defense_info) ~= nil then
			if self.sweep_boss_num > defense_info.remain_buyable_monster_num then
				self.sweep_boss_num = defense_info.remain_buyable_monster_num
				SysMsgCtrl.Instance:ErrorRemind(Language.DefenseFb.BuyMaxBoss)
			end
		end
	end

	self:SetCheckBoxText()
end

function DefenseSweepView:OnGoldReduce()
	self.sweep_boss_num = self.sweep_boss_num - 1
	if(self.sweep_boss_num < 0) then
		self.sweep_boss_num = 0
	end
	self:SetCheckBoxText()
end

function DefenseSweepView:OnClickMax()
	local max_count = SWEEP_BOSS_MAX_NUM
	if Scene.Instance:GetSceneType() == SceneType.Defensefb then
		local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
		if defense_info and next(defense_info) then
			max_count = defense_info.remain_buyable_monster_num
		end
	end
	self.sweep_boss_num = max_count
	self:SetCheckBoxText()
end

function DefenseSweepView:OnClickGoldInput()
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.GoldInputEnd, self), nil, self.gold)
end

function DefenseSweepView:GoldInputEnd(str)
	local num = tonumber(str)
	if(num < 0) then
		num = 0
	elseif(num > SWEEP_BOSS_MAX_NUM) then
		num = SWEEP_BOSS_MAX_NUM
	end

	local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
	if defense_info ~= nil and next(defense_info) ~= nil and self:SceneStateFuben() then 
		if num > defense_info.remain_buyable_monster_num then
			num = defense_info.remain_buyable_monster_num
			SysMsgCtrl.Instance:ErrorRemind(Language.DefenseFb.BuyMaxBoss)
		end
	end

	self.sweep_boss_num = num
	self:SetCheckBoxText()
end

function DefenseSweepView:SetCheckBoxText()
	if self.node_list["TextExpend"] and self.node_list["Text"] and self.node_list["TextCurNum"] then
		local cost = FuBenData.Instance:GetDefenseTowerOtherCfg().extra_call_gold 
		local str = string.format(Language.DefenseFb.DefenseBossGold, self.sweep_boss_num * cost, self.sweep_boss_num)
		self.node_list["Text"].text.text = self.sweep_boss_num
		self.node_list["TextExpend"].text.text = str
		local txt = string.format(Language.DefenseFb.DefenseCurNum, SWEEP_BOSS_MAX_NUM)
		if Scene.Instance:GetSceneType() == SceneType.Defensefb then
			local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
			if defense_info then
				txt = string.format(Language.DefenseFb.DefenseCurNum, defense_info.remain_buyable_monster_num or 0)
			end
		end
		self.node_list["TextCurNum"].text.text = txt
	end
end