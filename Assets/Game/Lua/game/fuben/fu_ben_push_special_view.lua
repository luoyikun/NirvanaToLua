-- 血战 内层
PushSpecialView = PushSpecialView or BaseClass(BaseRender)

function PushSpecialView:__init(instance)
	self.chapter_index = 1
	self.level_index = 1

	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAddNum, self))
	self.node_list["BtnEnterSaodang"].button:AddClickListener(BindTool.Bind(self.OnClickSaoDang, self))
	self.node_list["EnterButton"].button:AddClickListener(BindTool.Bind(self.OnClickEnterButton, self))
	self.node_list["BtnLaft"].button:AddClickListener(BindTool.Bind(self.OnClickLeftButton, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.OnClickRightButton, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.item_cells = {}
	for i = 1, 5 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item"..i])
	end

	self.special_item_list = {}
	self:ReCrateSpecialItemList()

	self.old_pass_chapter = nil
	self.old_pass_level = nil

	--引导用按钮
	self.wujin_enter_button = self.node_list["EnterButton"]

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)
end

function PushSpecialView:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
		self.get_ui_callback = nil
	end

	for k,v in pairs(self.special_item_list) do
		self.special_item_list[k]:DeleteMe()
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
	self.old_pass_chapter = nil
	self.old_pass_level = nil

	self.special_item_list = {}
end

function PushSpecialView:OpenCallBack()
	self:Flush()
end

function PushSpecialView:CloseCallBack()
	self.old_pass_chapter = nil
	self.old_pass_level = nil
end

function PushSpecialView:ReCrateSpecialItemList()
	for k,v in pairs(self.special_item_list) do
		self.special_item_list[k]:DeleteMe()
	end
	self.special_item_list = {}
	self.level_index = 1

	for i = 1, 4 do
		self.node_list["PushSpecialItem" .. i].transform.localScale = Vector3(1, 1, 1)
		self.special_item_list[i] = PushSpecialItem.New(self.node_list["PushSpecialItem" .. i])
		self.special_item_list[i].push_chapter_view = self
		self.node_list["BossObject" .. i].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClickBoss, self, i))
	end
end

function PushSpecialView:FlushBossList()
	local data = self:GetChapterData(self.chapter_index - 1)
	for k,v in pairs(self.special_item_list) do
		if data[k - 1] then
			v:SetData(data[k - 1])
		else
			print("Don't do now")
		end
	end
end

function PushSpecialView:GetChapterData(chapter_index)
	local chapter_index = self.chapter_index
	local push_fb_info = {}
	push_fb_info = FuBenData.Instance:GetPushFBInfo(1, chapter_index - 1)
	return push_fb_info
end

function PushSpecialView:OnFlush()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()

	if nil == data then
		return
	end

	if self.old_pass_chapter ~= data.pass_chapter then
		self.old_pass_chapter = data.pass_chapter
		self:CalcChapterIndex()
	end

	if self.old_pass_level ~= data.pass_level then
		self.old_pass_level = data.pass_level
		self:CalcLevelIndex()
	end

	self:FlushBossList()
	self:FlushDetailInfo()
end

function PushSpecialView:FlushDetailInfo()
	local special_info = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == special_info then
		return
	end
	local special_other_cfg = FuBenData.Instance:GetPushFBOtherCfg()
	local left_num = special_info.buy_join_times - special_info.today_join_times + special_other_cfg.hard_free_join_times
	local is_three_star = FuBenData.Instance:GetOneLevelIsPassAndThreeStar(1, self.chapter_index - 1, self.level_index - 1)
	self.node_list["NumTxt"].text.text = string.format(Language.FuBen.ResetEnterTimes, left_num)

	local nowRec =  special_info.pass_chapter * 4 + special_info.pass_level
	self.node_list["NowRecTxt"].text.text = string.format(Language.FuBen.NowRecrod, nowRec)
	local maxRec = special_info.pass_chapter * 4 + special_info.pass_level
	self.node_list["MaxRecTxt"].text.text = string.format(Language.FuBen.MaxRec, maxRec)
	self.node_list["BtnLaft"]:SetActive(self.chapter_index > 1)
	self.node_list["BtnRight"]:SetActive(not self:IsMaxIndex())
	self.node_list["TipNode"]:SetActive(not is_three_star)
	self.node_list["EnterButton"]:SetActive(not is_three_star)
	self.node_list["BtnEnterSaodang"]:SetActive(is_three_star)

	local fuben_cfg = FuBenData.Instance:GetPushFBInfo(1, self.chapter_index - 1, self.level_index - 1)
	local history_star = FuBenData.Instance:GetPushFBLeveLInfo(1, self.chapter_index - 1, self.level_index - 1).pass_star
	self.node_list["RewardDescTxt" ].text.text = history_star <= 0 and Language.FB.FirstReward or Language.FB.RewardShow
	local reward_cfg = history_star <= 0 and fuben_cfg.first_pass_reward or fuben_cfg.normal_reward_item
	self.item_data = {}
	for k, v in pairs(self.item_cells) do
		v:SetActive(false)
		if reward_cfg[k - 1] and reward_cfg[k - 1].item_id > 0 then
			v:SetActive(true)
			v:SetData(reward_cfg[k - 1])
			self.item_data[k] = reward_cfg[k - 1]
		end
	end
end

function PushSpecialView:OnClickAddNum()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == data then
		return
	end
	local buy_join_times = data.buy_join_times
	local can_buy_times = VipPower.Instance:GetParam(VipPowerId.push_special_buy_times) - buy_join_times
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local can_buy_count = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.PUSH_SPECIAL]
	local ok_fun = function ()
		FuBenCtrl.Instance:SendTuituFbOperaReq(1, 1, 1, param_3)
	end
	local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.PUSH_SPECIAL, buy_join_times + 1) or 0
	if PlayerData.Instance.role_vo.vip_level < limit_level then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.PUSH_SPECIAL)
		return
	end
	if can_buy_times > 0 then

		local next_pay_money = FuBenData.Instance:GetPushFBOtherCfg().hard_buy_times_need_gold
		local cfg = string.format(Language.Push[5], next_pay_money)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi")
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ExpFuBen.TipsText2)
	end
end

function PushSpecialView:OnClickEnterButton()
	local is_three_star = FuBenData.Instance:GetOneLevelIsPassAndThreeStar(1, self.chapter_index - 1, self.level_index - 1)
	if is_three_star then
		FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_SAODANG, 1, self.chapter_index - 1, self.level_index - 1)
	else
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 1, self.chapter_index - 1, self.level_index - 1)
	end
end

function PushSpecialView:OnClickSaoDang()
	FuBenCtrl.Instance:SendTuituFbOperaReq(3, 1, self.chapter_index - 1, self.level_index - 1)
end

function PushSpecialView:OnClickBoss(index)
	local tuitu_info = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == tuitu_info then
		return
	end
	local OneLevelIsPass = FuBenData.Instance:GetOneLevelIsPassBySpecial(1, self.chapter_index - 1, index - 1)
	if self.chapter_index == tuitu_info.pass_chapter + 1 and index > tuitu_info.pass_level + 1 or not OneLevelIsPass then
		SysMsgCtrl.Instance:ErrorRemind(Language.PushFb.PrveLevelPassLimit)
		return
	end

	self:SetLevelIndex(index)
	self:FlushDetailInfo()
end

function PushSpecialView:OnClickLeftButton()
	if self.chapter_index <= 1 then return end

	self:SetChapterIndex(self.chapter_index - 1)
	self:Flush()
end

function PushSpecialView:OnClickRightButton()
	if self:IsMaxIndex() then return end

	self:SetChapterIndex(self.chapter_index + 1)
	self:Flush()
end

function PushSpecialView:IsMaxIndex()
	local max_chapter = #(FuBenData.Instance:GetPushFBChapterInfo(1)) + 1
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == data then
		return false
	end
	local sc_max_chapter = data.pass_chapter + 1
	if self.chapter_index >= max_chapter or self.chapter_index >= sc_max_chapter then
		return true
	end
	return false
end

function PushSpecialView:CalcChapterIndex()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == data then
		return
	end
	local max_chapter = FuBenData.Instance:GetPushFbMaxChapter(PUSH_FB_TYPE.PUSH_FB_TYPE_HARD)
	local pass_chapter = math.min(data.pass_chapter, max_chapter)
	self:SetChapterIndex(pass_chapter + 1)
end

function PushSpecialView:SetChapterIndex(index)
	if self.chapter_index == index then
		return
	end

	self.chapter_index = index
	self:ReCrateSpecialItemList()
	self:CalcLevelIndex()
end

function PushSpecialView:CalcLevelIndex()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == data then
		return
	end
	local pass_chapter = data.pass_chapter
	local pass_level = data.pass_level

	if self.chapter_index <= pass_chapter then
		self:SetLevelIndex(1)
	else
		self:SetLevelIndex(data.pass_level % 4 + 1)
	end
end

function PushSpecialView:SetLevelIndex(index)

	for k,v in pairs(self.special_item_list) do
		v:OnUnSelect()
	end

	self.level_index = index
	local select_item = self.special_item_list[index]
	if nil ~= select_item then
		select_item:OnSelect()
	end
end

function PushSpecialView:GetLevelIndex()
	return self.level_index
end

function PushSpecialView:OnClickHelp()
	local tips_id = 205
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PushSpecialView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end

---------------------PushSpecialItem--------------------------------
PushSpecialItem = PushSpecialItem or BaseClass(BaseCell)

function PushSpecialItem:__init()
	self.push_chapter_view = nil
	self.boss_model_view = RoleModel.New()
	self.old_res_id = 0
end

function PushSpecialItem:__delete()
	self.push_chapter_view = nil
	if self.boss_model_view then
		self.boss_model_view:DeleteMe()
		self.boss_model_view = nil
	end
	self.special_effects = nil
end

function PushSpecialItem:SetChapterItemIndex(index)
	self.chapter_item_index = index
end

function PushSpecialItem:OnFlush()
	if self.data == nil then
		self.old_res_id = 0
		return
	end
	local data = self.data
	local special_info = FuBenData.Instance:GetTuituSpecialFbInfo()
	if nil == special_info then
		return
	end
	local push_fb_cfg = FuBenData.Instance:GetPushFBInfo(data.fb_type, data.chapter, data.level)
	local res_id = BossData.Instance:GetMonsterInfo(push_fb_cfg.monster_0).resid
	self.node_list["PassCondTxt"].text.text = Language.PushFb.NeedPassLastLevel
	local is_pass = self:IsPass(special_info, data.chapter, data.level)
	self.node_list["ImgPass"]:SetActive(is_pass)
	local is_open = self:IsOpen(special_info, data.chapter, data.level)
	self.node_list["MonsterModleNode"]:SetActive(is_open)
	self.node_list["StarList"]:SetActive( is_open)
	self.node_list["BossLock"]:SetActive(not is_open)

	self.node_list["ShowLimit"]:SetActive(not is_pass and not is_open and (data.level == 0 or self:IsOpen(special_info, data.chapter, data.level - 1) or self:IsPass(special_info, data.chapter, data.level - 1)))
---------------	
	local data = self.data
	if nil == data.level then return  end
	local numLoma = data.chapter * 4 + data.level + 1
	self.node_list["BossLevelTxt"].text.text = string.format(Language.FuBen.BossLevelText, numLoma)
	self.node_list["CapabilityTxt"].text.text = tostring(data.capability)
	local fb_info_list = special_info.chapter_info_list[data.chapter + 1]
	local level_info = fb_info_list.level_info_list[data.level + 1]
	for i = 1, 3 do
		UI:SetGraphicGrey(self.node_list["ImgStar" .. i], not (level_info.pass_star >= i))
	end
	self.boss_model_view:SetDisplay(self.node_list["boss_display"].ui3d_display)
	if self.old_res_id ~= res_id then
		self.old_res_id = res_id
		self.boss_model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
	end
end


function PushSpecialItem:IsOpen(special_info, chapter, level)
	local one_level_is_pass = FuBenData.Instance:GetOneLevelIsPassBySpecial(self.data.fb_type, chapter, level)
	return (chapter == 0 and level == 0 and one_level_is_pass) or chapter < special_info.pass_chapter or
						 (one_level_is_pass and special_info.pass_level >= level and chapter == special_info.pass_chapter and (chapter ~= 0 or level ~= 0))
end

function PushSpecialItem:IsPass(special_info, chapter, level)
	return chapter < special_info.pass_chapter or (special_info.pass_level > level and chapter == special_info.pass_chapter)
end

function PushSpecialItem:OnSelect()
	self.node_list["Anim"].animator:SetBool("fold", true)
end

function PushSpecialItem:OnUnSelect()
	self.node_list["Anim"].animator:SetBool("fold", false)
end

function PushSpecialItem:OnClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 1, self.data.chapter, self.data.level)
end
