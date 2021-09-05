require("game/symbol/symbol_view")
require("game/symbol/symbol_data")
require("game/symbol/symol_xl_stuff_view")

SymbolCtrl = SymbolCtrl or  BaseClass(BaseController)

function SymbolCtrl:__init()
	if SymbolCtrl.Instance ~= nil then
		ErrorLog("[SymbolCtrl] attempt to create singleton twice!")
		return
	end
	SymbolCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = SymbolData.New()
	self.view = SymbolView.New(ViewName.Symbol)
	self.symol_xl_stuff_view = SymbolXilianStuffView.New()
	
end

function SymbolCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.symol_xl_stuff_view ~= nil then
		self.symol_xl_stuff_view:DeleteMe()
		self.symol_xl_stuff_view = nil
	end

	SymbolCtrl.Instance = nil
end

-- 协议注册
function SymbolCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCElementHeartInfo, "OnElementHeartInfo")
	self:RegisterProtocol(SCElementShopInfo, "OnElementShopInfo")
	self:RegisterProtocol(SCElementTextureInfo, "OnElementTextureInfo")
	self:RegisterProtocol(SCCharmGhostSingleCharmInfo, "OnCharmGhostSingleCharmInfo")
	self:RegisterProtocol(SCElementHeartChouRewardListInfo, "OnElementHeartChouRewardListInfo")
	self:RegisterProtocol(SCElementProductListInfo, "OnElementProductListInfo")
	self:RegisterProtocol(SCElementXiLianAllInfo, "OnElementXiLianAllInfo")
	self:RegisterProtocol(SCElementXiLianSingleInfo, "OnElementXiLianSingleInfo")

end

--打开洗练材料界面
function SymbolCtrl:OpenSymbolXilianStuffView(callback)
	self.symol_xl_stuff_view:SetData(callback)
end

--元素之心信息
function SymbolCtrl:OnElementHeartInfo(protocol)
	self.data:SetElementHeartInfo(protocol)
	local index = next(protocol.element_list)
	if protocol.info_type == SymbolData.INFO_TYPE.WUXING_CHANGE and index then
		local info = protocol.element_list[index]
		local func = function ()
			self:SendSetElementHeartReq(info.id)
		end
		local cur_element = Language.Symbol.ElementsName[info.tartget_wuxing_type]
		TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Symbol.ChangeElementText, cur_element))
	end
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.SymbolYuanSu)
	RemindManager.Instance:Fire(RemindName.SymbolYuanHuo)
	RemindManager.Instance:Fire(RemindName.SymbolYuanHun)
	RemindManager.Instance:Fire(RemindName.SymbolYuanZhuang)
	RemindManager.Instance:Fire(RemindName.SymbolYuanShi)
end

--商店信息
function SymbolCtrl:OnElementShopInfo(protocol)
	self.data:SetElementShopInfo(protocol)
	self.view:Flush()
end

--元素之纹列表信息
function SymbolCtrl:OnElementTextureInfo(protocol)
	self.data:SetElementTextureInfo(protocol)
	self.view:Flush()
end

--单个元素之纹信息
function SymbolCtrl:OnCharmGhostSingleCharmInfo(protocol)
	self.data:SetCharmGhostSingleCharmInfo(protocol)
	self.view:Flush()
end

--抽奖奖品
function SymbolCtrl:OnElementHeartChouRewardListInfo(protocol)
	self.data:SetElementHeartChouRewardListInfo(protocol)
	if #protocol.reward_list == 1 then
		self.view:Flush("chou_reward", {item_id = protocol.reward_list[1].item_id})
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN)
	end
end

--产出列表
function SymbolCtrl:OnElementProductListInfo(protocol)
	self.data:SetElementProductListInfo(protocol)
	self.view:Flush()
	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SYMBOL)
end

--全部洗练信息
function SymbolCtrl:OnElementXiLianAllInfo(protocol)
	self.data:SetElementXiLianAllInfo(protocol)
	self.view:Flush()
end

--单个洗练信息
function SymbolCtrl:OnElementXiLianSingleInfo(protocol)
	self.data:SetElementXiLianSingleInfo(protocol)
	self.view:Flush()
end

-- 元素之心激活请求
function SymbolCtrl:SendActiveElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.ACTIVE_GHOST, id)
end

-- 元素之心转换请求
function SymbolCtrl:SendChangeElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.CHANGE_GHOST_WUXING_TYPE, id)
end

-- 元素之心设置请求
function SymbolCtrl:SendSetElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.SET_GHOST_WUXING_TYPE, id)
end

-- 元素之心喂养请求
function SymbolCtrl:SendFeedElementHeartReq(id, virtual_id, num)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.FEED_ELEMENT, id, virtual_id, num)
end

-- 元素之心领取请求
function SymbolCtrl:SendRewardElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.GET_PRODUCT, id)
end

-- 元素之心加速请求
function SymbolCtrl:SendProductElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.PRODUCT_UP_SEED, id)
end

-- 元素之心抽奖请求
local cj_count, cj_use_score, cj_is_use_gold = 0, 0, 0
function SymbolCtrl:SendChoujiangElementHeartReq(count, use_score, is_use_gold)
	cj_count = count
	cj_use_score = use_score
	cj_is_use_gold = is_use_gold
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.CHOUJIANG, count, use_score, cj_is_use_gold)
end

-- 元素之心抽奖请求
function SymbolCtrl:SendChoujiangElementHeartReqAgain()
	self:SendChoujiangElementHeartReq(cj_count, cj_use_score, cj_is_use_gold)
end

-- 元素之心洗练请求
function SymbolCtrl:SendXilianElementHeartReq(id, lock_flag, color, auto_buy)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.XILIAN, id, lock_flag, color, auto_buy)
end

-- 元素之心背包清理请求
function SymbolCtrl:SendCleanBagElementHeartReq(is_merge)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.KNASACK_ORDER, is_merge)
end

--元素之纹升级请求
function SymbolCtrl:SendUpgradeCharmReq(e_index,bag_index)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.UPGRADE_CHARM, e_index,bag_index)
end

--元素之心进阶请求
function SymbolCtrl:SendUpgradeGhostReq( element_id, is_one_key,is_auto_buy )
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.UPGRADE_GHOST,element_id,is_one_key,is_auto_buy)
end

--元素之心进阶结果返回
function SymbolCtrl:OnElementHeartUpgradeResult(result)
	self.view:ElementHeartUpgradeResult(result)
end

--元素之心符咒升级结果返回
function SymbolCtrl:OnElementTextureUpgradeResult(result)
	self.view:ElementTextureUpgradeResult(result)
end

--元素之心符咒升级结果返回
function SymbolCtrl:OnYuanZhuangUpgradeResult(result)
	self.view:OnYuanZhuangUpgradeResult(result)
end

--刷新商店
function SymbolCtrl:SendShopRefreshtReq(is_use_score)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.SHOP_REFRSH, is_use_score)
end

--购买商店物品
function SymbolCtrl:SendShopBuyReq(seq)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.SHOP_BUY, seq)
end

--穿戴装备
function SymbolCtrl:SendPutOnEquipment(id, equip_index)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.PUTON_EQUIP, id, equip_index)
end

--装备升级
function SymbolCtrl:SendEquipUpgrade(id, is_auto)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.UPGRADE_EQUIP, id, is_auto)
end

--装备分解
function SymbolCtrl:SendEquipRecycle(grid_index, num)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.EQUIP_RECYCLE, grid_index, num)
end

-- 元素之心操作请求
function SymbolCtrl:SendElementHeartReq(info_type, param1, param2, param3, param4)
	local protocol = ProtocolPool.Instance:GetProtocol(CSElementHeartReq)
	protocol.info_type = info_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol.param4 = param4 or 0
	protocol:EncodeAndSend()
end

-- 打开附魂选择提示界面
function SymbolCtrl:OpenSymbolSelectTips(callback)
	self.symbol_select_tips_view:SetCallBack(callback)
	self.symbol_select_tips_view:Open()
end

function SymbolCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if nil == item_id or self.data:GetElementItemCfg(item_id) or self.data:IsEquipmentItem(item_id) then
		self.data:ClearCacheElementItemList()
		self.data:UpdateFoodList()
	end
	self.view:Flush()
end
