#include <core.p4>
#include <v1model.p4>

struct alt_t {
    bit<1> valid;
    bit<7> port;
}

struct row_t {
    alt_t alt0;
    alt_t alt1;
}

struct local_metadata_t {
    row_t row;
}

header bitvec_hdr {
    row_t row;
}

struct parsed_packet_t {
    bitvec_hdr bvh;
    bitvec_hdr bvh1;
}

struct tst_t {
    bitvec_hdr bvh0;
}

parser parse(packet_in pk, out parsed_packet_t h, inout local_metadata_t local_metadata, inout standard_metadata_t standard_metadata) {
    state start {
        transition accept;
    }
}

control ingress(inout parsed_packet_t h, inout local_metadata_t local_metadata, inout standard_metadata_t standard_metadata) {
    apply {
        tst_t s;
        local_metadata.row.alt0 = local_metadata.row.alt1;
        local_metadata.row.alt0.valid = 1w1;
        local_metadata.row.alt1.port = local_metadata.row.alt1.port + 7w1;
        clone3<row_t>(CloneType.I2E, 32w0, local_metadata.row);
    }
}

control egress(inout parsed_packet_t hdr, inout local_metadata_t local_metadata, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control deparser(packet_out b, in parsed_packet_t h) {
    apply {
    }
}

control verify_checksum(inout parsed_packet_t hdr, inout local_metadata_t local_metadata) {
    apply {
    }
}

control compute_checksum(inout parsed_packet_t hdr, inout local_metadata_t local_metadata) {
    apply {
    }
}

V1Switch<parsed_packet_t, local_metadata_t>(parse(), verify_checksum(), ingress(), egress(), compute_checksum(), deparser()) main;
