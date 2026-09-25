namespace MyTelegram.Messenger.Services.Interfaces;

public interface IContactAppService
{
    ContactType GetContactType(long selfUserId, long targetUserId,
        IReadOnlyCollection<IContactReadModel> contactReadModels);

    Task<ContactType> GetContactTypeAsync(long selfUserId, long targetUserId);

    Task<SearchContactOutput> SearchAsync(long selfUserId,
            string keyword, int limit);
}