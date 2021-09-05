GuildPreView = GuildPreView or BaseClass(BaseView)

function GuildPreView:__init()
	self.ui_config = {
		{"uis/views/guildview_prefab", "GuildPreView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

-- 打开操作面板
function GuildPreView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self:InitPreview()
end

function GuildPreView:ReleaseCallBack()
for k,v in pairs(self.preview_cell) do
	if v.cell then
		v.cell:DeleteMe()
	end
end
self.preview_cell = {}
end

---------------------------------------------------顶级预览---------------------------------------------------------------

function GuildPreView:InitPreview()

	local name_table = self.node_list["Preview"]:GetComponent(typeof(UINameTable))
	self.preview_cell = {}
	for i = 1, 4 do
		self.preview_cell[i] = {}
		self.preview_cell[i].obj = U3DObject(name_table:Find("ItemCell" .. i))
		self.preview_cell[i].cell = ItemCell.New()
		self.preview_cell[i].cell:SetInstanceParent(self.preview_cell[i].obj)
	end

	self:FlushPreview()
end

function GuildPreView:FlushPreview()
	local config = GuildData.Instance:GetBoxConfig()[4]
	if config then
		local item_id = config.assist_reward.item_id
		local num = config.assist_reward.num
		self.preview_cell[4].cell:SetData({item_id = item_id, num = num})

		self.preview_cell[1].obj:SetActive(true)
		item_id = config.show.item_id
		num = config.show.num
		self.preview_cell[1].cell:SetData({item_id = item_id, num = num})
	end
end