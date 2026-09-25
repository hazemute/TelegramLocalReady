namespace MyTelegram.ReadModel.Interfaces;

public interface IReactionReadModel : IReadModel
{
    string Reaction { get; }
    string Title { get; }
    long StaticIconId { get; }
    long AppearAnimationId { get; }
    long SelectAnimationId { get; }
    long ActivateAnimationId { get; }
    long EffectAnimationId { get; }
    long? AroundAnimationId { get; }
    long? CenterIcon { get; }
}