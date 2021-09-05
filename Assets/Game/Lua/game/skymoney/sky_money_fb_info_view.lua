SkyMoneyFBInfoView = SkyMoneyFBInfoView or BaseClass(BaseView)

local COLLECT_TASK = 1
local KILL_TASK = 2
local MAX_TASK_NUM = 10

local MAX_BIG_QIANDUODUO_NUM = 1

SkyMoneyAutoTaskEvent = {
	CancelHightLightFunc = nil,
}

function SkyMoneyFBInfoView:__init()
	self.ui_config = {{"uis/views/skymoney_prefab", "SkyMoneyFBInFoView"}}
	self.cur_task_num = nil
	self.task_item_list = {}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.cur_gather_id = -1

	self.is_auto_gather = false
	self.is_click_auto_task = true
end

function SkyMoneyFBInfoView:__delete()
	self.cur_task_type = nil
	self.cur_task_cfg = nil
end

function SkyMoneyFBInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.task_item_list) do
		v:DeleteMe()
	end
	self.task_item_list = {}

	-- 清理变量和对象

	self.task_item_list = nil
	self.do_task_btn = nil
end

function SkyMoneyFBInfoView:CloseCallBack()
	self.cur_task_type = nil
	self.cur_task_cfg = nil
	self.cur_task_id = nil
	self.cur_param_value = nil
	self.gather_obj_id = 0

	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.star_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.star_gather_event)
		self.star_gather_event = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.money_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.money_count_down)
		self.money_count_down = nil
	end

	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

end

function SkyMoneyFBInfoView:OpenCallBack()
	if self.global_event == nil then
		self.global_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
			BindTool.Bind(self.OnStopGather, self))
	end

	self.star_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))

	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))

	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBig, self), 2)
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.FightSmallQianDuoDuo, self))

	self.is_click_auto_task = true

	self:Flush()
end

function SkyMoneyFBInfoView:LoadCallBack()

	self.node_list["RewardNode"].button:AddClickListener(BindTool.Bind(self.OnClickTaskList, self))
	self.node_list["DoTaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTaskList, self))
	self.node_list["BigTxr"].button:AddClickListener(BindTool.Bind(self.OnClickBig, self))

	self.task_item_list = {}
	for i = 1, 3 do
		self.task_item_list[i] = ItemCell.New()
		self.task_item_list[i]:SetInstanceParent(self.node_list["TaskItem"..i])
	end
	-- self.do_task_btn = self.node_list["DoTaskBtn"]
	if self.show_or_hide_other_button == nil then
		self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	end
end

-- 去找小钱多多
function SkyMoneyFBInfoView:FightSmallQianDuoDuo()
	local qianduoduo_cfg = SkyMoneyData.Instance:GetSkyMoneyCfg().qianduoduo[1]
	local x, y = self:GetMonsterPos(qianduoduo_cfg.qingduoduo_id)
	if x and y then
		self:MoveToPosOperateFight(qianduoduo_cfg.qingduoduo_id, x, y)
	end
end

-- 获取打怪的位置
function SkyMoneyFBInfoView:GetMonsterPos(moster_id)
	local target_distance = 1000 * 1000
	local target_x = nil
	local target_y = nil
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local obj_move_info_list = Scene.Instance:GetObjMoveInfoList()
	local monster_list = Scene.Instance:GetMonsterList()


	for k, v in pairs(monster_list) do
		local vo = v:GetVo()
		if BaseSceneLogic.IsAttackMonster(vo.monster_id) and vo.monster_id == moster_id and not AStarFindWay:IsBlock(vo.pos_x, vo.pos_y) then
			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	if nil ~= target_x and nil ~= target_y then
		return target_x, target_y
	end

	for k, v in pairs(obj_move_info_list) do
		local vo = v:GetVo()
		if vo.obj_type == SceneObjType.Monster and BaseSceneLogic.IsAttackMonster(vo.type_special_id)
		and vo.type_special_id == moster_id and not AStarFindWay:IsBlock(vo.pos_x, vo.pos_y) then
			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	return target_x, target_y
end

function SkyMoneyFBInfoView:MoveToPosOperateFight(monster_id, x, y)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	self.node_list["TasImg"]:SetActive(false)
	self.is_auto_gather = false
	self.gather_obj_id = 0
	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()
	local curr_task_cfg = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(sky_money_info.curr_task_id)
	if nil == curr_task_cfg or sky_money_info.curr_task_param >= curr_task_cfg.param_count then
		self.node_list["ArrowImg"]:SetActive(false)
	else
		self.node_list["ArrowImg"]:SetActive(true)
	end
	self.is_click_auto_task = false

	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.param1 = monster_id
	GuajiCache.monster_id = monster_id
	MoveCache.end_type = MoveEndType.FightByMonsterId
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 2, 1)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end

-- 去找大钱多多
function SkyMoneyFBInfoView:OnClickBig()
	local qianduoduo_cfg = SkyMoneyData.Instance:GetSkyMoneyCfg().big_qianduoduo[1]
	local x, y = self:GetMonsterPos(qianduoduo_cfg.bigqian_id)
	if x and y then
		self:MoveToPosOperateFight(qianduoduo_cfg.bigqian_id, x, y)
	end
end

function SkyMoneyFBInfoView:OnStopGather(role_obj_id)
	local main_role = Scene.Instance:GetMainRole()
	local obj_id = main_role:GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	self.is_auto_gather = false
end

function SkyMoneyFBInfoView:OnObjDelete(obj)
	local main_role = Scene.Instance:GetMainRole()

	if obj and obj:IsGather() and obj:GetGatherId() == self.cur_gather_id and self.is_auto_gather and self.gather_obj_id == obj:GetObjId() then
		self.is_auto_gather = false
		GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.2)
	end
end

function SkyMoneyFBInfoView:OnStartGather(role_obj_id, gather_obj_id)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end

	local gather_obj = Scene.Instance:GetObjectByObjId(gather_obj_id)
	local gather_id = gather_obj and gather_obj:GetGatherId() or 0

	if self.cur_gather_id == gather_id then
		self.is_auto_gather = true
		self.gather_obj_id = gather_obj_id
	end
end

function SkyMoneyFBInfoView:AutoDoTask()
	if not self.is_click_auto_task then
		return
	end

	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()
	local curr_task_cfg = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(sky_money_info.curr_task_id)
	if nil == curr_task_cfg or sky_money_info.curr_task_param >= curr_task_cfg.param_count then
		self.node_list["TasImg"]:SetActive(false)
		SkyMoneyAutoTaskEvent.CancelHightLightFunc = nil
		self.node_list["ArrowImg"]:SetActive(false)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
	local scene_gather_list = {}

	local x, y, id = 0, 0, 0
	local end_type = MoveEndType.GatherById
	local target = {}
	local list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	if self.cur_task_type == KILL_TASK then
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.FightByMonsterId
	end

	local gather_list = SkyMoneyData.Instance:GetSceneGatherListById(self.cur_task_cfg.param_id)

	list = self.cur_task_type ~= KILL_TASK and (next(gather_list) and gather_list or list) or list

	for k, v in pairs(list) do
		if self.cur_task_cfg ~= nil and self.cur_task_cfg.param_id == v.id then
			if not AStarFindWay:IsBlock(v.x, v.y) then
				local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
				if distance < target_distance then
					x = v.x
					y = v.y
					target_distance = distance
					id = v.id
				end
			end
		end
	end

	target = {scene = scene_id, x = x, y = y, id = id}
	MoveCache.end_type = end_type
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCache.monster_id = target.id

	self.cur_gather_id = target.id
	self.node_list["TasImg"]:SetActive(true)
	self.node_list["ArrowImg"]:SetActive(false)

	local click_call_back = function()
		self.node_list["TasImg"]:SetActive(false)
		self.node_list["ArrowImg"]:SetActive(true)
	end

	SkyMoneyAutoTaskEvent.CancelHightLightFunc = function()
		self.node_list["TasImg"]:SetActive(false)
		self.is_auto_gather = false
		self.gather_obj_id = 0
		self.node_list["ArrowImg"]:SetActive(true)
		self.is_click_auto_task = false
	end
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 1.5, 0)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end

function SkyMoneyFBInfoView:OnClickTaskList()
	self.is_click_auto_task = true
	self:AutoDoTask()
end

function SkyMoneyFBInfoView:SetInfo()
	local sky_money_info = SkyMoneyData.Instance:GetSkyMoneyInfo()

	local task_reward_cfg = SkyMoneyData.Instance:GetTaskRewardByCurTaskNum(sky_money_info.has_finish_task_num)
	self.node_list["SamllTxt"].text.text = string.format(Language.SkyMoney.SmallReward, task_reward_cfg.complete_task_num)
	if task_reward_cfg.complete_task_num and task_reward_cfg.complete_task_num > sky_money_info.has_finish_task_num then
		self.node_list["ShowBigCurTxt"].text.text = string.format(Language.TianJianCaiBao.Award,sky_money_info.has_finish_task_num,task_reward_cfg.complete_task_num)
	else
		self.node_list["ShowBigCurTxt"].text.text = string.format(Language.TianJianCaiBao.Award,sky_money_info.has_finish_task_num,task_reward_cfg.complete_task_num)
		self.node_list["SamllTxt"].text.text = Language.SkyMoney.FinishTask
	end

	local cur_task_cfg = SkyMoneyData.Instance:GetSkyMoneyTaskCfgById(sky_money_info.curr_task_id) or {}
	self.cur_task_cfg = cur_task_cfg
	local config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.cur_task_type = cur_task_cfg.task_type

	local is_set_exp = false
	for k, v in pairs(self.task_item_list) do
		v:SetActive(true and sky_money_info.curr_task_id >= 0)
		if cur_task_cfg.reward and cur_task_cfg.reward[k - 1] then
			v:SetData(cur_task_cfg.reward[k - 1])
		else
			v:SetActive(not is_set_exp)
			if not is_set_exp then
				v:SetData(SkyMoneyData.Instance:GetRewardExp())
				is_set_exp = true
			end
		end
	end
	MainUICtrl.Instance:SetViewState(false)


	if self.cur_task_id ~= sky_money_info.curr_task_id then
		self.cur_task_id = sky_money_info.curr_task_id
		self:AutoDoTask()
	end

	local small_diff_time = 0
	if sky_money_info.small_money_flush_time > 0 then
		small_diff_time = math.floor(math.max(sky_money_info.small_money_flush_time - TimeCtrl.Instance:GetServerTime(), 0))
	end
	local big_diff_time = 0
	if sky_money_info.big_money_flush_time > 0 then
		big_diff_time = math.floor(math.max(sky_money_info.big_money_flush_time - TimeCtrl.Instance:GetServerTime(), 0))
	end

	local qianduoduo_id = SkyMoneyData.Instance:GetQianDuoDuoId()
	local big_qianduoduo_id = SkyMoneyData.Instance:GetQianDuoDuoId(true)

	FuBenCtrl.Instance:SetMonsterInfo(qianduoduo_id)
	FuBenCtrl.Instance:SetMonsterInfo(big_qianduoduo_id, 2)
	FuBenCtrl.Instance:SetSkyMoneyTextState(true)

	local small_flush_text = sky_money_info.cur_qianduoduo_num .. "/" .. SkyMoneyData.Instance:GetQianDuoDuoMaxNum()
	local big_flush_text = sky_money_info.cur_bigqianduoduo_num .. "/" .. MAX_BIG_QIANDUODUO_NUM
	local show_monster_had_flush_1 = sky_money_info.cur_qianduoduo_num > 0
	local show_monster_had_flush_2 = sky_money_info.cur_bigqianduoduo_num > 0
	local show_monster_1 = sky_money_info.cur_qianduoduo_num > 0 or small_diff_time > 0
	local show_monster_2 = sky_money_info.cur_bigqianduoduo_num > 0 or (big_diff_time > 0 and small_diff_time <= 0)

	FuBenCtrl.Instance:SetMonsterDiffTime(small_diff_time)
	FuBenCtrl.Instance:SetMonsterDiffTime(big_diff_time, 2)

	FuBenCtrl.Instance:SetMonsterIconState(show_monster_1)
	FuBenCtrl.Instance:SetMonsterIconState(show_monster_2, 2)

	FuBenCtrl.Instance:ShowMonsterHadFlush(show_monster_had_flush_1, small_flush_text)
	FuBenCtrl.Instance:ShowMonsterHadFlush(show_monster_had_flush_2, big_flush_text, 2)
	self.node_list["NextAchieveTaskTxt"].text.text = string.format(Language.TianJianCaiBao.NowGold,sky_money_info.get_total_gold)
	self.node_list["HadKillTxt"].text.text = string.format(Language.TianJianCaiBao.Gold,sky_money_info.get_total_gold)
	self.node_list["BigRestTxt"].text.text = string.format(Language.TianJianCaiBao.TaskNum,sky_money_info.has_finish_task_num,MAX_TASK_NUM)
	if sky_money_info.has_finish_task_num == GameEnum.TIANJIANGCAIBAO_TASK_MAX then
		self.node_list["ItemList"]:SetActive(false)
		self.node_list["NeedKillTxt"]:SetActive(true)
		self.node_list["CurTaskTxt"]:SetActive(false)
		self.node_list["CurAchieveTaskTxt"]:SetActive(false)
		self.node_list["TxtDoTaskBtn"].text.text = Language.Common.CompleteTask
		UI:SetButtonEnabled(self.node_list["DoTaskBtn"],false)
		self.node_list["ArrowImg"]:SetActive(false)
		SkyMoneyAutoTaskEvent.CancelHightLightFunc = nil
		self.node_list["TasImg"]:SetActive(false)
		self.node_list["IconLevel"]:SetActive(false)
	else
		self.node_list["CurTaskTxt"]:SetActive(cur_task_cfg.task_type == 2)
		self.node_list["CurAchieveTaskTxt"]:SetActive(cur_task_cfg.task_type == 1)
		local hardflag = cur_task_cfg.is_kunnan
		self.node_list["IconLevel"]:SetActive(true)
		self.node_list["IconLevel"].image:LoadSprite(ResPath.GetRankTapByIndex(hardflag))
		self.node_list["ItemList"]:SetActive(true)
		self.node_list["NeedKillTxt"]:SetActive(false)
		self.node_list["TxtDoTaskBtn"].text.text = Language.Common.ContinueTask
		if nil ~= self.cur_param_value and self.cur_param_value ~= sky_money_info.curr_task_param and cur_task_cfg.task_type ~= 1 then
			self:AutoDoTask()
		end
	end

	if cur_task_cfg.task_type then
		if cur_task_cfg.task_type == 1 then
			local curr_task_param = sky_money_info.curr_task_param
			if sky_money_info.curr_task_param < cur_task_cfg.param_count then
				curr_task_param = string.format(Language.Mount.ShowRedNum, curr_task_param)
			end
			self.node_list["CurAchieveTaskTxt"].text.text = string.format(Language.TianJianCaiBao.Collect
				,config[cur_task_cfg.param_id].show_name,curr_task_param,cur_task_cfg.param_count)
		else
			local curr_task_param = sky_money_info.curr_task_param
			if sky_money_info.curr_task_param < cur_task_cfg.param_count then
				curr_task_param = string.format(Language.Mount.ShowRedNum, curr_task_param)
			end
			
			self.node_list["CurTaskTxt"].text.text =string.format(Language.TianJianCaiBao.Kill,
				monster_cfg[cur_task_cfg.param_id].name,curr_task_param,cur_task_cfg.param_count)

		end
	end
	self.cur_param_value = sky_money_info.curr_task_param
end

function SkyMoneyFBInfoView:SwitchButtonState(enable)
	self.node_list["Panel"]:SetActive(enable)
end

function SkyMoneyFBInfoView:OnFlush(param_t)
	self:SetInfo()
	-- self:SetActivityCountDown()
	-- self:SetMoneyMonsterCountDown()
end

function SkyMoneyFBInfoView:GetTime(time)
	local index = string.find(time, ":")
	local next_index = string.find(string.sub(time, index + 1, -1), ":")
	if next_index ~= nil then
		return string.sub(time, 1, index - 1), string.sub(string.sub(time, index + 1, -1), 1, next_index -1)
	end
	return string.sub(time, 1, index - 1), string.sub(time, index + 1, -1)
end