ShenYinLieHunView = ShenYinLieHunView or BaseClass(BaseRender)

local SOUL_BAOXIANG_NUM = 5	-- 抽招印宝箱
local SOUL_POOL_ROW = 5 	-- 猎招印的行数

function ShenYinLieHunView:__init()

	self.node_list["KeySaleBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeySale, self))
	self.node_list["OneKeyBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeyCall, self))
	self.node_list["ChangeBtn"].button:AddClickListener(BindTool.Bind(self.OnClickChangeLife, self))
	self.node_list["PutInBagBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeyPutInBag, self))
	self.node_list["CellChouHun1"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickChouHun, self,1))
	self.node_list["CellChouHun2"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickChouHun, self,2))
	self.node_list["CellChouHun3"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickChouHun, self,3))
	self.node_list["CellChouHun4"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickChouHun, self,4))
	self.node_list["CellChouHun5"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickChouHun, self,5))
	self.node_list["JumpShenMoBtn"].button:AddClickListener(BindTool.Bind(self.OnClickJumpShenMo, self))

	self.get_soul_items = {}
	for i = 1, SOUL_POOL_ROW do
		self.get_soul_items[i] = SpiritSoulItemGroupSixLengtow.New(self.node_list["ItemGroup"..i])
	end

	self.color_items = {}
	self.color_btn_costs = {}
	for i = 1, SOUL_BAOXIANG_NUM do
		self.color_items[i] = self.node_list["Icon" .. i]
		self.color_btn_costs[i] = self.node_list["CostNumTxt" .. i]
	end

	self.select_toggle = self.node_list["SelectToggle"]
	self.select_toggle.toggle.isOn = false
	self.select_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self))

	self.soul_items = {}
end

function ShenYinLieHunView:__delete()
	for k, v in pairs(self.soul_items) do
		v:DeleteMe()
	end
	self.soul_items = {}

	for k, v in pairs(self.get_soul_items) do
		v:DeleteMe()
	end
	self.get_soul_items = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ShenYinLieHunView:OpenCallBack()
	self:Flush()
end

function ShenYinLieHunView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ShenYinLieHunView:OnToggleChange(ison)
	self:SetCostHunli()
end

-- 一键回收
function ShenYinLieHunView:OnClickOneKeySale()
	local liehun_pool = ShenYinData.Instance:GetLieHunPoolInfo()
	if not liehun_pool or not next(liehun_pool) then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.SoulPoolNoCanSale)
		return
	end

	local can_sale = false
	local add_imprint_score = 0
	for k, v in pairs(liehun_pool) do
		if v > 0 then
			can_sale = true
			local v_item_id = ShenYinData.Instance:GetHunShouVItemIdByIndex(v)
			local item_cfg = ShenYinData.Instance:GetItemCFGByVItemID(v_item_id)
			local sale_imprint_score = ShenYinData.Instance:GetShenYinShenRecycle(item_cfg.quanlity, item_cfg.suit_id ~= 0 and 1 or 0)
			add_imprint_score = add_imprint_score + sale_imprint_score
		end
	end
	if not can_sale then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.SoulPoolNoCanSale)
		return
	end

	local ok_func = function ()
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.CONVERT_TO_EXP)
	end
	local text = string.format(Language.ShenYin.SoulOneKeySaleCallStr, add_imprint_score)
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, text, nil, nil, true, false, "onekeysale")
end

-- 一键放入背包
function ShenYinLieHunView:OnClickOneKeyPutInBag()
	local liehun_pool = ShenYinData.Instance:GetLieHunPoolInfo()
	if not liehun_pool or not next(liehun_pool) then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.SoulPoolNoCanPutBag)
		return
	end

	local can_sale = false
	for k, v in pairs(liehun_pool) do
		if v > 0 then
			can_sale = true
			break
		end
	end
	if not can_sale then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.SoulPoolNoCanPutBag)
		return
	end
	local ok_func = function ()
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.PUT_BAG_ONE_KEY)
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenYin.PutBagOnekey , nil, nil, true, false, "putbagonekey")
end

-- 一键召印
function ShenYinLieHunView:OnClickOneKeyCall()
	local liehun_color = ShenYinData.Instance:GetLieHunColor()
	local liehun_pool = ShenYinData.Instance:GetLieHunPoolInfo()
	local index = 0
	local cfg = ShenYinData.Instance:GetChouHunCfg()
	local chouhun_score_info = ShenYinData.Instance:GetChouHunScoreInfo()
	if liehun_pool then
		local ok_func = function ()
			ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.BATCH_HUNSHOU, self.select_toggle.toggle.isOn and 1 or 0)
		end
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		
		for k, v in pairs(cfg) do
			if v.chouhun_color == liehun_color then
				if self.select_toggle.toggle.isOn and chouhun_score_info < v.cost_hun_li then
					TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.NoYuanLi)
					return
				elseif not self.select_toggle.toggle.isOn and main_role_vo.gold < v.cost_diamonds then
					TipsCtrl.Instance:ShowLackDiamondView()
					return
				end
			end
		end
		local UseMoney = self.select_toggle.toggle.isOn and Language.ShenYin.SoulText or Language.Common.Gold
		local text = string.format(Language.ShenYin.SoulMultipleCallStr, UseMoney)
		local tips_key = self.select_toggle.toggle.isOn and "tip_score" or "tip_gold"
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, text , nil, nil, true, false, tips_key)
	end
end

-- 逆天改命
function ShenYinLieHunView:OnClickChangeLife()
	local other_cfg = ShenYinData.Instance:GetOtherCFG()
	local liehun_chouhun_color_info = ShenYinData.Instance:GetLieHunColor()
	local ok_func = function ()
		ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.SUPER_CHOUHUN)
	end

	local str = string.format(Language.ShenYin.SoulChangeLifeStr, other_cfg.super_chouhun_price)
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, str, nil, nil, true, false, "changelife")
end

-- 点击召唤出来的猎魂
function ShenYinLieHunView:OnClickHadCallSoulItem(data, item, i)
	item:CloseHighLight(i)
	ShenYinCtrl.Instance:OpenYinJiTip(data, ShenYinYinJiTipView.FromView.ShenYinStore)
end

-- 猎魂抽取存放池
function ShenYinLieHunView:SetSoulPoolItemData()
	local liehun_pool = ShenYinData.Instance:GetLieHunPoolInfo()
	if liehun_pool and next(liehun_pool) and self.get_soul_items then
		for k, v in pairs(self.get_soul_items) do
			for n = 1, 4 do
				local grid_index = (k - 1) * 4 + n
				local liehun_pool_index = liehun_pool[grid_index]
				v:SetData(n, {id = liehun_pool_index, grid_index = grid_index - 1})
				local virtual_item_id = ShenYinData.Instance:GetHunShouVItemIdByIndex(liehun_pool_index)
				local item_cfg = ShenYinData.Instance:GetItemCFGByVItemID(virtual_item_id)
				if item_cfg.item_type == 1 then
					local data = TableCopy(item_cfg)
					data.param1 = grid_index - 1
					v:ListenClick(n, BindTool.Bind(self.OnClickHadCallSoulItem, self, data, v, n))
				else
					v:ListenClick(n)
				end
			end
		end
	end
end

-- 设置抽猎魂颜色
function ShenYinLieHunView:SetItemColor()
	local liehun_color_info = ShenYinData.Instance:GetLieHunColor()
	local baoxiang_index = 0
	for k, v in pairs(self.color_items) do
		if k == (liehun_color_info + 1) then
			baoxiang_index = k
			UI:SetGraphicGrey(v,false)
		else
			UI:SetGraphicGrey(v,true)
			v.animator:SetBool("Shake", false)
		end
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if not self.time_quest then
		local time = 0
		if self.color_items[baoxiang_index] then
			self.color_items[baoxiang_index].animator:SetBool("Shake", true)
		end
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			time = time - 1
			if self.color_items[baoxiang_index] and time <= 0  then
				self.color_items[baoxiang_index].animator:SetBool("Shake", true)
				time = 1
			end
		end, 1)
	end
end

function ShenYinLieHunView:OnClickChouHun(index)
	local liehun_color = ShenYinData.Instance:GetLieHunColor()
	local chouhun_score_info = ShenYinData.Instance:GetChouHunScoreInfo()
	local cfg = ShenYinData.Instance:GetChouHunCfg()
	if index ~= (liehun_color + 1) or not cfg then return end

	for k, v in pairs(cfg) do
		if v.chouhun_color == liehun_color then
			if self.select_toggle.toggle.isOn and chouhun_score_info < v.cost_hun_li then
				TipsCtrl.Instance:ShowSystemMsg(Language.ShenYin.NoYuanLi)
				return
			end
		end
	end

	local is_use_score = self.select_toggle.toggle.isOn and 1 or 0
	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.CHOUHUN, is_use_score)
end

function ShenYinLieHunView:OnClickJumpShenMo()
	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.KF_TUANZHAN)
end

-- 设置抽猎命的消耗魂力数值
function ShenYinLieHunView:SetCostHunli()
	local cfg = ShenYinData.Instance:GetChouHunCfg()
	local score = ShenYinData.Instance:GetChouHunScoreInfo()
	local value
	local color
	local cost_text
	for k, v in pairs(self.color_btn_costs) do
		color = TEXT_COLOR.YELLOW
		if self.select_toggle.toggle.isOn then
			value = cfg[k] and cfg[k].cost_hun_li or 0
			color = score >= cfg[k].cost_hun_li and TEXT_COLOR.YELLOW or TEXT_COLOR.RED
		else
			value = cfg[k] and cfg[k].cost_diamonds or 0
		end
		cost_text = string.format(Language.ShenYin.CostHunliColor, color, value)
		v.text.text = cost_text
	end
end

function ShenYinLieHunView:SetChouHunScore()
	local chouhun_score_info = ShenYinData.Instance:GetChouHunScoreInfo()
	self.node_list["ChouHunScoreTxt"].text.text = string.format(Language.ShenYin.UseChouHunScore, chouhun_score_info)
end

function  ShenYinLieHunView:SetSpiritImprintScore()
	local score_info = ShenYinData.Instance:GetPastureSpiritImprintScoreInfo()
	self.node_list["TxtStorageExp"].text.text = string.format(Language.ShenYin.StorageExp, score_info)
end

function ShenYinLieHunView:OnFlush(param_t)
	self:SetSoulPoolItemData()
	self:SetItemColor()
	self:SetCostHunli()
	self:SetChouHunScore()
	self:SetSpiritImprintScore()
end

-------------------------------------SpiritSoulItemGroupSixLengt---------------------------------------------
-- 6个长度的猎魂格子组，在猎魂获取面板
SpiritSoulItemGroupSixLengtow = SpiritSoulItemGroupSixLengtow or BaseClass(BaseRender)

function SpiritSoulItemGroupSixLengtow:__init(instance)
	
	
	self.items = {}
	for i = 1, 4 do
		self.items[i] = ShenYinLieHunItem.New(self.node_list["SoulItem" .. i])
	end
end

function SpiritSoulItemGroupSixLengtow:__delete()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function SpiritSoulItemGroupSixLengtow:ListenClick(i, handler)
	self.items[i]:ListenClick(handler)
end

function SpiritSoulItemGroupSixLengtow:SetItemActive(i, enable)
	self.items[i]:SetActive(enable)
end

function SpiritSoulItemGroupSixLengtow:SetData(i, data)
	self.items[i]:SetData(data)
end

function SpiritSoulItemGroupSixLengtow:GetData(i)
	return self.items[i]:GetData()
end

function SpiritSoulItemGroupSixLengtow:GetItemCellCloseCallback(i)
	return self.items[i]:GetItemCellCloseCallback()
end

function SpiritSoulItemGroupSixLengtow:CloseHighLight(i)
	self.items[i]:CloseHighLight()
end

