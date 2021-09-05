TipsGongGaoView = TipsGongGaoView or BaseClass(BaseView)
local MAX_PAGE_COUNT = 10
function  TipsGongGaoView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/gonggaoview_prefab", "GongGaoView"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
	self.play_audio = true
end

function TipsGongGaoView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["TitleText"].text.text = Language.Title.GongGao

	self.cell_list = {}
	local list_delegate = self.node_list["Listview"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsGongGaoView:ShowIndexCallBack()
	self:Flush()
end

function TipsGongGaoView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TipsGongGaoView:CloseWindow()
	local des = Language.Common.Gonggao
	function ok_callback()
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GongGao, false)
	 	self:Close()
	end
	function cancel_callback()
	 	self:Close()
	end
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, cancel_callback)
end

function TipsGongGaoView:FlushGongGao()
	if self.node_list and self.node_list["Listview"] and self.node_list["Listview"].scroller and self.node_list["Listview"].scroller.isActiveAndEnabled then
		self.node_list["Listview"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TipsGongGaoView:GetNumberOfCells()
	return TipsData.Instance:GetGongGaoDataNum()
end

function TipsGongGaoView:RefreshCell(cell, cell_index)
	local gonggao_data = TipsData.Instance:GetGongGaoData()
	if nil == gonggao_data then
		return
	end

	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = GongGaoItem.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	item_cell:SetData(gonggao_data[cell_index + 1])
	item_cell:Flush()
end

function TipsGongGaoView:OnFlush()
	local page = TipsData.Instance:GetGongGaoDataNum()
	for i = 1, MAX_PAGE_COUNT do
		self.node_list["PageToggle" .. i]:SetActive(i <= page)
	end
	self.node_list["Listview"].list_page_scroll:SetPageCount(page)
	self:FlushGongGao()
end


--------------------- item --------------------

GongGaoItem = GongGaoItem or BaseClass(BaseCell)

function GongGaoItem:__init()
	self.node_list["RawImg"]:SetActive(false)
end

function GongGaoItem:__delete()

end

function GongGaoItem:SetData(data)
	self.data = data
	if self.data and self.data.content and self.data.content ~= "" then
		self.node_list["Text"]:SetActive(true)
		RichTextUtil.ParseRichText(self.node_list["Text"].rich_text, CommonDataManager.ParseTagContent(self.data.content))
	else
		self.node_list["Text"]:SetActive(false)
	end
end

function GongGaoItem:OnFlush()
	self.node_list["RawImg"]:SetActive(false)
	if self.data and self.data.img_url and type(self.data.img_url) == "table" then
		local url = self.data.img_url.url
		local path = ResPath.GetFilePath2(self.data.img_url.name)
		local load_callback = function ()
		if nil == self.node_list or nil == self.node_list["RawImg"] or IsNil(self.node_list["RawImg"].gameObject) then
				return
			end
			local avatar_path = path
			self.node_list["RawImg"].raw_image:LoadSprite(avatar_path,
			function()
				self.node_list["RawImg"]:SetActive(true)
			end)
		end
		HttpClient:Download(url, path, load_callback)
	end
end