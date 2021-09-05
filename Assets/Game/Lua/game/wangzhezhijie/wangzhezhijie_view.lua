WangZheZhiJieView = WangZheZhiJieView or BaseClass(BaseView)

function WangZheZhiJieView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/wangzhezhijie_prefab","WangZheZhiJie"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
	}
	self.play_audio = true
	self.hide = false
	self.is_modal = true
end

function WangZheZhiJieView:__delete()
end

function WangZheZhiJieView:LoadCallBack()
	self.jiezhi_list = {}
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["TitleText"].text.text = Language.Kuafu1V1.WangZhe
	local list_delegate = self.node_list["JieZhiListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
end

function WangZheZhiJieView:ReleaseCallBack()
	if self.jiezhi_list then
		for k,v in pairs(self.jiezhi_list) do
			v:DeleteMe()
		end
	end
	self.jiezhi_list = {}

end

function WangZheZhiJieView:OpenCallBack()

end

function WangZheZhiJieView:CloseCallBack()

end

function WangZheZhiJieView:OnFlush(param_list)
	for k, v in pairs(self.jiezhi_list) do
		v:Flush()
	end
end

function WangZheZhiJieView:OnClickClose()
	self:Close()
end

function WangZheZhiJieView:GetNumberOfCells()
	return WangZheZhiJieData.Instance:GetRingShowCount()
end

function WangZheZhiJieView:CellRefreshDel(cellobj,index)
	local cell = self.jiezhi_list[cellobj]
	if cell == nil then
		cell = JieZhiItem.New(cellobj.gameObject)
		self.jiezhi_list[cellobj] = cell
	end
	cell:SetIndex(index + 1)
	cell:SetClickWearToggleCallBack(BindTool.Bind(self.OnClickWearToggle,self))
	cell:Flush()
end

function WangZheZhiJieView:OnClickWearToggle(cell)
	local flag = cell.is_wear
	local oper_type = nil
	if flag then
		oper_type = CROSS_RING_CARD_OPER_TYPE.CROSS_RING_CARD_OPER_OFF
	else
		oper_type = CROSS_RING_CARD_OPER_TYPE.CROSS_RING_CARD_OPER_WEAR
	end

	local season_ring_cfg = WangZheZhiJieData.Instance:GetSeasonRingItemCfg(cell.season,cell.grade)
	WangZheZhiJieCtrl.Instance:SendCrossMatch1V1Req(oper_type,season_ring_cfg.seq)
end

-------------------------JieZhiItem----------------------------
JieZhiItem = JieZhiItem or BaseClass(BaseCell)

function JieZhiItem:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLiNum"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	self.attr_list = {}
	self.attr = {}
	self.season = 0
	self.grade = 0

	self.node_list["WearToggle"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClickWearToggle, self))

	local list_delegate = self.node_list["AttrListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
	self.is_wear = false
	self.bundle_name = ""
end

function JieZhiItem:__delete()

	self.fight_text = nil

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
	self.fight_text2 = nil
end

function JieZhiItem:OnClickWearToggle()
	if self.callback then
		self.callback(self)
	end
end

function JieZhiItem:SetClickWearToggleCallBack(callback)
	self.callback = callback
end

function JieZhiItem:OnFlush()
	self.node_list["TxtSeason"].image:LoadSprite(ResPath.GetZhiZunLingPai("font_" .. self.index))

	--判断是否拥有该赛季的戒指
	self.grade = WangZheZhiJieData.Instance:GetRingIsHaveGrande(self.index)
	self.season = self.index

	-- local jiezhi_res = WangZheZhiJieData.Instance:GetRingShowByIndex(self.index)
	-- local bundle, asset = ResPath.GetWangZheZhiJie(jiezhi_res)
	-- self.node_list["JiezhiImg"].image:LoadSprite(bundle, asset)

	local cur_season = WangZheZhiJieData.Instance:GetCurSeason()
	local jingxingzhong = false
	local season_state = 0 				--赛季状态 1进行中 2未开启 3已结束
	local show_des = self.grade > 0 and true or false

	--判断该赛季的状态
	if self.season == cur_season then
		self.node_list["StateImg"].image:LoadSprite(ResPath.GetWangZheZhiJie("jinxingzhong"))
		season_state = 1
	elseif self.season < cur_season then
		self.node_list["StateImg"].image:LoadSprite(ResPath.GetWangZheZhiJie("yijieshu"))
		season_state = 3
	else
		self.node_list["StateImg"].image:LoadSprite(ResPath.GetWangZheZhiJie("weikaiqi"))
		season_state = 2
	end

	self.node_list["AttrListShow"]:SetActive(season_state == 1)
	local ring_show = WangZheZhiJieData.Instance:GetSeasonShowCfg(cur_season)
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
	local bundle_name, asset_name = ResPath.GetWangZheZhiJieEffect(self.index)
	if self.bundle_name ~= bundle_name then
		self.node_list["Effect"]:ChangeAsset(bundle_name, asset_name)
		self.bundle_name = bundle_name
	end

	self.node_list["DesNode"]:SetActive(not show_des)
	self.node_list["AttrNode"]:SetActive(show_des)
	if show_des then
		local season_ring_cfg = WangZheZhiJieData.Instance:GetSeasonRingItemCfg(self.season,self.grade)
		self.attr = CommonDataManager.GetAttributteNoUnderline(season_ring_cfg)
		local capability = CommonDataManager.GetCapability(self.attr)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
		self.node_list["WearToggle"]:SetActive(true)
		self.node_list["Checkmark"]:SetActive(WangZheZhiJieData.Instance:GetUseRingBySeason(self.season))
		self.is_wear = WangZheZhiJieData.Instance:GetUseRingBySeason(self.season)
	else
		self.node_list["DesText"].text.text = Language.WangZheZhiJie["SeasonState"..season_state]
		local season_ring_cfg = WangZheZhiJieData.Instance:GetSeasonShowCfg(cur_season)
		self.attr = CommonDataManager.GetAttributteNoUnderline(season_ring_cfg)
		local capability = CommonDataManager.GetCapability(self.attr)
		if self.fight_text2 and self.fight_text2.text then
			self.fight_text2.text.text = capability
		end
	end

 	self.node_list["AttrListView"].scroller:ReloadData(0)

end

function JieZhiItem:GetNumberOfCells()
	return #WangZheZhiJieData.Instance:GetSeasonRingItemAttr(self.season,self.grade)
end

 function JieZhiItem:CellRefreshDel(cellobj, index)
 	local cell = self.attr_list[cellobj]
 	local data = WangZheZhiJieData.Instance:GetSeasonRingItemAttr(self.season,self.grade)
 	if cell == nil then
 		cell = WangZheAttrItem.New(cellobj.gameObject)
 		self.attr_list[cellobj] = cell
 	end
 	cell:SetData(data[index+1])
 end

-----------------------------WangZheAttrItem--------------------------
WangZheAttrItem = WangZheAttrItem or BaseClass(BaseCell)

function WangZheAttrItem:__init()
end

function WangZheAttrItem:__delete()

end

 function WangZheAttrItem:OnFlush()
 	self:SetName(self.data.name)
 	self:SetValue(self.data.value)
 end

 function WangZheAttrItem:SetName(name)
 	self.node_list["TxtName"].text.text = Language.Common.AttrName[name] .. "："
 end

 function WangZheAttrItem:SetValue(value)
 	self.node_list["TxtNum"].text.text = value
 end