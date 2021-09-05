BaoBaoBlessView = BaoBaoBlessView or BaseClass(BaseRender)
local BAOBAONUM = 5
local MOVE_TIME = 0.5
function BaoBaoBlessView:UIsMove()
	UITween.AlpahShowPanel(self.node_list["ImageBgBW"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["ImageListBW"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["ButtonHelp"] , Vector3(-166 , 50 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["ButtonFunc"] , Vector3(73 , 50 , 0 ) , MOVE_TIME )
end

function BaoBaoBlessView:__init(instance, mother_view)
	for i = 1, 3 do	
		self.node_list["OnClickQifu" .. i].button:AddClickListener(BindTool.Bind(self.OnClickQifu, self , i))
	end
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnClickDetial, self))
	self.node_list["ButtonFunc"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))

	self.baobao_model = {}
	self:SetYuanBaoIcon()
end

function BaoBaoBlessView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for k,v in pairs(self.baobao_model) do
		v:DeleteMe()
	end
	self.baobao_model = {}
end

function BaoBaoBlessView:OnClickQifu(bless_type)
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BABYHALDOFF)
	local gold_num = 0
	local bless = ""
	if qifu_tree ~= nil then
		if bless_type == 1 then
			gold_num = is_open and qifu_tree[1].activity_qifu_consume_bind_gold or qifu_tree[1].qifu_consume_bind_gold
			bless = string.format(Language.Marriage.CommonBabyTips, gold_num)
		elseif bless_type == 2 then
			gold_num = is_open and qifu_tree[2].activity_qifu_consume_gold or qifu_tree[2].qifu_consume_gold
			bless = string.format(Language.Marriage.SilverBabyTips, gold_num)
		elseif bless_type == 3 then
			gold_num = is_open and qifu_tree[3].activity_qifu_consume_gold or qifu_tree[3].qifu_consume_gold
			bless = string.format(Language.Marriage.GoldBabyTips, gold_num)
		end
	end
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(BaobaoCtrl.SendBabyBlessReq, bless_type), nil, bless, nil, nil, false)
end

function BaoBaoBlessView:SetYuanBaoIcon()
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	if not qifu_tree then return end

	for i = 1, 3 do	
		if tonumber(qifu_tree[i].qifu_consume_bind_gold) > 0 then
			self.node_list["QifuIcon" .. i].image:LoadSprite(ResPath.GetDiamonIcon("5_bind"))
		else
			self.node_list["QifuIcon" .. i].image:LoadSprite(ResPath.GetDiamonIcon("5"))
		end
	end
end

function BaoBaoBlessView:OnClickDetial()
	local tips_id = 279 -- 宝宝帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BaoBaoBlessView:OnClickBuy()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.lover_uid <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotLoverDes)
		return
	end

	local born_again_cfg = BaobaoData.Instance:GetBabyChaoShengGold()
	local born_consume = ""
	if born_again_cfg ~= nil then
		born_consume = string.format(Language.Marriage.BornAgainConSume, born_again_cfg)
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(BaobaoCtrl.SendBabyChaoshengReq), nil, born_consume, nil, nil, false)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.BaobaoMax)
	end
end

function BaoBaoBlessView:OnFlush()
	self:FlushView()
end

function BaoBaoBlessView:FlushView()
	local qifu_tree = BaobaoData.Instance:GetBabyQiFuTreeCfg()
	if qifu_tree ~= nil then
		self.node_list["QifuCost" .. 1].text.text = qifu_tree[1].qifu_consume_bind_gold
		self.node_list["QifuCost" .. 2].text.text = qifu_tree[2].qifu_consume_gold
		self.node_list["QifuCost" .. 3].text.text = qifu_tree[3].qifu_consume_gold
	end

	local baby = BaobaoData.Instance:GetBaoBaoInfoCfg()
	for i = 1, 3 do
		if baby[i - 1] ~= nil then
			self.node_list["FightNum" .. i].text.text = CommonDataManager.GetCapability(baby[i - 1]) * 2
			local str = string.format(Language.Marriage.BaobaoName,baby[i - 1] and baby[i - 1].name or "")
			self.node_list["BaoBaoName" .. i].text.text = str
			self.node_list["TxtBtnName" .. i].text.text = str
		end

		if self.baobao_model[i] == nil then
			self["baobao" .. i] = self.node_list["BaobaoDisplay" .. i]
			local baobao_model = RoleModel.New("baobao_bless_role_model"..i)
			baobao_model:SetDisplay(self["baobao" .. i].ui3d_display)
			baobao_model:SetMainAsset(ResPath.GetSpiritModel(BaobaoData.BabyModel[i]))
			baobao_model:SetRotation(Vector3(0, -30, 0))
			self.baobao_model[i] = baobao_model
		end
	end
	local baobao_data = BaobaoData.Instance:GetHaveBaoBaoData()
	local baobao_chaosheng = BaobaoData.Instance:GetBabyChaoShengCount() or 0
	self.node_list["BaoBaoNum"].text.text = string.format(Language.MarryBaoBao.BaoBaoNum , #baobao_data .. " / " .. BAOBAONUM + baobao_chaosheng)

	local active_state = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BABYHALDOFF)
	local time = active_state and active_state.next_time - TimeCtrl.Instance:GetServerTime() or 0

	if time > 0 then
		for i = 1, 3 do
			if i == 1 and qifu_tree[i] then 
				self.node_list["TxtDiscount" .. i].text.text = qifu_tree[i].activity_qifu_consume_bind_gold or ""
			elseif qifu_tree[i] then
				self.node_list["TxtDiscount" .. i].text.text = qifu_tree[i].activity_qifu_consume_gold or ""
			end
		end
		self.node_list["ActivetyPanle"]:SetActive(true)
		self:SetActTime(time)
	else
		self.node_list["ActivetyPanle"]:SetActive(false)
	end

	for i = 1, 3 do
		self.node_list["TxtDiscount" .. i]:SetActive(time > 0)
		self.node_list["ImgDiscount" .. i]:SetActive(time > 0)
	end
end

-- 活动倒计时
function BaoBaoBlessView:SetActTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 1)
			if left_time <= 0 then
				self.node_list["ActivetyPanle"]:SetActive(false)
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond(left_time, 10)
		end
		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 1, diff_time_func)
	end
end
