TipsTodayThemeView = TipsTodayThemeView or BaseClass(BaseView)

function TipsTodayThemeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseTodayPanel"},
		{"uis/views/tips/todaythemetips_prefab", "TodayThemeTip"},
	}
	-- self.view_layer = UiLayer.Pop
	self.camera_mode = UICameraMode.UICameraHigh
	self.is_any_click_close = true
	self.is_modal = true
	self.list_cell_list = {}
end

function TipsTodayThemeView:LoadCallBack()
	self.data_list = {}
	self.list_cell_list = {}
	self.node_list["ListView"].page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function TipsTodayThemeView:__delete()

end

function TipsTodayThemeView:ReleaseCallBack()
	for k, v in pairs(self.list_cell_list) do
		v:DeleteMe()
	end
	self.list_cell_list = {}
end

function TipsTodayThemeView:GetNumberOfCells()
	return #self.data_list
end

function TipsTodayThemeView:RefreshListCell(data_index, cell)
	local cell_item = self.list_cell_list[cell]
	if cell_item == nil then
		cell_item = TodayThemeListCell.New(cell.gameObject)
		self.list_cell_list[cell] = cell_item
	end
	local data = self.data_list[data_index + 1]
	cell_item:SetData(data)
	cell_item:SetIndex(data_index)

	local reward_cfg = TipsTodayThemeData.Instance:GetCfgByTypeAndIndex(data.system_big_type, data.system_type)
	if reward_cfg and reward_cfg.theme_name then
		self.node_list["TitleText"].text.text = reward_cfg.theme_name
	end
end

function TipsTodayThemeView:OpenCallBack()
	self:Flush("open_call_back")
	TipsTodayThemeData.Instance:SetTodayThemeEff(false)
	RemindManager.Instance:Fire(RemindName.TodayTheme)
end

function TipsTodayThemeView:OnFlush(param_t)
	self.data_list = TipsTodayThemeData.Instance:GetShowSystemTargetList()

	for k,v in pairs(param_t) do
		if "flush_list" == k then
			for k, v in pairs(self.list_cell_list) do
				-- v:Flush()
				local data_index = v:GetIndex()
				v:SetData(self.data_list[data_index + 1])
			end
		elseif "open_call_back" == k then
			if self.node_list["ListView"] and self.node_list["ListView"].gameObject.activeInHierarchy then
				self.node_list["ListView"].list_view:Reload()
				self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
			end
		end
	end

	if #self.data_list <= 0 then
		self:Close()
	elseif #self.data_list == 1 then
		self.node_list["PageButtons"]:SetActive(false)
	else
		self.node_list["PageButtons"]:SetActive(true)
	end

	if self.node_list["ListView"] and self.node_list["ListView"].gameObject.activeInHierarchy then
		self.node_list["ListView"].list_page_scroll2:SetPageCount(#self.data_list)
	end
	for i = 1, 11 do
		self.node_list["PageToggle".. i]:SetActive(i <= #self.data_list)
	end

end

----------------------------------TodayThemeListCell-----------------------------------------------

TodayThemeListCell = TodayThemeListCell or BaseClass(BaseCell)

function TodayThemeListCell:__init()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemParent"])
	
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickGetAward, self))
	self.node_list["SmallTargetImg"].button:AddClickListener(BindTool.Bind(self.OnSmallTargetImg, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	for i = 1, 3 do
		self.node_list["IconBtn" .. i].button:AddClickListener(BindTool.Bind(self.OnClickToOpenView, self, i))
		self.node_list["Chunk_" .. i].button:AddClickListener(BindTool.Bind(self.OnClickToOpenView, self, i))
	end

	local event_trigger = self.node_list["Drag"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnModelDrag, self))

	self.is_flush_model = true
	
end

function TodayThemeListCell:OnModelDrag(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function TodayThemeListCell:__delete()
	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self:StopCountDown()
	self.fight_text = nil
	self.open_view_type = nil
	self.open_view_flush_index = nil

	if self.add_delay_timer then
		GlobalTimerQuest:CancelQuest(self.add_delay_timer)
	end
end

-- 点击领取奖励按钮
function TodayThemeListCell:OnClickGetAward()
	if self.reward_cfg then
		TipsCtrl.Instance:SendThememeRewardSeq(self.reward_cfg.seq)
		self.is_flush_model = false

		if self.add_delay_timer then
			GlobalTimerQuest:CancelQuest(self.add_delay_timer)
		end
		self.add_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			local data = self.data
			if data.system_big_type == "advance" then 			-- 进阶类
				self:ShowAdvanceSystemType(data)
			elseif data.system_big_type == "system" then 		-- 系统类
				self:ShowSystemType(data)
			end
		end, 1.5)

		self.node_list["LockPanel"].animator:SetTrigger("OpenDoor")
		self.node_list["LockPanel"].animator:SetBool("IsClose", false)
	end
end

-- 点击领取小目标奖励
function TodayThemeListCell:OnSmallTargetImg()
	if self.data.system_big_type == "advance" then
		local function callback()
			local param1 = self.data.system_type
			local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
			local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

			local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
			if is_can_free then
				req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
			end
			JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
		end
		local data = JinJieRewardData.Instance:GetSmallTargetShowData(self.data.system_type, callback)
		TipsCtrl.Instance:ShowTimeLimitTitleView(data)

	elseif self.data.system_big_type == "system" then
		local fun = function(click_type)
			RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, self.data.system_type, click_type)
		end
		local goal_info = DisCountData.Instance:GetClassASmallTargetInfo(self.data.system_type)
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local open_system_time = self.data.open_system_time
		local left_times = math.ceil(open_system_time - sever_time + self.data.goal_cfg_info.free_time_since_open * 3600)
		local goal_data = {}
		goal_data.item_id = self.data.goal_cfg_info.reward_item[0].item_id
		goal_data.cost = self.data.goal_cfg_info.cost
		goal_data.can_fetch = goal_info.active_flag[0] == 1
		goal_data.left_time = left_times
		goal_data.from_panel = ""
		goal_data.call_back = fun

		TipsCtrl.Instance:ShowGoalTimeLimitTitleView(goal_data, false, self.data.system_type)
	end
end

-- 链接打开界面
function TodayThemeListCell:OnClickToOpenView(click_index)
	if nil == self.data or nil == next(self.data) then 
		return
	end
	
	if self.data.system_big_type == "advance" then
		local view_name
		local flush_index
		local index_advance = DisCountData.Instance:GetJumpIndexBySystemTypeAdvance(self.data.system_type)
		if self.open_view_type == "type_one" then
			if 1 == click_index then
				if index_advance ~= -1 then
					ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index_advance})
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.Tips.TodayThemeTipWord)
				end
			elseif 2 == click_index then
				view_name = ViewName.LeiJiDailyView
				if 1 == self.open_view_flush_index then
					flush_index = DailyChargeData.Instance:GetIsOpenActiveReward() and 3 or 2
				elseif 2 == self.open_view_flush_index then
					flush_index = DailyChargeData.Instance:GetIsOpenActiveReward() and 5 or 4
				end
			elseif 3 == click_index then
				local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
				if open_day <= 7 then
					view_name = ViewName.AdvancedReturn
				else
					view_name =	ViewName.AdvancedReturnTwo
				end
			end
		elseif self.open_view_type == "type_two" then
			if 1 == click_index then
				view_name = ViewName.CompetitionActivity
				-- if index_advance ~= -1 then
				-- 	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index_advance})
				-- else
				-- 	TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
				-- end	
			elseif 2 == click_index then
				view_name = ViewName.LeiJiDailyView
			elseif 3 == click_index then
				local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
				if open_day <= 7 then
					view_name = ViewName.AdvancedReturn
				else
					view_name =	ViewName.AdvancedReturnTwo
				end
			end
		end
		if view_name then
			if 2 == click_index then
				ViewManager.Instance:Open(view_name, nil, "list_index", {["list_index"] = flush_index})
			else
				ViewManager.Instance:Open(view_name)
			end
		end

	elseif self.data.system_big_type == "system" then
		local openview_tab = {
			[0] = {[2] = {view_name = ViewName.HappyErnieView}, [3] = {view_name = ViewName.Rune, tab_index = TabIndex.rune_treasure}},
			[1] = {[2] = {view_name = ViewName.Shop, tab_index = TabIndex.shop_youhui}},
			[2] = {[2] = {view_name = ViewName.SpiritView, tab_index = TabIndex.spirit_hunt}},
			[3] = {[2] = {view_name = ViewName.ScratchTicketView}, [3] = {view_name = ViewName.HunQiView, tab_index =  TabIndex.hunqi_bao}},
			[4] = {[2] = {view_name = ViewName.SecretTreasureHuntingView}, [3] = {view_name = ViewName.ShenGeView, tab_index = TabIndex.shen_ge_bless}},
			[5] = {[2] = {view_name = ViewName.ScratchTicketView}},
			[6] = {[2] = {view_name = ViewName.SecretTreasureHuntingView}},
			[9] = {[2] = {view_name = ViewName.ScratchTicketView}},
			[10] = {[2] = {view_name = ViewName.HappyErnieView}},
			[11] = {[2] = {view_name = ViewName.HappyErnieView}},
		}

		if 1 == click_index and 0 == self.data.goal_type then
			local index_system = DisCountData.Instance:GetJumpIndexBySystemType(self.data.system_type)
			if index_system ~= -1 then
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index_system})
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.ActivateNotOpen)
			end
		else
			if 1 == self.data.goal_type then
				click_index = click_index + 1
			elseif 0 == self.data.goal_type and openview_tab[self.data.system_type][3] then
				click_index = click_index + 1
			end
			local open_view = openview_tab[self.data.system_type] and openview_tab[self.data.system_type][click_index]
			if open_view then
				if open_view.tab_index then
					ViewManager.Instance:Open(open_view.view_name, open_view.tab_index)
				else
					ViewManager.Instance:Open(open_view.view_name)
				end
			end
		end

	end
end

function TodayThemeListCell:OnFlush()
	if nil == self.data or nil == next(self.data) then 
		return
	end
	
	self.reward_cfg = TipsTodayThemeData.Instance:GetCfgByTypeAndIndex(self.data.system_big_type, self.data.system_type)
	if not self.reward_cfg  then
		return
	end

	local show_lock_panel_flag = TipsTodayThemeData.Instance:GetShowLockPaneFlag(self.reward_cfg.seq)
	self.node_list["LockPanel"].animator:SetBool("IsClose", show_lock_panel_flag == 0)
	self.node_list["TodayPanel"]:SetActive(not (show_lock_panel_flag == 0))
	self.item_cell:SetData(self.reward_cfg.reward_item)
	self.node_list["BigTargetImg"]:SetActive(false)
	self.node_list["SmallTargetImg"]:SetActive(false)
	self.node_list["Display"]:SetActive(false)

	local data = self.data
	if data.system_big_type and self.is_flush_model then
		if data.system_big_type == "advance" then 			-- 进阶类
			self:ShowAdvanceSystemType(data)
		elseif data.system_big_type == "system" then 		-- 系统类
			self:ShowSystemType(data)
		end
	end 
end

-- 进阶类
function TodayThemeListCell:ShowAdvanceSystemType(data)
	self.is_flush_model = true
	local show_type, cur_model_grade, show_model_cfg, grade_cfg = TipsTodayThemeData.Instance:GetShowAdvanceSystemModel(data.system_type)
	
	if show_type == "small_target" then

	elseif show_type == "bipin" then
		if self.fight_text and self.fight_text.text.text then
			self.fight_text.text.text = ItemData.GetFightPower(show_model_cfg.item_id) or 0
		end
	elseif show_type == "big_target" then
		if self.fight_text and self.fight_text.text.text then
			local huanhua_cfg = JinJieRewardData.Instance:GetSystemSpecialImageLevelCfg(data.system_type, grade_cfg.param_0)
			self.fight_text.text.text = JinJieRewardData.Instance:GetSystemSpecialImageFightPower(data.system_type, huanhua_cfg)
		end
	else
		self:SetFightPower(grade_cfg)
	end

	if show_type == "small_target" then
		self:SetTitleImgAndEff(show_model_cfg.item_id)
	else
		self:FlushModle(show_model_cfg)
	end
	self:FlushRightPanel("advance", cur_model_grade)
	if type(show_type) == "number" then
		local name = string.format("%s%s·%s", Language.Common.NumToChs[show_type], Language.Common.Jie, show_model_cfg.image_name)
		self:SetDescribeWord(show_type, name)
	else
		self:SetDescribeWord(show_type, show_model_cfg and show_model_cfg.image_name)
	end
end

-- 系统类
function TodayThemeListCell:ShowSystemType(data)
	self.is_flush_model = true
	if 0 == data.goal_type then
		self:SetTitleImgAndEff(data.goal_cfg_info.reward_item[0].item_id)
	elseif 1 == data.goal_type then
		self:SetBigTargetImgAndEff(data.system_type)
	end
	self:FlushRightPanel("system")
end

-- 设置描述信息
function TodayThemeListCell:SetDescribeWord(show_type, image_name)
	local txt_dec = ""
	if show_type == "small_target" then
		txt_dec = string.format(Language.Tip.TodayThemeDescribeWord, Language.Common.NumToChs[6])
	elseif show_type == "bipin" then
		txt_dec = string.format(Language.Tip.TodayThemeDescribeWord, Language.Common.NumToChs[9])
	elseif show_type == "big_target" then
		txt_dec = string.format(Language.Tip.TodayThemeDescribeWord, Language.Common.NumToChs[10])
	else
		txt_dec = image_name
	end
	self.node_list["TextDec"].text.text = txt_dec
end

-- 设置小目标称号
function TodayThemeListCell:SetTitleImgAndEff(title_item)
	local item_cfg = ItemData.Instance:GetItemConfig(title_item)
	if nil == item_cfg then 
		return 
	end

	local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1 or 0)
	if title_cfg == nil then 
		return 
	end

	local bundle, asset = ResPath.GetTitleIcon(title_cfg.title_id)
	self.node_list["SmallBigTarget"]:SetActive(true)
	self.node_list["SmallTargetImg"].image:LoadSprite(bundle, asset, function()
		self.node_list["SmallTargetImg"].image:SetNativeSize()
		self.node_list["SmallTargetImg"].transform.localScale = Vector3(1.8, 1.8, 1.8)
		self.node_list["SmallTargetImg"]:SetActive(true)
	end)
	TitleData.Instance:LoadTitleEff(self.node_list["SmallTargetImg"], title_cfg.title_id or 0, true)
	self:SetFightPower(title_cfg)
	self:SetDescribeWord("system", self.reward_cfg.desc_little)
end

-- 计算战力
function TodayThemeListCell:SetFightPower(attr_list)
	if self.fight_text and self.fight_text.text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(attr_list)
	end
end

-- 设置大目标
function TodayThemeListCell:SetBigTargetImgAndEff(system_type)
	local effect_tab = {
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE] = {asset = "UI_zhanhun_da", bundle = "effects/prefab/ui/ui_zhanhun_da_prefab", is_special = true},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV] = {is_modal = true},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG] = {is_modal = true},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON] = {asset = "UI_yihuo_da", bundle = "effects/prefab/ui_x/ui_yihuo_da_prefab"},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE] = {asset = "UI_xinghui_da", bundle = "effects/prefab/ui/ui_xinghui_da_prefab"},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU] = {is_modal = true},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN] = {asset = "UI_xinghuihuo_da", bundle = "effects/prefab/ui_x/ui_xinghuihuo_da_prefab"},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC] = {asset = "UI_Effect_shengxiao", bundle = "effects/prefab/ui_x/ui_effect_shengxiao_prefab"},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI] = {is_modal = true},
		[ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER] = {is_modal = true},
	}

	local item_id = 0
	if effect_tab[system_type].is_modal then
		local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, system_type)
		if goal_cfg_info then
			item_id = goal_cfg_info.reward_item[0].item_id

			if system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV  then
				local _, res_id = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(item_id)
				local bundle, asset = ResPath.GetGoddessModel(res_id)
				self.model:SetMainAsset(bundle, asset)
				self.model:SetRotation(Vector3(0, 0, 0))
				self.model:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
			elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
				local type_cfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(item_id)
				if type_cfg == nil then
					return
				end
				local bundle, asset = ResPath.GetSpiritModel(type_cfg.res_id)
				self.model:SetMainAsset(bundle, asset)
				self.model:SetRotation(Vector3(0, -30, 0))
			elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
				local bundle, asset = "actors/longqi/10011_prefab", "10011"
				self.model:SetMainAsset(bundle, asset)
				self.model:SetRotation(Vector3(0, 0, 0))
			elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
				local bundle, asset = "actors/shengqi/1101_prefab", "1101"
				self.model:SetMainAsset(bundle, asset)
				self.model:SetRotation(Vector3(0, 0, 0))
			elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
				local big_goal_cfg = BianShenData.Instance:GetBigGoalCfg()
				if big_goal_cfg.res_id then
					local bundle, asset = ResPath.GetMingJiangRes(big_goal_cfg.res_id)
					self.model:SetMainAsset(bundle, asset, function()
						self.model:SetRotation(Vector3(0, 0, 0))
						self.model:SetScale(Vector3(1.2, 1.2, 1.2))
						self.model:SetTrigger(ANIMATOR_PARAM.REST)
					end)
				end
			end
		end
		self.node_list["Display"]:SetActive(true)
	else
		local asset, bundle = effect_tab[system_type].asset, effect_tab[system_type].bundle
		if asset and bundle then
			if effect_tab[system_type].is_special then
				self.node_list["BigTargetImg"]:SetActive(true)
				self.node_list["SmallBigTarget"]:SetActive(true)
				self.node_list["BigTargetEffect"]:ChangeAsset(bundle, asset)
			else
				local img_bundle, img_asset = ResPath.GetBigGoalImg(system_type)
				self.node_list["BigTargetImg"].image:LoadSprite(img_bundle, img_asset, function()
					self.node_list["BigTargetImg"]:SetActive(true)
					self.node_list["SmallBigTarget"]:SetActive(true)
					self.node_list["BigTargetImg"].image:SetNativeSize()
					self.node_list["BigTargetEffect"]:ChangeAsset(bundle, asset)
				end)
			end
		end
	end

	local cap = TipsTodayThemeData.Instance:GetBigGoalAttrData(system_type)
	if cap == nil or cap == 0 then
		cap = TipsTodayThemeData.Instance:GetBigGoalAttrDataTwo(system_type, item_id)
	end
	if self.fight_text and self.fight_text.text.text then
		self.fight_text.text.text = cap or 0
	end
	self:SetDescribeWord("system", self.reward_cfg.desc_big)
end

-- 右边Panel
function TodayThemeListCell:FlushRightPanel(system_big_type, cur_model_grade)
	self.node_list["TxtTipsTwo"]:SetActive(false)
	self.node_list["TxtTipsOne"]:SetActive(false)
	self.node_list["Btn_Icon_1"]:SetActive(false)
	self.node_list["TextName_1"]:SetActive(false)
	self.node_list["Btn_Icon_2"]:SetActive(false)
	self.node_list["TextName_2"]:SetActive(false)
	self.node_list["Btn_Icon_3"]:SetActive(false)
	self.node_list["TextName_3"]:SetActive(false)

	self.open_view_type = nil
	self.open_view_flush_index = nil
	local show_text_count = 0

	local set_size = false
	local icon_asset1, icon_bundle1
	local icon_text_asset1, icon_text_bundle1
	local icon_asset2, icon_bundle2
	local icon_text_asset2, icon_text_bundle2
	local icon_asset3, icon_bundle3
	local icon_text_asset3, icon_text_bundle3

	if system_big_type == "advance" and cur_model_grade then
		local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		self.node_list["TxtTipsOne"]:SetActive(true)
		if 0 <= cur_model_grade and cur_model_grade <= 7 then -- 0-7
			self.node_list["Text_Dec_1"].text.text = Language.Tip.TodayThemeTips1
			self.node_list["Text_Dec_3"].text.text = Language.Tip.TodayThemeTips3
			if 0 <= cur_model_grade and cur_model_grade <= 4 then -- 0-4
				self.node_list["Text_Dec_2"].text.text = Language.Tip.TodayThemeTips2[1]
				self.open_view_flush_index = 1
			else
				self.node_list["Text_Dec_2"].text.text = Language.Tip.TodayThemeTips2[2]
				self.open_view_flush_index = 2
			end
			self.open_view_type = "type_one"

			set_size = true
			icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("icon_hui2")
			icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("icon_hui2Name")

		elseif 8 <= cur_model_grade and cur_model_grade <= 14 then -- 8-14
			self.node_list["Text_Dec_2"].text.text = Language.Tip.TodayThemeTips2[3]
			self.node_list["Text_Dec_3"].text.text = Language.Tip.TodayThemeTips3
			if 8 == cur_model_grade then
				self.node_list["Text_Dec_1"].text.text = Language.Tip.TodayThemeTips4[1]
			else
				self.node_list["Text_Dec_1"].text.text = Language.Tip.TodayThemeTips4[2]
			end
			self.open_view_type = "type_two"

			icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("Icon_bipin_" .. open_day)
			icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("Icon_bipinName")
		end

		icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("Icon_System_LeiJiDaily")
		icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("Icon_System_LeiJiDailyName")
		icon_asset3, icon_bundle3 = ResPath.GetTodayThemeImg("Icon_back_" .. open_day)
		icon_text_asset3, icon_text_bundle3 = ResPath.GetTodayThemeImg("Icon_backName")

		show_text_count = 3

	elseif system_big_type == "system" then
		self.node_list["TxtTipsTwo"]:SetActive(true)

		local system_type = self.data.system_type
		
		if 0 == self.data.goal_type then
			-- 小目标
			self.node_list["Text_Dec_1"].text.text = Language.Tip.TodayThemeTips1
			show_text_count = show_text_count + 1

			if ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE == system_type or 
				ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG == system_type or 
				ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON == system_type or 
				ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE == system_type then

				local show_text = Language.Tip.TodayThemeTips5[system_type]
				if type(show_text) == "table" then
					-- for i = 1, #show_text do
					-- 	if i <= 2 then
					-- 		self.node_list["Text_Dec_" .. i + 1].text.text = show_text[i]
					-- 	end
					-- end
					self.node_list["Text_Dec_2"].text.text = show_text[2]
				else
					self.node_list["Text_Dec_2"].text.text = show_text
				end
				show_text_count = show_text_count + 1
			end

			set_size = true
			icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("icon_hui2")
			icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("icon_hui2Name")
			if ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE == system_type then
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_0")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_0")			
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG == system_type then
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_2")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_2")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON == system_type then
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_3")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_3")	
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE == system_type then
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_4")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_4")	
			end

		elseif 1 == self.data.goal_type then
			-- 大目标
			local show_text = Language.Tip.TodayThemeTips5[system_type]
			if type(show_text) == "table" then
				for i = 1, #show_text do
					if i <= 3 then
						self.node_list["Text_Dec_" .. i].text.text = show_text[i]
						show_text_count = show_text_count + 1
					end
				end
			else
				self.node_list["Text_Dec_1"].text.text = show_text
				show_text_count = show_text_count + 1
			end
			if ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("HappyErnieView")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("HappyErnieViewName")
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_0")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_0")						
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("Icon_System_Shop")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("Icon_System_ShopName")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("icon_choujiang_2")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("text_choujiang_2")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("Icon_GuaGuaLe")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("Icon_GuaGuaLeName")
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_3")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_3")	
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("SecretTreasureHuntingView")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("SecretTreasureHuntingViewName")
				icon_asset2, icon_bundle2 = ResPath.GetTodayThemeImg("icon_choujiang_4")
				icon_text_asset2, icon_text_bundle2 = ResPath.GetTodayThemeImg("text_choujiang_4")	
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("Icon_GuaGuaLe")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("Icon_GuaGuaLeName")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("SecretTreasureHuntingView")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("SecretTreasureHuntingViewName")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("Icon_GuaGuaLe")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("Icon_GuaGuaLeName")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("HappyErnieView")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("HappyErnieViewName")
			elseif ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER == system_type then
				icon_asset1, icon_bundle1 = ResPath.GetTodayThemeImg("HappyErnieView")
				icon_text_asset1, icon_text_bundle1 = ResPath.GetTodayThemeImg("HappyErnieViewName")
			end
		end
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level < 85 then
		show_text_count = 0
	end

	for i = 1, 3 do
		self.node_list["Chunk_" .. i]:SetActive(i <= show_text_count)
	end

	if icon_asset1 and icon_bundle1 then
		self.node_list["Btn_Icon_1"].image:LoadSprite(icon_asset1, icon_bundle1, function ()
			if set_size then
				self.node_list["Btn_Icon_1"].rect.sizeDelta = Vector3(72, 72, 0)
			else
				self.node_list["Btn_Icon_1"].image:SetNativeSize()
			end
			self.node_list["Btn_Icon_1"]:SetActive(true)
		end)
	end
	if icon_text_asset1 and icon_text_bundle1 then
		self.node_list["TextName_1"].image:LoadSprite(icon_text_asset1, icon_text_bundle1, function ()
			self.node_list["TextName_1"].image:SetNativeSize()
			self.node_list["TextName_1"]:SetActive(true)
		end)
	end
	if icon_asset2 and icon_bundle2 then
		self.node_list["Btn_Icon_2"].image:LoadSprite(icon_asset2, icon_bundle2, function ()
			self.node_list["Btn_Icon_2"].image:SetNativeSize()
			self.node_list["Btn_Icon_2"]:SetActive(true)
		end)
	end
	if icon_text_asset2 and icon_text_bundle2 then
		self.node_list["TextName_2"].image:LoadSprite(icon_text_asset2, icon_text_bundle2, function ()
			self.node_list["TextName_2"].image:SetNativeSize()
			self.node_list["TextName_2"]:SetActive(true)
		end)
	end
	if icon_asset3 and icon_bundle3 then
		self.node_list["Btn_Icon_3"].image:LoadSprite(icon_asset3, icon_bundle3, function ()
			self.node_list["Btn_Icon_3"].image:SetNativeSize()
			self.node_list["Btn_Icon_3"]:SetActive(true)
		end)
	end
	if icon_text_asset3 and icon_text_bundle3 then
		self.node_list["TextName_3"].image:LoadSprite(icon_text_asset3, icon_text_bundle3, function ()
			self.node_list["TextName_3"].image:SetNativeSize()
			self.node_list["TextName_3"]:SetActive(true)
		end)
	end

	self:StartCountDown(system_big_type)
end

function TodayThemeListCell:StartCountDown(system_big_type)
	self:StopCountDown()
	if nil == self.data then
		return
	end

	local time_des = ""
	local left_times = 0
	if system_big_type == "advance" then
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		left_times = 24 * 3600 - cur_time
	elseif system_big_type == "system" then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local open_system_time = self.data.open_system_time
		left_times = math.ceil(open_system_time - server_time + self.data.goal_cfg_info.free_time_since_open * 3600)
	end

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			self.node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	self.node_list["TextCountDown"].text.text = time_des
end

function TodayThemeListCell:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

--模型
function TodayThemeListCell:FlushModle(show_model_cfg)
	if nil == self.model then
		return
	end
	self.node_list["Display"]:SetActive(true)
	self.node_list["SmallBigTarget"]:SetActive(false)
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	self.model:ClearModel()
	self.model:ResetRotation()

	if JINJIE_TYPE.JINJIE_TYPE_MOUNT == self.data.system_type then
		-- 坐骑
		self:SetMountModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_WING == self.data.system_type then
		-- 羽翼
		self:SetWingModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT == self.data.system_type then
		-- 战斗坐骑
		self:SetFightMountModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_LINGCHONG == self.data.system_type then
		-- 灵童
		self:SetLingTongModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_FABAO == self.data.system_type then
		-- 法宝
		self:SetFabaoModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_FLYPET == self.data.system_type then
		-- 飞宠
		self:SetFlypetModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_HALO == self.data.system_type then
		-- 光环
		self:SetHaloModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_LINGQI == self.data.system_type then
		-- 灵骑
		self:SetLingqiModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_WEIYAN == self.data.system_type then
		-- 尾焰
		self:SetWeiyanModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_QILINBI == self.data.system_type then
		-- 麒麟臂
		self:SetQilinbiModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_SHENGONG == self.data.system_type then
		-- 仙环
		self:SetShenGongModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT == self.data.system_type then
		-- 足迹
		self:SetFootModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_LINGGONG == self.data.system_type then
		-- 灵弓
		self:SetLinggongModel(show_model_cfg)
	elseif JINJIE_TYPE.JINJIE_TYPE_SHENYI == self.data.system_type then
		-- 仙阵
		self:SetShenyiModel(show_model_cfg)
	end

end

function TodayThemeListCell:SetMountModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local bundle, asset = ResPath.GetMountModel(show_model_cfg.res_id)
	self.model:SetRotation(Vector3(0, -60, 0))
	self.model:SetMainAsset(bundle, asset)
	self.model:SetCameraSetting({position = Vector3(0, 2.2, 10), rotation = Quaternion.Euler(0, 180, 0)})
end

function TodayThemeListCell:SetWingModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	self.model:SetRoleResid(role_res_id)
	self.model:SetWingResid(show_model_cfg.res_id)
	if prof == GameEnum.ROLE_PROF_3 or prof == GameEnum.ROLE_PROF_2 then
		self.model:SetRotation(Vector3(0, -160, 0))
	elseif prof == GameEnum.ROLE_PROF_1 then
		self.model:SetRotation(Vector3(0, 170, 0))
	else
		self.model:SetRotation(Vector3(0, -170, 0))
	end
end

function TodayThemeListCell:SetFightMountModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local bundle, asset = ResPath.GetFightMountModel(show_model_cfg.res_id)
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -35, 0))
end

function TodayThemeListCell:SetLingTongModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id_h then return end

	local bundle1, asset1 = ResPath.GetLingChongModel(show_model_cfg.res_id_h)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle1, asset1)
	self.model:SetTrigger(LINGCHONG_ANIMATOR_PARAM.REST)
end

function TodayThemeListCell:SetFabaoModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local bundle, asset = ResPath.GetFaBaoModel(show_model_cfg.res_id)
	self.model:SetMainAsset(bundle, asset)
end

function TodayThemeListCell:SetFlypetModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local bundle, asset = ResPath.GetFlyPetModel(show_model_cfg.res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -35, 0))
end

function TodayThemeListCell:SetHaloModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	self.model:SetRoleResid(role_res_id)
	self.model:SetHaloResid(show_model_cfg.res_id)
end

function TodayThemeListCell:SetLingqiModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local bundle, asset = ResPath.GetLingQiModel(show_model_cfg.res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -45, 0))
end

function TodayThemeListCell:SetWeiyanModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	self:SetWeiYanIDModel(show_model_cfg.res_id)
	self.model:SetRotation(Vector3(0, 150, 0))
end

function TodayThemeListCell:SetQilinbiModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id0_h and nil == show_model_cfg.res_id1_h then return end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local qilinbi_res_id = main_vo.sex == 0 and show_model_cfg.res_id0_h or show_model_cfg.res_id1_h
	local bundle, asset = ResPath.GetQilinBiModel(qilinbi_res_id, main_vo.sex)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
end

function TodayThemeListCell:SetShenGongModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local info = {}
	info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	info.halo_res_id = show_model_cfg.res_id
	self.model:SetGoddessModelResInfo(info)
end

function TodayThemeListCell:SetFootModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	self.model:SetRoleResid(role_res_id)
	self.model:SetFootResid(show_model_cfg.res_id)
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	self.model:SetRotation(Vector3(0, -90, 0))
end

function TodayThemeListCell:SetLinggongModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id_h then return end

	local bundle, asset = ResPath.GetLingGongModel(show_model_cfg.res_id_h)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
end

function TodayThemeListCell:SetShenyiModel(show_model_cfg)
	if not show_model_cfg or nil == show_model_cfg.res_id then return end

	local info = {}
	info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	info.fazhen_res_id = show_model_cfg.res_id
	self.model:SetGoddessModelResInfo(info, true)
end

function TodayThemeListCell:SetWeiYanIDModel(res_id)
	if nil == res_id then
		return
	end

	local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
	local use_res_id = 0
	if mulit_mount_res_id > 0 then
		use_res_id = mulit_mount_res_id
	else
		local mount_image_id = MountData.Instance:GetUsedImageId()
		local mount_res_id = MountData.Instance:GetMountResIdByImageId(mount_image_id)
		use_res_id = mount_res_id
	end
	
	if use_res_id <= 0 then
		return
	end

	local bundle, asset = ResPath.GetMountModel(use_res_id)
	self.model:SetMainAsset(bundle, asset, function()
		self.model:SetWeiYanResid(res_id, use_res_id, false)
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		if use_res_id == 7053001 then
			self.model:SetCameraSetting({position = Vector3(0, 3.5, 18), rotation = Quaternion.Euler(0, 180, 0)})
		else
			self.model:SetCameraSetting({position = Vector3(-1.12, 2.26, 10), rotation = Quaternion.Euler(0, 180, 0)})
		end
	end)
end
