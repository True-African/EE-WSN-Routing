function e = radio_rx_energy(packet_bits, energy, aggregate)
%RADIO_RX_ENERGY First-order reception plus optional aggregation cost.

if nargin < 3
    aggregate = false;
end

e = energy.Eelec * packet_bits;
if aggregate
    e = e + energy.EDA * packet_bits;
end
end
