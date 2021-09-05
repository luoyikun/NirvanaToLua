LianXuChongZhiGao = LianXuChongZhiGao or BaseClass(BaseRender)
--连充特惠高 panel13
-- 不同角色对应的摄像机问位置,1,2,3,4对应职业男剑，男琴，女双剑，女炮
local pos_cfg = {
	[1] = {position = Vector3(0, 1.22, 3.57), rotation = Vector3(0, 180, 0)}, 
	[2] = {position = Vector3(0, 1.30, 3.57), rotation = Vector3(0, 180, 0)},
	[3] = {position = Vector3(0, 1.13, 3.40), rotation = Vector3(0, 180, 0)},
	[4] = {position = Vector3(0, 1.00, 2.93), rotation = Vector3(0, 180, 0)},
}



function LianXuChongZhiGao:__init()
	self.data_list = {}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self:InitListView()
	self.node_list["BtnRechargePlus"].button:AddClickListener(BindTool.Bind(self.ClickChongZhi,self))

	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local opengao_start, opengao_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO)
	local opengao_time = opengao_end - TimeCtrl.Instance:GetServerTime()
	if nil ~= opengao_time then
		self:SetRestTimeGao(opengao_time)
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisplayLianChong"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	local main_role = Scene.Instance:GetMainRole()
	self.model:SetRoleResid(main_role:GetRoleResId())
	self:FlushModel()
end

function LianXuChongZhiGao:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self:RealseTimer()
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.fight_text = nil
	self.data_list = {}
end

function LianXuChongZhiGao:InitListView()
	local info_gao = KaifuActivityData.Instance:GetChongZhiGao()
	if nil ~= info_gao then
		self.node_list["TxtTotalDay"].text.text = info_gao.continue_chongzhi_days
		-- self.node_list["TxtHaveReCharge"].text.text = CommonDataManager.ConverMoney(info_gao.today_chongzhi or 0)
	end
	if self.model then
		self.model:ShowRest()
	end
end

function LianXuChongZhiGao:Flush()
	local info_gao = KaifuActivityData.Instance:GetChongZhiGao()
	if nil ~= info_gao then
		local str = string.format(Language.OutLine.TotalLoginDay, info_gao.continue_chongzhi_days) 
		RichTextUtil.ParseRichText(self.node_list["TxtTotalDay"].rich_text, str, 22)
		-- self.node_list["TxtTotalDay"].text.text = string.format(Language.Activity.TotalLoginDay, info_gao.continue_chongzhi_days)
		self.node_list["TxtHaveReCharge"].text.text = CommonDataManager.ConverMoney(info_gao.today_chongzhi or 0)
	end
end

function LianXuChongZhiGao:GetNumberOfCells()
	return #self.data_list
end

function LianXuChongZhiGao:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]

	if nil == shop_cell then
		shop_cell = ChongZhiItemCellGroup.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end

	local index = cell_index + 1
	local item_id_group = self.data_list
	local data = item_id_group[index]

	shop_cell:SetIndex(index)
	shop_cell:SetData(data)

end

function LianXuChongZhiGao:FlushView()
	self.data_list = KaifuActivityData.Instance:ChongZhiTeHuiGao() or {}
	self.list_view.scroller:ReloadData(0)
end

function LianXuChongZhiGao:ClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- function LianXuChongZhiGao:ChangeUICamPosition(role_type)
-- 	if nil ~= role_type then
-- 		self.node_list["ModelCam"].transform.localPosition = pos_cfg[role_type].position
-- 		self.node_list["ModelCam"].transform.eulerAngles = pos_cfg[role_type].rotation
-- 	end
-- end

function LianXuChongZhiGao:SetRestTimeGao(diff_time)
	if self.count_down_chu == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_chu ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_chu)
					self.count_down_chu = nil
				end
				return
			end
			local format_time = TimeUtil.Format2TableDHMS(left_time)
			local time_str = ""

			local time_str
			if format_time.day >= 1 then
				time_str = string.format(Language.Activity.ActivityTime8, format_time.day, format_time.hour)
			else
				time_str = string.format(Language.Activity.ActivityTime9, format_time.hour, format_time.min, format_time.s)
			end
			if self.node_list and self.node_list["TxtGaoTime"] and self.node_list["TxtGaoTime"].text then
				self.node_list["TxtGaoTime"].text.text = time_str
			end
		end

		diff_time_func(0, diff_time)
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function LianXuChongZhiGao:RealseTimer()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end

function LianXuChongZhiGao:FlushModel()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local show_item_gao, show_type_gao, model_name_gao, power_gao, show_day = self:GetTeHuiItemGao()
	if show_item_gao and show_type_gao and self.model then
		local show_item_list = Split(show_item_gao, ",")
		local show_item_type = Split(show_type_gao, ",")
		local show_type = 0
		local fight_power = 0
		local all_fight_power = 0
		self.model:ResetRotation()
		self.model:ShowRest()
		if nil ~= show_item_list and nil ~= show_item_type then
			for i,v in ipairs(show_item_type) do
			show_type = tonumber(v)
			ItemData.Instance:ModelSet(self.model, show_type, tonumber(show_item_list[i]), false)
			if tonumber(v) == FASHION_SHOW_TYPE.FOOT then
				self.isfoot = true
			end
			-- fight_power = ItemData.GetFightPower(tonumber(show_item_list[i]))
			-- all_fight_power = all_fight_power + fight_power
			end
		end
	end
	if self.node_list and self.node_list["TxtGaoName"] and self.node_list["TxtGaoName"].text then
		self.node_list["TxtGaoName"].text.text = model_name_gao or ""
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power_gao or 0
	end
end

function LianXuChongZhiGao:GetTeHuiItemGao()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiGao()

	if nil == cfg then
		return
	end

	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.show_type, v.model_name, v.power, v.show_day
		end
	end
end

-----------------------------ChongZhiItemCellGroup--------------------------
ChongZhiItemCellGroup = ChongZhiItemCellGroup or BaseClass(BaseRender)

function ChongZhiItemCellGroup:__init()
	self.cell_list = {}
	local cell = ChongZhitemCell.New(self.node_list["item"])
	table.insert(self.cell_list, cell)
end

function ChongZhiItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ChongZhiItemCellGroup:SetToggleGroup()

end

function ChongZhiItemCellGroup:SetData(data)
	self.cell_list[1]:SetData(data)
end

function ChongZhiItemCellGroup:SetIndex(index)
	self.cell_list[1]:SetIndex(index)
end

-----------------------------ChongZhitemCell--------------------------
ChongZhitemCell = ChongZhitemCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 3

function ChongZhitemCell:__init()
	self.node_list["BtnLingqu"].button:AddClickListener(BindTool.Bind(self.OnClickLingQu,self))
	self.node_list["BtnChongzhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi,self))
	
	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i] = ItemCell.New()
		self["item_cell_" .. i]:SetInstanceParent(self.node_list["picture_" .. i])
		self["item_cell_" .. i]:ShowHighLight(false)
	end
end

function ChongZhitemCell:__delete()
	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i]:DeleteMe()
	end
end

function ChongZhitemCell:OnClickLingQu()

	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.data.day_index)
end

function ChongZhitemCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ChongZhitemCell:OnFlush()
	local item_num = KaifuActivityData.Instance:GetChongZhiGao()
	local can_fetch_reward_flag = bit:d2b(item_num.can_fetch_reward_flag)
	local has_fetch_reward_falg = bit:d2b(item_num.has_fetch_reward_falg)
	
	if nil == item_num then
		return
	end
	if can_fetch_reward_flag[32 - self.data.day_index] == 0 then
		self.node_list["BtnLingqu"]:SetActive(false)
		self.node_list["BtnChongzhi"]:SetActive(true)
	end
	if can_fetch_reward_flag[32 - self.data.day_index] == 1 then
		if has_fetch_reward_falg[32 - self.data.day_index] == 0 then
			self.node_list["BtnLingqu"]:SetActive(true)
			self.node_list["BtnChongzhi"]:SetActive(false)
			self.node_list["TxtInBtnLingQu"].text.text = Language.Common.LingQu
			UI:SetButtonEnabled(self.node_list["BtnLingqu"],true)
			self.node_list["NodeEffect"]:SetActive(true)
		end
		if has_fetch_reward_falg[32 - self.data.day_index] == 1 then
			self.node_list["BtnLingqu"]:SetActive(true)
			self.node_list["BtnChongzhi"]:SetActive(false)
			self.node_list["TxtInBtnLingQu"].text.text = Language.Common.YiLingQu
			UI:SetButtonEnabled(self.node_list["BtnLingqu"],false)
			self.node_list["NodeEffect"]:SetActive(false)
			self.node_list["BtnLingqu"]:SetActive(not has_fetch_reward_falg[32 - self.data.day_index] == 1)
		end
	end
	self.node_list["IsFalg"]:SetActive(has_fetch_reward_falg[32 - self.data.day_index] == 1)
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime() or 0
	local max_time = math.ceil((openchu_end - openchu_start) / 3600 / 24)
	local flag = math.floor(openchu_time / 3600 / 24) <= (max_time - self.data.day_index)
	UI:SetButtonEnabled(self.node_list["BtnChongzhi"], flag)

	local item_group = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i]:SetData(item_group[i])
		self["item_cell_" .. i]:SetRedPoint(false)
	end
	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local tehuigao = KaifuActivityData.Instance:ChongZhiTeHuiGao()
	local need_chongzhi = 0
	for k, v in pairs(tehuigao) do
		if open_sever_day <= v.open_server_day then
			need_chongzhi = v.need_chongzhi
			break
		end
	end
	local time_str = string.format(Language.Activity.LianChongTeHuiChuItemTips, self.data.day_index, need_chongzhi)
	RichTextUtil.ParseRichText(self.node_list["TxtLoginDay"].rich_text, time_str, 20)
	-- self.node_list["TxtLoginDay"].text.text = 

end