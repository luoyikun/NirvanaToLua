HongBaoView = HongBaoView or BaseClass(BaseView)

function HongBaoView:__init()
	self.ui_config = {{"uis/views/tips/hongbaotips_prefab", "HongBaoView"}}
	self.play_audio = true
	self.hongbao_type = RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON
end

function HongBaoView:__delete()

end

function HongBaoView:ReleaseCallBack()
	for k,v in pairs(self.panel3_cell_list) do
		v:DeleteMe()
	end
	self.panel3_cell_list = {}
	for k,v in pairs(self.panel4_cell_list) do
		v:DeleteMe()
	end
	self.panel4_cell_list = {}
	self.panel3_list = nil
	self.panel4_list = nil


end

function HongBaoView:CloseCallBack()

end

function HongBaoView:LoadCallBack()
	-- 监听
	self.node_list["BtnLuckButton"].button:AddClickListener(BindTool.Bind(self.OnClickLuck, self))
	self.node_list["BtnNormalButton"].button:AddClickListener(BindTool.Bind(self.OnClickNormal, self))
	self.node_list["BtnOKButton"].button:AddClickListener(BindTool.Bind(self.OnClickSend, self))
	self.node_list["BtnBGClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnCancelButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnConfirmPanel3"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnConfirmPanel4"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	self.node_list["BtnNextPanel3"].button:AddClickListener(BindTool.Bind(self.NextBtnClick, self))
	self.node_list["BtnNextPanel4"].button:AddClickListener(BindTool.Bind(self.NextBtnClick, self))
	self.node_list["TotalInput"].input_field.onValueChanged:AddListener(BindTool.Bind(self.OnClickSingleGold, self))
	self.node_list["CountInput"].input_field.onValueChanged:AddListener(BindTool.Bind(self.OnClickCount, self))


	self.node_list["TotalInput"].input_field.onValueChanged:AddListener(BindTool.Bind(self.TotalValueChange, self))
	self.node_list["CountInput"].input_field.onValueChanged:AddListener(BindTool.Bind(self.CountValueChange, self))


	self.panel3_cell_list = {}
	self.panel4_cell_list = {}
end


function HongBaoView:CreateLogList(is_suc)
	local list = nil
	local cell_list = nil
	if is_suc then
		self.panel3_list = self.node_list["Panel3List"]
		list = self.panel3_list
		cell_list = self.panel3_cell_list
	else
		self.panel4_list = self.node_list["Panel4List"]
		list = self.panel4_list
		cell_list = self.panel4_cell_list
	end
	local list_delegate = list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return #HongBaoData.Instance:GetRedPaperLog()
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = cell_list[cell]
		if cell_item == nil then
			cell_item = HongbaoLogCell.New(cell.gameObject)
			cell_list[cell] = cell_item
		end
		local data_list = HongBaoData.Instance:GetRedPaperLog()
		local data = data_list[data_index + 1]
		cell_item:SetData(data)
	end
end

function HongBaoView:TotalValueChange(value)
	if value == "" then
		return
	end

	local total_num = tonumber(value)

	self.node_list["TotalInput"].input_field.text = total_num

end

function HongBaoView:CountValueChange(value)
	if value == "" then
		return
	end
	local count_num = tonumber(value)


	self.node_list["CountInput"].input_field.text = count_num
end

function HongBaoView:OpenCallBack()
	self:Flush()
end

function HongBaoView:OnFlush()
	if self.node_list["BtnNextPanel3"] and self.node_list["BtnNextPanel4"] then
		local open_tpye = HongBaoData.Instance:GetOpenType()
		if open_tpye == GameEnum.HONGBAO_SEND then
			self:ShowView(1)
			local gold = HongBaoData.Instance:GetDailyCanSendGold()
			self.node_list["TxtCanSengGold"].text.text = string.format(Language.RedEnvelopes.FaHongBao, gold)
		else
			local red_result = HongBaoData.Instance:GetRedPaperFetchResult()
			if red_result.notify_reason ~= 0 then
				self:ShowView(4)
				self:FlushFailView()
			else
				self:ShowView(3)
				self:FlushSuccView()
			end
			local data = HongBaoData.Instance:GetRedPaperDetailInfo()
			--优先判断是否有boss_id
			if data.boss_id and data.boss_id > 0 then
				local monster_cfg = BossData.Instance:GetMonsterInfo(data.boss_id)
				if nil ~= monster_cfg then
					local headid = monster_cfg.headid
					local bundle, asset = ResPath.GetBossIcon(headid)
					self.node_list["ImgIconImage3"]:SetActive(true)
					self.node_list["ImgIconImage4"]:SetActive(true)
					self.node_list["Panel3Avatar"]:SetActive(false)
					self.node_list["Panel4Avatar"]:SetActive(false)
					self.node_list["ImgIconImage3"].image:LoadSprite(bundle, asset)
					self.node_list["ImgIconImage4"].image:LoadSprite(bundle, asset)
					return
				end
			end
			if data.avatar_key_small then
				AvatarManager.Instance:SetAvatarKey(data.creater_uid, data.avatar_key_big, data.avatar_key_small)
				if data.avatar_key_small == 0 then
					local bundle, asset = AvatarManager.GetDefAvatar(data.prof, false, data.sex)
					self.node_list["ImgIconImage3"]:SetActive(true)
					self.node_list["ImgIconImage4"]:SetActive(true)
					self.node_list["Panel3Avatar"]:SetActive(false)
					self.node_list["Panel4Avatar"]:SetActive(false)
					self.node_list["ImgIconImage3"].image:LoadSprite(bundle, asset)
					self.node_list["ImgIconImage4"].image:LoadSprite(bundle, asset)
				else
					local function callback(path)
						if self.panel3_list == nil then return end
						if path == nil then
							path = AvatarManager.GetFilePath(data.creater_uid, false)
						end
						local avatar = nil
						if red_result.notify_reason ~= 0 then
							avatar = self.node_list["Panel4Avatar"]
						else
							avatar = self.node_list["Panel3Avatar"]
						end

                        -- NOTE:
                        -- FIXME:
                        assert(nil)
						avatar.raw_image:LoadURLSprite(path, function ()
							if data.avatar_key_small == 0 then
								self.node_list["ImgIconImage3"]:SetActive(false)
								self.node_list["ImgIconImage4"]:SetActive(false)
								self.node_list["Panel3Avatar"]:SetActive(true)
								self.node_list["Panel4Avatar"]:SetActive(true)
							end
						end)

					end
					AvatarManager.Instance:GetAvatar(data.creater_uid, false, callback)
				end
			end
		end

		local hongbao_type = HongBaoData.Instance:GetHongbaoType()
		local is_show_next = true
		if hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
			is_show_next = #HongBaoData.Instance:GetCurServerHongBaoIdList() > 0
		else
			is_show_next = #HongBaoData.Instance:GetCurHongBaoIdList() > 0
		end
		self.node_list["BtnNextPanel3"]:SetActive(is_show_next)
		self.node_list["BtnNextPanel4"]:SetActive(is_show_next)
		self.node_list["BtnConfirmPanel3"]:SetActive(not is_show_next)
		self.node_list["BtnConfirmPanel4"]:SetActive(not is_show_next)
	end
end

function HongBaoView:ShowView(index)
	for i = 1, 4 do
		if i == index then
			self.node_list["panel" .. i]:SetActive(true)
		else
			self.node_list["panel" .. i]:SetActive(false)
		end
	end
end

function HongBaoView:OnClickLuck()
	local gold = HongBaoData.Instance:GetDailyCanSendGold()
	if gold <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.NotGoldToSend)
		return
	end
	self.hongbao_type = RED_PAPER_TYPE.RED_PAPER_TYPE_RAND
	self:ShowView(2)
	self:FlushTotalView()
end

function HongBaoView:OnClickNormal()
	local gold = HongBaoData.Instance:GetDailyCanSendGold()
	if gold <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.NotGoldToSend)
		return
	end
	self.hongbao_type = RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON
	self:ShowView(2)
	self:FlushTotalView()
end

function HongBaoView:OnClickSend()
	local total_num = self.node_list["TotalInput"].input_field.text
	if total_num == "" or tonumber(total_num) <= 0 then
		if self.hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON then
			SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.NotTotalNormal)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.NotTotalLuck)
		end
		return
	end

	local count_num = self.node_list["CountInput"].input_field.text
	if count_num == "" or tonumber(count_num) <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.NotCountNum)
		return
	end

	total_num = tonumber(total_num)
	count_num = tonumber(count_num)

	local send_gold = 0
	if self.hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON then
		send_gold = total_num * count_num
	else
		send_gold = total_num
	end
	local can_send_gold = HongBaoData.Instance:GetDailyCanSendGold()
	if send_gold > can_send_gold then
		local des = string.format(Language.RedEnvelopes.CanSendGoldDes, can_send_gold)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end

	local yes_button_text = Language.Common.Confirm
	local no_button_text = Language.Common.Cancel

	local desc = ""

	local function ok_func()
		HongBaoCtrl.Instance:SendRedPaperCreateReq(self.hongbao_type, total_num, count_num)
		self:Close()
	end

	if self.hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_RAND then
		if total_num < count_num then
			SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.IsLessThan)
			return
		end
		desc = string.format(Language.RedEnvelopes.IsPaiFaPinShouQi, count_num, total_num)
		TipsCtrl.Instance:ShowCommonAutoView(nil, desc, ok_func)
	else
		total_num = total_num * count_num
		desc = string.format(Language.RedEnvelopes.IsPaiFaPutong, count_num, total_num)
		TipsCtrl.Instance:ShowCommonAutoView(nil, desc, ok_func)
	end
end

function HongBaoView:OnClickClose()
	self:Close()
end

function HongBaoView:NextBtnClick()
	local hongbao_type = HongBaoData.Instance:GetHongbaoType()
	if hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
		HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurServerHongBaoIdList()[1].id)
	else
		HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurHongBaoIdList()[1].id)
	end
end

function HongBaoView:OnClickGet()

end

--刷新选择红包类型
function HongBaoView:FlushChoseView()

end

--刷新金额界面
function HongBaoView:FlushTotalView()
	self.node_list["TotalInput"].input_field.text = ""
	self.node_list["CountInput"].input_field.text = ""
	if self.hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON then
		self.node_list["TxtTotal"].text.text = Language.RedEnvelopes.OneStr
	else
		self.node_list["TxtTotal"].text.text = Language.RedEnvelopes.TotalStr
	end
end

--刷新成功界面
function HongBaoView:FlushSuccView()
	local red_result = HongBaoData.Instance:GetRedPaperFetchResult()
	local TxtMoney = self.node_list["TxtMoneyString"].text.text
	self.node_list["TxtFromName"].text.text = string.format(Language.RedEnvelopes.HuoDe,red_result.creater_name)
	self.node_list["TxtMoneyText"].text.text = red_result.fetch_gold
	if red_result.type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
		TxtMoney = Language.RedEnvelopes.moneyBang
	else
		TxtMoney = Language.RedEnvelopes.MoneyFei
	end
	if red_result.creater_name and red_result.creater_name == "福利BOSS" then
		TxtMoney = Language.RedEnvelopes.moneyBang
	end
	if self.panel3_list == nil then
		self:CreateLogList(true)
	else
		if self.panel3_list.scroller.isActiveAndEnabled then
			self.panel3_list.scroller:ReloadData(0)
		end
	end
end

--刷新失败界面
function HongBaoView:FlushFailView()
	if self.panel4_list == nil then
		self:CreateLogList()
	else
		if self.panel4_list.scroller.isActiveAndEnabled then
			self.panel4_list.scroller:ReloadData(0)
		end
	end
end

function HongBaoView:OnClickSingleGold()
	local can_send_gold = HongBaoData.Instance:GetDailyCanSendGold() or 0
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.TotalValueChange, self), nil, can_send_gold)
end

function HongBaoView:OnClickCount()
	if self.node_list["TotalInput"].input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ShuRuJinE)
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.CountValueChange, self), nil, 100)
end


HongbaoLogCell = HongbaoLogCell or BaseClass(BaseCell)

function HongbaoLogCell:__init(instance)
end

function HongbaoLogCell:__delete()

end

function HongbaoLogCell:OnFlush()
	self.node_list["ImgLuck"]:SetActive(self.data.is_luck == true)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtScore"].text.text = self.data.gold_num .. Language.RedEnvelopes.moneyBang
end
