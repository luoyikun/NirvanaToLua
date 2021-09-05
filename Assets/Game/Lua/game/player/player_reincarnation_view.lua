PlayerReincarnationView = PlayerReincarnationView or BaseClass(BaseRender)

function PlayerReincarnationView:__init()
	self.node_list["ZsButton"].button:AddClickListener(BindTool.Bind(self.ZsClick, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:ShowHighLight(false)

	-- 获取控件
	self.role_display = self.node_list["RoleDisplay"]

	--引导用按钮
	self.zs_button = self.node_list["ZsButton"]

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	
end

function PlayerReincarnationView:__delete()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	self.fight_text = nil
end

function PlayerReincarnationView:GetZsButton()
	return self.zs_button
end

function PlayerReincarnationView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	
end

function PlayerReincarnationView:SetRoleData()
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetDisplay(self.role_display.ui3d_display)
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
	self.role_model:SetHaloResid(main_role:GetHaloResId())
end

function PlayerReincarnationView:OpenCallBack()
end

function PlayerReincarnationView:OnClosen()
	self:Close()
end

function PlayerReincarnationView:ZsClick()
	ReincarnationCtrl.Instance:SendRoleZhuanShengReq()
end

function PlayerReincarnationView:OnFlush()
	local curr_zhuanshen_cfg = ReincarnationData.Instance:GetConfig()
	if not curr_zhuanshen_cfg then return end
	
	local level = ReincarnationData.Instance:GetZsLevel()
	local data = ReincarnationData.Instance:GetZsDataByLevel(level)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local gongji = curr_zhuanshen_cfg.gongji
	local maxhp = curr_zhuanshen_cfg.maxhp
	local fangyu = curr_zhuanshen_cfg.fangyu
	local force = ReincarnationData.Instance:GetForceByLevel(maxhp,gongji,fangyu)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = force
	end

	if level > 8 then
		self.node_list["TxtLevel"].text.text = data.name
		self.node_list["TxtAtkContentValue"].text.text = data.gongji
		self.node_list["TxtDefendContentValue"].text.text = data.fangyu
		self.node_list["TxtHpContentValue"].text.text = data.maxhp
		self.node_list["Image"]:SetActive(false)
		self.node_list["TxtLevel1"]:SetActive(false)
		self.node_list["ImgHpContentUp"]:SetActive(false)
		self.node_list["TxtHpContentUpValue"]:SetActive(false)
		self.node_list["ImgAtkContentUp"]:SetActive(false)
		self.node_list["TxtAtkContentUpvalue"]:SetActive(false)
		self.node_list["ImgDefendContentUp"]:SetActive(false)
		self.node_list["TxtDefendContentUpvalue"]:SetActive(false)
		self.node_list["ImgHitContentUp"]:SetActive(false)
		self.node_list["TxtHitContentUpvalue"]:SetActive(false)
		self.node_list["ImgFlashContentUp"]:SetActive(false)
		self.node_list["TxtFlashContentUpvalue"]:SetActive(false)
		self.node_list["TxtNeedLevel"]:SetActive(false)
		self.node_list["NoteFrame01"]:SetActive(false)
		self.node_list["ZsButton"]:SetActive(false)
		self.node_list["TxtMaxLevel"]:SetActive(true)
		return
	end

	local next_data = ReincarnationData.Instance:GetZsDataByLevel(level + 1)
	if level > 0 then
		self.node_list["TxtLevel"].text.text = data.name
		self.node_list["TxtAtkContentValue"].text.text = data.gongji
		self.node_list["TxtDefendContentValue"].text.text = data.fangyu
		self.node_list["TxtHpContentValue"].text.text = data.maxhp
		self.node_list["TxtLevel1"].text.text = next_data.name
		local next_role_level = (level + 1) * 100
		if role_level >= next_role_level then
			self.node_list["TxtNeedLevel"].text.text = string.format("<color=#D0D8FFFF>需要等级：</color>%s", string.format(Language.Common.GreenZhuanLevel, 100, ToColorStr(data.name, TEXT_COLOR.GREEN_4)))
		else
			self.node_list["TxtNeedLevel"].text.text = string.format("<color=#D0D8FFFF>需要等级：</color>%s", string.format(Language.Common.RedZhuanLevel, 100, ToColorStr(data.name, TEXT_COLOR.GREEN_4)))
		end
		self.node_list["TxtAtkContentUpvalue"].text.text = next_data.gongji - data.gongji
		self.node_list["TxtDefendContentUpvalue"].text.text = next_data.fangyu - data.fangyu
		self.node_list["TxtHpContentUpValue"].text.text = next_data.maxhp - data.maxhp
	else
		if role_level >= 100 then
			self.node_list["TxtNeedLevel"].text.text = string.format("<color=#D0D8FFFF>需要等级：</color>%s", string.format(Language.Common.GreenLevel, 100))
		else
			self.node_list["TxtNeedLevel"].text.text = string.format("<color=#D0D8FFFF>需要等级：</color>%s", string.format(Language.Common.RedLevel, 100))
		end
		self.node_list["TxtLevel"].text.text = "0"..Language.Common.Zhuan
		self.node_list["TxtLevel1"].text.text = next_data.name
		self.node_list["TxtAtkContentValue"].text.text = 0
		self.node_list["TxtDefendContentValue"].text.text = 0
		self.node_list["TxtHpContentValue"].text.text = 0
		self.node_list["TxtAtkContentUpvalue"].text.text = next_data.gongji
		self.node_list["TxtDefendContentUpvalue"].text.text = next_data.fangyu
		self.node_list["TxtHpContentUpValue"].text.text = next_data.maxhp
	end

	local have_num = ItemData.Instance:GetItemNumInBagById(next_data.consume_item.item_id)
	local item_num = next_data.consume_item.num

	if have_num < item_num then
		self.node_list["Text"].text.text = ToColorStr(have_num, TEXT_COLOR.RED) .. ToColorStr(" / " .. item_num, TEXT_COLOR.GREEN_4)
	else
		self.node_list["Text"].text.text = ToColorStr(have_num, TEXT_COLOR.GREEN_4) .. ToColorStr(" / " .. item_num, TEXT_COLOR.GREEN_4)
	end
	local item_data = {item_id = next_data.consume_item.item_id, is_bind = next_data.consume_item.is_bind}
	self.item_cell:SetData(item_data)
end