package mvvm;

import haxe.macro.Context;
import haxe.macro.Expr;
using Lambda;

#if macro
function build() {
    var fields = Context.getBuildFields();

    final observableFields = fields.filter(f -> f.meta.exists(f -> f.name == Meta.Observable));

    for (f in observableFields) {
        final accessors = makeAccessors(f);
        fields = fields.concat(accessors);
    }

    fields = fields.concat((macro class Dummy {
        var __listeners:Map<String, Array<Void->Void>> = [];

        public function addListener(name:String, callback:Void->Void):Void {
            var arr = __listeners.get(name);
            if (arr == null) 
                __listeners.set(name, arr = []);
            arr.push(callback);
        }
    
        public function removeListener(name:String, callback:Void->Void) {
            __listeners.get(name)?.remove(callback);
        }
    
        public function onPropertyChanged(name:String):Void {
            final callbacks = __listeners.get(name);
            if (callbacks != null) 
                for (cb in callbacks)
                    cb();
        }
    }).fields);

    return fields;

}

function makeAccessors(field:Field):Array<Field> {
  
    // final getter = 'get_${field.name}';
    final setter = 'set_${field.name}';
    final fieldType = switch (field.kind) {
        case FVar(t, e): t;
        default: throw "unsupported observable var";
    }
    field.kind = FProp("default", "set", fieldType);
    // field.meta.push({name:":isVar", pos: Context.currentPos()});
    final acc = macro class Dummy {
        // function $getter() {
        //     return $i{field.name};
        // }

        function $setter(v) {
            if ($i{field.name} != v) {
                $i{field.name} = v;
                onPropertyChanged($v{field.name});
            }
            return v;
        }
    };
    return acc.fields;

}
#end


@:autoBuild(mvvm.IObservable.build())
interface IObservable {
    function addListener(name:String, callback:Void->Void):Void;
    function removeListener(name:String, callback:Void->Void):Void;
    function onPropertyChanged(name:String):Void;
}