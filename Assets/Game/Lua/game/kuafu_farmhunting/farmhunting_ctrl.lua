require("game/kuafu_farmhunting/farmhunting_data")
require("game/kuafu_farmhunting/farmhunting_scene_view")
-- 多人塔防
FarmHuntingCtrl = FarmHuntingCtrl or BaseClass(BaseController)

function FarmHuntingCtrl:__init()
	if FarmHuntingCtrl.Instance ~= nil then
		ErrorLog("[FarmHuntingCtrl] Attemp to create a singleton twice !")
	end
	FarmHuntingCtrl.Instance = self
	self.data = FarmHuntingData.New()
	self.view = FarmHuntingSceneView.New(ViewName.FarmSceneView)

	self:RegisterAllProtocols()
	self.main_role_use_kill_calback = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind1(self.OnMainRoleUseSkill, self))
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
	BindTool.Bind(self.OnChangeScene, self))
end

function FarmHuntingCtrl:RegisterAllProtocols()
	-- 跨服秋收牧场
	self:RegisterProtocol(SCCrossPasturePlayerInfo, "OnCrossPasturePlayerInfo")
	self:RegisterProtocol(SCCrossPastureRankInfo, "OnSCCrossPastureRankInfo")
	self:RegisterProtocol(SCCPPlayerHasAttachAnimalNotic, "OnCPPlayerHasAttachAnimalNotic")
end

function FarmHuntingCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	FarmHuntingCtrl.Instance = nil

	GlobalEventSystem:UnBind(self.main_role_use_kill_calback)
end

function FarmHuntingCtrl:OnChangeScene()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.FarmHunting then
		FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBossIcon, self, 1))
	end
end

function FarmHuntingCtrl:OnClickBossIcon()

	local info = self.data:GetFarmHountingInfo()
	if nil == next(info) then return end

	local monster_id = self.data:GetMonsterID()

	local boss_flush_time = math.floor(info.special_monster_refresh_time - TimeCtrl.Instance:GetServerTime())
	if boss_flush_time > 0 then return end

	local monster_id = self.data:GetMonsterID()
	local x, y = self.data.Instance:GetMonsterPos()
	if x and y then
		self:MoveToPosOperateFight(x, y)
	end
end

function FarmHuntingCtrl:MoveToPosOperateFight(x, y)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_id = FarmHuntingData.Instance:GetMonsterID()
	GuajiCtrl.Instance:CancelSelect()
	GuajiCtrl.Instance:ClearAllOperate()
	MoveCache.param1 = boss_id
	GuajiCache.monster_id = boss_id
	-- MoveCache.end_type = MoveEndType.FightByMonsterId

	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.end_type = MoveEndType.FightByMonsterId
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 3, 0)
end


-- 打开副本底部技能面板
function FarmHuntingCtrl:FbSkillOpen()
	self.view:Open()
end

-- 关闭副本底部技能面板
function FarmHuntingCtrl:FbSkillClose()
	self.view:Close()
end

function FarmHuntingCtrl:OnMainRoleUseSkill(skill_id)
	if SceneType.FarmHunting == Scene.Instance:GetSceneType() then
		if self.data:GetFarmSkillIndex(skill_id) >= 0 then
			self.view:Flush("flush_skill_cd", {skill_id = skill_id})
		end
	end
end

-- 跨服秋收牧场
function FarmHuntingCtrl:OnCrossPasturePlayerInfo(protocol)
	self.data:OnFarmHountingInfo(protocol)
	self.view:Flush("flush_task_panel")
	-- self.view:Flush("show_forward_btn", {is_show = false})
end

function FarmHuntingCtrl:OnSCCrossPastureRankInfo(protocol)
	self.data:SetCrossRankInfo(protocol)
	self.view:Flush("flush_rank_panel")
end


-- 跨服秋收牧场
function FarmHuntingCtrl:OnCPPlayerHasAttachAnimalNotic(protocol)
	GuajiCtrl.Instance:StopGuaji()
	if protocol.notic_reason == 0 then
		local x, y = FarmHuntingData.Instance:GetNearRongluPoint()
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 0, 0)
	elseif protocol.notic_reason == 1 then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.FarmElves.BeRobbedTips, protocol.robber_name))
	end
	self.data:OnFarmHountingInfo(protocol)
	-- self.view:Flush("show_forward_btn", {is_show = protocol.notic_reason == 0})
	FarmHuntingData.Instance:SetBtnStatus(protocol.notic_reason == 0)
	GlobalEventSystem:Fire(MainUIEventType.ROLE_SKILL_CHANGE)
end
