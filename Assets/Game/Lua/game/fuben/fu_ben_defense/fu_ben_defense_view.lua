FuBenDefenseView = FuBenDefenseView or BaseClass(BaseRender)

function FuBenDefenseView:__init(instance)
	self.enter_tf_times = 0
	self.item_list = {}
	self.list_data = {}
	self.cell_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["ItemCell" .. i])
		table.insert(self.item_list, item)
	end

	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickCount, self))
	self.node_list["BtnClear"].button:AddClickListener(BindTool.Bind1(self.OnClinkSaoDangHandler, self))
	self.node_list["BtnChallenge"].button:AddClickListener(BindTool.Bind(self.OnChallenge, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenDrop, self))

end

function FuBenDefenseView:LoadCallBack()
	FuBenCtrl.Instance:SetDefenseRemind()
	local list_simple_delegate = self.node_list["ListView"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function FuBenDefenseView:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function FuBenDefenseView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], Vector3(200, -27, 0))
end

function FuBenDefenseView:OpenDrop()
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_FB)
end

function FuBenDefenseView:GetNumberOfCell()
	return #self.list_data
end


function FuBenDefenseView:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local drop_cell = self.cell_list[cell]
	if nil == drop_cell then
		drop_cell = DropCellItem.New(cell.gameObject)
		self.cell_list[cell] = drop_cell
	end

	drop_cell:SetData(self.list_data[data_index])
end


function FuBenDefenseView:OnClickCount()
	local tf_fb_buy_num = FuBenData.Instance:GetBuildTowerBuyTimes() or 0
	local can_buy_count = VipPower.Instance:GetParam(VipPowerId.build_tower_fb_buy_times) - tf_fb_buy_num

	if can_buy_count > 0 then
		local ok_fun = function ()
			FuBenCtrl.Instance:SendBuildTowerBuyTimes()
		end

		local cost = FuBenData.Instance:GetDefenseTowerOtherCfg().buy_times_gold
		local cfg
		if self.enter_tf_times > 0 then
			cfg = string.format(Language.TowerDefend.BuyTip4, cost)
		else
			cfg = string.format(Language.TowerDefend.BuyTip, cost)
		end

		-- -- 购买次数XXX/XXX
		-- local buy_count = string.format(Language.TowerDefend.BuyCount, can_buy_count, VipPower.Instance:GetParam(VipPowerId.build_tower_fb_buy_times))
		-- local cfg = cfg .. "\n" .. buy_count

		local data_fun = function ()
			local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
			local data = {}
			data[2] = FuBenData.Instance:GetBuildTowerBuyTimes() or 0
			data[1] = FuBenData.Instance:GetDefenseTowerOtherCfg().buy_times_gold
			data[3] = VipData.Instance:GetVipPowerList(vip_level)[VipPowerId.build_tower_fb_buy_times]
			data[4] = VipPower:GetParam(VipPowerId.build_tower_fb_buy_times, true)
			return data
		end
		local data = data_fun()
		FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.DABAO_TIMES, ok_fun, data_fun, 1, cfg)
		-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.BuyLimitTip)
	end
end

function FuBenDefenseView:OnClinkSaoDangHandler()
	local cfg = FuBenData.Instance:GetDefenseTowerOtherCfg()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if cfg and vo then
		if cfg.sweep_level > vo.level then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.FuBen.LevelEnough, cfg.sweep_level))
		else
			FuBenCtrl.Instance:OpenDefenseSweep()
		end
	end
end

function FuBenDefenseView:OnChallenge()
	if self.enter_tf_times > 0 then
		ViewManager.Instance:CloseAll()
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DEFENSE_FB)
	else
		self:OnClickCount()
	end
end

function FuBenDefenseView:OnButtonHelp()
	local tips_id = 295
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function FuBenDefenseView:OnFlush()
	self.list_data = BossData.Instance:GetDropLog(1) or {}
	self.node_list["ListView"].scroller:ReloadData(0)

	local tf_cfg_other = FuBenData.Instance:GetDefenseTowerOtherCfg()

	if tf_cfg_other then
		for k,v in pairs(self.item_list) do
			if not tf_cfg_other.reward_item[k-1] then
				v:SetActive(false)
			else
				v:SetActive(true)
			end 
			v:SetData(tf_cfg_other.reward_item[k-1])
		end
	-- 	local role_level = PlayerData.Instance:GetRoleLevel()
	-- 	local limit_level = FuBenCtrl.Instance.defense_fb_data:GetDefenseTowerOtherCfg().sweep_level
	-- 	self.node_list["BtnClear"]:SetActive(role_level >= limit_level)

	-- 	-- local des = string.format(Language.FuBenPanel.FbLevelLimitTips, tf_cfg_other.enter_level)
	-- 	-- RichTextUtil.ParseRichText(self.node_t_list.rich_tafang_des_1.node, des, 22, COLOR3B.LIGHT_BROWN)
	-- 	-- RichTextUtil.ParseRichText(self.node_t_list.rich_tafang_des_2.node, Language.FuBenPanel.TaFangFbTips2, 22, COLOR3B.LIGHT_BROWN)

		local tf_fb_buy_num = FuBenData.Instance:GetBuildTowerBuyTimes() or 0
		local tf_fb_join_num = FuBenData.Instance:GetBuildTowerEnterTimes() or 0
		self.enter_tf_times = tf_cfg_other.enter_free_times + tf_fb_buy_num - tf_fb_join_num
		local left_times_color = self.enter_tf_times <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.node_list["TextTimes"].text.text = (ToColorStr(self.enter_tf_times, left_times_color) .. " / " .. tf_cfg_other.enter_free_times + tf_fb_buy_num)
	end
	local scene_type = Scene.Instance:GetSceneType()
	UI:SetButtonEnabled(self.node_list["BtnClear"], scene_type ~= SceneType.Defensefb)
	-- self.node_t_list.img_tafang_remind.node:SetActive(self:CheckTaFangCount())
	-- self.node_t_list.img_ta_fang_stamp.node:SetActive(FuBenPanelData.Instance:GetIsDoubleDrop(DOUBLE_DROP_FB_TYPE.TAFANG_FB))

	UI:SetButtonEnabled(self.node_list["BtnClear"], self.enter_tf_times > 0)
	UI:SetButtonEnabled(self.node_list["BtnChallenge"], self.enter_tf_times > 0)
end


DropCellItem = DropCellItem or BaseClass(BaseCell)
function DropCellItem:__init()
end

function DropCellItem:__delete()
end

function DropCellItem:OnFlush()
	if nil == self.data or nil == next(self.data) then
		return
	end

	local time_str = os.date("%m/%d %X", self.data.timestamp)
	local name_str = self.data.role_name

	local scene_name = ""
	local scene_config = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	if scene_config then
		scene_name = scene_config.name
	end

	local boss_name = ""
	local boss_cfg_info = BossData.Instance:GetMonsterInfo(self.data.monster_id)
	if boss_cfg_info then
		boss_name = boss_cfg_info.name
	end

	local param_interval = ":"
	local xianpin_type_list_num = self.data.xianpin_type_list and #self.data.xianpin_type_list or 0
	local param = ""
	local num = 6 + xianpin_type_list_num
	for i=1, num do
		if i <= 6 then
			param = param .. param_interval
		else
			if self.data.xianpin_type_list and self.data.xianpin_type_list[i - 6] then
				param = param .. param_interval .. self.data.xianpin_type_list[i - 6]
			end
		end
	end

	local str = ""
	if self.data.is_cross == 1 then
		str = string.format(Language.Boss.BossDrop, time_str, TEXT_COLOR.YELLOW, name_str, TEXT_COLOR.RED, scene_name, TEXT_COLOR.YELLOW, boss_name, self.data.item_id, param, self.data.item_num)
	elseif self.data.is_cross == 0 then
		str = string.format(Language.Boss.BossDrop, time_str, TEXT_COLOR.YELLOW, name_str, TEXT_COLOR.GREEN, scene_name, TEXT_COLOR.YELLOW, boss_name, self.data.item_id, param, self.data.item_num)
	end
	RichTextUtil.ParseRichText(self.node_list["rich_text"].rich_text, str)
end