require("game/marriage/equip/marry_equip_ctrl")
require("game/marriage/marriage_data")
require("game/marriage/marriage_view")
-- require("game/marriage/church_view")
require("game/marriage/wedding_view")
require("game/marriage/wedding_by_view")
require("game/marriage/wedding_hunshu_view")
require("game/marriage/wedding_fuben_view")
require("game/marriage/wedding_enter_view")
-- require("game/marriage/wedding_invite_view")
require("game/marriage/qingyuan_fuben_view")
require("game/marriage/couple_halo")
require("game/marriage/monomer_view")
require("game/marriage/shengdi/shengdi_fuben_view")
require("game/marriage/wedding_yuyue_view")
require("game/marriage/wedding_invite_view")
require("game/marriage/marriage_wedding_view")
require("game/marriage/wedding_demand_view")
require("game/marriage/wedding_bless_view")
require("game/marriage/marriage_xunyou_view")
require("game/marriage/marriage_npc_view")
require("game/marriage/european_wedding_view")
require("game/marriage/marriage_friend_view")
require("game/marriage/marriage_baitang_tips")
require("game/marriage/european_wedding_tips")
require("game/marriage/wedding_tip_one")
require("game/marriage/wedding_tip_two")
require("game/marriage/wedding_tip_three")
require("game/marriage/marriage_halo_buy_view")
require("game/marriage/offsheet_speak_view")

MarriageCtrl = MarriageCtrl or  BaseClass(BaseController)

function MarriageCtrl:__init()
	if MarriageCtrl.Instance ~= nil then
		print_error("[MarriageCtrl] attempt to create singleton twice!")
		return
	end

	MarriageCtrl.Instance = self

	self.is_move_xuyou = false
	self.marry_equip_ctrl = MarryEquipCtrl.New()

	self:RegisterAllProtocols()
	self.marriage_view = MarriageView.New(ViewName.Marriage)
	self.wedding_view = WeddingView.New(ViewName.Wedding)
	self.wedding_by_view = WeddingByView.New()
	self.wedding_fuben_view = WeddingFuBenView.New(ViewName.FuBenHunYanInfoView)
	self.wedding_hunshu_view = WeddingHunShuView.New(ViewName.WeddingHunShuView)
	self.qingyuan_fuben_view = QingYuanFuBenView.New(ViewName.FuBenQingYuanInfoView)
	self.shengdi_fuben_view = ShengDiFuBenView.New(ViewName.FuBenShengDiInfoView)
	self.wedding_yuyue_view = WeddingYuYueView.New(ViewName.WeddingYuYueView)
	self.wedding_invite_view = WeddingInviteView.New(ViewName.WeddingInviteView)
	self.wedding_demand_view = WeddingDeMandView.New(ViewName.WeddingDeMandView)
	self.wedding_tip_one = WeddingTipsOne.New(ViewName.WeddingTipsOne)
	self.wedding_tips_two = WeddingTipsTwoView.New(ViewName.WeddingTipsTwo)
	self.wedding_tips_three = WeddingTipsThree.New(ViewName.WeddingTipsThree)
	self.wedding_blessing_view = WeddingBlessingView.New(ViewName.WeddingBlessView)
	self.marriage_wedding_view = MarriageWeddingView.New(ViewName.MarriageWedding)
	self.marriage_data = MarriageData.New()
	self.enter_wedding_view = WeddingEnterView.New(ViewName.WeddingEnterView)
	self.monomer_view = MonomerView.New()
	self.xunyou_view = XunYouView.New()
	self.npc_view = MarryNpcView.New(ViewName.MarryNpcMe)
	self.friend_list_view = MarryFriendListView.New()
	self.common_tips = BaitangView.New()
	self.european_wedding_tips = EuropeanWeddingTips.New(ViewName.EuropeanWeddingTips)
	self.off_sheet_speakview = OffSheetSpeakView.New(ViewName.OffSheetSpeakView)
	
	self.european_wedding_view = EuropeanWeddingView.New(ViewName.EuropeanWeddingView)
	self.marriage_halo_buy_view = MarriageHaloBuyView.New(ViewName.MarriageHaloBuyView)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))

	self.activity_call_back = BindTool.Bind(self.ActivityChangeCallback, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function MarriageCtrl:__delete()
	if self.marry_equip_ctrl then
		self.marry_equip_ctrl:DeleteMe()
		self.marry_equip_ctrl = nil
	end
	if self.marriage_view then
		self.marriage_view:DeleteMe()
		self.marriage_view = nil
	end
	if self.ring_content_view then
		self.ring_content_view:DeleteMe()
		self.ring_content_view = nil
	end

	if self.xunyou_view then
		self.xunyou_view:DeleteMe()
		self.xunyou_view = nil
	end

	if self.npc_view then
		self.npc_view:DeleteMe()
		self.npc_view = nil
	end

	if self.wedding_tip_one then
		self.wedding_tip_one:DeleteMe()
		self.wedding_tip_one = nil
	end

	if self.wedding_tips_two then
		self.wedding_tips_two:DeleteMe()
		self.wedding_tips_two = nil
	end

	if self.wedding_tips_three then
		self.wedding_tips_three:DeleteMe()
		self.wedding_tips_three = nil
	end

	if self.wedding_view then
		self.wedding_view:DeleteMe()
		self.wedding_view = nil
	end

	if self.wedding_by_view then
		self.wedding_by_view:DeleteMe()
		self.wedding_by_view = nil
	end

	if self.marriage_halo_buy_view then
		self.marriage_halo_buy_view:DeleteMe()
		self.marriage_halo_buy_view = nil
	end

	if self.wedding_fuben_view then
		self.wedding_fuben_view:DeleteMe()
		self.wedding_fuben_view = nil
	end

	if self.wedding_hunshu_view then
		self.wedding_hunshu_view:DeleteMe()
		self.wedding_hunshu_view = nil
	end

	if self.wedding_yuyue_view then
		self.wedding_yuyue_view:DeleteMe()
		self.wedding_yuyue_view = nil
	end

	if self.wedding_invite_view then
		self.wedding_invite_view:DeleteMe()
		self.wedding_invite_view = nil
	end
	if self.wedding_demand_view then
		self.wedding_demand_view:DeleteMe()
		self.wedding_demand_view = nil
	end

	if self.qingyuan_fuben_view then
		self.qingyuan_fuben_view:DeleteMe()
		self.qingyuan_fuben_view = nil
	end

	if self.shengdi_fuben_view then
		self.shengdi_fuben_view:DeleteMe()
		self.shengdi_fuben_view = nil
	end

	if self.marriage_data then
		self.marriage_data:DeleteMe()
		self.marriage_data = nil
	end

	if self.enter_wedding_view then
		self.enter_wedding_view:DeleteMe()
		self.enter_wedding_view = nil
	end

	if self.monomer_view then
		self.monomer_view:DeleteMe()
		self.monomer_view = nil
	end

	if self.scene_all_load then
		GlobalEventSystem:UnBind(self.scene_all_load)
		self.scene_all_load = nil
	end

	if self.off_sheet_speakview then
		self.off_sheet_speakview:DeleteMe()
		self.off_sheet_speakview = nil
	end
	
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	MarriageCtrl.Instance = nil
end

function MarriageCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMarryReqRoute, "OnMarryReqRoute")
	self:RegisterProtocol(SCDivorceReqRoute, "OnDivorceReqRoute")
	self:RegisterProtocol(SCQingyuanBlessInfo, "SyncBlessInfo")
	self:RegisterProtocol(SCQingyuanEuipmentInfo, "SyncRingInfo")
	self:RegisterProtocol(SCQingyuanLoverInfo, "OnQingyuanLoverInfo")
	self:RegisterProtocol(SCHunyanInfo, "OnWeddingInfo")
	self:RegisterProtocol(SCMarryHunyanOpera, "OnMarryHunyanOpera")
	self:RegisterProtocol(SCQingyuanHunyanInviteInfo, "OnGetWeddingInvite")
	self:RegisterProtocol(SCQingyuanFBInfo, "OnQingYuanFBInfo")
	self:RegisterProtocol(SCQingyuanInfo, "OnQingyuanInfo")
	self:RegisterProtocol(SCQingyuanCoupleHaloInfo, "OnHaloInfo")
	self:RegisterProtocol(SCIsAcceptMarry, "OnAcceptMarry")
	self:RegisterProtocol(SCQingyuanFBRewardRecordInfo, "OnQingyuanFBRewardRecordInfo")
	-- self:RegisterProtocol(SCMarryInfo, "OnMarryInfo")
	self:RegisterProtocol(SCQingyuanCoupleHaloTrigger, "OnQingyuanCoupleHaloTrigger")		--夫妻光环
	-----------------相思树-------------------------
	self:RegisterProtocol(CSLoveTreeWaterReq)
	self:RegisterProtocol(CSLoveTreeInfoReq)
	self:RegisterProtocol(SCLoveTreeInfo, "OnLoveTreeInfo")

	---------------我要脱单-----------------------
	self:RegisterProtocol(CSTuodanREQ)
	self:RegisterProtocol(CSGetAllTuodanInfo)												--请求全部脱单信息
	self:RegisterProtocol(SCAllTuodanInfo, "OnAllTuodanInfo")
	self:RegisterProtocol(SCSingleTuodanInfo, "OnSingleTuodanInfo")

	--------------情缘装备------------------------
	self:RegisterProtocol(CSQingyuanUpQuality)												-- 情缘装备进阶
	self:RegisterProtocol(CSQingyuanEquipInfo)												-- 情缘装备信息请求

	-------------爱情契约------------------------
	-- self:RegisterProtocol(CSQingyuanLoveContractInfoReq)									-- 请求爱情契约的信息
	self:RegisterProtocol(CSQingyuanBuyLoveContract)										-- 爱情契约请求为Ta祝福
	self:RegisterProtocol(CSQingyuanFetchLoveContract)										-- 爱情契约领取奖励
	self:RegisterProtocol(SCQingyuanLoveContractInfo, "OnQingyuanLoveContractInfo")			-- 爱情契约信息
	---------------------情缘圣地------------------
	self:RegisterProtocol(CSQingYuanShengDiOperaReq)										-- 情缘圣地操作请求
	self:RegisterProtocol(SCQingYuanShengDiTaskInfo, "OnQingYuanShengDiTaskInfo")			-- 情缘圣地任务信息
	self:RegisterProtocol(SCQingYuanShengDiBossInfo, "OnQingYuanShengDiBossInfo")			-- 情缘圣地boss信息

	self:RegisterProtocol(CSSkipReq)														-- 一键完成请求

	-------------摁手印------------------------
	self:RegisterProtocol(SCMarryRetInfo, "OnMarryRetInfo")									-- 请求结婚操作 
-------------------婚宴-------------------
	self:RegisterProtocol(SCQingYuanAllInfo, "OnSCQingYuanAllInfo")							-- 情缘婚礼信息
	self:RegisterProtocol(SCWeddingRoleInfo, "OnSCWeddingRoleInfo")							-- 婚礼玩家个人信息
	self:RegisterProtocol(SCQingYuanWeddingAllInfo, "OnSCQingYuanWeddingAllInfo")			-- 情缘婚宴预约信息返回
	self:RegisterProtocol(SCHunYanCurWeddingAllInfo, "OnSCHunYanCurWeddingAllInfo")			-- 当前婚宴场景信息请求返回
	self:RegisterProtocol(SCWeddingApplicantInfo, "OnSCWeddingApplicantInfo")				-- 申请者信息
	self:RegisterProtocol(SCWeddingBlessingRecordInfo, "OnSCWeddingBlessingRecordInfo")		-- 祝福
	self:RegisterProtocol(SCMarrySpecialEffect, "OnMarrySpecialEffect")						-- 婚礼特效
	self:RegisterProtocol(SCSpecialParamChange, "OnSCSpecialParamChange")					-- 巡游状态变更

		---------------------婚礼购买---------------------
	self:RegisterProtocol(CSQingYuanBuyWeddingGiftBagReq)
end

------------------------------------------------------------------------------


function MarriageCtrl:ActivityChangeCallback(activity_type, status, next_status_switch_time, open_type)
	-- 随机活动夫妻光环特购
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRIAGEHALOBUY and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRIAGEHALOBUY, 0)
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING, 0)
		if self.marriage_view and self.marriage_view:IsOpen() then
			self.marriage_view:Flush("tuodan")
		end		
		if self.wedding_view and self.wedding_view:IsOpen() then
			self.wedding_view:Flush()
		end
		if self.european_wedding_view and self.european_wedding_view:IsOpen() then
			self.european_wedding_view:Flush()
		end
		RemindManager.Instance:Fire(RemindName.MarryRing)
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEST_WEDDING and status == ACTIVITY_STATUS.CLOSE then
		if self.marriage_view and self.marriage_view:IsOpen() then
			self.marriage_view:Flush("tuodan")
		end		
		if self.wedding_view and self.wedding_view:IsOpen() then
			self.wedding_view:Flush()
		end
		if self.european_wedding_view and self.european_wedding_view:IsOpen() then
			self.european_wedding_view:Flush()
		end
		RemindManager.Instance:Fire(RemindName.MarryRing)		
	end 

	--婚宴剩余时间
	if activity_type ~= ACTIVITY_TYPE.WEDDING then
		return
	end

	self.marriage_data:SetActiveState(status)

	if status == HUNYAN_STATUS.OPEN then
		self.marriage_data:SetHunYanTime(next_status_switch_time)
		self.marriage_data:SetIsShowBubble(true)
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, true)
	end

	if status ~= HUNYAN_STATUS.CLOSE then
		self:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_WEDDING_INFO)

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo and main_role_vo.level >= WEDDING_ACTIVITY_LEVEL then
			if status ~= HUNYAN_STATUS.STANDY then
				-- MarriageCtrl.Instance:OpenDemandView()
			end
		end
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, true)
	else
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, false)
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.MarryInvite, false)
		local demandview = self:GetDemandView()
		if demandview:IsOpen() then
			demandview:Close()
		end
	end

	if status == HUNYAN_STATUS.XUNYOU then
		self.marriage_data:SetIsShowBubble(true)
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, true)

		local flag = PlayerData.Instance:GetRoleVo().sex == 0 and 3 or 2
		self:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_OBJ_POS, flag)
	else
		self:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_ROLE_INFO)
	end
end

function MarriageCtrl:SendQingyuanBuyLoveContract(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanBuyLoveContract)
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

function MarriageCtrl:SendQingyuanFetchLoveContract(opera_type, day_num, love_contract_notice)	--opera_type = 0 领取奖励， opera_type = 1 留言
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanFetchLoveContract)
	protocol.opera_type = opera_type
	protocol.day_num = day_num
	protocol.love_contract_notice = love_contract_notice
	protocol:EncodeAndSend()
end

function MarriageCtrl:OnQingyuanLoveContractInfo(protocol)
	self.marriage_data:SetQingyuanLoveContractInfo(protocol)
	RemindManager.Instance:Fire(RemindName.MarryLoveContent)
	self.marriage_view:Flush("love_contract")

	if self.marriage_data:GetQingyuanLoveContractReward() > 0 then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.LOVE_CONTENT, true)
	else
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.LOVE_CONTENT, false)
	end
end

function MarriageCtrl:FlushMainViewBubble(is_show)
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, is_show)
end

function MarriageCtrl:ShowCommonTip(func, data, content , cancle_data, no_func, is_show_no_tip, is_show_time, prefs_key, is_recycle, recycle_text, auto_text_desc, hide_cancel, boss_id, no_auto_click_yes, no_button_text, cal_time, auto_click_no, is_no_tip_toggle, close_unequal_no_fun)
	if SettingData.Instance:GetCommonTipkey(prefs_key) then
		if data then
			func(data)
		else
			func()
		end
		return
	end
	self.common_tips:SetOKCallback(func)
	self.common_tips:SetNoCallback(no_func)
	self.common_tips:SetData(data, cancle_data, is_show_no_tip, is_show_time, prefs_key, is_recycle, recycle_text, auto_text_desc,hide_cancel, boss_id, no_auto_click_yes, no_button_text, cal_time, auto_click_no, is_no_tip_toggle, close_unequal_no_fun)
	self.common_tips:SetContent(content)
	self.common_tips:Open()
end

------------------------------------------------------------------------------

function MarriageCtrl:SendQingYuanEquipInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanEquipInfo)
	protocol:EncodeAndSend()
end

function MarriageCtrl:OnLoveTreeInfo(protocol)
	self.marriage_data:SetLoveTreeInfo(protocol)
	self:UpDataLoverTreeRedPoint()
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("love_tree")
	end
end

--请求相思树信息
function MarriageCtrl:SendLoveTreeInfoReq(is_self)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLoveTreeInfoReq)
	send_protocol.is_self = is_self or 0
	send_protocol:EncodeAndSend()
end

--情缘操作请求
function MarriageCtrl:SendQingYuanOperate(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingYuanOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

--sex为只显示什么性别的好友
function MarriageCtrl:ShowFriendListView(callback, sex)
	self.friend_list_view:SetCallBack(callback)
	self.friend_list_view:SetSex(sex)
	self.friend_list_view:Open()
end

--情缘操作返回信息
function MarriageCtrl:OnSCQingYuanAllInfo(protocol)
	if protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_ROLE_INFO then  -- 玩家信息
		self.marriage_data:SetYuYueRoleInfo(protocol)
		self.wedding_yuyue_view:Flush()
		
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_WEDDING_YUYUE_FLAG then
		self.marriage_data:SetYuYueListInfo(protocol)
		if self.wedding_yuyue_view:IsOpen() then
			self.wedding_yuyue_view:Flush("my_yuyue")
				-- ViewManager.Instance:Open(ViewName.WeddingInviteView)
		end
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_YUYUE_RET then 			--对方婚礼预约请求
		self:OpenYuYueTips(protocol.param_ch1)
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_YUYUE_SUCC then 			--预约成功才打开邀请
		self:OpenInviteView()
		if self.wedding_yuyue_view:IsOpen() then
			self.wedding_yuyue_view:Close()
		end
		if self.marriage_view:IsOpen() then
			self.marriage_view:Flush("wedding")
		end
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_BAITANG_RET then --拜堂
		local lover_name = GameVoManager.Instance:GetMainRoleVo().lover_name or ""
		if protocol.param_ch1 == 1 then
			self:ShowCommonTip(nil, nil, string.format(Language.Marriage.BaiTangTip1, lover_name))
		else
			local ok_fun = function ()
				MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNUAN_OPERA_TYPE_BAITANG_RET, 1)
			end
			local cancel_fun = function ()
				MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNUAN_OPERA_TYPE_BAITANG_RET, 0)
			end
			self:ShowCommonTip(ok_fun, nil, string.format(Language.Marriage.BaiTangTip2, lover_name), nil, cancel_fun)
		end
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_WEDDING_BEGIN_NOTICE then 		--婚宴开启通知
		if not OpenFunData.Instance:CheckIsHide("marriage_wedding_demand") then
			return
		end

		-- ViewManager.Instance:Open(ViewName.WeddingDeMandView)

	-- elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_WEDDING_STANDBY then 			-- 婚礼准备
	-- 	print_error("开始")
	-- 	ViewManager.Instance:Open(ViewName.WeddingDeMandView)
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_GET_BLESSING then 		--收到祝福返回
		--特效
	-- elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_HAVE_APPLICANT then
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_XUNYOU_INFO then			--巡游信息面板
		if not self.marriage_data:IsMarryUser() then return end
		
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING)
		local main_obj = Scene.Instance:GetMainRole()
		local lover_obj = Scene.Instance:GetObjByUId(main_obj.vo.lover_uid)
		if activity_info.status ~= HUNYAN_STATUS.XUNYOU then
			self.xunyou_view:Close()
			main_obj:SetMarryFlag(0)
			if lover_obj then
				lover_obj:SetMarryFlag(0)
			end
			return
		end
		self.marriage_data:SetXunYouInfo(protocol)
		local scene = Scene.Instance:GetSceneType()
		local fun_calk = function ()
			local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING)
			local main_obj = Scene.Instance:GetMainRole()
			local lover_obj = Scene.Instance:GetObjByUId(main_obj.vo.lover_uid)
			if activity_info.status == HUNYAN_STATUS.XUNYOU then
				if self.xunyou_view:IsOpen() then
					self.xunyou_view:Flush()
				else
					self.xunyou_view:Open()
				end
				main_obj:SetMarryFlag(1)
				if lover_obj then
					lover_obj:SetMarryFlag(1)
				end
			end
			if self.scene_all_load then
				GlobalEventSystem:UnBind(self.scene_all_load)
				self.scene_all_load = nil
			end
		end
		if SceneType.Common ~= scene then
			self.scene_all_load = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind(fun_calk, self))
		else
			fun_calk()
		end
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_XUNYOU_OBJ_POS then
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING)
		self.marriage_data:SetXunYouPos(protocol)
		if self.is_move_xuyou then
			self.is_move_xuyou = false
			local marry_info = self.marriage_data:GetXunYouPos()
			if marry_info then
				MoveCache.end_type = MoveEndType.Normal
				local SceneKey = 0 --这里默认去1线
				GuajiCtrl.Instance:StopGuaji()
				GuajiCtrl.Instance:MoveToPos(marry_info.scene_id, marry_info.x, marry_info.y, 1, 1, false, SceneKey)
			end
		end
		if activity_info.status == HUNYAN_STATUS.XUNYOU and self.marriage_data:IsMarryUser() then
			MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_ROLE_INFO)
		end
	end
end

--设置是否传送去巡游队伍
function MarriageCtrl:SetMoveXuyou(bool)
	self.is_move_xuyou = bool
end

function MarriageCtrl:OpenYuYueTips(seq)
	local yuyue_tips_cfg = self.marriage_data:GetYuYueTime(seq)

	local begin1 = math.floor(yuyue_tips_cfg.apply_time / 100)
	local begin2 = yuyue_tips_cfg.apply_time % 100
	local end1 = math.floor(yuyue_tips_cfg.end_time / 100)
	local end2 = yuyue_tips_cfg.end_time % 100
	local time = string.format("%02d:%02d - %02d:%02d", begin1, begin2, end1, end2)

	local str = string.format(Language.Marriage.YuYueConf, time)

	local function ok_callback()
		MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_RESULT, seq, 1)
	end
	local function close_callback()
		MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_RESULT, seq, 0)
	end

	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, close_callback, false, Language.Guild.TONGYI, Language.Guild.JUJUE, nil, true, nil, close_callback)
end

--请求浇水
function MarriageCtrl:SendLoveTreeWaterReq(is_auto_buy, is_water_other)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLoveTreeWaterReq)
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.is_water_other = is_water_other or 0
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:OnAllTuodanInfo(protocol)
	self.marriage_data:SetAllTuoDanList(protocol)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("tuodan")
	end
	if self.off_sheet_speakview:IsOpen() then
		self.off_sheet_speakview:Flush()
	end
end

function MarriageCtrl:OnSingleTuodanInfo(protocol)
	self.marriage_data:ChangeTuoDanList(protocol)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("tuodan")
	end
	if self.off_sheet_speakview:IsOpen() then
		self.off_sheet_speakview:Flush()
	end
end

function MarriageCtrl:SendTuodanReq(req_type, notice)
	--删除我自己
	if req_type == 1 then
		self.marriage_data:RemoveTuoDanInfoMySelf()
		if self.marriage_view:IsOpen() then
			self.marriage_view:Flush("tuodan")
		end
		if self.off_sheet_speakview:IsOpen() then
			self.off_sheet_speakview:Flush()
		end
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTuodanREQ)
	send_protocol.req_type = req_type or 0
	send_protocol.notice = notice or ""
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:GetAllTuodanInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetAllTuodanInfo)
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:ShowMonomerView()
	self.monomer_view:Open()
end


function MarriageCtrl:OpenDemandView()
	if not OpenFunData.Instance:CheckIsHide("marriage_wedding_demand") then
		return
	end

	self.wedding_demand_view:Open()
end

function MarriageCtrl:OpenInviteView()
	self.wedding_invite_view:Open()
end

function MarriageCtrl:GetDemandView()
	return self.wedding_demand_view
end

--关闭所有与结婚有关的View
function MarriageCtrl:CloseAllView()
	self.marriage_view:Close()
	self.enter_wedding_view:Close()
end

-----------------光环------------------------------
function MarriageCtrl:OnHaloInfo(protocol)
	self.marriage_data:SetEquipCoupleHaloType(protocol.equiped_couple_halo_type)
	self.marriage_data:SetCoupleHaloLevelList(protocol.couple_halo_level_list)
	self.marriage_data:SetCoupleHaloExpList(protocol.couple_halo_exp_list)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("halo")
	end
	RemindManager.Instance:Fire(RemindName.MarryCoupHalo)

	self.marriage_data:SetIsHasBuyTeJiaHalo(protocol.is_today_buy_tejia_halo)
	self.marriage_data:SetHaloBuyInvalidTime(protocol.tejie_halo_invalid_time)
	if self.marriage_halo_buy_view:IsOpen() then
		self.marriage_halo_buy_view:Flush()
	end
end

function MarriageCtrl:FlushHaloInfo()
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("halo")
	end
end

function MarriageCtrl:FlushEquipInfo()
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("equip")
	end
end

function MarriageCtrl:SendUpgradeSpirit(req_type ,halo_type, spirit_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanCoupleHaloOperaReq)
	send_protocol.req_type = req_type
	send_protocol.param_1 = halo_type
	send_protocol.param_2 = spirit_index or 0
	send_protocol.param_3 = 0
	send_protocol:EncodeAndSend()

end

-----------------结婚/离婚------------------------------

--接收结婚请求
function MarriageCtrl:OnMarryReqRoute(protocol)
	self.marriage_data:SetReqWeddingInfo(protocol)
	if self.wedding_by_view:IsOpen() then
		self.wedding_by_view:Flush()
	else
		self.wedding_by_view:Open()
	end
end

--发送结婚回复
function MarriageCtrl:SendMarryRet(marry_type, is_accept, req_uid)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryRet)
	send_protocol.marry_type = marry_type or 0
	send_protocol.req_uid = req_uid or 0
	send_protocol.is_accept = is_accept or 0
	send_protocol:EncodeAndSend()
end

--发送离婚请求
function MarriageCtrl:SendDivorceReq(is_forced_divorce)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanDivorceReqCS)
	send_protocol.is_forced_divorce = is_forced_divorce
	send_protocol:EncodeAndSend()
end

--接收离婚请求
function MarriageCtrl:OnDivorceReqRoute(protocol)
	self.req_uid = protocol.req_uid
	self:ShowDivorceOrNotTips()
end

--发送离婚回复
function MarriageCtrl:SendDivorceRet(is_accept)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDivorceRet)
	send_protocol.is_accept = is_accept
	send_protocol.req_uid = self.req_uid
	send_protocol:EncodeAndSend()
end

--返回对方是否同意结婚请求    1:同意, 0:不同意
function MarriageCtrl:OnAcceptMarry(protocol)
	if protocol.accept_flag == 1 then
		if self.wedding_view:IsOpen() then
			self.wedding_view:Close()
		end
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.AgreeMarryDes)
		self.wedding_hunshu_view:Open()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.DisAgreeMarryDes)
	end
end

--情缘副本结算
function MarriageCtrl:OnQingyuanFBRewardRecordInfo(protocol)
	self.marriage_data:SetQingYuanFBRewardInfo(protocol)
end

function MarriageCtrl:UpDataLoverTreeRedPoint()
	--刷新相思树红点
	self.marriage_data:SetLoveTreeRedPoint()
end

function MarriageCtrl:OnMarryInfo(protocol)
	self.marriage_data:SetPutongHunyanTimes(protocol.today_putong_hunyan_times)
	self.marriage_data:SetTodayOpenHunYanTimes(protocol.today_total_open_hunyan_times)
	self.marriage_data:SetCanOpen(protocol.can_open)
	self.marriage_data:SetCanHasMarryHunli(protocol.has_marry_hunli_type_flag)
	RemindManager.Instance:Fire(RemindName.MarryParty)
end

-----------------蜜月------------------------------
--同步祝福信息
function MarriageCtrl:SyncBlessInfo(protocol)
	self.marriage_data:SyncBlessInfo(protocol)
	self.marriage_view:BlessChange()
end

--同步戒指信息
function MarriageCtrl:SyncRingInfo(protocol)
	self.marriage_data:SyncRingInfo(protocol)
	self.marriage_view:RingChange()
	RemindManager.Instance:Fire(RemindName.MarryRing)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("ring")
	end
end

--同步伴侣信息
function MarriageCtrl:OnQingyuanLoverInfo(protocol)
	self.marriage_data:OnQingyuanLoverInfo(protocol)
	self.marriage_view:RingChange()
	RemindManager.Instance:Fire(RemindName.MarryRing)
end

--结婚状态改变
function MarriageCtrl:MarryStateChange()
	RemindManager.Instance:Fire(RemindName.MarryRing)
	RemindManager.Instance:Fire(RemindName.MarryLoveContent)
	RemindManager.Instance:Fire(RemindName.MarryParty)
	RemindManager.Instance:Fire(RemindName.MarryFuBen)
	
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("lover_change")
	end
	ViewManager.Instance:FlushView(ViewName.Main, "recharge") -- 结婚后要隐藏我们结婚吧的活动按钮
end

--升级戒指
function MarriageCtrl:SendUpgradeRing(use_num, is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanUpLevel)
	send_protocol.stuff_id = self.marriage_data:GetRingUpgradeItem().stuff_id
	send_protocol.repeat_tiems = use_num or 1
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol:EncodeAndSend()
end

--发送领取祝福奖励
function MarriageCtrl:SendGetBlessReward()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanFetchBlessRewardReq)
	send_protocol:EncodeAndSend()
end



--发送购买祝福
function MarriageCtrl:SendBuyBless()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanAddBlessDaysReq)
	send_protocol:EncodeAndSend()
end
-----------------宴会副本--------------------------
--宴会副本信息
function MarriageCtrl:OnWeddingInfo(protocol)
	self.marriage_data:OnWeddingInfo(protocol)
	MainUICtrl.Instance:FlushView("wedding")
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush()
	end
end

function MarriageCtrl:OnMarryHunyanOpera(protocol)
	if protocol.opera_type == GameEnum.HUNYAN_OPERA_TYPE_SAXIANHUA then					--撒鲜花
		if self.wedding_fuben_view:IsOpen() then
			self.wedding_fuben_view:Flush("sahua")
		end
	end
end

--宴会行动 邀请、撒花、扔花球
function MarriageCtrl:SendMarryOpera(opera_type, opera_param, id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryHunyanOpera)
	send_protocol.opera_type = opera_type or 0
	send_protocol.opera_param = opera_param or 0
	send_protocol.invited_uid = id or 0
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:SendMarryBless()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryHunyanBless)
	send_protocol:EncodeAndSend()
end

--宴会邀请函改变
function MarriageCtrl:OnGetWeddingInvite(protocol)
	self.marriage_data:SetGetInviteData(protocol)
	if self.enter_wedding_view:IsOpen() then
		self.enter_wedding_view:Flush()
	end

	-- if next(protocol.invite_list) then
	-- 	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, true)
	-- else
	-- 	if self.enter_wedding_view:IsOpen() then
	-- 		self.enter_wedding_view:Close()
	-- 	end
	-- 	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, false)
	-- end
end

function MarriageCtrl:OpenMarriageTipView(index)
	if nil == index then return end
	for k,v in pairs(MARRIAGE_SELECT_TYPE) do
		if v.index == index then
			ViewManager.Instance:Open(v.name)
			return
		end
	end
end

-----------------情缘副本--------------------------
--接受情缘副本信息
function MarriageCtrl:OnQingYuanFBInfo(protocol)
	self.marriage_data:SetQingYuanFB(protocol)
	self.qingyuan_fuben_view:SetData(protocol)
end

--申请情缘副本基本信息
function MarriageCtrl:SendQingYuanFBInfoReq(opera_type, param_1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanFBOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0 
	send_protocol:EncodeAndSend()
end

--接受情缘副本进入信息
function MarriageCtrl:OnQingyuanInfo(protocol)
	self.marriage_data:SetQingYuanFBInfo(protocol)
	self.marriage_view:OnFuBenChange()
	RemindManager.Instance:Fire(RemindName.MarryFuBen)
end

function MarriageCtrl:MainuiOpen()
	self:SendQingYuanEquipInfo()
	self:GetAllTuodanInfo()
	self:SendQingyuanBuyLoveContract(LOVE_CONTRACT_REQ_TYPE.LC_REQ_TYPE_INFO)
	self:SendQingYuanFBInfoReq(QINGYUAN_FB_OPERA_TYPE.QINGYUAN_FB_OPERA_TYPE_BASE_INFO)
	self:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_GET_ROLE_INFO)
	RemindManager.Instance:Fire(RemindName.MarryRing)
end

function MarriageCtrl:ItemDataChange(item_id, change_item_index, change_reason)
	local is_lover_tree_item = self.marriage_data:IsLoverTreeItemById(item_id)
	if is_lover_tree_item then
		self:UpDataLoverTreeRedPoint()
		if self.marriage_view:IsOpen() then
			self.marriage_view:Flush("love_tree")
		end
	end
end

--附近有夫妻光环出现
function MarriageCtrl:OnQingyuanCoupleHaloTrigger(protocol)
	local role_obj_1 = Scene.Instance:GetObjByUId(protocol.role1_uid)
	if role_obj_1 then
		local halo_type = protocol.halo_type
		local halo_lover_uid = protocol.role2_uid
		if protocol.halo_type < 0 then
			halo_type = 0
			halo_lover_uid = 0
		end
		role_obj_1:SetAttr("halo_type", halo_type)
		role_obj_1:SetAttr("halo_lover_uid", halo_lover_uid)
	end

	local role_obj_2 = Scene.Instance:GetObjByUId(protocol.role2_uid)
	if role_obj_2 then
		local halo_type = protocol.halo_type
		local halo_lover_uid = protocol.role1_uid
		if protocol.halo_type < 0 then
			halo_type = 0
			halo_lover_uid = 0
		end
		role_obj_2:SetAttr("halo_type", halo_type)
		role_obj_2:SetAttr("halo_lover_uid", halo_lover_uid)
	end
end

-----------------Tips提示板--------------------------
--是否结婚提示板
function MarriageCtrl:ShowMarryOrNotTips(name)
	local player_name = name
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local gender_str = Language.Marriage.MarryQuestionFeMale
	if main_role_vo.sex == 1 then
		gender_str = Language.Marriage.MarryQuestionMale
	end
	local str = string.format(gender_str, ToColorStr(player_name, TEXT_COLOR.BLUE))
	local yes_func = BindTool.Bind(self.SendMarryRet, self, 1)
	local no_func = BindTool.Bind(self.SendMarryRet, self, 0)
	TipsCtrl.Instance:ShowCommonAutoView("", str, yes_func, no_func, nil, Language.Common.Willing, Language.Common.Jujue)
end

--是否离婚提示板
function MarriageCtrl:ShowDivorceOrNotTips()
	local yes_func = BindTool.Bind(self.SendDivorceRet, self, 1)
	local no_func = BindTool.Bind(self.SendDivorceRet, self, 0)
	TipsCtrl.Instance:ShowCommonAutoView("", Language.Marriage.DivorceQuestion, yes_func, no_func, nil, Language.Common.Agree, Language.Common.Jujue)
end

--是否购买祝福提示板-伴侣有买时
function MarriageCtrl:ShowBuyBlessTips()
	local yes_func = BindTool.Bind(self.SendBuyBless, self)
	local bless_cfg = self.marriage_data:GetBlessCfg()
	local bless_name = ToColorStr(bless_cfg.bless_name, TEXT_COLOR.BLUE)

	local str = ""

	local lover_bless_days = self.marriage_data:GetLoverBlessDays()
	if lover_bless_days ~= nil and lover_bless_days > 0 then
		local self_bless_days = self.marriage_data:GetSelfBlessDays()
		local cost = 1 / 2 * bless_cfg.bless_price_gold / 30 * (math.abs(lover_bless_days - self_bless_days))
		str = string.format(Language.Marriage.BuyBlessLoverHaveBless, bless_name, ToColorStr(cost, TEXT_COLOR.GOLD))
	else
		str = string.format(Language.Marriage.BuyBlessLoverNoBless, ToColorStr(bless_cfg.bless_price_gold, TEXT_COLOR.GOLD), bless_name)
	end

	TipsCtrl.Instance:ShowCommonAutoView("", str, yes_func)
end

---------------------------情缘圣地------------------------------
function MarriageCtrl:SendQingYuanShengDiOperaReq(task_type,param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingYuanShengDiOperaReq)
	send_protocol.opera_type = task_type or 0
	send_protocol.param = param or 0
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:OnQingYuanShengDiTaskInfo(protocol)
	self.marriage_data:SetQingYuanShengDiTaskInfo(protocol)
	RemindManager.Instance:Fire(RemindName.MarryShengDi)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("Shendi")
	end
	if self.shengdi_fuben_view:IsOpen() then
		GlobalEventSystem:Fire(OtherEventType.SHENGDI_FUBEN_INFO_CHANGE)
		self.shengdi_fuben_view:Flush("team_type")
	end
end

function MarriageCtrl:OnQingYuanShengDiBossInfo(protocol)
	self.marriage_data:SetQingYuanShengDiBossInfo(protocol)
	if self.shengdi_fuben_view:IsOpen() then
		self.shengdi_fuben_view:Flush()
	end
end

--一键完成
function MarriageCtrl:SendCSSkipReq(type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSkipReq)
	protocol.type = type
	protocol.param = param or -1
	protocol:EncodeAndSend()
end

----------------摁手印------------------------------
function MarriageCtrl:SendMarryReq(ope_type ,marry_type, target_uid)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryReq)
	send_protocol.ope_type = ope_type or 0
	send_protocol.marry_type = marry_type or 0
	send_protocol.target_uid = target_uid or 0
	send_protocol:EncodeAndSend()
	if ope_type == MARRY_REQ_TYPE.MARRY_REQ_TYPE_PROPOSE then
		self.marriage_data:SetWeddingTargetInfo(marry_type, target_uid)
	end
end

--结婚操作回馈  
function MarriageCtrl:OnMarryRetInfo(protocol)
	if protocol.ret_type == MARRY_RET_TYPE.MARRY_PRESS_FINGER then
		--代表对方摁了
		self.wedding_hunshu_view:Flush("finish")
	elseif protocol.ret_type == MARRY_RET_TYPE.MARRY_CANCEL then
		--对方拒绝了
		self.wedding_hunshu_view:Close()
	end
	if protocol.ret_val == 2 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_songhuaxinxing_hong")
		FlowersCtrl.Instance:PlayerEffectAddtion(bundle_name, asset_name, "songhua_effect_add_loader2")
		self.wedding_hunshu_view:Flush("bothfinish")
	end
end

function MarriageCtrl:OpenXunYouView()
	if not self.xunyou_view:IsOpen() then
		self.xunyou_view:Open()
	end
end

function MarriageCtrl:CloseXunYouView()
	if self.xunyou_view:IsOpen() then
		self.xunyou_view:Close()
	end
end
---------------摁手印end--------------------------------

function MarriageCtrl:OnSCQingYuanWeddingAllInfo(protocol)
	self.marriage_data:SetHunYanYuYueInfo(protocol)
	if self.wedding_invite_view:IsOpen() then
		self.wedding_invite_view:Flush()
	end
end

function MarriageCtrl:OnSCHunYanCurWeddingAllInfo(protocol)
	self.marriage_data:SetHunYanCurWeddingInfo(protocol)
	if self.wedding_demand_view:IsOpen() then
		self.wedding_demand_view:Flush()
	end
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush()
	end

	if HUNYAN_STATUS.CLOSE ~= self.marriage_data:GetActiveState() then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, true)
	end
end

--申请者信息
function MarriageCtrl:OnSCWeddingApplicantInfo(protocol)
	self.marriage_data:SetHaveApplicantInfo(protocol)
	if self.wedding_invite_view:IsOpen() then
		self.wedding_invite_view:Flush()
	end
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.MarryInvite, true)
end
--祝福历史记录
function MarriageCtrl:OnSCWeddingBlessingRecordInfo(protocol)
	self.marriage_data:SetBlessingRecordInfo(protocol)
	if self.wedding_blessing_view:IsOpen() then
		self.wedding_blessing_view:Flush()
	end
end

--婚礼玩家个人信息
function MarriageCtrl:OnSCWeddingRoleInfo(protocol)
	self.marriage_data:SetWeddingRoleInfo(protocol)
	if self.wedding_blessing_view:IsOpen() then
		self.wedding_blessing_view:Flush()
	end
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush("role_info")
	end
	if protocol.is_baitang == 1 then
		if not CgManager.Instance:IsCgIng() then
			CgManager.Instance:Play(BaseCg.New("cg/w3_gn_hunyan_prefab", "W3_GN_HunYan_Cg1"), function() end)
			-- print_error("播放CG")
		end
	end

	for k,v in pairs(protocol.hunyan_food_id_list) do
		self:ChangeGatherModle(v)
	end
end

function MarriageCtrl:GetMarriageView()
	return self.marriage_view
end

function MarriageCtrl:OnMarrySpecialEffect(protocol)
	-- 播放特效
	if protocol.marry_type == 2 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_songhuabian_lanmeigu")
		FlowersCtrl.Instance:PlayerEffectAddtion(bundle_name, asset_name, "songhua_effect_add_loader")

		bundle_name, asset_name = ResPath.GetUiXEffect("UI_songhua999")
		FlowersCtrl.Instance:PlayerEffectAddtion(bundle_name, asset_name, "songhua_effect_loader")

		bundle_name, asset_name = ResPath.GetUiEffect("UI_songhuaxinxing")
		FlowersCtrl.Instance:PlayerEffectAddtion(bundle_name, asset_name, "songhua_effect_add_loader2")
	else
		local bundle, asset = ResPath.GetUiEffect("UI_songhuabian_homeigu")
		FlowersCtrl.Instance:PlayerEffectAddtion(bundle, asset, "songhua_effect_add_loader")
		if protocol.marry_type == 1 then
			FlowersCtrl.Instance:PlayerEffectAddtion("effects/prefab/ui/ui_jinglinminghun/ui_songhua520_prefab", "UI_songhua520", "songhua_effect_loader")
			
			local bundle_name, asset_name = ResPath.GetUiXEffect("UI_songhuaxinxing_hong")
			FlowersCtrl.Instance:PlayerEffectAddtion(bundle_name, asset_name, "songhua_effect_add_loader2")
		end
	end
end

function MarriageCtrl:OpenEuropeanWeddingTips(data)
	self.european_wedding_tips:SetData(data)
	ViewManager.Instance:Open(ViewName.EuropeanWeddingTips)
end

function MarriageCtrl:OnSCSpecialParamChange(protocol)
	self.marriage_data:SetXunYouingObjId(protocol)

	local obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if obj and obj.SetMarryFlag then
		obj:SetMarryFlag(protocol.param)
	end
end

---------婚礼购买请求----------
function MarriageCtrl:SendCSQingYuanBuyWeddingGiftBagReq(marry_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingYuanBuyWeddingGiftBagReq)
	protocol.marry_type = marry_type
	protocol:EncodeAndSend()
end

-- 改变已采集婚宴的模型
function MarriageCtrl:ChangeGatherModle(gather_obj_id)
	local gather_obj = Scene.Instance:GetObjectByObjId(gather_obj_id)
	if gather_obj ~= nil then
		local res_id = MarrGatherId	or 0			--更换酒席模型id
		gather_obj:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(res_id))
	end
end

--------------------
--光环特购
function MarriageCtrl:OpenMarriageHaloBuyView()
	self.marriage_halo_buy_view:Open()
end