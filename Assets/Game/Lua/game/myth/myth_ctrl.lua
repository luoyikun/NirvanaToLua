require("game/myth/myth_view")
require("game/myth/myth_data")
-- require("game/myth/compose_select_equip")
require("game/myth/myth_equip_tip")

MythCtrl = MythCtrl or BaseClass(BaseController)

function MythCtrl:__init()
	if MythCtrl.Instance then
		print_error("[MythCtrl] Attempt to create singleton twice!")
		return
	end
	MythCtrl.Instance = self

	self.data = MythData.New()
	self.view = MythView.New(ViewName.MythView)

	-- self.select_equip_view = ComposeSelectEquip.New()
	self.myth_shenhun_tip = MythEquipTip.New()
	self:RegisterAllProtocols()

end

function MythCtrl:__delete()
	MythCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.myth_shenhun_tip then
		self.myth_shenhun_tip:DeleteMe()
		self.myth_shenhun_tip = nil
	end

end

function MythCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMythChpaterInfo, "OnSCMythChpaterInfo")
	self:RegisterProtocol(SCMythKnapaskInfo, "OnSCMythKnapaskInfo")
	self:RegisterProtocol(SCMythChpaterSingleInfo, "OnSCMythChpaterSingleInfo")
end

function MythCtrl:OnSCMythChpaterInfo(protocol)
	self.data:SetSCMythChpaterInfo(protocol)
	self.data:SetSoulGodList(protocol.chpater_list)
	self.view:Flush()
	self:FireRemind()
end

function MythCtrl:OnSCMythKnapaskInfo(protocol)
	if protocol.is_all == 1 then
		self.data:SetSCFirstMythKnapaskInfo(protocol)
	elseif protocol.is_all == 0 then
		self.data:SetSCMythKnapaskInfo(protocol)
	end
	self.view:Flush()
	self:FireRemind()
end

function MythCtrl:OnSCMythChpaterSingleInfo(protocol)
	self.data:SetSCMythChpaterSingleInfo(protocol)
	self.view:Flush()
	self:FireRemind()
end

-- 操作请求
function MythCtrl:SendCSMythOpera(opera_type, param1, param2, param3, param4)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMythOpera)
	protocol.opera_type = opera_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol.param4 = param4 or 0
	protocol:EncodeAndSend()
end


function MythCtrl:MythHeChengBagOpen(select_item)
	-- self.select_equip_view:SetHeChengData(select_item)
	-- self.select_equip_view:Open()
end

function MythCtrl:SetDataAndOepnEquipTip(select_item,form_view,myth_id ,close_call_back)
	self.myth_shenhun_tip:SetData(select_item, form_view,myth_id,close_call_back)
end

function MythCtrl:OnLingWuUpgradeResult(result)
	-- self.view:OnLingWuUpgradeResult(result)
end

function MythCtrl:FireRemind()
	RemindManager.Instance:Fire(RemindName.ShenHuaPianZhang)
	RemindManager.Instance:Fire(RemindName.ShenHuaGongMing)
	-- RemindManager.Instance:Fire(RemindName.Myth_LingWu)
	-- -- RemindManager.Instance:Fire(RemindName.Myth_CuiQu)
	-- RemindManager.Instance:Fire(RemindName.Myth_Compose)
	-- RemindManager.Instance:Fire(RemindName.Myth_GongMing)
end

function MythCtrl:OpenKnapsackClick()
	-- self.view:OpenKnapsackClick()
end