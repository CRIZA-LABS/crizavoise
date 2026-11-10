# CrizaVoise performance baseline

Measured 2026-11-10 on the development PC (Windows 11, Flutter 3.47.9). Release build.

## Database at shop scale
`BENCH=1 flutter test test/benchmarks/db_benchmark_test.dart` seeds **300 products, 500 customers and 5,000 invoices (15,000 lines)** into a real SQLite file. Timings are the median of 5 runs.

| Operation | Time |
|---|---|
| Invoice list, first page (20) | 11.2 ms |
| Invoice list, search "Customer 42" | 7.3 ms |
| Next invoice number (auto sequence, skips taken numbers) | 9.2 ms |
| Duplicate invoice-number check | 7.2 ms |
| Product search on New Invoice ("rice") | 0.8 ms |
| Product search by quick code ("Q150") | 0.6 ms |
| Saving one invoice (incl. items and stock), average while seeding | ~21 ms |

Everything is well inside the 100 ms "feels instant" range, and the test fails if any step passes 500 ms.

## App size (Windows release folder)
| Part | Size |
|---|---|
| Whole `Release` folder (exe + DLLs + data) | 59 MB |
| Compiled Dart code (`app.so`) | 21.3 MB |
| `flutter_assets` | 12 MB, of which 11 MB is fonts |

## Not yet measured
- **Cold start time** and **frame build/raster times** need the app running under a profiler (`flutter run --profile` plus DevTools) on the target PC. Smart App Control was blocking local runs until today, so this is the next measurement to take.
- Memory use with a large catalogue.

The biggest size win available: the fonts. Many Indic fonts exist only so PDFs can print names in those scripts. Loading them only for the languages a shop actually uses, or subsetting them, could save several MB.
