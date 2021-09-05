HunYinResolve = HunYinResolve or BaseClass(BaseView)

local BAG_COLUMN = 6					-- 列数
local EFFECT_CD = 1

function HunYinResolve:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/hunqiview_prefab", "HunYinResolveContent",}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.effect_cd = 0
end

function HunYinResolve:__delete()
	
end

-- 创建完调用
function HunYinResolve:LoadCallBack()
	self.cell_count = 40
	self.node_list["TxtLingXing"].text.text = HunQiData.Instance:GetLingshuExp()

	self.check_list_obj = {}
	for i = 1, 4 do
		self.check_list_obj[i] = self.node_list["Check_" .. i]
		self.node_list["Check_" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.Click, self, i))
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnResolve"].button:AddClickListener(BindTool.Bind(self.ClickResolve, self))

	self.node_list["Txt"].text.text = Language.HunQi.TxtTitle4
	self.node_list["Bg"].rect.sizeDelta = Vector3(910, 580, 0)

	local page_simple_delegate = self.node_list["ListView"].list_simple_delegate
	page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	self.curren_click_cell_index = -1
	self.select_item_id = 0
	self.current_click_item_id = 0

	self.lingzhi_text_list = {}
	for i = 1,3 do
		local lingzhi_text_obj = self.node_list["lingzhi_text_" .. i]
		table.insert(self.lingzhi_text_list, lingzhi_text_obj)
	end

	self.select_all = {}
	self.cell_list = {}
	self.is_first_in = true
end

-- 销毁前调用
function HunYinResolve:ReleaseCallBack()
	self.curren_click_cell_index = -1
	self.lingzhi_text_list = {}
	self.check_list_obj = {}
	self.is_first_in = false
	self.select_all = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

-- 打开后调用
function HunYinResolve:OpenCallBack()
	self:FlushHunYinCellList()
	self:InitLingzhi()
	self:Flush()
end

function HunYinResolve:CloseCallBack()
	self.select_all = {}
	for color_index, check_node in pairs(self.check_list_obj) do
		check_node.toggle.isOn = false
	end
end

function HunYinResolve:FlushHunYinCellList()
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo() or {}
	self.item_id_list = {}
	for k,v in pairs(self.hunyin_info) do
		table.insert(self.item_id_list, k)
	end
	self:GetAllItemInfo(self.item_id_list)
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

function HunYinResolve:InitLingzhi()
	local lingzhi_info = ExchangeData.Instance:GetAllLingzhi()
	self.current_purple = lingzhi_info.purple
	self.current_blue = lingzhi_info.blue
	self.current_orange = lingzhi_info.orange
end

function HunYinResolve:FlushLingzhi()
	local lingzhi_info = ExchangeData.Instance:GetAllLingzhi()
	local lingzhi = 0
	local show_fly_text = true
	for k,v in pairs(self.lingzhi_text_list) do
		show_fly_text = true
		if k == 1 then
			if lingzhi_info.blue == self.current_blue then
				show_fly_text = false
			else
				lingzhi = lingzhi_info.blue - self.current_blue
				self.current_blue = lingzhi_info.blue
			end
		elseif k == 2 then
			if lingzhi_info.purple == self.current_purple then
				show_fly_text = false
			else
				lingzhi = lingzhi_info.purple - self.current_purple
				self.current_purple = lingzhi_info.purple
			end
		elseif k == 3 then
			if lingzhi_info.orange == self.current_orange then
				show_fly_text = false
			else
				lingzhi = lingzhi_info.orange - self.current_orange
				self.current_orange = lingzhi_info.orange
			end
		end
		if show_fly_text then
			self:ShowFlyText(v, lingzhi)
		end
	end
end

-- 刷新
function HunYinResolve:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "all" then
			self:FlushLingXingZhiInfo()
		end
		if k == "beibao" then
			self:FlushHunYinCellList()
			self:FlushLingXingZhiInfo()
			self:PlayAni()
		end
		if k == "lingzhi" then
			self:FlushLingzhi()
		end
	end
end

-- 获取背包中所有魂印配置信息
function HunYinResolve:GetAllItemInfo(item_id_list)
	self.all_hunyin_info = {}
	local item_data_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(item_data_list) do
		for k1, v1 in pairs(item_id_list) do
			if v.item_id == v1 then
				table.insert(self.all_hunyin_info, v)
			end
		end
	end

	table.sort(self.all_hunyin_info, function(a, b)
			return a.item_id < b.item_id
		end)
end

function HunYinResolve:NumberOfCellsDel()
	self.cell_count = math.ceil(#self.all_hunyin_info / BAG_COLUMN)
	if self.cell_count <= 4 then
		self.cell_count = 4
	end
	return self.cell_count
end

--格子每次进来刷新
function HunYinResolve:CellRefreshDel(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = HunYinResolveGroup.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	for i = 1, BAG_COLUMN do
		local index = data_index * BAG_COLUMN + i
		group_cell:SetGroupIndex(i, index)
		local current_data = self.all_hunyin_info[index]
		local item_cell = group_cell.item_list[i]
		group_cell:SetGroupData(i, current_data)
		if current_data then
			item_cell:SetInteractable(true)
			item_cell:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(current_data.item_id)))
			group_cell:SetClickCallBack(i, BindTool.Bind(self.OnClickItem, self, index, group_cell.item_list[i]))
		else
			item_cell:SetInteractable(false)
		end
		self:SetItemSelected(item_cell, nil ~= self.select_all[index])
	end
end

function HunYinResolve:OnClickItem(data_index, item_cell)
	local item_data = item_cell:GetData()
	if nil == item_data or nil == next(item_data) then
		return
	end

	local is_show = item_cell:IsHaseGet()
	self:SetItemSelected(item_cell, not is_show)

	if not is_show then
		self.select_all[data_index] = item_data
	else
		self.select_all[data_index] = nil
	end

	self:FlushLingXingZhiInfo()
end

function HunYinResolve:SetItemSelected(item_cell, is_select)
	if IsNil(item_cell.root_node.gameObject) then
		return
	end

	item_cell:SetToggle(false)
	item_cell:SetIconGrayVisible(is_select)
	item_cell:ShowHasGet(is_select)
	item_cell:ShowHighLight(false)
end

function HunYinResolve:Click(index)
	if self.check_list_obj[index].toggle.isOn then
		for k,v in pairs(self.all_hunyin_info) do
			local item_cfg = self.hunyin_info[v.item_id] and self.hunyin_info[v.item_id][1]
			if item_cfg and item_cfg.hunyin_color then
				if item_cfg.hunyin_color == index then
					self.select_all[k] = v
				end
			end
		end
	else
		for k, v in pairs(self.select_all) do
			if v.item_id and self.hunyin_info[v.item_id] and self.hunyin_info[v.item_id][1] then
				local item_cfg = self.hunyin_info[v.item_id][1]
				if item_cfg and item_cfg.hunyin_color then
					if item_cfg.hunyin_color == index then
						self.select_all[k] = nil
					end
				end
			end
			
		end
	end

	for k, v in pairs(self.cell_list) do
		for i = 1, BAG_COLUMN do
			local data_index = v:GetGroupIndex(i)
			self:SetItemSelected(v.item_list[i], nil ~= self.select_all[data_index])
		end
	end

	self:FlushLingXingZhiInfo()
end

function HunYinResolve:FlushLingXingZhiInfo()
	local add_exp = 0
	local add_blue_lingzhi = 0
	local add_purple_lingzhi = 0
	local add_orange_lingzhi = 0
	for k, v in pairs(self.select_all) do
		if v.item_id and self.hunyin_info[v.item_id] and self.hunyin_info[v.item_id][1] then
			local item_cfg = self.hunyin_info[v.item_id][1]
			if item_cfg then
				add_exp = add_exp + v.num * item_cfg.discard_exp
				add_blue_lingzhi = add_blue_lingzhi + v.num * item_cfg.blue_lingzhi
				add_purple_lingzhi = add_purple_lingzhi + v.num * item_cfg.purple_lingzhi
				add_orange_lingzhi = add_orange_lingzhi + v.num * item_cfg.orange_lingzhi
			end
		end
		
	end
	self:FlushLingXingZhi(add_exp, add_blue_lingzhi, add_purple_lingzhi, add_orange_lingzhi)
end

function HunYinResolve:FlushLingXingZhi(add_value, add_blue_lingzhi, add_purple_lingzhi, add_orange_lingzhi)
	add_value = add_value or 0
	local current_exp = HunQiData.Instance:GetLingshuExp()
	if 0 ~= add_value then
		self.node_list["TxtLingXing"].text.text = string.format(Language.HunQi.TxtLingXing, current_exp, add_value)
	else
		self.node_list["TxtLingXing"].text.text = current_exp
	end
end

--点击分解
function HunYinResolve:ClickResolve()
	local resolve_index_table = {}
	if self.select_all ~= {} then
		for k,v in pairs(self.select_all) do
			table.insert(resolve_index_table, v.index)
		end
	end
	local call_back = function()
		if #resolve_index_table > 0 then
			HunQiCtrl.Instance:SendHunYiResolveReq(#resolve_index_table, resolve_index_table)
			resolve_index_table = {}
		end
	end
	
	for k, v in pairs(self.cell_list) do
		for i = 1, BAG_COLUMN do
			v.item_list[i]:SetHighLight(false)
			local index = v:GetGroupIndex(i)
			if nil ~= self.select_all[index] then
				v:PlayEffect(i, call_back)
				--v:SetGroupActive(i, false)
				v:SetGroupData(i, nil)
			end
		end
	end
	for i = 1, 4 do
		self.node_list["Check_" .. i].toggle.isOn = false
	end
	self.select_all = {}
end

function HunYinResolve:CloseWindow()
	for k, v in pairs(self.cell_list) do
		for i = 1, BAG_COLUMN do
			v.item_list[i]:SetHighLight(false)
		end
	end
	self.select_all = {}
	self:Close()
end

function HunYinResolve:OnMoveEnd(obj)
	if not IsNil(obj) then
		ResPoolMgr:Release(obj)
	end
	self.node_list["TxtLingzhi2"].text.text = self.current_purple
	self.node_list["TxtLingzhi"].text.text = self.current_blue
	self.node_list["TxtLingzhi1"].text.text = self.current_orange
end

function HunYinResolve:ShowFlyText(begin_obj, value)
	ResPoolMgr:GetDynamicObjAsync("uis/views/hunqiview_prefab", "LingZhiText", function(obj)
		local name_table = obj:GetComponent(typeof(UINameTable))
		if name_table then
			local txt_obj = U3DObject(name_table:Find("LingZhiText"))
			txt_obj.text.text = "+" .. value
		end
		obj.transform:SetParent(begin_obj.transform, false)
		local tween = obj.transform:DOLocalMoveY(10, 1)
		tween:SetEase(DG.Tweening.Ease.Linear)
		tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
	end)
end

--播放分解成功特效
function HunYinResolve:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_yihuo_juji")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end


HunYinResolveGroup = HunYinResolveGroup or BaseClass(BaseRender)
function HunYinResolveGroup:__init()
	self.item_list = {}
	for i = 1, BAG_COLUMN do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["HunYinResolveFrame" .. i].gameObject)
	end
end

function HunYinResolveGroup:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function HunYinResolveGroup:SetGroupIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function HunYinResolveGroup:SetGroupData(i, data)
	self.item_list[i]:SetData(data)
end

function HunYinResolveGroup:SetClickCallBack(i, call_back)
	self.item_list[i]:ListenClick(call_back)
end

function HunYinResolveGroup:GetGroupIndex(i)
	return self.item_list[i]:GetIndex()
end

function HunYinResolveGroup:PlayEffect(i, call_back)
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_yihuofenjie")
	EffectManager.Instance:PlayAtTransform(
		bundle_name,
		asset_name,
		self.node_list["HunYinResolveFrame" .. i].transform,
		1, Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), Vector3(1, 1, 1), call_back)
end

function HunYinResolveGroup:SetGroupActive(i, is_show)
	self.item_list[i].root_node:SetActive(is_show)
end