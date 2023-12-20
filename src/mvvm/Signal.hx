package mvvm;

abstract Signal<T>(Array<T->Void>) {
    public function new() {
        this = [];
    }

    public function connect(callback:T->Void):Void {
        if (!this.contains(callback))
            this.push(callback);
    }

    public function disconnect(callback:T->Void) {
        this.remove(callback);
    }

    public function emit(param:T):Void {
        for (callback in this)
            callback(param);
    }
}