# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

App.spreadsheet =
	active_users: {}

	new_user: (user) ->
		@active_users[user.id] = user
		@render_active_users()

	remove_user: (user) ->
		delete @active_users[user.id]
		@render_active_users()

	render_active_users: () ->
		$('#active_users_list').html(
			("<li>#{user.id}</li>" for id,user of @active_users).join("")
		)

