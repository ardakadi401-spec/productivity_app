/// Statistics Screen'in dönem seçici chip grubu (SCREENS.md §4.20,
/// COMPONENTS.md §10.3 "Günlük/Haftalık/Aylık"). `GoalPeriodType` ile aynı
/// üç isme sahip olsa da kavramsal olarak farklıdır (bir hedefin kendi
/// planlama dönemi değil, bir RAPORLAMA penceresidir) — bu yüzden Goals'a
/// bağımlı olmadan Statistics'in kendi enum'u olarak tutulur.
enum StatisticsPeriod { daily, weekly, monthly }
