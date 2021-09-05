XunYouView = XunYouView or BaseClass(BaseView)

function XunYouView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "XunYouView"}}
	self.view_layer = UiLayer.Normal
	self.is_show = true
end

function XunYouView:__delete()
	
end

function XunYouView:LoadCallBack()
	-- self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose, self))
	self.node_list["BtnSaRed"].button:AddClickListener(BindTool.Bind(self.ClickRed, self))
	self.node_list["BtnSaHua"].button:AddClickListener(BindTool.Bind(self.ClickHua, self))
end

function XunYouView:OpenCallBack()
	self:Flush()
end
function XunYouView:ClickRed()
	local info = MarriageData.Instance:GetXunYouInfo()
	local cfg = MarriageData.Instance:GetXunYouCfg()
	local hunyan_type = info.hunyan_type
	if not cfg[hunyan_type + 1] then return end
	if cfg[hunyan_type + 1].free_sa_red_bag_count + info.buy_throw_count - info.throw_count <= 0 then
		local yes_func = function()
			MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_SA_HONGBAO, 1)
		end
		local describe = string.format(Language.Marriage.BuyRedBao, cfg[hunyan_type + 1].red_bag_need_gold)
		TipsCommonAutoView.AUTO_VIEW_STR_T[""] = nil 								--有其他地方莫名其妙把""设为true
		TipsCtrl.Instance:ShowCommonAutoView("xunyou_red", describe, yes_func, nil, nil, nil, nil, nil, nil, true)
		return
	end

	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_SA_HONGBAO)
end

function XunYouView:ClickHua()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local info = MarriageData.Instance:GetXunYouInfo()
	local cfg = MarriageData.Instance:GetXunYouCfg()
	local hunyan_type = info.hunyan_type
	if not cfg[hunyan_type + 1] then return end
	if cfg[hunyan_type + 1].free_give_flower_count + info.buy_flower_count - info.flower_count > 0 then
		FlowersCtrl.Instance:SendFlowersReq(0, 0, main_vo.lover_uid, 0, 1)
	else
		local yes_func = function()
			MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_GIVE_FLOWER)
		end
		local describe = string.format(Language.Marriage.BuyFlower, cfg[hunyan_type + 1].flower_need_gold)
		TipsCommonAutoView.AUTO_VIEW_STR_T[""] = nil 								--有其他地方莫名其妙把""设为true
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function XunYouView:OnFlush(param)
	local info = MarriageData.Instance:GetXunYouInfo()
	local cfg = MarriageData.Instance:GetXunYouCfg()
	local hunyan_type = info.hunyan_type
	if not cfg[hunyan_type + 1] then return end
	self.node_list["RedCount"].text.text = cfg[hunyan_type + 1].free_sa_red_bag_count + info.buy_throw_count- info.throw_count
	self.node_list["HuaCount"].text.text = cfg[hunyan_type + 1].free_give_flower_count + info.buy_flower_count - info.flower_count
end