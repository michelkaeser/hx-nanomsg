package nanomsg;

import nanomsg.TransportAddress;

/**
 * Inter-process transport allows for sending messages between processes within a single box.
 *
 * The implementation uses native IPC mechanism provided by the local operating system and
 * the IPC addresses are thus OS-specific.
 *
 * @link http://nanomsg.org/v0.4/nn_ipc.7.html
 */
class IPCAddress extends TransportAddress
{
    /**
     * Constructor to initialize a new IPCAddress instance.
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
        return "ipc://" + this.address;
    }
}
