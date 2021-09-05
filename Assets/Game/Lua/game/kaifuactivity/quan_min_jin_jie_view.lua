QuanMinJinJieView = QuanMinJinJieView or BaseClass(BaseRender)
-- 全民进阶

-- 最大
local MAX_NUM = 3

local OPEN_INDEX_LIST = {
	[0] = TabIndex.mount_jinjie,
	[1] = TabIndex.wing_jinjie,
	[2] = TabIndex.fashion_jinjie,
	[3] = TabIndex.role_shenbing,
	[4] = TabIndex.fabao_jinjie,
	[5] = TabIndex.foot_jinjie,
	[6] = TabIndex.halo_jinjie,
}

function QuanMinJinJieView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function QuanMinJinJieView:__delete()
	if self.contain_cell_list then
		for k , v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
	end
end

function QuanMinJinJieView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2200, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	-- self.reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)
	-- if self.reward_list == nil or next(self.reward_list) == nil then return end

	-- local grade = KaifuActivityData.Instance:GetQuanMinJinJieInfo().grade - 1
	-- grade = grade == -1 and 0 or grade

	-- local type_num = self.reward_list[1].cond1

	-- local call_back = function ()
	-- 	self.node_list["ImgType"]:SetActive(true)
	-- 	self.node_list["ImgType"].image:SetNativeSize()
	-- end
	-- local asset, bundle = ResPath.GetOpenGameActivityRes("jinjie_" .. type_num + 1)
	-- self.node_list["ImgType"].image:LoadSprite(asset, bundle, call_back)


	-- self.node_list["TxtProgress"].text.text = string.format(Language.Activity.QuanMinType, Language.Activity.JinJieTypeName[type_num])
	-- self.node_list["TxtGrade"].text.text = string.format(Language.Activity.QuanMinGrade, grade)

	-- self.node_list["BtnGoUpgrade"].button:AddClickListener(BindTool.Bind(self.GoToUpGrade,self))

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)
	self:Flush()
end

function QuanMinJinJieView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function QuanMinJinJieView:OnFlush()
	self.node_list["ScrollerListView"].scroller:RefreshActiveCellViews()
	-- local grade = KaifuActivityData.Instance:GetQuanMinJinJieInfo().grade - 1 or 0
	-- grade = grade == -1 and 0 or grade

	-- if self.reward_list == nil or next(self.reward_list) == nil then return end

	-- local type_num = self.reward_list[1].cond1

	-- self.node_list["TxtProgress"].text.text = string.format(Language.Activity.QuanMinType, Language.Activity.JinJieTypeName[type_num])
	-- self.node_list["TxtGrade"].text.text = string.format(Language.Activity.QuanMinGrade, grade)

	self.reward_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE)
	if self.reward_list == nil or next(self.reward_list) == nil then return end

	local grade = KaifuActivityData.Instance:GetQuanMinJinJieInfo().grade - 1 or 0
	grade = grade == -1 and 0 or grade

	local type_num = self.reward_list[1].cond1

	local call_back = function ()
		self.node_list["ImgType"]:SetActive(true)
		self.node_list["ImgType"].image:SetNativeSize()
	end
	local asset, bundle = ResPath.GetOpenGameActivityRes("jinjie_" .. type_num)
	self.node_list["ImgType"].image:LoadSprite(asset, bundle, call_back)


	self.node_list["TxtProgress"].text.text = string.format(Language.Activity.QuanMinType, Language.Activity.JinJieTypeName[type_num])
	self.node_list["TxtGrade"].text.text = string.format(Language.Activity.QuanMinGrade, grade)

	self.node_list["BtnGoUpgrade"].button:AddClickListener(BindTool.Bind(self.GoToUpGrade,self))
end

function QuanMinJinJieView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	
	if contain_cell == nil then
		contain_cell = QuanMinJinJieCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1

	local type_list = KaifuActivityData.Instance:SortList(2200)
	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[cell_index].seq, 2200)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[cell_index].seq, 2200)

	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(type_list[cell_index],is_get_reward,is_complete)
	contain_cell:Flush()
end

function QuanMinJinJieView:GetNumberOfCells()
	return #self.reward_list
end

function QuanMinJinJieView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" and k ~= "hour" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str
	if temp.day > 0 then
		str = string.format(Language.Activity.ActivityTime8, temp.day, temp.hour)
	else
		str = string.format(Language.Activity.ActivityTime9, temp.hour, temp.min,temp.s)
	end

	self.node_list["TxtActTime"].text.text = str
end

-- 前往进阶
function QuanMinJinJieView:GoToUpGrade()
	-- local type_num = self.reward_list[1].cond1
	-- ViewManager.Instance:Open(ViewName.Advance,OPEN_INDEX_LIST[type_num])
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day == 1 then
		ViewManager.Instance:Open(ViewName.Advance,TabIndex.mount_jinjie)
	elseif cur_day == 2 then
		ViewManager.Instance:Open(ViewName.Advance,TabIndex.fashion_jinjie)
	elseif cur_day == 3 then
		ViewManager.Instance:Open(ViewName.Advance,TabIndex.role_shenbing)
	elseif cur_day == 4 then
		ViewManager.Instance:Open(ViewName.AppearanceView,TabIndex.appearance_lingtong)
	elseif cur_day == 5 then
		ViewManager.Instance:Open(ViewName.Advance,TabIndex.fight_mount)
	elseif cur_day == 6 then
		ViewManager.Instance:Open(ViewName.AppearanceView,TabIndex.appearance_linggong)
	elseif cur_day == 7 then
		ViewManager.Instance:Open(ViewName.AppearanceView,TabIndex.appearance_lingqi)
	end
end

------------------------------QuanMinJinJieCell-------------------------------------
QuanMinJinJieCell = QuanMinJinJieCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 2

function QuanMinJinJieCell:__init()

	self.charge_value = 0
	self.is_get_reward = false
	self.is_complete = false
	self.item_cell_list = {}
	for i = 1, MAX_CELL_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["CellItem_" .. i])
	end
		self.node_list["ImgYiLingQu"]:SetActive(false)
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))

end

function QuanMinJinJieCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_obj_list = nil
end

function QuanMinJinJieCell:SetChargeValue(value)
	self.charge_value = value
end

function QuanMinJinJieCell:OnFlush()
	self.data = self:GetData()
	local type_num = self.data.cond1
	local grade_num = self.data.cond2

	local str = string.format(Language.Activity.QuanMinJinJie[type_num], grade_num)
	RichTextUtil.ParseRichText(self.node_list["TxtHead"].rich_text, str, 20)
	local item_id = self.data.reward_item[0].item_id
	local reward_list = ItemData.Instance:GetGiftItemList(item_id)

	if next(reward_list) then
		for i = 1, MAX_CELL_NUM do
			self.item_cell_list[i]:SetData(reward_list)
		end
	else
		for i = 1, MAX_CELL_NUM do
			if self.data.reward_item[i - 1] then
				self.item_cell_list[i]:SetActive(true)
				self.item_cell_list[i]:SetData(self.data.reward_item[i - 1])
			else
				self.item_cell_list[i]:SetActive(false)
			end
		end
	end

	self.node_list["TxtBtn"].text.text = Language.Activity.QuanMinLingQu

	if self.is_complete and self.is_get_reward then
		self.node_list["TxtBtn"].text.text = Language.Activity.QuanMinYiLingQu
		self.node_list["BtnGet"]:SetActive(false)
		self.node_list["ImgYiLingQu"]:SetActive(true)
	else
		self.node_list["ImgYiLingQu"]:SetActive(false)
		self.node_list["BtnGet"]:SetActive(true)
	end


	self.node_list["NodeEffect"]:SetActive(self.is_complete and not self.is_get_reward)
	UI:SetButtonEnabled(self.node_list["BtnGet"], self.is_complete and not self.is_get_reward)

end

function QuanMinJinJieCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_JIN_JIE, 1, self.data.seq)
end

function QuanMinJinJieCell:SetData(data, is_get_reward, is_complete)
	self.data = data
	self.is_get_reward = is_get_reward
	self.is_complete = is_complete
end