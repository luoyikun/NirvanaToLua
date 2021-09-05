FarmHuntingSceneView = FarmHuntingSceneView or BaseClass(BaseView)

local Skill_Count = 4
local Monster_Type_Count = 5

function FarmHuntingSceneView:__init()
	self.ui_config = {{"uis/views/farmhunting_prefab", "FarmHunting"}}
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配

	self.skill_item_list = {}
	self.reward_item_list = {}
	self.rank_item_list = {}
	self.skill_count = Skill_Count
	self.monster_type_count = Monster_Type_Count
end

function FarmHuntingSceneView:ReleaseCallBack()
	for k,v in pairs(self.skill_item_list) do
		v:DeleteMe()
	end
	self.skill_item_list = {}

	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k,v in pairs(self.rank_item_list) do
		v:DeleteMe()
	end
	self.rank_item_list = {}

	if self.rotate_tween then
		self.rotate_tween:Pause()
		self.rotate_tween = nil
	end
	GlobalEventSystem:UnBind(self.show_or_hide_other_button)
end

function FarmHuntingSceneView:LoadCallBack()
	-- self.node_list["btn_open"].toggle:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	-- self.node_list["ImgQianwang"].button:AddClickListener(BindTool.Bind(self.OnClickForward, self))

	self.node_list["BtnScore"].toggle:AddClickListener(BindTool.Bind(self.ClickScore, self))
	self.node_list["BtnRank"].toggle:AddClickListener(BindTool.Bind(self.ClickRank, self))

	local farm_skill_list = FarmHuntingData.Instance:GetCrossPastureSkillCfg()
	for i = 1, self.skill_count do
		local farm_skill_cfg = farm_skill_list[i]
		local skill_item = FarmHuntingSkillItem.New(self.node_list["Skill" .. i])
		skill_item:SetData(farm_skill_cfg)
		self.skill_item_list[i] = skill_item
	end

	local monster_list = FarmHuntingData.Instance:GetMonsterList()
	for i = 1, self.monster_type_count do
		local farm_monster_cfg = monster_list[i] or {}
		local monster_id = farm_monster_cfg.monster_id or 0
		local monster_cfg = BossData.Instance:GetMonsterInfo(monster_id) or {}
		local monster_type_name = monster_cfg.name

		self.node_list["TextScoreType" .. i].text.text = string.format(Language.KuaFuFramhunting.TypeName, monster_type_name, farm_monster_cfg.score or 0)
	end

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:FlushTabHl(true)
	FuBenCtrl.Instance:SetMonsterIconState(true)
	self:InitRankScroller()
	self:ShowRewardItem()


	self:FlushPlayerRank()

	local canvas = self.node_list["FarmHunting"]:GetComponent(typeof(UnityEngine.Canvas))
	canvas.overrideSorting = false
end

function FarmHuntingSceneView:OpenCallBack()
	self.special_monster_refresh_time = -1
end

function FarmHuntingSceneView:ShowRewardItem()
	local item_cfg = self:GetRewardCfg()
	for i = 1 , 3 do 
		local reward_item = ItemCell.New()
		reward_item:SetInstanceParent(self.node_list["ItemRoot" .. i])
		reward_item:SetData(item_cfg[i - 1])
		self.reward_item_list[i] = reward_item
	end
end

function FarmHuntingSceneView:GetRewardCfg()
	local reward_info = FarmHuntingData.Instance:GetShowRewardCfg()
	return reward_info
end

function FarmHuntingSceneView:ClickScore()
	self:FlushTabHl(true)
end

function FarmHuntingSceneView:ClickRank()
	self:FlushTabHl(false)
end

function FarmHuntingSceneView:SetCdBySkillCD(skill_id)
	local skill_cfg =  FarmHuntingData.Instance:GetRoleSkillCfgBySkillId(skill_id)
	for k,v in pairs(self.skill_item_list) do
		if v:GetData() and v:GetData().skill_id == skill_id and skill_cfg then
			v:SetSkillCd(skill_id, skill_cfg.cd_s)
			break
		end
	end
end

function FarmHuntingSceneView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "flush_skill_cd" then
			self:SetCdBySkillCD(v.skill_id or 0)
		elseif k == "flush_task_panel" then
			self:FlsuhTaskPanel()
			self:SetSpeicalMonsterInfo()
		elseif k == "show_forward_btn" then
			-- self.node_list["BtnQianwang"]:SetActive(v.is_show)
		elseif k == "flush_rank_panel" then
			self:FlushRankScorller()
			self:FlushPlayerRank()
		end
	end
end

function FarmHuntingSceneView:FlsuhTaskPanel()
	local farm_data = FarmHuntingData.Instance:GetFarmHountingInfo()
	self.node_list["TxtLeiJi"].text.text = string.format(Language.KuaFuFramhunting.TotalScore, farm_data.score)
	self.node_list["TxtShengYu"].text.text = string.format(Language.KuaFuFramhunting.LeftTime, farm_data.left_get_score_times)
end

function FarmHuntingSceneView:FlushTabHl(show_score)
	self.node_list["ScoreHL"]:SetActive(show_score)
	self.node_list["RankHL"]:SetActive(not show_score)
end

function FarmHuntingSceneView:SetSpeicalMonsterInfo()
	local info = FarmHuntingData.Instance:GetFarmHountingInfo()
	local monster_id = FarmHuntingData.Instance:GetMonsterID()
	if nil == next(info) or self.special_monster_refresh_time == info.special_monster_refresh_time then
		return
	end
	self.special_monster_refresh_time = info.special_monster_refresh_time

	local boss_flush_time = math.floor(info.special_monster_refresh_time - TimeCtrl.Instance:GetServerTime())
	FuBenCtrl.Instance:SetMonsterDiffTime(boss_flush_time)
	if nil ~= monster_id then
		FuBenCtrl.Instance:SetMonsterInfo(monster_id)
	end
	FuBenCtrl.Instance:SetMonsterIconState(true)

	local str = string.format(Language.FarmElves.GoAndHunt)
	FuBenCtrl.Instance:ShowMonsterHadFlush(boss_flush_time <= 0 , str, 1)
end

function FarmHuntingSceneView:InitRankScroller()
	local list_delegate = self.node_list["RankScroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTreasureBoxCell, self)
end

function FarmHuntingSceneView:GetNumberOfCells()
	--排行信息
	local rank_list = FarmHuntingData.Instance:GetRankListInfo()
	return #rank_list
end

function FarmHuntingSceneView:FlushRankScorller()
	if self.node_list["RankScroller"] and self.node_list["RankScroller"].scroller.isActiveAndEnabled then
		self.node_list["RankScroller"].scroller:ReloadData(0)
	end
end

function FarmHuntingSceneView:RefreshTreasureBoxCell(cell, cell_index)
	local box_cell = self.rank_item_list[cell]
	if box_cell == nil then
		box_cell = FarmRankItem.New(cell.gameObject, self)
		self.rank_item_list[cell] = box_cell
	end
	cell_index = cell_index + 1
	box_cell:SetIndex(cell_index)
	box_cell:Flush()
end

function FarmHuntingSceneView:OnClickOpen()
	-- local rotate =self.node_list["btn_open"].toggle.isOn and 45 or 0
	-- 	self.rotate_tween =self.node_list["btn_open"].transform:DOLocalRotate(
	-- 	Vector3(0, 0, rotate), 0.5, DG.Tweening.RotateMode.FastBeyond360)
end


function FarmHuntingSceneView:OnClickForward()
	local x, y = FarmHuntingData.Instance:GetNearRongluPoint()
	GuajiCtrl.Instance:StopGuaji()
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 0, 0)
end

function FarmHuntingSceneView:SwitchButtonState(enable)
	self.node_list["TowerDefendFBInFoView"]:SetActive(enable)
	self.node_list["BtnSkillControl"]:SetActive(enable)
end

function FarmHuntingSceneView:FlushPlayerRank()
	local rank_info = FarmHuntingData.Instance:GetMainRoleRankInfo()
	local main_role_name = GameVoManager.Instance:GetMainRoleVo().name

	self.node_list["TxtMyRank"].text.text = string.format(Language.KuaFuFramhunting.TxtRank, rank_info.rank)
	self.node_list["TxtMyScore"].text.text = string.format(Language.KuaFuFramhunting.TxtScore, rank_info.score)
end

-----------------HuntingSkillItem------------------
FarmHuntingSkillItem = FarmHuntingSkillItem or BaseClass(BaseRender)

function FarmHuntingSkillItem:__init(index)
	self.node_list["ButtonHu"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, i, farm_skill_cfg, role_skill_cfg))
	self.in_skill_cd = 0
end

function FarmHuntingSkillItem:__delete()
	self:StopCountDown()
	self.in_skill_cd = 0
end

function FarmHuntingSkillItem:GetData()
	return self.data
end

function FarmHuntingSkillItem:SetData(data, cell_index)
	if nil == data then return end
	if nil ~= self.data and self.data.skill_id == data.skill_id then return end

	local role_skill_cfg = FarmHuntingData.Instance:GetRoleSkillCfgBySkillId(data.skill_id)
	if nil == role_skill_cfg then
		return
	end

	self.data = data
	local skill_name = role_skill_cfg.skill_name
	self.node_list["ButtonHuText"].text.text = skill_name

	self.node_list["BtnHuImg"].image:LoadSprite(ResPath.GetRoleSkillIcon(data.skill_id))
end

function FarmHuntingSkillItem:OnClickSkill()
	local skill_index = self.data.index
	local role_skill_cfg = FarmHuntingData.Instance:GetRoleSkillCfgBySkillId(self.data.skill_id)

	if nil == self.data or nil == role_skill_cfg then
		return
	end

	local skill_id = self.data.skill_id
	local distance = role_skill_cfg.distance
	local is_need_target = self.data.is_need_target == 1

	if self.in_skill_cd == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
		return
	end


	if is_need_target then
		local target_obj = GuajiCtrl.Instance:SelectAtkTarget(true)
		if target_obj then
			if 3 == skill_index and target_obj:GetType() ~= SceneObjType.Monster then
				return
			end
			local x, y = target_obj:GetLogicPos()
			GuajiCtrl.Instance:DoFightByClick(skill_id, target_obj, true)
		end
	end

	if not is_need_target then
		local main_role = Scene.Instance:GetMainRole()
		local x, y = main_role:GetLogicPos()

		FightCtrl.SendPerformSkillReq(2, 1, x, y, main_role:GetObjId(), 1, x, y)

	end
end


--设置技能CD byindex
function FarmHuntingSkillItem:SetSkillCd(skill_id, cd)
	local function updateCd(elapse_time, total_time)
		self.in_skill_cd = 1
		self.node_list["CDMask"]:SetActive(true)
		self.node_list["CDMask"]:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = 1 - elapse_time / total_time

	end

	local function completeCd()
		self.in_skill_cd = 0
		self.node_list["CDMask"]:SetActive(false)
	end

	if self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
	self.count_down = CountDown.Instance:AddCountDown(cd, 0.1, updateCd, completeCd)
end

function FarmHuntingSkillItem:StopCountDown()
	self.node_list["CDMask"]:SetActive(false)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-----------------HuntingSkillItem------End------------



-----------------FarmRankItem------------------=
FarmRankItem = FarmRankItem or BaseClass(BaseCell)

function FarmRankItem:__init(index)

end

function FarmRankItem:__delete()

end

function FarmRankItem:GetData()

end

function FarmRankItem:OnFlush()
	local rank_info = FarmHuntingData.Instance:GetRankInfoByIndex(self.index)

	self.node_list["Name"].text.text = rank_info ~= nil and rank_info.name or "苍星"
	self.node_list["Rank"].text.text = rank_info ~= nil and rank_info.rank or "1"
	self.node_list["ScoreNum"].text.text = rank_info ~= nil and rank_info.score or "520"

	if rank_info then
		if rank_info.rank <= 3 then
			local bundle, asset = ResPath.GetRankIcon(rank_info.rank)
			self.node_list["Rank"]:SetActive(false)
			self.node_list["Img_rank"]:SetActive(true)
			self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
		else
			self.node_list["Img_rank"]:SetActive(false)
			self.node_list["Rank"]:SetActive(true)
			self.node_list["Rank"].text.text = rank_info.rank
		end
	end
end
-----------------FarmRankItem-----------End-------