# Examples

> Various ready-to-use code examples showing how to use the `hx-nanomsg` library.

```haxe
import haxe.io.Bytes;
import nanomsg.*;

class Debug
{
    public static function main():Void
    {
        /* NN_PAIR */
        var s1 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.PAIR);
        var s2 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.PAIR);
        var addr = "inproc://hxnn";

        s1.bind(addr); s2.connect(addr);

        s1.write(Bytes.ofString("Hello from s1 to s2, sent via NN_PAIR"));
        trace(s2.readAll());
        s2.write(Bytes.ofString("Hello from s2 to s1, sent via NN_PAIR"));
        trace(s1.readAll());

        s1.close();
        s2.close();

        /* NN_REQREP */
        s1 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.REQ);
        s2 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.REP);
        addr = "inproc://hxnn";

        s2.bind(addr); s1.connect(addr);
        // s1.setOption(NanoLevel.REQ, NanoOption.REQ_RESEND_IVL, 5); // wait 5sec for reply before resending

        s1.write(Bytes.ofString("Request from s1 to s2, sent via NN_REQ"));
        trace(s2.readAll());
        s2.write(Bytes.ofString("Reply from s2 to s1, sent via NN_REQ"));
        trace(s1.readAll());

        s1.close();
        s2.close();

        /* PUBSUB */
        s1     = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.PUB);
        s2     = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.SUB);
        var s3 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.SUB);
        addr   = "inproc://hxnn";

        s1.bind(addr); s2.connect(addr); s3.connect(addr);
        s2.setOption(NanoLevel.SUB, NanoOption.SUB_SUBSCRIBE, ""); // subscribe to all messages
        s3.setOption(NanoLevel.SUB, NanoOption.SUB_SUBSCRIBE, "News"); // subscribe to news messages only
        s3.setOption(NanoLevel.SUB, NanoOption.SUB_SUBSCRIBE, "Flash"); // subscribe to news messages only

        s1.write(Bytes.ofString("Publication from s1 to NN_SUBs, sent via NN_PUB"));
        trace(s2.readAll());
        trace(s3.readAll()); // would block, as only subscribed to msg starting with "News" or "Flash" arrive (Attn: it is recommended to include `\000` after the topic in sent messages)

        s1.close();
        s2.close();

        /* SURVEY */
        s1 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.SURVEYOR);
        s2 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.RESPONDENT);
        addr = "inproc://hxnn";

        s1.bind(addr); s2.connect(addr);
        s1.setOption(NanoLevel.SURVEYOR, NanoOption.SURVEYOR_DEADLINE, 500); // wait half a second for votes

        s1.write(Bytes.ofString("Question from s1 to s2, sent by NN_SURVEYOR"));
        trace(s2.readAll());
        s2.write(Bytes.ofString("Reply from s2 to s1, sent by NN_RESPONDENT"));
        trace(s1.readAll());

        s1.close();
        s2.close();

        /* PIPELINE */
        s1 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.PUSH);
        s2 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.PULL);
        s3 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.PULL);
        addr = "inproc://hxnn";

        s1.bind(addr); s2.connect(addr); s3.connect(addr);

        s1.write(Bytes.ofString("Push from s1 to s2/s3, sent by NN_PUSH"));
        s1.write(Bytes.ofString("Push from s1 to s2/s3, sent by NN_PUSH"));
        trace(s2.readAll());
        // trace(s2.readAll()); // will not work; load balaced to s3
        trace(s3.readAll());

        s1.close();
        s2.close();
        s3.close();

        /* BUS */
        s1 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.BUS);
        s2 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.BUS);
        s3 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.BUS);
        addr = "inproc://hxnn";

        s1.bind(addr); s2.connect(addr); s3.connect(addr);

        s1.write(Bytes.ofString("Broadcast from s1 to s2/s3, sent by NN_BUS"));
        trace(s2.readAll());
        trace(s3.readAll());

        s1.close();
        s2.close();
        s3.close();

        /* POLL */
        s1 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.BUS);
        s2 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.BUS);
        s3 = new NanoSocket(NanoDomain.AF_SP, NanoProtocol.BUS);
        addr = "inproc://hxnn";

        s1.bind(addr); s2.connect(addr); s3.connect(addr);

        while (true) {
            var polls = NanoSocket.poll([s1, s2, s3], [s1, s2, s3]);
            if (polls[0] != null) {
                for (read in polls[0]) {
                    trace(read.readAll());
                }
            }
            if (polls[1] != null) {
                for (write in polls[1]) {
                    write.write(Bytes.ofString("A nice msg"));
                }
            }
        }

        s1.close();
        s2.close();
        s3.close();

        NanoSocket.terminate();
    }
}
```
