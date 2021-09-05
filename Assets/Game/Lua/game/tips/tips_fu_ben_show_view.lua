TipsFuBenShowView = TipsFuBenShowView or BaseClass(BaseView)

function TipsFuBenShowView:__init()
	self.ui_config = {{"uis/views/tips/fubenshowview_prefab", "FuBenShowView"}}
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsFuBenShowView:__delete()

end

function TipsFuBenShowView:ReleaseCallBack()
	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}

	for k, v in ipairs(self.item_tanxian) do
		v:DeleteMe()
	end
	self.item_tanxian = {}

	self.act_id = 0
end


function TipsFuBenShowView:LoadCallBack()
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnClickGo, self))
	self.item_cell = {}
	self.item_tanxian = {}
	self.act_id = 0
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	for i = 1, 4 do 
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Itemtx" .. i])
		item:SetData(nil)
		table.insert(self.item_tanxian, item)
	end

end

function TipsFuBenShowView:OpenCallBack()
	self:Flush()
end

function TipsFuBenShowView:OnFlush()
	local scene_type = Scene.Instance:GetSceneType()
	local wrold_level = RankData.Instance:GetWordLevel()
	if scene_type == SceneType.Kf_XiuLuoTower then
		local cur_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer() or 0
		self.act_id = ACTIVITY_TYPE.KF_XIULUO_TOWER
		self.node_list["BtnGo"]:SetActive(cur_layer == 10)
	elseif scene_type == SceneType.ShuiJing then
		self.act_id = ACTIVITY_TYPE.SHUIJING
		self.node_list["BtnGo"]:SetActive(true)
	elseif scene_type == SceneType.TombExplore then
		self.act_id = ACTIVITY_TYPE.TOMB_EXPLORE
		self.node_list["BtnGo"]:SetActive(true)
	end
	local item_list = ActivityData.Instance:GetActivityInfoById(self.act_id).show_item
	if nil == item_list then
		return
	end

	for k, v in ipairs(self.item_cell) do
		if item_list[k - 1] then
			v:SetData(item_list[k - 1])
		else
			v:SetData(nil)
			v:SetParentActive(false)
		end
	end
	 if scene_type == SceneType.TombExplore then
	 	self.node_list["ItemTanxian"]:SetActive(true)
		local tx_list = TombExploreData.Instance:GetTianXianRewardEq(wrold_level)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof) 
		self.node_list["ItemFrame"].transform:SetLocalPosition(-7, 36, 0)
		self.node_list["ItemTanxian"].transform:SetLocalPosition(-7, -58, 0)
		local itemtx_list = {}
		if tx_list["drop_item_list"..prof] then
			local show_data = tx_list["drop_item_list"..prof]
			itemtx_list = Split(show_data, "|")
		end

		for k, v in ipairs(self.item_tanxian) do
			if itemtx_list[k] then
				local temp_list = Split(itemtx_list[k], ",")
				local reward_item_id = tonumber(temp_list[1])
				v:SetData({item_id = reward_item_id})
				if tonumber(temp_list[3]) == 1 then
					v:SetShowOrangeEffect(true)
				else
					v:SetShowOrangeEffect(false)
				end

				if tonumber(temp_list[2]) == 1 then
					v:SetShowZhuanShu(true)
				else
					v:SetShowZhuanShu(false)
				end
			else
				v:SetData(nil)
				v:SetParentActive(false)
			end
		end
	else
		self.node_list["ItemTanxian"]:SetActive(false)
	end





end

function TipsFuBenShowView:OnClickGo()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Kf_XiuLuoTower then
		KuaFuXiuLuoTowerCtrl.Instance:SetMonsterClickGo()
	elseif scene_type == SceneType.ShuiJing then
		FuBenCtrl.Instance:SetClickGoToShuiJing()
	elseif scene_type == SceneType.TombExplore then
		TombExploreCtrl.Instance:GoToBoss()
	end
	self:Close()
end