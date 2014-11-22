#ifndef __NANOMSG_HX_HPP
#define __NANOMSG_HX_HPP

#ifdef __cplusplus
extern "C" {
#endif

#define alloc_socket(v)      alloc_int(v)
#define throw_errno()        val_throw(nn_strerror(nn_errno()))
#define throw_errstr()       val_throw(alloc_string(nn_strerror(nn_errno())))
#define val_check_socket(v)  val_check(v, int)
#define val_is_socket(v)     val_is_int(v)
#define val_socket(v)        val_int(v)


/*
 * Binds the socket to the given address.
 *
 * Depending on the procotol, binded sockets have other possibilities than connected ones.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_bind.3.html
 *
 * Example:
 *   value bindId = hx_nn_bind(alloc_socket(0), alloc_string("tcp://server001:5560"));
 *
 * Parameters:
 *   value[Int]    sock    the socket on which the action should be performed
 *   value[String] address the address to bind to
 *
 * Returns:
 *   value[int] the connection ID.
 *     If an error encounters, the error code is returned (and a Neko error is raised).
 */
value hx_nn_bind(value sock, value address);


/*
 * Closes the socket and all its open connections.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_close.3.html
 *
 * Example:
 *   hx_nn_close(alloc_socket(0));
 *
 * Parameters:
 *   value[Int]    sock    the socket to close
 *
 * Returns:
 *   value[int] 0 on success, -1 on error (and a Neko error is raised).
 */
value hx_nn_close(value sock);


/*
 * Connects the socket to the provided address.
 *
 * A socket can connect to multiple addresses at the same time.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_connect.3.html
 *
 * Example:
 *   value connectionId = hx_nn_connect(alloc_socket(0), alloc_string("tcp://server001:5560"));
 *
 * Parameters:
 *   value[Int]    sock    the socket on which the action should be performed
 *   value[String] address the address to connect to
 *
 * Returns:
 *   value[int] the connection ID.
 *     If an error encounters, the error code is returned (and a Neko error is raised).
 */
value hx_nn_connect(value sock, value address);


/*
 * Starts a device to forward messages between two sockets.
 *
 * To break the loop and make hxnn_device function exit use hxnnnn_term function.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_device.3.html
 *
 * Example:
 *   hx_nn_device(alloc_socket(0), alloc_socket(1));
 *
 * Parameters:
 *   value[Int] sock1 the primary socket to pair with the device
 *   value[Int] sock2 the 2nd socket to pair under the device
 *
 * Returns:
 *   value[int] the function loops until it hits an error.
 *     In such case it returns -1 (and a Neko error is raised).
 */
value hx_nn_device(value sock1, value sock2);


/*
 * Retreives the option value of option 'option'.
 *
 * TODO:
 *   - support string options
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_getsockopt.3.html
 *
 * Example:
 *   value optval = hx_nn_getsockopt(alloc_socket(0), alloc_int(NN_SOL_SOCKET), alloc_int(NN_LINGER));
 *
 * Parameters:
 *   value[Int] sock   the socket for which the option should be retreived
 *   value[Int] level  the level on which the option lives
 *   value[Int] option the code of the option to get
 *
 * Returns:
 *   value[int] the option's value
 *   or the error code (and a Neko error is raised).
 */
value hx_nn_getsockopt(value sock, value level, value option);


/*
 * Polls the sockets passed by the different arguments for either
 * read or write capability.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_poll.3.html
 *
 * Example:
 *   value ready = hx_nn_poll(..., ..., ...);
 *   if (val_array_size(val_array_value(ready)[0] > 0)) {
 *       // can read
 *   }
 *
 * Parameters:
 *   value[Array<Int>] reads   the sockets to poll for read capability
 *   value[Array<Int>] writes  the sockets to poll for write capability
 *   value[Array<Int>] boths   the sockets to poll for read OR write capability
 *   value[int]        timeout the timeout before polling gives up even if no socket is ready
 *
 * Returns:
 *   value[Array<Array<Int>>] Array holding the ready sockets ([0] = read, [1] = write)
 *   or [null] if no sockets are ready (timed-out),
 *   or the error code [Int] (and a Neko error is raised).
 */
value hx_nn_poll(value reads, value writes, value boths, value timeout);


/*
 * Reads up to 'nbytes' bytes from the socket.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_recv.3.html
 *
 * Example:
 *   value bytes = hx_nn_recv(alloc_socket(0), alloc_int(5), alloc_int(0));
 *
 * Parameters:
 *   value[Int] sock   the socket to read from
 *   value[Int] nbytes the  number of bytes to read
 *   value[Int] flags  optional read-flags (such as NN_DONTWAIT)
 *
 * Returns:
 *   value[haxe.io.BytesData] the read bytes
 *   or the error code [Int] (and a Neko error is raised).
 */
value hx_nn_recv(value sock, value nbytes, value flags);


/*
 * Reads all available bytes from the socket.
 *
 * If nothing is available, the call blocks the calling thread.
 * This can be omited by passing NN_DONTWAIT flag.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_recv.3.html
 *
 * Example:
 *   value bytes = hx_nn_recv_all(alloc_socket(0), alloc_int(NN_DONTWAIT));
 *
 * Parameters:
 *   value[Int] sock  the socket to read from
 *   value[Int] flags optional read-flags (such as NN_DONTWAIT)
 *
 * Returns:
 *   value[haxe.io.BytesData] the read bytes
 *   or the error code [Int] (and a Neko error is raised).
 */
value hx_nn_recv_all(value sock, value flags);


/*
 * Sends the bytes over the socket connection.
 *
 * Additional flags such as NN_DONTWAIT may be passed to control sending behavior.
 *
 * See:
 *  http://nanomsg.org/v0.4/nn_send.3.html
 *
 * Example:
 *  value nsentBytes = hx_nn_send(alloc_socket(0), buffer_val(buf), buffer_size(buf), alloc_int(NN_DONTWAIT));
 *
 * Parameters:
 *   value[Int]               sock   the socket to write to
 *   value[haxe.io.BytesData] bytes  the bytes to write
 *   value[Int]               length the number of bytes to send
 *   value[Int]               flags  optional control flags
 *
 * Returns:
 *   value[Int] the number of written bytes
 *   or the error code (and a Neko error is raised).
 */
value hx_nn_send(value sock, value bytes, value length, value flags);


/*
 * Sets the socket's option 'option' to value 'optval'.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_setsockopt.3.html
 *
 * Example:
 *   hx_nn_setsockopt(alloc_socket(0), alloc_int(NN_SOL_SOCKET), alloc_int(NN_LINGER), alloc_int(0));
 *
 * Parameters:
 *   value[Int]        sock   the socket to set the option on
 *   value[Int]        level  the level on which the option should be set
 *   value[Int]        option the option's code
 *   value[Int|String] optval the value to set
 *
 * Returns:
 *   value[Int] the return code which is 0 is everything went well.
 *     If an error encountered, a Neko error is raised.
 */
value hx_nn_setsockopt(value sock, value level, value option, value optval);


/*
 * Closes the open connection defined by 'address' on the socket.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_shutdown.3.html
 *
 * Example:
 *   value con  = hx_nn_connect(alloc_socket(0), alloc_string("tcp://server001:5560"));
 *   hx_nn_shutdown(sock, con);
 *
 * Parameters:
 *   value[Int] sock       the socket on which the connection should be closed
 *   value[Int] connection the connection ID
 *
 * Returns:
 *   value[Int] the return code which is 0 is everything went well.
 *     If an error encountered, a Neko error is raised.
 */
value hx_nn_shutdown(value sock, value connection);


/*
 * Creates a new nanomsg socket. The protocol defines
 * what kind of communication is allowed/supported, e.g. NN_BUS.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_socket.3.html
 *
 * Example:
 *   value sock = hx_nn_socket(alloc_int(AF_SP), alloc_int(NN_BUS));
 *   hx_nn_shutdown(sock, con);
 *
 * Parameters:
 *   value[Int] domain   domain to use
 *   value[Int] procotol protocol to use
 *
 * Returns:
 *   value[Int] the socket identifier or -1 if an error encountered (and a Neko error is raised).
 */
value hx_nn_socket(value domain, value protocol);


/*
 * Signalizes that the library will terminate.
 *
 * This should be called at the very end of your application
 * so nanomsg can do the cleanup.
 *
 * See:
 *   http://nanomsg.org/v0.4/nn_term.3.html
 *
 * Example:
 *   hx_nn_term();
 *
 * Returns:
 *   value[null] nothing is returned
 */
value hx_nn_term(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* __NANOMSG_HX_HPP */
