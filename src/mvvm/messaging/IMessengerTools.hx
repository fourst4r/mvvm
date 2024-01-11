package mvvm.messaging;

class IMessengerTools
{
    public static extern inline overload function register<TMessage:Class<Dynamic>, TToken>(self:IMessenger, recipient:IRecipient<TMessage>, messageType:Class<TMessage>, ?token:TToken)
        self.registerClass(recipient, token, messageType);
    
    public static extern inline overload function register<TMessage:EnumValue, TToken>(self:IMessenger, recipient:IRecipient<TMessage>, messageType:Enum<TMessage>, ?token:TToken)
        self.registerEnum(recipient, token, messageType);
}


