#define  IMPLEMENT_API
#define  NEKO_COMPATIBLE
#include <hx/CFFI.h>

#include <nanomsg/nn.h>
// scalability protocols
#include <nanomsg/pair.h>
#include <nanomsg/reqrep.h>
#include <nanomsg/pubsub.h>
#include <nanomsg/survey.h>
#include <nanomsg/pipeline.h>
#include <nanomsg/bus.h>
// transport mechanisms
#include <nanomsg/inproc.h>
#include <nanomsg/ipc.h>
#include <nanomsg/tcp.h>

#include "nanomsg-hx.hpp"

extern "C" {

__attribute__((destructor)) void fini(void)
{
    nn_term();
}


value hx_nn_bind(value sock, value address)
{
    val_check_socket(sock);
    val_check(address, string);

    int ret = nn_bind(val_socket(sock), val_string(address));
    if (ret < 0) {
        throw_errstr();
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_bind, 2);


value hx_nn_close(value sock)
{
    val_check_socket(sock);

    int ret = nn_close(val_socket(sock));
    if (ret != 0) {
        throw_errstr();
    }

   return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_close, 1);


value hx_nn_connect(value sock, value address)
{
    val_check_socket(sock);
    val_check(address, string);

    int ret = nn_connect(val_socket(sock), val_string(address));
    if (ret < 0) {
        throw_errstr();
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_connect, 2);


value hx_nn_device(value sock1, value sock2)
{
    val_check_socket(sock1);
    val_check_socket(sock2);

    int ret = nn_device(val_socket(sock1), val_socket(sock2));
    if (ret == -1) {
        throw_errstr();
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_device, 2);


value hx_nn_getsockopt(value sock, value level, value option)
{
    val_check_socket(sock);
    val_check(level, int);
    val_check(option, int);

    value val;
    int optval;
    size_t valsize = sizeof(val);
    int ret = nn_getsockopt(val_socket(sock), val_int(level), val_int(option), &optval, &valsize);
    if (ret < 0) {
        throw_errstr();
        val = alloc_int(ret);
    } else {
        val = alloc_int(optval);
    }

    return val;
}
DEFINE_PRIM(hx_nn_getsockopt, 3);


value hx_nn_poll(value reads, value writes, value boths, value timeout)
{
    val_check(reads, array);
    val_check(writes, array);
    val_check(boths, array);
    val_check(timeout, int);

    const size_t read_size  = val_array_size(reads);
    const size_t write_size = val_array_size(writes);
    const size_t boths_size = val_array_size(boths);
    const size_t arr_size   = read_size + write_size + boths_size;
    struct nn_pollfd pfd[arr_size];

    value current;
    for (int i = 0; i < read_size; ++i) {
        current = val_array_i(reads, i);
        val_check_socket(current);
        pfd[i].fd     = val_socket(current);
        pfd[i].events = NN_POLLIN;
    }
    for (int i = 0; i < write_size; ++i) {
        current = val_array_i(writes, i);
        val_check_socket(current);
        pfd[read_size + i].fd     = val_socket(current);
        pfd[read_size + i].events = NN_POLLOUT;
    }
    for (int i = 0; i < boths_size; ++i) {
        current = val_array_i(boths, i);
        val_check_socket(current);
        pfd[read_size + write_size + i].fd     = val_socket(current);
        pfd[read_size + write_size + i].events = NN_POLLIN | NN_POLLOUT;
    }

    value val;
    int ret = nn_poll(pfd, arr_size, val_int(timeout));
    if (ret == -1) {
        throw_errstr();
        val = alloc_int(ret);
    } else if (ret == 0) {
        val = alloc_null();
    } else {
        val         = alloc_array(2);
        value read  = alloc_array(read_size + boths_size);
        value write = alloc_array(write_size + boths_size);

        for (int i = 0; i < arr_size && ret > 0; ++i) {
            if (pfd[i].revents & NN_POLLIN) {
                val_array_set_i(read, i, alloc_int(pfd[i].fd));
                --ret;
            }
            if (pfd[i].revents & NN_POLLOUT) {
                val_array_set_i(write, i, alloc_int(pfd[i].fd));
                --ret;
            }
        }

        val_array_set_i(val, 0, read);
        val_array_set_i(val, 1, write);
    }

    return val;
}
DEFINE_PRIM(hx_nn_poll, 4);


value hx_nn_recv(value sock, value bytes, value flags)
{
    val_check_socket(sock);
    val_check(bytes, int);
    val_check(flags, int);

    value val;
    size_t length = val_int(bytes);
    char buf[length];
    int ret = nn_recv(val_socket(sock), &buf, length, val_int(flags));
    if (ret < 0) {
        throw_errstr();
        val = alloc_int(ret);
    } else {
        buffer b = alloc_buffer(NULL);
        buffer_append_sub(b, buf, ret);
        val = buffer_val(b);
    }

    return val;
}
DEFINE_PRIM(hx_nn_recv, 3);


value hx_nn_recv_all(value sock, value flags)
{
    val_check_socket(sock);
    val_check(flags, int);

    value val;
    char* buf = NULL;
    int ret  = nn_recv(val_socket(sock), &buf, NN_MSG, val_int(flags));
    if (ret < 0) {
        nn_freemsg(buf);
        throw_errstr();
        val = alloc_int(ret);
    } else {
        buffer b = alloc_buffer(NULL);
        buffer_append_sub(b, buf, ret);
        val = buffer_val(b);
        nn_freemsg(buf);
    }

    return val;
}
DEFINE_PRIM(hx_nn_recv_all, 2);


value hx_nn_send(value sock, value bytes, value length, value flags)
{
    val_check_socket(sock);
    val_check(length, int);
    val_check(flags, int);

    const size_t msg_length = val_int(length);
    const char* msg;
    if (val_is_string(bytes)) { // Neko
        msg = val_string(bytes);
    } else { // C++
        buffer buf = val_to_buffer(bytes);
        msg        = buffer_data(buf);
    }

    int ret = nn_send(val_socket(sock), msg, msg_length, val_int(flags));
    if (ret < 0) {
        throw_errstr();
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_send, 4);


value hx_nn_setsockopt(value sock, value level, value option, value optval)
{
    val_check_socket(sock);
    val_check(level, int);

    size_t size;
    if (val_is_int(optval)) {
        size = sizeof(int);
    } else if (val_is_string(optval)) {
        size = val_strlen(optval);
    }

    int ret;
    if (val_is_int(optval)) {
        int val = val_int(optval);
        ret = nn_setsockopt(val_socket(sock), val_int(level), val_int(option), &val, size);
    } else {
        ret = nn_setsockopt(val_socket(sock), val_int(level), val_int(option), val_string(optval), size);
    }

    if (ret != 0) {
        throw_errstr();
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_setsockopt, 4);


value hx_nn_shutdown(value sock, value connection)
{
    val_check_socket(sock);
    val_check(connection, int);

    int ret = nn_shutdown(val_socket(sock), val_int(connection));
    if (ret != 0) {
        throw_errstr();
    }

    return alloc_int(ret);
}
DEFINE_PRIM(hx_nn_shutdown, 2);


value hx_nn_socket(value domain, value protocol)
{
    val_check(domain, int);
    val_check(protocol, int);

    value val;
    int ret = nn_socket(val_int(domain), val_int(protocol));
    if (ret < 0) {
        throw_errstr();
        val = alloc_int(ret);
    } else {
        val = alloc_socket(ret);
    }

    return val;
}
DEFINE_PRIM(hx_nn_socket, 2);


value hx_nn_term(void)
{
    nn_term();
    return alloc_null();
}
DEFINE_PRIM(hx_nn_term, 0);

} // extern "C"
