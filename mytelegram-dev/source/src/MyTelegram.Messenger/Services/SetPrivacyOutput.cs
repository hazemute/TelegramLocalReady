namespace MyTelegram.Messenger.Services;

public class SetPrivacyOutput(IReadOnlyList<IPrivacyRule> rules)
{
    public IReadOnlyList<IPrivacyRule> Rules { get; } = rules;
}