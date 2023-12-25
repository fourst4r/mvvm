package mvvm;

#if haxeui_core
abstract ObservableArray<T>(ObservableArrayImpl<T>) {
    
}

class ObservableArrayImpl<T> 
    extends haxe.ui.data.ArrayDataSource<Dynamic> 
    implements IObservableCollection<T>
{
    public var collectionChanged:Signal<Change<T>>;

    public function new() {
        super();
    }

    
}
#else
abstract ObservableArray<T>(Array<T>) {
    public function new(items) {
        this = items;
    }
    public function add(el:T):Void {}
    public function remove():Void {}
    public function replace():Void {}
    public function reset():Void {}
    public function move():Void {}
}
#end