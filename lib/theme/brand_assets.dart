/// Paths of the CrizaVoise brand assets (see docs/brand.md).
///
/// The family follows Criza Labs: the app mark is the Criza "A" ribbon turned
/// into a V (vector), and the lockup "CRIZA VOISE." is built from the Criza
/// master lettering exactly like "CRIZA LABS." (raster, as the parent's is).
class BrandAssets {
  /// App-icon mark (Criza V on the navy plate). Use at 48px and up.
  static const mark = 'assets/brand/mark.svg';

  /// Same mark, simplified and enlarged for 16–47px.
  static const markSmall = 'assets/brand/mark-small.svg';

  /// Criza V without the plate; mono version uses currentColor.
  static const symbol = 'assets/brand/symbol.svg';
  static const symbolMono = 'assets/brand/symbol-mono.svg';

  /// "CRIZA VOISE." lockup (PNG, 216px tall). Minimum display height 36px;
  /// below that use [mark] alone.
  static const lockupLight = 'assets/brand/lockup-light.png';
  static const lockupDark = 'assets/brand/lockup-dark.png';
}
