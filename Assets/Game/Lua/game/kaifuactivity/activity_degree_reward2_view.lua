DegreeRewardsView2 = DegreeRewardsView2 or BaseClass(BaseRender)

function DegreeRewardsView2:__init()
	self.degree_data = {}
	self.model_list = {}
	self.fight_text ={}
	self.cell_list = {}
	self.act_type = 1
	self.rank_type = 1
	self.current_grade = 0

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_INFO)
end

function DegreeRewardsView2:__delete()

	for k, v in pairs(self.model_list) do
		v:DeleteMe()
	end
	self.model_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for i = 1,3 do
		self.fight_text[i] = nil
	end
	self.fight_text = nil
end

function DegreeRewardsView2:OpenCallBack()
	self:FlushTextInfo()
	local list_delegate = self.node_list["RewardList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for i =1, 3 do
		if not self.model_list[i] then
			self.model_list[i] = RoleModel.New()
			self.model_list[i]:SetDisplay(self.node_list["Display"..i].ui3d_display)
		end
		self.fight_text[i] = CommonDataManager.FightPower(self, self.node_list["Txt_zhanli_" .. i])
	end

	self.node_list["Btn_ranking"].button:AddClickListener(BindTool.Bind(self.OpenRankView, self))
	self.node_list["BtnJinJie"].button:AddClickListener(BindTool.Bind(self.OpenJinJieView, self))

	self:SendRankListReq()
end

function DegreeRewardsView2:OnFlush()
	self:SetReMainTime()
	self:FlushRoleModelList()
	local list = KaifuActivityData.Instance:GetUpGradeReturnList2()
	if #list > 0 then
		for i = 1, #list do
			self.degree_data[i] = list[i]
		end
	end
	self.node_list["RewardList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function DegreeRewardsView2:FlushTextInfo()
	local upgrade_return_info = KaifuActivityData.Instance:GetUpGradeReturnInfo2()
	self.act_type = upgrade_return_info.act_type
	local info = {}
	if self.act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		info = MountData.Instance:GetMountInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		info = WingData.Instance:GetWingInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		info = FaBaoData.Instance:GetFaBaoInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		info = FashionData.Instance:GetWuQiInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		info = FootData.Instance:GetFootInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		info = HaloData.Instance:GetHaloInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		info = FashionData.Instance:GetFashionInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		info = FightMountData.Instance:GetFightMountInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		info = TouShiData.Instance:GetTouShiInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		info = MaskData.Instance:GetMaskInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		info = WaistData.Instance:GetYaoShiInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		info = QilinBiData.Instance:GetQilinBiInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		info = LingChongData.Instance:GetLingChongInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		info = LingGongData.Instance:GetLingGongInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		info = LingQiData.Instance:GetLingQiInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		info = ShengongData.Instance:GetInfoGrade()
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		info = ShenyiData.Instance:GetShenyiInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		info = FlyPetData.Instance:GetFlyPetInfo()
	elseif self.act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		info = WeiYanData.Instance:GetWeiYanInfo()						
	end
	if nil == info or next(info) == nil then
		return
	end
	self.current_grade = info.grade > 0 and  info.grade - 1 or 0
	self.node_list["Txt_CurLevel"].text.text = string.format(Language.Tips.Jie, self.current_grade)
end

function DegreeRewardsView2:OpenJinJieView()
	local index = 0
	if self.act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.mount_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.wing_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fabao_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.role_shenbing)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.foot_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fashion_jinjie)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)
	elseif self.act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_toushi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView,  TabIndex.appearance_mask)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView,  TabIndex.appearance_waist)
	elseif self.act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView,  TabIndex.appearance_qilinbi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView,  TabIndex.appearance_lingtong)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView,  TabIndex.appearance_linggong)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingqi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengong)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shenyi)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_flypet)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_weiyan)							
	end
end

function DegreeRewardsView2:SendRankListReq()
	if self.act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT
	elseif self.act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING
	elseif self.act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FABAO
	elseif self.act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG_WUQI
	elseif self.act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT
	elseif self.act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO
	elseif self.act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHIZHUANG
	elseif self.act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT
	elseif self.act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_TOUSHI)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_TOUSHI
	elseif self.act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK
	elseif self.act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_YAOSHI
	elseif self.act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_QILINBI)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_QILINBI
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGTONG)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGTONG
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI
	elseif self.act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLYPET
	elseif self.act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN)
		self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEIYAN						
	end
end

function DegreeRewardsView2:FlushRoleModelList()
	local list = {}
	list = RankData.Instance:GetRankList()
	local rank_type = RankData.Instance:GetRankType()
	if self.rank_type ~= rank_type then
		return
	end
	for i = 1, 3 do
		if list[i] ~= nil then
			self.model_list[i]:SetModelResInfo(list[i], nil, true, true, true, true)
			self.model_list[i].display:SetRotation(Vector3(0, 180, 0))
			self.node_list["Img_nopeople" .. i]:SetActive(false)
			self.node_list["Txt_name_" .. i]:SetActive(true)
			self.node_list["Txt_name_" .. i].text.text = list[i].user_name
			if self.fight_text[i] and self.fight_text[i].text then
				self.fight_text[i].text.text = list[i].rank_value
			end
		else
			self.model_list[i]:SetModelResInfo(nil)
			self.node_list["Img_nopeople" .. i]:SetActive(true)
			if self.fight_text[i] then
				self.fight_text[i]:SetActive(false)
			end
		end
	end
end

function DegreeRewardsView2:SetReMainTime()
	local sever_time_ta = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local sever_time = sever_time_ta.hour * 3600 + sever_time_ta.min * 60 + sever_time_ta.sec
	local diff_time = 24 * 3600 - sever_time
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 3)
			self.node_list["Txt_LastTime"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function DegreeRewardsView2:GetNumberOfCells()
	return #self.degree_data or 0
end

function DegreeRewardsView2:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.cell_list[cell]
	if reward_cell == nil then
		reward_cell = RewardsItem.New(cell.gameObject)
		reward_cell.parent_view = self
		self.cell_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.degree_data[data_index])
end

function DegreeRewardsView2:OpenRankView()
	if self.act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.MOUNT)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.WING)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.FABAO)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.SHENBING)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.FOOT)
	elseif self.act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.HALO)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.FASHION)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.FIGHT_MOUNT)
	elseif self.act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.TOUSHI)
	elseif self.act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.MASK)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.YAOSHI)
	elseif self.act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.QILINBI)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.LINGTONG)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.LINGGONG)
	elseif self.act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.LINGQI)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.SHENGONG)
	elseif self.act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.SHENYI)
	elseif self.act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.FLYPET)
	elseif self.act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		ViewManager.Instance:Open(ViewName.Ranking, RANK_TAB_TYPE.WEIYAN)							
	end
end

------------------------------------------------------------------
RewardsItem = RewardsItem or BaseClass(BaseCell)

function RewardsItem:__init()
	self.node_list["Btn_Get"].button:AddClickListener(BindTool.Bind(self.OnGetReward, self))
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.item:SetData(nil)
	
end

function RewardsItem:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	self.parent_view = nil
end

function RewardsItem:OnGetReward()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPLEVEL_RETURN_2, RA_JINJIE_RETURN_OPERA_TYPE.RA_JINJIE_RETURN_OPERA_TYPE_FETCH, self.data.seq)
end

function RewardsItem:OnFlush()
	if self.parent_view.act_type == nil then
		return
	end	
	self.node_list["Txt_need_levle"].text.text = string.format(Language.Activity.NeedGrade, Language.Activity.UpGradeReturnGrade[self.parent_view.act_type],self.data.need_grade)
	self.item:SetData(self.data.reward_item)
	if self.data and next(self.data) then
		if self.data.fetch_reward_flag == 1 then
			self.node_list["Txt_button"].text.text = Language.Activity.QuanMinYiLingQu
			self.node_list["Effect"]:SetActive(false)
			UI:SetGraphicGrey(self.node_list["Btn_Get"], true)
			UI:SetButtonEnabled(self.node_list["Btn_Get"], false)

		elseif self.data.fetch_reward_flag == 0 and self.parent_view.current_grade < self.data.need_grade then
			self.node_list["Txt_button"].text.text = Language.Activity.QuanMinLingQu
			self.node_list["Effect"]:SetActive(false)
			UI:SetGraphicGrey(self.node_list["Btn_Get"], true)
			UI:SetButtonEnabled(self.node_list["Btn_Get"], false)

		elseif self.data.fetch_reward_flag == 0 and self.parent_view.current_grade >= self.data.need_grade then
			self.node_list["Txt_button"].text.text = Language.Activity.QuanMinLingQu
			self.node_list["Effect"]:SetActive(true)
			UI:SetGraphicGrey(self.node_list["Btn_Get"], false)
			UI:SetButtonEnabled(self.node_list["Btn_Get"], true)
		end
		self.node_list["ImgHasGet"]:SetActive(self.data.fetch_reward_flag == 1)
		self.node_list["Btn_Get"]:SetActive(self.data.fetch_reward_flag ~= 1)
	end
end