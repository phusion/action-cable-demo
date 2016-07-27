# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ActiveUsersChannel < ApplicationCable::Channel
  include NoBrainer::Streams

  def subscribed
    @user = User.create
    stream_from User.all, include_initial: true
  end

  def unsubscribed
    @user.destroy
  end
end
