BaoBaoAptitudeView = BaoBaoAptitudeView or BaseClass(BaseRender)

local MOVE_TIME = 0.5
function BaoBaoAptitudeView:UIsMove()
	UITween.MoveShowPanel(self.node_list["MountInfoZZ"] , Vector3(300 , -27 , 0 ) , MOVE_TIME )
end

function BaoBaoAptitudeView:__init(instance, mother_view)
	self.mother_view = mother_view
	self.node_list["BtnUpGradeZZ"].button:AddClickListener(BindTool.Bind(self.UpGradeClick, self))
	self.node_list["BtnReturn"].button:AddClickListener(BindTool.Bind(self.ReturnClick, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNumZZ"])
	self.stuff_list = {}
	for i = 1, 4 do
		self.stuff_list[i] = ItemCell.New()
		self.stuff_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end

    self.cell_list = {}
    self.list_view_delegate = self.node_list["AttrContentZZ"].list_simple_delegate
    self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function BaoBaoAptitudeView:__delete()
	for k,v in pairs(self.stuff_list) do
		v:DeleteMe()
	end
	self.stuff_list = {}

	for k,v in pairs(self.cell_list) do
        v:DeleteMe()
    end
    self.cell_list = {}
 
	self.mother_view = nil
	self.fight_text = nil
end

function BaoBaoAptitudeView:ReturnClick()
	self.mother_view:OpenZizhiClick(false)
end

function BaoBaoAptitudeView:UpGradeClick()
	local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if selected_baby_index then
		BaobaoCtrl.SendUpBabyReq(selected_baby_index - 1)
	end
end

function BaoBaoAptitudeView:GetNumberOfCells()
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return 0 end

	local level = 0
	if baby_info.level == 0 then
		level = 1
	else
		level = baby_info.level
	end
    local cur_attr = BaobaoData.Instance:GetBabyLevelAttribute(baby_info.baby_id, level)
    local count = 0
    for k,v in pairs(cur_attr) do 
    	if v > 0 then
    		count = count + 1
    	end
    end
    return count
end

function BaoBaoAptitudeView:RefreshView(cell,data_index)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end

	data_index = data_index +1 
    local attr_cell = self.cell_list[cell]
    if nil == attr_cell then
        attr_cell = BaobaoAttrCell.New(cell.gameObject)
        self.cell_list[cell] = attr_cell
    end
    local attribute = CommonStruct.Attribute()
    local cur_attr = BaobaoData.Instance:GetAptitudeCfg(baby_info.baby_id, baby_info.level)
    attr_cell:SetData(cur_attr[data_index])
end

function BaoBaoAptitudeView:OnFlush()
	self:FlushView()
end

function BaoBaoAptitudeView:FlushView()
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	local max_level = BaobaoData.Instance:GetMaxBabyUpleveCfgLength()
	if nil == baby_info then return end
	local next_level = baby_info.level >= max_level and max_level or baby_info.level + 1
	self.node_list["TxtCurLevel"].text.text = "Lv." .. baby_info.level
	local cur_attr = BaobaoData.Instance:GetBabyLevelAttribute(baby_info.baby_id, baby_info.level)
	local next_attr = BaobaoData.Instance:GetBabyLevelAttribute(baby_info.baby_id, next_level)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(cur_attr)
	end
	local stuff_data = BaobaoData.Instance:GetGridUpgradeStuffDataList() or {}
	self.node_list["TxtName"].text.text = ToColorStr(baby_info.baby_name, BAOBAO_COLOR[baby_info.baby_id + 1])
	for i = 1, 4 do
		if stuff_data[i - 1] then
			local data = stuff_data[i - 1]
			self.stuff_list[i]:SetData(data)
			local stuff_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
			local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
			local baby_index_info = BaobaoData.Instance:GetBabyInfo(selected_baby_index)
			if nil == baby_index_info then return end
			if baby_index_info.level >= max_level then
				self.node_list["Stuff" .. i].text.text = Language.Common.MaxLevelDesc
				UI:SetButtonEnabled(self.node_list["BtnUpGradeZZ"], false)
				self.node_list["TxtUpGrade"].text.text = string.format(Language.Marriage.UpGrade[2])
			else
				local color = stuff_num >= data.nedd_stuff_num and "#89F201FF" or "#ff0000" 
				self.node_list["Stuff" .. i].text.text = "<color=" .. color .. ">" .. stuff_num .. "</color>".." / ".. data.nedd_stuff_num
				UI:SetButtonEnabled(self.node_list["BtnUpGradeZZ"], true)
				self.node_list["TxtUpGrade"].text.text = string.format(Language.Marriage.UpGrade[1])
			end
		end
	end
	self.node_list["AttrContentZZ"].scroller:RefreshAndReloadActiveCellViews(true)
end

--------------------------------------------AttrCell---------------------------------------------------------------
BaobaoAttrCell = BaobaoAttrCell or BaseClass(BaseCell)

function BaobaoAttrCell:__init()
end

function BaobaoAttrCell:FlushAttr()
	self.node_list["CurAttr"].text.text = Language.Common.AttrName[self.data.name].."：".."<size=22>".."<color=".."#ffffff"..">"..self.data.cur_value.."</color>".."</size>"
    if self.data.next_value > 0 then
    	self.node_list["NextAttr"].text.text = "<size=22>"..self.data.next_value.."</size>"
   	end
   	--self.node_list["AttrIcon"].image:LoadSprite(ResPath.GetBaseAttrIcon(self.data.name))
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end

    local cur_level = baby_info.level
    self.node_list["NextIcon"]:SetActive(cur_level ~= BaobaoData.Instance:GetMaxBabyUpleveCfgLength())
end

function BaobaoAttrCell:OnFlush()
    self:FlushAttr()
end