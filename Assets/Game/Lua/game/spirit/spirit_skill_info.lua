-- 仙宠-技能
SpiritSkillInfo = SpiritSkillInfo or BaseClass(BaseView)

-- SpriteSkillView:从仙宠所拥有的技能的技能网格点开
-- SpriteSkillStorageView:从仙宠技能仓库点开
-- SpriteSkillView:从技能书背包网格点开
SpiritSkillInfo.FromView = {
	["SpriteSkillView"] = 1,
	["SpriteSkillStorageView"] = 2,
	["SpriteSkillBookBagView"] = 3,
}

function SpiritSkillInfo:__init()
	self.ui_config = {{"uis/views/spiritview_prefab", "SpriteSkillInfo"}}
	self.play_audio = true
	self.from_view = SpiritSkillInfo.FromView.SpriteSkillView
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_auto_buy = false
end

function SpiritSkillInfo:__delete()

end

function SpiritSkillInfo:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.is_auto_buy = false
	self.fight_text = nil
end

function SpiritSkillInfo:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritSkillInfo:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtForget"].button:AddClickListener(BindTool.Bind(self.OnForget, self))
	self.node_list["BtCopy"].button:AddClickListener(BindTool.Bind(self.OnCopy, self))
	self.node_list["BtLearn"].button:AddClickListener(BindTool.Bind(self.OnLearn, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["NumberTxt"], "FightPower3")
end

function SpiritSkillInfo:OnFlush()
	local is_show_btn_learn = self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView
	or self.from_view == SpiritSkillInfo.FromView.SpriteSkillStorageView

	self.node_list["BtForget"]:SetActive(not is_show_btn_learn)
	self.node_list["BtCopy"]:SetActive(not is_show_btn_learn)
	self.node_list["BtLearn"]:SetActive(is_show_btn_learn)

	local is_show_item_cell = self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView
	self.node_list["SkillCell"]:SetActive(not is_show_item_cell)
	self.node_list["ItemCell"]:SetActive(is_show_item_cell)

	-- 从不同的地方打开 表内的数据是不一样的
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
	if is_show_item_cell then
		self.item_cell:SetData({["item_id"] = cur_select_cell_data.item_id})
	else
		self.item_cell:SetData(nil)
	end
	self.item_cell:SetHighLight(false)

	local skill_id = 0
	local one_skill_cfg = nil
	if self.from_view == SpiritSkillInfo.FromView.SpriteSkillView or self.from_view == SpiritSkillInfo.FromView.SpriteSkillStorageView then
		skill_id = cur_select_cell_data.skill_id
		one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	elseif self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView then
		local item_id = cur_select_cell_data.item_id
		one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(item_id)
		skill_id = one_skill_cfg.skill_id
	end

	if nil == one_skill_cfg then
		return
	end
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritIcon("skill_" .. skill_id)
	end
	self.node_list["SkillImg"].image:LoadSprite(skill_icon_bundle, skill_icon_asset)
	self.node_list["SkillDescTxt"].text.text = one_skill_cfg.description or ""

	local color = SPRITE_SKILL_LEVEL_COLOR_TWO[one_skill_cfg.skill_level]
	local skill_name = ToColorStr(one_skill_cfg.skill_name, color)
	self.node_list["Title_IconNameTxt"].text.text = skill_name
	
	local level_str = Language.JingLing.SkillLevel[one_skill_cfg.skill_level or 1]
	self.node_list["UseLevelTxt"].text.text = string.format(Language.Common.JINengLevel, level_str)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = one_skill_cfg.zhandouli
	end
end

function SpiritSkillInfo:SetFromView(view_tpye)
	self.from_view = view_tpye or SpiritSkillInfo.FromView.SpriteSkillView
end

function SpiritSkillInfo:OnForget()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()

	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)

	local forget_item_id = one_skill_cfg.remove_stuff_id
	local forget_item_cfg = ItemData.Instance:GetItemConfig(forget_item_id)
	local have_num = ItemData.Instance:GetItemNumInBagById(forget_item_id)
	local color = have_num >= 1 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local item_color = ITEM_COLOR[forget_item_cfg.color]
	local skill_color = SPRITE_SKILL_LEVEL_COLOR_TWO[one_skill_cfg.skill_level]
	local des = string.format(Language.JingLing.IsForgetSkill,
						item_color, forget_item_cfg.name, skill_color, one_skill_cfg.skill_name, item_color, forget_item_cfg.name, color, have_num)

	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
		-- self.is_auto_buy = is_buy_quick
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
	end
	if have_num == 0 and not self.is_auto_buy then
		TipsCtrl.Instance:ShowCommonBuyView(func, forget_item_id, nil, 1, true)
		return
	end
	
	if have_num > 0 then
		local function ok_callback()
			self:Close()
			-- 技能 遗忘,param1 仙宠索引,param2 技能索引,param3 是否自动购买
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REMOVE_SKILL, cur_sprite_index, cur_select_cell_data.index, 0)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
	else
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REMOVE_SKILL, cur_sprite_index, cur_select_cell_data.index, 1)
	end
end

function SpiritSkillInfo:OnCopy()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
	-- 这里要去拿最新的数据
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local cur_sprite_info = spirit_info.jingling_list[cur_sprite_index]
	local new_data = cur_sprite_info.param.jing_ling_skill_list[cur_select_cell_data.index]
	if new_data.can_move == 0 then
		SpiritCtrl.Instance:OpenSkillCopyView()
	else
		-- 技能 脱下,param1 仙宠索引,param2 技能索引,param3 技能仓库索引
		local storage_index = SpiritData.Instance:GetStorageFirstNotSkillIndex()
		if nil == storage_index then
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SkillStorageFullSkill)
			return
		end
		
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKE_OFF_SKILL, cur_sprite_index, new_data.index, storage_index)
		self:Close()
	end
	
end

function SpiritSkillInfo:OnLearn()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	if nil == cur_sprite_index then
		return
	end

	if self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView then
		local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
		local stuff_item_id = cur_select_cell_data.item_id
		local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(stuff_item_id)
		local skill_id = one_skill_cfg.skill_id
		local skill_index, has_per_skill = SpiritData.Instance:GetLearnSkillCellIndex(cur_sprite_index, skill_id)

		local item_index = ItemData.Instance:GetItemIndex(stuff_item_id)
		-- param1 仙宠索引,param2 技能索引,param3 物品索引
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_LEARN_SKILL, cur_sprite_index, skill_index, item_index)
	else
		-- 技能仓库技能只需往后插
		local skill_index = SpiritData.Instance:GetFirstNotSkillCellIndex(cur_sprite_index)
		local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
		local storage_cell_index = cur_select_cell_data.index or 0
		-- 技能 穿戴,param1 仙宠索引,param2 技能索引,param3 技能仓库索引
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PUT_ON_SKILL, cur_sprite_index, skill_index, storage_cell_index)
	end

	self:Close()
end

function SpiritSkillInfo:OnClickItemCell()
	self.item_cell:SetHighLight(false)
end