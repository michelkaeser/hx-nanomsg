package nanomsg;

import nanomsg.TransportAddress;

/**
 * TODO
 */
class WebSocketAddress extends TransportAddress
{
    /**
     * Constructor to initialize a new WebSocketAddress instance.
     *
     * @param String address the address to use
     */
    public function new(address:String):Void
    {
        super(address);
    }

    /**
     * @{inherit}
     */
    override public inline function toString():String
    {
        return "ws://" + this.address;
    }
}
