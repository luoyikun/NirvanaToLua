KuaFu1v1ViewFight = KuaFu1v1ViewFight or BaseClass(BaseRender)

function KuaFu1v1ViewFight:__init(instance)
	if instance == nil then
		return
	end
	local name_table = self.node_list["RoleInfo"]:GetComponent(typeof(UINameTable))
	local name_table2 = self.node_list["RoleInfo2"]:GetComponent(typeof(UINameTable))
	self.hp_slider_top_self = name_table:Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom_self = name_table:Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_top_target = name_table2:Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom_target = name_table2:Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))

	self.name_self = U3DObject(name_table:Find("NameTxt"), name_table:Find("NameTxt").transform, self)
	self.level_self = U3DObject(name_table:Find("LevelTxt"), name_table:Find("LevelTxt").transform, self)
	self.icon_self = U3DObject(name_table:Find("IconImg"), name_table:Find("IconImg").transform, self)

	self.name_target = U3DObject(name_table2:Find("NameTxt"), name_table:Find("NameTxt").transform, self)
	self.level_target = U3DObject(name_table2:Find("LevelTxt"), name_table:Find("LevelTxt").transform, self)
	self.icon_target = U3DObject(name_table2:Find("IconImg"), name_table:Find("IconImg").transform, self)

	self.target_obj = nil
	self.listen_hp = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.node_list["RestTimeTxt"].text.text = ""
	PlayerData.Instance:ListenerAttrChange(self.listen_hp)
	self.node_list["ShowRemindImg"]:SetActive(false)
	self:HeadChangeSelf()
	self:FlushBaseInfo()
	KuaFu1v1Ctrl.Instance:SendCross1v1FightReadyReq()
end

function KuaFu1v1ViewFight:OpenCallBack()

end

function KuaFu1v1ViewFight:__delete()
	if self.listen_hp then
		PlayerData.Instance:UnlistenerAttrChange(self.listen_hp)
		self.listen_hp = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.target_obj then
		self.target_obj:DeleteMe()
		self.target_obj = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	
	if self.fight_timer then
		CountDown.Instance:RemoveCountDown(self.fight_timer)
		self.fight_timer = nil
	end

end

function KuaFu1v1ViewFight:StartCountDown()
	if self.count_down then
		return
	end
	self:HeadChangeSelf()
	self:FlushBaseInfo()
	self.node_list["TimeTxt"].text.text = 3
	self.node_list["ShowRemindImg"]:SetActive(true)
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, self.node_list["TimeTxt"]))
end

function KuaFu1v1ViewFight:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	
	if self.fight_timer then
		CountDown.Instance:RemoveCountDown(self.fight_timer)
		self.fight_timer = nil
	end
end

function KuaFu1v1ViewFight:CountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		self:StartFight()
		if callback then
			callback()
		end
	end
	time_obj.text.text = time
end

function KuaFu1v1ViewFight:StartFight()
	self.node_list["ShowRemindImg"]:SetActive(false)
	KuaFu1v1Ctrl.Instance:IsBlockActive()
	self:RemoveCountDown()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	GlobalEventSystem:Fire(KFONEVONE1v1Type.KF_STATUS_CHANGE)

	local servertime = TimeCtrl.Instance:GetServerTime()
	local fight_start = KuaFu1v1Data.Instance:GetCross1v1FightStart()
	local fight_end_timestmap = fight_start.fight_start_timestmap
	local time = fight_end_timestmap - math.ceil(servertime)
	self.node_list["RestTimeTxt"].text.text = time
	self.fight_timer = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self, self.node_list["RestTimeTxt"]))
end

function KuaFu1v1ViewFight:FlushBaseInfo()
	local target_info = KuaFu1v1Data.Instance:GetMatchResult()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if target_info and vo then
		local flag = target_info.side == 1 			--对手是不是在右边
		local target_name = flag and target_info.oppo_name .. "_s" .. target_info.oppo_sever_id or vo.name
		local target_level = flag and "Lv." .. target_info.level or "Lv." .. vo.level
		self.name_target.text.text = target_name
		self.level_target.text.text = target_level

		local self_name = flag and vo.name or target_info.oppo_name .. "_s" .. target_info.oppo_sever_id
		local self_level = flag and "Lv." .. vo.level or "Lv." .. target_info.level
		self.name_self.text.text = self_name
		self.level_self.text.text = self_level
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.target_obj then
		self.target_obj = nil
	end
	self:TimerCallback()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 0.3)
end


function KuaFu1v1ViewFight:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "hp" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local target_info = KuaFu1v1Data.Instance:GetMatchResult()
		local flag = target_info and target_info.side == 1 or false 			--对手是不是在右边
		if vo.max_hp ~= nil and vo.max_hp > 0 then
			self:SetHpPercent(vo.hp / vo.max_hp, flag)
		end
	end
end

-- 目标血量改变
function KuaFu1v1ViewFight:TimerCallback()
	if not self.target_obj then
		self.target_obj = self:GetTargetObj()
	end
	if self.target_obj then
		local target_hp = self.target_obj:GetAttr("hp")
		local target_info = KuaFu1v1Data.Instance:GetMatchResult()
		local flag = target_info and target_info.side == 1 or false 			--对手是不是在右边
		local max_hp = self.target_obj:GetAttr("max_hp")
		if max_hp ~= nil and max_hp > 0 then
			self:SetHpPercent(target_hp / max_hp, not flag)
		end
	end
end

-- 设置目标血条
function KuaFu1v1ViewFight:SetHpPercent(percent, is_self)
	if is_self then
		self.hp_slider_top_self.value = percent
		self.hp_slider_bottom_self:DOValue(percent, 0.8, false)
	else
		self.hp_slider_top_target.value = percent
		self.hp_slider_bottom_target:DOValue(percent, 0.8, false)
	end
end

-- 得到目标obj
function KuaFu1v1ViewFight:GetTargetObj()
	local target_info = KuaFu1v1Data.Instance:GetMatchResult()
	if target_info then
		local role_id = target_info.role_id
		local obj_list = Scene.Instance:GetObjList()
		if obj_list then
			for k,v in pairs(obj_list) do
				if v:IsRole() and not v:IsMainRole() then
					local vo = v:GetVo()
					self:HeadChangeTarget(vo)
					return v
				end
			end
		end
	end
end

function KuaFu1v1ViewFight:ClearInfo()
	self:RemoveCountDown()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

-- 头像更换
function KuaFu1v1ViewFight:HeadChangeSelf()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local target_info = KuaFu1v1Data.Instance:GetMatchResult()
	local is_target_left = target_info and target_info.side == 1 or false 		--对手是不是在右边
	self:SetRoleInfoHeadImage(vo, not is_target_left)
end

-- 对手头像更换
function KuaFu1v1ViewFight:HeadChangeTarget(vo)
	local target_info = KuaFu1v1Data.Instance:GetMatchResult()
	local is_target_left = target_info and target_info.side == 1 or false 		--对手是不是在右边
	self:SetRoleInfoHeadImage(vo, is_target_left)
end

function KuaFu1v1ViewFight:SetRoleInfoHeadImage(vo, is_target_left)
	if is_target_left then
		if vo then
			local bundle, asset = ResPath.GetRoleHeadBig((vo.prof % 10), vo.sex)
			if self.icon_target and self.icon_target.image then
				self.icon_target.image:LoadSprite(bundle, asset)
			end
		end
	else
		if vo then
			CommonDataManager.NewSetAvatar(vo.role_id, self.node_list["portraitRawSelf"], self.icon_self, self.node_list["portraitRawSelf"], vo.sex, vo.prof, true)
		end
	end
end
