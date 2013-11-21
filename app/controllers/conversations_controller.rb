class ConversationsController < ApplicationController
  before_filter :signed_in_user
  helper_method :mailbox, :conversation
  respond_to :html, :js

  def new
    if params[:recipient_id]
      @recipient = User.find_by_id(params[:recipient_id])
    end
    if params[:request_delivery_id]
      @request_delivery = RequestDelivery.find_by_id(params[:request_delivery_id])
    end
    render "new.html.erb"
  end

  def create
    recipient_emails = conversation_params(:recipients).split(',')
    recipients = User.where(email: recipient_emails).all
    @conversation = current_user.send_message(recipients, *conversation_params(:body, :subject))
    if @conversation.errors.blank?
      flash[:success] = "Great!<br><div class='sub_flash_text'>You've successfully sent your message.</div>".html_safe
      respond_to do |format|
        format.html { redirect_to activity_path }
        format.js
      end
    end
  end

  def index
    @my_conversations = Receipt.where(:deleted => false).where(:trashed => false).where(:receiver_id => current_user.id)
    @trashed = Receipt.where(:deleted => false).where(:trashed => true)
  end

  def reply
    current_user.reply_to_conversation(conversation, *message_params(:body, :subject))
    redirect_to conversation
  end

  def trash
    conversation.move_to_trash(current_user)
    redirect_to :conversations
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to :conversations
  end

  private

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end

  def conversation_params(*keys)
    fetch_params(:conversation, *keys)
  end

  def message_params(*keys)
    fetch_params(:message, *keys)
  end

  def fetch_params(key, *subkeys)
    params[key].instance_eval do
      case subkeys.size
        when 0 then self
        when 1 then self[subkeys.first]
        else subkeys.map{|k| self[k] }
      end
    end
  end
end
