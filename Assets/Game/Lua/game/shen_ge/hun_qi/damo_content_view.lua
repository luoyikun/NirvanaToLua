DaMoContentView = DaMoContentView or BaseClass(BaseRender)

local ItemCount = 3					--最大物品数量
local MaxAttrCount = 3				--最大属性条数
local MaxStarCount = 10				--最大星星数

local Attr_List = {"maxhp", "gongji", "fangyu"}

local LevelColorList = {
	[0] = "Green",
	[1] = "Green",
	[2] = "Blue",
	[3] = "Blue",
	[4] = "Purple",
	[5] = "Purple",
	[6] = "Orange",
	[7] = "Orange",
	[8] = "Red",
	[9] = "Red",
	[10] = "Red",
}

function DaMoContentView:__init()
	self.item_list = {}
	for i = 1, ItemCount do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["CellItem" .. i])
		table.insert(self.item_list, item_cell)
	end

	self.star_list = {}
	for i = 1, MaxStarCount do
		local star_res = self.node_list["ImgStar" .. i]
		table.insert(self.star_list, star_res)
	end

	self.attr_list = {}
	for i = 1, MaxAttrCount do
		local data = {}
		data.attr_name = self.node_list["TxtAttrName" .. i]
		data.up_value = self.node_list["TxtUpContent" .. i]
		table.insert(self.attr_list, data)
	end

	self.node_list["BtnIdentify"].button:AddClickListener(BindTool.Bind(self.ClickButton, self))
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.ClickExChange, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnRelics"].button:AddClickListener(BindTool.Bind(self.ClickRelicsBtn, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
end

function DaMoContentView:__delete()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.star_list = {}
	self.attr_list = {}
	self.fight_text = nil
end

function DaMoContentView:ClickButton()
	local not_num_count = 0
	for k, v in ipairs(self.item_list) do
		local data = v:GetData()
		local num = data.num or 0
		if num <= 0 then
			not_num_count = not_num_count + 1
		end
		if not_num_count >= ItemCount then
			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotMineralDes)
			return
		end
	end
	HunQiCtrl.Instance:SendOneKeyOperaReq()
end

function DaMoContentView:ClickExChange()
	local times = HunQiData.Instance:GetExChangeTimes()
	local exchange_list = HunQiData.Instance:GetExChangeCfg()
	if nil == exchange_list then
		return
	end
	local data = nil
	for k, v in ipairs(exchange_list) do
		if v.seq == times then
			data = v
			break
		end
	end
	if nil == data then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotExChangeTimeDes)
		return
	end
	ViewManager.Instance:Open(ViewName.DaMoExChangeTips)
end

function DaMoContentView:FlushExchangeAttr()
	local times = HunQiData.Instance:GetExChangeTimes()
	local exchange_list = HunQiData.Instance:GetExChangeCfg()
	if nil == exchange_list then
		return
	end

	local data = nil
	for k, v in ipairs(exchange_list) do
		if v.seq == times then
			data = v
			break
		end
	end
	local left_times = data and #exchange_list - data.seq or 0
	local color = data and TEXT_COLOR.WHITE or TEXT_COLOR.RED_4
	local consume_gold = data and data.consume_gold or 0
	local reward_exp = data and data.reward_exp or 0

	self.node_list["TxtShenKuiCount"].text.text = string.format(Language.HunQi.ShenKuiTime, color, left_times, #exchange_list)
	self.node_list["TxtGoldCost"].text.text = string.format(Language.HunQi.GoldCost, consume_gold)
	self.node_list["TxtAddEXP"].text.text = Language.HunQi.AddEXP .. reward_exp
end

function DaMoContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(166)
end

function DaMoContentView:ClickRelicsBtn()
	local  level  = PlayerData.Instance:GetRoleVo().level
	local skip_gather_level_limit = HunQiData.Instance:GetOtherCfg().skip_gather_level_limit
	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	if level >= skip_gather_level_limit and left_gather_times > 0 then
			GlobalTimerQuest:AddDelayTimer(function ()
				self:OnClickQuick()
			end, 0)
		return
	end

	local function ok_callback()
		ViewManager.Instance:Close(ViewName.HunQiView)
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	end

	local des = Language.HunQi.GoToAncientRelicsDes
	HunQiCtrl.Instance:ShowRelicTips(des, nil, ok_callback, Language.Common.Cancel, Language.Common.Confirm)
	ViewManager.Instance:Open(ViewName.TipsGoToRelicView)
end

function DaMoContentView:OnClickQuick()
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_SHENZHOU_WEAPON, -1)
	end

	local gather_callback = function ()
		ViewManager.Instance:Close(ViewName.HunQiView)
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	end

	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	local skip_gather_consume = HunQiData.Instance:GetOtherCfg().skip_gather_consume
	local gold = left_gather_times * skip_gather_consume

	local str = Language.HunQi.GoToAncientRelicsDes .. string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_SHENZHOU_WEAPON], gold, left_gather_times)
	--给小tips传值
	HunQiCtrl.Instance:ShowRelicTips(str, gather_callback,ok_callback ,Language.HunQi.GoToGather, Language.HunQi.QuickFinish)
	ViewManager.Instance:Open(ViewName.TipsGoToRelicView)
end


function DaMoContentView:ChangeStarLevel()
	local big_level = HunQiData.Instance:GetIdentifyLevel()
	local small_level = HunQiData.Instance:GetIdentifyStarLevel()

	for k, v in ipairs(self.star_list) do
		if k <= small_level then
			v.image:LoadSprite(ResPath.GetNewStarIcon(big_level + 1))
		else
			v.image:LoadSprite(ResPath.GetNewStarIcon(big_level))
		end
	end
end

function DaMoContentView:FlushAttr(is_init)
	local big_level = HunQiData.Instance:GetIdentifyLevel()
	local small_level = HunQiData.Instance:GetIdentifyStarLevel()

	--刷新遗迹采集次数
	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	local count_des = ToColorStr(left_gather_times, TEXT_COLOR.GREEN_4)
	if left_gather_times <= 0 then
		count_des = ToColorStr(left_gather_times, TEXT_COLOR.RED)
	end
	self.node_list["TxtRelicsIcon"].text.text = string.format(Language.HunQi.RelicsTime, count_des)

	--刷新右边的状态
	local attr_info = HunQiData.Instance:GetidentifyLevelInfo(big_level, small_level)
	if nil == attr_info then
		return
	end
	attr_info = attr_info[1]
	--刷新等级展示
	self.node_list["TxtKuiHuoLevel"].text.text = attr_info.name

	--刷新经验进度条
	local now_exp = HunQiData.Instance:GetNowExp()
	local need_exp = attr_info.need_exp
	local exp_value = now_exp / need_exp
	self.node_list["SliderExp"].slider.value = exp_value

	--激活进度条特效
	self.node_list["EffectHandle"]:SetActive(exp_value > 0)

	local pro_des = Language.Common.YiMan
	if now_exp < need_exp then
		pro_des = now_exp .. "/" .. need_exp
	end
	self.node_list["TxtExp"].text.text = pro_des

	--计算战斗力
	local capability = CommonDataManager.GetCapability(attr_info)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end

	--判断显示的属性个数
	local maxhp = attr_info.maxhp or 0
	local gongji = attr_info.gongji or 0
	local fangyu = attr_info.fangyu or 0

	local attr_count = 0
	if maxhp > 0 then
		attr_count = attr_count + 1
	end
	if gongji > 0 then
		attr_count = attr_count + 1
	end
	if fangyu > 0 then
		attr_count = attr_count + 1
	end
	if attr_count == 0 then
		attr_count = MaxAttrCount
	end
	self.node_list["NodeAttr1"]:SetActive(attr_count >= 1)
	self.node_list["NodeAttr2"]:SetActive(attr_count >= 2)
	self.node_list["NodeAttr3"]:SetActive(attr_count == 3)

	--获取下一级属性
	local next_big_level = 0
	local next_small_level = 0
	if small_level >= MaxStarCount then
		next_big_level = big_level + 1
	else
		next_big_level = big_level
		next_small_level = small_level + 1
	end

	local next_attr_info = HunQiData.Instance:GetidentifyLevelInfo(next_big_level, next_small_level)
	local show_up_attr = {}
	for i = 1, 3 do
		show_up_attr = self.node_list["NodeUpContent" .. i]
	end

	if nil == next_attr_info then
		show_up_attr:SetActive(false)
	else
		next_attr_info = next_attr_info[1]
		show_up_attr:SetActive(true)
	end

	--设置属性展示
	for i = 1, attr_count do
		local attr_data = self.attr_list[i]
		local attr_type = Attr_List[i]
		local name = Language.HunQi.AttrNameNoUnderDes[attr_type] or ""
		local now_attr = attr_info[attr_type]
		attr_data.attr_name.text.text = name .. "：" .. now_attr
		local next_attr = 0
		if nil ~= next_attr_info then
			next_attr = next_attr_info[attr_type]
		end
		up_attr = next_attr - now_attr
		attr_data.up_value.text.text = up_attr
	end
end

function DaMoContentView:FlushItemList()
	local item_data_list = HunQiData.Instance:GetIdentifyItemList()
	if nil == item_data_list then
		return
	end
	for k, v in ipairs(self.item_list) do
		local data = item_data_list[k]
		local item_id = data.consume_item_id
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		v:SetData({item_id = item_id, num = num})
		if num <= 0 then
			v:SetIconGrayScale(true)
			v:ShowQuality(false)
		else
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
		end
	end
end

function DaMoContentView:InitView()
	self:ChangeStarLevel()
	self:FlushAttr(true)
	self:FlushItemList()
	self:FlushExchangeAttr()
end

function DaMoContentView:FlushView()
	self:ChangeStarLevel()
	self:FlushAttr()
	self:FlushItemList()
	self:FlushExchangeAttr()
end