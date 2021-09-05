require("game/shenyin/shenyin_liehun_view")
require("game/shenyin/shenyin_qianghua_view")
require("game/shenyin/shenyin_shenyin_view")
require("game/shenyin/shenyin_tianxiang_view")
require("game/shenyin/shenyin_xilian_view")
require("game/shenyin/yinji_exchange_view")
require("game/shenyin/shenyin_tianxiang_all_attr")
require("game/shenyin/shenyin_tianxiang_change_view")
require("game/shenyin/shenyin_liehun_item")
require("game/shenyin/tianxiang_group_attr")
require("game/shenyin/shenyin_qianghua_attr")

local SHENYIN_TOGGLE = 1
local QIANGHUA_TOGGLE = 2
local XILIAN_TOGGLE = 3
local TIANXIANG_TOGGLE = 4
local LIEHUN_TOGGLE = 5
local EXCHANGE_TOGGLE = 6
ShenYinView = ShenYinView or BaseClass(BaseView)

function ShenYinView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/shenyinview_prefab", "ShenYinContent" ,{TabIndex.shenyin_shenyin}},
		{"uis/views/shenyinview_prefab", "QiangHuaContent" ,{TabIndex.shenyin_qianghua}},
		--{"uis/views/shenyinview_prefab", "XiLianContent" ,{TabIndex.shenyin_xilian}},
		--{"uis/views/shenyinview_prefab", "TianXiangContent" ,{TabIndex.shenyin_tianxiang}},
		-- {"uis/views/shenyinview_prefab", "LieHunContent" ,{TabIndex.shenyin_liehun}},
		{"uis/views/shenyinview_prefab", "ShenYinExchangeContent" ,{TabIndex.shenyin_exchange}},
		
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.shenyin_shenyin
	self.view_cfg = {}
	self.index_cfg = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.select_item_index = -1
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function ShenYinView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
	self:StopCountDown()
end

function ShenYinView:ReleaseCallBack()
	self.bing_gold_obj = nil
	-- for k,v in pairs(self.view_cfg) do
	-- 	if v then
	-- 		v:DeleteMe()
	-- 	end
	-- end
	-- self.view_cfg = {}
	self.index_cfg = {}
	self.red_point_list = {}
	self.tab_cfg = {}
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.shenyin_view then
		self.shenyin_view:DeleteMe()
		self.shenyin_view = nil
	end

	if self.shenyin_qianghua_view then
		self.shenyin_qianghua_view:DeleteMe()
		self.shenyin_qianghua_view = nil
	end

	if self.shenyin_xilian_view then
		self.shenyin_xilian_view:DeleteMe()
		self.shenyin_xilian_view = nil
	end

	if self.shenyin_tianxiang_view then
		self.shenyin_tianxiang_view:DeleteMe()
		self.shenyin_tianxiang_view = nil
	end

	if self.shenyin_liehun_view then
		self.shenyin_liehun_view:DeleteMe()
		self.shenyin_liehun_view = nil
	end

	if self.shenyin_exchange_view then
		self.shenyin_exchange_view:DeleteMe()
		self.shenyin_exchange_view = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	
	self:StopCountDown()
end

function ShenYinView:LoadCallBack()
	self.node_list["TxtTitle"].text.text = Language.Title.MingWen
	self.tab_cfg = {
		{name = Language.ShenYin.TabbarName[1],  bundle = "uis/images_atlas", asset = "tab_icon_shenyin_mingwen", func = "shenyin_shenyin", tab_index = TabIndex.shenyin_shenyin, remind_id = RemindName.ShenYin_ShenYin},
		{name = Language.ShenYin.TabbarName[2],  bundle = "uis/images_atlas", asset = "tab_icon_shenyin_zhuling", func = "shenyin_qianghua", tab_index = TabIndex.shenyin_qianghua, remind_id = RemindName.ShenYin_QiangHua},
		--{name = Language.ShenYin.TabbarName[3],  bundle = "uis/images_atlas", asset = "tab_icon_shenyin_jinglian", func = "shenyin_xilian", tab_index = TabIndex.shenyin_xilian, remind_id = RemindName.ShenYin_XiLian},
		--{name = Language.ShenYin.TabbarName[4],  bundle = "uis/images_atlas", asset = "tab_icon_shenyin_mingxiang", func = "shenyin_tianxiang", tab_index = TabIndex.shenyin_tianxiang, remind_id = RemindName.ShenYin_TianXiang},
		-- {name = Language.ShenYin.TabbarName[5],  bundle = "uis/images_atlas", asset = "tab_icon_shenyin_ningwen", func = "shenyin_liehun", tab_index = TabIndex.shenyin_liehun, remind_id = RemindName.ShenYin_LieHun},
		--{name = Language.ShenYin.TabbarName[6],  bundle = "uis/images_atlas", asset = "tab_icon_shenyin_duihuan", func = "shenyin_exchange", tab_index = TabIndex.shenyin_exchange, remind_id = RemindName.ShenYin_Exchange},
	}
--InlayContent_BG2
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], self.tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnBtnClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnAddBtn, self))
	self.node_list["TaiZi"]:SetActive(false)
	self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg", function()
			self.node_list["UnderBg"]:SetActive(true)
		end)

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Ming_Wen)
	if is_open then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
			end)
				node_list["TextYiZhe"].text.text = data.button_name
				self:StartCountDown(data, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end
end


-- 一折抢购跳转
function ShenYinView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 一折抢购跳转
function ShenYinView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ShenYinView:OnBtnClose()
	self:Close()
end

function ShenYinView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function ShenYinView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:FlushGold()
	-- self:InitTab()

	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN)
end

function ShenYinView:FlushGold()
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function ShenYinView:FlushScore()
	local exchange_score = ShenYinData.Instance:GetPastureSpiritImprintScoreInfo()
	self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(exchange_score)
end

function ShenYinView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ShenYinView:PlayerDataChangeCallback(attr_name, value, old_value)
	if (attr_name == "gold" or attr_name == "bind_gold") and
		self:GetShowIndex() ~= TabIndex.shenyin_exchange then
		-- local count = value
		local count = CommonDataManager.ConverMoney(value)
		if attr_name == "bind_gold" then
			self.node_list["BindGoldText"].text.text = count
		else
			self.node_list["GoldText"].text.text = count
		end
	end
end

function ShenYinView:OnAddBtn()
	local cur_index = self:GetShowIndex()
	local tab = self:GetTabByIndex(cur_index)

	if cur_index == TabIndex.shenyin_exchange then
		self:ChangeToIndex(TabIndex.shenyin_shenyin)
	else
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		ViewManager.Instance:Open(ViewName.VipView)
	end
end

function ShenYinView:GetTabByIndex(index)
	return self.index_cfg[index] or SHENYIN_TOGGLE
end

function ShenYinView:ShowIndexCallBack(index, index_nodes)

	self.tabbar:ChangeToIndex(index)

	if nil ~= index_nodes then
		if index == TabIndex.shenyin_shenyin then
			self.shenyin_view = ShenYinShenYinView.New(index_nodes["ShenYinContent"])
		elseif index == TabIndex.shenyin_qianghua then
			self.shenyin_qianghua_view = ShenYinQiangHuaView.New(index_nodes["QiangHuaContent"])
		elseif index == TabIndex.shenyin_xilian then
			self.shenyin_xilian_view = ShenYinXiLianView.New(index_nodes["XiLianContent"])
		elseif index == TabIndex.shenyin_tianxiang then
			self.shenyin_tianxiang_view = ShenYinTianXiangView.New(index_nodes["TianXiangContent"])
		-- elseif index == TabIndex.shenyin_liehun then
		-- 	self.shenyin_liehun_view = ShenYinLieHunView.New(index_nodes["LieHunContent"])
		elseif index == TabIndex.shenyin_exchange then
			self.shenyin_exchange_view = ShenYinYinJiExchangeView.New(index_nodes["ShenYinExchangeContent"])
		end
	end

	self:FlushGold()
	self:ChangeGoldType(index)

	if index == TabIndex.shenyin_shenyin then
		self.shenyin_view:UIsMove()
		self.shenyin_view:OpenCallBack()
		self.shenyin_view:Flush()
	elseif index == TabIndex.shenyin_qianghua then
		self.shenyin_qianghua_view:UIsMove()
		self.shenyin_qianghua_view:OpenCallBack()
		self.shenyin_qianghua_view:Flush()
	elseif index == TabIndex.shenyin_xilian then
		self.shenyin_xilian_view:UIsMove()
		self.shenyin_xilian_view:OpenCallBack()
		self.shenyin_xilian_view:Flush()
	elseif index == TabIndex.shenyin_tianxiang then
		self.shenyin_tianxiang_view:UIsMove()
		self.shenyin_tianxiang_view:OpenCallBack()
		self.shenyin_tianxiang_view:Flush()
	-- elseif index == TabIndex.shenyin_liehun then
	-- 	self.shenyin_liehun_view:OpenCallBack()
	-- 	self.shenyin_liehun_view:Flush()
	elseif index == TabIndex.shenyin_exchange then
		self.shenyin_exchange_view:UIsMove()
		self.shenyin_exchange_view:OpenCallBack()
		self:FlushScore()
		self.shenyin_exchange_view:Flush()
	end

	if index == TabIndex.shenyin_exchange then
		self.node_list["UnderBg"]:SetActive(false)
	else
		self.node_list["UnderBg"]:SetActive(true)
	end
end

function ShenYinView:AsyncLoadView(tab)
	local cfg = self.view_cfg[tab]
	if nil == cfg then return end
	if cfg.view == nil then
		local async_loader = AllocAsyncLoader(self, cfg.fun_name)
		async_loader:Load(cfg.prefab[1], cfg.prefab[2],
			function(obj)
				if IsNil(obj) then
					return
				end
				obj.transform:SetParent(cfg.content.transform,false)
				obj = U3DObject(obj)
				cfg.view = cfg.view_name.New(obj)
				cfg.view:OpenCallBack(self.select_item_index)
			end)
	end
end

function ShenYinView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	
	local tab = self:GetTabByIndex(cur_index)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_t) do
		if k == "all" then 
			if cur_index == TabIndex.shenyin_shenyin and self.shenyin_view then
				self.shenyin_view:Flush(param_t)
			elseif cur_index == TabIndex.shenyin_qianghua and self.shenyin_qianghua_view then
				self.shenyin_qianghua_view:Flush(param_t)
			elseif cur_index == TabIndex.shenyin_xilian and self.shenyin_xilian_view then
				self.shenyin_xilian_view:Flush(param_t)
			elseif cur_index == TabIndex.shenyin_tianxiang and self.shenyin_tianxiang_view then
				self.shenyin_tianxiang_view:Flush(param_t)
			-- elseif cur_index == TabIndex.shenyin_liehun and self.shenyin_liehun_view then
			-- 	self.shenyin_liehun_view:Flush(param_t)
			elseif cur_index == TabIndex.shenyin_exchange and self.shenyin_exchange_view then
				self.shenyin_exchange_view:Flush(param_t)
				self:FlushScore()				
			end
			ShenYinCtrl.Instance:FlushRecycleView()
		end
	end
end

function ShenYinView:SetSelectSlot(slot)
	self.select_item_index = slot
end

function ShenYinView:FlushTabbar()	
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function ShenYinView:ChangeGoldType(cur_index)
	local bundle, asset = "uis/images_atlas","icon_gold_5"
	if cur_index == TabIndex.shenyin_exchange then
		bundle, asset = ResPath.GetShenYin("shenyin_score")
		self.node_list["BindGoldNode"]:SetActive(false)
	else
		self.node_list["BindGoldNode"]:SetActive(true)
	end

	self.node_list["ImgGold"].image:LoadSprite(bundle, asset)

	local btn_gold = self.node_list["ImgGold"].gameObject:AddComponent(typeof(UnityEngine.UI.Button))
	-- btn_gold.transition = UnityEngine.UI.Selectable.Transition.None
	self.node_list["ImgGold"].image.raycastTarget = true
	self.node_list["ImgGold"].button:AddClickListener(function ()
		TipsCtrl.Instance:OpenItem({is_bind = 1, item_id = 90018, num = 1})
	end)
end