TipWaBaoView = TipWaBaoView or BaseClass(BaseView)

local HURT_BOSS_POS =
{
	CENTER_Y1 = 222,
	CENTER_Y2 = 550,
}

local TOUCH_STATE =
{
	DOWN = "down",
	UP = "up"
}
local FIX_DROP_HP = 1000
local BOSS_FIX_EXIT = 1.5      		 --BOSS界面退出时间
local BOSS_EXIT_ADD_TIME = 1.5 		 --BOSS界面增加退出时间
local FIX_DESTORY_HP_TEXT_TIME = 0.6 --每个飘血text销毁时间
local DEALY_TO_MOVE_ITEM_TIME = 2.5  --延时移动道具item
function TipWaBaoView:__init()
	self.ui_config = {{"uis/views/tips/wabaotips_prefab", "WaBaoTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipWaBaoView:ReleaseCallBack()
	self:CancelDelayMoveItemsQuest()
	self:ReleaseItemCells()
	self:ReleaseHpText()
	self.time_quest_list = {}

	if self.daoju_model_view then
		self.daoju_model_view:DeleteMe()
		self.daoju_model_view = nil
	end

	if self.boss_model_view then
		self.boss_model_view:DeleteMe()
		self.boss_model_view = nil
	end
end

function TipWaBaoView:LoadCallBack()
	self.text_list = {}
	local boss_display = self.node_list["boss_display"]
	self.boss_model_view = RoleModel.New()
	self.boss_model_view:SetDisplay(boss_display.ui3d_display)

	local daoju_display = self.node_list["daoju_display"]
	self.daoju_model_view = RoleModel.New()
	self.daoju_model_view:SetDisplay(daoju_display.ui3d_display)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BgClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.OnRewardClick, self))

	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = {}
		self.item_cell_list[i].item_cell = ItemCell.New()
		self.item_cell_list[i].item_game = self.node_list["item" .. i]
		self.item_cell_list[i].item_cell:SetInstanceParent(self.item_cell_list[i].item_game)
		self.item_cell_list[i].item_fix_pos = self.node_list["item_pos" .. i]
	end
	self:InitData()
end

function TipWaBaoView:CloseCallBack()
	for i = 1, 3 do
		self:CancelMoveQuest(i)
	end
	self.time_quest_list = {}
	self:CancelDelayMoveItemsQuest()
	self:OperateToNextWaBao()
	self:ToReward()
	self:InitData()
	self:StopPlay()
	self:ReleaseHpText()
	if self.boss_model_view then
		self.boss_model_view:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	end
	self.wabao_type = nil
end

function TipWaBaoView:OpenCallBack()
	self:InitCenterPos()
	if self.wabao_type == nil then
		return
	end

	self:Flush()

	if self.wabao_type ~= WABAO_REWARD_TYPE.BOSS then
		return
	end
	--开始update
	self:StartPlay()
end

function TipWaBaoView:SetData()
	-- 正在boss死亡表现时return
	if self.is_paly_anim then
		return
	end

	local reward_type = WaBaoData.Instance:GetWaBaoInfo().wabao_reward_type
	if reward_type ~= 4 then
		self.wabao_type = WABAO_REWARD_TYPE.DAOJU
	else
		self.wabao_type = WABAO_REWARD_TYPE.BOSS
	end
	self:Flush()
end

function TipWaBaoView:OnFlush()
	self.node_list["NodeItem"]:SetActive(self.wabao_type == WABAO_REWARD_TYPE.DAOJU)
	self.node_list["NodeBoss"]:SetActive(not self.wabao_type == WABAO_REWARD_TYPE.DAOJU)
	if self.wabao_type == WABAO_REWARD_TYPE.DAOJU then
		self:FlushDaoJuState()
	elseif self.wabao_type == WABAO_REWARD_TYPE.BOSS then
		self:FlushBossState()
	end
end

--展示道具状态
function TipWaBaoView:FlushDaoJuState()
	self:FlushDaoJuModel()
	self:DelayToMoveItems()
	self:FlushItems()
	self:OperateIsFastWaBao()
end

--展示BOSS状态
function TipWaBaoView:FlushBossState()
	self.is_paly_anim = true
	local res_id = 3014001
	self.boss_model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
	self.node_list["TxtBossProgress"].text.text = self.hp .."/".. self.max_hp
	self.node_list["SliderBossProgress"].slider.value = self.hp/self.max_hp
end

-----释放--
function TipWaBaoView:CancelDelayMoveItemsQuest()
	if self.delay_move_items_quest then
		GlobalTimerQuest:CancelQuest(self.delay_move_items_quest)
		self.delay_move_items_quest = nil
	end
end

function TipWaBaoView:ReleaseHpText()
	for k,v in pairs(self.text_list) do
		ResMgr:Destroy(v.gameObject)
		v = nil
	end
	self.text_list = {}
end

function TipWaBaoView:ReleaseItemCells()
	for i = 1, 3 do
		self.item_cell_list[i].item_cell:DeleteMe()
		self.item_cell_list[i].item_cell = nil
		self:CancelMoveQuest(i)
	end
	self.item_cell_list = {}
end
----------

function TipWaBaoView:StartPlay()
	Runner.Instance:AddRunObj(self)
end

function TipWaBaoView:StopPlay()
	Runner.Instance:RemoveRunObj(self)
end

function TipWaBaoView:InitData()
	for i = 1, 3 do
		if self.item_cell_list[i] then
			self.item_cell_list[i].item_game.transform.position = self.node_list["begin_pos"].transform.position
		end
	end

	local wabao_data = WaBaoData.Instance
	self.max_shouhu_time = wabao_data:GetOtherCfg().shouhuzhe_time
	self.max_hp = wabao_data:GetOtherCfg().shouhuzhe_hp
	self.hp = self.max_hp
	self.exit_time = 0     			--时间到了, 或时间规定内击杀boss标记
	self.is_completed = false 		--播放完死亡动画的标记
	self.is_play_dead_anim = false  --播放完渐变动画的标记
	self.is_play_hide_anim = false  --是否刷新界面,如果正在播放动画或击打boss,协议来了则暂不刷新界面
	self.destory_hp_timer = 0
	self.time_quest_list = {}
	self.old_touch_state = TOUCH_STATE.UP
	self.is_reward = false
end

function TipWaBaoView:InitCenterPos()
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local center_temp_pos = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.node_list["center_pos"].transform.position)
	self.center_pos = {}
	self.center_pos.x = center_temp_pos.x
end

--播放领取提示
function TipWaBaoView:ToReward()
	if not self.is_reward then
		self.is_reward = true
		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_WABAO)
	end
end

function TipWaBaoView:OnCloseClick()
	self:Close()
end

function TipWaBaoView:OnRewardClick()
	self.is_reward = true
	ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_WABAO)
	self:Close()
end

function TipWaBaoView:Update()
	if self.is_completed then
		self:IsCompleted()
	else
		self:IsNotCompleted()
	end

	--第一次按下
	if self:IsTouchDown() and self.old_touch_state ~= TOUCH_STATE.DOWN  then
		self:OnTouchBegin()
		return
	end

	if self.old_touch_state == TOUCH_STATE.DOWN then
		if self:IsTouchUp() then
			--松手
			self:OnTouchEnd()
		else
			--未松手
			if self.old_touch_state == TOUCH_STATE.DOWN then
				self:OnTouchMove()
				return
			end
		end
	end

	self:DestoryHpText()
end

--进行下一次挖宝
function TipWaBaoView:OperateToNextWaBao()
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	if not pos_cfg.baozang_scene_id or pos_cfg.baozang_scene_id == 0 then
		return
	end

	MoveCache.cant_fly = true
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(pos_cfg.baozang_scene_id, pos_cfg.baozang_pos_x, pos_cfg.baozang_pos_y, 0, 0)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end

--刷新道具物品
function TipWaBaoView:FlushItems()
	self.node_list["BtnReward"]:SetActive(false)
	local reward_items = WaBaoData.Instance:GetRewardItems()
	if not reward_items or not next(reward_items) then
		return
	end

	for i = 1, 3 do
		if self.item_cell_list[i] then
			self.item_cell_list[i].item_game.transform.position = self.node_list["begin_pos"].transform.position
		end
		if reward_items[i] then
			self.item_cell_list[i].item_cell:SetData(reward_items[i])
			self.item_cell_list[i].item_fix_pos:SetActive(true)
		else
			self.item_cell_list[i].item_fix_pos:SetActive(false)
		end
		self.item_cell_list[i].item_game:SetActive(false)
	end
end

--刷新道具模型
function TipWaBaoView:FlushDaoJuModel()
	local res_id = WaBaoData.Instance:GetRewardResId()
	self.daoju_model_view:SetMainAsset(ResPath.GetBoxModel(res_id))
end

--检测是否为快速挖宝
function TipWaBaoView:OperateIsFastWaBao()
	local is_fast_wabao = WaBaoData.Instance:GetFastWaBaoFlag()
	if not is_fast_wabao then
		WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
	end
	WaBaoData.Instance:SetFastWaBaoFlag(false)
end

--退出boss并再刷新一次当前状态
function TipWaBaoView:ExitBoss()
	self.node_list["NodeItem"]:SetActive(true)
	self.node_list["NodeBoss"]:SetActive(false)
	self.is_paly_anim = false
	self:SetData()
	self:StopPlay()
end

--BOSS未结束
function TipWaBaoView:IsNotCompleted()
	local time = math.max(0, WaBaoData.Instance:GetWaBaoInfo().shouhuzhe_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		self.node_list["TxtTimeText"].text.text = ToColorStr(TimeUtil.FormatSecond(time, 2))
	else
		self.is_completed = true
	end
end

--BOSS结束
function TipWaBaoView:IsCompleted()
	if self.hp > 0 then
		self.is_paly_anim = false
		self:StopPlay()
	else
		self.exit_time = self.exit_time + UnityEngine.Time.deltaTime
		--死亡动作播放完后,播放隐藏boss动画
		if self.exit_time > BOSS_FIX_EXIT and self.is_play_dead_anim == false then
			self:HideBoss()
		end
	end
end

--销毁飘血text
function TipWaBaoView:DestoryHpText()
	if #self.text_list <= 0 then
		return
	end

	self.destory_hp_timer = self.destory_hp_timer + UnityEngine.Time.deltaTime
	if self.destory_hp_timer < FIX_DESTORY_HP_TEXT_TIME then
		return
	end

	if not self.text_list[1] then
		return
	end

	ResMgr:Destroy(self.text_list[1].gameObject)
	table.remove(self.text_list, 1)
	self.destory_hp_timer = 0
end

--渐变隐藏BOSS
function TipWaBaoView:HideBoss()
	if self.is_play_hide_anim == true then
		return
	end
	self.is_play_hide_anim = true
	local draw_obj = self.boss_model_view.draw_obj
	if not draw_obj then
		return
	end
	--隐藏boss动画播放完后,进行退出boss操作
	draw_obj:PlayDead(1, BindTool.Bind(self.ExitBoss, self), BOSS_EXIT_ADD_TIME)
end

function TipWaBaoView:IsTouchUp()
	return UnityEngine.Input.GetMouseButtonUp(0)
end

function TipWaBaoView:IsTouchDown()
	return UnityEngine.Input.GetMouseButtonDown(0) or UnityEngine.Input.touchCount > 0 --0是左键
end

function TipWaBaoView:OnTouchBegin()
	self.old_touch_state = TOUCH_STATE.DOWN
	self.is_left = UnityEngine.Input.mousePosition.x <= self.center_pos.x
	self.is_record = false
end

function TipWaBaoView:OnTouchEnd()
	self.old_touch_state = TOUCH_STATE.UP
	self.is_record = false
end

function TipWaBaoView:OnTouchMove()
	if self.is_record == false then
		self:RecordBeginPos()
	else
		if not self:CheckIsHurtBoss() then
			return
		end
		self:OperateHurtBoss()
	end
end

--记录初始位置
function TipWaBaoView:RecordBeginPos()
	local cur_pos = UnityEngine.Input.mousePosition
	self.begin_pos_x = cur_pos.x
	self.begin_pos_y = cur_pos.y
	self.begin_pos = cur_pos
	self.is_record = true
end

--检测是否击中BOSS
function TipWaBaoView:CheckIsHurtBoss()
	if self.is_completed then
		return false
	end

	if self.hp <= 0 then
		return false
	end

	if self.is_left then
		return UnityEngine.Input.mousePosition.x > self.center_pos.x and
		(UnityEngine.Input.mousePosition.y > HURT_BOSS_POS.CENTER_Y1 or UnityEngine.Input.mousePosition.y < HURT_BOSS_POS.CENTER_Y2)
	else
		return UnityEngine.Input.mousePosition.x < self.center_pos.x and
		(UnityEngine.Input.mousePosition.y > HURT_BOSS_POS.CENTER_Y1 or UnityEngine.Input.mousePosition.y < HURT_BOSS_POS.CENTER_Y2)
	end
end

--伤害BOSS
function TipWaBaoView:OperateHurtBoss()
	self.hp = self.hp - FIX_DROP_HP
	self:FlushHurtBossHp()
	self:PlayHurtBossEffect()
	self:PlayDropHpAnim()
	if self.hp > 0 then
		self:OnBossNotDead()
	else
		self:OnBossDead()
	end
end

--BOSS死亡状态
function TipWaBaoView:OnBossDead()
	if self.is_completed then
		return
	end
	--杀死boss后发协议
	self.is_completed = true
	self.boss_model_view:SetInteger(ANIMATOR_PARAM.STATUS, 2)
	WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_SHOUHUZHE_TIME, 1)
end

--Boss未死状态
function TipWaBaoView:OnBossNotDead()
	--记录当前方向
	self.is_left = not self.is_left
	--设置重新记录位置
	self.is_record = false
end

function TipWaBaoView:FlushHurtBossHp()
	self.boss_model_view:SetTrigger("hurt")
	self.node_list["TxtBossProgress"].text.text = self.hp .."/".. self.max_hp
	self.node_list["SliderBossProgress"].slider.value = self.hp/self.max_hp
end

function TipWaBaoView:PlayHurtBossEffect()
	local begin_pos = Vector3(self.begin_pos.x, self.begin_pos.y, 0)
	local end_pos = Vector3(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y, 0)
	--向量差
	local delta_pos = u3d.v2Sub(end_pos, begin_pos)
	--单位向量
	local move_dir = u3d.v2Normalize(delta_pos)
	local z = math.deg(math.atan2(move_dir.y, move_dir.x))
	local rotation = Quaternion.Euler(0, 0, z)
	local bundle_name, asset_name = ResPath.GetMiscEffect("UI_daoguang_01")
	EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, self.root_node.transform, 1.0, nil, rotation)
end

function TipWaBaoView:MoveToTarget(index)
	if self.time_quest_list[index] then
		return
	end

	self.node_list["NodeItemPos"]:SetActive(true)
	self.time_quest_list[index] = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.item_cell_list[index].item_game
		local target_pos = self.item_cell_list[index].item_fix_pos.transform.position
		local path = {}
		table.insert(path, target_pos)
		local linear = DG.Tweening.PathType.Linear
		local path_mode = DG.Tweening.PathMode.TopDown2D

		local close_call_back = function()
			self:CancelMoveQuest(index)
			if index == 1 then
				self.node_list["BtnReward"]:SetActive(true)
			end
		end

		local tweener = item.transform:DOPath(path, 0.8, linear, path_mode, 1)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)
		tweener:OnComplete(close_call_back)
	end, 0)
end

function TipWaBaoView:CancelMoveQuest(index)
	if self.time_quest_list[index] then
		GlobalTimerQuest:CancelQuest(self.time_quest_list[index])
		self.time_quest_list[index] = nil
	end
end

function TipWaBaoView:DelayToMoveItems()
	if self.delay_move_items_quest then
		return
	end
	--设置block点击
	self.node_list["NodeBlock"]:SetActive(true)
	--延时移动
	self.delay_move_items_quest = GlobalTimerQuest:AddRunQuest(function()
		self.node_list["NodeBlock"]:SetActive(false)
		self:ToMoveItems()
		self:CancelDelayMoveItemsQuest()
	end, DEALY_TO_MOVE_ITEM_TIME)
end

function TipWaBaoView:ToMoveItems()
	local reward_items = WaBaoData.Instance:GetRewardItems()
	for i = 1, 3 do
		if reward_items[i] then
			self.item_cell_list[i].item_game:SetActive(true)
			self:MoveToTarget(i)
		end
	end
end

function TipWaBaoView:PlayDropHpAnim()
	local async_loader = AllocAsyncLoader(self, "effect_loader")
	async_loader:Load("uis/views/tips/wabaotips_prefab", "DropHpText", function (obj)
		if IsNil(obj) then
			return
		end
		local obj_transform = obj.transform
		obj_transform:SetParent(self.node_list["drop_hp_parent"].transform, false)
		table.insert(self.text_list, obj_transform)
	end)
end