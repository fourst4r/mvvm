package mvvm.messaging;

interface IRecipient<TMessage>
{
    function receive(message:TMessage):Void;
}