ShenGeData = ShenGeData or BaseClass()

SHENGE_SYSTEM_REQ_TYPE = {
		SHENGE_SYSTEM_REQ_TYPE_ALL_INFO = 0,					-- 请求所有信息
		SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE = 1,					-- 分解		p1 虚拟背包索引
		SHENGE_SYSTEM_REQ_TYPE_COMPOSE = 2,						-- 合成		p1 物品1的虚拟背包索引 p2 物品2的虚拟背包索引 p3 物品1的虚拟背包索引；
		SHENGE_SYSTEM_REQ_TYPE_SET_RUAN = 3,					-- 装备符文 p1 虚拟背包索引  p2 符文页 p3 格子索引；
		SHENGE_SYSTEM_REQ_TYPE_CHANGE_RUNA_PAGE = 4,			-- 切换符文页 p1 符文页
		SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG = 5,					-- 抽奖 p1 次数；
		SHENGE_SYSTEM_REQ_TYPE_UPLEVEL = 6,						-- 升级 符文 p1 0 背包 1 符文页  p2 背包索引/ 符文页  p3 格子索引
		SHENGE_SYSTEM_REQ_TYPE_SORT_BAG = 7,					-- 整理背包
		SHENGE_SYSTEM_REQ_TYPE_UNLOAD_SHENGE = 8,				-- 拆除符文		p1 符文页 	p2格子索引
		SHENGE_STYTEM_REQ_TYPE_CLEAR_PAGE = 9,					-- 清除符文页	p1 符文页
		SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG = 10,			-- 升级掌控		p1 0:升级1次, 1:升级10次
		SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR = 11,				-- 升级掌控后重算战斗力
		SHENGE_SYSTEM_REQ_TYPE_XILIAN = 12,						-- 神格神躯洗炼 p1 神躯id  p2 洗炼点  p3是否自动购

}

SHENGE_SYSTEM_INFO_TYPE ={
		SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE = 0,				-- 背包单个符文信息											p2 count数量
		SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO = 1,				-- 背包全部信息				p1当前使用符文页				p2 count数量
		SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO = 2,				-- 符文页单个的符文信息		p1符文页 						p2 count数量			p3 符文页历史最高等级
		SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO = 3,			-- 符文页的全部符文信息		p1符文页						p2 count数量			p3 符文页历史最高等级
		SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO = 4,			-- 奖品列表					p1 已使用免费次数					p2 count数量		p3 免费抽奖剩余时间
		SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO = 5,		-- 精华信息																		p3 精华积分
		SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX = 6,			-- 符文页					p1 当前使用符文页
		SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO = 7,		-- 合成信息
		SHENGE_SYSTEM_INFO_TYPE_ACTIVE_COMBINE_INFO = 8,		-- 激活的组合索引			p1 组合索引
		SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO = 9,				-- 抽奖信息					p1 已用免费抽奖次数									p3 下次抽奖cd
}

ShenGeEnum = {
	SHENGE_SYSTEM_BAG_MAX_GRIDS = 250,								-- 背包最大格子数量不可变 数据库
	SHENGE_SYSTEM_MAX_SHENGE_PAGE = 5,								-- 最大符文页 不可变 数据库
	SHENGE_SYSTEM_CUR_SHENGE_PAGE = 3,								-- 当期符文页数
	SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID = 16,							-- 当前普通符文格子数
	SHENGE_SYSTEM_MAX_SHENGE_GRID = 20,								-- 普通符文最大格子数 不可变 数据库
	SHENGE_SYSTEM_MAX_SHENGE_LEVEL = 30,							-- 最大符文等级
	SHENGE_SYSTEM_PER_SHENGE_PAGE_MAX_ZHONGJI_SHENGE_COUNT = 4,		-- 符文页终极符文最大个数
	SHENGE_SYSTEM_RECOVER_TIME_INTERVAL = 5,
	SHENGE_SYSTEM_QUALITY_MAX_VALUE = 4								-- 神格品质最大值(掌控的格子数)
}

local ShenGeZhanKongEnum =
{
	"gongji_pro",
	"fangyu_pro",
	"maxhp_pro",
	"shanbi_pro",
	"baoji_pro",
	"kangbao_pro",
	"mingzhong_pro",
}

-- 神格召星的位置
ShenGeBlessEnum = 
{
	[0] = 8,				-- 对应8号位置 
	[1] = 8,				-- 对应8号位置
	[2] = 7,				-- 对应7号位置
	[3] = 6,				-- 对应6号位置
	[4] = 5,				-- 对应5号位置
	[5] = 4,				-- 对应4号位置
	[10] = 1,				-- 对应1号位置
	[11] = 3,				-- 对应3号位置
	[12] = 2,				-- 对应2号位置
}

SHENGE_AUTOMATIC_COMPOSE_FLAG = {									 -- 神格合成自动合成
	NO_START = 0,													 -- 未开始
	COMPOSE_REQUIRE = 1,											 -- 合成请求
	COMPOSE_CONTINUE = 2,											 -- 合成结束
}
SHENGE_QUYU_MAX_COUNT = {
	[1] = "ultimate_shenge_type_max_count" ,			--特殊
	[2] = "normal_shenge_type_max_count" ,				--普通
	[3] = "normal_shenge_type_max_count" ,				--普通
	[4] = "normal_shenge_type_max_count" ,				--普通
}
SHENGE_HAVE_DATA = {
	NO_HAVE = -1,											-- 点击无数据
	HAVE = 1,												-- 点击有数据
}
local FenJieTiShiCount = 20		-- 星辉大于20提示红点
function ShenGeData:__init()
	if nil ~= ShenGeData.Instance then
		return
	end
	ShenGeData.Instance = self

	self.bag_list_cont = 0
	self.jifen_count = 0
	self.zhangkong_is_rolling = false
	self.is_can_play_bless_ani = true
	self.is_can_play_zhangkong_ani = true

	self.shen_ge_system_info = {}
	self.shen_ge_item_info = {}
	self.shen_ge_bag_info = {}
	self.shen_ge_bless_reward_list = {}

	self.shen_ge_inlay_info = {}
	self.shen_ge_inlay_level = {}
	self.shen_ge_inlay_history_level = {}

	self.one_key_decompose_data_list = {}
	self.same_types_num_list = {}
	self.same_types_total_num_list = {}
	self.shenqu_list = {}

	self.shenge_quality_info = {}

	self.shen_ge_cfg_auto = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto")
	self.attribute_cfg = ListToMapList(self.shen_ge_cfg_auto.attributescfg, "quality", "types")
	self.attribute_types_cfg = ListToMapList(self.shen_ge_cfg_auto.attributescfg, "types")
	self.shenge_preview_cfg = ListToMapList(self.shen_ge_cfg_auto.attributescfg, "types", "quality", "level")
	self.shenge_quyu_need_cfg = ListToMapList(self.shen_ge_cfg_auto.attributescfg, "types")
	self.item_id_to_shen_ge_cfg = ListToMapList(self.shen_ge_cfg_auto.item_id_to_shenge, "quality", "types")
	self.choujiang_cfg = ListToMapList(self.shen_ge_cfg_auto.choujiangcfg, "seq")
	self.compose_shen_ge = ListToMapList(self.shen_ge_cfg_auto.decomposecfg, "kind", "quality")
	self.group_cfg = self.shen_ge_cfg_auto.combination --ListToMapList(, "seq")
	self.shenge_suit_cfg = self.shen_ge_cfg_auto.xinghui_new_suit
	self.shenge_new_suit_cfg = self.shen_ge_cfg_auto.new_suit

	self.shenqu_cfg = self.shen_ge_cfg_auto.shenqu
	self.shenqu_xilian_cfg = ListToMapList(self.shen_ge_cfg_auto.shenqu_xilian, "shenqu_id", "point_type")

	self.zhangkong_cfg = self.shen_ge_cfg_auto.zhangkong
	self.other_cfg = self.shen_ge_cfg_auto.other[1]
	self.zhangkong_total_info = {}
	self.zhangkong_single_info = {}
	self:SetShenliName()

	self.sort_open_groove_cfg = self.shen_ge_cfg_auto.shengegroove
	table.sort(self.sort_open_groove_cfg, function(a, b)
		return a.shenge_open < b.shenge_open
	end)
	self.automatic_compose_flag = SHENGE_AUTOMATIC_COMPOSE_FLAG.NO_START			-- 神格自动合成状态
	self.select_compose_list = {}													-- 神格自动合成列表
	self.max_compose_num = 3														-- 神格自动合成最大数量
	self.cur_page_index = 1 														-- 神格当前标签页
	self.notify_data_change_callback_list = {}		--物品有更新变化时进行回调

	RemindManager.Instance:Register(RemindName.ShenGe_ShenGe, BindTool.Bind(self.CalcShenGeRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenGe_Bless, BindTool.Bind(self.CalcBlessRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenGe_Zhangkong, BindTool.Bind(self.CalcZhangkongRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShenGe_Godbody, BindTool.Bind(self.CalcGodbodyRedPoint, self))
end

function ShenGeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenGe_ShenGe)
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Bless)
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Zhangkong)
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Godbody)

	self.shenge_stone_num = nil
	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance = nil
	end
end

function ShenGeData:CalcShenGeRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	-- if self:GetShenGeCount() >= FenJieTiShiCount then 
	-- 	return 1
	-- end
	if self:CalcShenRedPointByPageNum(0) then
		return 1
	end

	if self:CalcShenGeRedPointByJiFen() then
		return 1
	end

	local goal_info =  self:GetGoalInfo()
	if goal_info ~= nil and goal_info.active_flag ~= nil and goal_info.fetch_flag ~= nil then
		if (goal_info.active_flag[0] == 1 and goal_info.fetch_flag[0] == 0) or (goal_info.fetch_flag[0] == 1 and goal_info.active_flag[1] == 1 and goal_info.fetch_flag[1] == 0) then
			return 1
		end
	end

	return 0
end

function ShenGeData:CalcShenGeRedPointByJiFen()
	if self.shen_ge_inlay_info[0] then
		for k, v in pairs(self.shen_ge_inlay_info[0]) do
			local data = v.shen_ge_data
			local cfg = self:GetShenGepreviewCfg(data.type, data.quality, data.level)
			if cfg and cfg.next_level_need_marrow_score <= self.jifen_count then
				return true
			end
		end
	end
	return false
end

function ShenGeData:CalcShenGeInLayRedPoint()
	if self:GetShenGeCount() >= FenJieTiShiCount then 
		return true
	end
	if self:CalcShenRedPointByPageNum(0) then
		return true
	end
	return false
end

function ShenGeData:SetCurPage(index)
	self.cur_page_index = index
end

function ShenGeData:GetCurPage()
	return self.cur_page_index
end
function ShenGeData:CalcShenRedPointByPageNum(page_num)
	page_num = page_num or self:GetCurPageIndex()
	local slot_state_list = self:GetSlotStateList(page_num)
	for i = 0, 3 do
		for i2 = i * 4, i * 4 + 3 do
			local inlay_data = self:GetInlayData(page_num, i2)
			if slot_state_list[i2] and (nil == inlay_data or inlay_data.item_id <= 0) and #self:GetSameQuYuDataList(i + 1) > 0 then
				if self:GetCanAddShengGe(i + 1) then 
					return true
				end
			end
		end
		local need_page = self:GetCurPageIndex()
		local same_quyu_list = self:GetSameQuYuDataList(i + 1)
		for k,v in pairs(same_quyu_list) do
			for iz = 0, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID - 1 do
				if nil ~= self.shen_ge_inlay_info[need_page] and self.shen_ge_inlay_info[need_page][iz] then 
					local cur_data = self.shen_ge_inlay_info[need_page][iz]
					if nil ~= v.shen_ge_data and nil ~= cur_data.shen_ge_data.quality and nil ~= v.shen_ge_data.quality and
						cur_data.shen_ge_data.quality < v.shen_ge_data.quality then
						if self.shenge_quyu_need_cfg[cur_data.shen_ge_data.type].quyu == self.shenge_quyu_need_cfg[v.shen_ge_data.type].quyu then 
							if self:GetCanChangeShenGe(cur_data.shen_ge_data.type , v.shen_ge_data.type , i + 1) then 
								return true
							end
						end
					end
				end
			end
		end
	end
	-- for k, v in pairs(self.shen_ge_inlay_info[page_num] or {}) do
	-- 	if self:GetShenGeInlayCellCanUpLevel(page_num, k) then
	-- 		return true
	-- 	end
	-- end
	-- return false
end

function ShenGeData:GetShenGeInlayCellCanUpLevel(page, index)
	local inlay_info = self:GetInlayData(page, index)
	if nil == inlay_info then
		return false
	end
	local shen_ge_data = inlay_info.shen_ge_data
	local next_attr_cfg = self:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == next_attr_cfg or not next(next_attr_cfg) then
		return false
	end
	local cur_all_fragments = self:GetFragments(true)
	return cur_all_fragments >= next_attr_cfg.next_level_need_marrow_score
end

function ShenGeData:CalcBlessRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	local times_limit, had_use_time, free_time, diff_time = 3, 3, 0, 0
	local info = self:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO)
	if nil ~= info then
		had_use_time = info.param1
		free_time = info.param3
		diff_time = math.floor(free_time - TimeCtrl.Instance:GetServerTime())
		if had_use_time >= times_limit or diff_time > 0 then
			return 0
		end
		return 1
	end
	info = self:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO)
	had_use_time = info and info.param1 or 3
	free_time = info and info.param3 or 0
	diff_time = math.floor(free_time - TimeCtrl.Instance:GetServerTime())
	if had_use_time >= times_limit or diff_time > 0 then
		return 0
	end
	return 1
end

function ShenGeData:CalcZhangkongRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	local num = 0
	--if not self:IsZhangkongAllMaxLevel() then
	local cfg = self:GetShenGeDataUplevelGridCfg()
	for k,v in pairs(cfg) do
		if not self:IsZhangkongMaxLevelByIndex(v.index) then
			local item_count = ItemData.Instance:GetItemNumInBagById(v.item_id)
			if item_count > 0 then
				num = 1
				break
			end
		end
	end
	--end

	return num
end

function ShenGeData:IsZhangkongMaxLevelByIndex(index)
	local is_max = true
	if nil == index then
		is_max = false
	else
		local level = self:GetZhangkongInfoByGrid(index).level
		if level == nil then return false end
		if level < 200 then
			is_max = false
		end
	end
	return is_max
end

function ShenGeData:SetShenGeStoneNum()
	local cfg = self:GetShenquCfgById(0)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	self.shenge_stone_num = material_num
end


function ShenGeData:CalcGodbodyRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shengeview") then
		return 0
	end
	local cfg = self:GetShenquCfgById(0)
	if not cfg then return 0 end
	local material_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	if self.shenge_stone_num and self.shenge_stone_num >= material_num then return 0 end

	for k,v in pairs(self.shenqu_cfg) do
		if v == nil or not next(v) then 
			return 0
		end
		local item_num = ItemData.Instance:GetItemNumInBagById(v.stuff_id)
		local shenqu_yiman = self:ShenQuItemAllActive(v.shenqu_id)
		local last_max_shenqu_id = 0
		if v.shenqu_id ~= 0 then 
			last_max_shenqu_id = v.shenqu_id - 1
		end
		local shenqu_history_max_cap = ShenGeData.Instance:GetShenQuHistoryMaxCap(last_max_shenqu_id)
		if nil == shenqu_history_max_cap then 
			return 0 
		end
		
		if not shenqu_yiman and item_num > 0 and shenqu_history_max_cap >= v.fighting_capacity then 
			return 1
		end
	end
	return 0
	-- local cfg = self:GetShenquCfgById(0)
	-- local item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	-- local data = self:GetShenquListData()
	-- local one_attr_list = ShenGeData.Instance:GetTotalAttrList(0)
	-- local value = (cfg.value_percent / 100 * CommonDataManager.GetCapability(one_attr_list)) * ShenGeData.Instance:GetAttrPointInfoNumByShenQuId(0)
	-- if item_num > 0 and (CommonDataManager.GetCapability(one_attr_list) + value) >= data[1].fighting_capacity then
	-- 	return 1
	-- else
	-- 	return 0
	-- end
end

-- 根据信息类型存数据
function ShenGeData:SetShenGeSystemBagInfo(protocol)
	
	local vo = {}
	vo.info_type = protocol.info_type
	vo.param1 = protocol.param1
	vo.count = protocol.count
	vo.param3 = protocol.param3
	vo.bag_list = protocol.bag_list
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO then 
		self.jifen_count = protocol.param3
	end
	self.shen_ge_system_info[vo.info_type] = vo

	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then
		self:ChangeShenGeBagInfo(vo.bag_list)
	end

	-- 背包单个、多个数据改变
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE then
		self:ChangeShenGeBagInfo(vo.bag_list)
	end

	-- 全部符文槽信息
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO then
		self:SetInlayLevel(vo.param1, vo.bag_list)
		self:SetInlayPageHistoryLevel(vo.param1, vo.param3)
		self:SetInlayInfo(vo.param1, vo.bag_list)
	end

	-- 单个、多个符文槽信息
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO then
		self:SetInlayInfo(vo.param1, vo.bag_list)
		self:SetInlayPageHistoryLevel(vo.param1, vo.param3)
	end

	-- 抽奖奖励信息
	if vo.info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then
		self:ChangeBlessRewardToItemData(protocol.bag_list)
	end

	-- 监听回调
	self:NoticeOneItemChange(protocol.info_type, protocol.param1, protocol.count, protocol.param3, protocol.bag_list)
end

function ShenGeData:GetShenGeSystemBagInfo(info_type)
	return self.shen_ge_system_info[info_type]
end

function ShenGeData:GetInlayData(page, index)
	return self.shen_ge_inlay_info[page] and self.shen_ge_inlay_info[page][index]
end

function ShenGeData:GetBagListCount()
	return self.bag_list_cont
end

function ShenGeData:GetShenGeBlessRewardDataList()
	return self.shen_ge_bless_reward_list
end

function ShenGeData:GetSameQualityInlayDataNum(types, quality)
	return self.same_types_num_list[types] and self.same_types_num_list[types][quality] or 0
end

function ShenGeData:SetBlessAniState(value)
	self.is_can_play_bless_ani = not value
end

function ShenGeData:GetBlessAniState()
	return self.is_can_play_bless_ani
end

function ShenGeData:SetZhangkongAniState(value)
	self.is_can_play_zhangkong_ani = not value
end

function ShenGeData:GetZhangkongAniState()
	return self.is_can_play_zhangkong_ani
end


function ShenGeData:GetFragments(is_no_conver)
	local info = self.shen_ge_system_info[SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO]
	local count = info and info.param3 or 0
	if is_no_conver then
		return count
	end
	return CommonDataManager.ConverMoney(count)
end

function ShenGeData:NoticeOneItemChange(info_type, param1, param2, param3, bag_list)
	for k,v in pairs(self.notify_data_change_callback_list) do  --协议改变
		v(info_type, param1, param2, param3, bag_list)
	end
end

-- 神格背包数据改变
function ShenGeData:ChangeShenGeBagInfo(data_list)
	for _, v in pairs(data_list) do
		if v.quality < 0 and v.type < 0 and v.level <= 0 then
			if nil ~= self.shen_ge_item_info[v.index] then
				self.bag_list_cont = self.bag_list_cont - 1
			end
			self.shen_ge_item_info[v.index] = nil
			self.shen_ge_bag_info[v.index] = nil
		else
			if nil == self.shen_ge_item_info[v.index] then
				self.bag_list_cont = self.bag_list_cont + 1
			end
			local temp_data = {}
			temp_data.item_id = self:GetShenGeItemId(v.type, v.quality)
			temp_data.num = 1
			temp_data.shen_ge_data = v
			local shenge_attribute_cfg = self:GetShenGeAttributeCfg(v.type, v.quality, v.level)
			temp_data.shen_ge_kind = shenge_attribute_cfg and shenge_attribute_cfg.kind or 0
			self.shen_ge_item_info[v.index] = temp_data
			self.shen_ge_bag_info[v.index] = v
		end
	end
end

function ShenGeData:ChangeBlessRewardToItemData(data_list)
	self.shen_ge_bless_reward_list = {}

	for _, v in pairs(data_list) do
		local temp_data = {}
		temp_data.item_id = self:GetShenGeItemId(v.type, v.quality)
		temp_data.num = 1
		temp_data.shen_ge_data = v
		local shenge_attribute_cfg = self:GetShenGeAttributeCfg(v.type, v.quality, v.level)
		temp_data.shen_ge_kind = shenge_attribute_cfg and shenge_attribute_cfg.kind or 0
		temp_data.quality = v.quality
		table.insert(self.shen_ge_bless_reward_list, temp_data)
	end

	table.sort(self.shen_ge_bless_reward_list, SortTools.KeyUpperSorters("quality"))

end

function ShenGeData:GetShenGeItemData(index)
	return self.shen_ge_item_info[index]
end

function ShenGeData:GetShenGeCount()
	local count = GetListNum(self.shen_ge_item_info)
	return count
end

function ShenGeData:ClearOneKeyDecomposeData()
	self.one_key_decompose_data_list = {}
end

function ShenGeData:GetShenGeSameQualityItemData(quality)
	if nil == next(self.one_key_decompose_data_list) then
		local list = {}
		for k, v in pairs(self.shen_ge_item_info) do
			list[v.shen_ge_data.quality] = list[v.shen_ge_data.quality] or {}
			table.insert(list[v.shen_ge_data.quality], v)
		end

		for k, v in pairs(list) do
			table.sort(v, function(a, b)
				if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
					return a.shen_ge_data.quality > b.shen_ge_data.quality
				end

				if a.shen_ge_data.level ~= b.shen_ge_data.level then
					return a.shen_ge_data.level > b.shen_ge_data.level
				end

				return a.shen_ge_data.type < b.shen_ge_data.type
			end)
		end

		for k, v in pairs(list) do
			self.one_key_decompose_data_list[k] = self.one_key_decompose_data_list[k] or {}
			for i = 1, #v do
				self.one_key_decompose_data_list[k][i] = v[i]
				self.one_key_decompose_data_list[k][i].is_select = false
			end
		end
	end
	return self.one_key_decompose_data_list[quality] or {}
end

function ShenGeData:SetInlayInfo(page, data_list)
	self.shen_ge_inlay_info[page] = self.shen_ge_inlay_info[page] or {}

	local data = nil
	for k, v in pairs(data_list) do
		self.same_types_num_list[v.type] = self.same_types_num_list[v.type] or {}
		self.same_types_num_list[v.type][v.quality] = self.same_types_num_list[v.type][v.quality] or 0

		data = self:GetInlayData(page, v.index)
		if nil ~= data then
			self.same_types_num_list[data.shen_ge_data.type][data.shen_ge_data.quality] = self.same_types_num_list[data.shen_ge_data.type][data.shen_ge_data.quality] - 1
		end

		if v.quality < 0 and v.type < 0 and v.level <= 0 then
			data_list[k] = nil
			if nil ~= data then
				self.shen_ge_inlay_level[page] = self.shen_ge_inlay_level[page] - data.shen_ge_data.level
			end
			self.shen_ge_inlay_info[page][v.index] = nil
		else
			local data = {}
			data.item_id = self:GetShenGeItemId(v.type, v.quality)
			data.num = 1
			data.shen_ge_data = v
			local shenge_attribute_cfg = self:GetShenGeAttributeCfg(v.type, v.quality, v.level)
			data.shen_ge_kind = shenge_attribute_cfg and shenge_attribute_cfg.kind or 0
			self.shen_ge_inlay_info[page][v.index] = data

			self.same_types_num_list[v.type][v.quality] = self.same_types_num_list[v.type][v.quality] + 1
		end
	end
end

function ShenGeData:GetCurPageIndex()
	local info = self:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX)
	if nil == info then
		info = self:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO)
		if nil ~= info and nil ~= info.param1 then
			return info.param1
		end
	end
	if nil ~= info and nil ~= info.param1 then
		return info.param1
	end
end

-- 设置当前符文页的符文总等级
function ShenGeData:SetInlayLevel(page, data_list)
	self.shen_ge_inlay_level[page] = 0
	for k, v in pairs(data_list) do
		self.shen_ge_inlay_level[page] = self.shen_ge_inlay_level[page] + v.level
	end
end

function ShenGeData:GetInlayLevel(page)
	return self.shen_ge_inlay_level[page]
end

function ShenGeData:GetInlayCurTotalLevel()
	local sum = 0
	for _, v in pairs(self.shen_ge_inlay_level) do
		sum = sum + v
	end
	return sum
end

function ShenGeData:SetInlayPageHistoryLevel(page, value)
	self.shen_ge_inlay_history_level[page] = value or 0
end

function ShenGeData:GetInlayPageHistoryLevel(page)
	return self.shen_ge_inlay_history_level[page] or 0
end

-- 获取镶嵌历史最高总等级
function ShenGeData:GetInlayHistoryTotalLevel()
	local sum = 0
	for _, v in pairs(self.shen_ge_inlay_history_level) do
		sum = sum + v
	end
	return sum
end

-- 获取神格物品ID
function ShenGeData:GetShenGeItemId(types, quality)
	if nil == self.item_id_to_shen_ge_cfg[quality] or nil == self.item_id_to_shen_ge_cfg[quality][types] then
		return 0
	end

	return self.item_id_to_shen_ge_cfg[quality][types][1].item_id
end

function ShenGeData:GetShenGeQualityByItemId(item_id)
	for k, v in pairs(self.shen_ge_cfg_auto.item_id_to_shenge) do
	 	if v.item_id == item_id then
	 		return v.quality, v.types, v.buwei
	 	end
	 end
	 return -1
end

function ShenGeData:GetChoujiangCfg(seq)
	return self.choujiang_cfg[seq]
end

-- 神格祈福转盘格子数据
function ShenGeData:GetShenGeBlessShowData(index)
	for k, v in pairs(self.shen_ge_cfg_auto.show) do
	 	if v.caowei == index then
	 		local data = {}
	 		data.item_id = v.icon_pic
	 		data.zhanli = v.zhanli
	 		data.detail = v.detail
	 		data.name = v.name
	 		data.index = v.caowei
	 		data.color = v.name_color
	 		return data
	 	end
	 end
	 return nil
end

function ShenGeData:GetShenGeBlessShowCfg()
	return self.shen_ge_cfg_auto.show
end

function ShenGeData:GetShenGeAttributeCfg(types, quality, level)
	if nil ~= level then
		if nil == self.attribute_cfg[quality] or nil == self.attribute_cfg[quality][types] then
			return nil
		end
		return self.attribute_cfg[quality][types][level]
	end

	if nil == self.attribute_cfg[quality] then
		return nil
	end
	return self.attribute_cfg[quality][types]
end

function ShenGeData:GetShenGepreviewCfg(types, quality, level)
	types = types or 0
	quality = quality or 0
	level = level or 1
	return self.shenge_preview_cfg[types]
	and self.shenge_preview_cfg[types][quality]
	and self.shenge_preview_cfg[types][quality][level]
	and self.shenge_preview_cfg[types][quality][level][1] or nil
end

function ShenGeData:GetShenGepreviewCfgForTypes()
	local PreviewtypesCfg = {}
	local cfg_type = -1
	if self.attribute_cfg[1] then
		for k,v in pairs(self.attribute_cfg[1]) do
			if cfg_type ~= v[1].types then
				cfg_type = v[1].types
				table.insert(PreviewtypesCfg, cfg_type)
			end
		end
	end
	return PreviewtypesCfg
end

function ShenGeData:GetShenGeGroupCfg(seq)
	return self.group_cfg[seq]
end

function ShenGeData:GetOtherCfg()
	return self.shen_ge_cfg_auto.other[1]
end

-- 获取当前符文页属性
function ShenGeData:GetInlayAttrListAndOtherFightPower(page_index, quality)
	if nil == self.shen_ge_inlay_info[page_index] then
		return {}, 0
	end

	quality = quality and quality or -1
	local list = {}
	local other_fight_power = 0
	local attr_cfg , attr_value, attr_type, attr_key = nil, 0, -1, nil
	for _, v in pairs(self.shen_ge_inlay_info[page_index]) do
		if v.shen_ge_data.quality >= quality then
			attr_cfg = self:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			if nil ~= attr_cfg then
				for i = 0, 1 do
					attr_value = attr_cfg["add_attributes_"..i]
					attr_type = attr_cfg["attr_type_"..i]
					attr_key = Language.ShenGe.AttrType[attr_type]
					if nil ~= attr_type and nil ~= attr_value and attr_value > 0 then
						list[attr_key] = list[attr_key] or 0
						list[attr_key] = list[attr_key] + attr_value
					end
				end
				other_fight_power = other_fight_power + attr_cfg.capbility
			end
		end
	end

	return list, other_fight_power
end

-- 获取当前符文页属性
function ShenGeData:GetInlayAttrListFightPower(page_index, quality)
	if nil == self.shen_ge_inlay_info[page_index] then
		return {}, 0
	end

	quality = quality and quality or -1
	local list = {}
	local other_fight_power = 0
	local attr_cfg , attr_value, attr_type, attr_key = nil, 0, -1, nil
	for _, v in pairs(self.shen_ge_inlay_info[page_index]) do
		if v.shen_ge_data.quality == quality then
			attr_cfg = self:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			if nil ~= attr_cfg then
				for i = 0, 1 do
					attr_value = attr_cfg["add_attributes_"..i]
					attr_type = attr_cfg["attr_type_"..i]
					attr_key = Language.ShenGe.AttrType[attr_type]
					if nil ~= attr_type and nil ~= attr_value and attr_value > 0 then
						list[attr_key] = list[attr_key] or 0
						list[attr_key] = list[attr_key] + attr_value
					end
				end
				other_fight_power = other_fight_power + attr_cfg.capbility
			end
		end
	end

	return list, other_fight_power
end

-- 神格槽开启预告
function ShenGeData:GetNextGrooveIndexAndNextGroove()
	local cur_page = self:GetCurPageIndex()
	local index = -1
	local next_open_level = -1
	for k, v in pairs(self.sort_open_groove_cfg) do
		if v.shenge_open > self:GetInlayPageHistoryLevel(cur_page) then
			index = v.shenge_groove
			next_open_level = v.shenge_open
			break
		end
	end
	return index, next_open_level
end

-- 神格槽是否开启
function ShenGeData:GetSlotStateList(page)
	local list = {}
	local cur_page = page or self:GetCurPageIndex()
	for k, v in pairs(self.sort_open_groove_cfg) do
		list[v.shenge_groove] = v.shenge_open <= self:GetInlayPageHistoryLevel(cur_page)
	end

	return list
end

function ShenGeData:GetShenGeOpenPageNum()
	local page_num = 0
	for _, v in pairs(self.shen_ge_cfg_auto.shengepage) do
		if v.shengepage_open <= self:GetInlayHistoryTotalLevel() then
			page_num = page_num + 1
		end
	end
	return page_num
end

-- 神格页开启等级
function ShenGeData:GetShenGePageOpenLevel(index)
	for _, v in pairs(self.shen_ge_cfg_auto.shengepage) do
		if v.shengepage == index then
			return v.shengepage_open
		end
	end
	return 0
end

function ShenGeData:GetBagItemKindAndQualityList()
	local list = {}
	local kind_num_list = {}
	local quality_num_list = {}
	local num_limit = 3
	for k, v in pairs(self.shen_ge_item_info) do
		list[v.shen_ge_kind] = list[v.shen_ge_kind] or {}

		kind_num_list[v.shen_ge_kind] = kind_num_list[v.shen_ge_kind] or 0
		kind_num_list[v.shen_ge_kind] = kind_num_list[v.shen_ge_kind] + 1

		quality_num_list[v.shen_ge_kind] = quality_num_list[v.shen_ge_kind] or {}
		quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] = quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] or 0
		quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] = quality_num_list[v.shen_ge_kind][v.shen_ge_data.quality] + 1

		table.insert(list[v.shen_ge_kind], v)
	end

	local temp_list = {}
	for k, v in pairs(list) do
		for _, v2 in pairs(v) do
			if kind_num_list[k] >= num_limit and quality_num_list[k][v2.shen_ge_data.quality] >= num_limit and v2.shen_ge_data.quality < 5 then
				table.insert(temp_list, v2)
			end
		end
	end

	return temp_list
end

function ShenGeData:GetCanComposeDataList(data_list, is_show_enough)
	if self.bag_list_cont <= 0 then
		return {}
	end

	local list = {}
	if data_list.count <= 0 then
		if is_show_enough then
			list = self:GetBagItemKindAndQualityList()
			return self:SortComposeList(list)
		end

		for _, v in pairs(self.shen_ge_item_info) do
			if v.shen_ge_data.quality < 5 then
				table.insert(list, v)
			end
		end
		return self:SortComposeList(list)
	end

	local temp_data_list = {}
	for k, v in pairs(data_list) do
		if type(v) == "table" then
			table.insert(temp_data_list, v)
		end
	end

	local index_1 = math.max(#temp_data_list - 0, 1)
	local index_2 = math.max(#temp_data_list - 1, 1)
	local index_3 = math.max(#temp_data_list - 2, 1)

	for k, v in pairs(self.shen_ge_item_info) do
		if temp_data_list[index_1].shen_ge_kind == v.shen_ge_kind and v.shen_ge_data.quality == temp_data_list[index_1].shen_ge_data.quality
			and (temp_data_list[index_1].shen_ge_data.index ~= k and temp_data_list[index_2].shen_ge_data.index ~= k and
				temp_data_list[index_3].shen_ge_data.index ~= k) and v.shen_ge_data.quality < 5 then

				table.insert(list, v)
		end
	end

	return self:SortComposeList(list)
end

function ShenGeData:SortComposeList(list)
	table.sort(list, function(a, b)
			if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
				return a.shen_ge_data.quality < b.shen_ge_data.quality
			end

			if a.shen_ge_data.type ~= b.shen_ge_data.type then
				return a.shen_ge_data.type > b.shen_ge_data.type
			end

			return a.shen_ge_data.level < b.shen_ge_data.level
		end)
	return list
end

-- 从神格背包获取相同类型、品质的神格
function ShenGeData:GetBagSameQualityAndTypesItemDataList(types, quality, index)
	if self.bag_list_cont <= 0 then
		return {}
	end

	local list = {}
	for _, v in pairs(self.shen_ge_item_info) do
		if v.shen_ge_data.quality == quality and v.shen_ge_data.index ~= index and v.shen_ge_data.type == types then
			table.insert(list, v)
		end
	end
	if #list > 1 then
		table.sort(list, function(a, b)
			if a.shen_ge_data.level ~= b.shen_ge_data.level then
				return a.shen_ge_data.level < b.shen_ge_data.level
			end
			return a.shen_ge_data.index < b.shen_ge_data.index
		end)
	end
	return list
end

-- 获取相同区域的神格
function ShenGeData:GetSameQuYuDataList(qu_yu, have_data)
	local need_num = self.shen_ge_cfg_auto.other[1].ultimate_shenge_type_max_count
	local cur_page = self:GetCurPageIndex()
	local list = {}
	local cfg = {}
	for k, v in pairs(self.shen_ge_item_info) do
		cfg = self:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
		if nil ~= cfg then
			list[cfg.quyu] = list[cfg.quyu] or {}
			table.insert(list[cfg.quyu], v)
		end
	end

	for k, v in pairs(list) do
		table.sort(v, function(a, b)
			if nil ~= have_data then 
				local count_a = 0 
				local count_b = 0 
				for i = 0, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID - 1 do
					if nil ~= self.shen_ge_inlay_info[cur_page] and self.shen_ge_inlay_info[cur_page][i] then 				 -- 需求的
						local cur_data = self.shen_ge_inlay_info[cur_page][i]
						if nil ~= cur_data.shen_ge_data and cur_data.shen_ge_data.type then 
							if cur_data.shen_ge_data.type == a.shen_ge_data.type then 
								count_a = count_a + 1 
							end
							if cur_data.shen_ge_data.type == b.shen_ge_data.type then 
								count_b = count_b + 1 
							end 
						end
					end
				end
				if have_data == SHENGE_HAVE_DATA.NO_HAVE or have_data ~= a.shen_ge_data.type and have_data ~= b.shen_ge_data.type then 
					if count_a < need_num or count_b < need_num then 
						if count_a >= need_num and count_b < need_num then 
							return false
						elseif count_b >= need_num and count_a < need_num then
							return true
						end
					end
				elseif have_data == a.shen_ge_data.type and have_data ~= b.shen_ge_data.type then 
					if count_a < need_num + 1 or count_b < need_num then 
						if count_a >= need_num + 1 and count_b < need_num then 
							return false
						elseif count_b >= need_num and count_a < need_num + 1 then
							return true
						end
					end
				elseif have_data == b.shen_ge_data.type and have_data ~= a.shen_ge_data.type then
					if count_a < need_num or count_b < need_num + 1 then 
						if count_a >= need_num and count_b < need_num + 1 then 
							return false
						elseif count_b >= need_num + 1 and count_a < need_num then
							return true
						end
					end
				end
			end
			if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
				return a.shen_ge_data.quality > b.shen_ge_data.quality
			end

			if a.shen_ge_data.level ~= b.shen_ge_data.level then
				return a.shen_ge_data.level > b.shen_ge_data.level
			end

			return a.shen_ge_data.type < b.shen_ge_data.type
		end)
	end

	return list[qu_yu] or {}
end

function ShenGeData:IsShenGeToggle(show_index)
	if show_index == TabIndex.shen_ge_inlay
		or show_index == TabIndex.shen_ge_bless
		or show_index == TabIndex.shen_ge_group
		or show_index == TabIndex.shen_ge_compose then
		return true
	end
	return false
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function ShenGeData:NotifyDataChangeCallBack(callback)
	if callback == nil then
		return
	end

	self.notify_data_change_callback_list[callback] = callback
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function ShenGeData:UnNotifyDataChangeCallBack(callback)
	if nil == self.notify_data_change_callback_list[callback] then
		return
	end

	self.notify_data_change_callback_list[callback] = nil
end

--协议获取掌控总信息
function ShenGeData:SetZhangkongTotalInfo(protocol)
	self.zhangkong_total_info = protocol
end

--协议获取掌控单个修改信息
function ShenGeData:SetZhangkongSingleInfo(protocol)
	self.zhangkong_single_info = protocol
end

--根据grid获取相应格子的信息
function ShenGeData:GetZhangkongInfoByGrid(grid)
	local data_list = {}
	if nil == self.zhangkong_total_info.zhangkong_list then
		return {}
	end
	local level = self.zhangkong_total_info.zhangkong_list[grid].level

	if level ~= nil then
		data_list.grid = grid
		data_list.level = level
		local index = data_list.level + data_list.grid * 50 + 1
		local detail_data = self:GetDetailData(data_list.grid, data_list.level)
		data_list.exp = self.zhangkong_total_info.zhangkong_list[grid].exp
		data_list.cfg_exp = detail_data.cfg_exp
		data_list.grade = detail_data.grade
		data_list.star = detail_data.star
		data_list.shenge_pro = 	detail_data.shenge_pro
		data_list.pro = detail_data.pro
		data_list.name = detail_data.name
		data_list.attr_list = detail_data.attr_list
	end
	return data_list
end

function ShenGeData:SetShenliName()
	self.shenli_name = {}
	for i = 1, 4 do
		for k,v in pairs(self.zhangkong_cfg) do
			if v.level ~= 0 then
				if v.grid == i - 1 then
					self.shenli_name[i] = v.shenli_name
					break
				end
			end
		end
	end
end

function ShenGeData:GetShenliName(grid)
	self:SetShenliName()
	if self.shenli_name ~= nil then
		return self.shenli_name[grid + 1]
	end
end

function ShenGeData:GetZhankongSingleChangeInfo()
	if self.zhangkong_single_info == nil then
		return
	end
	return self.zhangkong_single_info
end

function ShenGeData:GetDetailData(grid, level)
	local data_list = {}
	for k,v in pairs(self.zhangkong_cfg) do
		if v.level == level and v.grid == grid then
			if level == 100 then
				data_list.cfg_exp = v.exp
			else
				data_list.cfg_exp = nil ~= self.zhangkong_cfg[k + 1] and self.zhangkong_cfg[k + 1].exp or 0
			end
			data_list.grade = v.level or 0
			data_list.star = v.star or 1
			data_list.shenge_pro = v.shenge_pro
			data_list.name = v.shenli_name
			data_list.attr_list = {}

			local temp_attr_list = {}
			if level == 0 then
				temp_attr_list = self.zhangkong_cfg[k + 1]
			else
				temp_attr_list = v
			end
			for m, n in pairs(ShenGeZhanKongEnum) do
				if temp_attr_list[n] ~= 0 then
					local count = #data_list.attr_list
					data_list.attr_list[count + 1] = {}
					data_list.attr_list[count + 1].val = temp_attr_list[n]
					data_list.attr_list[count + 1].name = n
				end
			end
		end
	end
	return data_list
end

function ShenGeData:GetZhangkongCost()
	return self.other_cfg.uplevel_zhangkong_gold
end

function ShenGeData:GetZhangkongItemID()
	return self.other_cfg.uplevel_zhangkong_itemid
end

function ShenGeData:GetCfgOther()
	return self.other_cfg
end


function ShenGeData:IsExpBaoji(exp)
	if exp == self.shen_ge_cfg_auto.zhangkong_rand_exp_weight[1].exp then
		return false
	else
		return true
	end
end

function ShenGeData:IsZhangkongAllMaxLevel()
	local is_all_max = true
	for i = 0 , 3 do
		local level = self:GetZhangkongInfoByGrid(i).level
		if level < 200 then
			is_all_max = false
		end
	end
	return is_all_max
end

function ShenGeData:GetZhangkongIsRolling()
	return self.zhangkong_is_rolling
end

function ShenGeData:SetZhangkongIsRolling(is_rolling, obj)
	if obj and obj.button then 
		obj.button.interactable =  not is_rolling
	end
	self.zhangkong_is_rolling = is_rolling
end

function ShenGeData:GetCompseSucceedRate(kind, quality)
	local composite_prob = self.compose_shen_ge[kind][quality][1].show_prob
	return composite_prob
end

----------------神躯---------
function ShenGeData:SetShenquAllInfo(protocol)
	self.shenqu_list = protocol.shenqu_list
	self.shenqu_history_max_cap = protocol.shenqu_history_max_cap
end

function ShenGeData:SetShenquSingleInfo(protocol)
	if next(self.shenqu_list) then
		self.shenqu_list[protocol.shenqu_id] = protocol.shenqu_attr
	end
	
	if next(self.shenqu_history_max_cap) then
		self.shenqu_history_max_cap[protocol.shenqu_id] = protocol.shenqu_history_max_cap
	end
end

function ShenGeData:GetShenQuHistoryMaxCap(shenqu_id)
	return self.shenqu_history_max_cap and self.shenqu_history_max_cap[shenqu_id] or 0
end

function ShenGeData:GetOnePointInfo(shenqu_id, point_type)
	if next(self.shenqu_list) then
		return self.shenqu_list[shenqu_id][point_type]
	end
	return nil
end

function ShenGeData:GetShenquPointInfoByShenQuId(shenqu_id)
	if next(self.shenqu_list) then
		return self.shenqu_list[shenqu_id]
	end
	return {}
end

function ShenGeData:GetAttrPointInfoNumByShenQuId(shenqu_id)
	local data = self:GetShenquPointInfoByShenQuId(shenqu_id)
	local num = 0
	
	for i,v in ipairs(data) do
		local cfg = ShenGeData.Instance:GetShenquCfgById(shenqu_id)
		local ready_count = 0
		if nil ~= v or next(v) then
			ready_count = (v[1].attr_point >= 0 and v[1].attr_point + 1 == i) and ready_count + 1 or ready_count + 0
			ready_count = (v[2].attr_point >= 0 and v[2].attr_point + 1 == i) and ready_count + 1 or ready_count + 0
			ready_count = (v[3].attr_point >= 0 and v[3].attr_point + 1 == i) and ready_count + 1 or ready_count + 0
		end
		if ready_count >= cfg.perfect_num then num = num + 1 end
	end
	return num
end

function ShenGeData:GetShenquCfgById(shenqu_id)
	for k,v in pairs(self.shenqu_cfg) do
		if shenqu_id == v.shenqu_id then
			return v
		end
	end
	return nil
end

function ShenGeData:GetShenquXiLianCfg(shenqu_id, point_type)
	if nil == self.shenqu_xilian_cfg[shenqu_id] then
		return nil
	end
	return self.shenqu_xilian_cfg[shenqu_id][point_type]
end

function ShenGeData:GetShenquCount()
	local count = 0
	for k,v in pairs(self.shenqu_cfg) do
		count = count + 1
	end
	return count
end

function ShenGeData:GetShenquShowCount()
	local count = 0
	for k,v in pairs(self.shenqu_cfg) do
		local shenqu_history_max_cap = ShenGeData.Instance:GetShenQuHistoryMaxCap(v.shenqu_id - 1) or 0
		if shenqu_history_max_cap >= v.fighting_capacity then
			count = count + 1
		else
			count = count + 1
			break
		end
	end
	return count
end

function ShenGeData:GetShenquListData()
	local shenqu_cfg = TableCopy(self.shenqu_cfg)
	for k,v in pairs(shenqu_cfg) do
		local one_attr_list = self:GetTotalAttrList(v.shenqu_id)
		v.capbility = CommonDataManager.GetCapability(one_attr_list)
	end

	return shenqu_cfg
end

function ShenGeData:GetTotalAttrList(shenqu_id)
	local total_attr_list = {}
	local base_list = CommonDataManager.GetAttrKeyList2()
	if not next(self.shenqu_list) then return {} end
	for k,v in pairs(self.shenqu_list[shenqu_id]) do
		for k1,v1 in pairs(v) do
			if v1.attr_point >= 0 then
				if total_attr_list[base_list[v1.attr_point + 1]] == nil then
					total_attr_list[base_list[v1.attr_point + 1]] = v1.attr_value
				else
					total_attr_list[base_list[v1.attr_point + 1]] = total_attr_list[base_list[v1.attr_point + 1]] + v1.attr_value
				end
			end
		end
	end
	return total_attr_list
end

function ShenGeData:GetOnePointInfoAttr(shenqu_id, point_type)
	local point_info = self:GetOnePointInfo(shenqu_id, point_type)
	if nil == point_info then return {} end
	local total_attr_list = {}
	local base_list = CommonDataManager.GetAttrKeyList2()
	for k,v in pairs(point_info) do
		if v.attr_point >= 0 then
			if total_attr_list[base_list[v.attr_point + 1]] == nil then
				total_attr_list[base_list[v.attr_point + 1]] = v.attr_value
			else
				total_attr_list[base_list[v.attr_point + 1]] = total_attr_list[base_list[v.attr_point + 1]] + v.attr_value
			end
		end
	end
	return total_attr_list
end

function ShenGeData:ISShowCommonAutoList(list_index,point_index,toggle_value_list , first)
	local cur_info = self:GetOnePointInfo(list_index,point_index)
	local data = {}
	for i = 1, 3 do
		data[i] = false
		if cur_info[i].attr_point >= 0 then
			if cur_info[i].attr_point + 1 == point_index then
				data[i] = true
			else 
				data[i] = false
			end
		end
	end
	-- if first == nil then 
	-- 	for i = 1, 3 do
	-- 		if toggle_value_list[i] == 1 and data[i] == true then
	-- 			data[i] = true
	-- 		else
	-- 			data[i] = false
	-- 		end
	-- 	end
	-- end
	return data
end
function ShenGeData:ISShowCommonAuto(list_index,point_index,toggle_value_list)
	local cur_info = self:GetOnePointInfo(list_index,point_index)
	local data = {}

	for i = 1, 3 do
		if cur_info[i].attr_point >= 0 then
			if cur_info[i].attr_point + 1 == point_index then
				data[i] = true
			else 
				data[i] = false
			end
		end
	end
	for i = 1, 3 do
		if toggle_value_list[i] == 1 and data[i] == true then
			return true
		end
	end
	return false
end
function ShenGeData:ISAllShowCommonAuto(list_index,point_index)
	local cur_info = self:GetOnePointInfo(list_index,point_index)
	local data = true
	for i = 1, 3 do
		if cur_info[i].attr_point >= 0 then
			if cur_info[i].attr_point + 1 ~= point_index then
				data = false
			end
		else
			data = false
		end
	end
	return data
end

function ShenGeData:ShenQuItemAllActive(list_index)
	local cur_info = self:GetShenquPointInfoByShenQuId(list_index)
	local data = true
	for k,v in pairs(cur_info) do
		local type_color = v
		for kz,vz in pairs(type_color) do
			if nil == vz or nil == vz.attr_point then 
				return false
			end
			if vz.attr_point >= 0 then
				if vz.attr_point + 1 ~= k then
					data = false
				end
			else
				data = false
			end
		end
	end
	return data
end
--------------------------------------神格自动合成--------------------------------------
function ShenGeData:SetAutomaticComposeFlag(flag)
	self.automatic_compose_flag = flag
end

function ShenGeData:GetAutomaticComposeFlag()
	return self.automatic_compose_flag
end

function ShenGeData:SetSelectComposeList(list)
	self.select_compose_list = list or {} 
end

function ShenGeData:GetSelectComposeList()
	return self.select_compose_list
end

function ShenGeData:GetMaxComposeNum()
	return self.max_compose_num
end

function ShenGeData:GetCompouseIndexList()
	local index_list = {}
	for k,v in pairs(self.select_compose_list) do
		local param_list = v
		if type(param_list) == "table" then
			local index = v.shen_ge_data.index or -1
			if index ~= -1 then
				table.insert(index_list, index)
			end
		end
	end

	return index_list
end

function ShenGeData:IsCanAutomaticComposeContiue()
	local data_list = {}
	local compose_list = {}

	local select_list = self.select_compose_list[1]
	if select_list and type(select_list) == "table" then
		local data = select_list.shen_ge_data
		if nil ~= data then
			local shenge_quality = data.quality or -1
			local shenge_kind = select_list.shen_ge_kind or -1
			local list = self:GetBagSameQualityAndKindDataList(shenge_quality, shenge_kind)

			if #list > 0 then
				table.insert(compose_list, list[1])

				local same_list = {}
				table.insert(same_list, list[1])
				same_list.count = 1
				data_list = self:GetCanComposeDataList(same_list, true)
			end
		end
	end

	if #data_list >= self.max_compose_num -1 then
		for i = 1, self.max_compose_num - 1  do
			table.insert(compose_list, data_list[i])
		end

		if #compose_list == self.max_compose_num then
			self:SetSelectComposeList(compose_list)
			return true
		end
	end

	return false
end

-- 从神格背包获取相同品质和种类（大小玄图）的神格
function ShenGeData:GetBagSameQualityAndKindDataList(quality, kind)
	if self.bag_list_cont <= 0 or kind < 0 then
		return {}
	end

	local list = {}
	for _, v in pairs(self.shen_ge_item_info) do
		if v.shen_ge_data.quality == quality and v.shen_ge_kind == kind then
			table.insert(list, v)
		end
	end

	return list
end
function ShenGeData:GetCanAddShengGe(quyu)
	local max_count = 0
	if SHENGE_QUYU_MAX_COUNT[quyu] == "ultimate_shenge_type_max_count" then 
		if nil ~= self.shen_ge_cfg_auto.other[1] and nil ~= self.shen_ge_cfg_auto.other[1].ultimate_shenge_type_max_count then 
			max_count = self.shen_ge_cfg_auto.other[1].ultimate_shenge_type_max_count
		end
	elseif SHENGE_QUYU_MAX_COUNT[quyu] == "normal_shenge_type_max_count" then
		if nil ~= self.shen_ge_cfg_auto.other[1] and nil ~= self.shen_ge_cfg_auto.other[1].normal_shenge_type_max_count then
			max_count = self.shen_ge_cfg_auto.other[1].normal_shenge_type_max_count
		end
	end
	local data_count = {}
	local bag_same_list = self:GetSameQuYuDataList(quyu)
	local need_page = self:GetCurPageIndex()
	for i = 0, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID - 1 do
		if nil ~= self.shen_ge_inlay_info[need_page] and self.shen_ge_inlay_info[need_page][i] then 
			local cur_data = self.shen_ge_inlay_info[need_page][i]
			 if nil == data_count[cur_data.shen_ge_data.type] then 
			 	data_count[cur_data.shen_ge_data.type] = 1
			 else
			 	data_count[cur_data.shen_ge_data.type] = data_count[cur_data.shen_ge_data.type] + 1
			 end
		end
	end

	for k,v in pairs(bag_same_list) do
		if nil == data_count[v.shen_ge_data.type] then 
			return true
		end
		if data_count[v.shen_ge_data.type] < max_count then 
			return true
		end
	end
	return false
end
function ShenGeData:GetCanChangeShenGe(type_cur , type_need , quyu)
	if type_cur == type_need then 
		return true
	end
	local count = 0
	local need_page = self:GetCurPageIndex()
	for i = 0, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID - 1 do
		if nil ~= self.shen_ge_inlay_info[need_page] and self.shen_ge_inlay_info[need_page][i] then 				 -- 需求的
			local cur_data = self.shen_ge_inlay_info[need_page][i]
			if nil ~= cur_data.shen_ge_data and cur_data.shen_ge_data.type then 
				if cur_data.shen_ge_data.type == type_need then 
					count = count + 1 
				end
			end
		end
	end
	if SHENGE_QUYU_MAX_COUNT[quyu] == "ultimate_shenge_type_max_count" then 
		if nil ~= self.shen_ge_cfg_auto.other[1] and nil ~= self.shen_ge_cfg_auto.other[1].ultimate_shenge_type_max_count then 
			if count < self.shen_ge_cfg_auto.other[1].ultimate_shenge_type_max_count then 
				return true
			end
		end
	elseif SHENGE_QUYU_MAX_COUNT[quyu] == "normal_shenge_type_max_count" then
		if nil ~= self.shen_ge_cfg_auto.other[1] and nil ~= self.shen_ge_cfg_auto.other[1].normal_shenge_type_max_count then
			if count < self.shen_ge_cfg_auto.other[1].normal_shenge_type_max_count then 
				return true
			end
		end
	end
	return false
end

function ShenGeData:SetShenGeZhangKongState(state)
	self.click_state = state
end

function ShenGeData:GetShenGeZhangKongState()
	return self.click_state 
end

function ShenGeData:GetJiFenCount()
	return self.jifen_count
end

function ShenGeData:GetSameQuaItem(quality)
	local item_list = {}
	for k,v in pairs(self.shen_ge_item_info) do
		if v.shen_ge_data.quality == quality then
			item_list[k] = k
		end
	end
	return item_list
end

function ShenGeData:GetLowestXingHui(page)
	local index = nil 
	local lowest_level = nil 
	for k,v in pairs(self.shen_ge_inlay_info[page]) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg and nil == lowest_level then 
			lowest_level = v.shen_ge_data.level
			index = k
		end
		if nil ~= item_cfg and v.shen_ge_data.level < lowest_level then
			lowest_level = v.shen_ge_data.level
			index = k
		end
	end
	return index
end

function ShenGeData:GetLowestXingHuiSecond(page)
	local index = nil
	local lowest_cost = -1
	for k,v in pairs(self.shen_ge_inlay_info[page]) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			local xinghui_cfg = self:GetShenGepreviewCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			if lowest_cost < 0 or xinghui_cfg.next_level_need_marrow_score < lowest_cost then
				lowest_cost = xinghui_cfg.next_level_need_marrow_score
				index = k
			end
		end
	end
	return index
end

function ShenGeData:GetShenGeDataUplevelGridCfg()
	if self.uplevel_grid_cfg == nil then
		self.uplevel_grid_cfg = ListToMap(self.shen_ge_cfg_auto.uplevel_grid, "index")
	end
	return self.uplevel_grid_cfg
end

function ShenGeData:SetGoalInfo(protocol)
	self.goal_info = {}
	self.goal_info.open_system_timestamp = protocol.open_system_timestamp
	self.goal_info.active_flag = protocol.active_flag
	self.goal_info.fetch_flag = protocol.fetch_flag
	self.goal_info.active_special_attr_flag = protocol.active_special_attr_flag
end

function ShenGeData:GetGoalInfo()
	return self.goal_info
end

-- 神格套装
function ShenGeData:SetShengGeSuitInfo(protocol)
	self.shenge_quality_info = protocol.shenge_quality_info
end

function ShenGeData:GetNewSuitNum()
	if self.shenge_suit_cfg == nil then
		return 0
	end
	local num = 0
	local suit_id = -1
	for i,v in ipairs(self.shenge_suit_cfg) do
		if v.suit_id ~= suit_id then
			num = num + 1
			suit_id = v.suit_id
		end
	end
	return num
end

-- 获取神格套装数据
function ShenGeData:GetSuitCfgBySuitId(suit_id)
	if self.shenge_suit_cfg == nil then
		return {}
	end
	local single_suit_cfg = {}
	for k1,v1 in pairs(self.shenge_suit_cfg) do
		for k2,v2 in pairs(self.shenge_suit_cfg) do
			if k1 ~= k2 and k1 > k2 and v1.suit_id == v2.suit_id then
				local data = {}
				data.has_suit_num = self.shenge_quality_info[v1.suit_color] or 0
				data.seq = v1.suit_id
				data.info1 = v1
				data.info2 = v2
				table.insert(single_suit_cfg, data)
			end
		end
	end
	table.sort(single_suit_cfg, SortTools.KeyUpperSorters("has_suit_num", "seq"))
	return single_suit_cfg
end

function ShenGeData:GetSuitCfg()
	return self.shenge_new_suit_cfg
end

function ShenGeData:GetShenGeQualityInfo()
	return self.shenge_quality_info
end

function ShenGeData:GetSuitNumByQuaitly(index)
	local num = 0
	for k, v in pairs(self.shenge_new_suit_cfg) do
		if v.quality == index then
			if v.need_count > num then
				num = v.need_count
			end
		end
	end
	return num
end

function ShenGeData:GetTaoZhuangAttr()
	local cfg = self:GetSuitCfg()
	local shenge_info = self:GetShenGeQualityInfo() --4代表橙色, 5红色
	local attribute = CommonStruct.AttributeNoUnderline()
	if not cfg and not shenge_info then
		return attribute
	end
	
	for k, v in pairs(cfg) do
		if v.quality == 3 then
			if shenge_info[4] and shenge_info[4] >= v.need_count then
				local temp_attribute = CommonDataManager.GetAttributteNoUnderline(v)
				local per_attribute = CommonDataManager.GetRolePercentAttrNoUnderline(v)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, temp_attribute)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, per_attribute)
			end
		else
			if shenge_info[5] and shenge_info[5] >= v.need_count then
				local temp_attribute = CommonDataManager.GetAttributteNoUnderline(v)
				local per_attribute = CommonDataManager.GetRolePercentAttrNoUnderline(v)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, temp_attribute)
				attribute = CommonDataManager.AddAttributeAttrNoUnderLine(attribute, per_attribute)
			end
		end
	end

	return attribute
end

function ShenGeData:GetShenGeAllAttr()
	local cur_page = self:GetCurPageIndex()
	local attr_list = self:GetInlayAttrListAndOtherFightPower(cur_page)
	return attr_list
end

function ShenGeData:GetShenGeBlessCaoWei(quality, types)
	for k, v in pairs(self.shen_ge_cfg_auto.first_ten_chou) do
		if quality == v.quality and types == v.types then
			return v.caowei
		end
	end
	
end
