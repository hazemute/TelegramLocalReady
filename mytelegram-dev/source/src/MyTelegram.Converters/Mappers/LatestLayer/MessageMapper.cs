using System.Diagnostics.CodeAnalysis;

namespace MyTelegram.Converters.Mappers.LatestLayer;

internal sealed class MessageMapper
    : IObjectMapper<IMessageReadModel, TMessage>,
        IObjectMapper<MessageItem, TMessage>,
        ILayeredMapper,
        ITransientDependency
{
    public int Layer => Layers.LayerLatest;
    

    public TMessage Map(IMessageReadModel source)
    {
        return Map(source, new TMessage());
    }

    public TMessage Map(
        IMessageReadModel source,
        TMessage destination
    )
    {
        destination.Out = source.Out;
        //destination.Mentioned = source.Mentioned;
        //destination.MediaUnread = source.MediaUnread;
        destination.Silent = source.Silent;
        destination.Post = source.Post;
        destination.FromScheduled = source.FromScheduled;
        //destination.Legacy = source.Legacy;
        destination.EditHide = source.EditHide;
        destination.Pinned = source.Pinned;
        //destination.Noforwards = source.Noforwards;
        destination.InvertMedia = source.InvertMedia;
        //destination.Offline = source.Offline;
        //destination.VideoProcessingPending = source.VideoProcessingPending;
        destination.Id = source.MessageId;
        //destination.FromId = source.FromId;
        //destination.FromBoostsApplied = source.FromBoostsApplied;
        destination.PeerId = new Peer(source.ToPeerType, source.ToPeerId).ToPeer();
        destination.SavedPeerId = source.SavedPeerId.ToPeer();
        //destination.FwdFrom = source.FwdFrom;
        //destination.ViaBotId = source.ViaBotId;
        //destination.ViaBusinessBotId = source.ViaBusinessBotId;
        //destination.ReplyTo = source.ReplyTo;
        destination.ReplyTo = source.ReplyTo.ToMessageReplyHeader();
        destination.Date = source.Date;
        destination.Message = source.Message;
        destination.Media = source.Media2 ?? source.Media.ToTObject<IMessageMedia>();
        destination.ReplyMarkup = source.ReplyMarkup2;
        destination.Entities = source.Entities2 ?? source.Entities.ToTObject<TVector<IMessageEntity>>();
        destination.Views = source.Views;
        destination.Forwards = source.Views.HasValue ? 0 : null;
        //destination.Replies = source.Replies;
        destination.EditDate = source.EditDate;
        destination.PostAuthor = source.PostAuthor;
        destination.GroupedId = source.GroupedId;
        if (destination.GroupedId == 0)
        {
            destination.GroupedId = null;
        }

        //destination.Reactions = source.Reactions;
        //destination.RestrictionReason = source.RestrictionReason;
        destination.TtlPeriod = source.TtlPeriod;
        destination.QuickReplyShortcutId = source.QuickReplyItem?.ShortcutId;
        destination.Effect = source.Effect;
        //destination.Factcheck = source.Factcheck;
        //destination.ReportDeliveryUntilDate = source.ReportDeliveryUntilDate;

        if (destination.QuickReplyShortcutId != null)
        {
            destination.Date = 0;
        }

        return destination;
    }

    [return: NotNullIfNotNull("source")]
    public TMessage? Map(MessageItem source)
    {
        return Map(source, new TMessage());
    }

    [return: NotNullIfNotNull("source")]
    public TMessage? Map(MessageItem source, TMessage destination)
    {
        destination.Out = source.IsOut;
        //destination.Mentioned = source.Mentioned;
        //destination.MediaUnread = source.MediaUnread;
        destination.Silent = source.Silent;
        destination.Post = source.Post;
        //destination.FromScheduled = source.FromScheduled;
        //destination.Legacy = source.Legacy;
        destination.EditHide = source.EditHide;
        destination.Pinned = source.Pinned;
        //destination.Noforwards = source.Noforwards;
        destination.InvertMedia = source.InvertMedia;
        //destination.Offline = source.Offline;
        //destination.VideoProcessingPending = source.VideoProcessingPending;
        destination.Id = source.MessageId;
        //destination.FromId = source.FromId;
        //destination.FromBoostsApplied = source.FromBoostsApplied;
        destination.PeerId = source.ToPeer.ToPeer();
        destination.SavedPeerId = source.SavedPeerId.ToPeer();
        //destination.FwdFrom = source.FwdFrom;
        //destination.ViaBotId = source.ViaBotId;
        //destination.ViaBusinessBotId = source.ViaBusinessBotId;
        destination.ReplyTo = source.InputReplyTo.ToMessageReplyHeader();
        destination.Date = source.Date;
        destination.Message = source.Message;
        destination.Media = source.Media;
        destination.ReplyMarkup = source.ReplyMarkup;
        destination.Entities = source.Entities;
        destination.Views = source.Views;
        destination.Forwards = source.Views.HasValue ? 0 : null;
        //destination.Replies = source.Replies;
        destination.EditDate = source.EditDate;
        destination.PostAuthor = source.PostAuthor;
        destination.GroupedId = source.GroupId;
        if (destination.GroupedId == 0)
        {
            destination.GroupedId = null;
        }

        //destination.Reactions = source.Reactions;
        //destination.RestrictionReason = source.RestrictionReason;
        destination.TtlPeriod = source.TtlPeriod;
        //destination.QuickReplyShortcutId = source.QuickReplyShortcutId;
        destination.Effect = source.Effect;
        //destination.Factcheck = source.Factcheck;
        //destination.ReportDeliveryUntilDate = source.ReportDeliveryUntilDate;

        return destination;
    }
}