require("game/marriage/marriage_love_contract_view")
MarriageHoneymoonView = MarriageHoneymoonView or BaseClass(BaseRender)

local EFFECT_CD = 1
local SEND_CD = 10 --发送脱单宣言CD
local CHATSELF = 1 
local CHATLOVER = 2
local CHATBABY = 3

local BABY_CONFIG = {
	-- 模型位置，名字位置，气泡框位置
	[10997001] = {Vector3(0, 70, 0), Vector3(0, 30, 0), Vector3(-20, -30, 0)}, -- 中人之资
	[10998001] = {Vector3(0, 80, 0), Vector3(0, 20, 0), Vector3(-20, -30, 0)}, -- 小有才情
	[10999001] = {Vector3(0, 80, 0), Vector3(0, 30, 0), Vector3(-20, -30, 0)}, -- 聪颖绝伦
	[11001001] = {Vector3(0, 70, 0), Vector3(0, 110, 0), Vector3(-20, 50, 0)}, -- 龙宝宝
	[11000001] = {Vector3(0, 70, 0), Vector3(0, 90, 0), Vector3(-20, 30, 0)}, -- 凤宝宝
}

function MarriageHoneymoonView:__init()
	-- self.monomer_cell_list = {}
	-- self.monomer_data = {}

	-- local scroller_delegate = self.node_list["MonomerList"].list_simple_delegate
	-- scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	-- scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.effect_cd = 0

	self.node_list["TxtSelfName"].text.text = GameVoManager.Instance:GetMainRoleVo().name
	self.now_ring_item_id = 0

	-- self.node_list["OnlySexCheckBox"].toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckBoxChange, self))

	-- self.monomer_animator = self.node_list["MonomerView"].animator
	self.node_list["BtnProposal"].button:AddClickListener(BindTool.Bind(self.GoToMarryClick, self))
	self.node_list["BtnFunc"].button:AddClickListener(BindTool.Bind(self.ClickDivorce, self))
	self.node_list["BtnTuoDan"].button:AddClickListener(BindTool.Bind(self.ClickMonomer, self))
	-- self.node_list["Block"].button:AddClickListener(BindTool.Bind(self.HideOrShowMonomer, self))
	-- self.node_list["BtnArrow"].button:AddClickListener(BindTool.Bind(self.HideOrShowMonomer, self))
	self.node_list["BtnQiuhun2"].button:AddClickListener(BindTool.Bind(self.GoToMarry, self))
	self.node_list["BtnHunli"].button:AddClickListener(BindTool.Bind(self.GoToHunYan, self))
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.ClickTitleShow, self))
	self.node_list["OuShiMarry"].button:AddClickListener(BindTool.Bind(self.OnOuShiMarry, self))
	self.node_list["ImgBaby"].button:AddClickListener(BindTool.Bind(self.OnClickBaby, self))
	self.node_list["BtnPerfectLover"].button:AddClickListener(BindTool.Bind(self.OnClickPerfectLove, self))
	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	local event_trigger = self.node_list["RotateEventTriggerLover"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragLover, self))

	self.start_level = 0--开始自动升级的等级
	self.now_ring_level = 0

	self:InitDisPlay()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.MarryParty)
end

function MarriageHoneymoonView:__delete()
	if self.marriage_wedding_view then
		self.marriage_wedding_view:DeleteMe()
		self.marriage_wedding_view = nil
	end

	if self.love_contract_view then
		self.love_contract_view:DeleteMe()
		self.love_contract_view = nil
	end

	if self.self_model then
		self.self_model:DeleteMe()
		self.self_model = nil
	end

	if self.love_model then
		self.love_model:DeleteMe()
		self.love_model = nil
	end

	if self.baby_model then
		self.baby_model:DeleteMe()
		self.baby_model = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.effect_cd = 0

	-- for k, v in pairs(self.monomer_cell_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.monomer_cell_list = {}

	if self.ring_cell then
		self.ring_cell:DeleteMe()
		self.ring_cell = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end	
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end

function MarriageHoneymoonView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function MarriageHoneymoonView:OnRoleDragSelf(data)
	if self.self_model then
		self.self_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageHoneymoonView:OnRoleDragLover(data)
	if self.love_model then
		self.love_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarriageHoneymoonView:OnClickPerfectLove()
	ViewManager.Instance:Open(ViewName.PerfectLover)
end

--伴侣
function MarriageHoneymoonView:ClickLover()
	self:ShowIndexCallBack(TabIndex.marriage_lover)
end

--婚戒
function MarriageHoneymoonView:ClickRing()
	self:ShowIndexCallBack(TabIndex.marriage_ring) 
end

--婚宴
function MarriageHoneymoonView:ClickHunYan()
	self:ShowIndexCallBack(TabIndex.marriage_weeding)
end

--契约
function MarriageHoneymoonView:ClickQiYue()
	self:ShowIndexCallBack(TabIndex.marriage_love_contract)
end

--光环
function MarriageHoneymoonView:ClickHalo()
	self:ShowIndexCallBack(TabIndex.marriage_love_halo)
end

function MarriageHoneymoonView:ShowIndexCallBack(index)
	self:StopAutoUpgrade()

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if index == TabIndex.marriage_honeymoon or index == TabIndex.marriage_lover or index == TabIndex.marriage_monomer then
		self:RingInfoChange()
		self:FlushDisPlay()
		-- self.node_list["LoverView"]:SetActive(true)
		if index == TabIndex.marriage_monomer and main_vo.lover_uid <= 0 then
			self:OpenTuoDanList()
		end
	else
		self:ShowIndexCallBack(TabIndex.marriage_lover)
	end
end

function MarriageHoneymoonView:ShowOrHideTab()

end

function MarriageHoneymoonView:MarryStateChange()

	self:FlushDisPlay()
	self:RingInfoChange()
end

function MarriageHoneymoonView:FlushLoveContractView()
		GlobalTimerQuest:AddDelayTimer(function()
			if self.love_contract_view then
				self.love_contract_view:FlushLoveContractView()
			end
		end, 0)
end

function MarriageHoneymoonView:FlushWedding()
	if self.marriage_wedding_view then
		self.marriage_wedding_view:Flush()
	end
end

function MarriageHoneymoonView:CloseCallBack()
	self:StopAutoUpgrade()
	self:CancelTuoDanQuest()
end

function MarriageHoneymoonView:OpenMail()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_mail)
end

function MarriageHoneymoonView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(9)
end

function MarriageHoneymoonView:ClickMonomer()
	ViewManager.Instance:Open(ViewName.OffSheetSpeakView)
end

function MarriageHoneymoonView:ClickDivorce()
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[2])
end

function MarriageHoneymoonView:StopAutoUpgrade()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function MarriageHoneymoonView:InitDisPlay()
	if not self.self_model then
		self.self_model = RoleModel.New()
		self.self_model:SetDisplay(self.node_list["SelfDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if not self.love_model then
		self.love_model = RoleModel.New()
		self.love_model:SetDisplay(self.node_list["LoveDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if not self.baby_model then
		self.baby_model = RoleModel.New()
		self.baby_model:SetDisplay(self.node_list["BabyDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
end

function MarriageHoneymoonView:FlushDisPlay()
	self:InitDisPlay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo = {}
	role_vo.prof = main_role_vo.prof
	role_vo.sex = main_role_vo.sex
	role_vo.appearance = {}
	role_vo.appearance.fashion_body = 2
	self.self_model:SetModelResInfo(role_vo, true)
	self.self_model:SetDisplay(self.node_list["SelfDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	-- self.self_model:SetScale(Vector3(1.5, 1.5, 1.5))
	--有伴侣才加载伴侣模型
	GlobalTimerQuest:AddDelayTimer(function()
		if main_role_vo.lover_uid > 0 then
			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_body = 2
			self.love_model:SetModelResInfo(lover_vo, true)
			self.love_model:SetDisplay(self.node_list["LoveDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
			-- self.love_model:SetScale(Vector3(1.5, 1.5, 1.5))
		end
	end, 0)

	local baby_info = BaobaoData.Instance:GetBestBabyData()
	local resid = baby_info and BaobaoData.BabyModel[baby_info.baby_id + 1] or 0

	local data_list = {}
	local data_list1 = {}
	local longbaby_index = 1
	local fenbaby_index = 2
	local is_long_feng = false 
	local long_id = 0
	local feng_id = 0
	if main_role_vo.sex == 1 then
		data_list = BaobaoData.Instance:GetEquipLongInfo(longbaby_index)
		data_list1 = BaobaoData.Instance:GetEquipFengInfo(fenbaby_index)
		long_id = BaobaoData.Instance:GetMaxLongFenBaoBaoCfg(longbaby_index, longbaby_index)
	else
		data_list1 = BaobaoData.Instance:GetEquipLongInfo(fenbaby_index)
		data_list = BaobaoData.Instance:GetEquipFengInfo(longbaby_index)
		feng_id = BaobaoData.Instance:GetMaxLongFenBaoBaoCfg(fenbaby_index, fenbaby_index)
	end

	if data_list and data_list.special_baby_level ~= 0 and data_list.quality ~= 0 then
		resid = long_id > 0 and long_id or feng_id
		is_long_feng = true
	end
	if data_list1 and data_list1.special_baby_level ~= 0 and data_list1.quality ~= 0 then
		resid = long_id > 0 and long_id or feng_id
		is_long_feng = true
	end

	if resid and resid > 0 then
		self.node_list["BabyDisplay"].transform.localPosition = BABY_CONFIG[resid] and BABY_CONFIG[resid][1] or Vector3(0, 0, 0)
		self.node_list["ImgBabyName"].transform.localPosition = BABY_CONFIG[resid] and BABY_CONFIG[resid][2] or Vector3(0, 0, 0)
		self.node_list["ImgChat3"].transform.localPosition = BABY_CONFIG[resid] and BABY_CONFIG[resid][3] or Vector3(0, 0, 0)
		self.node_list["ImgBaby"]:SetActive(false)
		self.baby_model:SetMainAsset(ResPath.GetSpiritModel(resid))
		self.baby_model:ResetRotation()
		-- self.baby_model:SetRotation(Vector3(0, -30, 0))
		if is_long_feng then
			self.baby_model:SetScale(Vector3(0.5, 0.5, 0.5))
		elseif resid == BaobaoData.BabyModel[3] then
			self.baby_model:SetScale(Vector3(0.8, 0.8, 0.8))
		else
			self.baby_model:SetScale(Vector3(1, 1, 1))
		end
		self:FlushBabyChat()
	else
		self.node_list["ImgBaby"]:SetActive(OpenFunData.Instance:CheckIsHide("MarryBaby"))
	end
	local is_has_xianshi = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BABYHALDOFF)
	self.node_list["ImgHalfOff"]:SetActive(OpenFunData.Instance:CheckIsHide("MarryBaby") and is_has_xianshi and resid == 0)

	local baby_name = baby_info and baby_info.baby_name or ""
	if is_long_feng and long_id > 0 then
		baby_name = Language.Marriage.LongBaoBao
	elseif is_long_feng and feng_id > 0 then
		baby_name = Language.Marriage.FengBaoBao
	end
	self.node_list["TxtBabyName"].text.text = baby_name
	self.node_list["ImgBabyName"]:SetActive(baby_name ~= "")
end

function MarriageHoneymoonView:FlushBabyChat()
	local rand_num = math.random(1, 4)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo().sex
	local call_name = Language.Marriage.BaoBaoChatCall[main_role_vo] or ""
	local chat_text = Language.Marriage.BaoBaoDialog[rand_num]

	local show_text = ""
	local show_text2 = ""
	if rand_num <= 2 then
		show_text = string.format(chat_text[1], call_name)
		show_text2 = chat_text[2]
	elseif rand_num == 3 then
		show_text = string.format(chat_text[1], call_name)
		show_text2 = string.format(chat_text[2], call_name)
	end

	local show_index = 0
	local speak_time = 0
	local diff_time = 20

	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 1)
			speak_time = speak_time + 1

			if left_time <= 1 then
				self:RemoveCountDown()
				return
			elseif speak_time == 1 then
				if rand_num <= 2 then
					self:SetShowChat(CHATBABY, show_text)
				elseif rand_num == 3 then
					self:SetShowChat(CHATSELF, show_text)
				else
					show_index = main_role_vo == 1 and 1 or 2
					self:SetShowChat(show_index, chat_text[1])
				end
			elseif speak_time == 6 then
				if rand_num <= 2 then
					self:SetShowChat(CHATSELF, show_text2)
				elseif rand_num == 3 then
					self:SetShowChat(CHATBABY, show_text2)
				else
					show_index = main_role_vo == 1 and 2 or 1
					self:SetShowChat(show_index, chat_text[2])
				end
			elseif speak_time == 11 then
				if rand_num == 4 then
					self:SetShowChat(CHATBABY, chat_text[3])
				else
					self:SetShowChat(0, "")
				end
			elseif speak_time == 16 then
				self:SetShowChat(0, "")
			end
		end
		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 1, diff_time_func)
	end
end

function MarriageHoneymoonView:SetShowChat(index, text)
	for i = 1, 3 do
		if i == index then
			self.node_list["TxtChat" .. i].text.text = text
			self.node_list["ImgChat" .. i]:SetActive(true)
		else
			self.node_list["ImgChat" .. i]:SetActive(false)
		end
	end
end

function MarriageHoneymoonView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	-- self:FlushBabyChat()
end

function MarriageHoneymoonView:RingInfoChange()
	self:Flush()
end

function MarriageHoneymoonView:CancelTuoDanQuest()
	if self.tuo_dan_count_down then
		CountDown.Instance:RemoveCountDown(self.tuo_dan_count_down)
		self.tuo_dan_count_down = nil
	end
end

function MarriageHoneymoonView:ChangeTuoDanBtnText()
	--开始倒计时
	self:CancelTuoDanQuest()
	local send_time = MarriageData.Instance:GetSendTuoDanTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if send_time <= 0 or (server_time - send_time) > SEND_CD then
		Ui:SetButtonEnabled(self.node_list["BtnTuoDan"], true)
		return
	end

	local left_time = math.ceil(SEND_CD - (server_time - send_time))
	left_time = left_time > SEND_CD and SEND_CD or left_time

	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:CancelTuoDanQuest()
			Ui:SetButtonEnabled(self.node_list["BtnTuoDan"], true)
			return
		end
		local temp_time = math.ceil(total_time - elapse_time)
		local time_des = string.format(Language.Chat.ResetTimes, temp_time)
		Ui:SetButtonEnabled(self.node_list["BtnTuoDan"], false)
	end

	self.tuo_dan_count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	Ui:SetButtonEnabled(self.node_list["BtnTuoDan"], false)
	local time_des = string.format(Language.Chat.ResetTimes, left_time)
end

function MarriageHoneymoonView:Flush()
	--是否结婚
	local is_marry = self:CheckIsMarry()
	self.node_list["SingleView"]:SetActive(not is_marry)
	self.node_list["LoverView"]:SetActive(is_marry)
	-- self.node_list["MonomerView"]:SetActive(not is_marry)
	self.node_list["TxtProposalBtn"]:SetActive(not is_marry)
	self.node_list["TxtTeam"]:SetActive(is_marry)
	self.node_list["BtnProposal"]:SetActive(not is_marry)
	if is_marry then
		self.node_list["ImgLover"]:SetActive(not is_marry)
		self.node_list["ImgLover1"]:SetActive(not is_marry)
		self.node_list["LoveDisplay"]:SetActive(is_marry)
		self.node_list["TxtLevel"]:SetActive(is_marry)
		self.node_list["TxtName"]:SetActive(is_marry)
		self.node_list["BtnFunc"]:SetActive(is_marry)
		self.node_list["BtnTuoDan"]:SetActive(not is_marry)
		self.node_list["BtnQiuhun2"]:SetActive(is_marry)
		self.node_list["BtnHunli"]:SetActive(is_marry)
		self.node_list["BtnTitle"]:SetActive(is_marry)
		self.node_list["OuShiMarry"]:SetActive(is_marry)
		self:LoverChange()
	end

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if open_day <= 2 then
		self.node_list["OuShiMarry"]:SetActive(false)
	end

	self:UpdateZheKou()
end

function MarriageHoneymoonView:UpdateZheKou()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("MarriageHoneymoonView" .. main_role_id) or cur_day
	local is_marry = MarriageData.Instance:CheckIsMarry()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING)
	if cur_day ~= -1 and cur_day ~= remind_day and is_marry and is_open then	
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)	
	end

	if ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) then
		self.node_list["BtnPerfectLover"]:SetActive(true)
		self.node_list["BtnQiuhun2"]:SetActive(false)
	else
		self.node_list["BtnPerfectLover"]:SetActive(false)
	end


	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING) then
		if self.count_down_timer then
			CountDown.Instance:RemoveCountDown(self.count_down_timer)
			self.count_down_timer = nil
		end
		local count_down_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING)
		if count_down_time > 0 then
			local time = TimeUtil.FormatSecond(math.floor(count_down_time), 10)
			self.node_list["BuyTime"].text.text = time
			self.node_list["SaleEffect"]:SetActive(true)
			self.node_list["IconXianShi"]:SetActive(true)						
			self.count_down_timer = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.UpdateTimerCallback, self), 
				BindTool.Bind(self.CompleteTimerCallback, self))
		else
			self.node_list["BuyTime"].text.text = ""
			self.node_list["SaleEffect"]:SetActive(false)
			self.node_list["IconXianShi"]:SetActive(false)			
		end
	else
		if self.count_down_timer then
			CountDown.Instance:RemoveCountDown(self.count_down_timer)
			self.count_down_timer = nil
		end		
		self.node_list["BuyTime"].text.text = ""
		self.node_list["SaleEffect"]:SetActive(false)
		self.node_list["IconXianShi"]:SetActive(false)					
	end	
end

function MarriageHoneymoonView:UpdateTimerCallback(elapse_time, total_time)
	if self.node_list and self.node_list["BuyTime"] and self.node_list["BuyTime"].text and self.node_list["BuyTime"].text.text then
		local time = TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 10)
		self.node_list["BuyTime"].text.text = time
		self.node_list["SaleEffect"]:SetActive(true)
		self.node_list["IconXianShi"]:SetActive(true)
	end
end

function MarriageHoneymoonView:CompleteTimerCallback()
	if self.node_list and self.node_list["BuyTime"] and self.node_list["BuyTime"].text and self.node_list["BuyTime"].text.text then
		self.node_list["BuyTime"].text.text = ""
		self.node_list["SaleEffect"]:SetActive(false)
		self.node_list["IconXianShi"]:SetActive(false)
	end
end

function MarriageHoneymoonView:LoverChange()
	--脡猫露篓掳茅脗脗脨脭卤冒脙没鲁脝
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtObjectName"].text.text = main_role_vo.lover_name
	local lover_is_girl = main_role_vo.sex == 1 and true or false
	local is_marry = self:CheckIsMarry()
	if not is_marry then
	self.node_list["ImgLover"]:SetActive(not lover_is_girl)
	self.node_list["ImgLover1"]:SetActive(lover_is_girl)
	end
	self.node_list["ImgSexIconGril"]:SetActive(not lover_is_girl)
	self.node_list["ImgSexIconBoy"]:SetActive(lover_is_girl)
	
	self.node_list["ImgSexIconGril1"]:SetActive(lover_is_girl)
	self.node_list["ImgSexIconBoy2"]:SetActive(not lover_is_girl)
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(GameVoManager.Instance:GetMainRoleVo().level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["TxtLevel2"].text.text = string.format(Language.Marriage.MyLevel, PlayerData.GetLevelString(GameVoManager.Instance:GetMainRoleVo().level))

	local lover_level = MarriageData.Instance:GetLoverLevel()
	local lover_star = MarriageData.Instance:GetLoverStar()

	-- lv, zhuan = PlayerData.GetLevelAndRebirth(lover_level)
	-- level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["TxtLevel"].text.text = string.format(Language.Marriage.HeLevel, PlayerData.GetLevelString(lover_level))

	self.node_list["TxtRingLevel"].text.text = string.format(Language.Marriage.HisRingLevel, lover_star)

	local ring_cfg = MarriageData.Instance:GetRingCfg()
	if ring_cfg ~= nil then
		local _, big_lev = math.modf(ring_cfg.equip_id / 10)
		big_lev = string.format("%.2f", big_lev or 0) * 100
		local level = big_lev + ring_cfg.star
		self.node_list["TxtLevelTxt"].text.text = string.format(Language.Marriage.RingLevel, level)
	else
		self.node_list["TxtLevelTxt"].text.text = string.format(Language.Marriage.RingLevel, 0)
	end

	local title_show = MarriageData.Instance:GetMarryTitleShow()
	local title_cfg = nil
	if title_show then
		title_cfg = ItemData.Instance:GetItemConfig(title_show)
	end
	if title_cfg then
		local bundle, asset = ResPath.GetTitleIcon(title_cfg.param1)
		self.node_list["BtnTitle"].image:LoadSprite(bundle, asset, function()
			TitleData.Instance:LoadTitleEff(self.node_list["BtnTitle"], title_cfg.param1, true)
			self.node_list["BtnTitle"].image:SetNativeSize()
		end)
	end

end

--脢脟路帽脪脩禄茅
function MarriageHoneymoonView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

--脟掳脥霉陆谩禄茅
function MarriageHoneymoonView:GoToMarryClick()
	if self:CheckIsMarry() then
		if not ScoietyData.Instance:GetTeamState() then
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 1
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(GameVoManager.Instance:GetMainRoleVo().lover_uid)
	else
		-- ViewManager.Instance:Open(ViewName.Wedding)
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[1])
	end
end

function MarriageHoneymoonView:GoToMarry()
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[1])
end

function MarriageHoneymoonView:GoToHunYan()
	-- TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[3])
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Not_Marry)
		return
	end
	ViewManager.Instance:Open(ViewName.MarriageWedding)
end

--脟掳脥霉脭脗脌脧
function MarriageHoneymoonView:GoToMarryNpc()
	local cfg = MarriageData.Instance:GetMarriageConditions()
	if nil == cfg then return end
	local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.marry_npc_scene_id, cfg.marry_npc_id)
	if npc_info then
		local callback = function()
			MoveCache.end_type = MoveEndType.NpcTask
			MoveCache.param1 = cfg.marry_npc_id
			GuajiCtrl.Instance:MoveToPos(cfg.marry_npc_scene_id, npc_info.x, npc_info.y, 1, 1, false)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end
	ViewManager.Instance:Close(ViewName.Marriage)
end

--脟掳脥霉陆谩禄茅脤谩脢戮掳氓
function MarriageHoneymoonView:ShowGoToMarryTips()
	local click_func = BindTool.Bind(self.GoToMarryClick, self)
	TipsCtrl.Instance:ShowOneOptionView(Language.Marriage.Not_Marry_Can_Not_Use, click_func, Language.Marriage.Go_To_Marry)
end

--陆盲脰赂掳麓脧脗脢卤
function MarriageHoneymoonView:RingClick()
	local ring_had_active = MarriageData.Instance:GetRingHadActive()
	if ring_had_active then
	else
		if self:CheckIsMarry() then
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			self:ShowGoToMarryTips()
		end
	end
end

-- function MarriageHoneymoonView:OnCheckBoxChange(isOn)
-- 	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(isOn)
-- 	self.node_list["MonomerList"].scroller:ReloadData(0)
-- end

function MarriageHoneymoonView:OpenTuoDanList()
	self:HideOrShowMonomer()
end

-- function MarriageHoneymoonView:HideOrShowMonomer()
-- 	local bool = self.monomer_animator:GetBool("open")
-- 	bool = not bool
-- 		-- self.node_list["ImgArrow"]:SetActive( not bool)
-- 	if bool then
-- 		self.node_list["OnlySexCheckBox"].toggle.isOn = true
-- 		local only_other_sex = true
-- 		self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
-- 		self.node_list["MonomerList"].scroller:ReloadData(0)
-- 	end
-- 	self.monomer_animator:SetBool("open", bool)
-- end

-- function MarriageHoneymoonView:GetNumberOfCell()
-- 	return #self.monomer_data
-- end

-- function MarriageHoneymoonView:RefreshCell(cell, data_index)
-- 	data_index = data_index + 1
-- 	local monomer_cell = self.monomer_cell_list[cell]
-- 	if not monomer_cell then
-- 		monomer_cell = MonomerItemCell.New(cell.gameObject)
-- 		self.monomer_cell_list[cell] = monomer_cell
-- 	end
-- 	monomer_cell:SetIndex(data_index)
-- 	monomer_cell:SetData(self.monomer_data[data_index])
-- end

function MarriageHoneymoonView:FlushTuoDanList()
	-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- if main_role_vo.lover_uid <= 0 then
	-- 	local only_other_sex = self.node_list["OnlySexCheckBox"].toggle.isOn
	-- 	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
	-- 	self.node_list["MonomerList"].scroller:RefreshAndReloadActiveCellViews(true)
	-- end

	self:UpdateZheKou()
end

function MarriageHoneymoonView:ClickTitleShow()
	local title_id = MarriageData.Instance:GetMarryTitleShow()
	if title_id then
		TipsCtrl.Instance:OpenItem({item_id = title_id})
	end
end

function MarriageHoneymoonView:OnClickBaby()
	ViewManager.Instance:Open(ViewName.MarryBaby, TabIndex.marriage_baobao_bless)
end

function MarriageHoneymoonView:OnOuShiMarry()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		PlayerPrefsUtil.SetInt("MarriageHoneymoonView" .. main_role_id, cur_day)
		RemindManager.Instance:Fire(RemindName.MarryAffection)
	end	
	ViewManager.Instance:Open(ViewName.EuropeanWeddingView)

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("MarriageHoneymoonView" .. main_role_id) or cur_day
	local is_marry = MarriageData.Instance:CheckIsMarry()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING)
	if cur_day ~= -1 and cur_day ~= remind_day and is_marry and is_open then	
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)	
	end	
end

-------------我要脱单ItemCell------------------------
-- MonomerItemCell = MonomerItemCell or BaseClass(BaseCell)

-- function MonomerItemCell:__init()
-- 	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.ClickGood, self))
-- 	self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.ClickHead, self))
-- 	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPowerNum"], "FightPower3")
-- end

-- function MonomerItemCell:__delete()
-- 	self.fight_text = nil
-- end

-- function MonomerItemCell:OnFlush()
-- 	if not self.data or not next(self.data) then
-- 		return
-- 	end
-- 	if self.data.sex == 1 then
-- 		self.node_list["Img"]:SetActive(false)
-- 		self.node_list["Img1"]:SetActive(true)
-- 	else
-- 		self.node_list["Img"]:SetActive(true)
-- 		self.node_list["Img1"]:SetActive(false)
-- 	end

-- 	self.node_list["Txt"].text.text = self.data.name
-- 	if self.fight_text and self.fight_text.text then
-- 		self.fight_text.text.text = self.data.capability
-- 	end

-- 	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
-- 	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
-- 	self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(self.data.level)
-- 	self.node_list["TxtDes"].text.text = self.data.notice

-- 	local main_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	self.node_list["Btn"]:SetActive(self.data.uid ~= main_vo.role_id)

-- 	--设置头像
-- 	local role_id = self.data.uid
-- 	AvatarManager.Instance:SetAvatar(role_id, self.node_list["RawImage"],self.node_list["ImgIcon"], self.data.sex, self.data.prof, false)

-- 	self:StartCountDown()
-- end

-- --示好
-- function MonomerItemCell:ClickGood()
-- 	local main_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	if self.data.uid == main_vo.role_id then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotGoodDes)
-- 		return
-- 	end

-- 	local private_obj = {}
-- 	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.data.uid) then
-- 		private_obj = ChatData.CreatePrivateObj()
-- 		private_obj.role_id = self.data.uid
-- 		private_obj.username = self.data.name
-- 		private_obj.sex = self.data.sex
-- 		private_obj.prof = self.data.prof
-- 		private_obj.avatar_key_small = self.data.avatar_key_small
-- 		private_obj.level = self.data.level
-- 		private_obj.create_time = TimeCtrl.Instance:GetServerTime()
-- 		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
-- 	end

-- 	local text = MarriageData.Instance:GetTuoDanDes()

-- 	local msg_info = ChatData.CreateMsgInfo()
-- 	msg_info.from_uid = main_vo.role_id
-- 	msg_info.username = main_vo.name
-- 	msg_info.sex = main_vo.sex
-- 	msg_info.camp = main_vo.camp
-- 	msg_info.prof = main_vo.prof
-- 	msg_info.authority_type = main_vo.authority_type
-- 	msg_info.avatar_key_small = main_vo.avatar_key_small
-- 	msg_info.level = main_vo.level
-- 	msg_info.vip_level = main_vo.vip_level
-- 	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
-- 	msg_info.content = text
-- 	msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
-- 	msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
-- 	msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0--土豪金
-- 	msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()--气泡框
-- 	msg_info.is_read = 1
	
-- 	ChatData.Instance:AddPrivateMsg(self.data.uid, msg_info)

-- 	ChatCtrl.SendSingleChat(self.data.uid, text, CHAT_CONTENT_TYPE.TEXT)

-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.GoodSuccDes)

-- 	--设置冷却时间
-- 	MarriageData.Instance:AddSendGoodTimeList(self.data.uid)
-- 	self:StartCountDown()
-- end

-- --开始倒计时
-- function MonomerItemCell:StartCountDown()
-- 	self:StopCountDown()
-- 	local server_time = TimeCtrl.Instance:GetServerTime()
-- 	local last_send_time = MarriageData.Instance:GetSendGoodTime(self.data.uid) or 0
-- 	local end_cd_time = last_send_time + 10
-- 	if server_time >= end_cd_time then
-- 		self.node_list["Txt1"]:SetActive(flase)
-- 		self.node_list["TxtBtn"]:SetActive(true)
-- 		UI:SetButtonEnabled(self.node_list["Btn"], true) 
-- 		return
-- 	end

-- 	local function timer_func(elapse_time, total_time)
-- 		if self.root_node == nil or IsNil(self.root_node.gameObject) then
-- 			self:StopCountDown()
-- 			return
-- 		end
-- 		if elapse_time >= total_time then
-- 			self:StopCountDown()
-- 			self.node_list["Txt1"]:SetActive(false)
-- 		self.node_list["TxtBtn"]:SetActive(true)
		
-- 		UI:SetButtonEnabled(self.node_list["Btn"], true) 
-- 			return
-- 		end
-- 		local time = math.ceil(total_time - elapse_time)
-- 		self.node_list["Txt1"].text.text = string.format(Language.Marriage.ResidueTime, time)		
-- 		self.node_list["Txt1"]:SetActive(true)
-- 		self.node_list["TxtBtn"]:SetActive(false)
-- 		UI:SetButtonEnabled(self.node_list["Btn"], false) 
-- 	end

-- 	local left_time = math.ceil(end_cd_time - server_time)
-- 	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
-- 	self.node_list["Txt1"].text.text = string.format(Language.Marriage.ResidueTime, left_time)
-- 	self.node_list["Txt1"]:SetActive(true)
-- 	self.node_list["TxtBtn"]:SetActive(false)
	
-- 	UI:SetButtonEnabled(self.node_list["Btn"], false) 
-- end

-- --停止倒计时
-- function MonomerItemCell:StopCountDown()
-- 	if self.count_down then
-- 		CountDown.Instance:RemoveCountDown(self.count_down)
-- 		self.count_down = nil
-- 	end
-- end

-- function MonomerItemCell:ClickHead()
-- 	local main_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	if self.data.uid == main_vo.role_id then
-- 		return
-- 	end
-- 	local open_type = ScoietyData.DetailType.Default
-- 	ScoietyCtrl.Instance:ShowOperateList(open_type, self.data.name)
-- end
