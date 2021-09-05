ArenaTupoView = ArenaTupoView or BaseClass(BaseRender)
local TUPO_NUM = 10
local TWEEN_TIME = 0.5
function ArenaTupoView:__init()
	self.tupo_item_list = {}
	self.node_list["Btn_tupo"].button:AddClickListener(BindTool.Bind(self.OnUpGrade, self))
	
	for i = 1, TUPO_NUM do
		self.tupo_item_list[i] = ArenaTupoIcon.New(self.node_list["Item_tupo_" .. i])
		self.tupo_item_list[i]:SetIndex(i)
	end

	-- self.item = ItemCell.New()
	-- self.item:SetInstanceParent(self.node_list["Item_reward"])

	self.now_fight_text = CommonDataManager.FightPower(self, self.node_list["Txt_now_zhanli"])
	self.next_fight_text = CommonDataManager.FightPower(self, self.node_list["Txt_next_zhanli"])
end

function ArenaTupoView:__delete()
	-- self.item = nil

	if self.tupo_item_list ~= nil then
		for k,v in pairs(self.tupo_item_list) do
			v:DeleteMe()
		end
		self.tupo_item_list = nil
	end

	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end

	self.now_fight_text = nil
	self.next_fight_text = nil
end

function ArenaTupoView:OpenCallBack()
	self:SetReMainTime()
end

function ArenaTupoView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["infocontent"], Vector3(-58, -86, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["bg_time"], Vector3(-200, 301, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["Item_Tupo_Group"], true, TWEEN_TIME)
end

function ArenaTupoView:OnFlush()
	local data = ArenaData.Instance
	local cur_rank_cfg = data:GetHistoryRankCfg()
	local cur_index = ArenaData.Instance:GetBestRankIndex()
	local next_index = 1
	if cur_rank_cfg then
		next_index = cur_rank_cfg.index + 1
		self.node_list["Txt_now_hp"].text.text = string.format(Language.Field1v1.maxhp, cur_rank_cfg.maxhp or 0)
		self.node_list["Txt_now_gongji"].text.text = string.format(Language.Field1v1.gongji, cur_rank_cfg.gongji or 0)
		self.node_list["Txt_now_fangyu"].text.text = string.format(Language.Field1v1.fangyu, cur_rank_cfg.fangyu or 0)
		if self.now_fight_text and self.now_fight_text.text then
			self.now_fight_text.text.text = CommonDataManager.GetCapability(cur_rank_cfg) or 0
		end
	end
	local next_rank_cfg = data:GetHistoryRankCfg(next_index)
	if next_rank_cfg then
		self.node_list["Txt_next_hp"].text.text = string.format(Language.Field1v1.maxhp, next_rank_cfg.maxhp or 0)
		self.node_list["Txt_next_gongji"].text.text = string.format(Language.Field1v1.gongji, next_rank_cfg.gongji or 0)
		self.node_list["Txt_next_fangyu"].text.text = string.format(Language.Field1v1.fangyu, next_rank_cfg.fangyu or 0)
		if self.next_fight_text and self.next_fight_text.text then
			self.next_fight_text.text.text = CommonDataManager.GetCapability(next_rank_cfg) or 0
		end
		-- self.node_list["Item_reward"]:SetActive(true)
		-- local item_id = next_rank_cfg.reward_show and next_rank_cfg.reward_show[0].item_id or 0
		-- self.item:SetData({item_id = item_id, num = next_rank_cfg.reward_guanghui})
	-- else
		-- self.node_list["Item_reward"]:SetActive(false)
	end
	if cur_index == TUPO_NUM then
		self.node_list["Right_part"]:SetActive(false)
		self.node_list["Img_arrow"]:SetActive(false)
		self.node_list["Node_noone"]:SetActive(false)
		self.node_list["Txrt_one"]:SetActive(true)
	end

	self.node_list["Txt_history_rank"].text.text = string.format(Language.Field1v1.ResultTip4, data:GetBestRank())
	UI:SetButtonEnabled(self.node_list["Btn_tupo"], data:GetArenaTupoRemind() > 0)
	self.node_list["red_point"]:SetActive(data:GetArenaTupoRemind() > 0)

	for k,v in ipairs(self.tupo_item_list) do
		v:SetData(data:GetHistoryRankCfg(k))
		v:Flush()
		UI:SetGraphicGrey(self.node_list["Item_tupo_" .. k], v.index > cur_index)
	end
end

function ArenaTupoView:SetReMainTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local sever_day = ArenaData.Instance:GetArenaViewOpenSeverDay()
	local differ_day = sever_day - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day + 22 * 3600 - time
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["bg_time"]:SetActive(false)
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 17)
			self.node_list["bg_time"]:SetActive(true)
			self.node_list["refresh_tips"].text.text = string.format(Language.Arena.DayClearTime, time_str)
		end

		diff_time_func(0, diff_time)
		self.day_count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function ArenaTupoView:OnUpGrade()
	ArenaCtrl.SendChallengeFieldBestRankBreakReq(1)
end

------------------------------------------------------------------------------------------------
ArenaTupoIcon = ArenaTupoIcon or BaseClass(BaseCell)
function ArenaTupoIcon:__init()

end

function ArenaTupoIcon:__delete()

end

function ArenaTupoIcon:OnFlush()
	local cur_index = ArenaData.Instance:GetBestRankIndex()
	local bundle, asset = ResPath.GetTuPoIcon(self.index)
	local str = self.data.best_rank_pos > 2 and Language.Field1v1.FormerRank or Language.Field1v1.FormerRank2
	self.node_list["Txt_rank"].text.text = string.format(str, self.data.best_rank_pos + 1)
	self.node_list["Img_icon"].image:LoadSprite(bundle, asset)
	if cur_index then
		if self.index > cur_index then
			self.node_list["Txt_chenghao"].text.text = ToColorStr(self.data.best_rank_name, TEXT_COLOR.WHITE)
		else
			self.node_list["Txt_chenghao"].text.text = ToColorStr(self.data.best_rank_name, ARENA_NAME_COLOR[self.data.best_rank_name_color])
		end
	end
	self.node_list["Img_select"]:SetActive(self.index == cur_index)
end