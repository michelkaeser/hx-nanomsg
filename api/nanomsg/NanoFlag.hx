package nanomsg;

/**
 *
 */
@:enum
abstract NanoFlag(Int) from Int to Int
{
    var NONE     = 0;
    var DONTWAIT = 1;
}
