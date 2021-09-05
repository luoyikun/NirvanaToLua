LianXuChongZhi = LianXuChongZhi or BaseClass(BaseRender)

SLIDER_LENGTH = 778
local ITEM_COUNT = 4
function LianXuChongZhi:__init()
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["lianchongchu_zhanli"])

	self.node_list["show_yilingqu"]:SetActive(false)
	self.node_list["Effet"]:SetActive(false)
	self.node_list["show_lingqu"].button:AddClickListener(BindTool.Bind(self.OnClickLingQu, self))
	self.node_list["show_chongzhi"].button:AddClickListener(BindTool.Bind(self.OnClickChongZhi, self))
	self.isfoot = false
	self.cell_list = {}
	self.select_index = 1
	self:InitRewardList()
	self:InitSlider()	--下方条
	self:FlushModel()
end

function LianXuChongZhi:__delete()
	self:CancelCountDown()
	self.select_index = 1

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	for k,v in pairs(self.slider_cell_list) do
		v:DeleteMe()
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.fight_text = nil
	self.slider_cell_list = {}
end

function LianXuChongZhi:OpenCallBack()
	self:Flush()
end

function LianXuChongZhi:ReleaseCallBack()

end

function LianXuChongZhi:InitSlider()
	self.slider_cell_list = {}
	local zhongqiulianchong_cfg = KaifuActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if not zhongqiulianchong_cfg then
		return
	end

	local num = self:GetCfgNum() or 0
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	-- PrefabPool.Instance:Load(AssetID("uis/views/kaifuactivity/childpanel_prefab", "LianChong_Reward_Item"), function(prefab)
	res_async_loader:Load("uis/views/kaifuactivity/childpanel_prefab", "LianChong_Reward_Item", nil, function(prefab)
		if not prefab then
			return
		end

		for i = 1,num do
			local obj = ResMgr:Instantiate(prefab)
			obj.transform:SetParent(self.node_list["RewardList"].transform, false)
			obj.transform:SetLocalPosition(SLIDER_LENGTH / num * i, 0 ,0)
			obj = U3DObject(obj)
			local item = AutumnSliderCell.New(obj)
			local data_group = zhongqiulianchong_cfg[i]
			if not data_group then
				ResMgr:Destroy(prefab)
				return
			end

			item.parent_view = self
			if i < num then
				item:SetData(data_group.reward_item) --其他显示限时礼包
			else
				local data_id = data_group.reward_item.item_id or 0
				local data_list = ItemData.Instance:GetGiftItemList(data_id)
				-- if not data_list then
				-- 	PrefabPool.Instance:Free(prefab)
				-- 	return
				-- end

				item:SetData(data_list[1])	--最后的奖励显示礼包第一个  
			end

			item:SetIndex(i)
			self.slider_cell_list[i] = item
		end
		-- PrefabPool.Instance:Free(prefab)
		self:Flush()
	end)
end

function LianXuChongZhi:InitRewardList()
	self.cell_list = {}
	for i = 1, ITEM_COUNT do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["reward_" .. i])
		self.cell_list[i] = item
	end
	for i = 1, 4 do
		self.node_list["reward_" .. i]:SetActive(false)
	end
end

function LianXuChongZhi:SetSelectIndex(index)
	self.select_index = index
end

function LianXuChongZhi:GetSelectIndex()
	return self.select_index or 1
end

function LianXuChongZhi:FlushRewardView()
	local item_id_group = KaifuActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if not item_id_group then 
		return
	end

	local data_group = item_id_group[self.select_index]
	if not data_group or not data_group.reward_item then 
		return
	end

	local need_gold = data_group.need_chongzhi   --所需的充值数量
	local data_id = data_group.reward_item.item_id or 0
	local data_list = ItemData.Instance:GetGiftItemList(data_id)

	local index = 1
	for k,v in pairs(data_list)do
		if index > ITEM_COUNT then
			break
		end

		if v then
			self.cell_list[index]:SetData(v)
			index = index + 1
		end
	end

	for i = 1, 4 do
		self.node_list["reward_" .. i]:SetActive(index >= i)
	end

	local festival_data = KaifuActivityData.Instance

	--按钮更新
	if festival_data:GetCanFetchRewardFlagByIndex(self.select_index) == 0 then
		self.node_list["show_lingqu"]:SetActive(false)
		self.node_list["show_chongzhi"]:SetActive(true)
		self.node_list["show_yilingqu"]:SetActive(false)
	end

	if festival_data:GetCanFetchRewardFlagByIndex(self.select_index) == 1 then
		if festival_data:GetHasFetchRewardFlagByIndex(self.select_index) == 0 then  --未领取
			self.node_list["show_lingqu"]:SetActive(true)
			self.node_list["show_chongzhi"]:SetActive(false)
			self.node_list["show_yilingqu"]:SetActive(false)
		end
		if festival_data:GetHasFetchRewardFlagByIndex(self.select_index) == 1 then  --已经领取
			self.node_list["show_lingqu"]:SetActive(false)
			self.node_list["show_chongzhi"]:SetActive(false)
			self.node_list["show_yilingqu"]:SetActive(true)
		end
	end

	self.node_list["need_gold"].text.text = string.format("%s", need_gold)
end

function LianXuChongZhi:FlushAllHL()
	if not self.slider_cell_list then
		return
	end

	for i = 1, #self.slider_cell_list do
		self.slider_cell_list[i]:SetHightLight(self.select_index)
	end
end

function LianXuChongZhi:FlushSlider()
	if not self.slider_cell_list then
		return
	end

	local festival_data = KaifuActivityData.Instance
	local size = #self.slider_cell_list

	for i = 1, size do
		if festival_data:GetCanFetchRewardFlagByIndex(i) == 0 then
			if size == 1 then   --当第一个还没领取时不现实特效
				self.node_list["Effet"]:SetActive(false)
			else
				self.node_list["Effet"]:SetActive(true)
			end

			self.node_list["slider_num"].slider.value = (i - 1)/ size
			return
		elseif festival_data:GetCanFetchRewardFlagByIndex(i) == 1 and size == i then --当最后一个已经领取的时候
			self.node_list["slider_num"].slider.value = 1
			self.node_list["Effet"]:SetActive(true)
		end
	end
end

function LianXuChongZhi:OnFlush()

	local info_chu = KaifuActivityData.Instance:GetChongZhiZhongQiu()
	if nil ~= info_chu then
		self.node_list["today_coin_chu"].text.text = string.format(Language.Activity.LianXuChongZhiTodayCoinChu, info_chu.today_chongzhi)
	end

	local num = self:GetCfgNum() or 0

	for i = 1, num do
		if KaifuActivityData.Instance:GetHasFetchRewardFlagByIndex(i) == 0 then  --未领取
			self.select_index = i
			break
		end
	end

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	self:FlushRewardView()
	self:FlushAllHL()
	self:FlushSlider()
	self:FlushModel()
end

function LianXuChongZhi:FlushModel()
	local show_item_id, day_num, show_index = self:GetTeHuiItemChu()
	local item_cfg = ItemData.Instance:GetItemConfig(show_item_id)
	if item_cfg == nil then
		return
	end

	local name = item_cfg.name or ""
	local power = ResetDoubleChongzhiData.Instance:GetFightPower(item_cfg, show_item_id)
	-- local power = item_cfg.power or 0

	self.model:ChangeModelByItemId(show_item_id)
	local cfg = ItemData.Instance:GetItemConfig(show_item_id)

	if cfg and cfg.is_display_role == DISPLAY_TYPE.FOOTPRINT then
		self.model:SetInteger("status", 1)
	end
	self.node_list["TxtDay"].text.text = day_num
	self.node_list["TxtType"].text.text = Language.Activity.LianXuChongZhiType[show_index]
	self.node_list["lianchongchu_name"].text.text = name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
end

--获得配置数量
function LianXuChongZhi:GetCfgNum()
	local cfg = KaifuActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if not cfg then
		return 0
	end

	local get_cfg_num = #cfg or 0

	return get_cfg_num
end

function LianXuChongZhi:GetTeHuiItemChu()
	--local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if nil == cfg then
		return 0, 0, 0
	end

	local day_num = self:GetCfgNum() or 0
	if not cfg[day_num] then
		return 0, 0, 0
	end

	local show_index = cfg[day_num].show_index
	local item_id = cfg[day_num].res_id or 0

	return item_id, day_num, show_index 
	-- for k, v in pairs(cfg) do
	-- 	if open_server_day <= v.open_server_day then
	-- 		return v.show_item, v.show_type, v.model_name, v.power, v.show_day
	-- 	end
	-- end
end

function LianXuChongZhi:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["lianchongchu_day"].text.text = time_str

end

function LianXuChongZhi:CancelCountDown()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end

function LianXuChongZhi:OnClickLingQu()
	if KaifuActivityData.Instance:GetHasFetchRewardFlagByIndex(self.select_index) == 1 then 
		return
	end

	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.select_index)
end

function LianXuChongZhi:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------AutumnSliderCell----------------

AutumnSliderCell = AutumnSliderCell or BaseClass(BaseRender)

function AutumnSliderCell:__init()
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["reward_cell"])
	self.cell:SetIsShowTips(false)
	self.node_list["RewardItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function AutumnSliderCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.parent_view = nil
end

function AutumnSliderCell:SetHightLight(index)

	self.node_list["ImgHL"]:SetActive(self.index == index)
	self:Flush()
end

function AutumnSliderCell:SetData(data)
	self.cell:SetData(data)
	self:Flush()
	self.data = data
end

function AutumnSliderCell:SetIndex(index)
	self.index = index
	self.node_list["TxtNumber"].text.text = string.format(Language.Activity.LianXuChongZhiItemTime, index)
end

function AutumnSliderCell:OnFlush()
	local festival_data = KaifuActivityData.Instance

	if festival_data:GetCanFetchRewardFlagByIndex(self.index) == 0 then
		self.cell:ShowGetEffect(false)
		self.cell:ShowHasGet(false)
		self.cell:SetIconGrayVisible(false)
	end

	if festival_data:GetCanFetchRewardFlagByIndex(self.index) == 1 then
		if festival_data:GetHasFetchRewardFlagByIndex(self.index) == 0 then  --未领取
			self.cell:ShowGetEffect(true)
			self.cell:ShowHasGet(false)
			self.cell:SetIconGrayVisible(false)
			self.node_list["GetEffect"].gameObject:SetActive(true)
		end
		if festival_data:GetHasFetchRewardFlagByIndex(self.index) == 1 then  --已经领取
			self.cell:ShowGetEffect(false)
			self.cell:ShowHasGet(true)
			self.cell:SetIconGrayVisible(true)
			self.node_list["GetEffect"].gameObject:SetActive(false)
		end
	end
end

function AutumnSliderCell:OnClick()
	self:SetHightLight(self.index)
	self.cell:ShowHighLight(false)
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:FlushRewardView()
	self.parent_view:FlushAllHL()
end

-- function AutumnSliderCell:ShowHaseGet(is_show)
-- 	self.cell:SetIconGrayVisible(is_show)
-- 	self.cell:
-- end