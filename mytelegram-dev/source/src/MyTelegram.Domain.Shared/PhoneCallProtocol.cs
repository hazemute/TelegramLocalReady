namespace MyTelegram;

public class PhoneCallProtocol(
    bool udpP2P,
    bool udpReflector,
    int minLayer,
    int maxLayer,
    IReadOnlyList<string> libraryVersions)
{
    public IReadOnlyList<string> LibraryVersions { get; init; } = libraryVersions;
    public int MaxLayer { get; init; } = maxLayer;
    public int MinLayer { get; init; } = minLayer;

    public bool UdpP2P { get; init; } = udpP2P;
    public bool UdpReflector { get; init; } = udpReflector;
}