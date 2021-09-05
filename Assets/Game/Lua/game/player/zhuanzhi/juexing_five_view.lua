JueXingFiveView = JueXingFiveView or BaseClass(BaseRender)

local JUE_XING_FIVE_TPYE = 4
local BALL_NUM = 7
local ball_effect_scale = 0.4
local ball_red_pos = 18

function JueXingFiveView:__init(instance)
	for i=1, JUE_XING_FIVE_TPYE do
		self.node_list["type_" .. i].button:AddClickListener(BindTool.Bind(self.OnClickType, self, i))
		for k=1, BALL_NUM do
			self.node_list["ball_" .. i .. "_" .. k].button:AddClickListener(BindTool.Bind(self.OnClickBall, self, (i * BALL_NUM) + k - BALL_NUM))
		end
	end

	self.node_list["StartTask"].button:AddClickListener(BindTool.Bind(self.OnClickTaskBtn, self))
	self.node_list["TaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTaskBtn, self))

	self.node_list["arrow"].button:AddClickListener(BindTool.Bind(self.OnClickArrow, self))

	self:InitView()

	self.type_index = 1
	self.zhuan_index = 8		-- 这个界面是8转也是3觉醒
	self.is_can_zhuanzhi = false

	self.exp_view_is_open = false
end

function JueXingFiveView:__delete()
	self.exp_view_is_open = false

	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

function JueXingFiveView:InitView()
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local is_first = ZhuanZhiData.Instance:GetFirstTaskZhuanZhi()

	self.exp_view_is_open = ZhuanZhiData.Instance:GetWuZhuanViewFlag()
	self.node_list["BallList"]:SetActive(true)
	-- self.node_list["StartTask"]:SetActive(is_first and zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT)
	-- self.node_list["TaskBtn"]:SetActive((not is_first) and zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT)
	self.exp_view_is_open = false
	self:Flush()
end

function JueXingFiveView:OnFlush()
	local zhuanzhi_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(ZHUANZHI_TIME.ZHUANZHI_TIME_TEN)
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local is_first = ZhuanZhiData.Instance:GetFirstTaskZhuanZhi()
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == zhuanzhi_info then
		return
	end

	-- self.node_list["StartTask"]:SetActive(is_first and zhuan < self.zhuan_index and zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT and not self.exp_view_is_open)
	-- self.node_list["TaskBtn"]:SetActive((not is_first) and zhuan < self.zhuan_index and zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT and not self.exp_view_is_open)

	if self.exp_view_is_open then
		for i=1,BALL_NUM do
			local is_enable = false
			if self.type_index <= math.floor(zhuanzhi_info / BALL_NUM) then
				is_enable = false
			elseif i <= (zhuanzhi_info % BALL_NUM) and self.type_index == math.ceil(zhuanzhi_info / BALL_NUM) then
				is_enable = false
			else
				is_enable = true
			end 
			UI:SetGraphicGrey(self.node_list["ball_" .. self.type_index .. "_" .. i], is_enable)
		end
	end
	
	local is_vis_1, is_vis_2, is_vis_3, is_vis_4 = ZhuanZhiData.Instance:GetJueXingWuProgress()
	UI:SetButtonEnabled(self.node_list["type_1"], is_vis_1)
	UI:SetButtonEnabled(self.node_list["type_2"], is_vis_2)
	UI:SetButtonEnabled(self.node_list["type_3"], is_vis_3)
	UI:SetButtonEnabled(self.node_list["type_4"], is_vis_4)

	if zhuan == ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT - 1
		and self.type_index == math.floor(zhuanzhi_info / BALL_NUM) + 1
		and (zhuanzhi_info % BALL_NUM) < BALL_NUM
		and zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then

		local pos = self.node_list["ball_" .. self.type_index .. "_" .. (zhuanzhi_info % BALL_NUM + 1)].transform.anchoredPosition3D
		local scale = ball_effect_scale
		local red_pos = Vector3(pos.x + ball_red_pos, pos.y + ball_red_pos, 0)
		local ball_red_flag = ZhuanZhiData.Instance:GetBallRedPointRemind(ZHUANZHI_TIME.ZHUANZHI_TIME_TEN, zhuanzhi_info + 1)

		self:SetBallEffect(true, pos, scale)
		self:SetBallRedPoint(ball_red_flag, red_pos)
	else
		self:SetBallEffect(false)
		self:SetBallRedPoint(false)
	end

	local task_btn_text = ""
	local handler = true
	local btn_state = true
	local btn_show = false
	if task_cfg then
		if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
			task_btn_text = Language.Player.ZhuanZhiBtnText[5]
		elseif zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
			task_btn_text = Language.Player.ZhuanZhiBtnText[3]
			handler = false
			btn_state = false
			if task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB_LAYE then
				task_btn_text = Language.Player.ZhuanZhiBtnText[4]
				handler = true
			end
		elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
			task_btn_text = Language.Player.ZhuanZhiBtnText[3]
		end
		btn_show = (not TaskData.Instance:GetIsFirstZhuanZhi(task_cfg.task_id) and zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT)
			or (not TaskData.Instance:GetIsEndTaskZhuanZhi(task_cfg.task_id) and zhuanzhi_task_status == TASK_STATUS.COMMIT)
	end

	UI:SetButtonEnabled(self.node_list["TaskBtn"], handler)
	self.node_list["BtnText"].text.text = task_btn_text
	self.node_list["btn_text_state"].text.text = task_btn_text
	self.node_list["StartTask"]:SetActive(btn_state and task_cfg ~= nil and zhuan < self.zhuan_index and zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT, btn_show)
	self.node_list["TaskBtn"]:SetActive(not btn_state and handler)

	local attr_cfg = ZhuanZhiData.Instance:GetAttrCfgByZhuanNum(self.zhuan_index) or {}
	local task_id = task_cfg and task_cfg.task_id or attr_cfg.renwu
	local role_info = PlayerData.Instance:GetRoleVo()
	local task_cfg_tmp = TaskData.Instance:GetTaskConfig(task_id)
	if task_cfg_tmp == nil then return end
	self.is_can_zhuanzhi = true
	self.open_level = task_cfg_tmp.min_level
	if role_info.level < task_cfg_tmp.min_level then
		self.is_can_zhuanzhi = false
		self.node_list["btn_text_state"].text.text = Language.Player.ZhuanZhiBtnText[1]
	end
	-- UI:SetGraphicGrey(self.node_list["TaskBtn"], true)
	UI:SetGraphicGrey(self.node_list["StartTask"], role_info.level < task_cfg_tmp.min_level)
	self.node_list["StartRedPoint"]:SetActive(role_info.level >= task_cfg_tmp.min_level)
end

function JueXingFiveView:OnClickType(index)
	for i=1,JUE_XING_FIVE_TPYE do
		self.node_list["type_exp_" .. i]:SetActive(i == index)
	end
	self.exp_view_is_open = true
	ZhuanZhiData.Instance:SetWuZhuanViewFlag(self.exp_view_is_open)
	self.node_list["effect"]:SetActive(true)
	self.node_list["BallList"]:SetActive(false)
	self.node_list["TaskBtn"]:SetActive(false)
	self.type_index = index
	self:Flush()
	self:UpDownView(true)
end

function JueXingFiveView:UpDownView(flag)
	self.node_list["JueXing5"].animator:SetBool("UpDown", flag)
	self.node_list["JueXing5"].animator:SetBool("DownUp", not flag)	
end

function JueXingFiveView:OnClickBall(index)
	TipsCtrl.Instance:ShowZhuanZhiTips(ZHUANZHI_TIME.ZHUANZHI_TIME_TEN, index, ZHUANZHI_TIME.ZHUANZHI_TIME_TEN)
end

function JueXingFiveView:OnClickArrow()
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()

	self:UpDownView(false)

	self.exp_view_is_open = false

	for i=1,JUE_XING_FIVE_TPYE do
		self.node_list["type_exp_" .. i]:SetActive(false)
	end
	self.node_list["effect"]:SetActive(false)
	self.node_list["BallList"]:SetActive(true)
	-- self.node_list["TaskBtn"]:SetActive(zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT)
	self:DoPanelTweenPlay()
end

function JueXingFiveView:OnClickTaskBtn()
	if not self.is_can_zhuanzhi then
		local str_tip = string.format(Language.Player.OpenJueXing, self.open_level, self.zhuan_index - 5)
		TipsSystemManager.Instance:ShowSystemTips(str_tip)
		return
	end

	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == task_cfg then
		return
	end

	if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
		TaskCtrl.SendTaskAccept(task_cfg.task_id)
	elseif zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
		ViewManager.Instance:Close(ViewName.Player)
		TaskCtrl.Instance:DoZhuanZhiTask(task_cfg.task_id, zhuanzhi_task_status)
	elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
		MainUICtrl.Instance:GetTaskView():DoTask(task_cfg.task_id, zhuanzhi_task_status)
	end
end

function JueXingFiveView:OnClickGoFb()
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == task_cfg then
		return
	end

	if zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
		TaskCtrl.Instance:DoZhuanZhiTask(task_cfg.task_id, zhuanzhi_task_status)
	elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
		TaskCtrl.SendTaskCommit(task_cfg.task_id)
	end
end

function JueXingFiveView:SetBallEffect(is_show, pos, scale)
	if self.effect_obj then
		self.effect_obj:SetActive(is_show)
		self.effect_obj.gameObject.transform.localScale = scale and Vector3(scale, scale, 1) or Vector3(1, 1, 1)
		self.effect_obj.gameObject.transform.localPosition = pos and pos or Vector3(0, 0, 0)
	else
		if is_show then
			local effect_bundle, effect_asset = ResPath.GetUiXEffect("ui_juexing_dc")
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if nil == obj then
					return
				end
				obj.transform:SetParent(self.node_list["effect"].transform)
				obj.name = "effect_obj"
				obj.gameObject.transform.localScale = scale and Vector3(scale, scale, 1) or Vector3(1, 1, 1)
				obj.gameObject.transform.localPosition = pos and pos or Vector3(0, 0, 0)
				self.effect_obj = obj
			end)
		end
	end
end

function JueXingFiveView:SetBallRedPoint(is_show, pos)
	self.node_list["BallRedPoint"]:SetActive(is_show)
	self.node_list["BallRedPoint"].transform.localPosition = pos and pos or Vector3(0, 0, 0)
end

function JueXingFiveView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["BottumView"], Vector3(0, -100, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["BallList"] , true, MOVE_TIME , DG.Tweening.Ease.InExpo)
end