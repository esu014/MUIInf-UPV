
import {runPeer} from "./peer.js";

runPeer({ dbFile: "./dbs/peerA.sqlite", name: "peerA", natsUrl: "nats://172.17.0.3:4222" });
runPeer({ dbFile: "./dbs/peerB.sqlite", name: "peerB", natsUrl: "nats://172.17.0.3:4222" });
