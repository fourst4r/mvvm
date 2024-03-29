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
        // TODO: probably best to only add the accessors that don't already exist
        fields = fields.concat(accessors);
    }

    if (!fields.exists(f -> f.name == "propertyChanged")) {
        fields = fields.concat((macro class Dummy {
            public final propertyChanged:Signal<String> = new Signal();
        }).fields);
    }

    return fields;
}

function makeAccessors(field:Field):Array<Field> {
    final setter = 'set_${field.name}';
    final fieldType = switch (field.kind) {
        case FVar(t, e): t;
        default: throw "unsupported observable var";
    }
    field.kind = FProp("default", "set", fieldType);
    final acc = macro class Dummy {
        function $setter(v) {
            if ($i{field.name} != v) {
                $i{field.name} = v;
                propertyChanged.emit($v{field.name});
            }
            return v;
        }
    };
    return acc.fields;

}
#end


@:autoBuild(mvvm.IObservable.build())
interface IObservable {
    final propertyChanged:Signal<String>;
}