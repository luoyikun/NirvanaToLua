ZhuanZhiView = ZhuanZhiView or BaseClass(BaseRender)

local WUZHUAN_BALL_NUM = 12
local ball_red_pos = {35, 25}
local ball_effect_scale = {0.8, 0.55}

function ZhuanZhiView:__init(instance, parent_view)
	self.node_list["TaskBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTaskBtn, self))
	self.node_list["StartTask"].button:AddClickListener(BindTool.Bind(self.OnClickTaskBtn, self))
	-- self.index = 0
	self.juexing_one_view = JueXingOneView.New(self.node_list["JueXing1"])
	self.juexing_two_view = JueXingTwoView.New(self.node_list["JueXing2"])

	for i=1, ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE do
		self.node_list["zhuan_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickZhuanBtn, self, i))
	end

	self.wuzhuan_ball_list = {}
	for i=1, WUZHUAN_BALL_NUM do
		self.wuzhuan_ball_list[i] = self.node_list["ball_" .. i]
		UI:SetGraphicGrey(self.wuzhuan_ball_list[i], true)
		self.wuzhuan_ball_list[i].button:AddClickListener(BindTool.Bind(self.OnClickWuZhuanBall, self, i))
	end

	self.base_prof = 0
	self.zhuan_index = 0
	self.is_can_zhuanzhi = false
	self.open_level = 0

	self:InitView()
end

-- 功能引导按钮
function ZhuanZhiView:GetTaskBtn()
	if self.node_list["StartTask"] then
		return self.node_list["StartTask"], BindTool.Bind(self.OnClickTaskBtn, self)
	end
end

function ZhuanZhiView:__delete()
	if self.juexing_one_view then
		self.juexing_one_view:DeleteMe()
		self.juexing_one_view = nil
	end

	if self.juexing_two_view then
		self.juexing_two_view:DeleteMe()
		self.juexing_two_view = nil
	end

	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

--初始化滚动条
function ZhuanZhiView:InitScroller()
	self.cell_list = {}

	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function ZhuanZhiView:GetNumberOfCells()
	local skill_desc_list = ZhuanZhiData.Instance:GetFaceCfgListByZhuanNum(self.zhuan_index)
	return #skill_desc_list
end

--滚动条刷新
function ZhuanZhiView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ZhuanZhiViewScrollCell.New(cell.gameObject) --实例化item
		self.cell_list[cell] = group_cell
		-- self.cell_list[cell].root_node.toggle.group = self.node_list["Scroller"].toggle_group
	end

	-- if data_index + 1 == self.index then
	-- 	print_error(self.index)
	-- 	-- self.index = data_index + 1
	-- 	self.cell_list[cell].root_node.toggle.isOn = true
	-- end

	local skill_desc_list = ZhuanZhiData.Instance:GetFaceCfgListByZhuanNum(self.zhuan_index)
	local data = skill_desc_list[data_index + 1]
	if data then
		group_cell:SetIndex(data_index)
		group_cell:SetData(data)
	end
end

function ZhuanZhiView:FlushBattle()
	self.node_list["Scroller"].scroller:ReloadData(0)
end

function ZhuanZhiView:FlushByItemChange()
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if self.zhuan_index and self.zhuan_index ~= zhuan + 1 then
		-- 防住物品改变刷新界面
		return
	end
	self:InitView()
end

function ZhuanZhiView:InitView()
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	self.base_prof = base_prof
	self.zhuan_index = zhuan < ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE and zhuan + 1 or 1

	self:InitScroller()
	self:FlushToggleHL(self.zhuan_index)
	self:OnClickZhuanBtn(self.zhuan_index)
	self:Flush()
end

function ZhuanZhiView:OnFlush()
	self:FlushZhuanZhiLeftView()
	self:FlushZhuanZhiRightView()
	if self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_THREE then
		self:FlushWuZhuanView()
	elseif self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_FOUR then
		self.juexing_one_view:Flush()
	elseif self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE then
		self.juexing_two_view:Flush()
	end
end

function ZhuanZhiView:OnClickTaskBtn()

	if not self.is_can_zhuanzhi then
		local str_tip = string.format(Language.Player.OpenZhuanZhi, self.open_level, self.zhuan_index)
		TipsSystemManager.Instance:ShowSystemTips(str_tip)
		return
	end

	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()

	if task_cfg == nil then
		return
	end
	TASK_ZHUANZHI_AUTO = true
	if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
		TaskCtrl.SendTaskAccept(task_cfg.task_id)
	elseif zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
		TaskCtrl.Instance:DoZhuanZhiTask(task_cfg.task_id, zhuanzhi_task_status)
	elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
		MainUICtrl.Instance:GetTaskView():DoTask(task_cfg.task_id, zhuanzhi_task_status)
	end
	if self.zhuan_index <= TASK_AUTO_ZHUANZHI_LEVEL then
		ViewManager.Instance:Close(ViewName.Player)
	end
end

function ZhuanZhiView:OnClickZhuanBtn(index)
	if index < ZHUANZHI_TIME.ZHUANZHI_TIME_THREE then
		PlayerCtrl.Instance.view.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("zhuanzh_bg" .. index, true))
	else
		PlayerCtrl.Instance.view.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("bg_common1_under", true))
	end

	if index == self.zhuan_index then
		return
	end
	if index >= 3 then
		self.node_list["Skill_list"].rect.sizeDelta = Vector2(420, 360)
	else
		self.node_list["Skill_list"].rect.sizeDelta = Vector2(420, 517)
	end

	self.zhuan_index = index
	self:DoPanelTweenPlay()
	self:FlushBattle()
	self:Flush()
end

function ZhuanZhiView:OnClickWuZhuanBall(index)
	TipsCtrl.Instance:ShowZhuanZhiTips(ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE, index, ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
end

function ZhuanZhiView:FlushToggleHL(zhuan_index)
	for i=1, ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE do
		self.node_list["zhuan_" .. i].toggle.isOn = (i == zhuan_index)
	end

	if zhuan_index >= 3 then
		self.node_list["Skill_list"].rect.sizeDelta = Vector2(420, 360)
	else
		self.node_list["Skill_list"].rect.sizeDelta = Vector2(420, 517)
	end 
	self:FlushBattle()
end

function ZhuanZhiView:FlushZhuanZhiLeftView()
	local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf()

	local res_id  = ZhuanZhiData.Instance:GetZhuanZhiLimitProfImg(self.base_prof, self.zhuan_index - 1)
	local res_id1 = ZhuanZhiData.Instance:GetZhuanZhiLimitProfImg(self.base_prof, self.zhuan_index)
	if res_id then
		local bundle1, asset1 = ResPath.GetTransferNameIcon(res_id)
		self.node_list["img_name2"].image:LoadSprite(bundle1, asset1)
	end
	if res_id1 then
		local bundle, asset = ResPath.GetTransferNameIcon(res_id1)
		self.node_list["img_name1"].image:LoadSprite(bundle, asset)
	end
	
	local task_cfg, zhuanzhi_task_status, progress_num = TaskData.Instance:GetNowZhuanZhiTask()
	local is_first = ZhuanZhiData.Instance:GetFirstTaskZhuanZhi()

	self.node_list["StartTask"]:SetActive(is_first and zhuan < self.zhuan_index and self.zhuan_index <= ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
	self.node_list["TaskBtn"]:SetActive((not is_first) and zhuan < self.zhuan_index and self.zhuan_index <= ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
	self.node_list["zhuanzhichenggong"]:SetActive(zhuan >= self.zhuan_index)
	self.node_list["zhuanzhichenggong_1"]:SetActive(zhuan >= self.zhuan_index and self.zhuan_index >= ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
	self.node_list["TaskBar"]:SetActive(zhuan < self.zhuan_index)
	self.node_list["RedPoint"]:SetActive(false)

	-- 要求等级不足显示下一等级
	for i = 1, ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE do
		self.node_list["zhuan_" .. i]:SetActive((zhuan + 1) >= i)
	end

	self.node_list["left_des_title"]:SetActive(self.zhuan_index >= ZHUANZHI_TIME.ZHUANZHI_TIME_THREE and zhuan < self.zhuan_index)

	if task_cfg then
		local desc = ""
		local task_btn_text = ""
		local handler = true
		local btn_state = true
		if zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT then
			self.node_list["RedPoint"]:SetActive(true)
			desc = task_cfg.accept_desc
			task_btn_text = Language.Player.ZhuanZhiBtnText[1]
			btn_state = true
		elseif zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
			if progress_num then
				desc = MainUIViewTask.ChangeTaskProgressString(task_cfg.progress_desc, progress_num, task_cfg.c_param2)
				task_btn_text = Language.Player.ZhuanZhiBtnText[2]
				btn_state = false
			end
			if task_cfg.condition == TASK_COMPLETE_CONDITION.REACH_STATE then
				task_btn_text = Language.Player.ZhuanZhiBtnText[3]
				handler = false
			end
			if task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB_LAYE then
				self.node_list["RedPoint"]:SetActive(true)
				task_btn_text = Language.Player.ZhuanZhiBtnText[4]
				btn_state = false
			elseif task_cfg.condition == TASK_COMPLETE_CONDITION.REACH_STATE then
				handler = false
			end
		elseif zhuanzhi_task_status == TASK_STATUS.COMMIT then
			self.node_list["RedPoint"]:SetActive(true)
			task_btn_text = Language.Player.ZhuanZhiBtnText[3]
			desc = task_cfg.commit_desc
		end

		self.node_list["task_des_1"].text.text = desc
		self.node_list["task_des_2"].text.text = desc
		self.node_list["btn_text"].text.text = task_btn_text
		self.node_list["btn_text_state"].text.text = task_btn_text
		UI:SetButtonEnabled(self.node_list["TaskBtn"], handler)

		local btn_show = (not TaskData.Instance:GetIsFirstZhuanZhi(task_cfg.task_id) and zhuanzhi_task_status == TASK_STATUS.CAN_ACCEPT)
			or (not TaskData.Instance:GetIsEndTaskZhuanZhi(task_cfg.task_id) and zhuanzhi_task_status == TASK_STATUS.COMMIT)
		self.node_list["StartTask"]:SetActive(btn_state and zhuan + 1 == self.zhuan_index and self.zhuan_index <= ZHUANZHI_TIME.ZHUANZHI_TIME_THREE and btn_show)
		self.node_list["TaskBtn"]:SetActive(not btn_state and handler and zhuan + 1 == self.zhuan_index and self.zhuan_index <= ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
	end

	for i=1, ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE do
		self.node_list["zhuan_" .. i]:SetActive(zhuan >= i - 1)
	end

	local attr_cfg = ZhuanZhiData.Instance:GetAttrCfgByZhuanNum(self.zhuan_index) or {}
	local task_id = task_cfg and task_cfg.task_id or attr_cfg.renwu

	if self.zhuan_index < 5 then
		local special_des = ZhuanZhiData.Instance:GetZhuanZhiJieDuanDes(task_id, self.zhuan_index)
		self.node_list["special_des"].text.text = special_des
		self.node_list["hp"].text.text = attr_cfg.maxhp_1
		self.node_list["gongji"].text.text = attr_cfg.gongji_1
		self.node_list["fangyu"].text.text = attr_cfg.fangyu_1
		self.node_list["pojia"].text.text = attr_cfg.pojia_1
	end

	local role_info = PlayerData.Instance:GetRoleVo()
	local task_cfg_tmp = TaskData.Instance:GetTaskConfig(task_id)
	if task_cfg_tmp == nil then return end
	self.is_can_zhuanzhi = true
	self.open_level = task_cfg_tmp.min_level
	if role_info.level < task_cfg_tmp.min_level then
		self.is_can_zhuanzhi = false
		-- UI:SetGraphicGrey(self.node_list["TaskBtn"], true)
	end
	UI:SetGraphicGrey(self.node_list["StartTask"], role_info.level < task_cfg_tmp.min_level)

	self.node_list["StartRedPoint"]:SetActive(role_info.level >= task_cfg_tmp.min_level)

	if not self.is_can_zhuanzhi then
		local str_tip = string.format(Language.Player.OpenZhuanZhi, self.open_level, self.zhuan_index)
		self.node_list["task_des_1"].text.text = str_tip
		self.node_list["task_des_2"].text.text = str_tip
	end

end

function ZhuanZhiView:FlushZhuanZhiRightView()
	self.node_list["RightView"]:SetActive(self.zhuan_index < ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
	self.node_list["WuZhuanView"]:SetActive(self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_THREE)
	self.node_list["JueXing1"]:SetActive(self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_FOUR)
	self.node_list["JueXing2"]:SetActive(self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE)
end

function ZhuanZhiView:FlushWuZhuanView()
	local wuzhuan_info = ZhuanZhiData.Instance:GetSingleZhuanZhiInfo(ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE)
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == wuzhuan_info then
		return
	end

	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()

	for k,v in pairs(self.wuzhuan_ball_list) do
		UI:SetGraphicGrey(v, wuzhuan_info <= k - 1)
	end

	if zhuan == self.zhuan_index - 1 and wuzhuan_info < WUZHUAN_BALL_NUM and zhuanzhi_task_status == TASK_STATUS.ACCEPT_PROCESS then
		local pos = self.wuzhuan_ball_list[wuzhuan_info + 1].transform.anchoredPosition3D
		local red_pos = Vector3(0, 0, 0)
		local effect_scale = 1
		local ball_red_flag = ZhuanZhiData.Instance:GetBallRedPointRemind(5, wuzhuan_info + 1)

		if wuzhuan_info + 1 >= 1 and wuzhuan_info + 1 <= 5 or wuzhuan_info + 1 == 12 then
			red_pos = Vector3(pos.x + ball_red_pos[1],pos.y + ball_red_pos[1], 0)
			effect_scale = ball_effect_scale[1]
		else
			red_pos = Vector3(pos.x + ball_red_pos[2], pos.y + ball_red_pos[2], 0)
			effect_scale = ball_effect_scale[2]
		end
		self:SetBallEffect(true, pos, effect_scale)
		self:SetBallRedPoint(ball_red_flag, red_pos)
	else
		self:SetBallRedPoint(false)
		self:SetBallEffect(false)
	end
end

function ZhuanZhiView:OnClickWuzhuanTaskBtn()
	local task_cfg, zhuanzhi_task_status = TaskData.Instance:GetNowZhuanZhiTask()
	if nil == task_cfg then
		return
	end
	MainUICtrl.Instance:GetTaskView():DoTask(task_cfg.task_id, zhuanzhi_task_status)
end

function ZhuanZhiView:OnClickGoFb()
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

function ZhuanZhiView:SetBallEffect(is_show, pos, scale)
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
				if nil == self.node_list then
					ResPoolMgr:Release(obj)
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

function ZhuanZhiView:SetBallRedPoint(is_show, pos)
	self.node_list["BallRedPoint"]:SetActive(is_show)
	self.node_list["BallRedPoint"].transform.localPosition = pos and pos or Vector3(0, 0, 0)
end

function ZhuanZhiView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftView"], PlayerData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightPlane"], PlayerData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["WuZhuanView"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)

	if self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_FOUR then
		self.juexing_one_view:DoPanelTweenPlay()
	elseif self.zhuan_index == ZHUANZHI_TIME.ZHUANZHI_TIME_FIVE then
		self.juexing_two_view:DoPanelTweenPlay()
	end

end

-------------------------------------动态生成左边滚动信息条-----------------------------------------

ZhuanZhiViewScrollCell = ZhuanZhiViewScrollCell or BaseClass(BaseCell)
function ZhuanZhiViewScrollCell:__init()
end

function ZhuanZhiViewScrollCell:__delete()
end

function ZhuanZhiViewScrollCell:OnFlush()
	if nil == self.data then
		return
	end

	for i=1 , 3 do
		self.node_list["bg_" .. i]:SetActive(i == self.data.skill_type)
	end

	if self.data.skill then
		local bundle, asset = ResPath.GetZhuanZhiSkill(self.data.skill)
		self.node_list["Icon"].image:LoadSprite(bundle, asset)
	end
	-- self.node_list["Icon"].transform.localScale = Vector3.one * self.data.scale
	self.node_list["desc"].text.text = self.data.desc
end
