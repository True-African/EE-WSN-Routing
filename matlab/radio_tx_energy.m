function e = radio_tx_energy(distance, packet_bits, energy)
%RADIO_TX_ENERGY First-order radio transmission energy model.

e = ones(size(distance)) .* energy.Eelec .* packet_bits;
near = distance <= energy.d0;
e(near) = e(near) + energy.Efs .* packet_bits .* distance(near).^2;
e(~near) = e(~near) + energy.Emp .* packet_bits .* distance(~near).^4;
end
