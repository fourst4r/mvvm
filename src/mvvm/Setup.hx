package mvvm;

import haxe.macro.Context;
import haxe.macro.Expr;

class Setup {
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
                        return macro {
                            trace("vm change (onetime) " + $v{prop});
                            $target = $source;
                        };
                    default: 
                }
            case OneWay:
                // setup the IObservable listener
                switch (source.expr) {
                    case EField(vm,prop,_) 
                       | EParenthesis(_.expr => ECheckType(_.expr => EField(vm,prop,_), _)):
                        return macro {
                            $vm.propertyChanged.connect(name -> {
                                if (name == $v{prop}) {
                                    trace("vm change (oneway) " + $v{prop});
                                    $target = $source;
                                }
                            });
                            $target = $source;
                        };
                    default:
                }
            case OneWayToSource:
                // setup the HaxeUI listener
                switch (target.expr) {
                    case EField(comp, prop, _):
                        return macro {
                            $comp.registerEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, e -> {
                                if (e.data == $v{prop}) {
                                    trace("comp change (onewaytosource) "+$v{prop});
                                    $source = $target;
                                }
                            });
                            $source = $target;
                        };
                    default:
                }
                
            case TwoWay:
                // setup both listeners
                switch ([source.expr, target.expr]) {
                    case [EField(vm, vmprop, _), EField(comp, compprop, _)]:
                        return macro {
                            $source = $target;
                            $vm.propertyChanged.connect(name -> {
                                if (name == $v{vmprop}) {
                                    trace("vm change (twoway) " + $v{vmprop});
                                    $target = $source;
                                }
                            });
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
            case _: Context.error("Unknown expression", expr.pos);
        }
    }

}