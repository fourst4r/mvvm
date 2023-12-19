package mvvm;

interface ICommand {
    function canExecute(parameter:Any):Bool;
    function execute(parameter:Any):Void;
}