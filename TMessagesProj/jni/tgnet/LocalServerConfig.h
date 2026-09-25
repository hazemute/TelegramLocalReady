#pragma once

#include <cstdint>

// This file is intentionally simple: configure-local.ps1 rewrites only kServerIpv4.
// The RSA key matches mytelegram-dev/source/src/MyTelegram.AuthServer/private.pkcs8.key.
namespace MyTelegramLocalConfig {
    static constexpr const char *kServerIpv4 = "192.168.1.100";
    static constexpr uint16_t kBootstrapPort = 20443;
    static constexpr uint16_t kDc2Port = 20543;
    static constexpr uint64_t kRsaFingerprint = 0xce27f5081215bda4ULL;
    static constexpr const char *kRsaPublicKey =
        "-----BEGIN RSA PUBLIC KEY-----\\n"
        "MIIBCgKCAQEAu+3tvscWDAlEvVylTeMr5FpU2AjgqzoQHPjzp69r0YAtq0a8rX0M\\n"
        "Ue78F/FRAqBaEbZW6WBzF3AjOlNYpOtvvwGhl9rGCgziunbd9nwcKJBMDWS9O7Mz\\n"
        "/8xjz/swIB4V56XcjOhrjUHJ/GniFKoum00xeEcYnr5xnLesvpVMq97Ga6b+xt3H\\n"
        "RftHY/Zy1dG5zs8upuiAOlEiKilhu1IthfMjFG3NF6TiGrO9YU3YixFbJy67jtHk\\n"
        "v5FarscM2fC5iWQ2eP1y6jXR64sGU3QjncvozYOePrH9jGcnmzUmj42x/H28IjJQ\\n"
        "9EjEc22sPOuauK0IF2QiCGh+TfsKCK189wIDAQAB\\n"
        "-----END RSA PUBLIC KEY-----";
}
