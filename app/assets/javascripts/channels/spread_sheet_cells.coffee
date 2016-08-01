App.spread_sheet_cells = App.cable.subscriptions.create "SpreadSheetCellsChannel",
  received: (data) ->
    App.spreadsheet.update_cell(data.new_val)

  set_cell_value: (location, value) ->
    @perform('set_cell_value', location: location, value: value)
