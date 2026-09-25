namespace MyTelegram;

public enum ContactType
{
    None,
    TargetUserIsMyContact,
    /// <summary>
    /// I am the contact person of the target user
    /// </summary>
    ContactOfTargetUser,
    Mutual
}