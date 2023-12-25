package mvvm;

enum Change<T> {
    Add(el:T);
    // Move;
    Remove(el:T, i:Int);
    Replace(old:T, new_:T, i:Int);
    Reset;
}

interface IObservableCollection<T> {
    final collectionChanged:Signal<Change<T>>;
}