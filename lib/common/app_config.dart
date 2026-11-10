// app_config.dart
//
// Brand, contact and edition constants for CrizaVoise by Criza Labs.
// Email addresses live ONLY here (plus LICENSE/THIRD_PARTY_NOTICES.md). Every
// mail link in the app goes through `lib/utils/contact_links.dart`.
class AppConfig {
  static const kIsCloud = false;

  /// Product name, exactly as written in the brand sheet.
  static const name = "CrizaVoise";
  static const version = "v1.0.0";

  /// Maker credit line. Never imply Criza Labs wrote the original codebase.
  static const maker = "Criza Labs";
  static const makerCredit = "CrizaVoise by Criza Labs";
  static const madeBy = "Made by Criza Labs";
  static const website = "https://criza.dev";
  static const websiteLabel = "criza.dev";

  /// In-app support, help, bug reports, "Contact us", the support banner,
  /// error-report screens and the FAQ footer.
  static const supportEmail = "contact@criza.dev";

  /// General and legal: license, notices, About, privacy/terms, app metadata,
  /// publisher info, installer and store listings.
  static const infoEmail = "info@criza.dev";

  /// Business: partnerships, resellers, white-label/custom builds, "Work with
  /// us", and licensing / commercial-use permission requests.
  static const businessEmail = "connect@criza.dev";

  static const license = "Proprietary";
  static const description =
      "CrizaVoise is simple invoicing and billing for small businesses.";

  /// Credit printed on generated invoices, reports and exports. Hidden when
  /// the user turns off SettingKey.showInvoiceFooterBranding.
  static const pdfCredit = "Powered by CrizaVoise · criza.dev";

  /// ASCII-only form for ESC/POS thermal printers, whose code pages may not
  /// have the middle dot.
  static const pdfCreditAscii = "Powered by CrizaVoise - criza.dev";

  /// Asset path of the third-party notice shown under
  /// Settings → About → Open-source licenses.
  static const thirdPartyNoticesAsset = "THIRD_PARTY_NOTICES.md";

  /// Terms of Use / Privacy Policy, bundled as assets. Bump [termsVersion]
  /// when either changes materially: users are asked to accept again.
  static const termsAsset = "TERMS.md";
  static const privacyAsset = "PRIVACY.md";
  static const termsVersion = "2026-11-10.2";
}
