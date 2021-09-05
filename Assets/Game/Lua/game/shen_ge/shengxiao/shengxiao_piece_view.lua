ShengXiaoPieceView = ShengXiaoPieceView or BaseClass(BaseRender)
local MOVE_TIME = 0.5

local ATTR_LIST = {
	"maxhp",
	"gongji",
	"fangyu",
	"mingzhong",
	"shanbi",
	"baoji",
	"jianren"}
function ShengXiaoPieceView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightContent"] , Vector3(0 , -50 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["RightContent"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["LeftContent"] , Vector3(328 , -50 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["LeftContent"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)

	UITween.MoveShowPanel(self.node_list["RightList"] , Vector3(-667 , 200 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleDown"] , Vector3(0 , -200 , 0 ) , MOVE_TIME )
end

function ShengXiaoPieceView:__init()
	self.node_list["BtnSkill"].button:AddClickListener(BindTool.Bind(self.OpenSkillView, self))
	self.node_list["BtnTreasure"].button:AddClickListener(BindTool.Bind(self.OpenTearsueView, self))
	self.node_list["BtnBag"].button:AddClickListener(BindTool.Bind(self.OpenBagView, self))
	self.node_list["BtnMoveType"].button:AddClickListener(BindTool.Bind(self.OnSelectMoveType, self))
	self.node_list["BtnMask"].button:AddClickListener(BindTool.Bind(self.OnSelectNomalType, self))
	self.node_list["BtnDown"].button:AddClickListener(BindTool.Bind(self.OnPageDown, self))
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnPageUp, self))
	self.node_list["BtnCloseDetail"].button:AddClickListener(BindTool.Bind(self.CloseDetail, self))
	self.node_list["BtnPutOff"].button:AddClickListener(BindTool.Bind(self.OnTakeOffPiece, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["CloseDetail"].button:AddClickListener(BindTool.Bind(self.CloseDetail, self))

	self.cur_chapter = ShengXiaoData.Instance:GetMaxChapter()
	self.is_move_state = false
	self.select_piece_value = 0
	self.show_anim_count = 0

	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- self.red_point_list = {
	-- 	[RemindName.ErnieView] = self.node_list["Effect"],
	-- }
	-- for k, _ in pairs(self.red_point_list) do
	-- 	RemindManager.Instance:Bind(self.remind_change, k)
	-- end
	self.fight_text = {}
	for i = 1,3 do
		self.fight_text[i] = CommonDataManager.FightPower(self, self.node_list["TxtPower" .. i])
	end
	self.fight_text4 = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber"])
	self.fight_text5 = CommonDataManager.FightPower(self, self.node_list["TxtCombatNumber"])

	for i = 1, 3 do
		self.node_list["ImgIcon" .. i].button:AddClickListener(BindTool.Bind(self.OpenCombine, self, i))
	end

	self.piece_list = {}
	for i = 1, 7 do
		local group_obj = self.node_list["PieceContent"].transform:FindHard("Group" .. i)
		self.piece_list[i] = {}
		for j = 1, 7 do
			if nil ~= group_obj:FindHard("piece" .. j) then
				self.piece_list[i][j] = PieceItem.New()
				self.piece_list[i][j]:SetInstanceParent(group_obj:FindHard("piece" .. j))
				self.piece_list[i][j].parent_view = self
				if i > 4 then
					self.piece_list[i][j]:SetData({x = j + i - 4, y = i})
				else
					self.piece_list[i][j]:SetData({x = j, y = i})
				end
			end
		end
	end
	self.move_data1 = nil
	self.move_data2 = nil
	self.show_detail_data = nil
	if self.anim_countdown == nil then
		self.anim_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowAnim, self, 1), 1)
	end
	RemindManager.Instance:Fire(RemindName.ErnieView)
end

function ShengXiaoPieceView:RemindChangeCallBack(remind_name, num)
	-- if nil ~= self.red_point_list[remind_name] then

	-- 	self.red_point_list[remind_name]:SetActive(num > 0)
	-- end
end

function ShengXiaoPieceView:ShowAnim(index)
	if index > 3 then return end
	local show_anim_list = ShengXiaoData.Instance:GetShowAnimListByChatper(self.cur_chapter)
	if self.has_light then
		self.has_light = false
		self.show_anim_count = (self.show_anim_count + 1) % 3
		self:FLushCellAnim(false)
	elseif show_anim_list and show_anim_list[self.show_anim_count] then
		self.has_light = true
		self:FLushCellAnim(true, show_anim_list[self.show_anim_count])
	else
		self.show_anim_count = (self.show_anim_count + 1) % 3
		self:ShowAnim(index + 1)
	end
end

function ShengXiaoPieceView:__delete()
	self.move_data1 = nil
	self.move_data2 = nil
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			if v1 then
				v1:DeleteMe()
				v1 = nil
			end
		end
	end
	if self.anim_countdown ~= nil then
		GlobalTimerQuest:CancelQuest(self.anim_countdown)
		self.anim_countdown = nil
	end
	self.show_detail_data = nil
	self.move_data1 = nil
	self.move_data2 = nil
	self.select_piece_value = 0
	-- self.red_point_list = {}
	-- if RemindManager.Instance and self.remind_change then
	-- 	RemindManager.Instance:UnBind(self.remind_change)
	-- 	self.remind_change = nil
	-- end
end

function ShengXiaoPieceView:FlushPieceView()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			v1:OnFlush()
		end
	end
end

function ShengXiaoPieceView:FLushCellAnim(value, show_anim_list)
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			local x, y = 0, 0
			if v1:GetData() then
				x = v1:GetData().x
				y = v1:GetData().y
			end
			local bool = value
			if bool and show_anim_list and show_anim_list[y- 1] then
				bool = show_anim_list[y - 1][x - 1] ~= nil
			else
				bool = false
			end
			v1:SetShowAnim(bool)
		end
	end
end

function ShengXiaoPieceView:FLushItemHL()
	for k,v in pairs(self.piece_list) do
		for k1,v1 in pairs(v) do
			v1:FlushHL()
		end
	end
end

function ShengXiaoPieceView:OpenTearsueView()
	RemindManager.Instance:Fire(RemindName.ErnieView)
	ViewManager.Instance:Open(ViewName.ErnieView)
end

function ShengXiaoPieceView:OpenBagView()
	ShengXiaoCtrl.Instance:OpenShengXiaoBag(self.cur_chapter)
end

function ShengXiaoPieceView:OpenSkillView()
	ShengXiaoCtrl.Instance:OpenShengXiaoSkill(self.cur_chapter)
end

function ShengXiaoPieceView:OnSelectMoveType()
	self.is_move_state = not self.is_move_state
	if self.is_move_state then
		self.node_list["BtnMask"]:SetActive(true)
		self.node_list["TxtBtn"].text.text = Language.ShengXiao.TxtNormal
	else
		self.move_data1 = nil
		self.move_data2 = nil
		self:FLushItemHL()
		self.node_list["BtnMask"]:SetActive(false)
		self.node_list["TxtBtn"].text.text = Language.ShengXiao.TxtMove
	end
end

function ShengXiaoPieceView:OnSelectNomalType()
	self.move_data1 = nil
	self.move_data2 = nil
	self:FLushItemHL()
	self.is_move_state = false
	self.node_list["BtnMask"]:SetActive(false)
	self.node_list["TxtBtn"].text.text = Language.ShengXiao.TxtMove
end

function ShengXiaoPieceView:OnPageDown()
	if self.cur_chapter <= 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoMoreChapter)
		return
	end
	self.cur_chapter = self.cur_chapter - 1
	self:ShowAnim(1)
	self:FlushAll()
end

function ShengXiaoPieceView:OnPageUp()
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	if self.cur_chapter >= 5 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoMoreChapter)
		return
	end
	if self.cur_chapter >= max_chatpter then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NextChapter)
		return
	end
	self.cur_chapter = self.cur_chapter + 1
	self:ShowAnim(1)
	self:FlushAll()
end

function ShengXiaoPieceView:OpenDetail()
	self.node_list["PanelDetailContent"]:SetActive(true)
	self:FlushDetailView()
end

function ShengXiaoPieceView:CloseDetail()
	self.node_list["PanelDetailContent"]:SetActive(false)
end

function ShengXiaoPieceView:OpenCombine(idnex)
	local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_chapter - 1) * 3 + idnex - 1)
	for k, v in pairs(ATTR_LIST) do					--子豪说属性值为0就不显示
		if one_combine_cfg[v] == 0 then
			one_combine_cfg[v] = -1
		end
	end
	TipsCtrl.Instance:ShowAttrView(one_combine_cfg)
end


function ShengXiaoPieceView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(177)
end

function ShengXiaoPieceView:OnTakeOffPiece()
	if nil ~= self.show_detail_data then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XIE_BEAD, self.show_detail_data.x - 1
			, self.show_detail_data.y - 1, self.cur_chapter - 1)
	end
	self:CloseDetail()
end

function ShengXiaoPieceView:FlushDetailView()
	if self.select_piece_value <= 0 then return end
	local detail_cfg = ShengXiaoData.Instance:GetBeadCfg(self.select_piece_value)
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetPieceIcon(self.select_piece_value))
	local quality_num = ItemData.Instance:GetItemQuailty(detail_cfg.item_id or 0)
	if quality_num then
		local bundle, asset = ResPath.GetQualityIcon(quality_num)
		self.node_list["ImgQuailty"].image:LoadSprite(bundle, asset)
	end
	self.node_list["TxtPanelTitle"].text.text = ItemData.Instance:GetItemName(detail_cfg.item_id)

	local hp = detail_cfg.max_hp or detail_cfg.maxhp or 0
	local gong_ji = detail_cfg.gong_ji or detail_cfg.gongji or 0
	local fang_yu = detail_cfg.fang_yu or detail_cfg.fangyu or 0
	local ming_zhong = detail_cfg.ming_zhong or detail_cfg.mingzhong or 0
	local shan_bi = detail_cfg.shan_bi or detail_cfg.shanbi or 0
	local bao_ji = detail_cfg.bao_ji or detail_cfg.baoji or 0
	local jian_ren = detail_cfg.jian_ren or detail_cfg.jianren or 0

	if hp and hp >= 0 then
		self.node_list["TxtHp"].text.text = Language.Common.PassvieSkillAttr.max_hp .."：" .. hp
	end
	self.node_list["NodeHp"]:SetActive(hp > 0)

	if gong_ji and gong_ji >= 0 then
		self.node_list["TxtGongji"].text.text = Language.Common.PassvieSkillAttr.gong_ji .."：" .. gong_ji
	end
	self.node_list["NodeGongji"]:SetActive(gong_ji > 0)

	if fang_yu and fang_yu >= 0 then
		self.node_list["TxtFangYu"].text.text = Language.Common.PassvieSkillAttr.fang_yu .."：" .. fang_yu
	end
	self.node_list["NodeFangYu"]:SetActive(fang_yu > 0)

	if ming_zhong and ming_zhong >= 0 then
		self.node_list["TxtMingZhong"].text.text = Language.Common.PassvieSkillAttr.ming_zhong .."：" .. ming_zhong
	end
	self.node_list["NodeMingZhong"]:SetActive(ming_zhong > 0)

	if shan_bi and shan_bi >= 0 then
		self.node_list["TxtShanBi"].text.text = Language.Common.PassvieSkillAttr.shan_bi .."：" .. shan_bi
	end
	self.node_list["NodeShanBi"]:SetActive(shan_bi > 0)

	if bao_ji and bao_ji >= 0 then
		self.node_list["TxtBaoJi"].text.text = Language.Common.PassvieSkillAttr.bao_ji .."：" .. bao_ji
	end
	self.node_list["NodeBaoJi"]:SetActive(bao_ji > 0)

	if jian_ren and jian_ren >= 0 then
		self.node_list["TxtKangBao"].text.text = Language.Common.PassvieSkillAttr.jian_ren .."：" .. jian_ren
	end
	self.node_list["NodeKangBao"]:SetActive(jian_ren > 0)

	local cap = CommonDataManager.GetCapability(detail_cfg)
	if self.fight_text5 and self.fight_text5.text then
		self.fight_text5.text.text = cap >= 0 and cap or 0
	end
end

function ShengXiaoPieceView:SelectChange(data)
	if data == nil then return end
	if not self.is_move_state then
		self.move_data1 = nil
		self.move_data2 = nil
		if ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter ,data.y , data.x) > 0 then
			self.select_piece_value = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, data.y , data.x)
			self.show_detail_data = data
			self:OpenDetail()
		else
			local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
			if self.cur_chapter >= max_chatpter then
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChooseUseful)
			end
		end
	else
		local has_clear = false
		if self.move_data1 == nil then
			local type_1 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, data.y , data.x)
			if type_1 <= 0 then
				return
			end
			has_clear = true
			self.move_data1 = data
		else
			if self.move_data1.x == data.x and self.move_data1.y == data.y then
				self.move_data1 = nil
				has_clear = true
			end
		end
		if not has_clear then
			self.move_data2 = data
		end
		if self.move_data1 and self.move_data2 then
			local type1 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, self.move_data1.y , self.move_data1.x)
			local type2 = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.cur_chapter, self.move_data2.y , self.move_data2.x)
			if type1 > 0 or type2 > 0 then
				ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CHANGE_BEAD,
					self.move_data1.x - 1, self.move_data1.y - 1, self.move_data2.x - 1, self.move_data2.y - 1, self.cur_chapter - 1)
				self.move_data1 = nil
				self.move_data2 = nil
			else
				self.move_data2 = nil
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChooseUseful)
			end
		end
	end
	self:FLushItemHL()
end

function ShengXiaoPieceView:FlushAll()
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	local total_cap = 0
	for i = 1, 3 do
		local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_chapter - 1) * 3 + i - 1)
		self.node_list["TxtTitle" .. i].text.text = one_combine_cfg.name
		self.node_list["ImgIcon" .. i].image:LoadSprite(ResPath.GetXingHunIcon((self.cur_chapter - 1) * 3 + i))
		if self.fight_text[i] and self.fight_text[i].text then
			self.fight_text[i].text.text = CommonDataManager.GetCapability(one_combine_cfg)
		end
		total_cap = total_cap + CommonDataManager.GetCapability(one_combine_cfg)
		local actve_data_list = ShengXiaoData.Instance:GetActiveListByChatper(self.cur_chapter)
		self.node_list["ImgActivated" .. i]:SetActive(1 == actve_data_list[i] or false)			--因为actve_data_list传过来的是0,1 不是Boolean
		-- end
	end
	ShengXiaoData.Instance:SetChapterTotalCap(total_cap)
	self.node_list["TxtPage"].text.text = self.cur_chapter .. "/" .. max_chatpter
	local bundle, asset = ResPath.GetShengXiaoJianYing(self.cur_chapter)
	self.node_list["jianying_bg"].raw_image.enabled = false
	self.node_list["jianying_bg"].raw_image:LoadSprite(bundle, asset , function ()
		self.node_list["jianying_bg"].raw_image:SetNativeSize()
	end)

	local cur_chapter_cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_chapter)
	if cur_chapter_cfg == nil or next(cur_chapter_cfg) == nil then return end

	self.node_list["TxtBigTitle"].text.text = cur_chapter_cfg.name or ""
	self.node_list["AddText"].text.text = cur_chapter_cfg.display_des or ""
	UI:SetGraphicGrey(self.node_list["SkillIcon"], not ShengXiaoData.Instance:GetOneChapterActive(self.cur_chapter))
	self.node_list["SkillIcon"].image:LoadSprite(ResPath.GetShengXiaoSkillIcon(self.cur_chapter))

	if cur_chapter_cfg.chapter > 1 then
		if ShengXiaoData.Instance:GetOneChapterActive(self.cur_chapter) then
			self.node_list["PerCapImg"]:SetActive(false)
			self.node_list["SuitCapBg"]:SetActive(true)
			local attr_tab = CommonDataManager.GetAttributteNoUnderline(cur_chapter_cfg)
			local cap = CommonDataManager.GetCapability(attr_tab)
			self.node_list["SuitCap"].text.text = string.format(Language.Common.GaoZhanLi, cap)
		else
			self.node_list["PerCapImg"]:SetActive(true)
			self.node_list["SuitCapBg"]:SetActive(false)
		end
	else
		self.node_list["SuitCapBg"]:SetActive(false)
		self.node_list["PerCapImg"]:SetActive(false)
	end

	local info = ShengXiaoData.Instance:GetXingLingInfo(self.cur_chapter)
	local level = info.level

	local active_flag = ShengXiaoData.Instance:GetOneChapterActive(self.cur_chapter)
	local active_num = 0
	for i = 1, max_chatpter do
		if ShengXiaoData.Instance:GetOneChapterActive(i) then
			active_num = active_num + 1
		end
	end
	local extra_value = (cur_chapter_cfg.per_jingzhun / 100) or 0
	self.node_list["TxtAdd"].text.text = Language.ShengXiao.ExtraAdd
	self.node_list["TxtAdd_value"].text.text = ToColorStr(extra_value .. "%", TEXT_COLOR.GREEN)
	if self.fight_text4 and self.fight_text4.text then
		self.fight_text4.text.text = math.floor(ShengXiaoData.Instance:GetCombineCapByChapter(self.cur_chapter))
	end
	local is_show = ShengXiaoData.Instance:CalcErnieRedPoint()
	self.node_list["Effect"]:SetActive(is_show > 0)
	self:FlushPieceView()
end

PieceItem = PieceItem or BaseClass(BaseCell)

function PieceItem:__init()
	local bundle, asset = ResPath.GetMiscPreloadRes("PieceItem")
    self:SetInstance(ResPoolMgr:TryGetGameObject(bundle, asset))
	self.parent_view = nil
	self.node_list["Item"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
	self.node_list["icon"].image.enabled = false
	self.node_list["ImgHighlight"]:SetActive(false)

	self.drag_callback = BindTool.Bind(self.DragCallBack, self)
	self.node_list["icon"].uidrag:ListenBeginDragCallback(self.drag_callback)
	self.node_list["icon"].uidrag:ListenEndDragCallback(self.drag_callback)

	self.drag_event = BindTool.Bind(self.DragEvent, self)
	self.node_list["icon"].uidrag:ListenDropCallback(self.drag_event)
	self.node_list["Item"].uidrag:ListenDropCallback(self.drag_event)

	self.node_list["icon"].rect.anchoredPosition = Vector3(0, 0, 0)
	self.node_list["icon"].rect.sizeDelta = Vector2(66, 66)
end

function PieceItem:__delete()
	self.parent_view = nil
	self.node_list["icon"].uidrag:UnListenDropCallback(self.drag_event)
	self.node_list["Item"].uidrag:UnListenDropCallback(self.drag_event)

	self.node_list["icon"].uidrag:UnListenEndDragCallback(self.drag_callback)
	self.node_list["icon"].uidrag:UnListenBeginDragCallback(self.drag_callback)
end

function PieceItem:DragCallBack()
	self.node_list["icon"].rect.anchoredPosition = Vector3(0, 0, 0)
	self.node_list["icon"].rect.sizeDelta = Vector2(66, 66)
end

function PieceItem:DragEvent(drag_data, drag_obj)
	if self.data == nil then return end
	if nil ~= drag_data then
		local x = math.floor(drag_data / 100)
		local y = drag_data % 100

		local cur_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, self.data.y, self.data.x)
		local drag_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, y, x)
		ShengXiaoData.Instance:SetTianXiangSignBead({chapter = self.parent_view.cur_chapter - 1,y = y - 1, x = x - 1, type = cur_type})
		ShengXiaoData.Instance:SetTianXiangSignBead({chapter = self.parent_view.cur_chapter - 1,y = self.data.y - 1, x = self.data.x - 1, type = drag_type})
		self.parent_view:FlushPieceView()
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_CHANGE_BEAD,
			x - 1, y - 1, self.data.x - 1, self.data.y - 1, self.parent_view.cur_chapter - 1)
	end
end

function PieceItem:OnFlush()
	if self.data == nil then
		return
	end
	self.node_list["ImgHighlight"]:SetActive(false)
	self.node_list["icon"].image.enabled = false

	local cur_type = ShengXiaoData.Instance:GetTianxianInfoByPosAndChapter(self.parent_view.cur_chapter, self.data.y, self.data.x)
	if cur_type > 0 then
		self.node_list["icon"].image.enabled = true
		self.node_list["icon"].image:LoadSprite(ResPath.GetPieceIcon(cur_type))
	end
	self.node_list["icon"].rect.anchoredPosition = Vector3(0, 0, 0)
	self.node_list["icon"].rect.sizeDelta = Vector2(66, 66)
	self.node_list["icon"].uidrag:SetDragData(self.data.x * 100 + self.data.y)
	self.node_list["icon"].uidrag:SetIsCanDrag(true)
end

function PieceItem:FlushHL()
	if self.parent_view.move_data1 then
		if self.data.x == self.parent_view.move_data1.x and self.parent_view.move_data1.y == self.data.y then
			self.node_list["ImgHighlight"]:SetActive(true)
			return
		end
	end
	self.node_list["ImgHighlight"]:SetActive(false)
end

function PieceItem:SetShowAnim(is_show)
	self.node_list["Effect"]:SetActive(is_show)
end

function PieceItem:OnClickItem()
	self.node_list["icon"].rect.anchoredPosition = Vector3(0, 0, 0)
	self.node_list["icon"].rect.sizeDelta = Vector2(66, 66)

	self.parent_view:SelectChange(self.data)
end
