DouqiGradeView = DouqiGradeView or BaseClass(BaseRender)

function DouqiGradeView:__init(instance)

	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.OnBtnUpLevel, self))
	self.node_list["BtnBreakUp"].button:AddClickListener(BindTool.Bind(self.OnBtnBreakUp, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	self.cur_fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCurFight"])
	self.next_fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNextFight"])

	local str = Language.Douqi.ToGet
	local color = TEXT_COLOR.GREEN
	local callback = function(btn)
		if nil ~= btn then
			btn:AddClickListener(function()
				ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.shenyu_secret)
				ViewManager.Instance:FlushView(ViewName.ShenYuBossView, "KFJumpToIndex", {4})
			end)
		end
	end
	local btn_bg_path = "lucency_bg"
	RichTextUtil.CreateUnderLineBtn(self.node_list["Txt_Link"].rich_text, str, 20, color, callback, btn_bg_path, true)
end

function DouqiGradeView:__delete()

	self.cur_fight_text = nil
	self.next_fight_text = nil
	self.douqi_info = nil
end

function DouqiGradeView:OnFlush()
	self.douqi_info = DouQiData.Instance:GetSCCrossEquipAllInfo()
	if nil == self.douqi_info then return end


	local cur_douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(self.douqi_info.douqi_grade)
	local next_douqi_cfg
	local cur_fight, next_fight
	local max_level = DouQiData.Instance:GetDouqiMaxGrade()
	if max_level == self.douqi_info.douqi_grade then
		self.is_max = true
	else
		self.is_max = false
		next_douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(self.douqi_info.douqi_grade + 1)
		next_fight = CommonDataManager.GetCapability(next_douqi_cfg)
	end

	cur_fight = CommonDataManager.GetCapability(cur_douqi_cfg)
	self.cur_fight_text.text.text = cur_fight
	self.next_fight_text.text.text = next_fight

	local cur_bundle, cur_asset = ResPath.GetDouqiAsset("equip_level_" .. cur_douqi_cfg.douqi_grade)
	if not self.is_max then
		if next_douqi_cfg then
			local next_bundle, next_asset = ResPath.GetDouqiAsset("equip_level_" .. next_douqi_cfg.douqi_grade)
			self.node_list["ImgNextLevel"].image:LoadSprite(next_bundle, next_asset)
		end
		self.node_list["NextLevelPanel"]:SetActive(true)
		self.node_list["DownFrame"]:SetActive(true)
		self.node_list["TxtGot"].text.text = string.format(Language.Douqi.WantWearBetterEquip, self.douqi_info.douqi_grade + 1)
	else
		self.node_list["NextLevelPanel"]:SetActive(false)
		self.node_list["DownFrame"]:SetActive(false)
		self.node_list["TxtGot"].text.text = Language.Douqi.CanWearMaxEquip
	end
	self.node_list["ImgCurLevel"].image:LoadSprite(cur_bundle, cur_asset)
	self.node_list["ImgLevel"].image:LoadSprite(cur_bundle, cur_asset)

	local cur_have_douqi = self.douqi_info.douqi_exp
	local need_douqi = cur_douqi_cfg.need_exp
	local douqi_color = cur_have_douqi >= need_douqi and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["NeedDesc"].text.text = string.format(Language.Douqi.NeedDouqi, ToColorStr(cur_have_douqi, douqi_color), need_douqi)

	self.node_list["BtnRemind"]:SetActive(false)
	local item_datas = DouQiData.Instance:GetUseItemList() or {}
	for k, v in pairs(item_datas) do
		local have_item = ItemData.Instance:GetItemNumInBagById(v.item_id)
		if 9999 <= v.day_used_limit and have_item > 0 then
			self.node_list["BtnRemind"]:SetActive(true)
			break
		else
			if v.had_use_times < v.day_used_limit and have_item > 0 then
				self.node_list["BtnRemind"]:SetActive(true)
				break
			end
		end
	end
end

function DouqiGradeView:OnBtnUpLevel()
	DouQiCtrl.Instance:OpenUseItemView()
end

function DouqiGradeView:OnBtnBreakUp()
	if nil == self.douqi_info then return end

	if self.is_max then
		TipsCtrl.Instance:ShowSystemMsg(Language.Douqi.MaxLevel)
		return
	end

	local cur_douqi_cfg = DouQiData.Instance:GetDouqiGradeCfg(self.douqi_info.douqi_grade)
	if self.douqi_info.douqi_exp >= cur_douqi_cfg.need_exp then
		DouQiCtrl.Instance:SendCSCrossEquipOpera(CROSS_EQUIP_REQ_TYPE.CROSS_EQUIP_REQ_TYPE_DOUQI_GRADE_UP)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Douqi.NoEnoughDouqiExp)
	end
end

function DouqiGradeView:OnButtonHelp()
	local tips_id = 338
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end