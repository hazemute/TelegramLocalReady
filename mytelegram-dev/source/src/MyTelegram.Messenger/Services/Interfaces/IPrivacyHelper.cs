namespace MyTelegram.Messenger.Services.Interfaces;

public interface IPrivacyHelper
{
    void ApplyPrivacy(
        IPrivacyReadModel? privacyReadModel,
        Action<PrivacyValueType> executeOnPrivacyNotMatch,
        long selfUserId,
        ContactType contactType);

    //void ApplyPrivacy(IPrivacyReadModel? privacyReadModel,
    //    Action executeOnPrivacyNotMatch,
    //    SimpleUserItem userItem,
    //    ContactType contactType);
    bool IsAllowedByPrivacy(long selfUserId, IPrivacyReadModel? privacyReadModel,
        ContactType contactType);
}