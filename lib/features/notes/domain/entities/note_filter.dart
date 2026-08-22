/// Notes Screen filtreleri (SCREENS.md §4.18) ve Project/Task Detail'in
/// "bağlı notlar" sorgusu (SCREENS.md §4.8/§4.10) için tek filtre nesnesi —
/// Tasks'ın `TaskFilter`'ıyla aynı desen.
///
/// [tagIds] verilirse notlar arasında **birleşim (OR)** mantığıyla eşleşir
/// — bir not, seçili etiketlerden EN AZ BİRİNE sahipse listelenir (ROADMAP.md
/// FAZ 10 "birden fazla etiketle filtrelendiğinde doğru kesişim/birleşim
/// mantığı" test noktası — burada bilinçli olarak birleşim seçildi, yaygın
/// etiket filtreleme UX kuralı).
class NoteFilter {
  const NoteFilter({this.projectId, this.taskId, this.tagIds = const []});

  final String? projectId;
  final String? taskId;
  final List<String> tagIds;

  static const none = NoteFilter();
}
