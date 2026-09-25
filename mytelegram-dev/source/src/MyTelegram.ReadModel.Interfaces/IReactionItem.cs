namespace MyTelegram.ReadModel.Interfaces;

public interface IReactionItem
{
    List<ReactionCount>? Reactions { get; }
    List<MessagePeerReaction>? RecentReactions2 { get; }
    List<MessageReactor>? TopReactors { get; }
    int MessageId { get; }
    IInputReplyTo? ReplyTo { get; }
}
