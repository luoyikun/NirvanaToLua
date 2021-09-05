require("game/shenyin/shenyin_view")
require("game/shenyin/shenyin_data")
require("game/shenyin/shenyin_yinji_tip")
require("game/shenyin/shenyin_select_view")
require("game/shenyin/shenyin_recycle_view")
require("game/shenyin/shenyin_suit_attr_view")

ShenYinCtrl = ShenYinCtrl or  BaseClass(BaseController)

function ShenYinCtrl:__init()
	if ShenYinCtrl.Instance ~= nil then
		ErrorLog("[ShenYinCtrl] attempt to create singleton twice!")
		return
	end
	ShenYinCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = ShenYinData.New()
	self.view = ShenYinView.New(ViewName.ShenYinView)
	self.yinji_tip_view = ShenYinYinJiTipView.New(ViewName.ShenYinYinJiTipView)
	self.tianxiang_attr_view = ShenYinTianXiangAttrView.New(ViewName.ShenYinTianXiangAttrView)
	self.qianghua_attr_view = ShenYinQiangHuaAttrView.New(ViewName.ShenYinQiangHuaAttrView)
	self.tianxiang_group_view = TianXiangGroupAttrView.New(ViewName.TianXiangGroupAttrView)
	self.select_view = ShenYinSelectView.New()
	self.recycle_view = ShenYinRecycleView.New()
	self.suit_tip_view = ShenYinSuitAttrView.New(ViewName.ShenYinSuitAttrView)

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.global_event = GlobalEventSystem:Bind(OtherEventType.FLUSH_SHENYIN_BAG, BindTool.Bind(self.FlushRecycleView, self))
	-- ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShenYinCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.yinji_tip_view ~= nil then
		self.yinji_tip_view:DeleteMe()
		self.yinji_tip_view = nil
	end

	if self.tianxiang_attr_view ~= nil then
		self.tianxiang_attr_view:DeleteMe()
		self.tianxiang_attr_view = nil
	end

	if self.tianxiang_attr_view ~= nil then
		self.tianxiang_attr_view:DeleteMe()
		self.tianxiang_attr_view = nil
	end

	if self.tianxiang_group_view ~= nil then
		self.tianxiang_group_view:DeleteMe()
		self.tianxiang_group_view = nil
	end
	ShenYinCtrl.Instance = nil

	if nil ~= self.global_event then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

	if self.select_view then
		self.select_view:DeleteMe()
		self.select_view = nil
	end

	if self.recycle_view then
		self.recycle_view:DeleteMe()
		self.recycle_view = nil
	end
	-- if self.item_data_event ~= nil and ItemData.Instance then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end
end

-- 协议注册
function ShenYinCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSTianxiangOperaReq)	
	self:RegisterProtocol(CSShenYinOneKeyRecyleReq)

	self:RegisterProtocol(SCPastureSpiritImprintScoreInfo, "OnPastureSpiritImprintScoreInfo")
	self:RegisterProtocol(SCPastureSpiritImprintBagInfo, "OnPastureSpiritImprintBagInfo")
	self:RegisterProtocol(SCPastureSpiritImprintShopInfo, "OnPastureSpiritImprintShopInfo")
	self:RegisterProtocol(SCShenYinLieMingBagInfo, "OnShenYinLieMingBagInfo")
	self:RegisterProtocol(SCSendTianXiangAllInfo, "OnSCSendTianXiangAllInfo")
end

function ShenYinCtrl.SendTianXiangOperate(operate_type, param_1, param_2, param_3, param_4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTianxiangOperaReq)
    send_protocol.info_type = operate_type or 0
    send_protocol.param1 = param_1 or 0
    send_protocol.param2 = param_2 or 0
    send_protocol.param3 = param_3 or 0
    send_protocol.param4 = param_4 or 0
	send_protocol:EncodeAndSend()
end

function ShenYinCtrl.SendTianXiangRecycleOperate(count, virtual_bag_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenYinOneKeyRecyleReq)
	send_protocol.count = count or 0
	send_protocol.virtual_bag_list = virtual_bag_list or {}
	send_protocol:EncodeAndSend()
end

function ShenYinCtrl:OnPastureSpiritImprintBagInfo(protocol)
	self.data:SetImprintBagInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("all")
	end
	if self.recycle_view:IsOpen() then
		self.recycle_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ShenYin_ShenYin)
	RemindManager.Instance:Fire(RemindName.ShenYin_XiLian)
	RemindManager.Instance:Fire(RemindName.ShenYin_QiangHua)
end

function ShenYinCtrl:FlushRecycleView()
	if self.recycle_view:IsOpen() then
		self.recycle_view:Flush()
	end
end

function ShenYinCtrl:FlushShenYinView()
	if self.view:IsOpen() then
		self.view:Flush("all")
	end
end

function ShenYinCtrl:OnPastureSpiritImprintScoreInfo(protocol)
	local score = self.data:GetChouHunScoreInfo()
	if protocol.chouhun_score - score > 0 then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddHunYinScore, protocol.chouhun_score - score))
	end
	self.data:SetPastureSpiritImprintScoreInfo(protocol)
	if 0 == protocol.type then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.ShenYin.AddShenYinScore, protocol.add_score))
	end
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ShenYin_LieHun)
end

function ShenYinCtrl:OnPastureSpiritImprintShopInfo(protocol)
	self.data:SetSpiritImprintShopInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function ShenYinCtrl:OnShenYinLieMingBagInfo(protocol)
	self.data:SetLieHunPoolInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function ShenYinCtrl:OpenYinJiTip(data, view_type)
	if data and data.param1 then
		data.param1 = data.bag_index
	end
	self.yinji_tip_view:SetData(data, view_type)
end

function ShenYinCtrl:OnSCSendTianXiangAllInfo(protocol)
	self.data:SetCombineList(protocol.combine_list)
    self.data:SetBeadList(protocol.grid_list)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function ShenYinCtrl:OpenTianXiangChangeView(data, type)
	ViewManager.Instance:Open(ViewName.ShenYinTianXiangChangeView)
	self.tianxiang_change_view:SetData(data, type)
end

function ShenYinCtrl:OpenQiangHuaAttrView(index)
	ViewManager.Instance:Open(ViewName.ShenYinQiangHuaAttrView)
	self.qianghua_attr_view:SetSelectIndex(index)
end

function ShenYinCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.data.xilian_stuff[item_id] then
		if new_num > old_num then
			self.data:SetXiLianRedPoint(true)
			RemindManager.Instance:Fire(RemindName.ShenYin_XiLian)
		end
	end 
end

function ShenYinCtrl:OpenShenYinQianghuaViewBySlot(slot)
	self.view:SetSelectSlot(slot)
	self.view:ChangeToIndex(TabIndex.shenyin_qianghua)
end

function ShenYinCtrl:ShowSelectView(call_back, data_list)
	self.select_view:SetSelectCallBack(call_back)
	self.select_view:SetHadSelect(data_list)
	self.select_view:Open()
end

function ShenYinCtrl:ChangeToShenYinViewByIndex(index)
	self.view:ChangeToIndex(index)
end

function ShenYinCtrl:ShowRecycleView()
	self.recycle_view:Open()
end