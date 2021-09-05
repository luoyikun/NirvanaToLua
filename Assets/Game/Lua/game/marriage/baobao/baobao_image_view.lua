BaoBaoImageView = BaoBaoImageView or BaseClass(BaseRender)
local PageLeft = 1
local PageRight = 2
local MOTHER = 0
local FATHER = 1
local CELL_SIZE = 160
function BaoBaoImageView:__init(instance, mother_view)
	self.node_list["LeftButtonClick"].button:AddClickListener(BindTool.Bind(self.ChangePage, self , PageLeft))
	self.node_list["RightButtonClick"].button:AddClickListener(BindTool.Bind(self.ChangePage, self , PageRight))
	self.node_list["AbandonmentClick"].button:AddClickListener(BindTool.Bind(self.AbandonmentClick, self))
	self.select_res_id = 0
	self:InitScroller()
	self.selected_baby_index = 1
	self:FlushBaobaoModel()
end

function BaoBaoImageView:__delete()
	if self.baobao_model then
		self.baobao_model:DeleteMe()
		self.baobao_model = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

end
--初始化滚动条
function BaoBaoImageView:CloseCallBack()
	BaobaoData.Instance:SetSelectedBabyIndex(nil)
end


function BaoBaoImageView:AbandonmentClick()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end

	local function remove_baby()
		local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
		if selected_baby_index then
			BaobaoCtrl.SendRemoveBabyReq(selected_baby_index -1)
		end
	end

	TipsCtrl.Instance:ShowCommonTip(remove_baby, nil, Language.Marriage.BabyIsRemove, nil, nil, false)
end

--初始化滚动条
function BaoBaoImageView:InitScroller()
	self.cell_list = {}

	self.list_view_delegate = ListViewDelegate()
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/marriageview/baobao_prefab", "BaoBaoItem", nil , function (prefab)
		if nil == prefab then
			return
		end
		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
	self.node_list["Scroller"].scroller.scrollerScrolled = function ()
		self:ReSetBtnVisible()
	end
end

--滚动条数量
function BaoBaoImageView:GetNumberOfCells()
	return #BaobaoData.Instance:GetListBabyData()
end

--滚动条大小
function BaoBaoImageView:GetCellSize()
	return CELL_SIZE
end

--滚动条刷新
function BaoBaoImageView:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1

	if nil == self.cell_list[cell] then
		self.cell_list[cell] = BaoBaoScrollerItem.New(cell.gameObject)
		self.cell_list[cell].parent_view = self
	end

	local data_list = BaobaoData.Instance:GetListBabyData()
	if data_list[data_index] then
		self.cell_list[cell]:SetIndex(data_list[data_index].baby_index + 1)
		self.cell_list[cell]:SetData(data_list[data_index])
		self.cell_list[cell]:ShowHight(BaobaoData.Instance:GetSelectedBabyIndex())
	end
	return cell
end

--设置按钮是否可见
function BaoBaoImageView:ReSetBtnVisible()

	local position = self.node_list["Scroller"].scroller.ScrollPosition
	local disable_height = self.node_list["Scroller"].scroller.ScrollSize						--listview不可见的画布长度

	if disable_height < 10 then
		self.node_list["LeftButtonClick"]:SetActive(false)
		self.node_list["RightButtonClick"]:SetActive(false)
		return
	end
	self.node_list["LeftButtonClick"]:SetActive(true)
	self.node_list["RightButtonClick"]:SetActive(true)

	if position <= 0 then
		self.node_list["LeftButtonClick"]:SetActive(false)
	elseif disable_height - position <= 10 or position > disable_height then
		self.node_list["RightButtonClick"]:SetActive(true)
	end
end

function BaoBaoImageView:ChangePage(value)
	local position = self.node_list["Scroller"].scroller.ScrollPosition
	local disable_height = self.node_list["Scroller"].scroller.ScrollSize						--listview不可见的画布长度
	local visible_height = self.node_list["Scroller"].scroller.ScrollRectSize					--listview可见的画布长度
	self.node_list["LeftButtonClick"]:SetActive(true)
	self.node_list["RightButtonClick"]:SetActive(true)

	local temp_position = 0
	if value == PageLeft then
		temp_position = position - visible_height
		if temp_position < 0 then
			temp_position = 0
			self.node_list["LeftButtonClick"]:SetActive(false)
		end
	else
		temp_position = position + visible_height
		if temp_position > disable_height then
			temp_position = disable_height
			self.node_list["RightButtonClick"]:SetActive(false)
		end
	end

	local index = self.node_list["Scroller"].scroller:GetCellViewIndexAtPosition(temp_position)

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["Scroller"].scroller.snapTweenType
	local scrollerTweenTime = 0
	local scroll_complete = nil
	self.node_list["Scroller"].scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function BaoBaoImageView:FlushBaobaoModel(resid)
	if not self.baobao_model then
		self.baobao_model = RoleModel.New()
		self.baobao_model:SetDisplay(self.node_list["BaobaoDisplay"].ui3d_display)
	end

	if resid then
		if self.select_res_id ~= resid then
			self.select_res_id = resid
			self.baobao_model:SetMainAsset(ResPath.GetSpiritModel(resid))
			self.baobao_model:ResetRotation()
			self.baobao_model:SetRotation(Vector3(0, -30, 0))
		end
	end
end

function BaoBaoImageView:FlushView()
	self.node_list["Flag"]:SetActive(false)
	self.node_list["Level"]:SetActive(true)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end
	local baobao_num = #BaobaoData.Instance:GetListBabyData()
	if baobao_num ~= 0 then 
		local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
		if selected_baby_index == 1 then
			self.node_list["Scroller"].scroller:ReloadData(0)
		else
			self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end

    if self.hadremove then
    	local data = BaobaoData.Instance:GetAllBabyInfo()
			local index = 0
			for k,v in pairs(data) do
				if tonumber(v.baby_id)>=0 then
					index = v.baby_index + 1
					break
				end
			end
	    BaobaoData.Instance:SetSelectedBabyIndex(index)
	    self.hadremove = false
	end
    self.node_list["BaobaoDisplay"]:SetActive(true)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then
		self.node_list["Flag"]:SetActive(false)
		self.node_list["Level"]:SetActive(true)
		self.node_list["Name"].text.text = ""
		self.node_list["BaobaoDisplay"]:SetActive(false)
		return
	end

	local index = BaobaoData.Instance:GetSelectedBabyIndex()
	local baby_info_cfg = BaobaoData.Instance:GetBabyInfo(index)
	local baby_grade = baby_info_cfg.grade

    local daxie = CommonDataManager.GetDaXie(baby_grade)
    self.node_list["Level"].text.text = daxie..Language.Common.Jie

    if baby_grade >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	elseif baby_grade == 0 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(1)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(baby_grade)
	end

	self:FlushBaobaoModel(BaobaoData.BabyModel[baby_info.baby_id + 1] or BaobaoData.BabyModel[1])
	self.node_list["Name"].text.text = baby_info.baby_name
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local mother_name = vo.sex == MOTHER and vo.name or baby_info.lover_name
	local father_name = vo.sex == FATHER and vo.name or baby_info.lover_name
	self.node_list["MotherName"].text.text = string.format(Language.MarryBaoBao.MaMaName , mother_name)
	self.node_list["FatherName"].text.text = string.format(Language.MarryBaoBao.BaBaName , father_name)
end


--宝宝滚动条格子
BaoBaoScrollerItem = BaoBaoScrollerItem or BaseClass(BaseCell)
function BaoBaoScrollerItem:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.OnFlush, self)
	self.node_list["BaoBaoItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.node_list["Img_right_level"]:SetActive(true)
end

function BaoBaoScrollerItem:ClickItem()
	self.root_node.toggle.isOn = true
	local select_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if select_index == self.index then
		return
	end

	BaobaoData.Instance:SetSelectedBabyIndex(self.index)
	-- 重置当前记录的宝宝守护精灵等级Fag
	BaobaoCtrl.Instance:ResetValue()
	ViewManager.Instance:FlushView(ViewName.MarryBaby)
end

function BaoBaoScrollerItem:__delete()
	self.parent_view = nil

end

function BaoBaoScrollerItem:ShowHight(index)
	self.node_list["ShowHight"]:SetActive(self.index == index)
end

function BaoBaoScrollerItem:OnFlush()
	if not self.data then return end
	self.node_list["Name"].text.text = self.data.baby_name
	-- 刷新选中特效
	local select_index = BaobaoData.Instance:GetSelectedBabyIndex()

	local bundle, asset = ResPath.GetBabyIcon("baby_icon_" .. self.data.baby_id)
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
	local red = BaobaoData.Instance:SetBaobaoRedPoint(self.index)
	local cur_tab_index = BaobaoData.Instance:GetCurTabIndex()
	if cur_tab_index == TabIndex.marriage_baobao_guard then
		self.node_list["RedPoint"]:SetActive(red > 0)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end

	if cur_tab_index == TabIndex.marriage_baobao_att then
		local baby_info_cfg = BaobaoData.Instance:GetBabyInfo(self.index)
		if baby_info_cfg ~= nil then
			self.node_list["Txt_right_level"].text.text = baby_info_cfg.grade
		end
	elseif cur_tab_index == TabIndex.marriage_baobao_zizhi then
		local baby_info = BaobaoData.Instance:GetBabyInfoByIndex(self.index)
		if baby_info ~= nil then
			self.node_list["Txt_right_level"].text.text = baby_info.level
		end
	end

   if self.data.lover_name ~= BaobaoData.Instance:GetLoveID() then
   		self.node_list["ShowLihun"]:SetActive(true)
   	else
   		self.node_list["ShowLihun"]:SetActive(false)
   end
end
