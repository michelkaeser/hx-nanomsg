package nanomsg;

import nanomsg.TransportAddress;

/**
 * TCP transport allows for passing message over the network using simple reliable one-to-one connections.
 *
 * TCP is the most widely used transport protocol, it is virtually ubiquitous and thus the transport
 * of choice for communication over the network.
 *
 * @link http://nanomsg.org/v0.4/nn_tcp.7.html
 */
class TCPAddress extends TransportAddress
{
    /**
     * Constructor to initialize a new TCPAddress instance.
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
        return "tcp://" + this.address;
    }
}
