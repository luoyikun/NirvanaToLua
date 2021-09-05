-- 仙宠-技能封印
SpiritSkillCopy = SpiritSkillCopy or BaseClass(BaseView)

function SpiritSkillCopy:__init()
	self.ui_config = {{"uis/views/spiritview_prefab", "SkillCopyView"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SpiritSkillCopy:__delete()

end

function SpiritSkillCopy:ReleaseCallBack()
	self.text_skill_name = nil

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil
end

function SpiritSkillCopy:LoadCallBack()
	self.node_list["BtCopy"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnForget"].button:AddClickListener(BindTool.Bind(self.OnOkFunc, self))

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function SpiritSkillCopy:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritSkillCopy:OnFlush()
	-- 从不同的地方打开 表内的数据是不一样的
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	if nil == one_skill_cfg then
		return
	end
	-- 图标设置
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritIcon("skill_" .. skill_id)
	end
	self.node_list["IconImg"].image:LoadSprite(skill_icon_bundle, skill_icon_asset)

	-- 物品文本显示
	local desc = ""
	if cur_select_cell_data.can_move == 0 then
		local copy_item_id = one_skill_cfg.move_stuff_id
		local copy_item_cfg = ItemData.Instance:GetItemConfig(copy_item_id)
		local have_num = ItemData.Instance:GetItemNumInBagById(copy_item_id)
		local color = have_num >= 1 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		des = string.format(Language.JingLing.CopyItemCost, copy_item_cfg.name, color, have_num)
	else
		des = Language.JingLing.HasCopy
	end
	self.node_list["FrameTxt"].text.text = des
	-- 技能名字显示
	local color = SPRITE_SKILL_LEVEL_COLOR_TWO[one_skill_cfg.skill_level]
	local copy_item_name = ToColorStr(one_skill_cfg.skill_name, color)
	self.node_list["TxtSkillName"].text.text = copy_item_name

end

function SpiritSkillCopy:OnOkFunc()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()

	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	local copy_item_id = one_skill_cfg.move_stuff_id
	local have_num = ItemData.Instance:GetItemNumInBagById(copy_item_id)
	
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
	end
	if have_num == 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, copy_item_id, nil, 1)
		return
	end
	

	if have_num >= 1 then
		SpiritCtrl.Instance:CloseSkillInfoView()
		self:Close()
	end

	-- 技能 变成可移动,param1 仙宠索引,param2 技能索引,param3 是否自动购买
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_CHANGE_MOVE, cur_sprite_index, cur_select_cell_data.index, 0)
end

-- 物品不足，购买成功后刷新物品数量
function SpiritSkillCopy:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end