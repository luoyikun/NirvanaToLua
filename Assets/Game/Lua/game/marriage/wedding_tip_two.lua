WeddingTipsTwoView = WeddingTipsTwoView or BaseClass(BaseView)

function WeddingTipsTwoView:__init()
	self.ui_config = {
		{"uis/views/marriageview_prefab","WeddingTips2"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
	self.item_list = {}
end

function WeddingTipsTwoView:__delete()

end

function WeddingTipsTwoView:LoadCallBack()
	self.fight_power = self.node_list["FightPowerText"]
	self.title = self.node_list["Title"]
	self.self_display = self.node_list["SelfDisplay"]
	self.lover_display = self.node_list["LoverDisplay"]


	for i=1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["RingItem" .. i])
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close,self))
	self.title.button:AddClickListener(BindTool.Bind(self.OnClickTitle,self))
end

function WeddingTipsTwoView:ReleaseCallBack()
	TitleData.Instance:ReleaseTitleEff(self.node_list["Title"])
	if self.self_model then
		self.self_model:DeleteMe()
		self.self_model = nil
	end

	if self.love_model then
		self.love_model:DeleteMe()
		self.love_model = nil
	end


	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.fight_power = nil
	self.title = nil
	self.self_display = nil
	self.lover_display = nil
end

function WeddingTipsTwoView:OpenCallBack()
	self:Flush()
end

function WeddingTipsTwoView:OnFlush()
	local wedding_index = MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_FESTIVA.index - 1
	local wedding_info = MarriageData.Instance:GetHunliInfoByType(wedding_index)
	if next(wedding_info) == nil then
		return
	end

	-- 刷新右边内容
	for k ,v in ipairs(self.item_list) do
		if wedding_info.reward_type[k-1] then
			v:SetData(wedding_info.reward_type[k-1])
			v:SetParentActive(true)
		else
			v:SetParentActive(false)
		end
	end

	local bundle, asset = ResPath.GetTitleIcon(wedding_info.title_id)
	self.title.image:LoadSprite(bundle, asset .. ".png")
	TitleData.Instance:LoadTitleEff(self.title, wedding_info.title_id, true)
	local power_value = MarriageData.Instance:GetMarriageTipPower(wedding_index, WEDDING_TIPS_POWER_TYPE.SECONDGEAR)
	self.fight_power.text.text = power_value * 2

	-- 刷新左边内容
	self:FlushDisPlay()
end

function WeddingTipsTwoView:OnClickCloseView()
	self:Close()
end

function WeddingTipsTwoView:InitDisPlay()
	if not self.self_model then
		self.self_model = RoleModel.New()
		self.self_model:SetDisplay(self.self_display.ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if not self.love_model then
		self.love_model = RoleModel.New()
		self.love_model:SetDisplay(self.lover_display.ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
end

function WeddingTipsTwoView:FlushDisPlay()
	self:InitDisPlay()
	local wedding_info = MarriageData.Instance:GetHunliInfoByType(MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_FESTIVA.index - 1)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if next(wedding_info) == nil or next(main_role_vo) == nil then
		return
	end

	-- 设置自己的模型
	-- 第二档配置第二个为时装，故写死reward_type读第二个
	local my_prof =  PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
	local res_id = FashionData.GetFashionResByItemId(wedding_info.reward_type[1].item_id, main_role_vo.sex, my_prof) or 0
	self.self_model:SetRoleResid(res_id)

	-- 设置伴侣的模型
	local lover_sex = main_role_vo.sex == GameEnum.FEMALE and GameEnum.MALE or GameEnum.FEMALE
	local lover_prof = main_role_vo.sex == GameEnum.FEMALE and GameEnum.ROLE_PROF_1 or GameEnum.ROLE_PROF_3
	local prof = MarriageData.Instance:GetLoverProf()
	lover_prof = MarriageData.Instance:IsMarred() and prof or lover_prof
	local res_id = FashionData.GetFashionResByItemId(wedding_info.reward_type[1].item_id, lover_sex, lover_prof) or 0
	self.love_model:SetRoleResid(res_id)
end

function WeddingTipsTwoView:OnClickTitle()
	local wedding_info = MarriageData.Instance:GetHunliInfoByType(MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_FESTIVA.index - 1)
	local title_info = TitleData.Instance:GetUpgradeCfg(wedding_info.title_id)
	if next(wedding_info) == nil or title_info == nil or next(title_info) == nil then
		return
	end

	TipsCtrl.Instance:OpenItem({item_id = title_info.stuff_id})
end