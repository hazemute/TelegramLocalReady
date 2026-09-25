namespace MyTelegram;

public record ThemeSettings(
    bool MessageColorsAnimated,
    long BaseTheme,
    int AccentColor,
    int? OutboxAccentColor,
    List<int>? MessageColors,
    //long? WallPaperId,
    WallPaper? WallPaper);