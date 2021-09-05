local ROW = 10
local COLUMN = 5
local MAX_NUM = 50
local OFFTIME = 1

TipsGiftsRewardView = TipsGiftsRewardView or BaseClass(BaseView)

function TipsGiftsRewardView:__init()
	self.ui_config = {{"uis/views/tips/showgiftstips_prefab", "ShowGiftsTips"}}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.reward_state = false
end

function TipsGiftsRewardView:__delete()

end

function TipsGiftsRewardView:ReleaseCallBack()
	if self.play_quest_down then
		GlobalTimerQuest:CancelQuest(self.play_quest_down)
		self.play_quest_down = nil
	end

	for k, v in pairs(self.contain_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.contain_cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
	self.show_toggle_list = nil
	self.show_one_btn = nil
end

function TipsGiftsRewardView:SetData(items)
	self.data_list = {}
	self.data_list = items
end

function TipsGiftsRewardView:LoadCallBack()
	self.root_node:AddComponent(typeof(UnityEngine.CanvasGroup))
	self.contain_cell_list = {}
	self.node_list["BtnAffirm"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	-- self.node_list["BackWareHouseBtn"].button:AddClickListener(BindTool.Bind(self.OnBackWareHouseClick, self))
	-- self.node_list["BtnAgainBtn"].button:AddClickListener(BindTool.Bind(self.OnAgainClick, self))
	-- self.node_list["BtnOneBtn"].button:AddClickListener(BindTool.Bind(self.OneClick, self))

	self.show_toggle_list = {}
	for i = 1, 9 do
		self.show_toggle_list[i] = self.node_list["page_toggle_" .. i]
	end
	self:InitListView()
end

function TipsGiftsRewardView:CloseCallBack()
	self.show_toggle_list[1].toggle.isOn = true--重置toggle的显示
	if self.play_quest_down then
		GlobalTimerQuest:CancelQuest(self.play_quest_down)
		self.play_quest_down = nil
	end
	for k, v in pairs(self.contain_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.contain_cell_list = {}
end

function TipsGiftsRewardView:CloseView()
	self:Close()
	PackageData.Instance:SetNextRandGiftItem()
end

function TipsGiftsRewardView:InitListView()
	self.list_view = self.node_list["list_view"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsGiftsRewardView:GetNumberOfCells()
	local count = #self.data_list
	local show_count = 0
	if count <= 10 then
		show_count = 1
	elseif count > 10 and count <= 20 then
		show_count = 2
	elseif count > 20 and count <= 30 then
		show_count = 3
	elseif count > 30 and count <= 40 then
		show_count = 4
	elseif count > 40 and count <= 50 then
		show_count = 5
	elseif count > 50 and count <= 60 then
		show_count = 6
	elseif count > 60 and count <= 70 then
		show_count = 7
	elseif count > 70 and count <= 80 then
		show_count = 8
	elseif count > 80 and count <= 90 then
		show_count = 9
	end
	return show_count
end

function TipsGiftsRewardView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShowGiftsContain.New(cell.gameObject)
		contain_cell.parent_view = self
		self.contain_cell_list[cell] = contain_cell
	end

	--改变排列方式
	contain_cell:ChangeLayoutGroup()

	local page = cell_index + 1
	contain_cell:SetPage(page)
	for i = 1, ROW do
		local index = page * 10 - (ROW - i)
		local data = nil
		data = self.data_list[index] or {}
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if item_cfg and EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and item_cfg.color >= 5 then
			data.is_from_extreme = 3
		end
		contain_cell:SetToggleGroup(i, self.list_view.toggle_group)
		contain_cell:SetData(i, data)
		--contain_cell:ShowHighLight(i, next(data) ~= nil)
		contain_cell:ListenClick(i, BindTool.Bind(self.OnClickItem, self, contain_cell, i, index, data))
	end
end

function TipsGiftsRewardView:OnClickItem(group, group_index, index, data)
	self.current_grid_index = index
	group:SetToggle(group_index, index == self.current_grid_index)
	local close_call_back = function()
		group:SetToggle(group_index, false)
	end
	TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)
end

function TipsGiftsRewardView:OpenCallBack()
	for k,v in pairs(self.item_list) do
		v:SetParentActive(self.data_list[k-1] ~= nil)
		if self.data_list[k-1] then
			v:SetData(self.data_list[k-1])
		end
	end

	self.node_list["Reward"]:SetActive(self.reward_state)
	self.node_list["CanReward"]:SetActive(not self.reward_state)
end

function TipsGiftsRewardView:CheckToPlayAni()
	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end

	self.star_ani = false
	self.root_node.transform:Find("Root"):GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 0
	self.node_list["BtnAffirm"]:SetActive(false)
	-- self.node_list["BtnAgainBtn"]:SetActive(false)
	-- self.node_list["BtnOneBtn"]:SetActive(false)
	self.node_list["NodePageButtons"]:SetActive(false)
	self.node_list["NodeBlock"]:SetActive(true)
	-- --开始播放获取特效
	if self.play_quest_down == nil then
		self.play_quest_down = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.StartPlayEffect, self), 0.5)
	end
end

function TipsGiftsRewardView:OpenCallBack()
	-- self:ChangeBtnCount()
	-- self:SetTreasureType()
	self.node_list["page_toggle_1"]:SetActive(true)
	self.node_list["text_frame"].animator:SetBool("is_open", true)
	for i = 1, 9 do
		self.show_toggle_list[i]:SetActive(true)
	end
	local count = #self.data_list
	if count <= 10 then
		self:SetToggleActiveFalse(1,9)
	elseif count > 10 and count <= 20 then
		self:SetToggleActiveFalse(3,9)
	elseif count > 20 and count <= 30 then
		self:SetToggleActiveFalse(4,9)
	elseif count > 30 and count <= 40 then
		self:SetToggleActiveFalse(5,9)
	elseif count > 40 and count <= 50 then
		self:SetToggleActiveFalse(6,9)
	elseif count > 50 and count <= 60 then
		self:SetToggleActiveFalse(7,9)
	elseif count > 60 and count <= 70 then
		self:SetToggleActiveFalse(8,9)
	elseif count > 70 and count <= 80 then
		self:SetToggleActiveFalse(9,9)
	end
	self.list_view.scroller:ReloadData(0)

	self:CheckToPlayAni()
end

function TipsGiftsRewardView:SetToggleActiveFalse(first,the_end)
	local page = first - 1
	page = page < 1 and 1 or page
	self.page = page
	self.list_view.list_page_scroll:SetPageCount(page)
	for i=first,the_end do
		self.show_toggle_list[i]:SetActive(false)
	end
end

function TipsGiftsRewardView:GetPageCount()
	return self.page or 0
end

function TipsGiftsRewardView:LoadEffect(item_num, group_cell, obj)
	if not obj then
		return
	end
	if not group_cell or group_cell:IsNil() then
		ResMgr:Destroy(obj)
		return
	end
	local transform = obj.transform
	transform:SetParent(group_cell:GetTransForm(item_num), false)
	local function Free()
		if IsNil(obj) then
			return
		end
		ResMgr:Destroy(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end

function TipsGiftsRewardView:PlayTime(group_cell, count, elapse_time, total_time)
	if self.step >= count or elapse_time >= total_time then
		self.node_list["BtnAffirm"]:SetActive(not self.show_one_btn)
		-- self.node_list["BtnAgainBtn"]:SetActive(not self.show_one_btn)
		-- self.node_list["BtnOneBtn"]:SetActive(self.show_one_btn)
		self.node_list["NodePageButtons"]:SetActive(true)
		self.node_list["NodeBlock"]:SetActive(false)
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		return
	end
	self.step = self.step + 1

	local item_num = self.step

	local async_loader = AllocAsyncLoader(self, "step_loader_" .. self.step)
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
	async_loader:Load(bundle_name, 
		asset_name, 
		function(obj)
			if not IsNil(obj) then
				self:LoadEffect(item_num, group_cell, obj)
			end
		end)

	group_cell:SetAlpha(self.step, 1)
end

function TipsGiftsRewardView:StartPlayEffect()
	self.root_node.transform:Find("Root"):GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
	for k, v in pairs(self.contain_cell_list) do
		--只有第一页有动画
		if v:GetPage() == 1 and not v:IsNil() then
			--先隐藏item
			self.star_ani = true
			local count = #self.data_list
			count = count > 10 and 10 or count
			for i = 1, count do
				v:SetAlpha(i, 0)
			end
			--创建计时器分步显示item
			self.step = 0
			self.play_count_down = CountDown.Instance:AddCountDown(10, 0.05, BindTool.Bind(self.PlayTime, self, v, count))
		end
	end
	if not self.star_ani then
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		self.node_list["BtnAffirm"]:SetActive(not self.show_one_btn)
		-- self.node_list["BtnAgainBtn"]:SetActive(not self.show_one_btn)
		-- self.node_list["BtnOneBtn"]:SetActive(self.show_one_btn)
		self.node_list["NodePageButtons"]:SetActive(true)
		self.node_list["NodeBlock"]:SetActive(false)
	end
	self.play_quest_down = nil
end
----------------------------------------------------------
ShowGiftsContain = ShowGiftsContain  or BaseClass(BaseCell)

function ShowGiftsContain:__init()
	self.parent_view = nil
	self.treasure_contain_list = {}
	for i = 1, 10 do
		self.treasure_contain_list[i] = GiftsItemCell.New(self.node_list["item_" .. i])
	end
end

function ShowGiftsContain:__delete()
	self.parent_view = nil
	for k, v in pairs(self.treasure_contain_list) do
		v:DeleteMe()
	end
	self.treasure_contain_list = {}
end

function ShowGiftsContain:SetPage(page)
	self.page = page
end

function ShowGiftsContain:GetPage()
	return self.page
end

function ShowGiftsContain:SetToggleGroup(i, toggle_group)
	self.treasure_contain_list[i]:SetToggleGroup(toggle_group)
end

function ShowGiftsContain:SetData(i, data)
	self.treasure_contain_list[i]:SetData(data)
	if self.page == 1 then
		self.treasure_contain_list[i]:PlayEffect()
	end
end

function ShowGiftsContain:SetIsNeedShowEffect(is_need_show_effect)
	for k,v in pairs(self.treasure_contain_list) do
		v:SetIsNeedShowEffect(is_need_show_effect)
	end
end

function ShowGiftsContain:ListenClick(i, handler)
	if self.treasure_contain_list[i] then
		self.treasure_contain_list[i]:ListenClick(handler)
	end
end

function ShowGiftsContain:ShowHighLight(i, enable)
	if self.treasure_contain_list[i] then
		self.treasure_contain_list[i]:ShowHighLight(enable)
	end
end

function ShowGiftsContain:SetToggle(i, enable)
	if self.treasure_contain_list[i] then
		self.treasure_contain_list[i]:SetToggle(enable)
	end
end

function ShowGiftsContain:SetAlpha(i, value)
	if self.treasure_contain_list[i] then
		self.treasure_contain_list[i]:SetAlpha(value)
	end
end

function ShowGiftsContain:GetTransForm(i)
	if self.treasure_contain_list[i] then
		return self.treasure_contain_list[i]:GetTransForm()
	end
end

--改变排列方式
function ShowGiftsContain:ChangeLayoutGroup()
	if self.parent_view then
		local page_count = self.parent_view:GetPageCount()
		local enum = 0
		if page_count > 1 then
			enum = UnityEngine.TextAnchor.UpperLeft
		else
			enum = UnityEngine.TextAnchor.MiddleCenter
		end
		self.root_node.grid_layout_group.childAlignment = enum
	end
end

----------------------------------------------------------
GiftsItemCell = GiftsItemCell  or BaseClass(BaseRender)

function GiftsItemCell:__init()
	self.treasure_item = ItemCell.New()
	self.treasure_item:SetInstanceParent(self.node_list["item"])
	self.is_need_show_effect = true
end

function GiftsItemCell:PlayEffect()
	if self.is_need_show_effect then
		self.is_need_show_effect = false
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_Jinengshengji_1")
		EffectManager.Instance:PlayAtTransform(
			bundle_name,
			asset_name,
			self.node_list["item"].transform,
			OFFTIME, Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), Vector3(0.5, 0.5, 0.5))
	end
end

function GiftsItemCell:SetIsNeedShowEffect(is_need_show_effect)
	self.is_need_show_effect = is_need_show_effect
end

function GiftsItemCell:GetLocalPos(Obj)
	if Obj.transform ~= nil then
		return 
	end
end

function GiftsItemCell:__delete()
	if self.treasure_item then
		self.treasure_item:DeleteMe()
	end
	self.treasure_item = nil
	self.is_need_show_effect = true
end

function GiftsItemCell:SetToggleGroup(toggle_group)
	self.treasure_item:SetToggleGroup(toggle_group)
end

function GiftsItemCell:SetData(data)
	if not next(data) then
		self:SetActive(false)
	else
		self:SetActive(true)
	end

	self.node_list["ImgSwordBG"]:SetActive(false)
	self.node_list["ImgSword"]:SetActive(false)
	self.treasure_item:SetData(data)
end

function GiftsItemCell:ListenClick(handler)
	self.treasure_item:ListenClick(handler)
end

function GiftsItemCell:ShowHighLight(enable)
	self.treasure_item:ShowHighLight(enable)
end

function GiftsItemCell:SetToggle(enable)
	self.treasure_item:SetToggle(enable)
end

function GiftsItemCell:SetAlpha(value)
	if self.root_node.canvas_group then
		self.root_node.canvas_group.alpha = value
	end
end

function GiftsItemCell:IsNil()
	return not self.root_node or not self.root_node.gameObject.activeInHierarchy
end

function GiftsItemCell:GetTransForm()
	return self.root_node.transform
end
