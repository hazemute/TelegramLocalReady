namespace MyTelegram.ReadModel.Interfaces;

public interface IGroupCallReadModel : IReadModel
{
    string MeetingId { get; }
    long CreatorUserId { get; }
    long GroupCallId { get; }
    long AccessHash { get; }
    /// <summary>
    /// group/supergroup/channel
    /// </summary>
    long ChatId { get; }
    string? Title { get; }
    int? StreamDcId { get; }
    bool RtmpStream { get; }
    List<int> ServerSources { get; }

    List<long> Participants { get; }

    bool JoinMuted { get; }
    bool CanChangeJoinMuted { get; }
    bool JoinDateAsc { get; }
    bool ScheduleStartSubscribed { get; }
    bool CanStartVideo { get; }
    bool RecordVideoActive { get; }
    bool ListenersHidden { get; }
    int ParticipantsCount { get; }
    int? RecordStartDate { get; }
    int? ScheduleDate { get; }
    int? UnmutedVideoCount { get; }
    int UnmutedVideoLimit { get; }
    int GroupCallVersion { get; }
}