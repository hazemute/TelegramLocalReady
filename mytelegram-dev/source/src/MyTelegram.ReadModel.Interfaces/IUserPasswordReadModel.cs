namespace MyTelegram.ReadModel.Interfaces;

public interface IUserPasswordReadModel : IReadModel
{
    string? Email { get; }
    bool HasPassword { get; }
    //bool HasRecovery { get; }
    string? Hint { get; }
    string Id { get; }
    bool IsEmailConfirmed { get; }
    byte[] PasswordHash { get; }
    SrpData SrpData { get; }

    long SrpId { get; }
    long UserId { get; }
    string? UnconfirmedEmail { get; }
}