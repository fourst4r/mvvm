package mvvm;

import mvvm.IObservableCollection;

#if haxeui_core
abstract ObservableArray<T>(ObservableDataSource<T>) 
    to IObservableCollection<T> 
    to ObservableDataSource<T>
{
    public function new(?items) {
        this = new ObservableDataSource();
        if (items != null)
            @:privateAccess this._array = items;
    }

    public function add(el:T):Int {
        return this.add(el);
    }

    public function remove(el:T):T {
        return this.remove(el);
    }
}

class ObservableDataSource<T> 
    extends haxe.ui.data.ArrayDataSource<T> 
    implements IObservableCollection<T>
{
    public final collectionChanged:Signal<Change<T>> = new Signal();

    public function new(transformer:haxe.ui.data.transformation.IItemTransformer<T> = null) {
        super(transformer);
    }

    override function handleAddItem(item:T):Int {
        final i = super.handleAddItem(item);
        collectionChanged.emit(Add(item));
        return i;
    }

    override function handleClear() {
        super.handleClear();
        collectionChanged.emit(Reset);
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