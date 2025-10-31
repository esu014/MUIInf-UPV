
import {runPeer} from "./peer.js";
import "./server.js";

runPeer({ dbFile: "./dbs/peerA.sqlite", name: "peerA" });
runPeer({ dbFile: "./dbs/peerB.sqlite", name: "peerB" });
