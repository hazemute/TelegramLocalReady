namespace MyTelegram;

public record GlobalPrivacySettings(
    bool ArchiveAndMuteNewNoncontactPeers,
    bool KeepArchivedUnmuted,
    bool KeepArchivedFolders,
    bool HideReadMarks,
    bool NewNoncontactPeersRequirePremium,
    long? NoncontactPeersPaidStars
    );