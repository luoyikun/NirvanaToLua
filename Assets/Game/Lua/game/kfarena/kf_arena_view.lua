KFArenaView = KFArenaView or BaseClass(BaseRender)
local TWEEN_TIME = 0.5
function KFArenaView:__init()
	self.node_list["SwitchEnemy"].button:AddClickListener(BindTool.Bind(self.SendRefreshCompetitor, self))

	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.role_model:SetModelResInfo(main_role_vo, nil, false, nil, nil, nil, nil, true)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerNum"])

	self.enemy_card_list = {}
	for i=1, 4 do
		self.enemy_card_list[i] = KFArenaCard.New(self.node_list["EnemyCard" .. i])
	end

	self.role_enter_scene_effect = GlobalEventSystem:Bind(SceneEventType.CLOSE_LOADING_VIEW, BindTool.Bind1(self.OnCloseSceneLoadingView, self))
end

function KFArenaView:__delete()
	if self.delay_open_switch then
		GlobalTimerQuest:CancelQuest(self.delay_open_switch)
		self.delay_open_switch = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if next(self.enemy_card_list) then
		for k,v in pairs(self.enemy_card_list) do
			v:DeleteMe()
		end
		self.enemy_card_list = {}
	end

	if self.role_enter_scene_effect then
		GlobalEventSystem:UnBind(self.role_enter_scene_effect)
		self.role_enter_scene_effect = nil
	end
end

function KFArenaView:OnCloseSceneLoadingView()
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO)
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_OPPONENT_INFO, 0)
	self:FlushKFArenaView()
end

function KFArenaView:OnFlush()
	self:FlushKFArenaView()
end

function KFArenaView:CalToShowAnim()

end

function KFArenaView:SetModel()

end

function KFArenaView:OpenCallBack()
	self.can_send_change = false
	if self.delay_open_switch then
		GlobalTimerQuest:CancelQuest(self.delay_open_switch)
		self.delay_open_switch = nil
	end
	if self.delay_open_switch == nil then
		self.delay_open_switch = GlobalTimerQuest:AddDelayTimer(function() self.can_send_change = true
			end, 1.5)
	end

	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO)
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_OPPONENT_INFO, 0)
end

function KFArenaView:DoPanelTweenPlay()

end

function KFArenaView:SendRefreshCompetitor()
	if self.can_send_change then
		self.can_send_change = false
		self.node_list["EnemyPanel"].animator:SetTrigger("move_tween")
		KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_REFRESH)

		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end

		if self.delay_open_switch then
			GlobalTimerQuest:CancelQuest(self.delay_open_switch)
			self.delay_open_switch = nil
		end
		if self.delay_open_switch == nil then
			self.delay_open_switch = GlobalTimerQuest:AddDelayTimer(function() self.can_send_change = true end, 1)
		end
	end
end

function KFArenaView:OnClickBuffBtn()

end

function KFArenaView:SendBuyJoinTimes()

end

function KFArenaView:FlushKFArenaView()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = main_role_vo.capability
	end

	local info = KFArenaData.Instance:GetUserInfo()
	if nil == info then
		return
	end
	local sorted_list = info.rank_list
	self.uid_list = {}
	self.rank_pos_list = {}
	self.rank_index_list = {}
	table.sort(sorted_list, SortTools.KeyUpperSorter("rank"))
	for i, v in ipairs(sorted_list) do
		table.insert(self.uid_list, v.user_id)
		table.insert(self.rank_pos_list, v.rank_pos)
		table.insert(self.rank_index_list, v.index)
	end

	for i=1, 4 do
		local role_info = KFArenaData.Instance:GetRoleInfoByUid(self.uid_list[i])
		local role_info2 = KFArenaData.Instance:GetRoleTiaoZhanInfoByUid(self.uid_list[i])
		if role_info and role_info2 then
			role_info.rank = role_info2.rank
		end
		self.enemy_card_list[i]:SetData(role_info)
		self.enemy_card_list[i]:SetIndex(self.rank_index_list[i])
		self.enemy_card_list[i]:SetPos(self.rank_pos_list[i])
	end

	if info.rank > 1000 then
		self.node_list["Txt_myrank"].text.text = string.format(Language.KFArena.MyRank, ToColorStr(Language.KFArena.NotEnoughRank, TEXT_COLOR.GREEN))
	else
		self.node_list["Txt_myrank"].text.text = string.format(Language.KFArena.MyRank, ToColorStr(info.rank, TEXT_COLOR.GREEN))
	end
end

function KFArenaView:SetReMainTime()

end


KFArenaCard = KFArenaCard or BaseClass(BaseCell)
function KFArenaCard:__init()
	self.node_list["Btn_challenge"].button:AddClickListener(BindTool.Bind(self.ToggleEvent, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Node_fightNum"])
end

function KFArenaCard:__delete()
	self.data = nil
end

function KFArenaCard:OnFlush()
	local info = KFArenaData.Instance:GetUserInfo()
	if self.data == nil or info == nil then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local img_type = 3
	if self.data.capability < main_role_vo.capability and self.data.rank > info.rank then
		img_type = 2
	elseif self.data.capability > main_role_vo.capability and self.data.rank < info.rank then
		img_type = 1
	end
	local bundle, asset = ResPath.GetKFArenaDes(img_type)
	self.node_list["Img_dec"].image:LoadSprite(bundle, asset, function ()
		self.node_list["Img_dec"].image:SetNativeSize()
	end)

	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.data.capability
	end
	if self.data.server_id ~= 0 then
		self.node_list["Txt_Name"].text.text = string.format(Language.KFArena.NameWithSever, self.data.name, self.data.server_id)
	else
		self.node_list["Txt_Name"].text.text = self.data.name
	end

	if self.data.rank > 1000 then
		self.node_list["Txt_Rank"].text.text = Language.KFArena.NotEnoughRank
	else
		self.node_list["Txt_Rank"].text.text = string.format(Language.KFArena.RankDesc, self.data.rank)
	end

	local user_id = self.data.user_id
	local prof =  self.data.prof
	local sex = self.data.sex
	AvatarManager.Instance:SetAvatarKey(user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["HeadRawImage"], self.node_list["HeadImage"], sex, prof, false)
end

function KFArenaCard:SetPos(num)
	self.pos = num
end

function KFArenaCard:SetIndex(num)
	self.index = num
end


function KFArenaCard:ToggleEvent()
	-- if self.data == nil then
	-- 	return
	-- end
	-- local role_info = KFArenaData.Instance:GetRoleInfoByUid(self.data.user_id)
	-- if nil == role_info then
	-- 	return
	-- end
	-- local tz_info = KFArenaData.Instance:GetRoleTiaoZhanInfoByUid(role_info.user_id)
	-- if tz_info then
		KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_FIGHT, self.index, 1, self.pos)
	-- end
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO)
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_REFRESH)
	KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_OPPONENT_INFO, 0)
end