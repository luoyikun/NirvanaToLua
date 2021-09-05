-- 副本试炼/爬塔-TowerFBContent
FuBenTowerView = FuBenTowerView or BaseClass(BaseRender)

function FuBenTowerView:__init(instance)
	self.node_list["TowerChallenge"].button:AddClickListener(BindTool.Bind(self.OnClickChallenge, self))
	self.node_list["SaodangBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOneKey, self))
	self.node_list["BtnPeiJian"].button:AddClickListener(BindTool.Bind(self.OpenTowerMoJieView, self))
	self.node_list["BtnRank"].button:AddClickListener(BindTool.Bind(self.OnClickRank, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
		self.item_cell_list[i]:SetShowOrangeEffect(true)
	end
	
	self.is_onekey_saodang = false

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
end

function FuBenTowerView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function FuBenTowerView:CloseCallBack()
	self.is_onekey_saodang = false
end

function FuBenTowerView:OnFlush()
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	if not fb_info then
		return
	end
	local tower_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	if not tower_cfg or nil == next(tower_cfg) then
		return
	end
	self:FlushRightPanel(fb_info, tower_cfg)
	self:FlushLeft(fb_info)
end

function FuBenTowerView:FlushRightPanel(fb_info, tower_cfg)
	local curr_level_cfg = tower_cfg[fb_info.pass_level + 1]
	local is_max_level = fb_info.pass_level >= FuBenData.Instance:MaxTowerFB()
	if is_max_level then
		curr_level_cfg = tower_cfg[#tower_cfg]
	end
	if nil == curr_level_cfg then
		return
	end

	local is_first = fb_info.pass_level == 0 or fb_info.pass_level < fb_info.today_level + 1
	local reward_cfg = is_first and curr_level_cfg.first_reward or curr_level_cfg.normal_reward
	local item_index_offset = 1

	if fb_info.pass_level >= FuBenData.Instance:MaxTowerFB() then
		self.node_list["Items"]:SetActive(false)
		-- reward_cfg = FuBenData.Instance:GetTowerFbSaoDangAllReward()
		-- item_index_offset = 0
	else
		self.node_list["Items"]:SetActive(true)
	end

	local first_cell_count = 0
	for k, v in pairs(reward_cfg) do
		if v and self.item_cell_list[k + item_index_offset] then
			self.item_cell_list[k + item_index_offset]:SetParentActive(true)
			self.item_cell_list[k + item_index_offset]:SetData(v)
			first_cell_count = first_cell_count + 1
		end
	end

	for i = first_cell_count + 1, #self.item_cell_list do
		if self.item_cell_list[i] then
			self.item_cell_list[i]:SetParentActive(false)
		end
	end

	local is_can_sao_dang = fb_info.today_level >= fb_info.pass_level and fb_info.pass_level > 0
	self.node_list["SaoDangBtnText"].text.text = is_can_sao_dang and Language.Common.HadSaoDang or Language.Common.OneKeySaoDang
	UI:SetButtonEnabled(self.node_list["SaodangBtn"], not is_can_sao_dang and fb_info.pass_level ~= 0)
	local is_show_saodang = not is_can_sao_dang and fb_info.pass_level ~= 0
	self.node_list["SaodangBtn"]:SetActive(is_show_saodang)
	self.node_list["TowerChallenge"]:SetActive(fb_info.pass_level < FuBenData.Instance:MaxTowerFB() and not is_show_saodang)
	self.node_list["TextReward"].text.text = is_first and Language.GaoZhanFuBen.FirstReward or Language.GaoZhanFuBen.DayReward
	if is_max_level then
		self.node_list["TextReward"].text.text = Language.GaoZhanFuBen.DayReward
		self.node_list["CurLevel"].text.text = Language.FuBen.CurOverLevel
		-- self.node_list["CurLevel"].text.text = string.format(Language.FuBen.ArriveCurLevel, fb_info.pass_level , )
	else
		self.node_list["CurLevel"].text.text = string.format(Language.FuBen.CurLevel, fb_info.pass_level + 1)
		
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo and main_role_vo.capability and curr_level_cfg and curr_level_cfg.capability then
		local power = curr_level_cfg.capability
		local color = main_role_vo.capability >= power and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
		self.node_list["TxtZhanLi"].text.text = string.format(Language.FuBen.RecommendCap, ToColorStr(power, color))
	end
	self:SetRightModel(curr_level_cfg)
end

function FuBenTowerView:SetRightModel(curr_level_cfg)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[curr_level_cfg.boss_id]
	if nil == monster_cfg then
		return
	end
	local bundle, asset = ResPath.GetMonsterModel(monster_cfg.resid)
	local boss_cfg = BossData.Instance:GetMonsterInfo(curr_level_cfg.boss_id)
	self.model:SetMainAsset(bundle, asset, function()
		if boss_cfg then
			local Scale_boss = boss_cfg.ui_scale or 1
			self.model:SetScale(Vector3(Scale_boss, Scale_boss, Scale_boss))
			local boss_rotation = FuBenData.Instance:GetPaTaBossAngle(curr_level_cfg.boss_id)
			self.model:SetRotation(Vector3(0,boss_rotation, 0))
		end
	end)
	self.model:ResetRotation()
end

function FuBenTowerView:FlushLeft(fb_info)
	local next_reward_mojie_cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()
	local is_max_level = fb_info.pass_level >= FuBenData.Instance:MaxTowerFB()
	local num  = FuBenData.Instance:MaxTowerFB()
	if is_max_level == true then
		next_reward_mojie_cfg = FuBenData.Instance:GetMaxTowerMojieCfg()
	end
	if nil == next_reward_mojie_cfg then
		return
	end
	self.node_list["TextActiveTip"].text.text = is_max_level and Language.GaoZhanFuBen.RewardTipTwo or string.format(Language.GaoZhanFuBen.RewardTip, next_reward_mojie_cfg.pata_layer)
	local tmp_id = next_reward_mojie_cfg.skill_id % 10 + 1
	local tmp_id1 = next_reward_mojie_cfg.skill_id % 10 == 0 and 1 or next_reward_mojie_cfg.skill_id % 10
	local bundle, asset = ResPath.GetTowerPeiJianIcon(tmp_id)

	local dqtmp_idtwo = next_reward_mojie_cfg.skill_id + 1
	local dqtmp_id = next_reward_mojie_cfg.skill_id  == 0 and 1 or next_reward_mojie_cfg.skill_id
	local my_selftmpid  = dqtmp_idtwo  > 10 and dqtmp_idtwo - 10 or dqtmp_idtwo
	local name_cfg  = FuBenData.Instance:GetTowerMojieCfgBySkillId(my_selftmpid)
	self.node_list["ImgSword"].raw_image:LoadSprite(bundle, asset)
	local tmp_id2 = math.modf(next_reward_mojie_cfg.skill_id / 10)
	tmp_id2 = tmp_id2 > 0 and 3 or 2 										--策划要求显示中级跟高级特效
	local roadA = "KGH_mingjian_" .. 0 .. tmp_id .. "_0" .. tmp_id2
	local roadB = "KGH_mingjian_" .. tmp_id .. "_0" .. tmp_id2
	local asset1 = tmp_id < 10 and roadA or roadB
	if tmp_id2 > 0 then
		local bundle_name, asset_name = ResPath.GetUiMingJianEffect(asset1)
		self.node_list["Nodeeffect"]:ChangeAsset(bundle_name, asset_name)
	end

	local skill_bundle, skill_asset = ResPath.GetFuBenViewImage("peijian_skill_" .. tmp_id)
	self.node_list["Skill1"].image:LoadSprite(skill_bundle, skill_asset)
	self.node_list["Skill2"].image:LoadSprite(skill_bundle, skill_asset)

	if next_reward_mojie_cfg.level == 1 then
		self.node_list["RightSkill"]:SetActive(false)
		self.node_list["SkillArrow"]:SetActive(false)
		self.node_list["CurrSkill"].text.text = next_reward_mojie_cfg.name
	else
		self.node_list["RightSkill"]:SetActive(true)
		self.node_list["SkillArrow"]:SetActive(true)
		self.node_list["CurrSkill"].text.text = next_reward_mojie_cfg.name .. " Lv." ..next_reward_mojie_cfg.level - 1
		self.node_list["NextSkill"].text.text = next_reward_mojie_cfg.name .. " Lv." .. next_reward_mojie_cfg.level
	end

	-- 设置下一个解锁名剑name

	local tip_id1 = next_reward_mojie_cfg.skill_id % 10 + 1
	local tip_id2 = next_reward_mojie_cfg.skill_id % 10 == 0  and 1 or next_reward_mojie_cfg.skill_id % 10 
	local tmp_id2 = math.modf(next_reward_mojie_cfg.skill_id / 10)
	self.node_list["NameIcon"]:SetActive(tmp_id2 > 0)
	if tmp_id2 > 0 then
		local bundle, asset = ResPath.GetTowerMojieNameIconVertical(tmp_id2)
		self.node_list["NameIcon"].image:LoadSprite(bundle, asset)
	end
	local bundle, asset = ResPath.GetTowerMojieNameVertical(tmp_id)
	self.node_list["NameImg"].image:LoadSprite(bundle, asset)

	-- 设置名剑描述
	local next_mojie_cfg = FuBenData.Instance:GetMoJieTipscfg(dqtmp_idtwo)
	local params = next_mojie_cfg.skill_param or 0
	local dq_mojie_cfg = FuBenData.Instance:GetMoJieTipscfg(my_selftmpid)
	local dqparams = dq_mojie_cfg.skill_param or 0
	local max_level = FuBenData.Instance:MaxTowerFB()
	if fb_info.pass_level >= max_level then
		self.node_list["TxtAttrDec"].text.text = string.format(Language.Common.ActiveMaxLevel)
		self.node_list["DqTxtAttrDec"].text.text = string.format(Language.FubenTower.TowerMoJieSkillDes[tip_id2], params[1], params[2], params[3], params[4])
	else
		self.node_list["TxtAttrDec"].text.text = string.format(Language.FubenTower.TowerMoJieSkillDes[tip_id1], params[1], params[2], params[3], params[4])
		self.node_list["DqTxtAttrDec"].text.text = string.format(Language.FubenTower.TowerMoJieSkillDes[tip_id1], dqparams[1], dqparams[2], dqparams[3], dqparams[4])
	end
	
end

-- 打开传世佩剑窗口
function FuBenTowerView:OpenTowerMoJieView()
	ViewManager.Instance:Open(ViewName.TowerMoJieView)
end

-- 挑战
function FuBenTowerView:OnClickChallenge()
	if FuBenData.Instance:IsShowTowerFBRedPoint() then
		FuBenCtrl.Instance:SetRedPointCountDown("tower")
		RemindManager.Instance:Fire(RemindName.GaoZhanFuBen)
	end
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PATAFB)
	ViewManager.Instance:Close(ViewName.GaoZhanFuBen)
end

-- 扫荡
function FuBenTowerView:OnClickOneKey()
	if not FuBenData.Instance:IsShowTowerFBRedPoint() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Dungeon.TowerSaoDangCompelet)
		return
	end
	self.is_onekey_saodang = true
	FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PATAFB)
end

-- 排行榜
function FuBenTowerView:OnClickRank()
	ViewManager.Instance:Open(ViewName.TowerRank)
	self:SetBtnRankState(false)
end

-- 帮助按钮
function FuBenTowerView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(293)
end

-- 设置排行榜按钮状态
function FuBenTowerView:SetBtnRankState(enable)
	self.node_list["BtnRank"]:SetActive(enable)
	-- if enable then
		-- UITween.MoveToShowPanel(self.node_list["BtnRank"], Vector3(-398.5, 0, 0), Vector3(-322.6, 0, 0), 0.5)
	-- else
		-- UITween.MoveToShowPanel(self.node_list["BtnRank"], Vector3(-322.6, 0, 0), Vector3(-398.5, 0, 0), 0.5)
	-- end
end

-- 设置动画
function FuBenTowerView:UITween()
	UITween.MoveShowPanel(self.node_list["RightArea"], Vector3(370, -26, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Bottom"], Vector3(-93, -400, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BtnPeiJian"], Vector3(-381, 284, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["Title"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["ImgSword"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["BtnRank"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NameGrop"], true, 0.5, DG.Tweening.Ease.InExpo)
end