package mvvm;

class ObservableArray<T> 
#if haxeui_core
    extends haxe.ui.data.DataSource<Dynamic>
#end
{
    var _arr:Array<T>;

    public function new(?arr) {
        _arr = arr ?? [];
    }

    
}