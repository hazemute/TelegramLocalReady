namespace MyTelegram.ReadModel.Interfaces;

public interface IUserWallPaperReadModel : IReadModel
{
    long UserId { get; }
    long WallPaperId { get; }
    WallPaperSettings WallPaperSettings { get; }
}