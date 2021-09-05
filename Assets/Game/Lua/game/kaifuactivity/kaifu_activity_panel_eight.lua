KaifuActivityPanelEight = KaifuActivityPanelEight or BaseClass(BaseRender)
--BOSS猎手
local TOGGLE_NUM = 4
local MAX_REWARD_CELL = 4
local Max_BOSS_ITEM = 1

function KaifuActivityPanelEight:__init(instance)
	self.toggle_list = {}
	self.red_point_list = {}

	local toggle_obj_list = {
		self.node_list["ToggleXinShou"],
		self.node_list["ToggleJinJie"],
		self.node_list["ToggleRongYao"],
		self.node_list["ToggleWangZhe"],
	}

	local red_point_obj_list = {
		self.node_list["ImgXSRedPoint"],
		self.node_list["ImgJJRedPoint"],
		self.node_list["ImgRYRedPoint"],
		self.node_list["ImgWZRedPoint"],
	}

	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGetReward, self))

	for  i = 1, TOGGLE_NUM do
		self.toggle_list[i] = toggle_obj_list[i].toggle
		self.toggle_list[i]:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i))
		self.red_point_list[i] = red_point_obj_list[i]
	end

	self.reward_item_list = {}

	self.boss_item_cell = PanelEightListCell.New(self.node_list["CellBossItem"])

	self.boss_list = {}
	self.cur_index = 0
	self.is_initshowed = false

end

function KaifuActivityPanelEight:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.is_initshowed = false

	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	self.boss_list = {}
	self.cur_index = nil

	if self.boss_item_cell then
		self.boss_item_cell:DeleteMe()
		self.boss_item_cell = nil
	end
end

function KaifuActivityPanelEight:InitShow()
	self.reward_item_list = {
		ItemCell.New(),
		ItemCell.New(),
		ItemCell.New(),
		ItemCell.New(),
	}

	for i = 1, MAX_REWARD_CELL do
		self.reward_item_list[i]:SetInstanceParent(self.node_list["CellRewardItem" .. i])
	end

	self.toggle_list[1].isOn = true
	self:SetBossInfo(1)
end

function KaifuActivityPanelEight:OnClickToggle(index)
	self.cur_index = index - 1
	self:SetBossInfo(index)
end

function KaifuActivityPanelEight:SetBossInfo(index)
	local cfg_list = KaifuActivityData.Instance:GetShowBossList(index - 1)
	self.boss_item_cell:SetData(cfg_list)
	self.boss_list = KaifuActivityData.Instance:GetShowBossList(index - 1)

	for i = 1, 4 do
		self.boss_item_cell.node_list["BtnBossItem" .. i].button:AddClickListener(BindTool.Bind(self.OnClickBossItem, self, i))
	end
	
	self:SetGetRewardBtnState(index - 1)
	self:SetRewardItemData(index - 1)
	local reward_cfg = KaifuActivityData.Instance:GetShowBossList(index - 1, true) or {}
	self.node_list["TxtLiBaoType"].text.text = reward_cfg.title or ""
	self.node_list["TxtTitle"].text.text = reward_cfg.title or ""
end

function KaifuActivityPanelEight:OnClickBossItem(index)
	if not index then return end

	for k, v in pairs(self.boss_list) do
		if k == index then
			TipsCtrl.Instance:ShowBossInfoView(v.boss_id)
			return
		end
	end
end

function KaifuActivityPanelEight:SetRewardItemData(cur_index)
	local cur_index = cur_index or self.cur_index
	local reward_cfg = KaifuActivityData.Instance:GetShowBossList(cur_index, true) or {}
	local gift_list = ItemData.Instance:GetGiftItemList(reward_cfg.reward_item and reward_cfg.reward_item.item_id or 0)
	local count = 0

	if next(gift_list) then
		local is_destory_effect = true

		for k, v in pairs(gift_list) do
			if self.reward_item_list[k] then
				for _, v2 in pairs(reward_cfg.item_special or {}) do
					if v2.item_id == v.item_id then
						self.reward_item_list[k]:IsDestoryActivityEffect(false)
						self.reward_item_list[k]:SetActivityEffect()
						is_destory_effect = false
						break
					end
				end

				if is_destory_effect then
					self.reward_item_list[k]:IsDestoryActivityEffect(is_destory_effect)
					self.reward_item_list[k]:SetActivityEffect()
				end

				self.reward_item_list[k]:SetGiftItemId(reward_cfg.reward_item.item_id)
				self.reward_item_list[k]:SetActive(true)
				self.reward_item_list[k]:SetData(v)
				count = count + 1
			end
		end
	else
		for k, v in pairs(reward_cfg) do
			if k == "reward_item" then
				count = count + 1
				self.reward_item_list[count]:SetActive(true)
				self.reward_item_list[count]:SetData(v)
			end
		end
	end
	for i = count + 1, #self.reward_item_list do
		if self.reward_item_list[i] then
			self.reward_item_list[i]:SetActive(false)
		end
	end

	self.node_list["TxtLiBaoType"].text.text = reward_cfg.title
	self.node_list["TxtTitle"].text.text = reward_cfg.title
end

function KaifuActivityPanelEight:SetGetRewardBtnState(cur_index)
	local cur_index = cur_index or self.cur_index
	local flag = KaifuActivityData.Instance:GetShowBossList(cur_index).flag or -1
	UI:SetButtonEnabled(self.node_list["BtnGetReward"], flag ==2)
	self.node_list["EffectInBtn"]:SetActive(flag == 2)
	self.node_list["RewardTxt"].text.text = flag == 0 and Language.HefuActivity.YiLingQu or Language.HefuActivity.LingQu
end

function KaifuActivityPanelEight:OnClickGetReward()
	local cfg = KaifuActivityData.Instance:GetShowBossList(self.cur_index) or {}
	if cfg.flag and cfg.flag == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.temp_activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BOSS, cfg.seq)
		return
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

function KaifuActivityPanelEight:Flush(activity_type)
	if not KaifuActivityData.Instance:IsBossLieshouType(activity_type) then print_error("不是boss猎命类型", activity_type) return end

	if not self.is_initshowed then
		self:InitShow()
		self.is_initshowed = true
	end

	self.boss_list = KaifuActivityData.Instance:GetShowBossList(self.cur_index)

	for i = 0, 3 do
		local cfg = KaifuActivityData.Instance:GetShowBossList(i)
		local flag = cfg and cfg.flag or 0
		self.red_point_list[i + 1]:SetActive(flag == 2)
	end

	local toggle_index = self.boss_list.seq and (self.boss_list.seq + 1) or 1
	if self.toggle_list[toggle_index] then
		self.toggle_list[toggle_index].isOn = true
	end

	self:SetRewardItemData(self.cur_index)
	self:SetGetRewardBtnState(self.cur_index)

	self.temp_activity_type = activity_type
end


PanelEightListCell = PanelEightListCell or BaseClass(BaseRender)

function PanelEightListCell:__init(instance)
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
end

function PanelEightListCell:__delete()
	self.monster_cfg = {}
end

function PanelEightListCell:SetData(data_list)
	if not data_list then return end

	for k, v in pairs(data_list) do
		if type(v) == "table" then
			local cfg = self.monster_cfg[v.boss_id]
			if not cfg then print_error("没有此怪物配置  monster_id :", v.boss_id) return end
			local boss_cfg = KaifuActivityData.Instance:GetBossInfoById(v.boss_id)

			if cfg.headid > 0 then
				local asset,bundle = ResPath.GetBossIcon(cfg.headid)
				self.node_list["ImgBossIcon" .. k].image:LoadSprite(asset,bundle)
			end

			self.node_list["TxtName" .. k].text.text = cfg.name
			self.node_list["ImgHadKill" .. k]:SetActive(KaifuActivityData.Instance:BossIsKill(v.seq))
			UI:SetButtonEnabled(self.node_list["BtnBossItem" .. k],not KaifuActivityData.Instance:BossIsKill(v.seq))
		end
	end
end