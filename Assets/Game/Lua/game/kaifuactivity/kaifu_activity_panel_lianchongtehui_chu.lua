LianXuChongZhiChu = LianXuChongZhiChu or BaseClass(BaseRender)
--连充特惠初 panel14

-- 不同角色对应的摄像机问位置,1,2,3,4对应职业男剑，男琴，女双剑，女炮
local pos_cfg = {
	[1] = {position = Vector3(0, 1.22, 3.57), rotation = Vector3(0, 180, 0)}, 
	[2] = {position = Vector3(0, 1.30, 3.57), rotation = Vector3(0, 180, 0)},
	[3] = {position = Vector3(0, 1.13, 3.40), rotation = Vector3(0, 180, 0)},
	[4] = {position = Vector3(0, 1.00, 2.93), rotation = Vector3(0, 180, 0)},
}
	-- local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
	-- local opengao_start, opengao_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO)
	-- local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	-- local opengao_time = opengao_end - TimeCtrl.Instance:GetServerTime()
	-- --有两个连充特惠初面板
	-- self:SetRestTimeChu(openchu_time)
	-- --连充 初、高
	-- self:SetRestTimeGao(opengao_time)

function LianXuChongZhiChu:__init()
	self:InitListView()
end

function LianXuChongZhiChu:__delete()
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

end

function LianXuChongZhiChu:InitListView()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	if nil ~= openchu_time then
		self:SetRestTimeChu(openchu_time)
	end

	local info_chu = KaifuActivityData.Instance:GetChongZhiChu()
	if nil ~= info_chu and info_chu.continue_chongzhi_day ~= nil then
		self.node_list["TxtTotalDay"].text.text = info_chu.continue_chongzhi_day
		-- self.node_list["TxtHaveReCharge"].text.text = CommonDataManager.ConverMoney(info_chu.today_chongzhi or 0)
	end

	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.OnClickRecharge,self))
		
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisplayLianChong"].ui3d_display,MODEL_CAMERA_TYPE.BASE)
	self:SetRoleDisPlay()
end
function LianXuChongZhiChu:OnClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function LianXuChongZhiChu:Flush()
	local info_chu = KaifuActivityData.Instance:GetChongZhiChu()
	if nil ~= info_chu then
		self.node_list["TxtTotalDay"].text.text =  info_chu.continue_chongzhi_days
		self.node_list["TxtHaveReCharge"].text.text = CommonDataManager.ConverMoney(info_chu.today_chongzhi or 0)
	end
	if self.model then
		self.model:ShowRest()
	end
end


function LianXuChongZhiChu:GetNumberOfCells()
	return #KaifuActivityData.Instance:ChongZhiTeHuiChu()
end

function LianXuChongZhiChu:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]

	if nil == shop_cell then
		shop_cell = ChongZhiItemCellGroupChu.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end

	local index = cell_index + 1
	local item_id_group = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	local data = item_id_group[index]
	shop_cell:SetIndex(index)
	shop_cell:SetData(data)
end

function LianXuChongZhiChu:FlushView()
	self.list_view.scroller:ReloadData(0)
end

-- 将角色职业类型传过来然后设定摄像机
-- function LianXuChongZhiChu:ChangeUICamPosition(role_type)
-- 	if nil ~= role_type then
-- 		self.node_list["ModelCam"].transform.localPosition = pos_cfg[role_type].position
-- 		self.node_list["ModelCam"].transform.eulerAngles = pos_cfg[role_type].rotation
-- 	end
-- end

function LianXuChongZhiChu:SetRestTimeChu(diff_time)
	local info_chu =  KaifuActivityData.Instance:GetChongZhiChu()
	if info_chu == nil then
		return
	end
	if self.count_down_chu == nil and info_chu.continue_chongzhi_days ~= nil then

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
			-- local str = string.format(Language.OutLine.TotalLoginDay, info_chu.continue_chongzhi_days)

			if format_time.day >= 1 then
				time_str = string.format(Language.Activity.ActivityTime8, format_time.day, format_time.hour)
			else
				time_str = string.format(Language.Activity.ActivityTime9, format_time.hour, format_time.min, format_time.s)
			end
			self.node_list["TxtChuTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end

end

function LianXuChongZhiChu:RealseTimer()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end

function LianXuChongZhiChu:GetTeHuiItemChu()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	if nil == cfg then
		return
	end

	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.model_name, v.power
		end
	end
end


function LianXuChongZhiChu:SetRoleDisPlay()
	local model_item_id, show_type_gao, model_name_chu, power_chu, show_day = self:GetTeHuiItemChu()
	local cfg = ItemData.Instance:GetItemConfig(model_item_id)
	if cfg == nil then
		return
	end

	self.model:ResetRotation()
	ItemData.ChangeModel(self.model, model_item_id)
	local fight_power = ItemData.GetFightPower(model_item_id)
	self.node_list["TxtChuName"].text.text = model_name_chu
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power_chu
	end
	-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- local wuqi_1 = 0
	-- local wuqi_2 = 0
	-- local base_prof = main_role_vo.prof % 10

	-- if main_role_vo.sex == 0 then
	-- 	if base_prof == 3 then
	-- 		self.shizhuang = 1003000
	-- 	elseif base_prof == 4 then
	-- 		self.shizhuang = 1004000
	-- 	end
	-- elseif main_role_vo.sex == 1 then
	-- 	if base_prof == 1 then
	-- 		self.shizhuang = 1101000
	-- 	elseif base_prof == 2 then
	-- 		self.shizhuang = 1102000
	-- 	end
	-- end

	-- if base_prof == 1 then
	-- 	wuqi_1 = 900100001
	-- elseif base_prof == 2 then
	-- 	wuqi_1 = 910100001
	-- elseif base_prof == 3 then
	-- 	wuqi_1 = 920100001
	-- 	wuqi_2 = 920100002
	-- elseif base_prof == 4 then
	-- 	wuqi_1 = 930100101
	-- end

	-- --self:ChangeUICamPosition(base_prof)

	-- local main_role = Scene.Instance:GetMainRole()
	-- local tehui_item_chu, model_name_chu, power_chu = self:GetTeHuiItemChu()
	-- local res_id = 0
	-- local wuqi_id_1 = 0
	-- local wuqi_id_2 = 0
	-- if nil ~= tehui_item_chu then
	-- 	self.model:SetRoleResid(main_role:GetRoleResId())
	-- 	self.model:SetHaloResid(tehui_item_chu)
	-- 	self.node_list["TxtChuName"].text.text = model_name_chu
	-- 	self.node_list["TxtFightPower"].text.text = power_chu
	-- end

end


function LianXuChongZhiChu:GetTeHuiItemChu()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	if nil == cfg then
		return
	end
	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.show_type, v.model_name, v.power, v.show_day
		end
	end

end




-----------------------------ChongZhiItemCellGroupChu--------------------------
ChongZhiItemCellGroupChu = ChongZhiItemCellGroupChu or BaseClass(BaseRender)

function ChongZhiItemCellGroupChu:__init()
	self.cell_list = {}
	local cell = ChongZhitemCellChu.New(self.node_list["item"])
	table.insert(self.cell_list, cell)
end

function ChongZhiItemCellGroupChu:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ChongZhiItemCellGroupChu:SetToggleGroup()

end

function ChongZhiItemCellGroupChu:SetData(data)
	self.cell_list[1]:SetData(data)
end

function ChongZhiItemCellGroupChu:SetIndex(index)
	self.cell_list[1]:SetIndex(index)
end

-----------------------------ChongZhitemCellChu--------------------------
ChongZhitemCellChu = ChongZhitemCellChu or BaseClass(BaseCell)

local MAX_CELL_NUM = 3

function ChongZhitemCellChu:__init()
	self.node_list["BtnLingqu"].button:AddClickListener(BindTool.Bind(self.OnClickLingQu,self))
	self.node_list["BtnChongzhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi,self))

	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i] = ItemCell.New()
		self["item_cell_" .. i]:SetInstanceParent(self.node_list["picture_" .. i])
		self["item_cell_" .. i]:ShowHighLight(false)
	end
end

function ChongZhitemCellChu:__delete()
	for i = 1, MAX_CELL_NUM do
		self["item_cell_" .. i]:DeleteMe()
	end
end

function ChongZhitemCellChu:OnClickLingQu()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.data.day_index)
end

function ChongZhitemCellChu:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ChongZhitemCellChu:OnFlush()
	local item_num = KaifuActivityData.Instance:GetChongZhiChu()
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
			self.node_list["NodeEffect"]:SetActive(true)
			UI:SetButtonEnabled(self.node_list["BtnLingqu"],true)
		end
		
		if has_fetch_reward_falg[32 - self.data.day_index] == 1 then
			self.node_list["BtnLingqu"]:SetActive(true)
			self.node_list["BtnChongzhi"]:SetActive(false)
			self.node_list["TxtInBtnLingQu"].text.text = Language.Common.YiLingQu
			-- self.node_list["IsFalg"]:SetActive(true)
			self.node_list["NodeEffect"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["BtnLingqu"],false)
			self.node_list["BtnLingqu"]:SetActive(not has_fetch_reward_falg[32 - self.data.day_index] == 1)
		end
	end
	self.node_list["IsFalg"]:SetActive(has_fetch_reward_falg[32 - self.data.day_index] == 1)
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
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
	local tehuigao = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	local need_chongzhi = 0
	for k, v in pairs(tehuigao) do
		if open_sever_day <= v.open_server_day then
			need_chongzhi = v.need_chongzhi
			break
		end
	end

-- string.format(Language.Activity.LianChongTeHuiChuItemTips, self.data.day_index, need_chongzhi)

	local str = string.format(Language.OutLine.LianChongTeHuiChuItemTips,self.data.day_index, need_chongzhi)
	RichTextUtil.ParseRichText(self.node_list["TxtLoginDay"].rich_text, str, 20)
	self.node_list["TxtLoginDay"].text.text = ""
end