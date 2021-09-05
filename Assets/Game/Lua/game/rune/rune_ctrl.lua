require("game/rune/rune_view")
require("game/rune/rune_data")
require("game/rune/rune_bag_view")
--require("game/rune/rune_item_cell")
require("game/rune/rune_item_tips")
require("game/rune/rune_preview_view")
require("game/rune/rune_awaken_view")
require("game/rune/rune_awaken_tips_view")

RuneCtrl = RuneCtrl or  BaseClass(BaseController)

local RUNE_SYSTEM_ERROR_TYPE = {
	RUNE_SYSTEM_ERROR_TYPE_GRID_INVALID = 0,				-- 格子无效
	RUNE_SYSTEM_ERROR_TYPE_TOWER_LAYER_NOT_ENOUGH = 1,		-- 符文塔未达到指定层数
	RUNE_SYSTEM_ERROR_TYPE_MAX_LEVEL = 2,					-- 符文已达到最大等级
	RUNE_SYSTEM_ERROR_TYPE_NOT_ENOUGH_SCORE = 3,			-- 战魂精华不足
}

function RuneCtrl:__init()
	if RuneCtrl.Instance ~= nil then
		print_error("[RuneCtrl] attempt to create singleton twice!")
		return
	end
	RuneCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = RuneView.New(ViewName.Rune)
	self.bag_view = RuneBagView.New(ViewName.RuneBag)
	self.tips_view = RuneItemTips.New(ViewName.RuneItemTips)
	self.preview_view = RunePreviewView.New(ViewName.RunePreview)
	self.data = RuneData.New()
	self.old_rune_jinhua = -1
	--创建觉醒面板
	self.awaken_view = RuneAwakenView.New(ViewName.RuneAwakenView)
	self.awaken_tips_view = RuneAwakenTipsView.New(ViewName.RuneAwakenTipsView)
end

function RuneCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.bag_view ~= nil then
		self.bag_view:DeleteMe()
		self.bag_view = nil
	end

	if self.tips_view ~= nil then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	if self.preview_view ~= nil then
		self.preview_view:DeleteMe()
		self.preview_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	--注销觉醒面板
	if self.awaken_view ~= nil then
		self.awaken_view:DeleteMe()
		self.awaken_view = nil
	end
	if self.awaken_tips_view ~= nil then
		self.awaken_tips_view:DeleteMe()
		self.awaken_tips_view = nil
	end

	RuneCtrl.Instance = nil
end

function RuneCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSRuneSystemReq)
	self:RegisterProtocol(CSRuneSystemDisposeOneKey)
	self:RegisterProtocol(SCRuneSystemBagInfo, "OnRuneSystemBagInfo")				--获取符文列表数据
	self:RegisterProtocol(SCRuneSystemRuneGridInfo, "OnRuneSystemRuneGridInfo")		--符文槽信息
	self:RegisterProtocol(SCRuneSystemOtherInfo, "OnRuneSystemOtherInfo")			--符文其他信息
	self:RegisterProtocol(SCRuneSystemComposeInfo, "OnRuneComposeSuc")				--成功合成道具
	self:RegisterProtocol(SCRuneSystemRuneGridAwakenInfo, "OnRuneGridAwakenInfo")	--开始觉醒
	self:RegisterProtocol(SCRuneSystemZhulingNotifyInfo, "OnRuneSystemZhulingNotifyInfo")	--符文注灵抽奖返回
	self:RegisterProtocol(SCRuneSystemZhulingAllInfo, "OnRuneSystemZhulingAllInfo")			--符文注灵信息
	self:RegisterProtocol(SCRoleBigSmallGoalInfo, "OnRuneBigSmallGoalInfo")			--大小目标信息
	
	self:RegisterProtocol(SCRuneTowerPassRewardInfo, "OnRuneTowerPassRewardInfo")			--首通奖励
end

function RuneCtrl:RuneSystemReq(req_type, param1, param2, param3, param4)
	-- print_error(req_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneSystemReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end

function RuneCtrl:SendOneKeyAnalyze(list_count, index_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneSystemDisposeOneKey)
	send_protocol.list_count = list_count or 0
	send_protocol.index_list = index_list or {}
	send_protocol:EncodeAndSend()
end

function RuneCtrl:OnRuneSystemBagInfo(protocol)
	if protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_INVAILD then
		self.data:ChangeBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("analyze")
		end
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then			--背包
		self.data:SetBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("analyze")
			self.view:Flush("compose")
		end
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_RUNE_XUNBAO_INFO then		--寻宝
		self.data:SetTreasureList(protocol.bag_list)
		if #protocol.bag_list > 1 then
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RUNE_MODE_10)
		else
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RUNE_MODE_1)
		end
		self.data:ChangeBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("treasure")
		end
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_OPEN_BOX_INFO then
		self.data:SetMagic(protocol.jinghua_box_magic_crystal)			--宝箱
		self.data:SetBaoXiangList(protocol.bag_list)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE)
		self.data:ChangeBagList(protocol.bag_list)
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_CONVERT_INFO then			--兑换
		self.data:ChangeBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("exchange")
		end
	end
	RemindManager.Instance:Fire(RemindName.RuneInlay)
	RemindManager.Instance:Fire(RemindName.RuneAnalyze)
	RemindManager.Instance:Fire(RemindName.RuneCompose)
end

function RuneCtrl:OnRuneSystemRuneGridInfo(protocol)
	-- print_error("OnRuneSystemRuneGridInfo")
	-- print_error("OnRuneSystemRuneGridInfo", protocol.rune_grid_awaken)
	self.data:SetSlotList(protocol.rune_grid)
	-- print_error("protocol.rune_grid", protocol.rune_grid)
	self.data:SetAwakenList(protocol.rune_grid_awaken)
	if self.view:IsOpen() then
		self.view:Flush("inlay")
		self.view:Flush("zhuling")
	end
	if self.awaken_view:IsOpen() then
		self.awaken_view:Flush("rightview")
	end
	RemindManager.Instance:Fire(RemindName.RuneInlay)
	RemindManager.Instance:Fire(RemindName.RuneCompose)
	RemindManager.Instance:Fire(RemindName.RuneAwake)
end

function RuneCtrl:OnRuneSystemOtherInfo(protocol)
	-- print_error("OnRuneSystemOtherInfo")
	if -1 == self.old_rune_jinhua then
		self.old_rune_jinhua = protocol.rune_jinghua
	else
		local add_jinhua = protocol.rune_jinghua - self.old_rune_jinhua
		self.old_rune_jinhua = protocol.rune_jinghua

		if add_jinhua > 0 then
			TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddRuneJinghua, add_jinhua))
		end
	end
	
	self.data:SetOtherInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("inlay")
		self.view:Flush("compose")
		self.view:Flush("suipian")
	end
	if self.awaken_view:IsOpen() then
		self.awaken_view:Flush("diamondcost")
	end
	RemindManager.Instance:Fire(RemindName.RuneInlay)
	RemindManager.Instance:Fire(RemindName.RuneCompose)
	RemindManager.Instance:Fire(RemindName.RuneTreasure)
end

function RuneCtrl:OnRuneComposeSuc()
	if self.view:IsOpen() then
		self.view:Flush("compose_effect")
	end
end

function RuneCtrl:FlushTowerView()
	if self.view:IsOpen() then
		self.view:Flush("tower")
	end
end

function RuneCtrl:FlushRankView()
	if self.view:IsOpen() then
		self.view:Flush("rank")
	end
end

function RuneCtrl:OnRuneGridAwakenInfo(protocol)
	self.data:SetAwakenSeq(protocol.awaken_seq)
	self.data:SetIsNeedRecalc(protocol.is_need_recalc)
	if self.awaken_view:IsOpen() then
		self.awaken_view:Flush("needle")
	end
end

function RuneCtrl:OnRuneSystemZhulingNotifyInfo(protocol)
	self.view:Flush("zhuling_bless", {protocol.index, protocol.zhuling_slot_bless})
	self.data:SetRuneZhulingSlotBless(protocol.zhuling_slot_bless)
end

function RuneCtrl:OnRuneSystemZhulingAllInfo(protocol)
	self.data:SetRuneZhulingInfo(protocol)
	self.view:Flush("zhuling_effect")
end

function RuneCtrl:OnRuneTowerPassRewardInfo(protocol)
	self.data:SetRunePassRewardInfo(protocol)
end

function RuneCtrl:SetSlotIndex(slot)				--1开始
	self.bag_view:SetSlotIndex(slot)
end

function RuneCtrl:SetTipsData(data)
	self.tips_view:SetData(data)
end

function RuneCtrl:SetTipsCallBack(callback)
	self.tips_view:SetCloseCallBack(callback)
end

function RuneCtrl:SetAwakenTipsCallBack(callback)
	self.awaken_tips_view:SetCloseCallBack(callback)
end

function RuneCtrl:SetAwakenTipsOpenCallBack(callback)
	self.awaken_tips_view:SetOpenCallBack(callback)
end

function RuneCtrl:SendBigSmallGoalOper(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleBigSmallGoalOper)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function RuneCtrl:OnRuneBigSmallGoalInfo(protocol)
	self.data:SetAllGoalInfo(protocol)
	if protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		GoddessData.Instance:SetGoalInfo(protocol)
		GoddessCtrl.Instance:FlushView("info")
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.Goddess)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		SpiritData.Instance:SetGoalInfo(protocol)
		SpiritCtrl.Instance.spirit_view:Flush("spirit")
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.SpiritInfo)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		self.data:SetGoalInfo(protocol)
		self.view:FlushGoal()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.RuneInlay)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		HunQiData.Instance:SetGoalInfo(protocol)
		HunQiCtrl.Instance:FlushHunQiTimes()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.HunQi_HunQi)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		ShenGeData.Instance:SetGoalInfo(protocol)
		ShenGeCtrl.Instance.view:FlushGoal()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		ShenYinData.Instance:SetGoalInfo(protocol)
		ShenYinCtrl.Instance.view:Flush()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.ShenYin_ShenYin)
	
	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		ShenShouData.Instance:SetGoalInfo(protocol)
		ShenShouCtrl.Instance.view:Flush()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.ShenShou)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN then
		ForgeData.Instance:SetStrengthGoalInfo(protocol)
		ForgeCtrl.Instance:FLushStrengthView()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE then
		ForgeData.Instance:SetGemGoalInfo(protocol)
		ForgeCtrl.Instance:FLushGemView()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
	
	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		ShengXiaoData.Instance:SetGoalInfo(protocol)
		ShengXiaoCtrl.Instance:OnXingzuoYijiInfoChange()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		ShenShouData.Instance:SetShengQiGoalInfo(protocol)
		ShenShouCtrl.Instance.view:Flush()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.ShengQi)

	elseif protocol.system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		BianShenData.Instance:SetGoalInfo(protocol)
		BianShenCtrl.Instance:FlushMsgView()
		TipsCtrl.Instance:FlushGoalTimeLimitTitleView()
		RemindManager.Instance:Fire(RemindName.BianShenMsg)
	end

	if ViewManager.Instance:IsOpen(ViewName.TodayThemeView) then
		TipsCtrl.Instance:FlushTodayThemeRewardView()
	end
end

-- 战魂附魂提示 result = 1 succ, 0 fail
function RuneCtrl:OnRuneInlayTips(result, param1, param2)
	if result == 0 then
		local str = ""
		if param1 == RUNE_SYSTEM_ERROR_TYPE.RUNE_SYSTEM_ERROR_TYPE_TOWER_LAYER_NOT_ENOUGH then
			str = string.format(Language.Rune.RuneSystemErrorType[param1], param2)
		else
			str = Language.Rune.RuneSystemErrorType[param1] or ""
		end
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end