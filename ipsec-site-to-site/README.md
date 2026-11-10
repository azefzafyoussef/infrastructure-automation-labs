# strongSwan — site-to-site IPsec VPN

An IKEv2 site-to-site tunnel between two routers (R1/R2), connecting two private subnets
over an untrusted link, with modern crypto.

## Configuration

| File | Role |
|------|------|
| [`ipsec.conf`](ipsec.conf) | Connection definition (R1 side; mirror left/right on R2) |
| [`ipsec.secrets`](ipsec.secrets) | Pre-shared key (root-only, `chmod 600`) |

- **IKEv2**, PSK authentication, **tunnel mode**
- Proposals: **AES-256 / SHA-256 / DH modp2048** (`aes256-sha256-modp2048!`)
- `leftsubnet`/`rightsubnet` route the two LANs through the tunnel

## Bring-up & verification

```bash
sudo ipsec restart
sudo ipsec statusall          # shows negotiated AES_CBC_256/HMAC_SHA2_256/MODP_2048
sudo tcpdump -ni eth0 esp     # traffic is ESP-encapsulated between R1 and R2
```

Captures confirm the IKE_SA/CHILD_SA negotiation, then ESP between the routers while the
clients of each subnet can reach each other. Swapping ESP for **AH** shows
authentication/integrity without confidentiality (smaller SPIs, no encryption).

## Skills

IPsec (IKEv2, ESP/AH, tunnel vs transport), strongSwan, PSK vs certificate auth, crypto
proposal selection, traffic analysis with tcpdump/Wireshark.
