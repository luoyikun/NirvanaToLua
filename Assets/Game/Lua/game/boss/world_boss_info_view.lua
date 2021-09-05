WorldBossInfoView = WorldBossInfoView or BaseClass(BaseView)

function WorldBossInfoView:__init()
	self.ui_config = {
		{"uis/views/bossview_prefab", "WorldBossDiceView"}
	}
end

function WorldBossInfoView:__delete()
	
end

function WorldBossInfoView:ReleaseCallBack()
	self.slider1 = nil
	self.slider2 = nil

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil

	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end

	if self.be_select_event then
		GlobalEventSystem:UnBind(self.be_select_event)
		self.be_select_event = nil
	end
	if self.obj_del_event then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end
	if self.obj_dead_event then
		GlobalEventSystem:UnBind(self.obj_dead_event)
		self.obj_dead_event = nil
	end

	self:RemoveCountDown()
	self:PauseTweener()
end

function WorldBossInfoView:LoadCallBack()
	self.slider1 = self.node_list["Slider1"].slider
	self.slider2 = self.node_list["Slider2"].slider

	self.node_list["BtnRoll"].button:AddClickListener(function() self:OnClickRoll(1) end)
	self.node_list["BtnRoll1"].button:AddClickListener(function() self:OnClickRoll(2) end)
	self.node_list["BtnAbandon"].button:AddClickListener(function() self:OnClickAbandon(1) end)
	self.node_list["BtnAbandon1"].button:AddClickListener(function() self:OnClickAbandon(2) end)

	self.node_list["TxtXuQiu1"].text.text = Language.Boss.Toushai
	self.node_list["TxtXuQiu"].text.text = Language.Boss.Toushai
	self.node_list["TxtFangqi1"].text.text = Language.Common.FangQi
	self.node_list["TxtFangqi"].text.text = Language.Common.FangQi
	self.node_list["Txtshengyu1"].text.text = Language.Common.ShengYuShiJian
	self.node_list["Txtshengyu"].text.text = Language.Common.ShengYuShiJian

	-- 监听系统事件
	self.scene_loaded = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,BindTool.Bind(self.OnSceneLoaded, self))
	self.be_select_event = GlobalEventSystem:Bind(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObjHead, self))
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDeleteHead, self))
	self.obj_dead_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDead, self))

	self:ChangeState(false)
	self:ChangeState2(false)

	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end

	self.roll_effective_time = 10
	local world_boss_other_config = BossData.Instance:GetBossOtherConfig()
	if world_boss_other_config then
		self.roll_effective_time = world_boss_other_config.roll_effective_time or 10
	end
	self:OnSceneLoaded()
	self:OnSelectObjHead(nil, nil)
end

function WorldBossInfoView:ChangeState(flag)
	self.node_list["Slider1"]:SetActive(not flag)
	self.node_list["BtnRoll"]:SetActive(not flag)
	self.node_list["BtnAbandon"]:SetActive(not flag)
	self.node_list["TxtTopName1"]:SetActive(flag)
	self.node_list["TxtTopPoint1"]:SetActive(flag)
end

function WorldBossInfoView:ChangeState2(flag)
	self.node_list["Slider2"]:SetActive(not flag)
	self.node_list["BtnRoll1"]:SetActive(not flag)
	self.node_list["BtnAbandon1"]:SetActive(not flag)
	self.node_list["TxtTopName2"]:SetActive(flag)
	self.node_list["TxtTopPoint2"]:SetActive(flag)
end


function WorldBossInfoView:OnSceneLoaded()
	BossCtrl.Instance:SetBossHpInfo()
	self:RemoveCountDown()
	self.node_list["PanelShowBtn"]:SetActive(false)
	self.node_list["PanelShowBtn1"]:SetActive(false)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			if boss_id then
				BossCtrl.Instance:SendWorldBossPersonalHurtInfoReq(boss_id)
				BossCtrl.Instance:SendWorldBossGuildHurtInfoReq(boss_id)
				local config = BossData.Instance:GetBossCfgById(boss_id)
				if config then
					local item_list = config.gift_item
					if item_list then
						local item_id = item_list.item_id
						for i = 1, 2 do
							self.item_cell_list[i]:SetData({item_id = item_id, num = item_list.num, is_bind = item_list.is_bind})
						end
					end
				end
			end
		end
	end
end

function WorldBossInfoView:ClickMap()
	ViewManager.Instance:Open(ViewName.Map)
end

function WorldBossInfoView:CountToString(count)
	if not count then return end
	if count > 9999 and count < 100000000 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count >= 100000000 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	return count
end

function WorldBossInfoView:OnSelectObjHead(target_obj, select_type)
	if nil == target_obj
		or target_obj:GetType() == SceneObjType.MainRole
		or target_obj:GetType() == SceneObjType.TruckObj
		or target_obj:GetType() == SceneObjType.EventObj
		or target_obj:GetType() == SceneObjType.Trigger
		or target_obj:GetType() == SceneObjType.MingRen
		or target_obj:IsNpc()
		or (target_obj.IsGather and target_obj:IsGather())
		or (target_obj:IsMonster() and not target_obj:IsBoss() and target_obj:GetMonsterId() ~= qizhi_id)
		or (target_obj:GetType() == SceneObjType.Monster and target_obj:GetMonsterId() == 1101 and Scene.Instance:GetSceneType() == SceneType.QunXianLuanDou) then
		self.target_obj = nil
		return
	end

	self.target_obj = target_obj
	if self.target_obj == nil then
		return
	end
end

-- 取消
function WorldBossInfoView:OnObjDeleteHead(obj)
	if self.target_obj == obj then
		self.target_obj = nil
	end
end

function WorldBossInfoView:OnObjDead(obj)
	-- self:SetHpPercent(0)
	if self.target_obj == obj then
		self.target_obj = nil
	end
end

function WorldBossInfoView:OnClickRoll(index)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			BossCtrl.Instance:SendWorldBossRollReq(boss_id, index)
		end
	end
end

function WorldBossInfoView:OnClickAbandon(index)
	if index == 1 then
		self.node_list["PanelShowBtn"]:SetActive(false)
	else
		self.node_list["PanelShowBtn1"]:SetActive(false)
	end
end

function WorldBossInfoView:SetCanRoll(index)
	if index == 1 then
		self.node_list["PanelShowBtn"]:SetActive(true)
		self:ChangeState(false)
		self.slider1.value = 0

		if nil == self.count_down1 and nil == self.time_quest1 then
			self.time_quest1 = GlobalTimerQuest:AddDelayTimer(function ()
				self.node_list["PanelShowBtn"]:SetActive(false)
				end, self.roll_effective_time + 2)
			self.count_down1 = CountDown.Instance:AddCountDown(self.roll_effective_time, 0.05,
			function(elapse_time, total_time)
				self.node_list["TxtRestTime1"].text.text = string.format("%.1f", total_time - elapse_time)
				self.node_list["Slider1"].slider.value = elapse_time/total_time
				if total_time - elapse_time <= 0 then
					self.node_list["PanelShowBtn"]:SetActive(false)
					if self.count_down1 then
						CountDown.Instance:RemoveCountDown(self.count_down1)
						self.count_down1 = nil
					end
					self:OnClickAbandon(index)
				end 
			end)
		end

	else
		if self.node_list then
			self.node_list["PanelShowBtn1"]:SetActive(true)
		end
		self:ChangeState2(false)
		self.slider2.value = 0

		if nil == self.count_down2 and nil == self.time_quest2 then
			self.time_quest2 = GlobalTimerQuest:AddDelayTimer(function ()
				self.node_list["PanelShowBtn1"]:SetActive(false)
				end, self.roll_effective_time + 2)
			self.count_down2 = CountDown.Instance:AddCountDown(self.roll_effective_time, 0.05,
			function(elapse_time, total_time) 
				self.node_list["TxtRestTime2"].text.text = string.format("%.1f", total_time - elapse_time)
				self.node_list["Slider2"].slider.value = elapse_time/total_time
				if total_time - elapse_time <= 0 then
					self.node_list["PanelShowBtn1"]:SetActive(false)
					if self.count_down2 then
					CountDown.Instance:RemoveCountDown(self.count_down2)
					self.count_down2 = nil
					end
					self:OnClickAbandon(index)
				end 
			end)
		end
	end
end

function WorldBossInfoView:SetRollResult(point, index)
	if index == 1 then
		self:ChangeState(true)
		if self.count_down1 then
			CountDown.Instance:RemoveCountDown(self.count_down2)
			self.count_down1 = nil
		end
	elseif index == 2 then
		self:ChangeState2(true)
		if self.count_down2 then
			CountDown.Instance:RemoveCountDown(self.count_down2)
			self.count_down2 = nil
		end
	end
end

function WorldBossInfoView:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.Instance:IsWorldBossScene(scene_id) then
			local this_boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			if this_boss_id == boss_id then
				if self.node_list then
					if hudun_index == 1 then
						self.node_list["TxtTopPoint1"].text.text = string.format(Language.Boss.WorldBossPoint, top_roll_point)
						self.node_list["TxtTopName1"].text.text = string.format(Language.Boss.WorldBossInfoMexValue, top_roll_name)
					elseif hudun_index == 2 then
						self.node_list["TxtTopPoint2"].text.text = string.format(Language.Boss.WorldBossPoint, top_roll_point)
						self.node_list["TxtTopName2"].text.text = string.format(Language.Boss.WorldBossInfoMexValue, top_roll_name)
					end
				end
			end
		end
	end
end

function WorldBossInfoView:RemoveCountDown()
	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end
	if self.time_quest2 then
		GlobalTimerQuest:CancelQuest(self.time_quest2)
		self.time_quest2 = nil
	end
	if self.count_down1 then
		CountDown.Instance:RemoveCountDown(self.count_down1)
		self.count_down1 = nil
	end
	if self.count_down2 then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
end

function WorldBossInfoView:PauseTweener()
	if self.count_down1 then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down1 = nil
	end
	if self.count_down2 then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
end
