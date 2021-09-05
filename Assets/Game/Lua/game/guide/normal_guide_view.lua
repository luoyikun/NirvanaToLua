NormalGuideView = NormalGuideView or BaseClass(BaseView)

NormalGuideView.GuideDir = {
	["left"] = 1,
	["right"] = 2,
	["top"] = 3,
	["bottom"] = 4,
}

function NormalGuideView:__init()
	self.ui_config = {{"uis/views/guideview_prefab", "NormalGuideView"}}
	self.step_cfg = {}
	self.target_height = 0
	self.target_width = 0

	--是否在缩小动画中
	self.is_end_ani = false
	self.change_value = 0

	self.obj_height = 0
	self.obj_width = 0
	self.obj_pos_x = 0
	self.obj_pos_y = 0

	self.view_layer = UiLayer.Guide
end

function NormalGuideView:__delete()
	if self.qinggong_guide_autoclick_timer then
		CountDown.Instance:RemoveCountDown(self.qinggong_guide_autoclick_timer)
		self.qinggong_guide_autoclick_timer = nil
	end
end

function NormalGuideView:ReleaseCallBack()
	if self.qinggong_guide_autoclick_timer then
		CountDown.Instance:RemoveCountDown(self.qinggong_guide_autoclick_timer)
		self.qinggong_guide_autoclick_timer = nil
	end
	
	if self.size_tween then
		self.size_tween:Kill()
		self.size_tween = nil
	end

	if self.other_size_tween then
		self.other_size_tween:Kill()
		self.other_size_tween = nil
	end

	self:StopFixTimeQuest()

	-- 清理变量和对象
	self.strong_block = nil
	self.right_guide = nil
	self.left_girl_guide = nil
	self.right_girl_guide = nil
	self.bottom_girl_guide = nil
	self.left_guide = nil
	self.top_girl_guide = nil
	self.left_image = nil
	self.right_image = nil
	self.block = nil
	self.kuang = nil
	self.other_kuang = nil
	self.left = nil
	self.right = nil
	self.top = nil
	self.bottom = nil
	self.strong_guide = nil
	self.animator = nil
	self.girl_arrow = nil
	self.week_block = nil
	self.click_obj = nil
	self.click_rect = nil
	self.guide_text_arrow = nil
	self.left_image = nil
	self.right_image = nil
	
	self.uicamera = nil
end

function NormalGuideView:LoadCallBack()
	self.strong_block = self.node_list["StrongBlock"]
	self.right_guide = self.node_list["RightGirlGuide"]
	self.left_girl_guide = self.node_list["LeftStrongGuide"]
	self.right_girl_guide = self.node_list["RightStrongGuide"]
	self.bottom_girl_guide = self.node_list["BottomStrongGuide"]
	self.left_guide = self.node_list["LeftGirlGuide"]
	self.top_girl_guide = self.node_list["TopStrongGuide"]
	self.left_image = self.node_list["LeftImage"]
	self.right_image = self.node_list["RightImage"]
	self.block = self.node_list["Block"]
	self.block:SetActive(true)

	self.left_image = self.node_list["LeftImage"]					--美女图片
	self.right_image = self.node_list["RightImage"]					--美女图片
	--获取组件
	self.kuang = self.node_list["Kuang"]								--指引框
	self.other_kuang = self.node_list["OtherKuang"]						--指引框(提示用)

	self.guide_text_arrow = self.node_list["GuideTextArrow"]			--文字强指引
	self.left = self.node_list["Left"]
	self.right = self.node_list["Right"]
	self.top = self.node_list["Top"]
	self.bottom = self.node_list["Bottom"]
	self.strong_guide = self.node_list["StrongGuide"]
	self.animator = self.strong_guide.animator

	self.girl_arrow = self.node_list["GirlArrow"]							--美女强指引箭头
	self.week_block = self.node_list["WeekBlock"]							--弱指引遮罩

	self.guide_list = {[1] = self.left_girl_guide, [2] = self.right_girl_guide, [3] = self.top_girl_guide, [4] = self.bottom_girl_guide, [5] = self.left_guide, [6] = self.right_guide}

	self.left.button:AddClickListener(BindTool.Bind(self.OtherClick, self))
	self.right.button:AddClickListener(BindTool.Bind(self.OtherClick, self))
	self.top.button:AddClickListener(BindTool.Bind(self.OtherClick, self))
	self.bottom.button:AddClickListener(BindTool.Bind(self.OtherClick, self))

	self.week_block.button:AddClickListener(BindTool.Bind(self.StrongBlockClick, self))
	self.strong_block.button:AddClickListener(BindTool.Bind(self.StrongBlockClick, self))


end

function NormalGuideView:SetBtnObj(obj)
	if nil == obj then
		return
	end
	self.click_obj = obj
	self.click_rect = self.click_obj:GetComponent(typeof(UnityEngine.RectTransform))
end

function NormalGuideView:SetStepCfg(cfg)
	self.step_cfg = cfg
end

function NormalGuideView:SetIsFrist(state)
	self.frist_open = state
end

function NormalGuideView:OtherClick()
	--是否点击任意地方关闭界面
	local is_click_another_close = self.step_cfg.is_rect_effect
	if is_click_another_close == 1 then
		self:StrongBlockClick()
		return
	end

	if self.obj_height == 0 then
		return
	end
	if self.is_end_ani then
		if self.other_size_tween then
			self.other_size_tween:Kill()
			self.other_size_tween = nil
		end
		self.other_kuang:SetActive(true)
		self.other_kuang.rect.localPosition = Vector2(self.obj_pos_x, self.obj_pos_y)
		self.other_kuang.rect.sizeDelta = Vector2(self.obj_width + 1000, self.obj_height + 1000)
		self.other_size_tween = self.other_kuang.rect:DOSizeDelta(Vector2(self.obj_width + 20, self.obj_height + 20), 0.5)
		self.other_size_tween:SetEase(DG.Tweening.Ease.OutQuad)
		self.other_size_tween:OnComplete(function()
			self.other_kuang:SetActive(false)
		end)
	end
end

function NormalGuideView:StrongBlockClick()
	self.block:SetActive(true)
	if self.click_call_back then
		self.click_call_back()
	end
	self:Close()
	FunctionGuide.Instance:StartNextStep()
end

function NormalGuideView:SetClickCallBack(callback)
	self.click_call_back = callback
end

--初始化界面（这时候暂时隐藏所有东西）
function NormalGuideView:InitView()
	--重置黑幕位置
	self:ReSetStrongGuide()

	self.other_kuang:SetActive(false)
	self:SetShowGuideNum(0)
	self.week_block:SetActive(false)
	self.kuang:SetActive(false)
	self.strong_block:SetActive(false)
	self:SetShowArrow(false)
	self.block:SetActive(false)
end

function NormalGuideView:SetShowGuideNum(num)
	if num == 5 or num == 6 then
		self.girl_arrow:SetActive(true)
	else
		self.girl_arrow:SetActive(false)
	end
	for i=1,6 do
		if num == i then
			self.guide_list[i]:SetActive(true)
		else
			self.guide_list[i]:SetActive(false)
		end
	end

	if self.step_cfg and self.step_cfg.module_name == ViewName.OffLineExp then -- 离线引导
		self.node_list["GirlRightTopGuide"]:SetActive(self.step_cfg.ui_name == GuideUIName.OffLineExpTop)
		self.node_list["GirlLeftBottomGuide"]:SetActive(self.step_cfg.ui_name == GuideUIName.OffLineExpDown)
	end
end

function NormalGuideView:SetShowArrow(bool)
	for i = 1, 5 do
		self.node_list["Arrow" .. i]:SetActive(bool)
	end
end

function NormalGuideView:FlushOneView()
	self:StopFixTimeQuest()

	self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	if self.click_rect then
		--重置锚点
		self.click_rect.pivot = Vector2(0.5, 0.5)
	end
	self:SetShowArrow(self.step_cfg.offset_y ~= 1)
	self:SetArrowTips(self.step_cfg.arrow_tip)

	local audio_id = self.step_cfg.offset_x
	if audio_id and audio_id ~= "" then
		local bundle, asset = ResPath.GetVoiceRes(audio_id)
		AudioManager.PlayAndForget(bundle, asset)
	end
	
	if self.step_cfg.is_modal == 1 then
		local arrow_dir = self.step_cfg.arrow_dir
		local dir_num = NormalGuideView.GuideDir[arrow_dir]
		if not dir_num then
			--1-4是带文字的箭头指引, 5-6是美女指引, 6以上的就只有箭头
			self:SetShowGuideNum(7)
			-- 0-3层为有文字的箭头指引, 4层为美女指引(包括只有箭头的情况)
			self.animator:SetLayerWeight(4, 1)
		else
			self:SetShowGuideNum(dir_num)
			self.animator:SetLayerWeight(dir_num - 1, 1)
		end

		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			local bunble, asset = ResPath.GetGuideviewRes("guide_talk_cell_girl")
			self.left_image.image:LoadSprite(bunble, asset)
			self.right_image.image:LoadSprite(bunble, asset)
		end

		self:FlushStrong()
	else
		local arrow_dir = self.step_cfg.arrow_dir
		local dir_num = NormalGuideView.GuideDir[arrow_dir]
		if not dir_num then
			--1-4是带文字的箭头指引, 5-6是美女指引, 6以上的就只有箭头
			self:SetShowGuideNum(7)
			-- 0-3层为有文字的箭头指引, 4层为美女指引(包括只有箭头的情况)
			self.animator:SetLayerWeight(4, 1)
		else
			self:SetShowGuideNum(dir_num)
			self.animator:SetLayerWeight(dir_num - 1, 1)
		end
		self:FlushWeak()
	end
end

function NormalGuideView:StopFixTimeQuest()
	if self.fix_time_quest then
		GlobalTimerQuest:CancelQuest(self.fix_time_quest)
		self.fix_time_quest = nil
	end
end

function NormalGuideView:OpenCallBack()
	self:InitView()
	self:FlushNow()

	self.is_first = true

	self.bottom_right_complete = true
	self.top_right_complete = true
	local cur_guide_step = FunctionGuide.Instance:GetCurGuideStep()
	local last_step_info = FunctionGuide.Instance:GetLastGuideStepCfg()
	if last_step_info and last_step_info.unuseful ~= 1 and last_step_info.step_type ~= GuideStepType.AutoCloseView then
		--如果上一个引导是这两个的按钮的话就要等待动画完毕再指引按钮（并且不是关闭操作）
		--由于两个动画的时候可能不统一，所以分开监听
		if last_step_info.ui_name == GuideUIName.MainUIRoleHead then
			self.bottom_right_complete = false
		elseif last_step_info.ui_name == GuideUIName.MainUIRightShrink then
			self.top_right_complete = false
		end
	end
	
	self.node_list["Desc"]:SetActive(false)

	local is_qinggong_guide = FunctionGuide.Instance:GetIsQingGongGuide()
	if is_qinggong_guide then
		self.node_list["Desc"]:SetActive(true)
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			local draw_obj = main_role:GetDrawObj()
			if draw_obj then
				draw_obj:SetRotation(0, -9, 0)
			end
		end

		MainUICtrl.Instance:SetJoystickIsShow(true)							--屏蔽摇杆
		Scene.Instance:LockCameraInQingGongGuide(true)						--锁定摄像机位置和角度
		MainUICtrl.Instance:ChangeFunctionTrailer(false)					--功能预告
		MainUICtrl.Instance:SetQingGongGuideClickCountDownState(true)		--

		local cur_guide_step = cur_guide_step - 1
		local delay_time = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].qinggong_delay_auto_click_time or 3
		local desc_str = cur_guide_step <= 4 and string.format(Language.QingGong["QingGongGuideDesc" .. cur_guide_step], delay_time) 
			or string.format(Language.QingGong.QingGongDownGuideDesc, delay_time)
		self.node_list["DescTxt"].text.text = desc_str

		self:SetQingGongGuideAutoClickTimer(cur_guide_step, delay_time)

		MainUICtrl.Instance:ShowQingGongGuideSkillEffect(true, cur_guide_step == 5)
	else
		-- 容错: 加一个倒计时，防止引导失效导致游戏无法进行
		self.fix_time_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:Close()
			FunctionGuide.Instance:StartNextStep()
		end, 2)
	end
end

function NormalGuideView:SetQingGongGuideAutoClickTimer(cur_guide_step, delay_time)
	if self.qinggong_guide_autoclick_timer then
		CountDown.Instance:RemoveCountDown(self.qinggong_guide_autoclick_timer)
		self.qinggong_guide_autoclick_timer = nil
	end
	local count_index = 0
	self.qinggong_guide_autoclick_timer = CountDown.Instance:AddCountDown(delay_time, 1,
		function(elapse_time, now_time)
			count_index = count_index + 1
			local desc_str = cur_guide_step <= 4 and Language.QingGong["QingGongGuideDesc" .. cur_guide_step]
					or Language.QingGong.QingGongDownGuideDesc

			if elapse_time < now_time then
				self.node_list["DescTxt"].text.text = string.format(desc_str, (now_time - count_index))
			else
				self.node_list["DescTxt"].text.text = string.format(desc_str, 0)
				CountDown.Instance:RemoveCountDown(self.qinggong_guide_autoclick_timer)
				self.qinggong_guide_autoclick_timer = nil
			end
	end)
end

function NormalGuideView:ReSetStrongGuide()
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height

	self.left.rect.offsetMin = Vector2(0, 0)
	self.left.rect.offsetMax = Vector2(0, 0)

	self.right.rect.offsetMin = Vector2(0, 0)
	self.right.rect.offsetMax = Vector2(0, 0)

	self.top.rect.offsetMin = Vector2(0, 0)
	self.top.rect.offsetMax = Vector2(0, 0)

	self.bottom.rect.offsetMin = Vector2(0, 0)
	self.bottom.rect.offsetMax = Vector2(0, 0)
end

function NormalGuideView:FlushNow()
	if next(self.step_cfg) then
		local main_view = MainUICtrl.Instance:GetView()
		if main_view then
			local player_button_ani_state = main_view:GetPlayerButtonAniState()
			local top_right_button_ani_state = main_view:GetRightButtonsVisible()
			if not self.bottom_right_complete then
				self.bottom_right_complete = player_button_ani_state == 0
			end
			if not self.top_right_complete then
				self.top_right_complete = top_right_button_ani_state == 1
			end

			if self.is_first and self.bottom_right_complete and self.top_right_complete then
				self:FlushOneView()
				self.is_first = false
			end
			if self.step_cfg.is_modal == 1 then
				self:FlushStrong()
			else
				self:FlushWeak()
			end
		end
	end
end

function NormalGuideView:FlushStrong()
	local main_view = MainUICtrl.Instance:GetView()
	if nil == main_view then return end

	local player_button_ani_state = main_view:GetPlayerButtonAniState()
	local top_right_button_ani_state = main_view:GetRightButtonsVisible()
	if not self.bottom_right_complete then
		self.bottom_right_complete = player_button_ani_state == 0
	end
	if not self.top_right_complete then
		self.top_right_complete = top_right_button_ani_state == 1
	end

	if not self.bottom_right_complete or not self.top_right_complete then
		return
	end

	if not self.click_rect or not next(self.step_cfg) then
		return
	end
	self.block:SetActive(false)
	self.week_block:SetActive(true)
	local is_qinggong_guide = FunctionGuide.Instance:GetIsQingGongGuide()
	self.kuang:SetActive(not is_qinggong_guide)
	self.strong_block:SetActive(true)

	self:ReSetStrongGuide()

	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.click_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	--计算高亮框的位置
	local height = rect.rect.height
	local width = rect.rect.width

	local click_real_rect = self.click_rect.rect
	local btn_height = click_real_rect.height
	local btn_width = click_real_rect.width
	local pos_x = local_pos_tbl.x
	local pos_y = local_pos_tbl.y

	--判断显示的美女指引位置
	if self.step_cfg.step_type == GuideStepType.GirlGuide then
		if pos_x > 0 then
			self:SetShowGuideNum(5)
		else
			self:SetShowGuideNum(6)
		end
		self.animator:SetLayerWeight(4, 1)
	end

	--设置强指引的位置
	local arrow_dir = self.step_cfg.arrow_dir
	local strong_guide = self.guide_text_arrow
	local guide_x = 0
	local guide_y = 0
	local rotarion = -1
	if arrow_dir == "left" then
		-- strong_guide = self.left_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 180
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x - btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "right" then
		-- strong_guide = self.right_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 0
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x + btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "top" then
		-- strong_guide = self.top_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 90
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom" then
		-- strong_guide = self.bottom_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 270
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "top_left" then
		strong_guide = self.girl_arrow
		rotarion = 135
		guide_x = pos_x - btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "top_right" then
		strong_guide = self.girl_arrow
		rotarion = 45
		guide_x = pos_x + btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom_left" then
		strong_guide = self.girl_arrow
		rotarion = 225
		guide_x = pos_x - btn_width/2
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "bottom_right" then
		strong_guide = self.girl_arrow
		rotarion = 315
		guide_x = pos_x + btn_width/2
		guide_y = pos_y - btn_height/2
	end
	local normal_rect = strong_guide.rect
	normal_rect.localPosition = Vector2(guide_x, guide_y)

	if rotarion ~= -1 then
		normal_rect.localEulerAngles = Vector3(0, 0, rotarion)
	end
	--用DoTween实现缩放效果
	if nil == self.size_tween and btn_width > 0 and btn_height > 0 then
		self.is_end_ani = false
		self.kuang.rect.sizeDelta = Vector2(btn_width + 600, btn_height + 600)
		self.size_tween = self.kuang.rect:DOSizeDelta(Vector2(btn_width + 10, btn_height + 10), 0.7)
		self.size_tween:SetEase(DG.Tweening.Ease.OutQuart)
		-- self.size_tween:SetUpdate(true)			--按真实时间执行
		self.size_tween:OnComplete(function()
			self.is_end_ani = true
			self.size_tween = self.kuang.rect:DOSizeDelta(Vector2(btn_width + 20, btn_height + 20), 0.5)
			self.size_tween:SetEase(DG.Tweening.Ease.Linear)
			self.size_tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
		end)
	end

	--记录指引按钮的大小
	if btn_height ~= self.obj_height or btn_width ~= self.obj_width then
		self.obj_height = btn_height
		self.obj_width = btn_width
	end
	self.obj_pos_x = pos_x
	self.obj_pos_y = pos_y

	--设置框
	self.kuang.rect.localPosition = Vector2(pos_x, pos_y)

	local left_width = (width/2 + pos_x - btn_width/2) + 5
	local right_width = (width/2 - (pos_x + btn_width/2)) + 5
	local top_height = (height/2 - (pos_y + btn_height/2)) + 5
	local bottom_height = (height/2 + pos_y - btn_height/2) + 5

	self.left.rect.offsetMin = Vector2(0, 0)
	self.left.rect.offsetMax = Vector2(-(width - left_width), 0)

	self.right.rect.offsetMin = Vector2(width - right_width, 0)
	self.right.rect.offsetMax = Vector2(0, 0)

	self.top.rect.offsetMin = Vector2(left_width, height-top_height)
	self.top.rect.offsetMax = Vector2(-right_width, 0)

	self.bottom.rect.offsetMin = Vector2(left_width, 0)
	self.bottom.rect.offsetMax = Vector2(-right_width, -(height-bottom_height))
end

function NormalGuideView:FlushWeak()
	if not self.click_rect or not next(self.step_cfg) then
		return
	end
	self.block:SetActive(false)
	self.week_block:SetActive(false)
	self.kuang:SetActive(false)
	self.strong_block:SetActive(false)

	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.click_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	local click_real_rect = self.click_rect.rect
	local btn_height = click_real_rect.height
	local btn_width = click_real_rect.width
	local pos_x = local_pos_tbl.x
	local pos_y = local_pos_tbl.y

	--设置弱指引遮罩的位置大小
	self.week_block.rect.localPosition = Vector2(pos_x, pos_y)
	self.week_block.rect.sizeDelta = Vector2(btn_width, btn_height)

	--设置弱指引的位置
	local arrow_dir = self.step_cfg.arrow_dir
	local dir_obj = self.guide_text_arrow
	local is_special_arrow = false
	local guide_x = 0
	local guide_y = 0
	local rotarion = 0
	if arrow_dir == "left" then
		rotarion = 180
		guide_x = pos_x - btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "right" then
		rotarion = 0
		guide_x = pos_x + btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "top" then
		rotarion = 90
		guide_x = pos_x
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom" then
		rotarion = 270
		guide_x = pos_x
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "top_left" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 135
		guide_x = pos_x - btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "top_right" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 45
		guide_x = pos_x + btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom_left" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 225
		guide_x = pos_x - btn_width/2
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "bottom_right" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 315
		guide_x = pos_x + btn_width/2
		guide_y = pos_y - btn_height/2
	end

	dir_obj.rect.localPosition = Vector2(guide_x, guide_y)
	if is_special_arrow then
		dir_obj.rect.localEulerAngles = Vector3(0, 0, rotarion)
	end
end

function NormalGuideView:OnFlush(paramt)
	for k, v in pairs(paramt) do
		if k == "qinggongguide" then
			self:StrongBlockClick()
		end
	end
	self:FlushNow()
end

function NormalGuideView:CloseCallBack()
	self.step_cfg = {}
	self.click_obj = nil
	self.click_rect = nil
	self.click_call_back = nil

	self.is_end_ani = false
	self.change_value = 0

	self.target_width = 0
	self.target_height = 0

	self.obj_height = 0
	self.obj_width = 0
	self.obj_pos_x = 0
	self.obj_pos_y = 0

	if self.size_tween then
		self.size_tween:Kill()
		self.size_tween = nil
	end

	if self.other_size_tween then
		self.other_size_tween:Kill()
		self.other_size_tween = nil
	end

	self.uicamera = nil

	self:StopFixTimeQuest()

end

function NormalGuideView:SetArrowTips(des)
	for i = 1, 8 do
		self.node_list["NormalDesc" .. i].text.text = des
	end
end