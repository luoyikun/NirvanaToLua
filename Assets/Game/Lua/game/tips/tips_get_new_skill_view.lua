TipsGetNewSkillView = TipsGetNewSkillView or BaseClass(BaseView)

local prof_skill = {
	{121, 131, 141, 5},
	{221, 231, 241, 5},
	{321, 331, 341, 5},
	{421, 431, 441, 5},
}

function TipsGetNewSkillView:__init()
	self.ui_config = {{"uis/views/tips/getnewskilltips_prefab", "GetNewSkillTips"}}
	self.delay_time = 1.5
	self.fade_speed = 1.5
	self.move_speed = 90
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_open_newskill = false

	self.timer = 0
end

function TipsGetNewSkillView:__delete()

end

function TipsGetNewSkillView:LoadCallBack()
	self.skill_button_pos_list = MainUICtrl.Instance:GetSkillButtonPosition()
	self.bg = self.node_list["Image"]
	self.frame = self.node_list["Frame"]
	self.skill_icon = self.node_list["SkillIcon"]
	self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.BlockClick, self))
end

function TipsGetNewSkillView:ReleaseCallBack()
	-- 清理变量和对象
	self.bg = nil
	self.frame = nil
	self.skill_icon = nil
	self.target_icon = nil

	if self.timer_hide_quest then
		GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
		self.timer_hide_quest = nil
	end
end

function TipsGetNewSkillView:ShowView(skill_id)
	if skill_id < 100 and skill_id ~= 5 then
		return
	end

	if BianShenData.Instance:CheckIsGeneralSkill(skill_id) then
		return
	end
	
	self.id_value = skill_id
	local skill_cfg = SkillData.GetSkillinfoConfig(self.id_value)
	if skill_cfg == nil then
		return
	end
	self.index = (skill_cfg.skill_index - 1)

	for k,v in pairs(ZHUAN_ZHI_SKILL1) do
		if skill_id == v then
			self.index = 9 		--两个专职技能写死的9和10
			break
		end
	end
	for k,v in pairs(ZHUAN_ZHI_SKILL2) do
		if skill_id == v then
			self.index = 10
			break
		end
	end
	self:Open()
end

function TipsGetNewSkillView:BlockClick()
	if self.fly_flag == false then
		self.fly_flag = true
		if self.timer > 0 then
			if self.timer_hide_quest then
			   GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
			   self.timer_hide_quest = nil
			end
			self.bg:SetActive(false)
			self.frame:SetActive(false)
			self:MoveToTarget()
		end
	end
end

function TipsGetNewSkillView:OpenCallBack()
	local view_manager = ViewManager.Instance
	view_manager:CloseAll()
	if view_manager:IsOpen(ViewName.TaskDialog) then
		view_manager:Close(ViewName.TaskDialog)
	end
	self.fly_flag = false
	self.bg:SetActive(true)
	self.frame:SetActive(true)
	TaskCtrl.Instance:SetAutoTalkState(false)		--停止接受任务
	ViewManager.Instance:CloseAll()					--关闭所有界面
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)				--切换成带技能界面的状态

	local skill_cfg = SkillData.GetSkillinfoConfig(self.id_value)
	self.node_list["TxtName"].text.text = skill_cfg.skill_name

	local icon_id = skill_cfg.skill_icon
	local prof = PlayerData.Instance:GetAttr("prof")
	if skill_cfg.skill_id == 5 then
		local base_prof = PlayerData.Instance:GetRoleBaseProf(prof)
		icon_id = icon_id + base_prof
	end
	self.skill_icon.image:LoadSprite(ResPath.GetRoleSkillIcon(icon_id))
	self.skill_icon:SetActive(true)
	self:CalTimeToHideBg()
	if nil == self.skill_button_pos_list then
		return
	end
	local target = self.skill_button_pos_list[self.index]
	if IS_AUDIT_VERSION then
		self.target_icon = target.transform:FindHard("Icon_url")
	else
		self.target_icon = target.transform:FindHard("Icon")
	end
	self.target_icon.gameObject:SetActive(false)
	self.is_open_newskill = true
end

function TipsGetNewSkillView:GetIsOpenNewSkill()
	return self.is_open_newskill
end

function TipsGetNewSkillView:CloseCallBack()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	GuajiCache.monster_id = 0
	TaskCtrl.Instance:SetAutoTalkState(true)
	self.fly_flag = false
	if self.timer_hide_quest then
		GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
		self.timer_hide_quest = nil
	end
	self.is_open_newskill = false
end


function TipsGetNewSkillView:MoveToTarget()
	local timer = 1
	if nil == self.skill_button_pos_list then
		self:Close()
		self.is_open_newskill = false
		return
	end
	local target = self.skill_button_pos_list[self.index]
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.skill_icon
		local path = {}
		self.target_pos = target.transform.position
		table.insert(path, self.target_pos)
		local tweener = item.transform:DOPath(
			path,
			timer,
			DG.Tweening.PathType.Linear,
			DG.Tweening.PathMode.TopDown2D,
			1,
			nil)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)
		local close_view = function()
			self:Close()
			self.is_open_newskill = false
			self.skill_icon:SetActive(false)
			self.target_icon.gameObject:SetActive(true)
			GlobalTimerQuest:CancelQuest(self.time_quest)
			local main_view = ViewManager.Instance:GetView(ViewName.Main)
			if main_view and main_view.skill_view then
				main_view.skill_view:CheckNuqiEff()
			end
		end
		tweener:OnComplete(close_view)
		item.loop_tweener = tweener
	end, 0)
end

function TipsGetNewSkillView:CalTimeToHideBg()
	if self.timer_hide_quest then
		GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
		self.timer_hide_quest = nil
	end
	self.timer = 1
	self.timer_hide_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			self.bg:SetActive(false)
			self.frame:SetActive(false)
			GlobalTimerQuest:CancelQuest(self.timer_hide_quest)
			self.timer_hide_quest = nil
			self:MoveToTarget()
		end
	end, 0)
end


