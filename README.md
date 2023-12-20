# Binding
| BindingMode | source __ target
| - | - 
| OneTime | `a.foo >> b.foo`
| OneWay | `a.foo => b.foo`
| OneWayToSource | `a.foo <= b.foo`
| TwoWay | `a.foo == b.foo`

# Converters
```haxe
@:transitive abstract Currency(Float) from Float {
    @:to function toString():String {
        return "$" + Std.string(this) + ".00";
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    var vm:MainViewModel;

    public function new() {
        super();

        vm = new MainViewModel();
        bind((vm.price:Currency) => button1.text);
    }
}
```

# How it works
```haxe
bind(a.foo => b.foo)
// the above is equivalent to bindTo(a.foo, b.foo, OneWay);
```
Transforms into
```haxe
a.addObserver("foo", () -> {
    if (a.foo != b.foo) {
        b.foo = a.foo;
    }
});
```
