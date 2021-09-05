MarriageBiaoBaiView = MarriageBiaoBaiView or BaseClass(BaseRender)

function MarriageBiaoBaiView:__init()

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.lover_model = RoleModel.New()
	self.lover_model:SetDisplay(self.node_list["LoverDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["FightPower2"])
	self.fight_text3 = CommonDataManager.FightPower(self, self.node_list["FightPower3"])

	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnClickBiaobai, self))
	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	local event_trigger = self.node_list["RotateEventTriggerLover"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragLover, self))

	BiaoBaiQiangCtrl.Instance:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_LEVEL_INFO)
end

function MarriageBiaoBaiView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.lover_model then
		self.lover_model:DeleteMe()
		self.lover_model = nil
	end
	self.fight_text = nil
	self.fight_text2 = nil
	self.fight_text3 = nil
end

function MarriageBiaoBaiView:OnRoleDragSelf(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageBiaoBaiView:OnRoleDragLover(data)
	if self.lover_model then
		self.lover_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageBiaoBaiView:OnFlush(param_t)
	self:FlushDisPlay()
	local info = MarriageData.Instance:GetBiaoBaiInfo()
	if not info then return end

	self:FlushRightView(info.my_exp, info.my_grade, info.other_grade)
	self.node_list["TxtBiaoBaiLevel"].text.text = string.format(Language.Marriage.BiaobaiLevel, info.my_grade)
	self.node_list["TxtLoverBiaoBaiLevel"].text.text = string.format(Language.Marriage.BiaobaiLevel, info.other_grade)
end

function MarriageBiaoBaiView:OnClickBiaobai()
	if ViewManager.Instance:IsOpen(ViewName.BiaoBaiQiang) then
		ViewManager.Instance:Close(ViewName.Marriage)
	else
		ViewManager.Instance:Open(ViewName.BiaoBaiQiang)
	end
end

function MarriageBiaoBaiView:FlushDisPlay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo = {}
	role_vo.prof = main_role_vo.prof
	role_vo.sex = main_role_vo.sex
	role_vo.appearance = {}
	role_vo.appearance.fashion_body = 2
	self.model:SetModelResInfo(role_vo, true, true, true, true)	

		--有伴侣才加载伴侣模型
	GlobalTimerQuest:AddDelayTimer(function()
		if main_role_vo.lover_uid > 0 then
			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_body = 2
			self.lover_model:SetModelResInfo(lover_vo, true, true, true, true)
		end
	end, 0)
	local sex = GameVoManager.Instance:GetMainRoleVo().sex ~= 0
	self.node_list["Img1"]:SetActive(sex)
	self.node_list["Img2"]:SetActive(not sex)
	self.node_list["ImgLover"]:SetActive(not (main_role_vo.lover_uid > 0))	
end

function MarriageBiaoBaiView:FlushRightView(exp, level, lover_level)
	local cfg = MarriageData.Instance:GetBiaoBaiCfgByLevel(level)
	if not cfg then return end

	self.node_list["Hp"].text.text =  ToColorStr(cfg.maxhp or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["Gongji"].text.text = ToColorStr(cfg.gongji or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["Fangyu"].text.text = ToColorStr(cfg.fangyu or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["Baoji"].text.text = ToColorStr(cfg.baoji or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["MingZhong"].text.text = ToColorStr(cfg.mingzhong or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["ShanBi"].text.text = ToColorStr(cfg.shanbi or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["KangBao"].text.text = ToColorStr(cfg.jianren or 0, TEXT_COLOR.ORANGE_4)
	if self.fight_text and self.fight_text.text and self.fight_text3 and self.fight_text3.text then
		local fight = CommonDataManager.GetCapability(cfg)
		self.fight_text.text.text = fight
		self.fight_text3.text.text = fight
	end

	local lover_cfg = MarriageData.Instance:GetBiaoBaiCfgByLevel(lover_level)
	if lover_cfg then
		if self.fight_text2 and self.fight_text2.text then
			self.fight_text2.text.text = CommonDataManager.GetCapability(lover_cfg)
		end
	end

	self.node_list["ProTxt"].text.text = exp .. " / " .. cfg.exp
	self.node_list["ProgressBG"].slider.value = exp/cfg.exp

	local max_level = MarriageData.Instance:GetMaxBiaoBaiLevel() or 200
	if level >= max_level then
		self.node_list["ProgressBG"].slider.value = 1
		self.node_list["ProTxt"].text.text = Language.Common.YiMan
	end
end