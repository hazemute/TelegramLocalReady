namespace MyTelegram.ReadModel.Interfaces;

public interface IQuickReplyReadModel : IReadModel
{
    long UserId { get; }
    string Title { get; }
    int ShortcutId { get; }
    List<int> MessageIds { get; }
}
