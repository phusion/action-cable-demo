# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ActiveUsersChannel < ApplicationCable::Channel
  include NoBrainer::Streams

  def subscribed
    @user = User.create
    transmit current_user: @user
    stream_from User.all, include_initial: true
  end

  def unsubscribed
    @user.destroy
  end

  def select_cells(message)
    @user.update! selected_cells: message['selected_cells']
  end

  def lock_cell(message)
    location = [message['location']['r'],message['location']['c']]
    result = @user.lock_cell(location)
    if result["inserted"] == 1
      Rails.logger.info "Lock acquired by #{@user.id} on #{location}"
    elsif result["unchanged"] = 1
      Rails.logger.info "Lock refused to #{@user.id} on #{location}"
    else
      Rails.logger.info "Unknown result for lock: #{result.inspect}"
    end
  end

  def unlock_cell(message)
    @user.unlock_cell
  end
end
