JueXingThreeView = JueXingThreeView or BaseClass(BaseRender)

local JUE_XING_THREE_BALL_NUM = 10
local ball_effect_scale = 0.7
local ball_red_pos = 32

function JueXingThreeView:__init(instance)
	for i=1, JUE_XING_THREE_BALL_NUM do
		self.node_list["ball_" .. i].button:AddClickListener(BindTool.Bind(self.OnClickBall, self, i))
	end

	-- self.node_list["GoFbBtn"].button:AddClickListener(BindTool.Bind(self.OnClickGoFb, self))
	self.node_list["StartTask"].button:AddClickListener(BindTool.Bind(self.OnClickTaskBtn, self))
	self.node_list["TaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTaskBtn, self))

	self.ball_index = 1
	self.zhuan_index = 6		-- 这个界面是6转也是1觉醒
	self.is_can_zhuanzhi = false

	self:InitView()
end

function JueXingThreeView:__delete()
	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

function JueXingThreeView:LoadCallBack()

end

function JueXingThreeView:InitView()
	local zhuanzhi_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT)
	if nil == zhuanzhi_info then
		return
	end

	self:Flush()
end

function JueXingThreeView:OnFlush()
	local zhuanzhi_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT)
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local is_first = ZhuanZhiData.Instance:GetFirstTaskZhuanZhi()
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == zhuanzhi_info then
		return
	end

	-- self.node_list["StartTask"]:SetActive(is_first and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SEVEN)
	-- self.node_list["TaskBtn"]:SetActive(not is_first and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SEVEN)

	for i=1,JUE_XING_THREE_BALL_NUM do
		UI:SetGraphicGrey(self.node_list["ball_" .. i], zhuanzhi_info < i)
	end

	if zhuan == ZHUANZHI_TIME.ZHUANZHI_TIME_SIX - 1 
		and zhuanzhi_info < JUE_XING_THREE_BALL_NUM 
		and zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then

		local pos = self.node_list["ball_" .. zhuanzhi_info + 1].transform.anchoredPosition3D
		local scale = ball_effect_scale
		local red_pos = Vector3(pos.x + ball_red_pos, pos.y + ball_red_pos, 0)
		local ball_red_flag = ZhuanZhiData.Instance:GetBallRedPointRemind(ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT, zhuanzhi_info + 1)

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
	self.node_list["StartTask"]:SetActive(btn_state and task_cfg ~= nil and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SEVEN and btn_show)
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

function JueXingThreeView:OnClickBall(index)
	TipsCtrl.Instance:ShowZhuanZhiTips(ZHUANZHI_TIME.ZHUANZHI_TIME_EIGHT, index, ZHUANZHI_TIME.ZHUANZHI_TIME_SIX)
end

function JueXingThreeView:OnClickTaskBtn()

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

function JueXingThreeView:OnClickGoFb()
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

function JueXingThreeView:SetBallEffect(is_show, pos, scale)
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

function JueXingThreeView:SetBallRedPoint(is_show, pos)
	self.node_list["BallRedPoint"]:SetActive(is_show)
	self.node_list["BallRedPoint"].transform.localPosition = pos and pos or Vector3(0, 0, 0)
end

function JueXingThreeView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["BottumView"], Vector3(0, -100, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["BallList"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end