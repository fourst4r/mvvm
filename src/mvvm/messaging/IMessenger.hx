package mvvm.messaging;

interface IMessenger
{
    function registerClass<TMessage>(recipient:IRecipient<TMessage>, ?token:Any, messageType:Class<TMessage> = null):Void;
    function registerEnum<TMessage>(recipient:IRecipient<TMessage>, ?token:Any, messageType:Enum<TMessage> = null):Void;
    function broadcast<TMessage>(message:TMessage, ?token:Any):Void;
    function broadcastEnum<TMessage:EnumValue>(message:TMessage, ?token:Any):Void;
}