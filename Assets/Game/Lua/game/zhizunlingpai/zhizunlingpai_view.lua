ZhiZunLingPaiView = ZhiZunLingPaiView or BaseClass(BaseView)

function ZhiZunLingPaiView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/zhizunlingpai_prefab","ZhiZunLingPai"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
	}
	self.play_audio = true
	self.hide = false
	self.is_modal = true
end

function ZhiZunLingPaiView:__delete()
end

function ZhiZunLingPaiView:LoadCallBack()
	self.lingpai_list = {}
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["TitleText"].text.text = Language.Kuafu3V3.ZhiZun
	local list_delegate = self.node_list["LingPaiListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
end

function ZhiZunLingPaiView:ReleaseCallBack()
	if self.lingpai_list then
		for k,v in pairs(self.lingpai_list) do
			v:DeleteMe()
		end
	end
	self.lingpai_list = {}

end

function ZhiZunLingPaiView:OnFlush(param_list)
	for k, v in pairs(self.lingpai_list) do
		v:Flush()
	end
end

function ZhiZunLingPaiView:OnClickClose()
	self:Close()
end

function ZhiZunLingPaiView:GetNumberOfCells()
	return ZhiZunLingPaiData.Instance:GetCardShowCount()
end

function ZhiZunLingPaiView:CellRefreshDel(cellobj,index)
	local cell = self.lingpai_list[cellobj]
	if cell == nil then
		cell = LingPaiItem.New(cellobj.gameObject)
		self.lingpai_list[cellobj] = cell
	end

	cell:SetIndex(index + 1)
	cell:SetClickWearToggleCallBack(BindTool.Bind(self.OnClickWearToggle, self))
	cell:Flush()
end

function ZhiZunLingPaiView:OnClickWearToggle(cell)
	if nil == cell then
		return
	end
	local flag = KuafuPVPData.Instance:GetIsWear(cell.index)-- cell.is_wear:GetBoolean()
	local oper_type = nil
	if flag then
		oper_type = CROSS_RING_CARD_OPER_TYPE.CROSS_RING_CARD_OPER_OFF
	else
		oper_type = CROSS_RING_CARD_OPER_TYPE.CROSS_RING_CARD_OPER_WEAR
	end

	local season_card_cfg = ZhiZunLingPaiData.Instance:GetSeasonCardItemCfg(cell.season, cell.grade)
	ZhiZunLingPaiCtrl.Instance:SendCross3v3LingPai(oper_type, season_card_cfg.seq)
end

-------------------------LingPaiItem----------------------------
LingPaiItem = LingPaiItem or BaseClass(BaseCell)

function LingPaiItem:__init()

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLiNum"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	self.attr_list = {}
	self.attr = {}
	self.season = 0
	self.grade = 0

	self.node_list["WearToggle"].button:AddClickListener(BindTool.Bind(self.OnClickWearToggle, self))

	local list_delegate = self.node_list["AttrListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
	self.bundle_name = ""
end

function LingPaiItem:__delete()
	self.fight_text = nil
	self.fight_text2 = nil
	if self.attr_lst then
		for k,v in pairs(self.attr_list) do
			v:DeleteMe()
		end
	end
	self.attr_list = {}

	self.callback = nil
	self.grade = 0
	self.season = 0
	self.bundle_name = nil
end

function LingPaiItem:OnClickWearToggle()
	if self.callback then
		self.callback(self)
	end
end

function LingPaiItem:SetClickWearToggleCallBack(callback)
	self.callback = callback
end

function LingPaiItem:OnFlush()
	self.node_list["TxtSeason"].image:LoadSprite(ResPath.GetZhiZunLingPai("font_" .. self.index))

	--判断是否拥有该赛季的戒指
	self.grade = ZhiZunLingPaiData.Instance:GetCardIsHaveGrande(self.index)
	self.season = self.index

	-- local lingpai_res = ZhiZunLingPaiData.Instance:GetCardShowByIndex(self.index)
	-- local bundle, asset = ResPath.GetZhiZunLingPai(lingpai_res)
	-- self.node_list["JiezhiImg"].image:LoadSprite(bundle, asset)

	local cur_season = ZhiZunLingPaiData.Instance:GetCurSeason()
	local jingxingzhong = false
	local season_state = 0 				--赛季状态 1进行中 2未开启 3已结束
	local show_des = self.grade > 0 and true or false

	--判断该赛季的状态
	if self.season == cur_season then
		self.node_list["StateImg"].image:LoadSprite(ResPath.GetZhiZunLingPai("jinxingzhong"))
		season_state = 1
	elseif self.season < cur_season then
		self.node_list["StateImg"].image:LoadSprite(ResPath.GetZhiZunLingPai("yijieshu"))
		season_state = 3
	else
		self.node_list["StateImg"].image:LoadSprite(ResPath.GetZhiZunLingPai("weikaiqi"))
		season_state = 2
	end
	self.node_list["AttrListShow"]:SetActive(season_state == 1)
	local ring_show = ZhiZunLingPaiData.Instance:GetSeasonShowCfg(cur_season)
	if ring_show then
		self.node_list["QiXue"].text.text = ring_show.max_hp
		self.node_list["GongJi"].text.text = ring_show.gong_ji
		self.node_list["FangYu"].text.text = ring_show.fang_yu
		self.node_list["JianShang"].text.text = tostring(ring_show.reduce_hurt / 100) .. "%"
		self.node_list["ZengShang"].text.text = tostring(ring_show.add_hurt / 100) .. "%"

		self.node_list["AttrItemQiXue"]:SetActive(ring_show.max_hp > 0)
		self.node_list["AttrItemGongJi"]:SetActive(ring_show.gong_ji > 0)
		self.node_list["AttrItemFangYu"]:SetActive(ring_show.fang_yu > 0)
		self.node_list["AttrItemJianShang"]:SetActive(ring_show.reduce_hurt > 0)
		self.node_list["AttrItemZengShang"]:SetActive(ring_show.add_hurt > 0)
	end

	local bundle_name, asset_name = ResPath.GetLingPaiEffect(self.index)
	if self.bundle_name ~= bundle_name then
		self.node_list["Effect"]:ChangeAsset(bundle_name, asset_name)
		self.bundle_name = bundle_name
	end

	self.node_list["DesNode"]:SetActive(not show_des)
	self.node_list["AttrNode"]:SetActive(show_des)
	if show_des then
		local season_card_cfg = ZhiZunLingPaiData.Instance:GetSeasonCardItemCfg(self.season, self.grade)
		self.attr = CommonDataManager.GetAttributteNoUnderline(season_card_cfg)
		local capability = CommonDataManager.GetCapability(self.attr)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
		self.node_list["WearToggle"]:SetActive(true)
		self.node_list["Checkmark"]:SetActive(KuafuPVPData.Instance:GetIsWear(self.index))
	else
		self.node_list["DesText"].text.text = Language.ZhiZunLingPai["SeasonState" .. season_state]
		local season_ring_cfg = WangZheZhiJieData.Instance:GetSeasonShowCfg(cur_season)
		self.attr = CommonDataManager.GetAttributteNoUnderline(season_ring_cfg)
		local capability = CommonDataManager.GetCapability(self.attr)
		if self.fight_text2 and self.fight_text2.text then
			self.fight_text2.text.text = capability
		end
	end

	self.node_list["AttrListView"].scroller:ReloadData(0)

end

function LingPaiItem:GetNumberOfCells()
	return #ZhiZunLingPaiData.Instance:GetSeasonCardItemAttr(self.season, self.grade)
end

function LingPaiItem:CellRefreshDel(cellobj, index)
	local cell = self.attr_list[cellobj]
	local data = ZhiZunLingPaiData.Instance:GetSeasonCardItemAttr(self.season, self.grade)
	if cell == nil then
		cell = ZhiZunLingPaiAttrItem.New(cellobj.gameObject)
		self.attr_list[cellobj] = cell
	end
	cell:SetData(data[index + 1])
end

-----------------------------ZhiZunLingPaiAttrItem--------------------------
ZhiZunLingPaiAttrItem = ZhiZunLingPaiAttrItem or BaseClass(BaseCell)

function ZhiZunLingPaiAttrItem:__init()
end

function ZhiZunLingPaiAttrItem:__delete()

end

function ZhiZunLingPaiAttrItem:OnFlush()
	if self.data == nil then
		return
	end
	self:SetName(self.data.name)
	self:SetValue(self.data.value)
end

function ZhiZunLingPaiAttrItem:SetName(name)
	self.node_list["TxtName"].text.text = Language.Common.AttrName[name] .. "："
end

function ZhiZunLingPaiAttrItem:SetValue(value)
	self.node_list["TxtNum"].text.text = value
end