App.active_users = App.cable.subscriptions.create "ActiveUsersChannel",
  received: (data) ->
    if data.old_val && !data.new_val
      App.spreadsheet.remove_user(data.old_val)
    else if data.new_val
      App.spreadsheet.new_user(data.new_val)

