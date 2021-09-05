LongXingView = LongXingView or BaseClass(BaseView)

local GRID_NUM = 30

function LongXingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/longxing_prefab", "LongXingView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.play_audio = true
	self.grid_cell_list = {}
	self.is_modal = true
end

function LongXingView:__delete()
end

function LongXingView:ReleaseCallBack()

	if self.grid_cell_list then
		for k,v in pairs(self.grid_cell_list) do
			v:DeleteMe()
		end
	end
	self.grid_cell_list = {}

	--清理对象和变量
	self.grid_list = nil
	self.my_rawimage = nil
	self.my_image_res = nil
	self.my_image_state = nil
	self.play_img = nil
	self.upgrade_btn = nil

	self.is_gray = nil
	self.display = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function LongXingView:LoadCallBack()
	-- self.is_gray = self:FindVariable("IsGray")

	self.display = self.node_list["Display"]
	self.upgrade_btn = self.node_list["UpgradeBtn"]
	self.grid_list = self.node_list["GridList"]

	for i = 1, GRID_NUM do
		local gird_obj = self.grid_list.transform:FindHard("Grid_" .. i)
		local res_async_loader = AllocResAsyncLoader(self, "LongXing_loader" .. i)
		res_async_loader:Load("uis/views/longxing_prefab", "LongXingGridCell", nil, function(prefab)
			if nil == prefab then
				return
			end

			local obj = ResMgr:Instantiate(prefab)
			-- PrefabPool.Instance:Free(prefab)
			obj.transform:SetParent(gird_obj.transform, false)
			local cell = LongXingGridCell.New(obj)
			self.grid_cell_list[i] = cell
			local data = {}
			if i == GRID_NUM then
				data = LongXingData.Instance:GetRewardListByGrid(GRID_NUM + LongXingData.Instance:GetCurrloop() % 2) or LongXingData.Instance:GetMaxReward()
			else
				data = LongXingData.Instance:GetRewardListByGrid(i)
			end
			self.grid_cell_list[i]:SetData(data)
		end)
	end

	--头像相关
	self.my_image_res = self.node_list["Portrait"]
	self.my_image_state = self.node_list["MyImageState"]				--是否显示自己的默认头像
	self.my_rawimage = self.node_list["MyRawImage"]

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["UpgradeBtn"].button:AddClickListener(BindTool.Bind(self.ClickUpgrade, self))
	self.node_list["HelpTip"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))

	self:Flush()
end

function LongXingView:OpenCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		PlayerPrefsUtil.SetInt(main_role_id .. "longxing_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.LongXingRemind)
	end
	self:SetMyHead()
	self:Flush()
end

function LongXingView:OnFlush()
	local info = LongXingData.Instance:GetSCMolongInfo()
	if info == nil or next(info) == nil then return end

 	for i=1,GRID_NUM do
		if self.grid_cell_list[i] then
			local data = LongXingData.Instance:GetRewardListByGrid(i)
			if i == GRID_NUM then
				data = LongXingData.Instance:GetRewardListByGrid(GRID_NUM + LongXingData.Instance:GetCurrloop()) or LongXingData.Instance:GetMaxReward()
			end
			self.grid_cell_list[i]:SetData(data)
		end
	end
	self.node_list["Title_Img"].image:LoadSprite(ResPath.GetLongxingLevelIcon(math.ceil(info.rank_grade / 10)))
	self.node_list["LongXingRank"].text.text = info.rank_grade
	self.node_list["Leiji_Num"].text.text = info.accumulate_consume_gold
	-- local rank_cfg = LongXingData.Instance:GetRankByGrade(info.rank_grade)
	-- self.node_list["Title_Text"].text.text = rank_cfg.rank_name
	-- self.node_list["Zhanli_Num"].text.text = rank_cfg.war_value

	-- if info.rank_cumulate_gold >= rank_cfg.cumulate_gold then
	-- 	UI:SetButtonEnabled(self.node_list["UpgradeBtn"], true)
	-- 	self.node_list["Show_Red"]:SetActive(true)
	-- 	if info.rank_grade >= LongXingData.Instance:GetRankMaxGrade() then
	-- 		UI:SetButtonEnabled(self.node_list["UpgradeBtn"], false)
	-- 		self.node_list["UpgradeBtn_Text"].text.text = Language.Common.YiManJi
	-- 		self.node_list["Show_Red"]:SetActive(false)
	-- 	else
	-- 		UI:SetButtonEnabled(self.node_list["UpgradeBtn"], true)
	-- 		self.node_list["UpgradeBtn_Text"].text.text = Language.LongXing.ShengJi
	-- 		self.node_list["Show_Red"]:SetActive(true)
	-- 	end
	-- 	self.node_list["Num_Text"].text.text = "<color=#0000f1>"..info.rank_cumulate_gold.."</color>".."/"..rank_cfg.cumulate_gold
	-- else
	-- 	UI:SetButtonEnabled(self.node_list["UpgradeBtn"], false)
	-- 	self.node_list["Show_Red"]:SetActive(false)
	-- 	self.node_list["Num_Text"].text.text = "<color=#fe3030>"..info.rank_cumulate_gold.."</color>".."/"..rank_cfg.cumulate_gold

	-- end
	-- self.node_list["Xiaoguo_Text"].text.text = rank_cfg.value_percent

	--判断是否是第一步
	if info.total_move_step == 0 then
		self.my_image_state:SetActive(false)
		self.node_list["Complete"]:SetActive(info.curr_loop > 1 or false)
		self.node_list["IsComplete"]:SetActive(not (info.curr_loop > 1 or false))
	else
		self.node_list["Complete"]:SetActive(false)
		self.node_list["IsComplete"]:SetActive(true)
		self.my_image_state:SetActive(true)
		self.my_image_state.transform.position = self.grid_list.transform:FindHard("Grid_" .. info.total_move_step).transform.position
	end

	local today_move_step = info.today_move_step<=0 and 0 or info.today_move_step
	local next_need_gold = 0
	if today_move_step >= 5 then
		next_need_gold = 0
	else
		next_need_gold = LongXingData.Instance:GetMoveByStep(today_move_step>=5 and 5 or today_move_step+1).consume_gold - info.today_consume_gold
	end

	self.node_list["Bushu_Num"].text.text = string.format(Language.LongXing.LeftTimes, 5 - info.today_move_step)
	self.node_list["Next_Num"].text.text = next_need_gold

	local index = GRID_NUM + LongXingData.Instance:GetCurrloop() % 2
	local longxing_cfg = LongXingData.Instance:GetRewardListByGrid(index)

	self:SetModel(longxing_cfg.model_show)
end

function LongXingView:CloseWindow()
	self:Close()
end

function LongXingView:ClickUpgrade()
	LongXingCtrl.Instance:SendMolongRankInfoReq()
end

function LongXingView:ClickHelp()
	local tip_id = 305
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

--设置我的头像
function LongXingView:SetMyHead()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = main_role_vo.role_id
	local prof = main_role_vo.prof
	local sex = main_role_vo.sex
	CommonDataManager.NewSetAvatar(role_id, self.my_rawimage, self.my_image_res, self.my_rawimage, sex, prof, true)
	-- CommonDataManager.NewSetAvatar(role.role_id, self.node_list["raw_image_obj"], self.node_list["AvatarImage"], self.node_list["raw_image_obj"], role.sex, role.prof, true)
end

function LongXingView:SetModel(model_show)
	if self.model == nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.display.ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]

	local function complete_callback()
		if string.find(model_show, "mount") then
			self.model:SetLocalPosition(Vector3(0, -2.6, -8))
			self.model:SetRotation(Vector3(0, -60, 0))

		elseif string.find(model_show, "wing") then
			self.model:SetLocalPosition(Vector3(0, 0, 0))
			self.model:SetRotation(Vector3(0, 0, 0))
		end
	end

	self.model:SetMainAsset(bundle, asset, complete_callback)
end

---------------------------龙行天下格子--------------------------
LongXingGridCell = LongXingGridCell or BaseClass(BaseCell)

function LongXingGridCell:__init()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["Reward_Item"])
	self.reward_item:GetTransForm():SetLocalScale(0.6, 0.6, 0.6)

end

function LongXingGridCell:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

end

-- function LongXingGridCell:SetIndex(index)
-- 	self.index = index
-- end

function LongXingGridCell:OnFlush()
	local today_move_step = LongXingData.Instance:GetTotalMoveStep()
	if today_move_step == nil then return end

	self.node_list["Bushu_Num"].text.text = self.data.grid

	if self.data.reward_item then
		self.reward_item:SetData(self.data.reward_item)
	end
	if self.data.fanli_rate > 0 then
		self.node_list["Fanli_Num"].text.text = self.data.fanli_rate .. "%"
	end

	if self.data.grid <= today_move_step then
		self.node_list["Bushu_Num"]:SetActive(true)
		self.node_list["Fanli"]:SetActive(false)
		self.node_list["Reward_Item"]:SetActive(false)
	else
		self.node_list["Fanli"]:SetActive(self.data.fanli_rate>0)
		self.node_list["Bushu_Num"]:SetActive(not (self.data.reward_item~=nil and self.data.fanli_rate>0))
		self.node_list["Reward_Item"]:SetActive(self.data.reward_item~=nil)
	end
end
