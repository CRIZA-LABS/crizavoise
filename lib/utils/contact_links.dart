import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/services/backend_services.dart';

/// Which Criza Labs mailbox a link goes to. See AppConfig for what each is for.
enum ContactChannel { support, info, business }

extension ContactChannelX on ContactChannel {
  String get email => switch (this) {
        ContactChannel.support => AppConfig.supportEmail,
        ContactChannel.info => AppConfig.infoEmail,
        ContactChannel.business => AppConfig.businessEmail,
      };

  String get subject => switch (this) {
        ContactChannel.support =>
          '${AppConfig.name} Support – ${AppConfig.version}',
        ContactChannel.info => '${AppConfig.name} Enquiry',
        ContactChannel.business => '${AppConfig.name} Business Enquiry',
      };
}

/// Body for support mails: app version, OS and installation ID only — never
/// personal, company or invoice data.
Future<String> buildSupportDiagnostics() async {
  String installationId;
  try {
    installationId =
        await BackendServices.installation.getOrCreateInstallationId();
  } catch (_) {
    installationId = 'unavailable';
  }
  return '\n\n'
      '— Please describe the issue above this line —\n'
      'App: ${AppConfig.name} ${AppConfig.version}\n'
      'OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\n'
      'Installation ID: $installationId\n';
}

/// Builds the mailto: URI for [channel] with a prefilled subject (and, for
/// support, the diagnostics body). [topic] is appended to the subject.
Future<Uri> buildContactUri(ContactChannel channel, {String? topic}) async {
  final subject =
      topic == null ? channel.subject : '${channel.subject} – $topic';
  final params = <String, String>{'subject': subject};
  if (channel == ContactChannel.support) {
    params['body'] = await buildSupportDiagnostics();
  }
  // Uri(queryParameters:) encodes spaces as '+', which many mail clients show
  // literally; build the query with %20 instead.
  final query = params.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');
  return Uri.parse('mailto:${channel.email}?$query');
}

/// Opens the user's mail app addressed to [channel]. Returns false if no
/// mail handler is available, so callers can show the address instead.
Future<bool> openContact(ContactChannel channel, {String? topic}) async {
  final uri = await buildContactUri(channel, topic: topic);
  try {
    return await launchUrl(uri);
  } catch (_) {
    return false;
  }
}

/// Opens https://criza.dev in the browser.
Future<void> openCrizaWebsite() async {
  await launchUrl(Uri.parse(AppConfig.website),
      mode: LaunchMode.externalApplication);
}
