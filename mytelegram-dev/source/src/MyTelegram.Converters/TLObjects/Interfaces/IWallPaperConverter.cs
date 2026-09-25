namespace MyTelegram.Converters.TLObjects.Interfaces;

public interface IWallPaperConverter : ILayeredConverter
{
    IWallPaper ToWallPaper(long selfUserId, IWallPaperReadModel wallPaperReadModel, IDocument? document);
    IWallPaper ToWallPaper(long selfUserId, WallPaper wallPaper, IDocument? document);

    List<IWallPaper> ToWallPapers(long selfUserId, IReadOnlyCollection<IWallPaperReadModel> wallPaperReadModels,
        IReadOnlyCollection<IDocument> documents);
}