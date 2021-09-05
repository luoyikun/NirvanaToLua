JueXingOneView = JueXingOneView or BaseClass(BaseRender)

local BALL_NUM = 7
local ball_effect_scale = 0.4
local ball_red_pos = 16

function JueXingOneView:__init(instance)
	self.juexing_one_ball_list = {}
	self.juexing_one_ball_name_list = {}
	for i=1, BALL_NUM do
		self.juexing_one_ball_list[i] = self.node_list["ball_" .. i]
		self.juexing_one_ball_list[i].button:AddClickListener(BindTool.Bind(self.OnClickBall, self, i))
		self.juexing_one_ball_name_list[i] = self.node_list["text_" .. i]
	end

	self.line_list = {}
	for i=1,6 do
		self.line_list[i] = self.node_list["Line_" .. i]
	end

	self.big_ball_list = {}
	for i=1,3 do
		self.big_ball_list[i] = self.node_list["Big_ball_" .. i]
		self.big_ball_list[i].button:AddClickListener(BindTool.Bind(self.OnClickBigBall, self, i))
	end

	self.node_list["StartTask"].button:AddClickListener(BindTool.Bind(self.UpgradeBtn, self))
	self.node_list["YiJueUpgradeBtn"].button:AddClickListener(BindTool.Bind(self.UpgradeBtn, self))

	self.big_ball_index = 1
	self.ball_index = 1
	self.zhuan_index = 4		-- 这个界面是4转
	self.is_can_zhuanzhi = false --是否达到转职等级
	self.open_level = 0

	self:InitView()
end

function JueXingOneView:__delete()
	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

function JueXingOneView:InitView()
	local zhuanzhi_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(ZHUANZHI_TIME.ZHUANZHI_TIME_SIX)
	if nil == zhuanzhi_info then
		return
	end

	self.big_ball_index = ZhuanZhiData.Instance:GetJueXingOneTypeKey()
	self:OnClickBigBall(self.big_ball_index)
	self:Flush()
end

function JueXingOneView:OnFlush()
	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local is_first = ZhuanZhiData.Instance:GetFirstTaskZhuanZhi()
	local zhuanzhi_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(ZHUANZHI_TIME.ZHUANZHI_TIME_SIX)
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	local zhuanzhi_state = zhuanzhi_task_status and zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS or false
	local is_vis_1, is_vis_2 = ZhuanZhiData.Instance:GetJueXingOneProgress()
	local big_ball_key = ZhuanZhiData.Instance:GetJueXingOneTypeKey()
	
	if self.is_auto_jump_type then
		self.is_auto_jump_type = false
	else
		self.big_ball_index = big_ball_key
	end

	UI:SetGraphicGrey(self.node_list["Big_ball_1"], big_ball_key < 1)
	UI:SetGraphicGrey(self.node_list["Big_ball_2"], big_ball_key < 2)
	UI:SetGraphicGrey(self.node_list["Big_ball_3"], big_ball_key < 3)
	self.node_list["Thick_Light_1"]:SetActive(is_vis_1)
	self.node_list["Thick_Light_2"]:SetActive(is_vis_2)
	-- self.node_list["StartTask"]:SetActive(is_first and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SIX)
	self.node_list["YiJueUpgradeBtn"]:SetActive(not is_first and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SIX)

	if zhuanzhi_info then
		local bundle, asset
		for k,v in pairs(self.juexing_one_ball_list) do
			if self.big_ball_index <= math.floor(zhuanzhi_info / BALL_NUM) then
				bundle, asset = ResPath.GetZhuanZhiIcon("liuzhuan_ball")
			elseif k <= (zhuanzhi_info % BALL_NUM) then
				bundle, asset = ResPath.GetZhuanZhiIcon("liuzhuan_ball")
			else
				bundle, asset = ResPath.GetZhuanZhiIcon("liuzhuan_huise_ball")
			end
			v.image:LoadSprite(bundle, asset)
		end

		for k,v in pairs(self.line_list) do
			v:SetActive(k < (zhuanzhi_info % BALL_NUM))
		end

		if zhuan == ZHUANZHI_TIME.ZHUANZHI_TIME_FOUR - 1
			and self.big_ball_index == math.floor(zhuanzhi_info / BALL_NUM) + 1
			and (zhuanzhi_info % BALL_NUM) < BALL_NUM
			and zhuanzhi_state then

			local pos = self.juexing_one_ball_list[zhuanzhi_info % BALL_NUM + 1].transform.anchoredPosition3D
			local scale = ball_effect_scale
			local red_pos = Vector3(pos.x + ball_red_pos, pos.y + ball_red_pos, 0)
			local ball_red_flag = ZhuanZhiData.Instance:GetBallRedPointRemind(ZHUANZHI_TIME.ZHUANZHI_TIME_SIX, zhuanzhi_info + 1)

			self:SetBallEffect(true, pos, scale)
			self:SetBallRedPoint(ball_red_flag, red_pos)
		else
			self:SetBallEffect(false)
			self:SetBallRedPoint(false)
		end
	end

	for k,v in pairs(self.juexing_one_ball_name_list) do
		local index = k * self.big_ball_index > 0 and (self.big_ball_index - 1) * 7 + k or 1
		local cfg = ZhuanZhiData.Instance:GetJueXingOneCfgByIndex(index)
		if cfg then
			v.text.text = cfg.name
		end
	end

	local task_btn_text = ""
	local handler = true
	local btn_state = true
	local btn_show = false
	if task_cfg then
		if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
			task_btn_text = Language.Player.ZhuanZhiBtnText[1]
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
	self.node_list["BtnText"].text.text = task_btn_text
	self.node_list["btn_text_state"].text.text = task_btn_text

	self.node_list["StartTask"]:SetActive(btn_state and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SIX and btn_show)
	self.node_list["YiJueUpgradeBtn"]:SetActive(not btn_state and handler and zhuan < self.zhuan_index and zhuan <= ZHUANZHI_TIME.ZHUANZHI_TIME_SIX)
	UI:SetButtonEnabled(self.node_list["YiJueUpgradeBtn"], handler)

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
	UI:SetGraphicGrey(self.node_list["StartTask"], role_info.level < task_cfg_tmp.min_level)

	self.node_list["StartRedPoint"]:SetActive(role_info.level >= task_cfg_tmp.min_level)
end

function JueXingOneView:UpgradeBtn()
	if not self.is_can_zhuanzhi then
		local str_tip = string.format(Language.Player.OpenZhuanZhi, self.open_level, self.zhuan_index)
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
		TaskCtrl.Instance:DoZhuanZhiTask(task_cfg.task_id, zhuanzhi_task_status)
	elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
		MainUICtrl.Instance:GetTaskView():DoTask(task_cfg.task_id, zhuanzhi_task_status)
	end

end

function JueXingOneView:OnClickBall(index)
	TipsCtrl.Instance:ShowZhuanZhiTips(ZHUANZHI_TIME.ZHUANZHI_TIME_SIX, index + self.big_ball_index * BALL_NUM - BALL_NUM, ZHUANZHI_TIME.ZHUANZHI_TIME_FOUR)
end

function JueXingOneView:OnClickBigBall(index)
	local is_vis_1, is_vis_2 = ZhuanZhiData.Instance:GetJueXingOneProgress()
	if index == 2 and not is_vis_1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.NeedUpLevelCap[1])
		return
	elseif index == 3 and not is_vis_2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.NeedUpLevelCap[2])
		return
	end

	self.is_auto_jump_type = true
	self.big_ball_index = index
	self:Flush()
end

function JueXingOneView:OnClickWuzhuanTaskBtn()
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == task_cfg then
		return
	end

	if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
		TaskCtrl.SendTaskAccept(task_cfg.task_id)
	end
end

function JueXingOneView:OnClickGoFb()
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

function JueXingOneView:SetBallEffect(is_show, pos, scale)
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
				if self.node_list then
					obj.transform:SetParent(self.node_list["effect"].transform)
				end
				obj.name = "effect_obj"
				obj.gameObject.transform.localScale = scale and Vector3(scale, scale, 1) or Vector3(1, 1, 1)
				obj.gameObject.transform.localPosition = pos and pos or Vector3(0, 0, 0)
				self.effect_obj = obj
			end)
		end
	end
end

function JueXingOneView:SetBallRedPoint(is_show, pos)
	self.node_list["BallRedPoint"]:SetActive(is_show)
	self.node_list["BallRedPoint"].transform.localPosition = pos and pos or Vector3(0, 0, 0)
end

function JueXingOneView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["BottumView"], Vector3(-146.5, -100, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["BallList"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end