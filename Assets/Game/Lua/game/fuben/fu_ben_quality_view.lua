-- 幻境副本
FuBenQualityView = FuBenQualityView or BaseClass(BaseRender)

function FuBenQualityView:__init(instance)
	self.cur_page = 1
	self.list = {}
	self.node_list["PageView"].page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["PageView"].page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)
	self.node_list["PageView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushAllHL, self))
	self.node_list["PageView"].page_view:Reload()
	self.node_list["PageView"].page_view:JumpToIndex(0)
	self.node_list["CanReStartTxt" ].text.text = Language.FuBen.ReStart

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnAddChallengeTime"].button:AddClickListener(BindTool.Bind(self.AddChallengeTime, self))
	self.node_list["BtnCanChallenge"].button:AddClickListener(BindTool.Bind(self.ClickChallenge, self))
	self.node_list["BtnCanReStart"].button:AddClickListener(BindTool.Bind(self.ClickReStart, self))
	self.node_list["BtnChouJiang"].button:AddClickListener(BindTool.Bind(self.OnClickChouJiang, self))

	self.item_list = {}
	for i=1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ItemCell" .. i])
		item_cell:SetShowOrangeEffect(true)
		self.item_list[i] = item_cell
	end

	self.is_continue = false
	self:FlushView()
end

function FuBenQualityView:__delete()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = nil
	end

	self.is_can_enter = nil
	self.cur_select_index = 0
end

function FuBenQualityView:GetBtnCanChallenge()
	return self.node_list["BtnCanChallenge"], BindTool.Bind(self.ClickChallenge, self)
end

function FuBenQualityView:OpenCallBack()
	FuBenCtrl.Instance:ReqChallengeFbInfo()
	self:FlushCurInfo()
end

function FuBenQualityView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Bottom"], FuBenTweenData.Down)
end

function FuBenQualityView:GetNumberOfCells()
	return FuBenData.Instance:GetChallengCfgLength()
end
function FuBenQualityView:SelectItemCallback(cell)
	if cell == nil or cell.data.index == nil then return end
	local num = FuBenData.Instance:GetChallengCfgLength()
	self.node_list["PageView"].page_view:JumpToIndex(cell.data.index, 0, 5 / num)
end

function FuBenQualityView:RefreshListCell(data_index, cell)
	local qualit_item = self.list[cell]
	if qualit_item == nil then
		qualit_item = QualityItem.New(cell.gameObject)
		qualit_item:SetClickCallback(BindTool.Bind(self.SelectItemCallback, self))
		qualit_item.parent_view = self
		self.list[cell] = qualit_item
	end
	local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(data_index)
	local data = {}
	data.cfg = fb_cfg
	data.index = data_index 
	qualit_item:SetData(data)
	qualit_item:IsSelect(data_index + 1 == self.cur_page )
end

function FuBenQualityView:OnFlush()
	self.cur_select_index = FuBenData.Instance:GetCanChallengeMaxLevel()
	self.node_list["PageView"].page_view:Reload()
	if self.cur_select_index ~= 0 then
		self.node_list["PageView"].page_view:JumpToIndex(self.cur_select_index)
	else
		self.node_list["PageView"].page_view:JumpToIndex(0)
	end
end

function FuBenQualityView:JumpListIndex(index)
	if self.node_list["PageView"] and self.node_list["PageView"].page_view.isActiveAndEnabled then
		local num = FuBenData.Instance:GetChallengCfgLength()
		self.node_list["PageView"].page_view:JumpToIndex(index - 1, 0, 5 / num)
	end
end

function FuBenQualityView:FlushAllHL()
	local page = self.node_list["PageView"].page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page
		for k, v in pairs(self.list) do
			v:IsSelect(v.data.index + 1 == self.cur_page)
		end
		self:FlushView()
	end
end


function FuBenQualityView:FlushView()
	local level = FuBenData.Instance:GetCanChallengeMaxLevel()
	self:OnToggleChange(level)
	self:ShowChouJiangEffect()
	self:FlushInfo()
end

function FuBenQualityView:FlushInfo()
	local level = FuBenData.Instance:GetCanChallengeMaxLevel()
	local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.cur_page - 1 )
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	local effect_level = other_cfg and other_cfg.effect_show

	if fb_cfg == nil then return end 
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local str_level = string.format(Language.Mount.ShowGreenNum, fb_cfg.role_level)
	if level < fb_cfg.role_level then
		str_level = string.format(Language.Mount.ShowRedNum, fb_cfg.role_level)
	end
	self.node_list["OpenLevelTxt"].text.text = string.format(Language.FuBen.OpenLevel, str_level)
	-- self.node_list["TextDsc"].text.text = Language.FuBen.FuBenQualityDsc

	local new_fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.cur_page - 1)
	if new_fb_cfg then
		for i,v in ipairs(self.item_list) do
			-- local equiment_quality = new_fb_cfg["item_quality" .. i] or 1
			local item_cfg = ItemData.Instance:GetItemConfig(tonumber(new_fb_cfg.item_list[i]))
			local equiment_quality = item_cfg and item_cfg.color or 1
			if new_fb_cfg.item_list[i] then
				self.item_list[i]:SetActive(true)
				self.item_list[i]:SetData({item_id = tonumber(new_fb_cfg.item_list[i])})
			else
				self.item_list[i]:SetData(nil)
				self.item_list[i]:SetActive(false)
			end
			-- self.item_list[i]:SetShowStar(new_fb_cfg.equiment_star)
			-- self.item_list[i]:SetQualityByColor(equiment_quality)
			local func = function()
				local item_data = {item_id = tonumber(new_fb_cfg.item_list[i])}
				TipsCtrl.Instance:OpenItem(item_data)
				-- GlobalTimerQuest:AddDelayTimer(function()
					-- TipsCtrl.Instance:SetQualityAndClor(equiment_quality)
					-- TipsCtrl.Instance:SetPropQualityAndClor(equiment_quality)
					-- TipsCtrl.Instance:SetOtherQualityAndClor(equiment_quality)
					-- end, 0.1)
			end
			if effect_level ~= nil and tonumber(equiment_quality) ~= nil and equiment_quality >= effect_level then
				if equiment_quality == 4 then
					self.item_list[i]:ShowEquipOrangeEffect(true)
				elseif equiment_quality == 5 then
					self.item_list[i]:ShowEquipRedEffect(true)
				elseif equiment_quality == 6 then
					self.item_list[i]:ShowEquipFenEffect(true)
				end
			end
			self.item_list[i]:ShowHighLight(false)
			-- self.item_list[i]:ShowExtremeEffect(false)
			self.item_list[i]:ListenClick(func)
		end
	end

	local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(self.cur_page - 1 )
	if fb_info == nil then
		return
	end
	local can_enter = FuBenData.Instance:GetCanEnterByLevel(self.cur_page - 1 ) and (fb_info.state == 0 or fb_info.state == 2)

	local total_layer = FuBenData.Instance:GetTotalLayerByLevel(self.cur_page - 1 )
	local cur_fight_layer = fb_info.fight_layer >= 0 and fb_info.fight_layer or 0
	self.node_list["EnterTimesTxt"].text.text = string.format(Language.FuBen.JinDu, cur_fight_layer, total_layer)


	local enter_time_str = string.format(Language.Mount.ShowGreenNum, 1)
	if not can_enter then
		enter_time_str = string.format(Language.Mount.ShowRedNum, 0)
	end
	self.node_list["BuyTimesTxt"].text.text = string.format(Language.FuBen.BuyTimes, enter_time_str)
	
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	if nil == other_cfg then
		return
	end

	local challenge_btn_text = Language.FuBen.Challnge
	if fb_info.is_continue == 1 or (fb_info.use_count == 1 and fb_info.history_max_reward < other_cfg.auto_need_star) then
		if fb_info.is_pass == 1 then
			challenge_btn_text = Language.FuBen.Challnge
		else
			challenge_btn_text = Language.FuBen.Continue
		end
		self.is_continue = true
	elseif fb_info.history_max_reward >= other_cfg.auto_need_star then
		challenge_btn_text = Language.FuBen.Auto
	end
	self.node_list["ChallengeBtnTxt" ].text.text =challenge_btn_text
	UI:SetGraphicGrey(self.node_list["BtnCanChallenge"], false)
	UI:SetButtonEnabled(self.node_list["BtnCanChallenge"], true)

	local can_restart = false
	local pass_layer = fb_info.fight_layer < 0 and 0 or fb_info.fight_layer
	if pass_layer > 0 then
		can_restart = true
	end
	UI:SetGraphicGrey(self.node_list["BtnCanReStart"], not can_restart)
	UI:SetButtonEnabled(self.node_list["BtnCanReStart"], can_restart)

	--计算总挑战次数
	local day_free_times = other_cfg.day_free_times
	local buy_times = FuBenData.Instance:GetQualityBuyCount()
	local total_times = day_free_times + buy_times

	--计算剩余的挑战次数
	local enter_times = FuBenData.Instance:GetQualityEnterCount()			--已经进入的次数
	self.left_times = total_times - enter_times
	local left_times_color = TEXT_COLOR.GREEN
	if self.left_times <= 0 then
		left_times_color = TEXT_COLOR.RED
	end
	local is_show = FuBenData.Instance:GetCanEnterByLevel(self.cur_page - 1)
	UI:SetButtonEnabled(self.node_list["BtnCanChallenge"], is_show)
	UI:SetGraphicGrey(self.node_list["ChallengeBtnTxt"], not is_show)
	self.node_list["ChallengeTimesTxt"].text.text = string.format(Language.FuBen.ChallengeTime, ToColorStr(self.left_times, left_times_color), total_times)
	self.node_list["PageView"].page_view:Reload()
end

function FuBenQualityView:OnToggleChange(index)
	self.cur_select_index = index
	FuBenData.Instance:SetQualitySelectIndex(index)
end

function FuBenQualityView:GetCurIndex()
	return self.cur_select_index
end

function FuBenQualityView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(186)
end

function FuBenQualityView:AddChallengeTime()
	-- local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	-- if nil == other_cfg then
	-- 	return
	-- end
	-- local buy_max_times = VipPower:GetParam(VIPPOWER.QUALITY_FB_TIMES) or 0
	-- local buy_times = FuBenData.Instance:GetQualityBuyCount()
	-- if buy_times >= buy_max_times then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.AddChallengeMaxDes)
	-- 	return
	-- end

	-- local cost = FuBenData.Instance:GetCostGoldByTimes(buy_times)
	-- local des = string.format(Language.FuBen.AddChallengeDes, cost)
	-- local function ok_callback()
	-- 	FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_BUY_TIMES)
	-- end

		local ok_fun = function ()
			FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_BUY_TIMES)
		end
		local data_fun = function ()
			local data = {}
			local buy_times = FuBenData.Instance:GetQualityBuyCount()
			data[2] = buy_times or 0
			data[1] = FuBenData.Instance:GetCostGoldByTimes(buy_times + 1)
			data[3] = VipPower:GetParam(VIPPOWER.QUALITY_FB_TIMES)
			data[4] = VipPower:GetParam(VIPPOWER.QUALITY_FB_TIMES, true)
			return data
		end
		local data = data_fun()
		FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.QUALITY_FB_TIMES, ok_fun, data_fun)
	-- TipsCtrl.Instance:ShowCommonAutoView("FuBenQuality", des, ok_callback)
end

function FuBenQualityView:ClickChallenge()
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	if nil == other_cfg then
		return
	end
	if self.left_times > 0 or self.is_continue then
		local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(self.cur_page -1 )
		if fb_info.history_max_reward >= other_cfg.auto_need_star then
			--星级足够（可扫荡副本）
			if FuBenData.Instance:GetIsInFuBenScene() then
				SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.FuBenNotSaoDang)
				return
			end
			FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_AUTO_FB, self.cur_page - 1)
		else
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_CHALLENGE, self.cur_page - 1)
		end
	else
		self:AddChallengeTime()
	end
end

function FuBenQualityView:ClickReStart()
	local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.cur_page - 1)
	if fb_cfg then
		local des = string.format(Language.FuBen.ResetTip, fb_cfg.fbname)
		local function ok_callback()
			FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_RESET_FB, self.cur_page - 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView("quality_restart", des, ok_callback)
	end
end

function FuBenQualityView:OnClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_CHALLENGE, self.cur_page)
	FuBenCtrl.Instance:CloseView()
end

-- 跳转到抽奖活动
function FuBenQualityView:OnClickChouJiang()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

-- 转盘抽奖按钮特效显示
function FuBenQualityView:ShowChouJiangEffect()
	if self.node_list["Effect"] then
		self.node_list["Effect"]:SetActive(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
	end
end

-----------------------------------------------------------------------------------------

QualityItem = QualityItem or BaseClass(BaseRender)

function QualityItem:__init()
	self.parent_view = nil
	-- self.item_list = {}
	-- for i = 1, 2 do
	-- 	local item_cell = ItemCell.New()
	-- 	item_cell:SetInstanceParent(self.node_list["Item" .. i])
	-- 	item_cell:SetData(nil)
	-- 	table.insert(self.item_list, item_cell)
	-- end

	self.node_list["RawImage"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
	-- self.node_list["Anim"].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self))

end

function QualityItem:__delete()
	self.parent_view = nil

	-- for _, v in ipairs(self.item_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.item_list = {}
end

function QualityItem:SetData(data)
	if not data then return end
	self.data = data
	self:OnFlush()
end

function QualityItem:OnFlush()
	if self.data == nil then return end
	local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(self.data.index)
	if nil == fb_info then
		return
	end
	self.node_list["ButtonChallenge"]:SetActive(fb_info.history_max_reward ~= 3 and fb_info.is_pass ~= 1)
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	if nil == other_cfg and nil == fb_info then
		return
	end

	local challenge_bundle, challenge_asset = ResPath.GetFuBenViewImage("chanllenge_fuben")
	if fb_info.is_continue == 1 or (fb_info.use_count == 1 and fb_info.history_max_reward < other_cfg.auto_need_star) then
		challenge_bundle, challenge_asset = ResPath.GetFuBenViewImage("goon_chanllenge_fuben")
	end
	self.node_list["ButtonText"].image:LoadSprite(challenge_bundle, challenge_asset)
	local can_enter = FuBenData.Instance:GetCanEnterByLevel(self.data.index) and (fb_info.state == 0 or fb_info.state == 2)
	local total_layer = FuBenData.Instance:GetTotalLayerByLevel(self.data.index)
	local cur_layer = fb_info.fight_layer >= 0 and fb_info.fight_layer or 0
	self.node_list["FbName" ].text.text = self.data.cfg.fbname .. " " .. cur_layer .. "/" .. total_layer

	local small_key = "quality".. self.data.cfg.icon
	local big_key = "Quality".. self.data.cfg.icon
	local bundle, asset = ResPath.GetFubenRawImage(small_key, big_key)
	self.node_list["RawImage"].raw_image:LoadSprite(bundle, asset)

	local is_active = FuBenData.Instance:GetCanEnterByLevel(self.data.index)
	self:SetHActive(is_active)

	local redpoint_value = (FuBenData.Instance:GetCanEnterByLevel(self.data.index) and (fb_info.state == 0 or fb_info.state == 2) and 
	FuBenData.Instance:IsCanShowQualityEnterByLevel(self.data.index)) or ((fb_info.state == 0 or fb_info.state == 2) and fb_info.history_max_reward >= 3)
	if not is_active then
		local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.data.index - 1)
		if fb_cfg then
			self.node_list["TextLastName"].text.text = string.format(Language.FuBen.LastName, fb_cfg.fbname)
		end
		self.node_list["ButtonChallenge"]:SetActive(false)
	end
	if cur_layer <= 0 and fb_info.history_max_reward > 0 then
		self.node_list["FbName" ].text.text = self.data.cfg.fbname .. " " .. total_layer .. "/" .. total_layer
	
	end

	if fb_info.state == 3 then
		self.node_list["ButtonChallenge"]:SetActive(false)
	end

	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local pass_layer = fb_info.fight_layer < 0 and 0 or fb_info.fight_layer
	local layer_cfg = FuBenData.Instance:GetChallengLayerCfgByLevelAndLayer(self.data.index, pass_layer)
	-- local str_fight_power = string.format(Language.Mount.ShowGreenNum, layer_cfg.zhanli)
	-- if capability < layer_cfg.zhanli then
	-- 	str_fight_power = string.format(Language.Mount.ShowRedNum, layer_cfg.zhanli)
	-- end

	-- self.node_list["FightPower"].text.text = string.format(Language.FuBen.RecommendCap, str_fight_power)
	for i = 1, 3 do
		UI:SetGraphicGrey(self.node_list["Star" .. i], i > fb_info.history_max_reward)
	end
	self.node_list["Tab_pass"]:SetActive(fb_info.history_max_reward == 3 or fb_info.is_pass == 1)

	-- --设置奖励信息
	-- local new_fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.data.index)
	-- for k, v in ipairs(self.item_list) do
	-- 	if new_fb_cfg["drop_item_"..k] ~= "" then
	-- 		v:SetData({item_id = new_fb_cfg["drop_item_"..k]})
	-- 		v:SetShowStar(2)
	-- 	end
	-- end
end

function QualityItem:FlushHL()
	if self.data == nil then return end
	local cur_index = self.parent_view:GetCurIndex()
	if self.node_list["Anim"].animator.isActiveAndEnabled then
		self.node_list["Anim"].animator:SetBool("fold", self.data.index == cur_index)
	end
end

function QualityItem:SetHActive(activeType)
	UI:SetGraphicGrey(self.node_list["RawImage"], not activeType)
	self.node_list["RawImageMask"]:SetActive(not activeType)
	self.node_list["TitleBg"]:SetActive(not activeType)
	self.node_list["TextLastName"]:SetActive(not activeType)
	-- self.node_list["NowStar"]:SetActive(activeType)
	-- self.node_list["FightPower"]:SetActive(activeType)
	self.node_list["NowStar"]:SetActive(true)
	-- self.node_list["FightPower"]:SetActive(true)	
end
function QualityItem:IsSelect(value)
	self.node_list["RawImgSelect"]:SetActive(value)
end

function QualityItem:SetClickCallback(handler)
	self.handler = handler
end
function QualityItem:OnClickItem()
	if self.handler then
		self.handler(self)
	end
end