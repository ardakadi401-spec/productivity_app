/// COMPONENTS.md §7.3 "öncelik pastel setinden" — `AppPriorityColors.palette`
/// ile birebir aynı 8 renk, DATABASE.md §3.2 `color` alanının beklediği hex
/// kod string temsili (Firestore/Isar'da `Color` nesnesi değil, string
/// saklanır). Yalnızca Proje oluşturma/düzenleme formundaki renk seçici
/// tarafından kullanıldığından (Tasks yalnızca `core/utils/color_hex.dart`
/// ile var olan bir hex'i render eder, palet listesine ihtiyaç duymaz) bu
/// palet Projects'in kendi `presentation/utils/`'inde kalır.
const List<String> projectColorPalette = [
  '#FF8A8A',
  '#FFC078',
  '#FFE066',
  '#8CE99A',
  '#66D9E8',
  '#74C0FC',
  '#B197FC',
  '#F783AC',
];
