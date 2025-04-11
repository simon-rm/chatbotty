class StoreMessage
  include Interactor
  def call
    find_or_create_user
    create_message
  end

  private

  def find_or_create_user
    attrs = context.user_attributes
    identifier = [attrs.slice(:id, :session_id, :phone_number).first].to_h
    context.fail!(error: "No user identifier provided") if identifier.blank?
    user = User.find_or_create_by identifier
    context.fail!(error: user.errors.full_messages) unless user.update attrs
    context.user = user
  end

  def create_message
    message = Message.new(user: context.user, **context.message_attributes)
    context.fail!(error: message.errors.full_messages) unless message.save
    context.message = message
  end
end