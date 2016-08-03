# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

App.spreadsheet =
	active_users: {}

	current_user: id: 'unknown'

	set_current_user: (user) ->
		@current_user = user

	new_user: (user) ->
		@active_users[user.id] = user
		@number_users()
		@render_active_users()
		@render_selected_cells()

	number_users: () ->
		num = 0
		for id,user of @active_users
			if id != @current_user.id
				num += 1
				user.num = num

	remove_user: (user) ->
		delete @active_users[user.id]
		@render_active_users()

	render_active_users: () ->
		$('#active_users_list').html(
			("<li class=\"user-#{user.num}\">#{user.id}</li>" for id,user of @active_users).join("")
		)

	render_selected_cells: () ->
		for cells in @selected_cells
			cell = @hot.getCell(cells.r, cells.c)
			if cell.classList.contains("current")
				cell.classList = "current"
			else
				cell.classList = ""

		@selected_cells = []
		for id, user of @active_users
			if id != @current_user.id && (cells = user.selected_cells)
				@selected_cells.push(cells)
				cell = @hot.getCell(cells.r, cells.c)
				cell.classList.add('user-' + user.num)

	setup: () ->
		@selected_cells = []
		@cell_lock_callback = {}
		container = document.getElementById('spreadsheet')
		@hot = new Handsontable(container,
			minSpareCols: 1
			minSpareRows: 1
			rowHeaders: true
			colHeaders: true
			contextMenu: true
			afterSelection: () => @select_cells(arguments)
			afterDeselect: () => @deselect_cells()
			afterChange: (changes, source) =>
				if source != 'remote' && changes
					for change in changes
						App.spread_sheet_cells.set_cell_value(
							{ r: change[0], c: change[1] },
							change[3]
						)
			afterRenderer: () => @render_selected_cells()
		)

		@hot.acquireEditLock = (editor, callback) =>
			location = {r: editor.row, c: editor.col}
			@cell_lock_callback[location] = callback
			App.active_users.lock_cell(location)

		@hot.releaseEditLock = (editor, callback) =>
			location = {r: editor.row, c: editor.col}
			App.active_users.unlock_cell(location)
			callback()

	select_cells: (cells) ->
		App.active_users.select_cells(r: cells[0], c: cells[1], r2: cells[2], c2: cells[3])

	deselect_cells: () -> App.active_users.select_cells(null)

	update_cell: (update) ->
		location = r: update.location[0], c: update.location[1]
		value = update.value
		@hot.setDataAtCell(location.r, location.c, value, 'remote')

		if update.lock == @current_user.id
			@cell_lock_callback[location]?()
			delete @cell_lock_callback[location]

# Monkey patch HandsOnTable BaseEditor for communicating editor locks
MultiEditorPatch =
	inject: ->
		baseProto = Handsontable.editors.BaseEditor.prototype
		baseProto.beginEditing = @beginEditing(baseProto.beginEditing)
		baseProto.finishEditing = @finishEditing(baseProto.finishEditing)

	beginEditing: (original) -> (initialValue, event) ->
		if @instance.acquireEditLock
			@instance.acquireEditLock(@, => original.apply(@, [initialValue, event]))
		else
			original.apply(@, arguments)

	finishEditing: (original) -> (restoreOriginalValue, ctrlDown, callback) ->
		if @instance.releaseEditLock && @state == 'STATE_EDITING'
			@instance.releaseEditLock(@, => original.apply(@, [restoreOriginalValue, ctrlDown, callback]))
		else
			original.apply(@, arguments)

MultiEditorPatch.inject()

$ -> App.spreadsheet.setup()
