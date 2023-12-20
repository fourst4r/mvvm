package mvvm;

import haxe.macro.Context;
import haxe.macro.Expr;

class Setup {
#if macro
    static function all() {
        final cl = switch (Context.getType("haxe.ui.core.Component")) {
            case TInst(t, params): t.get();
            case _: throw "fail!";
        };
        cl.meta.add(":autoBuild", [macro @:pos(cl.pos) Setup.augment()], cl.pos);
    }

    static function augment() {
        final fields = Context.getBuildFields();
        final cl = Context.getLocalClass().get();
        if (cl.name == "Button") {
            trace("inside "+cl.name);
            trace(fields.map(f -> f.name));
        }
        return fields;
    }
#end

    
    // public static macro function bind(source:Expr, target:Expr, mode:Expr) {
    //     return macro null;
    // }

    public static macro function bindTo(source:Expr, target:Expr, mode:ExprOf<BindingMode>) {
        final mode:BindingMode = switch (mode) {
            case macro BindingMode.OneTime: OneTime;
            case macro BindingMode.OneWay: OneWay;
            case macro BindingMode.OneWayToSource: OneWayToSource;
            case macro BindingMode.TwoWay: TwoWay;
            default: Context.error("Invalid BindingMode", mode.pos);
        }
        return bindInternal(source, target, mode);
    }

    #if macro
    static function bindInternal(source:Expr, target:Expr, mode:BindingMode) {
        switch (mode) {
            case OneTime:
                // setup the IObservable listener
                switch (source.expr) {
                    case EField(vm, prop, _)
                       | EParenthesis(_.expr => ECheckType(_.expr => EField(vm,prop,_), _)):
                        return macro @:observer {
                            var cb:String->Void = null;
                            cb = name -> {
                                if (name == $v{prop}) {
                                    trace("vm change (onetime) " + $v{prop});
                                    $target = $source;
                                    $vm.propertyChanged.disconnect(cb);
                                }
                            };
                            $vm.propertyChanged.connect(cb);
                        };
                        // return macro @:observer {
                        //     var cb:()->Void = null;
                        //     cb = () -> {
                        //         trace("vm change (onetime) " + $v{prop});
                        //         $target = $source;
                        //         $vm.removeListener($v{prop}, cb);
                        //     };
                        //     $vm.addListener($v{prop}, cb);
                        // };
                    default: 
                }
            case OneWay:
                // setup the IObservable listener
                switch (source.expr) {
                    case EField(vm,prop,_) 
                       | EParenthesis(_.expr => ECheckType(_.expr => EField(vm,prop,_), _)):
                        return macro @:observer {
                            $vm.propertyChanged.connect(name -> {
                                if (name == $v{prop}) {
                                    trace("vm change (oneway) " + $v{prop});
                                    $target = $source;
                                }
                            });
                        };
                    default:
                }
                // switch (source.expr) {
                //     case EField(vm,prop,_) 
                //        | EParenthesis(_.expr => ECheckType(_.expr => EField(vm,prop,_), _)):
                //         return macro @:observer {
                //             $vm.addListener($v{prop}, () -> {
                //                 trace("vm change (oneway) " + $v{prop});
                //                 $target = $source;
                //             });
                //         };
                //     default:
                // }
                
            case OneWayToSource:
                // setup the HaxeUI listener
                switch (target.expr) {
                    case EField(comp, prop, _):
                        return macro @:observer {
                            $comp.registerEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, e -> {
                                if (e.data == $v{prop}) {
                                    trace("comp change (onewaytosource) "+$v{prop});
                                    $source = $target;
                                }
                            });
                        };
                    default:
                }
                
            case TwoWay:
                // setup both listeners
                switch ([source.expr, target.expr]) {
                    case [EField(vm, vmprop, _), EField(comp, compprop, _)]:
                        return macro @:observer {
                            $vm.propertyChanged.connect(name -> {
                                if (name == $v{vmprop}) {
                                    trace("vm change (twoway) " + $v{vmprop});
                                    $target = $source;
                                }
                            });
                            // $vm.addListener($v{vmprop}, () -> {
                            //     trace("vm change (twoway) " + $v{vmprop});
                            //     $target = $source;
                            // });
                            $comp.registerEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, e -> {
                                if (e.data == $v{compprop}) {
                                    trace("comp change (twoway) "+$v{compprop});
                                    $source = $target;
                                }
                            });
                        };
                    default:
                }
                
        }
        
        Context.error("Failed to parse binding", Context.currentPos());
        return macro null;
    }
    #end

    public static macro function bind(expr:Expr) {
        trace(expr);
        return switch (expr.expr) {
            case EBinop(OpShr, source, target): bindInternal(source, target, OneTime);
            case EBinop(OpArrow, source, target): bindInternal(source, target, OneWay);
            case EBinop(OpLte, source, target): bindInternal(source, target, OneWayToSource);
            case EBinop(OpEq, source, target): bindInternal(source, target, TwoWay);
            // case EParenthesis(e): bind(expr);
            // case ECheckType(e, t): macro trace("i am a fucking god");
            case _: Context.error("Unknown expression", expr.pos);
        }
    }

}