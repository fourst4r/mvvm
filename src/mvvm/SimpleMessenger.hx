package mvvm;

import mvvm.messaging.IRecipient;
import mvvm.messaging.IMessenger;

private class Unit { public function new() {} }
private final unit = new Unit();

private typedef Token = Any;
private typedef Message = Any;
private typedef ClassMessage = Any;

final class SimpleMessenger implements IMessenger
{
    var _types:Map<ClassMessage, Map<Token, Array<IRecipient<Message>>>>;
    var _enums:Map<ClassMessage, Map<Token, Array<IRecipient<Message>>>>;

    public function new()
    {
        _types = new Map();
        _enums = new Map();
    }

    public function registerClass<TMessage>(recipient:IRecipient<TMessage>, ?token:Any, messageType:Class<TMessage> = null)
    {
        token ??= unit;

        var tokenMap = _types.get(messageType);
        if (tokenMap == null)
        {
            tokenMap = [];
            _types.set(messageType, tokenMap);
            trace('registered msg=$messageType tkn=$token');
        }
        var recips = tokenMap.get(token);
        if (recips == null)
        {
            recips = [];
            tokenMap.set(token, recips);
            trace('registered recip=$recipient tkn=$token');
        }
        recips.push(recipient);
    }

    public function registerEnum<TMessage>(recipient:IRecipient<TMessage>, ?token:Any, messageType:Enum<TMessage> = null)
    {
        token ??= unit;

        var tokenMap = _enums.get(messageType);
        if (tokenMap == null)
        {
            tokenMap = [];
            _enums.set(messageType, tokenMap);
            trace('registered msg=$messageType tkn=$token');
        }
        var recips = tokenMap.get(token);
        if (recips == null)
        {
            recips = [];
            tokenMap.set(token, recips);
            trace('registered recip=$recipient tkn=$token');
        }
        recips.push(recipient);
    }

    public inline function broadcast<TMessage>(message:TMessage, ?token:Any)
    {
        token ??= unit;
        final tokenMap = _types.get(Type.getClass(message)) ?? throw "no type registered for "+Type.getClassName(Type.getClass(message));
        final recips = tokenMap.get(cast token ?? cast unit) ?? throw "no token registered for "+token;
        for (recip in recips)
            recip.receive(message);
    }
    
    public inline function broadcastEnum<TMessage:EnumValue>(message:TMessage, ?token:Any)
    {
        token ??= unit;
        final tokenMap = _enums.get(Type.getEnum(message)) ?? throw "no type registered for "+Type.getEnumName(Type.getEnum(message));
        final recips = tokenMap.get(cast token ?? cast unit) ?? throw "no token registered for "+token;
        for (recip in recips)
            recip.receive(message);
    }
}