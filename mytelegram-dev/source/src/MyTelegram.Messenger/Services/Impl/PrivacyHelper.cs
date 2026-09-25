namespace MyTelegram.Messenger.Services.Impl;

public class PrivacyHelper : IPrivacyHelper, ITransientDependency
{
    public void ApplyPrivacy(IPrivacyReadModel? privacyReadModel,
        Action executeOnPrivacyNotMatch,
        long selfUserId,
        bool isContact)
    {

    }

    public void ApplyPrivacy(IPrivacyReadModel? privacyReadModel, Action<PrivacyValueType> executeOnPrivacyNotMatch, long selfUserId,
        ContactType contactType)
    {
        
    }

    public bool IsAllowedByPrivacy(long selfUserId, IPrivacyReadModel? privacyReadModel, ContactType contactType)
    {
        return true;
    }
}