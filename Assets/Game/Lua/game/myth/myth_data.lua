MythData = MythData or BaseClass()

MythGongMingAttrType = {
		[1] = "maxhp",
		[2] = "gongji",
		[3] = "fangyu",
		[4] = "mingzhong",
		[5] = "shanbi",
		[6] = "baoji",
		[7] = "jianren",
		[8] = "constant_zengshang",
		[9] = "constant_mianshang",
		[10] = "whole_gongji",
		[11] = "whole_fangyu",
		[12] = "whole_maxhp",
		[13] = "whole_baoshang",
		[14] = "whole_zengshang",
		[15] = "whole_mianshang",
		[21] = "skill_zengshang",
		[22] = "skill_jianshang",
		[23] = "per_kang_bao",
		[24] = "mingzhong_per",
		[25] = "shanbi_per",
		[26] = "gedang_per",
	}
local ShenHunAttrType = {
		[1] = "maxhp",									-- 血量上限
		[2] = "gongji",									-- 攻击
		[3] = "fangyu",									-- 防御
		[4] = "shanbi",									-- 闪避
		[5] = "mingzhong",								-- 命中
		[6] = "baoji",									-- 暴击
		[7] = "jian_ren",								-- 抗暴
		[8] = "constant_zengshang",						-- 增伤
		[9] = "constant_mianshang",						-- 免伤
		[10] = "maxhp",									-- 血量上限
		[11] = "gongji",								-- 攻击
		[12] = "fangyu",								-- 防御
		[13] = "shanbi",								-- 闪避
		[14] = "mingzhong",								-- 命中
		[15] = "baoji",									-- 暴击
		[16] = "jian_ren",								-- 抗暴
		[17] = "constant_zengshang",					-- 增伤
		[18] = "constant_mianshang",					-- 免伤
}
local GONGMING_ATTR_LIST_MAX_NUM = 4

function MythData:__init()
	if MythData.Instance then
		print_error("[MythData] Attempt to create singleton twice!")
		return
	end
	MythData.Instance = self

	self.myth_chpater_info = {
		soul_essence = 0,
		chpater_list = {},
	}

	self.myth_knapask_info = {
		count = 0,
		list = {},
	}

	self.myth_chpater_single_info = {
		soul_essence = 0,
		chpater_id = 0,
		single_item = {},
	}
	self.zero = 0
	self.position = {}
	self.is_lock_list = {}
	-- self.islock1 = false
	-- self.islock2 = false
	-- self.islock3 = false
	self.soul_essence = 0 				--神圣精华数量
	self.enougth = true
	self.mid_index = 0
	self.selecttab = 0
	self.shenhun_flag = 0

	self.rand_attr_list = {}
	self.soul_god_list = {}
	self.myth_knapsack_list = {}
	self.chapters_total_attr = {maxhp = 0,gongji = 0,fangyu = 0,mingzhong = 0,shanbi = 0,baoji = 0,jianren = 0,constant_zengshang = 0,constant_mianshang = 0}
	self.chapters_now_level_list = {}		--所有篇章的等级

	self:InitMythCfg()

	RemindManager.Instance:Register(RemindName.ShenHuaPianZhang, BindTool.Bind(self.GetMythPianZhanRemind, self))
	RemindManager.Instance:Register(RemindName.ShenHuaGongMing, BindTool.Bind(self.GetMythGongMingRemind, self))
end

function MythData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenHuaPianZhang)
	RemindManager.Instance:UnRegister(RemindName.ShenHuaGongMing)
	MythData.Instance = nil
end

------------------------ 配置表处理 ----------------------

function MythData:InitMythCfg()
	local myth_cfg = ConfigManager.Instance:GetAutoConfig("myth_auto")
	if myth_cfg then
		self.chapter_cfg = myth_cfg.chapter
		self.resonance_cfg = myth_cfg.resonance
		self.decompose_cfg = myth_cfg.decompose
		self.digestion_cfg = myth_cfg.digestion
		self.baoji_cfg = myth_cfg.baoji
		self.god_soul_cfg = myth_cfg.god_soul
		self.rand_attr_count_cfg = myth_cfg.rand_attr_count
		self.rand_attr_cfg = myth_cfg.rand_attr
		self.synthesis_exchange_cfg = myth_cfg.synthesis_exchange
		self.inlay_cfg = myth_cfg.inlay
		self.activate_section_level_cfg = myth_cfg.activate_section_level
		self.chapter_name_cfg = myth_cfg.chpater_name

		self.sort_cui_qu_cfg = ListToMap(self.decompose_cfg, "item_id")
		self.god_soul_cfg = ListToMap(self.god_soul_cfg, "item_id")
		self.resonance_open_limit_cfg = ListToMap(myth_cfg.resonance_open_limit, "chpater_id", "level")
		self.resonance_list_cfg = ListToMap(self.resonance_cfg, "chpater", "level")
		self.chapter_list_cfg = ListToMap(self.chapter_cfg, "chpater_id", "level")
		self.chpater_name_list_cfg = ListToMapList(myth_cfg.chpater_name, "quality")
	end
end
----------------------------------------------------------

------------------------ 接收的协议 ----------------------

function MythData:SetSCMythChpaterInfo(protocol)
	self.myth_chpater_info.soul_essence = protocol.soul_essence
	self.myth_chpater_info.chpater_list = protocol.chpater_list
	self.soul_essence = self.myth_chpater_info.soul_essence

	self:SetChapterTotalAttr(i, true)
	for i=1, MYTH_TYPE.MAX_MYTH_CHAPTER_ID do
		self:SetSoulGodList(i)
		self.chapters_now_level_list[i] = self.myth_chpater_info.chpater_list[i].level
	end
	self:SetAllKnapsackData()
end

function MythData:SetSCFirstMythKnapaskInfo(protocol)
	self.myth_knapask_info.count = protocol.count
	self.myth_knapask_info.is_all = protocol.is_all
	self.myth_knapask_info.list = protocol.list
end

function MythData:SetSCMythKnapaskInfo(protocol)
	for k,v in pairs(protocol.list) do
		self.myth_knapask_info.list[v.index] = v
		self:SetKnapsackSingleData(v)
	end
end

--获取虚拟背包列表
function MythData:GetMythKnapaskList()
	return self.myth_knapask_info.list
end

function MythData:SetSCMythChpaterSingleInfo(protocol)
	self.myth_chpater_single_info.soul_essence = protocol.soul_essence
	self.myth_chpater_single_info.chpater_id = protocol.chpater_id
	self.myth_chpater_single_info.single_item = protocol.chpater_list
	self.myth_chpater_info.chpater_list[protocol.chpater_id] = protocol.chpater_list
	self.soul_essence = self.myth_chpater_single_info.soul_essence
	self:SetSoulGodList(protocol.chpater_id)
	self:UpdateSCMythChpaterInfo(self.myth_chpater_single_info.chpater_id)
end

function MythData:UpdateSCMythChpaterInfo(index)
	if self.myth_chpater_info.chpater_list then
		self.myth_chpater_info.chpater_list[index] = self.myth_chpater_single_info.single_item
	end
end

---------------领悟------------------

function MythData:GetItemCfgByIdAndLevel(chpater_id,level)
	local cfg = self.digestion_cfg or {}
	for k,v in pairs(cfg) do
		if v.chpater_id == chpater_id and v.digestion_level == level then
			return v
		end
	end
	return {}
end

function MythData:GetLingWuItemAttr(chpater_id,level)
	local data = {}
	if level > 0 then
		local cfg = self:GetItemCfgByIdAndLevel(chpater_id,level)
		local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
		for k,v in pairs(attr) do
			if v > 0 then
				local dd = {name = k,value = v}
				table.insert(data,dd)
			end
		end
	else
		data = {{name = "fangyu",value = 0},
				{name = "gongji",value = 0},
				{name = "maxhp",value = 0}}
	end
	return data
end

function MythData:GetItemNameById(chpater_id)
	local cfg = self.chapter_cfg or {}
	for k,v in pairs(cfg) do
		if chpater_id == v.chpater_id then
			local item_cfg = {
			name = v.name,
			quality = v.quality,
			}
			return item_cfg
		end
	end
end

function MythData:GetChapterNameById(chpater_id)
	local cfg = self.chapter_cfg or {}
	for k,v in pairs(cfg) do
		if chpater_id == v.chpater_id then
			return v.name or ""
		end
	end
	return ""
end

function MythData:GetLingWuLevelById(chpater_id)
	if chpater_id == nil then
		return 0
	end
	local chapter_list = self:GetChapterListByIndex(chpater_id)
	if next(chapter_list) == nil then
		return 0
	end 
	return chapter_list.digestion_level or 0
end

function MythData:GetLingWuLevelValById(chapter_id)
	if chapter_id == nil then
		return 0
	end
	local chapter_list = self:GetChapterListByIndex(chapter_id)
	if next(chapter_list) == nil then
		return 0
	end 
	return chapter_list.digestion_level_val or 0
end

function MythData:GetLingWuSoulEssence()
	return self.soul_essence
end

function MythData:GetLingWuAttrCapability(chpater_id,level)
	local cfg = self:GetItemCfgByIdAndLevel(chpater_id,level)
	local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
	return CommonDataManager.GetCapability(attr)
end

function MythData:GetLingWuMaxLevel()
	local cfg = self.digestion_cfg or {}
	local max_level = 0
	for k,v in pairs(cfg) do
		if v.chpater_id == 1 then
			max_level = max_level + 1
		end
	end
	return max_level - 1
end

function MythData:GetLingWuRedPointFlag(chpater_id)
	if not  self.myth_chpater_info.chpater_list[chpater_id] then return 0 end

	local level = self.myth_chpater_info.chpater_list[chpater_id].digestion_level
	local cfg = self:GetItemCfgByIdAndLevel(chpater_id,level)
	if self.soul_essence >= cfg.single_essence and level < MythData.Instance:GetLingWuMaxLevel() then
		return 1
	else
		return 0
	end
end


---------------神魂------------------

function MythData:SetSoulGodList(select_writing_id)
	local soul_god_list = {}
	if self.myth_chpater_info.chpater_list[select_writing_id] and self.myth_chpater_info.chpater_list[select_writing_id].soul_god_list then
		soul_god_list = self.myth_chpater_info.chpater_list[select_writing_id].soul_god_list
		local grid_index = 0
		for i=1,MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
			grid_index = grid_index + 1
			local item_cfg = self:GetGodSoulConfig(soul_god_list[i].item_id)
		 	local base_cap = CommonDataManager.GetCapability(item_cfg)
			local rand_cap = self:ComputingAttrListPower(soul_god_list[i].attr_list, soul_god_list[i].quality)
			local cap = base_cap + rand_cap
			soul_god_list[i].grid_index = grid_index
			soul_god_list[i].cap = cap
		end
		self.soul_god_list[select_writing_id] = soul_god_list
	end
end

--已装备格子
function MythData:GetSoulGodList(select_writing_id)
	return self.soul_god_list[select_writing_id] or {}
end

function MythData:SetAllKnapsackData()
	local knapsack_list = self.myth_knapask_info.list
	if nil == knapsack_list then return end

	self.myth_knapsack_list = {}
	for k,v in pairs(knapsack_list) do
		self:InsertKnapsackList(v)
	end

	self:FlushKnapsackDataListSort()
end

function MythData:SetKnapsackSingleData(single_data_info)
	if not self.myth_knapsack_list then return end
	for i,v in ipairs(self.myth_knapsack_list) do
		if v.inlay_index == single_data_info.index then
			if single_data_info.item.num > 0 then
				table.remove(self.myth_knapsack_list, i)
				self:InsertKnapsackList(single_data_info)
			else
				table.remove(self.myth_knapsack_list, i)
			end
			self:FlushKnapsackDataListSort()
			return
		end
	end

	if single_data_info.item.num > 0 then
		self:InsertKnapsackList(single_data_info)
		self:FlushKnapsackDataListSort()
	end
end

function MythData:InsertKnapsackList(single_data_info)
	local cfg = self.god_soul_cfg or {}
	for k1,v1 in pairs(cfg) do
		if single_data_info.item.item_id == v1.item_id then
			local cfg_list = TableCopy(single_data_info.item)
			cfg_list["inlay_index"] = single_data_info.index
			cfg_list["god_soul_type"] = v1.soul_type
			local base_cap = CommonDataManager.GetCapability(v1)
			local rand_cap = self:ComputingAttrListPower(single_data_info.item.attr_list, single_data_info.item.quality)
			local cap = base_cap + rand_cap
			cfg_list["cap"] = cap
			table.insert(self.myth_knapsack_list, cfg_list)
			return
		end
	end
end

function MythData:FlushKnapsackDataListSort()
	if not self.myth_knapsack_list or not next(self.myth_knapsack_list) then return end
	SortTools.SortDesc(self.myth_knapsack_list, "cap")
	local index = 0
	for i,v in ipairs(self.myth_knapsack_list) do
		index = index + 1
		v["grid_index"] = index
	end
end

--从背包中筛选相同类型的装备的数据
function MythData:GetKnapsackDataByType(god_soul_type)
	local list = {}
	if not self.myth_knapsack_list then 
		return list 
	end

	for i,v in ipairs(self.myth_knapsack_list) do
		if v.god_soul_type == god_soul_type then
			table.insert(list, v)
		end
	end

	return list
end

function MythData:GetKnapsackIndexByGridIndex(select_grid_index)
	if not self.myth_knapsack_list then return end
	for i,v in ipairs(self.myth_knapsack_list) do
		if v.grid_index == select_grid_index then
			return v.inlay_index
		end
	end
end

--镶嵌条件
function MythData:GetInlayDemand(select_writing_id)
	local cfg = self.inlay_cfg or {}
	local data ={}
	for k,v in pairs(cfg) do
		if v.chpater_id == select_writing_id then
			table.insert(data,v)
		end
	end
	return data
end

--根据ID获取配置
function MythData:GetGodSoulConfig(item_id)
	local cfg = self.god_soul_cfg or {}
	for k,v in pairs(cfg) do
		if item_id == v.item_id then
			return v
		end
	end
	return {}
end

function MythData:GetRandAttrCfg(quality, attr_type)
	local random_attr_cfg = self.rand_attr or {}
	for i,v in ipairs(random_attr_cfg) do
		if quality == v.quality and attr_type == v.attr_type then
			return v
		end
	end
	return {}
end

----获取随机属性战力
--attr_list格式：{1={item_id = xxx , attr_list = {1 = {...},2 = {...},3 = {...}}},2={...},}
function MythData:ComputingAttrListPower(attr_list, quality)
	local all_attr = self:GetChapterTotalAttr()
	if nil == attr_list then 
		return 0
	end
	local rand_attr_tab = {maxhp = 0,gongji = 0,fangyu = 0,mingzhong = 0,shanbi = 0,baoji = 0,jianren = 0,constant_zengshang = 0,constant_mianshang = 0}
	for i=1, MYTH_TYPE.MAX_MYTH_SOUL_RAND_ATTR_COUNT do
		local attr = attr_list[i]
		local attr_name = ShenHunAttrType[attr.attr_type]
		local rand_attr_cfg = self:GetRandAttrCfg(quality, attr.attr_type)
		if next(rand_attr_cfg) ~= nil and attr_name then
			if rand_attr_cfg.is_star_attr > 0 then
				rand_attr_tab[attr_name] = rand_attr_tab[attr_name] + (all_attr[attr_name] * rand_attr_cfg.attr_value * 0.0001)
			elseif rand_attr_cfg.is_star_attr == 0 then
				rand_attr_tab[attr_name] = rand_attr_tab[attr_name] + rand_attr_cfg.attr_value
			end
		end
	end
	local rand_cap = CommonDataManager.GetCapability(rand_attr_tab)
	return rand_cap
end

----背包与格子的战力对比
--v.grid_index 相当于三个格子上的装备对应的类型
function MythData:ComparePower(select_writing_id,god_soul_type)
	local grid_cap_list = self:GetSoulGodList(select_writing_id)
	if not grid_cap_list then return {} end
	local knapsack_cap_list = self:GetKnapsackDataByType(god_soul_type)
	local bool_list = {}
	for k,v in pairs(grid_cap_list) do
		local bool = 0
		if next(knapsack_cap_list) and v.grid_index == knapsack_cap_list[1].god_soul_type and 
			knapsack_cap_list[1].cap > v.cap then

			bool = 1
		end
		table.insert(bool_list, bool)
	end
	return bool_list
end

--神魂红点
function MythData:GetShenHunRemidFlage(select_writing_id,god_soul_type)
	local bool_list = self:ComparePower(select_writing_id,god_soul_type)
	local num = 0
	for k,v in pairs(bool_list) do
		num = num + v
	end
	return num
end

function MythData:SetChapterTotalAttr(chapter_index, is_all)
	if nil == self:GetChpaterList() or not next(self:GetChpaterList()) then return end
	local chapters_now_level = self:GetChpaterList()

	if is_all then
		self:CalculateChapterTotalAttr()
	elseif chapters_now_level[chapter_index] and chapters_now_level[chapter_index].level > 0 then
		if nil == self.chapters_now_level_list[chapter_index] then
			self.chapters_now_level_list[chapter_index] = chapters_now_level[chapter_index].level
		elseif chapters_now_level[chapter_index].level > self.chapters_now_level_list[chapter_index] then
			self.chapters_now_level_list[chapter_index] = chapters_now_level[chapter_index].level
		else
			return
		end
		self:CalculateChapterTotalAttr()
	end
end

function MythData:CalculateChapterTotalAttr()
	self.chapters_total_attr = {maxhp = 0,gongji = 0,fangyu = 0,mingzhong = 0,shanbi = 0,baoji = 0,jianren = 0,constant_zengshang = 0,constant_mianshang = 0, per_pofang = 0, per_mianshang = 0}
	local chapters_all_attr = {}
	local chapters_now_level = self:GetChpaterList()
	for i=1, MYTH_TYPE.MAX_MYTH_CHAPTER_ID do
		chapters_all_attr[i] = self:GetChapterNowAttr(i, chapters_now_level[i].level)
	end
	for k,v in pairs(chapters_all_attr) do
		if next(v) then
			for i=1, 3 do
				self.chapters_total_attr[v[i].name] = self.chapters_total_attr[v[i].name] + v[i].value
			end
		end
	end
end

--获取八个篇章所有的篇章基础属性
function MythData:GetChapterTotalAttr()
	return self.chapters_total_attr
end

---------------萃取------------------
function MythData:GetCuiQuItemCfg()
    return self.sort_cui_qu_cfg
end

function MythData:GetRecycleCfg()
	return self.god_soul_cfg
end

function MythData:GetChapterID()
	local chapter_cfg = self.chapter_cfg or {}
	local chapter_id = {}
	for k,v in pairs(chapter_cfg) do
    	chapter_id[v.stuff_id1.item_id] = v.level
    end
	return chapter_id
end

-------------------------篇章-----------------------
function MythData:GetChapterCfg(index,level)
	local cfg = self.chapter_list_cfg
	if cfg == nil then
		return {}
	end
	if cfg[index] == nil or cfg[index][level] == nil then
		return {}
	end
	return cfg[index][level]
end

-- 获取对应篇章共鸣的最大等级
function MythData:GetPianZhangMaxLevelByIndex(chapter_id)
	if self.chapter_list_cfg == nil then
		return 0
	end
	local cfg = self.chapter_list_cfg[chapter_id]
	if cfg == nil then
		return 0
	end
	return #cfg
end

-- 获取篇章Icon图(IconId)
function MythData:GetPianZhangIconId(chapter_id)
	if self.chapter_list_cfg == nil then
		return 0
	end
	local cfg = self.chapter_list_cfg[chapter_id]
	if cfg == nil then
		return 0
	end
	local first_cfg = cfg[1]
	if first_cfg == nil then
		return 0
	end
	local active_item = first_cfg.stuff_id1
	local item_cfg = ItemData.Instance:GetItemConfig(active_item.item_id)
	if item_cfg == nil then
		return 0
	end
	return item_cfg.icon_id or 0
end

-- 获取篇章Icon图(IconId)
function MythData:GetPianZhangItem(chapter_id)
	if self.chapter_list_cfg == nil then
		return 0
	end
	local cfg = self.chapter_list_cfg[chapter_id]
	if cfg == nil then
		return 0
	end
	local first_cfg = cfg[1]
	if first_cfg == nil then
		return 0
	end
	local active_item = first_cfg.stuff_id1
	return active_item.item_id or 0
end

-- 篇章当前等级
function MythData:GetPianZhangCurLevel(chapter_id)
	local chapter_list = self:GetChapterListByIndex(chapter_id)
	if next(chapter_list) == nil then
		return 0
	end
	return chapter_list.level or 0
end

-- 篇章是否可激活
function MythData:GetPianZhangIsCanActive(chapter_id)
	-- 第一级没有限制
	if chapter_id == 1 then
		return true, 0
	end

	local active_cfg = self.activate_section_level_cfg
	if active_cfg == nil then
		return false, 0
	end

	for k,v in pairs(active_cfg) do
		if chapter_id == v.chpater_id then
			local open_level = v.level
			local prior_chapter_list = self:GetChapterListByIndex(chapter_id - 1)
			if next(prior_chapter_list) == nil then
				return false
			end
			local prior_level = prior_chapter_list.level
			return prior_level >= open_level, v.level
		end
	end
	return false, 0
end

-- 获取篇章是否开启
function MythData:GetPianZhangIsOpen(chapter_id)
	local chapter_list = self:GetChapterListByIndex(chapter_id)
	if next(chapter_list) == nil then
		return false
	end
	local level = chapter_list.level or 0
	return level > 0
end

-- 获取篇章名字
function MythData:GetPianZhangNameByIndex(chapter_id)
	-- 默认拿第一级的名字
	local chapter_cfg = self:GetChapterCfg(chapter_id, 1)
	if next(chapter_cfg) == nil then
		return ""
	end
	return chapter_cfg.name or ""
end

-- 获取篇章品质
function MythData:GetPianZhangQualityByIndex(chapter_id)
	if self.chapter_name_cfg == nil then
		return 0
	end
	for k,v in pairs(self.chapter_name_cfg) do
		if v.chpater_id == chapter_id then
			return v.quality + 1
		end
	end
	return 0
end

-- 获取篇章特效
function MythData:GetPianZhangEffectByIndex(chapter_id)
	if self.chapter_name_cfg == nil then
		return ""
	end
	for k,v in pairs(self.chapter_name_cfg) do
		if v.chpater_id == chapter_id then
			return v.effect_name
		end
	end
	return ""
end

function MythData:GetMythPianZhangType()
	if nil ~= self.chpater_name_list_cfg or nil ~= next(self.chpater_name_list_cfg) then
		for k, v in pairs(self.chpater_name_list_cfg) do
			table.sort(v, SortTools.KeyLowerSorter("chpater_id"))
		end
	end
	return self.chpater_name_list_cfg or {}
end

local function SortAttr(a, b)
	local order_a = 100000
	local order_b = 100000

	if a.name == b.name then
		return false
	end

	if a.name == "gongji" then
		order_a  = order_a + 10000
	elseif b.name == "gongji" then
		order_b = order_b + 10000
	end

	if a.name == "fangyu" then
		order_a  = order_a + 1000
	elseif b.name == "fangyu" then
		order_b = order_b + 1000
	end

	if a.name == "maxhp" then
		order_a  = order_a + 100
	elseif b.name == "maxhp" then
		order_b = order_b + 100
	end

	if a.name == "per_pofang" then
		order_a  = order_a + 10
	elseif b.name == "per_pofang" then
		order_b = order_b + 10
	end

	if a.name == "per_mianshang" then
		order_a  = order_a + 1
	elseif b.name == "per_mianshang" then
		order_b = order_b + 1
	end

	return order_a > order_b
end

function MythData:SortListByAttr(cur_list)
	if cur_list and #cur_list > 1 then
		table.sort(cur_list, SortAttr)
	end
	return cur_list
end

function MythData:GetChapterNowAttr(index, level)
	local data = {}
	if nil == index or nil == level or level == 0 then
		return data
	end 

	local cur_cfg = self:GetChapterCfg(index, level)
	if nil == cur_cfg or nil == cur_cfg.maxhp then
		return data
	end

	local attr_list = CommonStruct.AttributeNoUnderline()
	local cur_attr = CommonDataManager.GetGoddessAttributteNoUnderline(cur_cfg)
	for k,v in pairs(attr_list) do
		if cur_attr[k] > 0 then
			local cur_data = {name = k, value = cur_attr[k]}
			table.insert(data,cur_data)
		end
	end

	if data and #data > 1 then
		table.sort(data, SortAttr)
	end

	local power = CommonDataManager.GetCapabilityCalculation(cur_cfg)
	self.nowattr_value = power

	return data
end

function MythData:CalPianZhangAddAttr(attr_list)
	local main_role_attr = PlayerData.Instance:GetRoleVo()
	for k,v in pairs(attr_list) do
		if k == "per_mianshang" then
			local add_max_hp = (attr_list.maxhp + main_role_attr.max_hp) * (v / 10000)
			attr_list.maxhp = attr_list.maxhp + add_max_hp
			attr_list.per_mianshang = 0
		elseif k == "per_pofang" then
			local add_gongji = (attr_list.gongji + main_role_attr.gong_ji) * ((v / 10000) * 1.3)
			attr_list.gongji = attr_list.gongji + add_gongji
			attr_list.per_pofang = 0
		end
	end
end

function MythData:GetNowAttrValue()
	return self.nowattr_value
end

function MythData:GeNextAttrValue()
	return self.nextattr_value
end

function MythData:GetMaxlevel()
	local cfg = self.chapter_cfg or {}
	return math.floor(#cfg / 8)
end

function MythData:GetChapterNextAttr(index, level)
	local data = {}
	if nil == index or nil == level or level == 0 then
		return data
	end 

	local next_cfg = self:GetChapterCfg(index, level)
	if nil == next_cfg or nil == next_cfg.maxhp then
		return data
	end

	local nextattr_list = CommonStruct.AttributeNoUnderline()
	local next_attr = CommonDataManager.GetGoddessAttributteNoUnderline(next_cfg)
	for k,v in pairs(nextattr_list) do
		if next_attr[k] > 0 then
			local next_data = {name = k, value = next_attr[k]}
			table.insert(data, next_data)
		end
	end

	if data and #data > 1 then
		table.sort(data, SortAttr)
	end

	local active_cfg = nil
	if level > 1 then
		active_cfg = self:GetChapterCfg(index, level - 1)
	end

	local power = CommonDataManager.GetCapabilityCalculation(next_cfg)
	self.nextattr_value = power

	return data
end

function MythData:GetGongmingCfg(index,level)
	local cfg = self.resonance_cfg or {}
	for k,v in pairs(cfg) do
		if v.chpater == index and v.level == level then
			return v
		end
	end
	return {}
end

-- 共鸣总属性
function MythData:GetGongMingTotalAttr(chapter_id)
	local resonance_level = self:GetCurGongMingLevel(chapter_id)
	local cfg = self.resonance_list_cfg or {}
	local attr_list = {}
	if next(cfg) == nil then
		return attr_list
	end
	local chapter_cfg = cfg[chapter_id]
	if chapter_cfg == nil or cfg[chapter_id][1] == nil then
		return attr_list
	end
	attr_list[1] = {name = MythGongMingAttrType[chapter_cfg[1].resonance_type1], value = 0}
	attr_list[2] = {name = MythGongMingAttrType[chapter_cfg[2].resonance_type2], value = 0}
	attr_list[3] = {name = MythGongMingAttrType[chapter_cfg[3].resonance_type3], value = 0}
	attr_list[4] = {name = MythGongMingAttrType[chapter_cfg[4].resonance_type4] or "", value = 0}
	-- 前面等级的属性值之和
	if resonance_level ~= 1 then
		for i = 1, resonance_level - 1 do
			if chapter_cfg[i] then
				attr_list[1].value = attr_list[1].value + chapter_cfg[i].resonance_val1
				attr_list[2].value = attr_list[2].value + chapter_cfg[i].resonance_val2
				attr_list[3].value = attr_list[3].value + chapter_cfg[i].resonance_val3
				if attr_list[4].name ~= "" then
					attr_list[4].value = attr_list[4].value + chapter_cfg[i].resonance_val4
				end
			end
		end
	end
	-- 当前等级属性值
	local lock_num = self:GetIsLockNum(chapter_id)
	if lock_num >= 1 and chapter_cfg[resonance_level] then
		attr_list[1].value = attr_list[1].value + chapter_cfg[resonance_level].resonance_val1
	end
	if lock_num >= 2 and chapter_cfg[resonance_level] then
		attr_list[2].value = attr_list[2].value + chapter_cfg[resonance_level].resonance_val2
	end
	if lock_num >= 3 and chapter_cfg[resonance_level] then
		attr_list[3].value = attr_list[3].value + chapter_cfg[resonance_level].resonance_val3
		if attr_list[4].name ~= "" then
			attr_list[4].value = attr_list[4].value + chapter_cfg[resonance_level].resonance_val4
		end
	end
	return attr_list
end

function MythData:AddTwoAttrList(attr_list, add_attr_list)
	local list = {}
	if nil == attr_list or nil == add_attr_list then
		return list
	end

	local num = 0
	for i = 1,  GONGMING_ATTR_LIST_MAX_NUM do
		if attr_list[i] and add_attr_list[i] and attr_list[i].name and add_attr_list[i].name
		 and attr_list[i].value and add_attr_list[i].value and attr_list[i].name == add_attr_list[i].name then
		 	local cur_attr_list = {}
		 	cur_attr_list.name = attr_list[i].name
		 	cur_attr_list.value = attr_list[i].value + add_attr_list[i].value
		 	table.insert(list, cur_attr_list)
		 	num = num + 1
		end
	end

	if num == 0 then
		list = add_attr_list
	end

	return list
end

function MythData:GetGongMingTotalAttrByLevel(chapter_id, level)
	local attr_list = {}
	if nil == chapter_id or nil == level or level <= 0 then
		return attr_list
	end
	
	for i = 1, level do
		local cur_level_list = self:GetGongMingCurAttrList(chapter_id, i)
		if cur_level_list and next(cur_level_list) then
			table.sort(cur_level_list, SortAttr)
			attr_list = self:AddTwoAttrList(attr_list, cur_level_list)
		end
	end
	return attr_list
end

--获取共鸣当前等级总属性
function MythData:GetGongMingTotalAttrList(chapter_id, level)
	local attr_list = {}
	if nil == chapter_id or nil == level then
		return attr_list
	end

	local gongming_attr_list = self:GetGongMingTotalAttrByLevel(chapter_id, level)
	if nil == gongming_attr_list then
		return attr_list
	end

	attr_list = self:ClassifyGongMingAddAttr(gongming_attr_list)
	return attr_list
end

function MythData:GetGongMingTotalPowerByLevel(chapter_id, level, is_need_next_level_power)
	local cur_power = 0
	local next_power = 0

	local attr_list = self:GetGongMingTotalAttrList(chapter_id, level)
	local next_attr_list = self:GetGongMingTotalAttrList(chapter_id, level + 1)

	-- cur_power = CommonDataManager.GetCapability(attr_list, true, attr_list)
	cur_power = CommonDataManager.GetCapabilityCalculation(attr_list)
	next_power = CommonDataManager.GetCapabilityCalculation(next_attr_list)
	-- next_power = CommonDataManager.GetCapability(next_attr_list, true)

	return cur_power, next_power
end

function MythData:GrtGongMingZhanLi()
	return self.gongming_zhanli
end


function MythData:GetGongMingActiviteCap()
	return self.activite_cap
end

function MythData:GetChpaterList()
	return self.myth_chpater_info.chpater_list
end

function MythData:GetChapterListByIndex(index)
	if index == nil or self.myth_chpater_info.chpater_list == nil or next(self.myth_chpater_info.chpater_list) == nil then
		return {}
	end
	return self.myth_chpater_info.chpater_list[index] or {}
end

function MythData:GetPianZhanActivite(index)
	local chapter = self.myth_chpater_info.chpater_list[index]
	if nil == chapter then
		return false
	end

	return chapter.level >= 1
end

function MythData:GetSingleChapterInfo()
	return self.myth_chpater_single_info.single_item
end

function MythData:GetSingleResonanceInfo()
	return self.resonance_info
end

function MythData:SetPianzhanZero(num)
	self.zero = num
end

function MythData:GetPianZhanZero()
	return self.zero
end

function MythData:GetIsLock()
	return self.is_lock_list
end

function MythData:SetNotEnougth(boolen)
	self.enougth = boolen
end

function MythData:GetNotEnougth()
	return self.enougth
end

function MythData:GetRedPointList()
	self.redpoint_cfg = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
	}
	local auto_cfg = self.chapter_cfg or {}
	local chapter_list = self:GetChpaterList()
	local resonance_list = self.resonance_cfg or {}
	local bag_list = self:GetMythKnapaskList()
	if bag_list == nil then return self.redpoint_cfg end

	--有点恶心，不同面板红点不一样
	for k,v in pairs(chapter_list) do
		local activite_num = self:GetResonanceInfo(k,v.level)
		--升级面板，两个材料是否满足
		if activite_num == 3 or v.level == 0 then
			for k1,v1 in pairs(auto_cfg) do
					if k == v1.chpater_id and v1.level == v.level + 1 then
						local num1 = v1.stuff_id1.num
						local can_num1 = false
						for k2,v2 in pairs(bag_list) do
							if v1.stuff_id1.item_id == v2.item.item_id then
								if v2.item.num >= num1 then
									can_num1 =true
								end
							else
								self.redpoint_cfg[k] = false
							end

							if can_num1 then
								self.redpoint_cfg[k] = true
							else
								self.redpoint_cfg[k] = false
							end
						end
						if v1.level == 8 then
							self.redpoint_cfg[k] = false
						end
					end
			end
		else
			--共鸣面板红点
			for k3,v3 in pairs(resonance_list) do
				if k == v3.chpater and v3.level == v.level then
					for k4,v4 in pairs(bag_list) do
						if v3.stuff_id.item_id == v4.item.item_id then
							if v4.item.num >= v3.stuff_id.num then
								self.redpoint_cfg[k] = true
							else
								self.redpoint_cfg[k] = false
							end
						-- else
						-- 	self.redpoint_cfg[k] = false
						end
					end
				end
			end
		end
	end

	return self.redpoint_cfg
end

-- 单个篇章红点
function MythData:GetPianzhangItemRedPoint(chapter_id)
	-- 不可激活
	local is_can_active = self:GetPianZhangIsCanActive(chapter_id)
	if is_can_active == false then
		return false
	end

	local chapter_info = self:GetChapterListByIndex(chapter_id)
	if next(chapter_info) == nil then
		return false
	end

	local chapter_list_cfg = self.chapter_list_cfg
	if chapter_list_cfg == nil then
		return false
	end

	if chapter_list_cfg[chapter_id] == nil then
		return false
	end

	-- 满级
	local max_level = #chapter_list_cfg[chapter_id]
	local level = chapter_info.level or 0
	if level == max_level then
		return false
	end
	level = level == max_level and max_level or level + 1

	if chapter_list_cfg[chapter_id][level] then
		local cur_cfg = chapter_list_cfg[chapter_id][level]
		local stuff_item = cur_cfg.stuff_id1 or {}
		local stuff_need_num = stuff_item.num or 0
		local stuff_in_bag_num = ItemData.Instance:GetItemNumInBagById(stuff_item.item_id)
		if stuff_in_bag_num >= stuff_need_num then
			return true
		end
	end
	return false
end

function MythData:SetPianzhanRedPoint(index,boolen)
	self.redpoint_cfg[index] = boolen
end

------------------------------ 共鸣 ------------------------------
-- 共鸣是否开启
function MythData:GetGongMingIsOpenByIndex(chapter_id)
	local chapter_list = self:GetChapterListByIndex(chapter_id)
	if next(chapter_list) == nil then
		return false, 0
	end

	local resonance_list = chapter_list.resonance_list
	if resonance_list == nil then
		return false, 0
	end

	local cfg = self.resonance_open_limit_cfg
	if cfg == nil or cfg[chapter_id] == nil then
		return false, 0
	end

	local chapter_level = chapter_list.level or 0
	local resonance_max_level = #cfg[chapter_id]
	local resonance_level = resonance_list.resonance_level or 0
	if resonance_level >= resonance_max_level then
		return true, 0
	end
	resonance_level = resonance_level == 0 and 1 or resonance_level

	if cfg[chapter_id][resonance_level] then
		local open_level = cfg[chapter_id][resonance_level].grid_level or 0
		return chapter_level >= open_level, open_level
	end
	return false, 0
end

-- 获取对应篇章共鸣的最大等级
function MythData:GetGongMingMaxLevelByIndex(chapter_id)
	if self.resonance_open_limit_cfg == nil then
		return 0
	end
	local cfg = self.resonance_open_limit_cfg[chapter_id]
	if cfg == nil then
		return 0
	end
	return #cfg
end

-- 获取共鸣材料数量
function MythData:GetGongMingStuffNumInBag(chapter_id, level)
	if level <= 0 then
		return 0
	end
	local cfg = self:GetGongmingCfg(chapter_id, level)
	if next(cfg) == nil then
		return 0
	end
	local stuff_id = cfg.stuff_id.item_id or 0
	
	return count
end

-- 获取当前共鸣属性列表
function MythData:GetGongMingCurAttrList(index, level)
	local attr_list = {}
	if nil == index or nil == level then
		return attr_list
	end

	local cfg = self:GetGongmingCfg(index, level)
	if nil == cfg then
		return attr_list
	end

	for i = 1, GONGMING_ATTR_LIST_MAX_NUM do
		if cfg["resonance_type" .. i] then
			local list = {}
			list.name = MythGongMingAttrType[cfg["resonance_type" .. i]] or ""
			list.value = cfg["resonance_val" .. i]
			table.insert(attr_list, list)
		end
	end

	return attr_list
end


-- 获取当前共鸣战力，第一个返回值为本卷共鸣战力，第二个返回值为本卷已激活属性战力
function MythData:GetCurGongMingPower(index, level, active_num)
	local total_power = 0
	local active_power = 0
	local cur_attr_list = self:GetGongMingCurAttrList(index, level)
	if nil == cur_attr_list or nil == next(cur_attr_list) then
		return total_power, active_power
	end

	if active_num == nil then
		active_num = self:GetIsLockNum()
	end

	local total_attr_list = self:ClassifyGongMingAddAttr(cur_attr_list)
	local active_attr_list = self:ClassifyGongMingAddAttr(cur_attr_list, true, active_num)
	total_power = CommonDataManager.GetCapability(total_attr_list, true)
	active_power = CommonDataManager.GetCapability(active_attr_list, true, active_attr_list)

	return total_power, active_power
end

--获取计算全身加成属性后的属性列表
function MythData:ClassifyGongMingAddAttr(list, is_classify_active, active_num)
	if list == nil then
		return
	end

	local attr_list = {}
	for k,v in pairs(list) do
		if v.name and v.name ~= "" and v.name ~= "whole_gongji" and v.name ~= "whole_fangyu" 
		 and v.name ~= "whole_maxhp" and v.name ~= "whole_baoshang" and v.name ~= "whole_zengshang" 
		 and v.name ~= "whole_mianshang" then
			attr_list[v.name] = v.value
		end
	end

	local num = active_num or 1
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(list) do
		if (is_classify_active and k ~= GONGMING_ATTR_LIST_MAX_NUM and k <= num ) 
		 or not is_classify_active then
			if v.name then
				local whole_add = v.value or 0
				local whole_add_per = whole_add / 10000
				if name == "whole_gongji" then
					local base_gongji = vo.base_gongji or 0
					local cfg_gongji = attr_list.gongji or 0
					local gongji = base_gongji + cfg_gongji
					local add_gongji = gongji * whole_add_per
					attr_list.gongji = gongji + add_gongji

				elseif name == "whole_fangyu" then
					local base_fangyu = vo.base_fangyu or 0
					local cfg_fangyu = attr_list.fangyu or 0
					local fangyu = base_fangyu + cfg_fangyu
					local add_fangyu = fangyu * whole_add_per
					attr_list.fangyu = fangyu + add_fangyu

				elseif name == "whole_maxhp" then
					local base_max_hp = vo.base_max_hp or 0
					local cfg_maxhp = attr_list.maxhp or 0
					local maxhp = base_max_hp + cfg_maxhp
					local add_maxhp = maxhp * whole_add_per
					attr_list.maxhp = maxhp + add_maxhp

				elseif name == "whole_baoshang" then
					local base_per_baoji = vo.base_per_baoji or 0
					local cfg_per_baoji = attr_list.per_baoji or 0
					local per_baoji = base_per_baoji + cfg_per_baoji
					local add_per_baoji = per_baoji * whole_add_per
					attr_list.per_baoji = per_baoji + add_per_baoji

				elseif name == "whole_zengshang" then
					local base_per_pofang = vo.base_per_pofang or 0
					local cfg_per_pofang = attr_list.per_pofang or 0
					local per_pofang = base_per_pofang + cfg_per_pofang
					local add_per_pofang = per_pofang * whole_add_per
					attr_list.per_pofang = per_pofang + add_per_pofang

				elseif name == "whole_mianshang" then
					local base_per_mianshang = vo.base_per_mianshang or 0
					local cfg_per_mianshang = attr_list.per_mianshang or 0
					local per_mianshang = base_per_mianshang + cfg_per_mianshang
					local add_per_mianshang = per_mianshang * whole_add_per
					attr_list.per_mianshang = per_mianshang + add_per_mianshang

				end
			end
		end
	end

	return attr_list
end

-- 获取当前等级
function MythData:GetCurGongMingLevel(index)
	local chapter_cfg = self:GetChapterListByIndex(index)
	if next(chapter_cfg) == nil then
		return 0
	end
	local resonance_list = chapter_cfg.resonance_list
	if resonance_list == nil then
		return 0
	end

	-- 篇章达到共鸣开启等级时默认升为1级
	local is_open = self:GetGongMingIsOpenByIndex(index)
	local max_level = self:GetGongMingMaxLevelByIndex(index)
	local level = resonance_list.resonance_level or 0
	if is_open and level == 0 then
		level = 1
	end
	return level
end

-- 获得共鸣的锁定
function MythData:GetGongMingLockList(chapter_id)
	local resonance_lock_list = {}

	local chapter_list = self:GetChapterListByIndex(chapter_id)
	if next(chapter_list) == nil then
		return resonance_lock_list
	end

	local resonance_info = chapter_list.resonance_list or {}
	local resonance_level = resonance_info.resonance_level or 0
	if resonance_level == 0 then
		return resonance_lock_list
	end

	local cfg = self.resonance_list_cfg
	if cfg == nil or next(cfg) == nil then
		return resonance_lock_list
	end

	if cfg[chapter_id] and cfg[chapter_id][resonance_level] then
		local cur_resonance_cfg = cfg[chapter_id][resonance_level]
		local cur_level_resonance = resonance_info.cur_level_resonance or {}
		resonance_lock_list[1] = cur_level_resonance[1] == cur_resonance_cfg.position_1
		resonance_lock_list[2] = cur_level_resonance[2] == cur_resonance_cfg.position_2
		resonance_lock_list[3] = cur_level_resonance[3] == cur_resonance_cfg.position_3
		return resonance_lock_list
	end
	return resonance_lock_list
end

-- 获得共鸣的激活数量
function MythData:GetIsLockNum(chapter_id)
	local lock_list = self:GetGongMingLockList(chapter_id) or {}
	local activite_num = 0
	for k,v in pairs(lock_list) do
		if v then
			activite_num = activite_num + 1
		end
	end
	return activite_num
end

-- 共鸣界面单个item红点
function MythData:GetGongMingItemRedPoint(chapter_id)
	local is_open = self:GetGongMingIsOpenByIndex(chapter_id)
	if is_open == false then
		return false
	end

	local level = self:GetCurGongMingLevel(chapter_id)
	local max_level = self:GetGongMingMaxLevelByIndex(chapter_id)
	local lock_num = self:GetIsLockNum(chapter_id)
	-- 满级直接退出
	if level >= max_level and lock_num >= 3 then
		return false
	end

	if self.resonance_list_cfg and self.resonance_list_cfg[chapter_id] and self.resonance_list_cfg[chapter_id][level] then
		local cfg = self.resonance_list_cfg[chapter_id][level]
		local stuff_item = cfg.stuff_id or {}
		local stuff_num = stuff_item.num or 0
		local stuff_count = ItemData.Instance:GetItemNumInBagById(stuff_item.item_id)
		if stuff_count >= stuff_num then
			return true
		end
	end

	return false
end

-------------------------------合成-------------------------------

function MythData:GetMythComposeTypeOfCount()
	local equipforge_cfg = self.synthesis_exchange_cfg or {}
	local list = {}
	for k,v in ipairs(equipforge_cfg) do
		list[k] = {}
		list[k].seq = v.seq
		list[k].item_id = v.after_item_id
		list[k].give_quality = ItemData.Instance:GetItemConfig(v.after_item_id).color
		list[k].need_quality = ItemData.Instance:GetItemConfig(v.before_item_id).color
		list[k].give_start_num = v.give_start_num
		list[k].need_start_num = v.need_start_num
		list[k].before_item_id = v.before_item_id
		list[k].is_need_item = v.is_need_item
		list[k].stuff_id = v.stuff_id
		list[k].item_num = v.item_num
		list[k].is_broatcast = v.is_broatcast
	end
	local data_list = {}
	for k,v in ipairs(list) do
		if data_list[v.give_start_num] == nil then
			data_list[v.give_start_num] = {}
		end
		table.insert(data_list[v.give_start_num], v)
	end

	local acc_data_list = {}
	for k, child_list in pairs(data_list)do
		local item_data = {}
		for k,v in ipairs(child_list)do
			table.insert(item_data, v)
		end
		table.insert(acc_data_list, item_data)
	end
	return acc_data_list
end

function MythData:GetItemDataList(target_data,index)
	local stuff_list = self:GetMythKnapaskList()

	local sheng_hun_list = {}
	for k,v in pairs(stuff_list) do
		sheng_hun_list[k] = {}
		sheng_hun_list[k].num = stuff_list[k].item.num
		sheng_hun_list[k].item_id = stuff_list[k].item.item_id
		sheng_hun_list[k].attr_list = stuff_list[k].item.attr_list
		sheng_hun_list[k].index = stuff_list[k].index
	end

	local list = {}
	for k,v in pairs(sheng_hun_list) do
		--筛选品质和类型
		if v.item_id == target_data.item_id - 1 then
			local cfg = self:GetGodsoulBaseattr(v.item_id)
			local satrt_count = 0
			---筛选星级`
			for k1,v1 in pairs(v.attr_list) do
				local start_cfg = self:GetRandomAttrCfg(cfg.quality, v1.attr_type)
				if start_cfg and start_cfg.is_star_attr == 1 then
					satrt_count = satrt_count + 1
				end
			end
			if satrt_count == target_data.need_start_num then
				sheng_hun_list[k].start = satrt_count
				table.insert(list,v)
			end
		end
	end
	if not index then
		return list
	end
	-----去除已选
	for k1,v1 in pairs(index) do
		for k,v in pairs(list) do
			if v1 == v.index  then
				table.remove(list,k)
				break
			end
		end
	end

	return list
end

function MythData:GetGodsoulBaseattr(item_id)
	local equipforge_cfg = self.god_soul_cfg or {}
	for k,v in pairs(equipforge_cfg) do
		if item_id == v.item_id then
			return v
		end
	end
	return nil
end

function MythData:GetRanAttrList(quality, legend_num)
	local legend_attr_list = {}
	local attr_list = {}
	local rand_attr = {}
	local gonglve_legend_attr = self.rand_attr or {}
	for k,v in pairs(gonglve_legend_attr) do
		if quality == v.quality then
			if v.is_star_attr == 1 then
				table.insert(legend_attr_list, v)
			else 
				table.insert(attr_list, v)
			end
		end
	end

	local num_list = GameMath.RandList(1, #legend_attr_list, legend_num)
	local num_list_2 = GameMath.RandList(1, #attr_list, 3 - legend_num)
	for k,v in pairs(num_list) do
		table.insert(rand_attr, legend_attr_list[v])
	end

	for k,v in pairs(num_list_2) do
		table.insert(rand_attr, attr_list[v])
	end

	return rand_attr
end

function MythData:GetRandomAttrCfg(quality, attr_type)
	local cfg = self.rand_attr_cfg or {}
	for k,v in pairs(cfg) do
		if quality == v.quality and attr_type == v.attr_type then
			return v
		end
	end
	return {}
end

function MythData:GetMythcomposeRedCount(data)
	local has_num = ItemData.Instance:GetItemNumInBagById(data.stuff_id)
	local equip_list = #MythData.Instance:GetItemDataList(data)

	if not equip_list then
	 	return 0
	end

	if data.is_need_item == 0 then
	 	return  math.floor(equip_list / 3)
	else
	 	return math.min(math.floor(equip_list / 3), math.floor(has_num / need_num))
	end
end

function MythData:SetSelectTab(index)
	self.selecttab = index
end

function MythData:GetSelectTab()
	return self.selecttab
end

------红点提示-------
--篇章
function MythData:GetMythPianZhanRemind()
	if OpenFunData.Instance:CheckIsHide("MythView") == false then
		return 0
	end

	local cfg = self.chapter_list_cfg or {}
	local max_num = #cfg
	for i = 1, max_num do
		if self:GetPianzhangItemRedPoint(i) then
			return 1
		end
	end
	return 0
end

--共鸣
function MythData:GetMythGongMingRemind()
	if OpenFunData.Instance:CheckIsHide("mythview_myth_gongming") == false then
		return 0
	end

	local cfg = self.resonance_list_cfg or {}
	local max_num = #cfg
	for i = 1, max_num do
		if self:GetGongMingItemRedPoint(i) then
			return 1
		end
	end
	return 0
end

--神魂
function MythData:GetMythShenHunRemind()
	if OpenFunData.Instance:CheckIsHide("mythview_myth_gongming") == false then
		return 0
	end
	-- self.shenhun_flag = 0
	if self.selecttab ~= LINGWU_TOGGLE then
		for i=1,MYTH_TYPE.MAX_MYTH_CHAPTER_ID do
	 		for j=1,MYTH_TYPE.MAX_MYTH_SOUL_SLOT do
				local inlay_demand_cfg = self:GetInlayDemand(i)
				local cur_writing_level = self:GetChpaterList()
				self.shenhun_flag = self:GetShenHunRemidFlage(i,j)
				if self.shenhun_flag > 0 and cur_writing_level[i].level >= inlay_demand_cfg[j].grid_level then
					return self.shenhun_flag
				end
				self.shenhun_flag = 0
			end
		end
	end
	return self.shenhun_flag
end

--领悟
function MythData:GetMythLingWuRemind()
	if OpenFunData.Instance:CheckIsHide("mythview_myth_lingwu") == false then
		return 0
	end
	local flag = 0
	local is_jihuo = false
	for i=1,8 do
		is_jihuo = false
		is_jihuo = self:GetPianZhanActivite(i)
		flag = self:GetLingWuRedPointFlag(i)
		if flag == 1 and is_jihuo then
			return 1
		end
		flag = 0
	end
	return flag
end

--萃取
-- function MythData:GetMythCuiQuRemind()
-- 	return 0
-- end

--合成
function MythData:GetMythComposeRemind()
	if OpenFunData.Instance:CheckIsHide("mythview_myth_compose") == false then
		return 0
	end
	local flag = 0
	local list = self:GetMythComposeTypeOfCount()

	for k,v in pairs(list) do
		for k1,v1 in pairs(v) do
			flag = flag + self:GetMythcomposeRedCount(v1)
		end
	end
	return flag
end
