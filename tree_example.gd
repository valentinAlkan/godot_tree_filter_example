extends Node

export var root_node_text = 'Resources'
export var choices = ['gold', 'steel', 'iron', 'platinum', 'whatever']	#an array of choices currently available on the market (strings)
export var spacing = 10 	 #vertical spacing in pixels
var selectedItems = []
var DEFAULT_SEARCH_TEXT = 'Search'

#nodes
var itemTree =  null
var searchbox = null
var btnClear = null
var btnSelAll = null
var btnSelNone = null
var detailPanel = null
var details = null #list of detail names (names match with choices)

func _ready():
	itemTree = get_node("Panel").get_node("HSplitContainer/VBoxContainer/ItemList")
	searchbox = get_node("Panel").get_node("HSplitContainer/VBoxContainer/HBoxContainer/LineEdit")
	btnClear = get_node("Panel").get_node("HSplitContainer/VBoxContainer/HBoxContainer/btnClear")
	btnSelAll = get_node("Panel").get_node("HSplitContainer/VBoxContainer/HBoxContainer 2/btnSelAll")
	btnSelNone = get_node("Panel").get_node("HSplitContainer/VBoxContainer/HBoxContainer 2/btnSelNone")
	detailPanel = get_node("Panel").get_node("HSplitContainer/ItemDetail")
	
	#connect signals
	itemTree.connect("cell_selected", self, '_on_ItemList_cell_selected')
	searchbox.connect("input_event", self, '_on_LineEdit_input_event')
	btnClear.connect("pressed", self, '_on_btnClear_pressed')
	btnSelAll.connect("pressed", self, '_on_btnSelAll_pressed')
	btnSelNone.connect("pressed", self, '_on_btnSelNone_pressed')
	#detailPanel.connect("pressed", self, '')
	
	searchbox.set_text(DEFAULT_SEARCH_TEXT)
	
	#add each resource to the tree
	_populateItemList(choices)
	
	
	

func _populateItemList(itemList, saveChoices = true, selectThese = []):
	#save the selected items, if any
	var root = itemTree.get_root()
	if saveChoices:
	#normally we will be saving our choices
		if root:
			var item = root.get_children()
			while (item):
				#if an item is checked, add it to the checked items
				var itemtext = item.get_text(0)
				if item.is_checked(0):
					#don't add duplicates
					if not itemtext in selectedItems:
						selectedItems.append(itemtext)
				else:
					#if an item is unchecked, attempt to remove it from the selected items list
					if itemtext in selectedItems:
						selectedItems.remove(itemtext)
				item = item.get_next()
		
	else:
		#however we might want to pass in a list of choices that need to only be selected
		selectedItems = selectThese
	
	#clear the tree
	itemTree.clear()

	#add the root item to the tree
	itemTree.create_item(TreeItem.new())
	#set a text value for it
	itemTree.get_root().set_text(0,root_node_text)
	
	for itemname in itemList:
		var treeitem = itemTree.create_item(itemTree.get_root())	#create a new itemlist entry
		treeitem.set_cell_mode(0,1)		#Set the items to be checkboxes
		treeitem.set_editable(0, true)	#make sure the item can be selected
		treeitem.set_text(0,itemname)	#set the text
		
		#if the item has been previously selected, set its checked state
		if itemname in selectedItems:
			treeitem.set_checked(0,true)






func _getVisibleItems():
#returns a list of treeItems that are currently visible to the user
	var visibleItems = []
	var root = itemTree.get_root()
	if root:
		var item = root.get_children()
		while (item):
			visibleItems.append(item)
			item = item.get_next()
	return visibleItems


func _getVisibleChoices():
#returns a list of the choices that are currently visible to the user
	var visibleChoices = []
	var isChecked = false
	for item in _getVisibleItems():
		visibleChoices.append(item.get_text(0))
		if item.is_checked(0):
			isChecked = true
	return [visibleChoices, isChecked]


func _searchItemList():
	#search the item list and show the relevent items
	var searchtext = searchbox.get_text()
	var validItems = []
	
	#if the search string is empty, simply populate the list as normal
	if searchtext:
		#search through our choices for strings that match our search query
		for resource in choices:
			var capitalizedName = resource.capitalize()
			if (resource.matchn('*'+searchtext+'*')):
				validItems.append(resource)
	else:
		validItems=choices
	return validItems






func _selectAll(visible = false):
	if visible:
		#if the visible flag is specified, select all visible items
		for visibleitem in _getVisibleItems():
			visibleitem.set_checked(0, true)
	else:
		_populateItemList(choices, false, choices)
	_showDetail()





func _selectNone():
	_populateItemList(choices, false)


func _showDetail():
	#show the appropriate details
	var visibleChoices = _getVisibleChoices()
	for choice in choices:
		#any visible item that is checked is added to the details list and any visible item that is unchecked gets removed
		 if choice in visibleChoices:
		    pass
			#details[choice] = Detail.new(choice)
		
#		details[choiceName] = null
#	else:
		#hide the detail
#		if details.has(choiceName):
#			details.erase(choiceName)
	





#HANDLERS==========================================================================
func _on_LineEdit_input_event(ev):
	#highlight the text of the search box upon clicking on it
	if(ev.type == InputEvent.MOUSE_BUTTON):
		if(ev.button_index == 1 and searchbox.get_text()==DEFAULT_SEARCH_TEXT):
			searchbox.select_all()
	if(ev.type == InputEvent.KEY):
		_populateItemList(_searchItemList())
		if(ev.scancode == KEY_RETURN):
			#if the return key is selected, select all visible items and then highlight the search text
			_selectAll(true)
			searchbox.select_all()

func _on_ItemList_item_edited():
	_populateItemList(_searchItemList())
	return

func _on_ItemList_cell_selected():
	var sel = itemTree.get_selected()
	if sel:
		sel.set_checked(0, not sel.is_checked(0))
		_showDetail()


func _on_btnClear_pressed():
	#clear the search text
	searchbox.clear()
	searchbox.grab_focus()
	_populateItemList(_searchItemList())
	
func _on_btnSelAll_pressed():
	_selectAll()

func _on_btnSelNone_pressed():
	_selectNone()