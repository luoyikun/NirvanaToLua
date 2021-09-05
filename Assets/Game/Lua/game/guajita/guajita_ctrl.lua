require("game/guajita/guajita_data")
require("game/guajita/guajita_fb_info_view")
require("game/guajita/guajita_unlock_view")
require("game/guajita/guajita_jiesuotips_view")

local CHECK_TIME_CD = 600		-- 检查剩余时间CD
local LESS_TIEM = 3600			-- 时间阈值

GuaJiTaCtrl = GuaJiTaCtrl or BaseClass(BaseController)

function GuaJiTaCtrl:__init()
	if GuaJiTaCtrl.Instance then
		return
	end

	GuaJiTaCtrl.Instance = self

	self.data = GuaJiTaData.New()
	self.fb_view = GuajiTaFbInfoView.New(ViewName.RuneTowerFbInfoView)
	self.guajita_unlock_view = GuajiTaFbUnlockView.New()
	self.guajita_jiesuo_view = GuajiTaFbJieSuoView.New()
	self:RegisterAllProtocols()
	self.can_open_offline_view = false
	self.is_mainui_open = false
	self.can_move = true
end

function GuaJiTaCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.fb_view then
		self.fb_view:DeleteMe()
		self.fb_view = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.guajita_unlock_view then
		self.guajita_unlock_view:DeleteMe()
		self.guajita_unlock_view = nil
	end
	if self.guajita_jiesuo_view then
		self.guajita_jiesuo_view:DeleteMe()
		self.guajita_jiesuo_view = nil
	end

	if GuaJiTaCtrl.Instance then
		GuaJiTaCtrl.Instance = nil
	end
end

function GuaJiTaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRuneTowerInfo, "OnRuneTowerInfo")
	self:RegisterProtocol(SCRuneTowerAutoReward, "OnRuneTowerAutoReward")

	self:RegisterProtocol(CSRuneTowerFetchTime)
	self:RegisterProtocol(CSRuneTowerAutoFb)
end

function GuaJiTaCtrl:OpenRuneTowerUnlockView(data)
	self.guajita_unlock_view:SetData(data)
end

function GuaJiTaCtrl:OpenRuneJieSuoView(data)
	self.guajita_jiesuo_view:SetData(data)
end

-- 符文塔信息
function GuaJiTaCtrl:OnRuneTowerInfo(protocol)
	self.data:SetRuneTowerInfo(protocol)

	RuneCtrl.Instance:FlushTowerView()
	RemindManager.Instance:Fire(RemindName.RuneTower)
	RemindManager.Instance:Fire(RemindName.BeStrength)
end

function GuaJiTaCtrl:OnRuneTowerAutoReward(protocol)
	self.data:SetAutoRewardData(protocol)
	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD)
end

-- 领取离线时间
function GuaJiTaCtrl:SendGetRuneTowerFetchBuff()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneTowerFetchTime)
	send_protocol:EncodeAndSend()
end

-- 扫荡 req_type = 1(进入副本请求刷新怪物)
function GuaJiTaCtrl:SendRuneTowerAuto(req_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneTowerAutoFb)
	send_protocol.req_type = req_type or 0
	send_protocol:EncodeAndSend()
end

function GuaJiTaCtrl:CheckOfflineCountDown()
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			if not OpenFunData.Instance:CheckIsHide("runetower") then
				return
			end
			local other_cfg = self.data:GetRuneOtherCfg()
			local rune_info = self.data:GetRuneTowerInfo()
			if rune_info.offline_time >= LESS_TIEM then
				return
			end

			local can_use = true
			if next(other_cfg) and next(rune_info) and other_cfg.offline_time_max <= rune_info.offline_time then
				can_use = false
			end

			local ok_callback = function()
				local callback = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					local use_flag = can_use and 1 or 0
					if not can_use then
						TipsCtrl.Instance:ShowSystemMsg(Language.Rune.OfflineLimit)
					end
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, use_flag)
				end
				TipsCtrl.Instance:ShowCommonBuyView(callback, GUAJI_TA_TIME_CARD_ITEM_ID, nil, 1)
			end
			TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback, true, false, false, false, false, false, "runetowerview")
		end, CHECK_TIME_CD)
	end
end
function GuaJiTaCtrl:SetCanMove(is_move)
		self.can_move = is_move
end

function GuaJiTaCtrl:GetCanMove()
	return self.can_move
end

function GuaJiTaCtrl:GetFuwenImgState(is_show)
		self.fb_view:FuwenImgState(is_show)
end
