#include <core.p4>
#include <pna.p4>

typedef bit<48> EthernetAddress;
header ethernet_t {
    EthernetAddress dstAddr;
    EthernetAddress srcAddr;
    bit<16>         etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header udp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> length;
    bit<16> checksum;
}

struct empty_metadata_t {
}

struct main_metadata_t {
}

struct headers_t {
    ethernet_t ethernet;
    ipv4_t     ipv4;
    udp_t      udp;
}

control PreControlImpl(in headers_t hdr, inout main_metadata_t meta, in pna_pre_input_metadata_t istd, inout pna_pre_output_metadata_t ostd) {
    apply {
    }
}

parser MainParserImpl(packet_in pkt, out headers_t hdr, inout main_metadata_t main_meta, in pna_main_parser_input_metadata_t istd) {
    state parse_ipv4 {
        pkt.extract<ipv4_t>(hdr.ipv4);
        pkt.extract<udp_t>(hdr.udp);
        transition accept;
    }
    state start {
        pkt.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
}

control MainControlImpl(inout headers_t hdr, inout main_metadata_t user_meta, in pna_main_input_metadata_t istd, inout pna_main_output_metadata_t ostd) {
    @hidden action pnaexamplepass1l107() {
        hdr.udp.src_port = hdr.udp.src_port + 16w1;
        recirculate();
    }
    @hidden table tbl_pnaexamplepass1l107 {
        actions = {
            pnaexamplepass1l107();
        }
        const default_action = pnaexamplepass1l107();
    }
    apply {
        if (istd.pass == 3w4) {
            tbl_pnaexamplepass1l107.apply();
        }
    }
}

control MainDeparserImpl(packet_out pkt, in headers_t hdr, in main_metadata_t user_meta, in pna_main_output_metadata_t ostd) {
    @hidden action pnaexamplepass1l120() {
        pkt.emit<ethernet_t>(hdr.ethernet);
        pkt.emit<ipv4_t>(hdr.ipv4);
        pkt.emit<udp_t>(hdr.udp);
    }
    @hidden table tbl_pnaexamplepass1l120 {
        actions = {
            pnaexamplepass1l120();
        }
        const default_action = pnaexamplepass1l120();
    }
    apply {
        tbl_pnaexamplepass1l120.apply();
    }
}

PNA_NIC<headers_t, main_metadata_t, headers_t, main_metadata_t>(MainParserImpl(), PreControlImpl(), MainControlImpl(), MainDeparserImpl()) main;

