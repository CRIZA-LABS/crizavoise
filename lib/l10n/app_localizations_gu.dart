// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'CrizaVoise';

  @override
  String get actionSave => 'સાચવો';

  @override
  String get actionCancel => 'રદ કરો';

  @override
  String get actionSkip => 'છોડો';

  @override
  String get actionNext => 'આગળ';

  @override
  String get actionBack => 'પાછળ';

  @override
  String get actionGetStarted => 'શરૂ કરો';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonSystemDefault => 'System Default';

  @override
  String get commonTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get onboardingStepCompanyTitle => 'Company';

  @override
  String get onboardingStepCompanySubtitle => 'Tell us about your business';

  @override
  String get onboardingStepInvoiceTitle => 'Invoice Settings';

  @override
  String get onboardingStepInvoiceSubtitle => 'Set up how your invoices work';

  @override
  String get onboardingStepPurchaseBillsTitle => 'Purchase Bills & Suppliers';

  @override
  String get onboardingStepPurchaseBillsSubtitle =>
      'Track supplier bills and stock purchases (optional)';

  @override
  String get onboardingStepAppearanceTitle => 'Invoice Appearance';

  @override
  String get onboardingStepAppearanceSubtitle =>
      'Pick a page size and template';

  @override
  String get onboardingStepDoneTitle => 'All Set';

  @override
  String get onboardingCompanyNameLabel => 'Company Name';

  @override
  String get onboardingCountryLabel => 'Country';

  @override
  String get onboardingLogoLabel => 'Company Logo';

  @override
  String get onboardingCurrencyLabel => 'Currency';

  @override
  String get onboardingDateFormatLabel => 'Date Format';

  @override
  String get onboardingInvoiceStartingNumberLabel => 'Invoice Starting Number';

  @override
  String get onboardingLeadingZerosLabel => 'Leading Zeros';

  @override
  String get onboardingLeadingZerosSubtitle =>
      'Pad invoice numbers to 8 digits (e.g. 00000007)';

  @override
  String get onboardingDefaultTaxRateLabel => 'Default Tax Rate (%)';

  @override
  String get onboardingEnablePurchaseBillsSuppliersLabel =>
      'Enable Purchase Bills & Suppliers';

  @override
  String get onboardingEnablePurchaseBillsSuppliersSubtitle =>
      'Adds Purchase Bills and Suppliers to the dashboard menu. You can change this anytime in Settings.';

  @override
  String get onboardingPageSizeLabel => 'Page Size';

  @override
  String get onboardingTemplateLabel => 'Invoice Template';

  @override
  String get onboardingDoneHeadline => 'You\'re all set!';

  @override
  String get onboardingDoneBody =>
      'Your company, invoice and template details are saved. You can update any of these later from Settings.';

  @override
  String get splashInitErrorTitle => 'Initialization Error';

  @override
  String splashInitErrorMessage(String error) {
    return 'Failed to initialize the database.\n\n$error';
  }

  @override
  String get actionRetry => 'ફરી પ્રયાસ કરો';

  @override
  String get splashInitializingMessage => 'Initializing App...';

  @override
  String get testGateNoInternetTitle =>
      'Test installer needs internet access to verify.';

  @override
  String get testGateExpiredTitle => 'This test build has expired.';

  @override
  String get testGateNoInternetSubtitle => 'Connect to the internet and retry.';

  @override
  String testGateExpiredSubtitle(String email) {
    return 'Contact support: $email';
  }

  @override
  String get dashboardSessionExpiredMessage =>
      'Session expired due to inactivity.';

  @override
  String get dashboardUnknownTabLabel => 'Unknown tab';

  @override
  String dashboardInvoiceLayoutTooltip(String layout) {
    return 'Invoice layout: $layout — tap for info';
  }

  @override
  String get dashboardLayoutNew => 'New';

  @override
  String get dashboardLayoutClassic => 'Classic';

  @override
  String get dashboardInvoiceLayoutDialogTitle => 'Invoice layout';

  @override
  String dashboardInvoiceLayoutDialogBody(String layout) {
    return 'You\'re using the $layout \"New Invoice\" layout. You can switch it from Settings > Accessibility. Note: switching mid-edit discards any unsaved changes on this form.';
  }

  @override
  String get actionClose => 'બંધ કરો';

  @override
  String get dashboardOpenSettingsAction => 'Open Settings';

  @override
  String get dashboardCollapseSidebarTooltip => 'Collapse sidebar';

  @override
  String get dashboardExpandSidebarTooltip => 'Expand sidebar';

  @override
  String get navDashboard => 'ડેશબોર્ડ';

  @override
  String get navNewInvoice => 'નવું ઇન્વૉઇસ';

  @override
  String get navInvoices => 'ઇન્વૉઇસ';

  @override
  String get navServices => 'રોકડ વિનિમય સેવાઓ';

  @override
  String get navQuotations => 'ક્વોટેશન';

  @override
  String get navReceipts => 'રસીદો';

  @override
  String get navCreditNotes => 'ક્રેડિટ નોટ';

  @override
  String get navDebitNotes => 'ડેબિટ નોટ';

  @override
  String get navCustomers => 'ગ્રાહકો';

  @override
  String get navProducts => 'ઉત્પાદનો';

  @override
  String get navReports => 'અહેવાલો';

  @override
  String get navPurchaseBills => 'ખરીદ બિલ';

  @override
  String get navSuppliers => 'સપ્લાયર્સ';

  @override
  String get navSettings => 'સેટિંગ્સ';

  @override
  String get dashboardRoleAdmin => 'એડમિન';

  @override
  String get dashboardRoleUser => 'વપરાશકર્તા';

  @override
  String get dashboardSupportTooltip => 'Support';

  @override
  String get dashboardLogoutTooltip => 'Logout';

  @override
  String get dashboardTestBuildBadge => 'TEST BUILD';

  @override
  String get dashboardTestBadgeShort => 'TEST';

  @override
  String get dashboardKeyboardShortcutsTitle => 'Keyboard Shortcuts';

  @override
  String get dashboardShortcutsBannerTitle => 'New: Keyboard shortcuts';

  @override
  String get dashboardShortcutsBannerSubtitle =>
      'Ctrl+Q for a new invoice, Ctrl+S to save, and more.';

  @override
  String get dashboardPurchaseBannerTitle => 'New: Purchase Bills & Suppliers';

  @override
  String get dashboardPurchaseBannerSubtitle =>
      'Record supplier bills, update stock automatically, and track what you owe each supplier.';

  @override
  String get dashboardPurchaseBannerAction => 'Enable';

  @override
  String get dashboardViewAllAction => 'View all';

  @override
  String get dashboardLayoutBannerTitle => 'New: Multiple dashboard layouts';

  @override
  String get dashboardLayoutBannerSubtitle =>
      'Switch between Default, Classic, Bento, and Simple Feed using the grid icon in the top-right.';

  @override
  String get actionGotIt => 'સમજાયું';

  @override
  String get dashboardThemeBannerTitle => 'New: Dark mode';

  @override
  String get dashboardThemeBannerSubtitle =>
      'We\'re still polishing it — switch it on from Settings > Company Info and let us know what looks off.';

  @override
  String dashboardSupportBannerTitle(String count) {
    return 'You\'ve created $count invoices!';
  }

  @override
  String get dashboardSupportBannerReviewSubtitle =>
      'Enjoying CrizaVoise? Tell us what\'s working and what isn\'t.';

  @override
  String get dashboardSupportBannerSupportSubtitle =>
      'Looks like CrizaVoise is part of your workflow. Questions or ideas? We\'d love to hear from you.';

  @override
  String get dashboardReviewAction => 'Share feedback';

  @override
  String get dashboardSupportAction => 'Contact us';

  @override
  String get dashboardOverviewTitle => 'Dashboard Overview';

  @override
  String get actionRefresh => 'તાજું કરો';

  @override
  String get helpSearchTooltip => 'Search Help & Settings';

  @override
  String dashboardOutOfStockCountLabel(int count) {
    return '$count out of stock';
  }

  @override
  String get dashboardRevenueCollectedLabel => 'Revenue Collected';

  @override
  String get dashboardOutstandingLabel => 'Outstanding';

  @override
  String dashboardOverdueCountLabel(int count) {
    return '$count overdue';
  }

  @override
  String get dashboardRecentInvoicesTitle => 'Recent Documents';

  @override
  String get dashboardLastFiveInvoicesLabel => 'Last 5 documents';

  @override
  String get dashboardColDocumentNo => 'Document no.';

  @override
  String get dashboardColType => 'Type';

  @override
  String get dashboardNoInvoicesYetTitle => 'No invoices yet';

  @override
  String get dashboardNoInvoicesYetSubtitle =>
      'Create your first invoice to see it here';

  @override
  String get actionView => 'જુઓ';

  @override
  String get actionEdit => 'ફેરફાર કરો';

  @override
  String get actionDuplicate => 'નકલ બનાવો';

  @override
  String get actionPdfPreview => 'PDF પૂર્વાવલોકન';

  @override
  String get actionDownloadPdf => 'PDF ડાઉનલોડ કરો';

  @override
  String get actionPrint => 'છાપો';

  @override
  String get actionPayment => 'ચુકવણી';

  @override
  String get actionDelete => 'કાઢી નાખો';

  @override
  String get actionRecordPayment => 'ચુકવણી નોંધો';

  @override
  String dashboardDueDateLabel(String date) {
    return 'Due: $date';
  }

  @override
  String get labelInvoice => 'Invoice';

  @override
  String get labelQuotation => 'Quotation';

  @override
  String get labelReceipt => 'Receipt';

  @override
  String dashboardWelcomeBackMessage(String username) {
    return 'Welcome back, $username';
  }

  @override
  String get dashboardBusinessGlanceSubtitle =>
      'Here\'s your business at a glance';

  @override
  String get dashboardDueSoonTitle => 'Due Soon';

  @override
  String dashboardInvoiceCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices',
      one: '1 invoice',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTodayTomorrowLabel => 'Today & Tomorrow';

  @override
  String get dashboardDueTodayBadge => 'Due Today';

  @override
  String get dashboardDueTomorrowBadge => 'Due Tomorrow';

  @override
  String get dashboardOverdueSectionTitle => 'Overdue';

  @override
  String get dashboardOldestFirstLabel => 'Oldest first';

  @override
  String dashboardDaysOverdueLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get dashboardNewStockQuantityLabel => 'New Stock Quantity';

  @override
  String get actionUpdate => 'અપડેટ કરો';

  @override
  String get labelService => 'સેવા';

  @override
  String get labelProduct => 'ઉત્પાદન';

  @override
  String dashboardStockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get actionUpdateStock => 'સ્ટોક અપડેટ કરો';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusPartial => 'Partial';

  @override
  String get paymentStatusUnpaid => 'Unpaid';

  @override
  String get dashboardDuplicateInvoiceTitle => 'Duplicate Invoice';

  @override
  String dashboardDuplicateInvoiceBody(String number, String customerName) {
    return 'Create a copy of Invoice #$number\n($customerName) as:';
  }

  @override
  String get dashboardDeleteInvoiceTitle => 'Delete Invoice';

  @override
  String dashboardDeleteInvoiceBody(String number) {
    return 'Are you sure you want to delete Invoice #$number? This action cannot be undone.';
  }

  @override
  String get dashboardLayoutTooltip => 'Dashboard Layout';

  @override
  String get dashboardLayoutDefaultTitle => 'Default';

  @override
  String get dashboardLayoutDefaultSubtitle => 'Original layout';

  @override
  String get dashboardLayoutClassicSubtitle => 'Charts + KPI grid';

  @override
  String get dashboardLayoutBentoTitle => 'Bento';

  @override
  String get dashboardLayoutBentoSubtitle => 'Hero chart + card grid';

  @override
  String get dashboardLayoutSimpleTitle => 'Simple Feed';

  @override
  String get dashboardLayoutSimpleSubtitle => 'Clean list view';

  @override
  String get dashboardTotalInvoicesLabel => 'Total Invoices';

  @override
  String get dashboardRevenueLast6MonthsTitle => 'Revenue — Last 6 Months';

  @override
  String get dashboardNoPaymentDataYetLabel => 'No payment data yet';

  @override
  String get dashboardFinancialOverviewTitle => 'Financial Overview';

  @override
  String get dashboardCollectedLabel => 'Collected';

  @override
  String dashboardInvoiceCountOverdueLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices overdue',
      one: '1 invoice overdue',
    );
    return '$_temp0';
  }

  @override
  String dashboardLastNLabel(int n) {
    return 'Last $n';
  }

  @override
  String get labelCustomer => 'Customer';

  @override
  String get labelAmount => 'Amount';

  @override
  String get dashboardZeroLeftLabel => '0 left';

  @override
  String get labelStock => 'Stock';

  @override
  String get actionPay => 'ચૂકવો';

  @override
  String get dashboardQuickActionsTitle => 'Quick Actions';

  @override
  String get dashboardPdfActionsTooltip => 'PDF Actions';

  @override
  String get dashboardActionsTooltip => 'Actions';

  @override
  String get dashboardTopCustomersTitle => 'Top Customers';

  @override
  String get dashboardTopProductsTitle => 'Top Products';

  @override
  String dashboardUnitsLabel(String qty) {
    return '$qty units';
  }

  @override
  String get dashboardBetaBadge => 'BETA';

  @override
  String get dashboardOutOfStockSectionTitle => 'Out of Stock';

  @override
  String dashboardItemCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTapToRestockLabel => 'Tap to restock';

  @override
  String get createInvoiceUnsavedChangesTitle => 'Unsaved changes';

  @override
  String get createInvoiceUnsavedChangesMessage =>
      'You have unsaved changes in this invoice. Save them before leaving?';

  @override
  String get createInvoiceKeepEditingButton => 'Keep Editing';

  @override
  String get actionDiscard => 'રદબાતલ કરો';

  @override
  String createInvoiceErrorLoadingDataMessage(String e) {
    return 'Error loading data: $e';
  }

  @override
  String get createInvoiceInsufficientStockTitle => 'Insufficient Stock';

  @override
  String createInvoiceInsufficientStockMessage(int stock, double qty) {
    return 'Only $stock unit(s) available. Add $qty anyway?';
  }

  @override
  String get createInvoiceAddAnywayButton => 'Add Anyway';

  @override
  String get createInvoiceOutOfStockTitle => 'Out of Stock';

  @override
  String createInvoiceOutOfStockMessage(String name) {
    return '$name is out of stock. Add anyway?';
  }

  @override
  String get createInvoiceUnlimitedStockLabel => 'Unlimited Stock';

  @override
  String createInvoiceAvailableStockLabel(int stock) {
    return 'Available Stock: $stock';
  }

  @override
  String get fieldDiscountLabel => 'Discount';

  @override
  String get fieldUnitPriceOverrideLabel => 'Unit Price (override)';

  @override
  String get fieldExtraCostLabel => 'Extra Cost (optional)';

  @override
  String get fieldInsertAtPositionLabel => 'Insert at position';

  @override
  String get actionAdd => 'ઉમેરો';

  @override
  String get createInvoiceProductAlreadyAddedMessage =>
      'This product has already been added';

  @override
  String get createInvoiceCustomerNameRequiredMessage =>
      'Please provide customer name';

  @override
  String get createInvoiceAtLeastOneItemRequiredMessage =>
      'Please add at least one item';

  @override
  String createInvoiceCreatedSuccessMessage(String invoiceTypeLabel) {
    return '$invoiceTypeLabel created successfully!';
  }

  @override
  String createInvoiceErrorCreatingMessage(String e) {
    return 'Error creating invoice: $e';
  }

  @override
  String get createInvoiceEditItemTitle => 'Edit Item';

  @override
  String get createInvoiceCustomItemTitle => 'Custom Item';

  @override
  String get fieldItemNameLabel => 'Item Name';

  @override
  String get fieldAliasForPdfLabel => 'Alias (for PDF)';

  @override
  String get fieldUnitPriceLabel => 'Unit Price';

  @override
  String get fieldRateLabel => 'Rate';

  @override
  String get fieldTaxRateLabel => 'Tax Rate (%)';

  @override
  String get fieldPriceIncludesTaxLabel => 'Price includes tax';

  @override
  String get createInvoicePhoneAlreadyInUseTitle =>
      'Phone Number Already In Use';

  @override
  String createInvoicePhoneAlreadyInUseMessage(String ownerName) {
    return 'This phone number belongs to \"$ownerName\".\n\nCannot save this customer with a phone number that already belongs to someone else.';
  }

  @override
  String get actionOk => 'બરાબર';

  @override
  String get createInvoiceCustomerNameRequiredBeforeSavingMessage =>
      'Please enter a customer name before saving';

  @override
  String get createInvoicePhoneChangedTitle => 'Phone Number Changed';

  @override
  String createInvoicePhoneChangedMessage(String name) {
    return 'The phone number for \"$name\" was changed.\n\nUpdate their existing record, or save these details as a new customer?';
  }

  @override
  String get createInvoiceSaveAsNewButton => 'Save as New';

  @override
  String get createInvoiceUpdateExistingButton => 'Update Existing';

  @override
  String createInvoiceCustomerUpdatedMessage(String name) {
    return '$name updated in customer list';
  }

  @override
  String get createInvoiceCustomerAlreadyExistsTitle =>
      'Customer Already Exists';

  @override
  String createInvoiceCustomerAlreadyExistsMessage(String name) {
    return '\"$name\" is already saved with this phone number.\n\nUse their existing details, or update their record with the current information?';
  }

  @override
  String get createInvoiceUseExistingButton => 'Use Existing';

  @override
  String createInvoiceUsingExistingCustomerMessage(String name) {
    return 'Using existing customer \"$name\"';
  }

  @override
  String createInvoiceCustomerSavedMessage(String name) {
    return '$name saved to customer list';
  }

  @override
  String get createInvoiceCustomerRecordGoneMessage =>
      'Customer record no longer exists';

  @override
  String get createInvoiceCustomerRefreshedMessage =>
      'Customer details refreshed';

  @override
  String get fieldLabelLabel => 'Label';

  @override
  String get hintLabelExample => 'e.g. Shipping';

  @override
  String get tooltipRemove => 'Remove';

  @override
  String get createInvoiceAddRowButton => 'Add Row';

  @override
  String get fieldDiscountPerUnitLabel => 'Discount per unit';

  @override
  String get createInvoiceDiscountPerUnitFormulaOn =>
      '(price − discount) × qty';

  @override
  String get createInvoiceDiscountPerUnitFormulaOff =>
      '(price × qty) − discount';

  @override
  String get createInvoicePrevBalanceShortLabel => 'Prev. Balance';

  @override
  String get createInvoicePreviousBalanceDueLabel => 'Previous Balance Due';

  @override
  String get createInvoicePaymentSectionLabel => 'Payment';

  @override
  String get createInvoiceBalanceDueLabel => 'Balance Due';

  @override
  String createInvoicePaymentNotRecordedMessage(String error) {
    return 'Invoice saved, but the payment was not recorded: $error. Add it from the Invoices list.';
  }

  @override
  String get createInvoiceDueShortLabel => 'Due';

  @override
  String get createInvoiceTotalDueLabel => 'Total Due';

  @override
  String createInvoiceUpdatedSuccessMessage(String invoiceTypeLabel) {
    return '$invoiceTypeLabel updated successfully!';
  }

  @override
  String createInvoiceTotalBelowPaidMessage(String paid) {
    return 'The new total is less than the $paid already paid. Delete payments in Apply Payment first, or keep the total at or above that amount.';
  }

  @override
  String createInvoiceErrorUpdatingMessage(String e) {
    return 'Error updating invoice: $e';
  }

  @override
  String createInvoiceCreatedHeadline(String invoiceTypeLabel) {
    return '$invoiceTypeLabel Created Successfully!';
  }

  @override
  String createInvoiceIdLabel(String invoiceTypeLabel, String invoiceNumber) {
    return '$invoiceTypeLabel ID: $invoiceNumber';
  }

  @override
  String get createInvoiceViewDetailsLabel => 'View Details';

  @override
  String get createInvoicePreviewPdfLabel => 'Preview PDF';

  @override
  String get createInvoicePreviewPdfTooltip => 'Preview PDF (Shortcut: Ctrl+o)';

  @override
  String get createInvoicePrintPdfLabel => 'Print PDF';

  @override
  String get createInvoicePrintPdfTooltip => 'Print PDF (Shortcut: Ctrl+p)';

  @override
  String get actionDismiss => 'બંધ કરો';

  @override
  String get createInvoiceCreateNewInvoiceButton =>
      'Create New Invoice (Shortcut: Ctrl+q)';

  @override
  String createInvoiceAppBarTitle(String invoiceTypeLabel) {
    return 'Create New $invoiceTypeLabel';
  }

  @override
  String get commonLoadingDataMessage => 'Loading data...';

  @override
  String get createInvoiceAddItemBeforeCreatingMessage =>
      'Add at least one item before creating the invoice.';

  @override
  String createInvoiceCreatedTitleShort(String invoiceTypeLabel) {
    return '$invoiceTypeLabel Created';
  }

  @override
  String createInvoiceEditTitle(String invoiceTypeLabel) {
    return 'Edit $invoiceTypeLabel';
  }

  @override
  String createInvoiceDuplicateAsTitle(String invoiceTypeLabel) {
    return 'Duplicate as $invoiceTypeLabel';
  }

  @override
  String get createInvoiceNewShortLabel => 'New';

  @override
  String get createInvoiceNewInvoiceShortcutLabel =>
      'New Invoice (Shortcut: Ctrl+q)';

  @override
  String get createInvoiceSavingEllipsisLabel => 'Saving...';

  @override
  String get createInvoiceSaveCustomerLabel => 'Save customer';

  @override
  String get createInvoiceSelectExistingCustomerButton =>
      'Select from existing';

  @override
  String get createInvoiceRefreshCustomerTooltip =>
      'Refresh from saved customer';

  @override
  String get createInvoiceClearCustomerTooltip => 'Clear customer selection';

  @override
  String get fieldCustomerNameRequiredLabel => 'Customer Name *';

  @override
  String get fieldBusinessNameLabel => 'Business Name';

  @override
  String get fieldPhoneLabel => 'Phone';

  @override
  String get fieldGstinVatLabel => 'GSTIN / VAT';

  @override
  String get fieldEmailLabel => 'Email';

  @override
  String get fieldAddressLabel => 'Address';

  @override
  String get tooltipEditInLargerView => 'Edit in larger view';

  @override
  String get createInvoiceChooseCustomerTitle => 'Choose a customer';

  @override
  String get createInvoiceSearchCustomerLabel => 'Search customer';

  @override
  String get createInvoiceNoCustomersFoundMessage => 'No customers found';

  @override
  String createInvoiceDetailsHeading(String invoiceTypeLabel) {
    return '$invoiceTypeLabel DETAILS';
  }

  @override
  String get createInvoiceTypeFieldLabel => 'Invoice type';

  @override
  String get createInvoiceTypeLockedHelperText =>
      'Type can\'t be changed after creation';

  @override
  String get createInvoiceOrderDateLabel => 'Order date';

  @override
  String get createInvoiceOrderTimeLabel => 'Order time';

  @override
  String get createInvoiceDueDateLabel => 'Due date';

  @override
  String get createInvoiceGstTitleLabel => 'GST title';

  @override
  String get createInvoiceTaxTitleLabel => 'Tax title';

  @override
  String get gstTitleTaxInvoiceLabel => 'Tax Invoice';

  @override
  String get gstTitleBillOfSupplyLabel => 'Bill of Supply';

  @override
  String get gstTitleInvoiceCumBillLabel => 'Invoice-cum-Bill of Supply';

  @override
  String get gstTitleCashBillLabel => 'Cash Bill';

  @override
  String get gstTitleCreditNoteLabel => 'Credit Note';

  @override
  String get gstTitleDebitNoteLabel => 'Debit Note';

  @override
  String get gstTitleRevisedInvoiceLabel => 'Revised Invoice';

  @override
  String get createInvoiceSearchProductLabel =>
      'નામ કે ક્વિક કોડથી શોધો અને ઉમેરો (Ctrl+F)';

  @override
  String get createInvoiceCustomItemButton => 'Custom item (Ctrl+M)';

  @override
  String get createInvoiceNoProductsFoundMessage => 'No products found';

  @override
  String createInvoiceItemAlreadyInProductListMessage(String name) {
    return '\"$name\" already exists in product list';
  }

  @override
  String createInvoiceProductSavedMessage(String name) {
    return '$name saved to product list';
  }

  @override
  String get createInvoiceSaveToProductListTooltip => 'Save to product list';

  @override
  String get tooltipEditItem => 'Edit item';

  @override
  String get tooltipRemoveItem => 'Remove item';

  @override
  String get createInvoiceNoItemsAddedMessage => 'No items added yet';

  @override
  String get createInvoiceSearchHintMessage => 'Search below or press Ctrl+F';

  @override
  String get createInvoiceDiscountFieldLabel => 'Invoice Discount';

  @override
  String get discountTypeAmountShortLabel => 'Amt';

  @override
  String get createInvoiceNotesOptionalLabel => 'Notes (optional)';

  @override
  String get createInvoiceNotesHint => 'Payment terms, thank-you note…';

  @override
  String get createInvoiceNotesTitle => 'Notes';

  @override
  String get createInvoiceHideNumberInPdfLabel => 'Hide invoice number in PDF';

  @override
  String get createInvoiceCustomNumberLabel => 'Custom number (optional)';

  @override
  String get createInvoiceCustomNumberHint =>
      'e.g. QUO-2026-014 — shown in PDF instead';

  @override
  String get createInvoiceEnableTaxLabel => 'Enable tax';

  @override
  String get createInvoiceGlobalRateTooltip => 'Global rate';

  @override
  String get createInvoicePerItemRateTooltip => 'Per item rate';

  @override
  String get createInvoiceDefaultTaxRateLabel => 'Default tax rate';

  @override
  String get createInvoiceTaxRateFromProductMessage =>
      'Tax rate from each product';

  @override
  String get createInvoiceInterStateLabel => 'Interstate supply (IGST)';

  @override
  String get createInvoicePaymentUpiAccountLabel => 'Payment UPI account';

  @override
  String get commonNoneLabel => 'None';

  @override
  String get createInvoiceBankAccountLabel => 'Bank account';

  @override
  String get fieldSubtotalLabel => 'Subtotal';

  @override
  String get createInvoiceDiscountColonLabel => 'Discount:';

  @override
  String get fieldTaxLabel => 'Tax';

  @override
  String get createInvoiceExtraCostFallbackLabel => 'Extra Cost';

  @override
  String createInvoiceDiscountPercentLabel(String toStringAsFixed) {
    return 'Invoice Discount ($toStringAsFixed%):';
  }

  @override
  String get createInvoiceInvoiceDiscountColonLabel => 'Invoice Discount:';

  @override
  String get fieldTotalLabel => 'Total';

  @override
  String get createInvoicePreviewLabel => 'પૂર્વાવલોકન';

  @override
  String get createInvoicePreviewTooltip => 'Preview (Shortcut: Ctrl+o)';

  @override
  String get createInvoiceDownloadLabel => 'ડાઉનલોડ';

  @override
  String get createInvoicePrintTooltip => 'Print (Shortcut: Ctrl+p)';

  @override
  String get fieldUnitOverrideLabel => 'Unit (override)';

  @override
  String get commonCustomEllipsisLabel => 'Custom…';

  @override
  String get fieldCustomUnitLabel => 'Custom unit';

  @override
  String get invoiceMgmtMoveToTrashTitle => 'Move to Trash';

  @override
  String invoiceMgmtMoveToTrashBody(String number) {
    return 'Move Invoice #$number to trash?';
  }

  @override
  String get invoiceMgmtMovedToTrashMessage => 'Invoice moved to trash.';

  @override
  String invoiceMgmtFailedToLoadMessage(String error) {
    return 'Failed to load invoices: $error';
  }

  @override
  String invoiceMgmtExportToCsvTitle(String type) {
    return 'Export $type to CSV';
  }

  @override
  String get invoiceMgmtExportAllRecordsLabel => 'Export All Records';

  @override
  String get invoiceMgmtFilterByDateRangeLabel => 'Or filter by date range:';

  @override
  String get invoiceMgmtFromDateLabel => 'From Date';

  @override
  String get invoiceMgmtToDateLabel => 'To Date';

  @override
  String get invoiceMgmtDateRangeInvalidMessage =>
      'To date must be after From date.';

  @override
  String get actionExport => 'નિકાસ';

  @override
  String invoiceMgmtExportedRecordsMessage(int count, String path) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count records to: $path',
      one: 'Exported 1 record to: $path',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtExportFailedMessage(String error) {
    return 'Export failed: $error';
  }

  @override
  String invoiceMgmtBulkMoveToTrashBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count invoices to trash?',
      one: 'Move 1 invoice to trash?',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtBulkMovedToTrashMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices moved to trash.',
      one: '1 invoice moved to trash.',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtBulkDeleteFailedMessage(String error) {
    return 'Bulk delete failed: $error';
  }

  @override
  String invoiceMgmtBulkExportedCsvMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count invoices to CSV',
      one: 'Exported 1 invoice to CSV',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtCsvExportFailedMessage(String error) {
    return 'CSV export failed: $error';
  }

  @override
  String get invoiceMgmtDownloadPdfsTitle => 'Download PDFs';

  @override
  String invoiceMgmtSavePdfsPromptMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'How would you like to save $count PDFs?',
      one: 'How would you like to save 1 PDF?',
    );
    return '$_temp0';
  }

  @override
  String get invoiceMgmtSaveToFolderLabel => 'Save to Folder';

  @override
  String get invoiceMgmtSaveAsZipLabel => 'Save as ZIP';

  @override
  String get invoiceMgmtChooseFolderDialogTitle => 'Choose folder to save PDFs';

  @override
  String get invoiceMgmtSaveZipDialogTitle => 'Save ZIP file';

  @override
  String get invoiceMgmtCreatingZipLabel => 'Creating ZIP';

  @override
  String get invoiceMgmtGeneratingPdfsLabel => 'Generating PDFs';

  @override
  String invoiceMgmtProcessingPdfsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Processing $count PDFs...',
      one: 'Processing 1 PDF...',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtSavedToMessage(String path) {
    return 'Saved to: $path';
  }

  @override
  String invoiceMgmtPdfExportFailedMessage(String error) {
    return 'PDF export failed: $error';
  }

  @override
  String get invoiceMgmtDownloadByFilterTitle => 'Download PDFs by Filter';

  @override
  String get invoiceMgmtByDateLabel => 'By Date';

  @override
  String get invoiceMgmtByInvoiceNumberLabel => 'By Invoice Number';

  @override
  String get invoiceMgmtFromInvoiceNumberLabel => 'From invoice #';

  @override
  String get invoiceMgmtToInvoiceNumberLabel => 'To invoice #';

  @override
  String get invoiceMgmtCheckCountLabel => 'Check count';

  @override
  String invoiceMgmtInvoicesExceedLimitMessage(int count, int limit) {
    return '$count invoices — exceeds limit of $limit';
  }

  @override
  String invoiceMgmtInvoicesMatchMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices match',
      one: '1 invoice match',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtMaxPdfsPerDownloadMessage(int limit) {
    return 'Max $limit PDFs per download. Narrow your filter.';
  }

  @override
  String get invoiceMgmtNoInvoicesForFilterMessage =>
      'No invoices found for the selected filter.';

  @override
  String invoiceMgmtFilterExceedsLimitMessage(int count, int limit) {
    return 'Filter returned $count invoices — max is $limit.';
  }

  @override
  String get invoiceMgmtFilterInvoicesTitle => 'Filter Invoices';

  @override
  String get invoiceMgmtHideFullyPaidLabel => 'Hide fully paid invoices';

  @override
  String get invoiceMgmtHideDeclinedLabel => 'Hide declined invoices';

  @override
  String get invoiceMgmtPaymentStatusLabel => 'Payment status';

  @override
  String get invoiceMgmtDueDateLabel => 'Due date';

  @override
  String get invoiceMgmtInvoiceDateRangeLabel => 'Invoice date range';

  @override
  String get invoiceMgmtInvoiceNumberRangeLabel => 'Invoice # range';

  @override
  String get invoiceMgmtFromHashLabel => 'From #';

  @override
  String get invoiceMgmtToHashLabel => 'To #';

  @override
  String get actionReset => 'રીસેટ';

  @override
  String get actionApply => 'લાગુ કરો';

  @override
  String get invoiceMgmtSortByTitle => 'Sort By';

  @override
  String get invoiceMgmtSearchHintMessage =>
      'Search by Invoice ID or Customer Name…';

  @override
  String get invoiceMgmtFilterLabel => 'Filter';

  @override
  String get invoiceMgmtSortLabel => 'Sort';

  @override
  String invoiceMgmtTotalPageStatusLabel(int total, int page, int totalPages) {
    return 'Total: $total   ·   Page $page/$totalPages';
  }

  @override
  String invoiceMgmtSelectedCountLabel(int count) {
    return '$count selected';
  }

  @override
  String get invoiceMgmtDeselectLabel => 'Deselect';

  @override
  String get invoiceMgmtSelectPageLabel => 'Select Page';

  @override
  String get invoiceMgmtMarkPaidLabel => 'Mark Paid';

  @override
  String get invoiceMgmtCsvLabel => 'CSV';

  @override
  String get invoiceMgmtPdfsLabel => 'PDFs';

  @override
  String get invoiceMgmtTrashLabel => 'Trash';

  @override
  String get actionApplyPayment => 'ચુકવણી લાગુ કરો';

  @override
  String get invoiceMgmtMoreActionsTooltip => 'More actions';

  @override
  String get invoiceMgmtColSlNo => 'Sl No';

  @override
  String get invoiceMgmtColInvoiceCustomer => 'Invoice / Customer';

  @override
  String get invoiceMgmtColTitle => 'Title';

  @override
  String get invoiceMgmtColDate => 'Date';

  @override
  String get invoiceMgmtColItems => 'Items';

  @override
  String get invoiceMgmtColStatus => 'Status';

  @override
  String get invoiceMgmtColOutstanding => 'Outstanding';

  @override
  String get invoiceMgmtColActions => 'Actions';

  @override
  String get invoiceMgmtRowsPerPageLabel => 'Rows per page:';

  @override
  String get actionPrevious => 'પાછલું';

  @override
  String invoiceMgmtPageOfLabel(int page, int totalPages) {
    return 'Page $page of $totalPages';
  }

  @override
  String invoiceMgmtNoResultsForQueryMessage(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String invoiceMgmtNoFilteredTypeFoundMessage(String type) {
    return 'No $type found';
  }

  @override
  String invoiceMgmtCreateFirstTypeMessage(String type) {
    return 'Create your first $type to see it here';
  }

  @override
  String get invoiceMgmtTryAdjustingFiltersMessage =>
      'Try adjusting your search or filters';

  @override
  String get invoiceMgmtDownloadByRangeTooltip =>
      'Download PDFs by date or invoice range';

  @override
  String get invoiceMgmtExportAllCsvTooltip => 'Export all to CSV';

  @override
  String get invoiceMgmtDownloadByRangeMenuLabel => 'Download PDFs by range';

  @override
  String invoiceMgmtManagementTitle(String type) {
    return '$type Management';
  }

  @override
  String invoiceMgmtNewDocumentButton(String type) {
    return 'New $type';
  }

  @override
  String get invoiceMgmtConvertToInvoiceAction => 'Convert to Invoice';

  @override
  String get invoiceMgmtConvertAgainTitle => 'Convert again?';

  @override
  String invoiceMgmtConvertAgainBody(String number) {
    return 'Quotation $number was already converted to an invoice. Create another invoice from it?';
  }

  @override
  String get invoiceMgmtMarkAsSent => 'Mark as sent';

  @override
  String get invoiceMgmtMarkAsAccepted => 'Mark as accepted';

  @override
  String get invoiceMgmtMarkAsDeclined => 'Mark as declined';

  @override
  String get quotationStatusDraft => 'Draft';

  @override
  String get quotationStatusSent => 'Sent';

  @override
  String get quotationStatusAccepted => 'Accepted';

  @override
  String get quotationStatusDeclined => 'Declined';

  @override
  String get quotationStatusConverted => 'Converted';

  @override
  String get invoiceMgmtDeclineInvoiceTitle => 'Cancel / void this sale?';

  @override
  String invoiceMgmtDeclineInvoiceBody(String number) {
    return '#$number will be marked as declined. It stays in the list but no longer counts in reports or balances. This can\'t be undone.';
  }

  @override
  String invoiceMgmtDeclineHasPaymentsMessage(String number) {
    return 'Invoice #$number has payments recorded. Delete them in Apply Payment before declining.';
  }

  @override
  String get invoiceMgmtDeclinedSuccessMessage =>
      'Sale cancelled (void), stock returned.';

  @override
  String get invoiceStatusDeclinedBadge => 'Declined';

  @override
  String get createInvoiceConvertTitle => 'Convert to Invoice';

  @override
  String createInvoiceConvertedSuccessMessage(String invoiceNumber) {
    return 'Converted to Invoice #$invoiceNumber';
  }

  @override
  String get createInvoiceTrashQuotationAction => 'Trash quote';

  @override
  String get createInvoiceQuotationTrashedMessage => 'Quotation moved to trash';

  @override
  String get invoiceMgmtOverdueBadge => 'Overdue';

  @override
  String get invoiceMgmtTodayBadge => 'Today';

  @override
  String get invoiceMgmtTrashIsEmptyLabel => 'Trash is empty';

  @override
  String get actionRestore => 'પુનઃસ્થાપિત કરો';

  @override
  String get invoiceMgmtPermanentlyDeleteTitle => 'Permanently Delete';

  @override
  String invoiceMgmtPermanentlyDeleteBody(String number) {
    return 'Permanently delete Invoice #$number? This cannot be undone.';
  }

  @override
  String get invoiceMgmtInvoiceRestoredMessage => 'Invoice restored.';

  @override
  String get invoiceMgmtAnyDateLabel => 'Any';

  @override
  String get invoiceMgmtStatusAllLabel => 'All';

  @override
  String get invoiceMgmtDueAllLabel => 'All Dues';

  @override
  String get invoiceMgmtDueTodayLabel => 'Due Today';

  @override
  String get invoiceMgmtDueWeekLabel => 'Due This Week';

  @override
  String get invoiceMgmtDueMonthLabel => 'Due This Month';

  @override
  String get invoiceMgmtSortRecentlyAdded => 'Recently Added';

  @override
  String get invoiceMgmtSortOldestAdded => 'Oldest Added';

  @override
  String get invoiceMgmtSortDateNewest => 'Invoice Date (Newest First)';

  @override
  String get invoiceMgmtSortDateOldest => 'Invoice Date (Oldest First)';

  @override
  String get invoiceMgmtSortCustomerAZ => 'Customer Name (A–Z)';

  @override
  String get invoiceMgmtSortCustomerZA => 'Customer Name (Z–A)';

  @override
  String get invoiceMgmtMarkAsPaidTitle => 'Mark as Paid';

  @override
  String invoiceMgmtMarkAsPaidBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mark $count invoices as fully paid?',
      one: 'Mark 1 invoice as fully paid?',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtAlreadyPaidNoteMessage(int count) {
    return '\n($count already paid — will be skipped)';
  }

  @override
  String get invoiceMgmtAllAlreadyPaidMessage =>
      'All selected invoices are already fully paid.';

  @override
  String invoiceMgmtMarkedAsPaidMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices marked as paid.',
      one: '1 invoice marked as paid.',
    );
    return '$_temp0';
  }

  @override
  String invoiceMgmtMarkAsPaidFailedMessage(String error) {
    return 'Failed to mark as paid: $error';
  }

  @override
  String get fieldNameLabel => 'Name';

  @override
  String get customerMgmtEditCustomerTitle => 'Edit Customer';

  @override
  String get customerMgmtViewCustomerTitle => 'View Customer';

  @override
  String fieldTaxVatNumberLabel(String taxWord) {
    return '$taxWord / VAT Number';
  }

  @override
  String get customerMgmtUpdatedMessage => 'Customer updated successfully!';

  @override
  String fieldRequiredMessage(String field) {
    return 'Please enter $field';
  }

  @override
  String get customerMgmtConfirmDeleteTitle => 'Confirm Delete';

  @override
  String customerMgmtDeleteConfirmBody(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get customerMgmtDeletedMessage => 'Customer deleted successfully!';

  @override
  String get customerMgmtSaveSampleCsvDialogTitle => 'Save Sample CSV';

  @override
  String get customerMgmtSampleSavedMessage => 'Sample CSV saved successfully!';

  @override
  String customerMgmtErrorSavingSampleMessage(String error) {
    return 'Error saving sample: $error';
  }

  @override
  String get customerMgmtImportCsvDialogTitle => 'Import Customers from CSV';

  @override
  String get customerMgmtCsvFormatInstructionMessage =>
      'Your CSV file must use the following column headers (exact spelling, any order):';

  @override
  String get customerMgmtCsvColColumnHeader => 'Column';

  @override
  String get customerMgmtCsvColRequiredHeader => 'Required';

  @override
  String get customerMgmtCsvColDescriptionHeader => 'Description';

  @override
  String get commonYesLabel => 'Yes';

  @override
  String get commonNoLabel => 'No';

  @override
  String get customerMgmtCsvDescName => 'Customer full name';

  @override
  String get customerMgmtCsvDescEmail => 'Email address';

  @override
  String get customerMgmtCsvDescPhone => 'Phone number';

  @override
  String get customerMgmtCsvDescAddress => 'Full address';

  @override
  String get customerMgmtCsvDescBusinessName => 'Company / business name';

  @override
  String get customerMgmtCsvDescTaxNumber => 'Tax / VAT / GSTIN number';

  @override
  String customerMgmtCsvMaxRowsNote(int max) {
    return 'Maximum $max rows per import.';
  }

  @override
  String get customerMgmtCsvDuplicatesNote =>
      'Duplicates are detected by email or phone. You will be asked to overwrite or skip each one.';

  @override
  String get customerMgmtCsvMissingNameNote =>
      'Rows missing a name are skipped and reported at the end.';

  @override
  String get customerMgmtCsvEncodingNote =>
      'UTF-8 encoding recommended. Excel BOM is handled automatically.';

  @override
  String get customerMgmtDownloadSampleCsvButton => 'Download Sample CSV';

  @override
  String get customerMgmtChooseFileButton => 'Choose File';

  @override
  String get customerMgmtSelectCsvDialogTitle => 'Select Customer CSV';

  @override
  String get customerMgmtCsvEmptyMessage => 'CSV file is empty.';

  @override
  String get customerMgmtCsvMissingNameColumnMessage =>
      'CSV missing required column: \"name\"';

  @override
  String customerMgmtUnknownColumnMessage(String col, String expected) {
    return 'Unknown column \"$col\". Expected: $expected';
  }

  @override
  String customerMgmtCsvTooManyRowsMessage(int count, int max) {
    return 'CSV has $count rows. Maximum is $max. Please split the file.';
  }

  @override
  String get customerMgmtImportingTitle => 'Importing Customers';

  @override
  String customerMgmtValidatingRowsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Checking for duplicates and validating $count rows...',
      one: 'Checking for duplicates and validating 1 row...',
    );
    return '$_temp0';
  }

  @override
  String customerMgmtRowMissingNameMessage(int n) {
    return 'Row $n: missing name — skipped';
  }

  @override
  String customerMgmtCsvReadErrorMessage(String error) {
    return 'Error reading CSV: $error';
  }

  @override
  String get customerMgmtImportPreviewTitle => 'Import Preview';

  @override
  String customerMgmtNewCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '1 new',
    );
    return '$_temp0';
  }

  @override
  String customerMgmtDuplicatesCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates',
      one: '1 duplicate',
    );
    return '$_temp0';
  }

  @override
  String customerMgmtErrorsCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors',
      one: '1 error',
    );
    return '$_temp0';
  }

  @override
  String get customerMgmtDuplicatesMatchedLabel =>
      'Duplicates (matched by email or phone):';

  @override
  String get customerMgmtOverwriteAllButton => 'Overwrite All';

  @override
  String get customerMgmtSkipAllButton => 'Skip All';

  @override
  String get customerMgmtOverwriteLabel => 'Overwrite';

  @override
  String get customerMgmtSkippedRowsLabel => 'Skipped rows (errors):';

  @override
  String customerMgmtErrorBulletLabel(String error) {
    return '• $error';
  }

  @override
  String customerMgmtWillImportMessage(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Will import $total customers.',
      one: 'Will import 1 customer.',
    );
    return '$_temp0';
  }

  @override
  String customerMgmtImportCountButton(int total) {
    return 'Import $total';
  }

  @override
  String get customerMgmtDeleteAllTitle => 'Delete All Customers';

  @override
  String get customerMgmtNoCustomersToDeleteMessage =>
      'No customers to delete.';

  @override
  String customerMgmtDeleteAllBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This will permanently delete all $count customers. Existing invoices are not affected. This cannot be undone.',
      one:
          'This will permanently delete all 1 customer. Existing invoices are not affected. This cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String get customerMgmtDeleteAllButton => 'Delete All';

  @override
  String get customerMgmtAllDeletedMessage => 'All customers deleted.';

  @override
  String customerMgmtDeleteAllErrorMessage(String error) {
    return 'Error deleting customers: $error';
  }

  @override
  String get customerMgmtSaveCsvDialogTitle => 'Save Customer CSV';

  @override
  String get customerMgmtCsvExportedMessage => 'CSV exported successfully!';

  @override
  String customerMgmtCsvExportErrorMessage(String error) {
    return 'Error exporting CSV: $error';
  }

  @override
  String get customerMgmtSavePdfDialogTitle => 'Save Customer PDF';

  @override
  String get customerMgmtPdfExportedMessage => 'PDF exported successfully!';

  @override
  String customerMgmtPdfExportErrorMessage(String error) {
    return 'Error exporting PDF: $error';
  }

  @override
  String get customerMgmtTotalCustomersLabel => 'Total Customers';

  @override
  String get customerMgmtAllCustomersSubtitle => 'All customers';

  @override
  String get customerMgmtBusinessesLabel => 'Businesses';

  @override
  String get customerMgmtRegisteredBusinessesSubtitle =>
      'Registered businesses';

  @override
  String get customerMgmtIndividualsLabel => 'Individuals';

  @override
  String get customerMgmtIndividualCustomersSubtitle => 'Individual customers';

  @override
  String customerMgmtTaxRegisteredLabel(String taxWord) {
    return '$taxWord Registered';
  }

  @override
  String customerMgmtWithTaxNumberSubtitle(String taxWord) {
    return 'With $taxWord number';
  }

  @override
  String customerMgmtWithoutTaxLabel(String taxWord) {
    return 'Without $taxWord';
  }

  @override
  String get customerMgmtTitle => 'Customer Management';

  @override
  String get customerMgmtSubtitle =>
      'Manage your customers and contact details';

  @override
  String get actionImport => 'આયાત';

  @override
  String get customerMgmtExportPdfMenuLabel => 'Export PDF';

  @override
  String get customerMgmtNewCustomerButton => 'New Customer';

  @override
  String get customerMgmtSortNameAZ => 'Name A-Z';

  @override
  String get customerMgmtSortNameZA => 'Name Z-A';

  @override
  String get customerMgmtSortIdOldest => 'ID (oldest first)';

  @override
  String get customerMgmtSortIdNewest => 'ID (newest first)';

  @override
  String get customerMgmtSortOutstandingHighLow => 'Outstanding (high-low)';

  @override
  String get customerMgmtSortOutstandingLowHigh => 'Outstanding (low-high)';

  @override
  String get customerMgmtWithOutstandingLabel => 'With Outstanding';

  @override
  String customerMgmtSearchHint(String taxWord) {
    return 'Search customers by name, business, phone, $taxWord, email…';
  }

  @override
  String customerMgmtAllTaxStatusesLabel(String taxWord) {
    return 'All $taxWord statuses';
  }

  @override
  String customerMgmtTaxRegisteredLowerLabel(String taxWord) {
    return '$taxWord registered';
  }

  @override
  String customerMgmtSortWithLabel(String label) {
    return 'Sort: $label';
  }

  @override
  String get customerMgmtColumnsLabel => 'Columns';

  @override
  String customerMgmtTaxVatNoColumnLabel(String taxWord) {
    return '$taxWord / VAT No';
  }

  @override
  String get customerMgmtHideStatCardsTooltip => 'Hide stat cards';

  @override
  String get customerMgmtShowStatCardsTooltip => 'Show stat cards';

  @override
  String customerMgmtTabChipLabel(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get customerMgmtColSlNo => 'SL. NO.';

  @override
  String get customerMgmtColNameBusiness => 'NAME / BUSINESS';

  @override
  String get customerMgmtColPhone => 'PHONE';

  @override
  String get customerMgmtColEmail => 'EMAIL';

  @override
  String customerMgmtColTaxVatNo(String taxWord) {
    return '$taxWord / VAT NO';
  }

  @override
  String get customerMgmtColAddress => 'ADDRESS';

  @override
  String get customerMgmtColActions => 'ACTIONS';

  @override
  String get customerMgmtViewStatementTooltip => 'View Statement (in Reports)';

  @override
  String customerMgmtShowingRangeLabel(int from, int to, int total) {
    return 'Showing $from to $to of $total customers';
  }

  @override
  String get customerMgmtRowsPerPageLabel => 'Rows per page';

  @override
  String customerMgmtOfTotalPagesLabel(int totalPages) {
    return 'of $totalPages';
  }

  @override
  String get customerMgmtAddAnotherLabel => 'Add another after saving';

  @override
  String get customerMgmtSaveCustomerButton => 'Save Customer';

  @override
  String get customerMgmtAddFirstCustomerSubtitle =>
      'Add your first customer to get started';

  @override
  String get customerMgmtTryAdjustingSearchSubtitle =>
      'Try adjusting your search';

  @override
  String customerMgmtLoadErrorMessage(String error) {
    return 'Error loading customers: $error';
  }

  @override
  String get customerMgmtAddedMessage => 'Customer added successfully!';

  @override
  String customerMgmtSaveErrorMessage(String error) {
    return 'Error saving customer: $error';
  }

  @override
  String customerMgmtImportedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count customers successfully!',
      one: 'Imported 1 customer successfully!',
    );
    return '$_temp0';
  }

  @override
  String customerMgmtImportErrorMessage(String error) {
    return 'Import error: $error';
  }

  @override
  String get taxWordGst => 'GST';

  @override
  String get taxWordTax => 'Tax';

  @override
  String get commonMoreLabel => 'More';

  @override
  String get productMgmtSellingAtLossTitle => 'Selling at a loss';

  @override
  String productMgmtSellingAtLossMessage(String purchase, String sale) {
    return 'Purchase price ($purchase) is higher than sale price ($sale). Save anyway?';
  }

  @override
  String get actionSaveAnyway => 'છતાં સાચવો';

  @override
  String get productMgmtAdvancedInformationLabel => 'Advanced Information';

  @override
  String get productMgmtStorageLocationLabel => 'Storage Location';

  @override
  String get productMgmtContainerNumberLabel => 'Container Number';

  @override
  String get productMgmtBatchNumberLabel => 'Batch Number';

  @override
  String get productMgmtExpiryDateLabel => 'Expiry Date';

  @override
  String get productMgmtManufactureDateLabel => 'Manufacture Date';

  @override
  String get productMgmtManufactureNameLabel => 'Manufacturer Name';

  @override
  String get productMgmtSupplierNameLabel => 'Supplier Name';

  @override
  String get productMgmtSkuCodeLabel => 'SKU Code';

  @override
  String get productMgmtNotesLabel => 'Notes';

  @override
  String get fieldEnterValidPriceMessage => 'Enter valid price';

  @override
  String get fieldEnterValidStockMessage => 'Enter valid stock';

  @override
  String get fieldTaxRangeMessage => 'Tax must be between 0-100';

  @override
  String get productMgmtImportProductsCsvTitle => 'Import Products from CSV';

  @override
  String get productMgmtCsvDescName => 'Product name';

  @override
  String get productMgmtCsvDescPrice => 'Unit price (numeric)';

  @override
  String get productMgmtCsvDescHsnCode => 'HSN / SAC code';

  @override
  String get productMgmtCsvDescDescription => 'Short description';

  @override
  String get productMgmtCsvDescTaxRate => 'Tax % (0–100), default 0';

  @override
  String get productMgmtCsvDescStock => 'Stock quantity, default 0';

  @override
  String get productMgmtCsvDescType =>
      '\"product\" or \"service\", default product';

  @override
  String get productMgmtCsvDescDefaultDiscount =>
      'Flat discount amount (currency), default 0';

  @override
  String get productMgmtCsvDescPurchasePrice =>
      'Cost price (numeric), default 0';

  @override
  String get productMgmtCsvDescAliasName =>
      'Local-language display name for PDFs';

  @override
  String get productMgmtCsvDescUnit =>
      'Unit of measure (e.g. kg, bag, pcs), default pcs';

  @override
  String get productMgmtCsvDescUnlimitedStock =>
      '1/true for unlimited stock, default 0';

  @override
  String get productMgmtCsvDescPriceIncludesTax =>
      '1/true if price already includes tax, default 0';

  @override
  String get productMgmtCsvDescLowStockLimit =>
      'Low-stock threshold for this product, blank = default 10';

  @override
  String get productMgmtCsvDescStorageLocation => 'Warehouse/shelf location';

  @override
  String get productMgmtCsvDescContainerNumber => 'Container/box number';

  @override
  String get productMgmtCsvDescBatchNumber => 'Batch/lot number';

  @override
  String get productMgmtCsvDescExpiryDate => 'Expiry date';

  @override
  String get productMgmtCsvDescManufactureDate => 'Manufacture date';

  @override
  String get productMgmtCsvDescManufactureName => 'Manufacturer name';

  @override
  String get productMgmtCsvDescSupplierName => 'Supplier name';

  @override
  String get productMgmtCsvDescSkuCode => 'SKU code';

  @override
  String get productMgmtCsvDescNotes => 'Free-text notes';

  @override
  String get productMgmtCsvDuplicateNote =>
      'Duplicates are detected by product name (case-insensitive). You will be asked to overwrite or skip each one.';

  @override
  String get productMgmtCsvMissingRequiredNote =>
      'Rows missing name or price are skipped and reported.';

  @override
  String get productMgmtSelectCsvDialogTitle => 'Select Product CSV';

  @override
  String get productMgmtCsvMissingPriceColumnMessage =>
      'CSV missing required column: \"price\"';

  @override
  String productMgmtRowInvalidPriceMessage(int n, String price) {
    return 'Row $n: invalid price \"$price\" — skipped';
  }

  @override
  String get productMgmtImportingTitle => 'Importing Products';

  @override
  String get productMgmtDuplicatesMatchedByNameLabel =>
      'Duplicates (matched by name):';

  @override
  String productMgmtWillImportMessage(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Will import $total products.',
      one: 'Will import 1 product.',
    );
    return '$_temp0';
  }

  @override
  String get productMgmtNoProductsToDeleteMessage => 'No products to delete.';

  @override
  String get productMgmtDeleteAllTitle => 'Delete All Products';

  @override
  String productMgmtDeleteAllBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This will permanently delete all $count products. Existing invoices are not affected. This cannot be undone.',
      one:
          'This will permanently delete all 1 product. Existing invoices are not affected. This cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String get productMgmtAllDeletedMessage => 'All products deleted.';

  @override
  String productMgmtDeleteAllErrorMessage(String error) {
    return 'Error deleting products: $error';
  }

  @override
  String get productMgmtSaveProductsCsvDialogTitle => 'Save Products CSV';

  @override
  String get productMgmtExportToPdfTitle => 'Export to PDF';

  @override
  String productMgmtExportPdfChoiceMessage(int pageSize, int allCount) {
    return 'Export the current page ($pageSize products) or all $allCount products?';
  }

  @override
  String get productMgmtCurrentPageLabel => 'Current Page';

  @override
  String get productMgmtAllProductsLabel => 'All Products';

  @override
  String get productMgmtSaveProductsPdfDialogTitle => 'Save Products PDF';

  @override
  String get productMgmtTitle => 'Product Management';

  @override
  String get productMgmtSubtitle => 'Manage your products and services';

  @override
  String get productMgmtNewProductButton => 'New Product';

  @override
  String get productMgmtSearchHint => 'નામ, ક્વિક કોડ, ઉપનામ, HSN/SAC થી શોધો…';

  @override
  String get productMgmtFilterByStockStatusTooltip => 'Filter by stock status';

  @override
  String get productMgmtAllStockLevelsLabel => 'All stock levels';

  @override
  String get productMgmtLowStockLabel => 'Low stock';

  @override
  String get productMgmtLowStockTabLabel => 'Low Stock';

  @override
  String get productMgmtOutOfStockLabel => 'Out of stock';

  @override
  String get productMgmtOutOfStockTabLabel => 'Out of Stock';

  @override
  String get productMgmtExpiredLabel => 'Expired';

  @override
  String get productMgmtSortPriceLowHigh => 'Price Low-High';

  @override
  String get productMgmtSortPriceHighLow => 'Price High-Low';

  @override
  String get productMgmtSortStockLowHigh => 'Stock Low-High';

  @override
  String get productMgmtSortStockHighLow => 'Stock High-Low';

  @override
  String get productMgmtServicesTabLabel => 'Services';

  @override
  String get productMgmtColSlNo => 'SL. NO.';

  @override
  String get productMgmtColNameAlias => 'NAME / ALIAS';

  @override
  String get productMgmtColHsnSac => 'HSN / SAC';

  @override
  String get productMgmtColPrice => 'PRICE';

  @override
  String get productMgmtColPurchase => 'PURCHASE';

  @override
  String get productMgmtColStock => 'STOCK';

  @override
  String get productMgmtColTaxPercent => 'TAX %';

  @override
  String get productMgmtColExpiryDate => 'EXPIRY DATE';

  @override
  String get productMgmtCustomizeColumnsLabel => 'Customize Product Columns';

  @override
  String get productMgmtShowColumnsLabel => 'Show Columns';

  @override
  String productMgmtShowColumnsMaxHint(int max) {
    return 'Show up to $max columns';
  }

  @override
  String productMgmtShowingRangeLabel(int from, int to, int total) {
    return 'Showing $from to $to of $total products';
  }

  @override
  String get productMgmtAddFirstProductSubtitle =>
      'Add your first product to get started';

  @override
  String get productMgmtColumnsBannerTitle => 'New: Customize product fields';

  @override
  String get productMgmtColumnsBannerSubtitle =>
      'Choose which fields show for a simpler catalog. Settings > Customize Product Details.';

  @override
  String get productMgmtConfigureAction => 'Configure';

  @override
  String productMgmtAddNewItemTitle(String type) {
    return 'Add New $type';
  }

  @override
  String get productMgmtEnterProductDetailsSubtitle => 'Enter product details';

  @override
  String get productMgmtSaveProductButton => 'Save Product';

  @override
  String get productMgmtAliasNameLabel => 'Alias Name (for invoice PDF)';

  @override
  String get productMgmtAliasHelperText =>
      'Optional local-language display name used only on PDF invoices.';

  @override
  String get productMgmtDescriptionLabel => 'Description';

  @override
  String get productMgmtHsnSacLabel => 'HSN/SAC';

  @override
  String get productMgmtSalePriceLabel => 'Sale Price';

  @override
  String get productMgmtPurchasePriceLabel => 'Purchase Price';

  @override
  String get productMgmtDefaultDiscountLabel => 'Default Discount';

  @override
  String get productMgmtTaxPercentLabel => 'Tax (%)';

  @override
  String get productMgmtPerItemTaxModeOnlyLabel => 'Per-item tax mode only';

  @override
  String get productMgmtSectionGeneral => 'General';

  @override
  String get productMgmtSectionPricing => 'Pricing';

  @override
  String get productMgmtSectionInventory => 'Inventory';

  @override
  String get productMgmtUnlimitedStockLabel => 'Unlimited stock';

  @override
  String get productMgmtTrackInfiniteStockSubtitle =>
      'Track infinite stock for this product';

  @override
  String get productMgmtLowStockLimitLabel => 'Low-stock limit';

  @override
  String get productMgmtLowStockLimitHelper =>
      'Shown in Low Stock when stock is at or below this number. Leave blank for the default (10).';

  @override
  String get productMgmtTipEnableCustomFieldsMessage =>
      'Tip: Enable custom fields from Columns to add more details.';

  @override
  String get productMgmtEditProductTitle => 'Edit Product';

  @override
  String get productMgmtViewProductTitle => 'View Product';

  @override
  String get productMgmtUpdateProductDetailsSubtitle =>
      'Update product details';

  @override
  String get productMgmtProductDetailsSubtitle => 'Product details';

  @override
  String get productMgmtUpdatedMessage =>
      'Product/Service updated successfully!';

  @override
  String get productMgmtDeleteProductButton => 'Delete Product';

  @override
  String get productMgmtSaveChangesButton => 'Save Changes';

  @override
  String get fieldUnitLabel => 'Unit';

  @override
  String get productMgmtAddedMessage => 'Product added successfully!';

  @override
  String productMgmtAddErrorMessage(String error) {
    return 'Error adding product: $error';
  }

  @override
  String productMgmtLoadErrorMessage(String error) {
    return 'Error loading products: $error';
  }

  @override
  String get productMgmtDeletedMessage => 'Product deleted successfully!';

  @override
  String productMgmtImportedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count products successfully!',
      one: 'Imported 1 product successfully!',
    );
    return '$_temp0';
  }

  @override
  String get productMgmtTotalItemsSubtitle => 'Total items';

  @override
  String get productMgmtTangibleProductsSubtitle => 'Tangible products';

  @override
  String get productMgmtNonTangibleServicesSubtitle => 'Non-tangible services';

  @override
  String get productMgmtNeedAttentionSubtitle => 'Need attention';

  @override
  String get productMgmtProductNameLabel => 'Product Name';

  @override
  String get productMgmtPriceLabel => 'Price';

  @override
  String get actionClear => 'સાફ કરો';

  @override
  String get reportsAboutConversionRateTitle => 'About Conversion Rate';

  @override
  String reportsAgedReceivablesTitle(int count) {
    return 'Aged Receivables ($count)';
  }

  @override
  String get reportsAllCurrenciesLabel => 'All currencies';

  @override
  String get reportsArAgingSummaryTitle => 'A/R Aging Summary';

  @override
  String get reportsAvgInvoiceValueLabel => 'Avg Invoice Value';

  @override
  String get reportsBalanceColumnLabel => 'Balance';

  @override
  String get reportsBilledLabel => 'Billed';

  @override
  String get reportsBucket0to30Label => '0–30 days';

  @override
  String get reportsBucket31to60Label => '31–60 days';

  @override
  String get reportsBucket61to90Label => '61–90 days';

  @override
  String get reportsBucket90PlusLabel => '90+ days';

  @override
  String get reportsBucketLabel => 'Bucket';

  @override
  String get reportsClosingLabel => 'Closing';

  @override
  String get reportsCogsColumnLabel => 'COGS';

  @override
  String get reportsConversionRateExplanationBody =>
      'Conversion rate = Invoices created ÷ Quotations issued × 100.\nA rate above 100% means more invoices were raised than quotations in the selected period (common when invoices are created directly without a prior quotation).\n\nNote: this is a period-level ratio, not individual quote-to-invoice tracking.';

  @override
  String get reportsConversionRateLabel => 'Conversion Rate';

  @override
  String get reportsCreditColumnLabel => 'Credit';

  @override
  String get reportsCurrencySectionLabel => 'CURRENCY';

  @override
  String get reportsCurrentBucketLabel => 'Current';

  @override
  String reportsCurrentSelectedCurrencyLabel(String currency) {
    return 'Current selected currency ($currency)';
  }

  @override
  String get reportsCustomRangeLabel => 'Custom Range';

  @override
  String get reportsDailySalesProfitTitle => 'Daily Sales & Profit';

  @override
  String reportsDaysCountLabel(int d) {
    return '$d days';
  }

  @override
  String get reportsDaysOverdueLabel => 'Days Overdue';

  @override
  String get reportsDebitColumnLabel => 'Debit';

  @override
  String get reportsDiscountGivenColumnLabel => 'Discount Given';

  @override
  String get reportsExportCsvLabel => 'Export CSV';

  @override
  String reportsFilteredToDateLabel(String date) {
    return 'Filtered to $date';
  }

  @override
  String reportsInvoiceCountInPeriodLabel(int count, String scope) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString invoices in period · $scope',
      one: '1 invoice in period · $scope',
    );
    return '$_temp0';
  }

  @override
  String get reportsInvoiceIdLabel => 'Invoice ID';

  @override
  String get reportsInvoicedLabel => 'Invoiced';

  @override
  String get reportsInvoicesColumnLabel => 'Invoices';

  @override
  String get reportsInvoicesInPeriodLabel => 'Invoices in Period';

  @override
  String reportsLabelWithCountLabel(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get reportsMarginColumnLabel => 'Margin';

  @override
  String get reportsMaxRangeOneYearMessage =>
      'Maximum range is 1 year. End date clamped.';

  @override
  String get reportsMaxRangeThirtyOneDaysMessage =>
      'Maximum range is 31 days. End date clamped.';

  @override
  String reportsMissingCostBannerMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count items sold in this period have no purchase price set — profit/margin is understated for those items until a purchase price is added to the product.',
      one:
          '1 item sold in this period has no purchase price set — profit/margin is understated for that item until a purchase price is added to the product.',
    );
    return '$_temp0';
  }

  @override
  String get reportsMonthYearLabel => 'Month & Year';

  @override
  String get reportsMonthlyRevenueTrendTitle => 'Monthly Revenue Trend';

  @override
  String get reportsMonthlyBreakdownTitle => 'Monthly Breakdown';

  @override
  String get reportsMonthColumnLabel => 'Month';

  @override
  String get reportsTotalRowLabel => 'Total';

  @override
  String get reportsNavDailyReportLabel => 'Daily Report';

  @override
  String get reportsNavInventoryLabel => 'Inventory';

  @override
  String get reportsNavInvoiceStatusLabel => 'Invoice Status';

  @override
  String get reportsNavReceivablesLabel => 'Receivables';

  @override
  String get reportsNavRevenueLabel => 'Revenue';

  @override
  String get reportsNavTaxLabel => 'Tax';

  @override
  String get reportsInventoryBlockedValueLabel => 'Inventory Value Blocked';

  @override
  String get reportsInventoryPotentialSaleValueLabel => 'Potential Sale Value';

  @override
  String get reportsInventoryLockedProfitLabel => 'Profit Locked in Stock';

  @override
  String get reportsInventoryTotalUnitsLabel => 'Total Units';

  @override
  String get reportsInventoryProductCountLabel => 'Products Tracked';

  @override
  String get reportsInventoryBreakdownTitle => 'Product Breakdown';

  @override
  String get reportsNoInventoryDataMessage => 'No inventory data';

  @override
  String get reportsInventoryProductColumnLabel => 'Product';

  @override
  String get reportsInventoryStockColumnLabel => 'Stock';

  @override
  String get reportsInventoryPurchasePriceColumnLabel => 'Purchase Price';

  @override
  String get reportsInventoryStockValueColumnLabel => 'Stock Value';

  @override
  String get reportsInventorySaleValueColumnLabel => 'Sale Value';

  @override
  String reportsInventoryExcludedBannerMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count items are excluded from inventory value — they\'re services or have unlimited stock tracking on.',
      one:
          '1 item is excluded from inventory value — it\'s a service or has unlimited stock tracking on.',
    );
    return '$_temp0';
  }

  @override
  String get reportsNoCustomerDataMessage => 'No customer data in this period';

  @override
  String get reportsNoCustomersMatchSearchMessage =>
      'No customers match this search';

  @override
  String get reportsNoCustomersWithInvoicesMessage =>
      'No customers with invoices';

  @override
  String get reportsNoDueDateLabel => 'No Due Date';

  @override
  String get reportsNoInvoiceDataMessage => 'No invoice data in this period';

  @override
  String get reportsNoInvoicesInPeriodMessage => 'No invoices in this period';

  @override
  String get reportsNoInvoicesMatchFilterMessage =>
      'No invoices match this filter';

  @override
  String get reportsNoOutstandingInvoicesMessage => 'No outstanding invoices';

  @override
  String get reportsNoProductDataMessage => 'No product data in this period';

  @override
  String get reportsNoSalesInPeriodMessage => 'No sales in this period';

  @override
  String get reportsNoStatementActivityMessage =>
      'No statement activity for this customer';

  @override
  String get reportsNoTaxableItemsMessage => 'No taxable items in this period';

  @override
  String get reportsNoTransactionsMessage => 'No transactions in this period';

  @override
  String get reportsOpeningLabel => 'Opening';

  @override
  String get reportsOverviewLabel => 'Overview';

  @override
  String get reportsPaymentStatusBreakdownTitle => 'Payment Status Breakdown';

  @override
  String get reportsPeriodSectionLabel => 'PERIOD';

  @override
  String get reportsPresetLast30DaysLabel => 'Last 30 days';

  @override
  String get reportsPresetLast3MonthsLabel => 'Last 3 months';

  @override
  String get reportsPresetLast6MonthsLabel => 'Last 6 months';

  @override
  String get reportsPresetLastFYLabel => 'Last FY';

  @override
  String get reportsPresetThisFYLabel => 'This FY';

  @override
  String get reportsPresetThisYearLabel => 'This year';

  @override
  String get reportsProductServiceColumnLabel => 'Product / Service';

  @override
  String get reportsProfitLabel => 'Profit';

  @override
  String get reportsQuotationsIssuedLabel => 'Quotations Issued';

  @override
  String get reportsRankByProfitLabel => 'Rank: Profit';

  @override
  String get reportsRankByRevenueLabel => 'Rank: Revenue';

  @override
  String get reportsReferenceColumnLabel => 'Reference';

  @override
  String get reportsSalesColumnLabel => 'Sales';

  @override
  String get reportsSaveCsvReportTitle => 'Save CSV Report';

  @override
  String get reportsSavePdfReportTitle => 'Save PDF Report';

  @override
  String reportsSavedAtMessage(String path) {
    return 'Saved: $path';
  }

  @override
  String get reportsSelectCustomerTitle => 'Select customer';

  @override
  String get reportsSelectDailyRangeMaxDaysHelpText =>
      'Select date or date range (max 31 days)';

  @override
  String get reportsSelectDateRangeMaxYearHelpText =>
      'Select date range (max 1 year)';

  @override
  String get reportsShareLabel => 'Share';

  @override
  String reportsShowingInvoicesDatedLabel(String range) {
    return 'Showing invoices dated $range';
  }

  @override
  String reportsShowingRangeLabel(int start, int end, int total) {
    return '$start – $end of $total';
  }

  @override
  String get reportsSlColumnLabel => 'SL';

  @override
  String get reportsStatementsLabel => 'Statements';

  @override
  String get reportsTaxCollectedByRateTitle => 'Tax by Rate';

  @override
  String get reportsTaxCollectedLabel => 'Tax';

  @override
  String get reportsTaxableAmountLabel => 'Taxable Amount';

  @override
  String get reportsGrossAmountLabel => 'Gross';

  @override
  String get reportsTaxAccrualNote =>
      'Tax charged on invoices dated in this period — accrual basis, before payment.';

  @override
  String get reportsTaxRateBucketsLabel => 'Tax Rate Buckets';

  @override
  String get reportsTodayLabel => 'Today';

  @override
  String reportsTopCustomersByRevenueTitle(int count) {
    return 'Top $count Customers by Revenue';
  }

  @override
  String reportsTopProductsByMetricTitle(int count, String metric) {
    return 'Top $count Products / Services by $metric';
  }

  @override
  String get reportsTotalBilledLabel => 'Total Billed';

  @override
  String get reportsTotalCollectedLabel => 'Total Collected';

  @override
  String reportsTotalInvoicesCountLabel(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString total invoices',
      one: '1 total invoice',
    );
    return '$_temp0';
  }

  @override
  String get reportsTotalInvoicesLabel => 'Total Invoices';

  @override
  String get reportsRealizedProfitLabel => 'Realized Profit';

  @override
  String get reportsTotalProfitLabel => 'Total Profit';

  @override
  String get reportsTotalTaxCollectedLabel => 'Total Tax Charged';

  @override
  String get reportsTypeColumnLabel => 'Type';

  @override
  String get reportsUnitsSoldColumnLabel => 'Units Sold';

  @override
  String userMgmtLoadErrorMessage(String error) {
    return 'Error loading users: $error';
  }

  @override
  String get userMgmtAddedMessage => 'User added successfully';

  @override
  String get userMgmtUpdatedMessage => 'User updated successfully';

  @override
  String userMgmtSaveErrorMessage(String error) {
    return 'Error saving user: $error';
  }

  @override
  String get userMgmtChangePasswordTitle => 'Change Password';

  @override
  String userMgmtUserColonLabel(String username) {
    return 'User: $username';
  }

  @override
  String get userMgmtCurrentPasswordLabel => 'Current Password';

  @override
  String get userMgmtCurrentPasswordRequiredMessage =>
      'Current password is required';

  @override
  String get userMgmtNewPasswordLabel => 'New Password';

  @override
  String get userMgmtNewPasswordRequiredMessage => 'New password is required';

  @override
  String get userMgmtPasswordMinLengthMessage =>
      'Password must be at least 6 characters';

  @override
  String get userMgmtConfirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get userMgmtConfirmPasswordRequiredMessage =>
      'Please confirm your password';

  @override
  String get userMgmtPasswordsDoNotMatchMessage => 'Passwords do not match';

  @override
  String get userMgmtPasswordChangedMessage => 'Password changed successfully';

  @override
  String get userMgmtCurrentPasswordIncorrectMessage =>
      'Current password is incorrect';

  @override
  String get userMgmtDeleteUserTitle => 'Delete User';

  @override
  String get userMgmtDeleteUserConfirmLabel =>
      'Are you sure you want to delete user:';

  @override
  String get userMgmtActionCannotBeUndoneMessage =>
      'This action cannot be undone.';

  @override
  String get userMgmtDeletedMessage => 'User deleted successfully';

  @override
  String get userMgmtCantDeleteOwnAccountMessage =>
      'You can\'t delete your own account';

  @override
  String get userMgmtCantDemoteLastAdminMessage =>
      'You can\'t change the role of the only admin';

  @override
  String get userMgmtCantChangeOwnRoleMessage =>
      'You can\'t change your own role';

  @override
  String get userMgmtUsernameTakenMessage => 'That username is already taken';

  @override
  String get userMgmtDeleteSelectedTitle => 'Delete selected users?';

  @override
  String userMgmtBulkDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This will permanently delete $count users. This action cannot be undone.',
      one: 'This will permanently delete 1 user. This action cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String get userMgmtOwnAccountSkippedMessage =>
      'Your own account was in the selection but will be skipped.';

  @override
  String userMgmtBulkDeletedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users deleted',
      one: '1 user deleted',
    );
    return '$_temp0';
  }

  @override
  String userMgmtBulkDeleteErrorMessage(String error) {
    return 'Error deleting users: $error';
  }

  @override
  String get userMgmtTitle => 'User Management';

  @override
  String get userMgmtSubtitle =>
      'Manage application users and access permissions';

  @override
  String get userMgmtAddUserButton => 'Add User';

  @override
  String get userMgmtSearchHint => 'Search users by name or role…';

  @override
  String get userMgmtFilterByRoleTooltip => 'Filter by role';

  @override
  String get userMgmtAllRolesLabel => 'All roles';

  @override
  String get userMgmtAllLabel => 'All';

  @override
  String userMgmtRoleColonLabel(String role) {
    return 'Role: $role';
  }

  @override
  String get userMgmtColUser => 'USER';

  @override
  String get userMgmtColRole => 'ROLE';

  @override
  String get userMgmtYouBadgeLabel => 'You';

  @override
  String get userMgmtDeleteSelectedMenuLabel => 'Delete selected';

  @override
  String get userMgmtBulkActionsTooltip => 'Bulk actions';

  @override
  String get userMgmtBulkActionsLabel => 'Bulk Actions';

  @override
  String userMgmtShowingRangeLabel(int from, int to, int total) {
    return 'Showing $from to $to of $total users';
  }

  @override
  String get userMgmtNoUsersFoundMessage => 'No users found';

  @override
  String get userMgmtAddNewUserTitle => 'Add New User';

  @override
  String get userMgmtEditUserTitle => 'Edit User';

  @override
  String get userMgmtUsernameRequiredLabel => 'Username *';

  @override
  String get userMgmtEnterUsernameHint => 'Enter username';

  @override
  String get userMgmtUsernameRequiredMessage => 'Username is required';

  @override
  String get userMgmtUsernameMinLengthMessage =>
      'Username must be at least 3 characters';

  @override
  String get userMgmtPasswordRequiredLabel => 'Password *';

  @override
  String get userMgmtEnterPasswordHint => 'Enter password';

  @override
  String get userMgmtPasswordRequiredMessage => 'Password is required';

  @override
  String get userMgmtMinimum6CharsMessage => 'Minimum 6 characters';

  @override
  String get userMgmtRoleRequiredLabel => 'Role *';

  @override
  String get userMgmtRoleRequiredMessage => 'Role is required';

  @override
  String get userMgmtSaveUserButton => 'Save User';

  @override
  String get userMgmtThisIsYourAccountMessage => 'This is your account';

  @override
  String get invoiceSettingsAppBarTitle => 'Invoice Settings';

  @override
  String get invoiceSettingsSavedMessage =>
      'Invoice settings saved successfully!';

  @override
  String get invoiceSettingsSectionGeneral => 'General';

  @override
  String get invoiceSettingsSectionBranding => 'Branding';

  @override
  String get invoiceSettingsSectionTax => 'Tax & GST';

  @override
  String get invoiceSettingsSectionItems => 'Invoice Items';

  @override
  String get invoiceSettingsSectionSuppliers => 'Suppliers';

  @override
  String get settingsEnablePurchaseBillsSuppliersLabel =>
      'Enable Purchase Bills & Suppliers';

  @override
  String get settingsEnablePurchaseBillsSuppliersSubtitle =>
      'Shows Purchase Bills and Suppliers in the dashboard menu';

  @override
  String get invoiceSettingsSectionCustomer => 'Customer Details';

  @override
  String get invoiceSettingsSectionColumns => 'Invoice Columns';

  @override
  String get invoiceSettingsColumnsSectionHint =>
      'Choose which columns appear in the invoice PDF items table. Item Name, Price and Total are always shown.';

  @override
  String get invoiceSettingsShowSlNoLabel => 'Sl No column';

  @override
  String get invoiceSettingsShowSlNoSubtitle =>
      'Print the serial-number column on A4/Letter invoices';

  @override
  String get invoiceSettingsColumnHsnLabel => 'HSN/SAC column';

  @override
  String get invoiceSettingsColumnHsnSubtitle =>
      'Print the HSN/SAC code column (tied to Show GST Fields)';

  @override
  String get invoiceSettingsColumnTaxLabel => 'Show tax column';

  @override
  String get invoiceSettingsColumnTaxSubtitle =>
      'Show the tax % and amount for each item, for global and per-item tax';

  @override
  String get invoiceSettingsSplitCgstSgstLabel => 'Split CGST / SGST';

  @override
  String get invoiceSettingsSplitCgstSgstSubtitle =>
      'Split the tax into CGST/SGST, or IGST for interstate (India GST)';

  @override
  String get invoiceSettingsColumnRequiredSubtitle => 'Always shown';

  @override
  String get invoiceSettingsColumnItemNameLabel => 'Item Name column';

  @override
  String get invoiceSettingsColumnPriceLabel => 'Price / Rate column';

  @override
  String get invoiceSettingsColumnTotalLabel => 'Total column';

  @override
  String get invoiceSettingsCustomerSectionHint =>
      'Choose which customer details print on invoice PDFs and thermal receipts. A field only shows when it\'s enabled and the customer has a value for it. Customer name is always shown.';

  @override
  String get invoiceSettingsShowCustomerBusinessNameLabel =>
      'Show Business Name';

  @override
  String get invoiceSettingsShowCustomerBusinessNameSubtitle =>
      'Print the customer\'s business name under their name';

  @override
  String get invoiceSettingsShowCustomerAddressLabel => 'Show Address';

  @override
  String get invoiceSettingsShowCustomerAddressSubtitle =>
      'Print the customer\'s address in the Bill To block';

  @override
  String get invoiceSettingsShowCustomerPhoneLabel => 'Show Phone';

  @override
  String get invoiceSettingsShowCustomerPhoneSubtitle =>
      'Print the customer\'s phone number';

  @override
  String get invoiceSettingsShowCustomerEmailLabel => 'Show Email';

  @override
  String get invoiceSettingsShowCustomerEmailSubtitle =>
      'Print the customer\'s email address (not shown on thermal receipts)';

  @override
  String get invoiceSettingsShowCustomerGstinLabel => 'Show GSTIN / Tax ID';

  @override
  String get invoiceSettingsShowCustomerGstinSubtitle =>
      'Print the customer\'s GSTIN / tax id (requires GST fields on)';

  @override
  String get invoiceSettingsCustomerFieldsHeader => 'Customer Fields';

  @override
  String get invoiceSettingsCustomerFieldsHint =>
      'Extra details you can record on customers and invoices. Each one appears on the customer and invoice forms and prints on PDFs only when switched on.';

  @override
  String get invoiceSettingsShippingAddressLabel => 'Separate Shipping Address';

  @override
  String get invoiceSettingsShippingAddressSubtitle =>
      'Add a Ship To name, phone and address. When it\'s the same as billing, only one block prints';

  @override
  String get invoiceSettingsCustomerDobLabel => 'Date of Birth';

  @override
  String get invoiceSettingsCustomerDobSubtitle =>
      'Record the customer\'s date of birth. When set, age is calculated from it';

  @override
  String get invoiceSettingsCustomerAgeLabel => 'Age';

  @override
  String get invoiceSettingsCustomerAgeSubtitle =>
      'Record the customer\'s age. Used only when no date of birth is entered';

  @override
  String get invoiceSettingsCustomerGenderLabel => 'Gender';

  @override
  String get invoiceSettingsCustomerGenderSubtitle =>
      'Record the customer\'s gender (Male / Female / Other)';

  @override
  String get invoiceSettingsCustomerCustomFieldsLabel =>
      'Customer Custom Fields';

  @override
  String get invoiceSettingsCustomerCustomFieldsSubtitle =>
      'Define your own customer fields (e.g. Patient ID, Blood Group) and fill them in on each customer';

  @override
  String get invoiceSettingsCustomerCustomFieldHint => 'e.g. Patient ID';

  @override
  String get invoiceSettingsPrintOnPdfLabel => 'Print on PDF';

  @override
  String get invoiceSettingsPrintOnPdfSubtitle =>
      'Show this field on invoice PDFs and thermal receipts';

  @override
  String get customFieldPrintedOnPdfTooltip => 'Printed on PDF — click to hide';

  @override
  String get customFieldNotPrintedOnPdfTooltip =>
      'Not printed on PDF — click to print';

  @override
  String customFieldMaxReachedHint(int max) {
    return 'You can add up to $max fields.';
  }

  @override
  String get customerFieldDobLabel => 'Date of Birth';

  @override
  String get customerFieldClearDobTooltip => 'Clear date of birth';

  @override
  String get customerFieldAgeLabel => 'Age';

  @override
  String get customerFieldAgeFromDobHelper => 'Calculated from date of birth';

  @override
  String get customerFieldAgeInvalidMessage => 'Enter an age between 0 and 150';

  @override
  String get customerFieldGenderLabel => 'Gender';

  @override
  String get customerFieldGenderNotSpecified => 'Not specified';

  @override
  String get customerFieldGenderMale => 'Male';

  @override
  String get customerFieldGenderFemale => 'Female';

  @override
  String get customerFieldGenderOther => 'Other';

  @override
  String get customerFieldShippingSameAsBillingLabel =>
      'Shipping address same as billing';

  @override
  String get customerFieldShipToNotPrintedHint =>
      'Only the Bill To address prints on the PDF while this is ticked.';

  @override
  String get customerFieldShipToHeader => 'Ship To';

  @override
  String get createInvoiceCustomerDetailsDialogTitle => 'Customer Details';

  @override
  String get customerFieldPersonalDetailsHeader => 'Personal Details';

  @override
  String get customerFieldAdditionalDetailsHeader => 'Additional Details';

  @override
  String get customerFieldCopyFromBillingButton => 'Copy from billing';

  @override
  String get customerFieldRecipientNameLabel => 'Recipient Name';

  @override
  String get customerFieldRecipientPhoneLabel => 'Recipient Phone';

  @override
  String get customerFieldShippingAddressLabel => 'Shipping Address';

  @override
  String get customerFieldShippingAddressRequiredMessage =>
      'Enter a shipping address, or tick \"same as billing\"';

  @override
  String get customerMgmtCsvDescShippingName => 'Ship To recipient name';

  @override
  String get customerMgmtCsvDescShippingPhone => 'Ship To recipient phone';

  @override
  String get customerMgmtCsvDescShippingAddress =>
      'Ship To address. Empty = same as billing';

  @override
  String get customerMgmtCsvDescDob =>
      'Date of birth, yyyy-MM-dd (e.g. 1990-06-15)';

  @override
  String get customerMgmtCsvDescAge =>
      'Age in years (used only when dob is empty)';

  @override
  String get customerMgmtCsvDescGender => 'male, female or other';

  @override
  String get customerMgmtCsvDescCustomField =>
      'One column per customer custom field, header custom:<field label> (e.g. custom:Patient ID)';

  @override
  String get invoiceSettingsShowTimeInPdfLabel => 'Show Time on PDF';

  @override
  String get invoiceSettingsShowTimeInPdfSubtitle =>
      'Append the invoice creation time next to the date on PDFs and thermal receipts';

  @override
  String get invoiceSettingsTimeFormatLabel => 'Time Format';

  @override
  String get invoiceSettingsTimeFormat24 => '24-hour (14:30)';

  @override
  String get invoiceSettingsTimeFormat12 => '12-hour (2:30 PM)';

  @override
  String get invoiceSettingsPrefixLabel => 'Invoice Prefix';

  @override
  String get invoiceSettingsStartingNumberHelper =>
      'First invoice will start from this number';

  @override
  String get invoiceSettingsStartingNumberLockedMessage =>
      'Invoice starting number cannot be changed while invoices exist. Please permanently delete all invoices/quotations (including trash) and try again.';

  @override
  String get invoiceSettingsQuantityColumnLabel => 'Quantity Column Label';

  @override
  String get invoiceSettingsQuantityColumnHint => 'e.g. Words, Hours, Units';

  @override
  String get invoiceSettingsQuantityColumnHelper =>
      'Leave blank to use default \"Qty\"';

  @override
  String get invoiceSettingsAdditionalInfoLabel => 'Additional Information';

  @override
  String get invoiceSettingsThankYouNoteLabel => 'Thank You Note';

  @override
  String get invoiceSettingsHideInvoiceNumberLabel =>
      'Hide Invoice Number by Default';

  @override
  String get invoiceSettingsHideInvoiceNumberSubtitle =>
      'Enable \"Hide invoice number in PDF\" by default when creating new invoices.';

  @override
  String get invoiceSettingsTaxRateHint => 'e.g. 18';

  @override
  String get invoiceSettingsTaxRateHelper => 'Applied to new invoices';

  @override
  String get invoiceSettingsTaxEnabledLabel => 'Tax Enabled by Default';

  @override
  String get invoiceSettingsTaxEnabledSubtitle =>
      'Enable the Tax toggle by default when creating new invoices.';

  @override
  String get invoiceSettingsTaxModeLabel => 'Default Tax Rate Mode';

  @override
  String get invoiceSettingsAppliesNewInvoicesOnly =>
      'Applies to new invoices only';

  @override
  String get invoiceSettingsTaxModeGlobal => 'Global';

  @override
  String get invoiceSettingsTaxModePerItem => 'Per Item';

  @override
  String get invoiceSettingsShowGstFieldsLabel => 'Show GST Fields';

  @override
  String get invoiceSettingsShowGstFieldsSubtitle =>
      'Display GSTIN fields (HSN/SAC) on invoices, PDFs, and CSV exports';

  @override
  String get invoiceSettingsShowCgstSgstLabel => 'Show CGST/SGST/IGST';

  @override
  String get invoiceSettingsShowCgstSgstSubtitle =>
      'Split tax into CGST + SGST, or IGST for interstate invoices (India only).';

  @override
  String get invoiceSettingsDefaultGstTitleLabel => 'Default GST Invoice Title';

  @override
  String get invoiceSettingsDefaultTaxTitleLabel => 'Default TAX Invoice Title';

  @override
  String get invoiceSettingsGstTitleHelperGst =>
      'Preselected on new invoices — e.g. \"Bill of Supply\" for GST Composition Scheme dealers';

  @override
  String get invoiceSettingsGstTitleHelperGeneric =>
      'Preselected on new invoices';

  @override
  String get invoiceSettingsShowRoundOffLabel => 'Show Round Off';

  @override
  String get invoiceSettingsShowRoundOffSubtitle =>
      'Show a Round Off row + Net Amount (rounded to nearest) and amount in words on invoice PDFs.';

  @override
  String get invoiceSettingsShowAliasNameLabel => 'Show Alias Name in PDF';

  @override
  String get invoiceSettingsShowAliasNameSubtitle =>
      'Print a product\'s local-language alias (if set) instead of its actual name on PDFs';

  @override
  String get invoiceSettingsShowDescriptionLabel => 'Show Product Description';

  @override
  String get invoiceSettingsShowDescriptionSubtitle =>
      'Print each item\'s description as a row under it on A4 PDFs (not on thermal receipts)';

  @override
  String get invoiceSettingsDescriptionNewLineLabel =>
      'Description on a New Line';

  @override
  String get invoiceSettingsDescriptionNewLineSubtitle =>
      'Print the description as a full-width row below the item instead of a line under its name';

  @override
  String get invoiceSettingsAllowFractionalQtyLabel =>
      'Allow Fractional Quantities';

  @override
  String get invoiceSettingsAllowFractionalQtySubtitle =>
      'Enable decimal quantities (e.g. 1.5 hrs, 0.5 kg)';

  @override
  String get invoiceSettingsShowQuantityLabel => 'Show Quantity Field';

  @override
  String get invoiceSettingsShowQuantitySubtitle =>
      'Hide quantity for service-based billing; price column becomes \"Rate\"';

  @override
  String get invoiceSettingsShowDiscountLabel => 'Show Discount Column';

  @override
  String get invoiceSettingsShowDiscountSubtitle =>
      'Hide discount column for clients who don\'t use item-level discounts';

  @override
  String get invoiceSettingsShowTypeTagLabel => 'Show Product/Service Tag';

  @override
  String get invoiceSettingsShowTypeTagSubtitle =>
      'Show or hide the Product/Service label on each invoice item';

  @override
  String get invoiceSettingsAllowDuplicateItemsLabel =>
      'Allow Duplicate Invoice Items';

  @override
  String get invoiceSettingsAllowDuplicateItemsSubtitle =>
      'Allow adding the same product more than once to an invoice';

  @override
  String get invoiceSettingsShowPrevBalanceLabel => 'Show Previous Balance Due';

  @override
  String get invoiceSettingsShowPrevBalanceSubtitle =>
      'Show calculated prior outstanding balance on invoice PDFs';

  @override
  String get invoiceSettingsLogoPositionLabel => 'Company Logo Position';

  @override
  String get invoiceSettingsLogoSizeLabel => 'Company Logo Size';

  @override
  String get commonLeftLabel => 'Left';

  @override
  String get commonRightLabel => 'Right';

  @override
  String get invoiceSettingsSignatureImageLabel => 'Signature Image';

  @override
  String get invoiceSettingsSignatureImageSubtitle =>
      'Printed on invoices as Authorised Signature';

  @override
  String get invoiceSettingsChangeSignatureButton => 'Change Signature';

  @override
  String get invoiceSettingsUploadSignatureButton => 'Upload Signature';

  @override
  String get invoiceSettingsSignatureSizeLabel => 'Signature Size';

  @override
  String get invoiceSettingsSignaturePositionLabel => 'Signature Position';

  @override
  String get invoiceSettingsWatermarkImageLabel => 'Watermark Image';

  @override
  String get invoiceSettingsWatermarkImageSubtitle =>
      'Shown on invoice PDFs (not printed on thermal receipts)';

  @override
  String get invoiceSettingsChangeWatermarkButton => 'Change Watermark';

  @override
  String get invoiceSettingsUploadWatermarkButton => 'Upload Watermark';

  @override
  String get invoiceSettingsWatermarkPlacementLabel => 'Watermark placement';

  @override
  String get invoiceSettingsWatermarkPlacementItemsTable => 'Items table';

  @override
  String get invoiceSettingsWatermarkPlacementFullPage => 'Full page';

  @override
  String invoiceSettingsOpacityLabel(int value) {
    return 'Opacity: $value%';
  }

  @override
  String invoiceSettingsPercentValueLabel(int value) {
    return '$value%';
  }

  @override
  String get invoiceSettingsPromoTitle => 'Need more fields on your invoices?';

  @override
  String get invoiceSettingsPromoBody =>
      'Add PO number, project code, department, or any custom field.';

  @override
  String get invoiceSettingsPromoButton => 'See Options';

  @override
  String get pdfSettingsTitle => 'PDF Settings';

  @override
  String get pdfSettingsSubtitle =>
      'Customize invoice, quotation and receipt PDF templates';

  @override
  String get pdfSettingsResetToDefaultButton => 'Reset to Default';

  @override
  String get pdfSettingsSaveSettingsButton => 'Save Settings';

  @override
  String get pdfSettingsTemplatesLabel => 'Templates';

  @override
  String pdfSettingsNoTemplatesForPageSizeMessage(String pageSize) {
    return 'No templates for $pageSize';
  }

  @override
  String get pdfSettingsSavedSnackbar => 'PDF settings saved';

  @override
  String get commonActiveLabel => 'Active';

  @override
  String get commonUnavailableLabel => 'Unavailable';

  @override
  String get pdfSettingsDisplayOptionsLabel => 'Display Options';

  @override
  String get pdfSettingsShowTotalQtyRowLabel => 'Show total quantity row';

  @override
  String get pdfSettingsOrientationLabel => 'Orientation';

  @override
  String get pdfSettingsOrientationPortrait => 'Portrait';

  @override
  String get pdfSettingsOrientationLandscape => 'Landscape';

  @override
  String get pdfSettingsMetadataColumnsLabel => 'Product metadata columns';

  @override
  String get pdfSettingsMetadataColumnsHint =>
      'Print product metadata as extra columns in the items table.';

  @override
  String get pdfSettingsMetadataColumnsWarning =>
      'Metadata columns print on any A4 template (not A5/A6 or thermal receipts). Each one narrows the others — if the table looks cramped, turn a few off, or switch Grid Classic to Landscape above. Values are captured when an item is added; editing the product later won\'t change past invoices.';

  @override
  String get pdfSettingsItemLayoutLabel => 'Item layout';

  @override
  String get pdfSettingsItemLayoutTableLabel => 'Table';

  @override
  String get pdfSettingsItemLayoutDetailedLabel => 'Detailed';

  @override
  String get pdfSettingsItemLayoutHelpText =>
      'Table: one line per item (Sl/Name/Qty/Rate/Total). Detailed: name on its own line, then Qty/Rate/Total below it.';

  @override
  String get pdfSettingsCompanyNameSizeLabel => 'Company name size';

  @override
  String get pdfSettingsFontSizeLabel => 'PDF text size';

  @override
  String get pdfSettingsSectionSizesLabel => 'Section sizes';

  @override
  String get pdfSettingsDocTitleSizeLabel => 'Document title size';

  @override
  String get pdfSettingsTableHeaderSizeLabel => 'Table header size';

  @override
  String get pdfSettingsTableItemsSizeLabel => 'Table items size';

  @override
  String get pdfSettingsTotalsSizeLabel => 'Totals size';

  @override
  String get pdfFontSizeSameAsOverallLabel => 'Same as overall';

  @override
  String get pdfSettingsThemeColorLabel => 'Theme Color';

  @override
  String get pdfSettingsHexErrorText => 'Use #RRGGBB';

  @override
  String get pdfSettingsPickColorTooltip => 'Open color picker';

  @override
  String get pdfSettingsPickThemeColorDialogTitle => 'Pick theme color';

  @override
  String get pdfSettingsPreviewDisclaimer =>
      'Preview may slightly differ in the final PDF.';

  @override
  String get pdfSettingsCustomTemplatePromoTitle => 'Want a custom template?';

  @override
  String get pdfSettingsCustomTemplatePromoBody =>
      'Get a design that matches your brand — colors, fonts, and layout.';

  @override
  String get pdfSettingsCustomizationOptionsButton => 'Customization Options';

  @override
  String get pdfTemplateClassicName => 'Classic';

  @override
  String get pdfTemplateClassicDescription =>
      'Traditional layout with clean structure';

  @override
  String get pdfTemplateModernName => 'Modern';

  @override
  String get pdfTemplateModernDescription =>
      'Bold header with contemporary styling';

  @override
  String get pdfTemplateMinimalName => 'Minimal';

  @override
  String get pdfTemplateMinimalDescription => 'Simple and distraction-free';

  @override
  String get pdfTemplateExecutiveName => 'Executive';

  @override
  String get pdfTemplateExecutiveDescription =>
      'Premium business layout with structured billing blocks';

  @override
  String get pdfTemplateCompactName => 'Compact';

  @override
  String get pdfTemplateCompactDescription =>
      'Space-efficient receipt layout, ideal for A6 printing';

  @override
  String get pdfTemplateThermalName => 'Thermal';

  @override
  String get pdfTemplateThermalDescription =>
      'Narrow receipt layout for 80mm and 58mm thermal printers';

  @override
  String get pdfTemplateGridClassicName => 'Grid Classic';

  @override
  String get pdfTemplateGridClassicDescription =>
      'Old-style bordered tabular bill, for A4, A5 and A6';

  @override
  String get companyInfoAppBarTitle => 'Company Information';

  @override
  String get companyInfoUploadLogoLabel => 'Upload Logo';

  @override
  String get companyInfoClickToBrowseLabel => 'Click to browse';

  @override
  String get companyInfoRemoveLogoButton => 'Remove Logo';

  @override
  String get companyInfoShowOnPdfLabel => 'Show on PDF';

  @override
  String get companyInfoLogoSectionLabel => 'COMPANY LOGO';

  @override
  String get companyInfoDetailsSectionLabel => 'COMPANY DETAILS';

  @override
  String get companyInfoBusinessTypeSectionLabel => 'BUSINESS TYPE';

  @override
  String get companyInfoPaymentSettingsSectionLabel => 'PAYMENT SETTINGS';

  @override
  String get companyInfoUpiAccountsSectionLabel => 'UPI ACCOUNTS';

  @override
  String get companyInfoBankAccountsSectionLabel => 'BANK ACCOUNTS';

  @override
  String get fieldGstinLabel => 'GSTIN';

  @override
  String get fieldTaxVatNoLabel => 'Tax/VAT No';

  @override
  String get fieldPanLabel => 'PAN';

  @override
  String get fieldTinLabel => 'TIN';

  @override
  String get fieldVatRegNoLabel => 'VAT Registration Number';

  @override
  String get companyInfoFssaiCodeLabel => 'FSSAI Code';

  @override
  String get companyInfoPhoneHelperText =>
      'Multiple numbers: separate with comma';

  @override
  String get fieldWebsiteLabel => 'Website';

  @override
  String get companyInfoBusinessTypeTitle => 'Business Type';

  @override
  String get companyInfoBusinessTypeSubtitle =>
      'Controls item type options in the product list and invoices';

  @override
  String get labelBoth => 'Both';

  @override
  String get companyInfoSetAsDefaultTooltip => 'Set as Default';

  @override
  String get companyInfoUpiIdLabel => 'UPI ID';

  @override
  String get companyInfoAddUpiAccountButton => 'Add UPI Account';

  @override
  String get companyInfoShowQrToggleTitle => 'Show QR Code on Invoices';

  @override
  String get companyInfoShowQrToggleSubtitle =>
      'Adds scannable UPI payment QR codes to generated PDFs';

  @override
  String get companyInfoShowBankDetailsToggleTitle =>
      'Show Bank Details on Invoices';

  @override
  String get companyInfoShowBankDetailsToggleSubtitle =>
      'Prints bank account details on generated PDFs';

  @override
  String get fieldBankNameLabel => 'Bank Name';

  @override
  String get fieldAccountNumberLabel => 'Account Number';

  @override
  String get fieldIfscCodeLabel => 'IFSC Code';

  @override
  String get fieldIbanLabel => 'IBAN';

  @override
  String get companyInfoAddBankAccountButton => 'Add Bank Account';

  @override
  String get companyInfoEditBankAccountTitle => 'Edit Bank Account';

  @override
  String get fieldBankAccountNameLabel => 'Account Name';

  @override
  String get tooltipShowOnInvoicePdf => 'Show on invoice PDF';

  @override
  String get companyInfoSavedSuccessMessage =>
      'Company info saved successfully';

  @override
  String get companyInfoInvalidImageMessage => 'Invalid image file.';

  @override
  String get companyInfoHintExampleBankName => 'e.g. HDFC Bank';

  @override
  String get companyInfoHintExampleAccountLabel => 'e.g. Main Account';

  @override
  String get actionConfirm => 'પુષ્ટિ કરો';

  @override
  String get actionShare => 'શેર કરો';

  @override
  String get appInfoTitle => 'About CrizaVoise';

  @override
  String get appInfoAppDetailsTitle => 'APP DETAILS';

  @override
  String get appInfoAppNameLabel => 'App Name';

  @override
  String get appInfoVersionLabel => 'Version';

  @override
  String get appInfoLicenseLabel => 'License';

  @override
  String get appInfoDeveloperTitle => 'MADE BY';

  @override
  String get appInfoDeveloperLabel => 'Maker';

  @override
  String get appInfoSupportEmailLabel => 'Support Email';

  @override
  String get appInfoCheckingLabel => 'Checking...';

  @override
  String get appInfoUpdateAvailableLabel => 'Update Available';

  @override
  String get appInfoUpToDateLabel => 'Up to date';

  @override
  String get appInfoCheckFailedLabel => 'Check failed';

  @override
  String get appInfoUpdatesTitle => 'UPDATES';

  @override
  String get appInfoCurrentVersionLabel => 'Current Version';

  @override
  String get appInfoLatestVersionLabel => 'Latest Version';

  @override
  String get appInfoCheckNowButton => 'Check Now';

  @override
  String get backupManagementTitle => 'Backup Management';

  @override
  String get backupCreateDbButton => 'Create DB Backup';

  @override
  String get backupExportJsonButton => 'Export JSON';

  @override
  String get backupImportButton => 'Import Backup';

  @override
  String get backupNoBackupsFoundMessage => 'No backups found';

  @override
  String backupSizeLabel(String size) {
    return 'Size: $size';
  }

  @override
  String backupCreatedLabel(String date) {
    return 'Created: $date';
  }

  @override
  String backupLoadErrorMessage(String error) {
    return 'Failed to load backups: $error';
  }

  @override
  String get backupCreatedSuccessMessage => 'Backup created successfully!';

  @override
  String backupCreateErrorMessage(String error) {
    return 'Failed to create backup: $error';
  }

  @override
  String get backupRestoreConfirmTitle => 'Restore Backup';

  @override
  String get backupRestoreConfirmBody =>
      'This will replace all current data with the backup. Are you sure?';

  @override
  String backupRestoreErrorMessage(String error) {
    return 'Failed to restore backup: $error';
  }

  @override
  String get backupDeleteConfirmTitle => 'Delete Backup';

  @override
  String get backupDeleteConfirmBody =>
      'Are you sure you want to delete this backup?';

  @override
  String get backupDeletedSuccessMessage => 'Backup deleted successfully!';

  @override
  String get backupDeleteFailedMessage => 'Failed to delete backup';

  @override
  String backupDeleteErrorMessage(String error) {
    return 'Failed to delete backup: $error';
  }

  @override
  String get backupSavedToDownloadsMessage =>
      'Backup saved to Downloads folder.';

  @override
  String backupDownloadErrorMessage(String error) {
    return 'Failed to download backup: $error';
  }

  @override
  String backupShareErrorMessage(String error) {
    return 'Failed to share backup: $error';
  }

  @override
  String backupImportErrorMessage(String error) {
    return 'Failed to import backup: $error';
  }

  @override
  String get backupRestoreSuccessTitle => 'Restore Successful';

  @override
  String get backupRestoreSuccessBody =>
      'The database has been restored successfully.\n\nThe app needs to restart to apply the changes. Please close and reopen the application.';

  @override
  String get backupCloseLaterButton => 'Close Later';

  @override
  String get backupCloseAppNowButton => 'Close App Now';

  @override
  String get commonSuccessTitle => 'Success';

  @override
  String get commonErrorTitle => 'Error';

  @override
  String get productColumnsScreenTitle => 'Customize Product Details';

  @override
  String get productColumnsSavedMessage => 'Product columns saved.';

  @override
  String get productColumnsIntroText =>
      'Choose which fields appear on the product add/edit forms, the product list, and invoice line items. Name and Price are always required.';

  @override
  String get productColumnsNameLabel => 'Name';

  @override
  String get productColumnsPriceLabel => 'Price';

  @override
  String get productColumnsAlwaysRequiredSubtitle => 'Always shown — required.';

  @override
  String get productColumnsStockLabel => 'Stock';

  @override
  String get productColumnsStockSubtitle =>
      'Turn off if you never track stock — products default to unlimited stock instead.';

  @override
  String get productColumnsProductFieldsSectionTitle => 'Product fields';

  @override
  String get productColumnsAliasNameLabel => 'Alias Name';

  @override
  String get productColumnsAliasNameSubtitle =>
      'Local-language display name for PDFs/printing.';

  @override
  String get productColumnsTaxRateLabel => 'Tax Rate';

  @override
  String get productColumnsTaxRateSubtitle => 'Per-product tax percentage.';

  @override
  String get productColumnsHsnSacLabel => 'HSN/SAC';

  @override
  String get productColumnsHsnSacSubtitle => 'HSN or SAC code field.';

  @override
  String get productColumnsDescriptionLabel => 'Description';

  @override
  String get productColumnsDescriptionSubtitle =>
      'Free-text product description.';

  @override
  String get productColumnsPurchasePriceLabel => 'Purchase Price';

  @override
  String get productColumnsPurchasePriceSubtitle =>
      'Cost price, for margin tracking.';

  @override
  String get productColumnsPurchasePriceAdminOnlyLabel =>
      'Purchase Price: Admins Only';

  @override
  String get productColumnsPurchasePriceAdminOnlySubtitle =>
      'Hide purchase price, profit and stock value from non-admin users.';

  @override
  String get productColumnsStockEditAdminOnlyLabel =>
      'Stock Editing: Admins Only';

  @override
  String get productColumnsStockEditAdminOnlySubtitle =>
      'Non-admin users can\'t set or change stock quantities, or import products from CSV.';

  @override
  String get productColumnsDefaultDiscountLabel => 'Default Discount';

  @override
  String get productColumnsDefaultDiscountSubtitle =>
      'Pre-filled discount when adding this product to an invoice.';

  @override
  String get productColumnsUnitLabel => 'Unit';

  @override
  String get productColumnsUnitSubtitle => 'Unit of measure (pcs, kg, hrs...).';

  @override
  String get productColumnsProductServiceTypeLabel => 'Product/Service Type';

  @override
  String get productColumnsProductServiceTypeSubtitle =>
      'Segmented Product vs Service selector.';

  @override
  String get productColumnsMetadataLabel => 'Product Metadata';

  @override
  String get productColumnsMetadataSubtitle =>
      'Storage location, container/batch number, expiry, manufacture date, manufacturer, supplier, SKU, notes.';

  @override
  String get productColumnsMetaStorageLocationLabel => 'Storage Location';

  @override
  String get productColumnsMetaContainerNumberLabel => 'Container Number';

  @override
  String get productColumnsMetaBatchNumberLabel => 'Batch Number';

  @override
  String get productColumnsMetaExpiryDateLabel => 'Expiry Date';

  @override
  String get productColumnsMetaManufactureDateLabel => 'Manufacture Date';

  @override
  String get productColumnsMetaManufactureNameLabel => 'Manufacturer Name';

  @override
  String get productColumnsMetaSupplierNameLabel => 'Supplier Name';

  @override
  String get productColumnsMetaSkuCodeLabel => 'SKU Code';

  @override
  String get productColumnsMetaNotesLabel => 'Notes';

  @override
  String get productColumnsExtraCostLabel => 'Extra Cost';

  @override
  String get productColumnsExtraCostSubtitle =>
      'Optional flat extra charge on an invoice line item.';

  @override
  String get settingsOptionsComingSoonMessage => 'Options coming soon...';

  @override
  String get settingsNavCompanyInfoLabel => 'Company Info';

  @override
  String get settingsNavCompaniesLabel => 'Companies';

  @override
  String get settingsNavTeamLabel => 'Team';

  @override
  String get settingsNavBackupLabel => 'Backup';

  @override
  String get settingsNavUsersLabel => 'Users';

  @override
  String get settingsNavProductDetailsLabel => 'Product Details';

  @override
  String get settingsNavCustomizeLabel => 'Customize';

  @override
  String get settingsNavAccessibilityLabel => 'Accessibility';

  @override
  String get settingsNavSoftwareInfoLabel => 'About';

  @override
  String get companyMgmtTitle => 'Manage Companies';

  @override
  String get companyMgmtActiveBadge => 'Active';

  @override
  String get companyMgmtSwitchButton => 'Switch';

  @override
  String get companyMgmtSwitchConfirmTitle => 'Switch Company?';

  @override
  String companyMgmtSwitchConfirmBody(String name) {
    return 'CrizaVoise will restart to switch to \"$name\".';
  }

  @override
  String get companyMgmtNewCompanyButton => '+ New Company';

  @override
  String get companyMgmtNewCompanyTitle => 'New Company';

  @override
  String get companyMgmtAdminAccountSectionLabel => 'Admin Account';

  @override
  String get companyMgmtCreateButton => 'Create';

  @override
  String get companyMgmtDeleteButton => 'Delete This Company';

  @override
  String companyMgmtDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get companyMgmtDeleteConfirmBody =>
      'This permanently deletes all of this company\'s data and cannot be undone. Type the company name to confirm.';

  @override
  String get companyMgmtRenameTooltip => 'Rename';

  @override
  String get companyMgmtRenameTitle => 'Rename Company';

  @override
  String get companyMgmtNameTakenMessage =>
      'A company with this name already exists';

  @override
  String companyMgmtSwitchErrorMessage(String error) {
    return 'Failed to switch company: $error';
  }

  @override
  String get companyMgmtSwitchRestartTitle => 'Company Switched';

  @override
  String get companyMgmtSwitchRestartBody =>
      'CrizaVoise needs to restart to finish switching companies. Please close and reopen the application.';

  @override
  String get companyMgmtCreateRestartTitle => 'Company Created';

  @override
  String get companyMgmtCreateRestartBody =>
      'Your new company is ready. Please close and reopen the application to continue.';

  @override
  String get companyMgmtDeletedMessage => 'Company deleted';

  @override
  String get companyMgmtDeleteRestartTitle => 'Company Deleted';

  @override
  String get companyMgmtDeleteRestartBody =>
      'The company was deleted and CrizaVoise switched to another one. Please close and reopen the application to continue.';

  @override
  String get companyMgmtOnlyCompanyTooltip =>
      'You need at least one other company before you can delete this one';

  @override
  String get loginCompanyGearTooltip => 'Manage companies';

  @override
  String get loginCompanySelectorLabel => 'Company';

  @override
  String get customizationEyebrowLabel => 'CUSTOMIZATION';

  @override
  String get customizationHeadline => 'Tailored just for your business';

  @override
  String get customizationSubtitle =>
      'Pick what you need and send a request. We\'ll reply with a personal quote.';

  @override
  String get customizationRecommendedBadge => 'Recommended';

  @override
  String get customizationRequestButton => 'Request';

  @override
  String customizationDisclaimerMessage(String email) {
    return 'Every request gets a personal quote based on its scope. For anything else, write to $email.';
  }

  @override
  String get customizationPdfTemplateTitle => 'Custom PDF Template';

  @override
  String get customizationPdfTemplateDescription =>
      'Get an invoice template designed to match your brand — your colors, fonts, logo placement, and layout.';

  @override
  String get customizationCustomFieldsTitle => 'Custom Fields';

  @override
  String get customizationCustomFieldsDescription =>
      'Need extra fields on your invoices? (PO number, project code, department, etc.) We\'ll add them for you.';

  @override
  String get customizationWhiteLabelTitle => 'White-label / Remove Branding';

  @override
  String get customizationWhiteLabelDescription =>
      'Remove all CrizaVoise branding from the app and PDF outputs, and replace it with your own company identity.';

  @override
  String get customizationIndustryBuildTitle => 'Industry-specific Build';

  @override
  String get customizationIndustryBuildDescription =>
      'Need a version tailored to your industry? (construction, consulting, retail, etc.) We\'ll customise the workflow to fit your needs.';

  @override
  String get accessibilityCreateInvoiceLayoutSectionTitle =>
      'New Create Invoice Page Layout';

  @override
  String get accessibilityClassicLayoutLabel => 'Classic layout';

  @override
  String get accessibilityNewLayoutLabel => 'New layout';

  @override
  String get accessibilityLayoutDescription =>
      'Choose which \"New Invoice\" screen design to use.';

  @override
  String get accessibilityShortcutsSubtitle =>
      'Speed up invoice creation without touching the mouse.';

  @override
  String paymentDialogInvoiceRefLabel(String number, String customer) {
    return '#$number — $customer';
  }

  @override
  String get paymentDialogInvoiceTotalLabel => 'Invoice Total';

  @override
  String get paymentDialogAmountPaidLabel => 'Amount Paid';

  @override
  String get paymentDialogHistoryTitle => 'Payment History';

  @override
  String get paymentDialogNoPaymentsMessage => 'No payments recorded yet';

  @override
  String get paymentDialogFullyPaidExclaimMessage => 'Invoice fully paid!';

  @override
  String get paymentDialogFullyPaidBannerLabel => 'Invoice fully paid';

  @override
  String paymentDialogRecordedMessage(String symbol, String amount) {
    return 'Payment recorded. Outstanding: $symbol $amount';
  }

  @override
  String paymentDialogRecordFailedMessage(String error) {
    return 'Failed to record payment: $error';
  }

  @override
  String get paymentDialogDeleteTitle => 'Delete Payment';

  @override
  String paymentDialogDeleteConfirmBody(String receiptNumber) {
    return 'Delete receipt $receiptNumber?\n\nThis cannot be undone.';
  }

  @override
  String get paymentDialogNewPaymentTitle => 'New Payment';

  @override
  String paymentDialogAmountFieldLabel(String symbol) {
    return 'Amount ($symbol)';
  }

  @override
  String paymentDialogMaxHelperText(String symbol, String amount) {
    return 'Max: $symbol $amount';
  }

  @override
  String get paymentDialogInvalidAmountError => 'Enter a valid amount';

  @override
  String get paymentDialogExceedsOutstandingError =>
      'Exceeds outstanding balance';

  @override
  String get paymentDialogMethodFieldLabel => 'Payment Method';

  @override
  String get paymentDialogSelectMethodHint => 'Select method';

  @override
  String get paymentDialogTaxCoveredLabel => 'Tax Covered';

  @override
  String get paymentDialogAutoCalculatedHelper => 'Auto-calculated';

  @override
  String get paymentDialogNotesFieldLabel => 'Reference / Notes (optional)';

  @override
  String get paymentDialogNotesHint => 'e.g. cheque no., transaction ID...';

  @override
  String get paymentDialogReceiptColLabel => 'Receipt #';

  @override
  String get paymentDialogMethodColLabel => 'Method';

  @override
  String get paymentDialogDownloadReceiptTooltip => 'Download receipt';

  @override
  String get paymentDialogDeletePaymentTooltip => 'Delete payment';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodBankTransfer => 'Bank Transfer';

  @override
  String get paymentMethodCheck => 'Check';

  @override
  String get paymentMethodOnline => 'Online';

  @override
  String get paymentMethodUpi => 'UPI';

  @override
  String get paymentMethodOther => 'Other';

  @override
  String get accessibilityOptionalFeaturesSectionTitle => 'Optional features';

  @override
  String get accessibilityCashExchangeLabel => 'Cash / UPI Exchange Service';

  @override
  String get accessibilityCashExchangeSubtitle =>
      'Adds a Cash Exchange Services menu after New Invoice to record UPI ↔ Cash exchanges, service fees and cash movements, with Cash and UPI/Bank balances.';

  @override
  String get accessibilityReportsAdminOnlyLabel => 'Reports: Admins Only';

  @override
  String get accessibilityReportsAdminOnlySubtitle =>
      'Hides the Reports menu from non-admin users.';

  @override
  String get accessibilityPurchaseBillsAdminOnlyLabel =>
      'Purchase Bills & Suppliers: Admins Only';

  @override
  String get accessibilityPurchaseBillsAdminOnlySubtitle =>
      'Hides the Purchase Bills and Suppliers menus from non-admin users.';

  @override
  String get cashExchangeCashLabel => 'Cash';

  @override
  String get cashExchangeUpiBankLabel => 'UPI/Bank';

  @override
  String get cashExchangeTotalLabel => 'Total balance';

  @override
  String get cashExchangeIncomeTodayLabel => 'Service income (today)';

  @override
  String get cashExchangeIncomeMonthLabel => 'Service income (this month)';

  @override
  String get reportsServiceIncomeLabel => 'Service income';

  @override
  String get reportsTxnsLabel => 'Txns';

  @override
  String get reportsInvoiceProfitLabel => 'Invoice profit';

  @override
  String get reportsTransactionsLabel => 'Transactions';

  @override
  String get reportsCashExchangeTypeLabel => 'Cash exchange';

  @override
  String get reportsCountColumnLabel => 'Count';

  @override
  String get cashExchangeExpensesMonthLabel => 'Expenses (this month)';

  @override
  String get cashExchangeSetupTitle => 'Set opening balances';

  @override
  String get cashExchangeSetupMessage =>
      'Enter the cash and UPI/Bank money you have on this date. Invoice payments from this date on are added to the balances.';

  @override
  String get cashExchangeSetupAdminOnlyMessage =>
      'Ask an admin to set the opening balances.';

  @override
  String get cashExchangeUpiToCash => 'UPI → Cash';

  @override
  String get cashExchangeCashToUpi => 'Cash → UPI';

  @override
  String get cashExchangeExpense => 'Expense';

  @override
  String get cashExchangeWithdrawal => 'Withdrawal';

  @override
  String get cashExchangeBankDeposit => 'Bank deposit';

  @override
  String get cashExchangeOpeningBalance => 'Opening balance';

  @override
  String get cashExchangeAdjustment => 'Adjustment';

  @override
  String get cashExchangeInvoicePayment => 'Invoice payment';

  @override
  String get cashExchangeAmountLabel => 'Amount';

  @override
  String get cashExchangeFeeLabel => 'Service fee';

  @override
  String get cashExchangeFeePaidByLabel => 'Service fee paid by';

  @override
  String get cashExchangeFromAccountLabel => 'Paid from';

  @override
  String get cashExchangeCustomerNameLabel => 'Customer name (optional)';

  @override
  String get cashExchangeCustomerSearchHint =>
      'Search customers or type a new name';

  @override
  String get cashExchangeCustomerPhoneLabel => 'Phone (optional)';

  @override
  String get cashExchangeNotesLabel => 'Notes (optional)';

  @override
  String get cashExchangeDateTimeLabel => 'Date & time';

  @override
  String get cashExchangeDateLabel => 'Date';

  @override
  String get cashExchangeCashDeltaLabel => 'Cash change (+ / −)';

  @override
  String get cashExchangeUpiDeltaLabel => 'UPI/Bank change (+ / −)';

  @override
  String get cashExchangeDeleteTitle => 'Delete entry';

  @override
  String get cashExchangeDeleteMessage =>
      'Delete this entry? Balances will be recalculated.';

  @override
  String get cashExchangeEditTitle => 'Edit entry';

  @override
  String get cashExchangeEdited => 'Edited';

  @override
  String get cashExchangeHistoryTitle => 'Change history';

  @override
  String get cashExchangeHistoryCurrent => 'Current';

  @override
  String cashExchangeHistoryEdited(String user, String date) {
    return 'Edited by $user · $date';
  }

  @override
  String cashExchangeHistoryDeleted(String user, String date) {
    return 'Deleted by $user · $date';
  }

  @override
  String get cashExchangeChangeLog => 'Change log';

  @override
  String get cashExchangeDeleted => 'Deleted';

  @override
  String get cashExchangeNoChanges => 'No changes recorded.';

  @override
  String get cashExchangeChangeFailed =>
      'This entry can no longer be changed. It may have been deleted, or the 24-hour edit window has passed.';

  @override
  String get cashExchangeEmpty => 'No entries for this period.';

  @override
  String get cashExchangePeriodToday => 'Today';

  @override
  String get cashExchangePeriodMonth => 'This month';

  @override
  String get cashExchangePeriodAll => 'All time';

  @override
  String get cashExchangePeriodCustom => 'Custom date';

  @override
  String get cashExchangeShowingLabel => 'Showing';

  @override
  String get cashExchangeChangeDates => 'Change dates';

  @override
  String get cashExchangeClosingBalance => 'Closing balance';

  @override
  String get cashExchangeShowBalances => 'Show balances';

  @override
  String get cashExchangeHideBalances => 'Hide balances';

  @override
  String get cashExchangeAllTypes => 'All types';

  @override
  String cashExchangeSummaryUpiToCash(
      String amount, String fee, String method) {
    return 'Customer sends $amount by UPI/Bank • You give $amount cash • Fee $fee by $method';
  }

  @override
  String cashExchangeSummaryCashToUpi(
      String amount, String fee, String method) {
    return 'Customer gives $amount cash • You send $amount by UPI/Bank • Fee $fee by $method';
  }

  @override
  String cashExchangeLowBalanceWarning(String balance, String account) {
    return 'Only $balance available in $account.';
  }

  @override
  String get customerInfoButtonTooltip => 'View contact details';

  @override
  String get customerInfoButtonNoContactMessage =>
      'No contact details available.';

  @override
  String get updateDialogTitle => 'Update Available';

  @override
  String get updateDialogBodyMessage =>
      'A new version of CrizaVoise is available. Visit the download page to get the latest release.';

  @override
  String get pageSizeA4Label => 'Standard A4';

  @override
  String get pageSizeA5Label => 'Standard A5';

  @override
  String get pageSizeA6Label => 'Standard A6';

  @override
  String get pageSizeThermal80Label => 'Thermal Paper 80mm';

  @override
  String get pageSizeThermal58Label => 'Thermal Paper 58mm';

  @override
  String get dateFormatDdmmyyyyLabel => 'DD/MM/YYYY  (e.g. 15/04/2026)';

  @override
  String get dateFormatMmddyyyyLabel => 'MM/DD/YYYY  (e.g. 04/15/2026)';

  @override
  String get dateFormatDdMmmyyyyLabel => 'DD MMM YYYY  (e.g. 15 Apr 2026)';

  @override
  String get dateFormatYyyymmddLabel => 'YYYY-MM-DD  (e.g. 2026-04-15)';

  @override
  String get sizeXSmallLabel => 'X-Small';

  @override
  String get sizeSmallLabel => 'Small';

  @override
  String get sizeMediumLabel => 'Medium';

  @override
  String get sizeLargeLabel => 'Large';

  @override
  String get sizeXLargeLabel => 'Extra Large';

  @override
  String get shortcutNewInvoiceDescription =>
      'New Invoice (from Dashboard) / Reset form (in Create Invoice)';

  @override
  String get shortcutSaveInvoiceDescription => 'Save / create the invoice';

  @override
  String get shortcutAddProductDescription => 'Add product to invoice';

  @override
  String get shortcutAddCustomItemDescription => 'Add custom (ad-hoc) item';

  @override
  String get shortcutPreviewPdfDescription => 'Preview invoice PDF';

  @override
  String get shortcutPrintPdfDescription => 'Generate / print invoice PDF';

  @override
  String supplierMgmtLoadErrorMessage(String error) {
    return 'Failed to load suppliers: $error';
  }

  @override
  String get supplierMgmtAddedMessage => 'Supplier added successfully!';

  @override
  String get supplierMgmtUpdatedMessage => 'Supplier updated successfully!';

  @override
  String supplierMgmtSaveErrorMessage(String error) {
    return 'Error saving supplier: $error';
  }

  @override
  String supplierMgmtOutstandingLabel(String amount) {
    return 'Outstanding: $amount';
  }

  @override
  String supplierMgmtMoveToTrashBody(String name) {
    return 'Move \"$name\" to trash? Existing purchase bills keep showing their snapshotted supplier name.';
  }

  @override
  String get supplierMgmtMovedToTrashMessage => 'Supplier moved to trash.';

  @override
  String get supplierMgmtRestoredMessage => 'Supplier restored.';

  @override
  String get supplierMgmtAddSupplierButton => 'Add Supplier';

  @override
  String get supplierMgmtTitle => 'Suppliers';

  @override
  String get supplierMgmtSubtitle =>
      'Manage the suppliers you purchase stock from';

  @override
  String get supplierMgmtSearchHint =>
      'Search suppliers by name, phone, or GSTIN...';

  @override
  String get supplierMgmtColSupplier => 'Supplier';

  @override
  String get supplierMgmtColGstin => 'GSTIN';

  @override
  String supplierMgmtTotalCountLabel(int count) {
    return 'Total: $count';
  }

  @override
  String get supplierMgmtNoSuppliersYetMessage => 'No suppliers yet';

  @override
  String get supplierMgmtNoSuppliersMatchMessage =>
      'No suppliers match your search';

  @override
  String get supplierMgmtAddNewTitle => 'Add New Supplier';

  @override
  String get supplierMgmtEditTitle => 'Edit Supplier';

  @override
  String get supplierMgmtSaveChangesButton => 'Save Changes';

  @override
  String get supplierMgmtTaxVatNumberLabel => 'Tax/VAT Number (GSTIN)';

  @override
  String purchaseBillMgmtLoadErrorMessage(String error) {
    return 'Failed to load purchase bills: $error';
  }

  @override
  String get purchaseBillMgmtAlreadyFullyPaidMessage =>
      'This bill is already fully paid.';

  @override
  String purchaseBillMgmtMoveToTrashBody(String billNumber) {
    return 'Move bill \"$billNumber\" to trash? Stock will be reversed.';
  }

  @override
  String get purchaseBillMgmtMovedToTrashMessage =>
      'Purchase bill moved to trash.';

  @override
  String get purchaseBillMgmtRestoredMessage => 'Purchase bill restored.';

  @override
  String get purchaseBillMgmtSortByTitle => 'Sort By';

  @override
  String get purchaseBillMgmtSortDateNewest => 'Date (Newest First)';

  @override
  String get purchaseBillMgmtSortDateOldest => 'Date (Oldest First)';

  @override
  String get purchaseBillMgmtSortSupplierAZ => 'Supplier (A-Z)';

  @override
  String get purchaseBillMgmtSortSupplierZA => 'Supplier (Z-A)';

  @override
  String get purchaseBillMgmtSortAmountHighest => 'Amount (Highest First)';

  @override
  String get purchaseBillMgmtSortAmountLowest => 'Amount (Lowest First)';

  @override
  String get purchaseBillMgmtFilterTitle => 'Filter Purchase Bills';

  @override
  String get purchaseBillMgmtPaymentStatusLabel => 'Payment Status';

  @override
  String get purchaseBillMgmtSearchHint =>
      'Search by bill number or supplier...';

  @override
  String get purchaseBillMgmtNewBillButton => 'New Purchase Bill';

  @override
  String get purchaseBillMgmtColBill => 'Bill';

  @override
  String get purchaseBillMgmtColBalance => 'Balance';

  @override
  String purchaseBillMgmtTotalCountLabel(int count) {
    return 'Total: $count';
  }

  @override
  String get purchaseBillMgmtNoBillsFoundTitle => 'No purchase bills found';

  @override
  String get purchaseBillMgmtCreateFirstMessage =>
      'Create your first purchase bill to get started';

  @override
  String get purchaseBillMgmtTryAdjustingMessage =>
      'Try adjusting your search or filters';

  @override
  String get purchaseBillMgmtTitle => 'Purchase Bills';

  @override
  String get purchaseBillMgmtUnknownSupplierLabel => 'Unknown supplier';

  @override
  String get purchaseBillMgmtNotesSectionLabel => 'Notes';

  @override
  String get purchaseBillMgmtItemsSectionLabel => 'Items';

  @override
  String get purchaseBillMgmtGrandTotalLabel => 'Grand Total';

  @override
  String get purchaseBillMgmtBillDetailsTitle => 'Bill Details';

  @override
  String get purchaseBillMgmtExistingSupplierLabel => 'Existing Supplier';

  @override
  String get purchaseBillMgmtWalkInSupplierLabel => 'Walk-in Supplier';

  @override
  String get purchaseBillMgmtSupplierRequiredLabel => 'Supplier *';

  @override
  String get purchaseBillMgmtBillNumberOptionalLabel =>
      'Bill Number (optional)';

  @override
  String get purchaseBillMgmtAutoGenerateHint => 'Auto generate';

  @override
  String get purchaseBillMgmtBillDateRequiredLabel => 'Bill Date *';

  @override
  String get purchaseBillMgmtPickDateTooltip => 'Pick date';

  @override
  String get purchaseBillMgmtAddAnyNotesHint => 'Add any notes';

  @override
  String get purchaseBillMgmtAttachmentOptionalLabel => 'Attachment (optional)';

  @override
  String get purchaseBillMgmtAttachFileHint => 'Attach file';

  @override
  String get purchaseBillMgmtBrowseTooltip => 'Browse';

  @override
  String get purchaseBillMgmtSelectSupplierMessage =>
      'Please select a supplier or switch to walk-in.';

  @override
  String get purchaseBillMgmtEnterSupplierNameMessage =>
      'Please enter a supplier name.';

  @override
  String get purchaseBillMgmtAddAtLeastOneItemMessage =>
      'Add at least one item.';

  @override
  String get purchaseBillMgmtUpdatedMessage => 'Purchase bill updated!';

  @override
  String get purchaseBillMgmtCreatedMessage => 'Purchase bill created!';

  @override
  String get purchaseBillMgmtDraftSavedMessage =>
      'Draft saved — stock not updated';

  @override
  String purchaseBillMgmtSaveErrorMessage(String error) {
    return 'Error saving purchase bill: $error';
  }

  @override
  String get purchaseBillMgmtEnterNameMessage => 'Enter a name';

  @override
  String get purchaseBillMgmtAddCustomItemTitle => 'Add Custom Item';

  @override
  String get purchaseBillMgmtDescriptionOptionalLabel =>
      'Description (optional)';

  @override
  String get purchaseBillMgmtQuantityLabel => 'Quantity';

  @override
  String get purchaseBillMgmtCostPerUnitLabel => 'Cost/unit';

  @override
  String get purchaseBillMgmtCostIncludesTaxLabel => 'Cost/unit includes tax';

  @override
  String get purchaseBillMgmtEnterItemNameMessage => 'Enter an item name';

  @override
  String get purchaseBillMgmtInvalidValueMessage => 'Invalid';

  @override
  String get purchaseBillMgmtEditItemTitle => 'Edit Item';

  @override
  String get purchaseBillMgmtEditItemTooltip => 'Edit item';

  @override
  String get purchaseBillMgmtRemoveItemTooltip => 'Remove item';

  @override
  String get purchaseBillMgmtNoItemsAddedMessage => 'No items added yet';

  @override
  String purchaseBillMgmtLastCostLabel(String amount) {
    return 'Last cost: $amount';
  }

  @override
  String get purchaseBillMgmtSearchProductsHint => 'Search products to add...';

  @override
  String get purchaseBillMgmtCustomBadgeLabel => 'Custom';

  @override
  String get purchaseBillMgmtQtyDetailLabel => 'Qty';

  @override
  String get purchaseBillMgmtUnitCostDetailLabel => 'Unit Cost';

  @override
  String purchaseBillMgmtTaxInclusiveLabel(String rate) {
    return '$rate% Inclusive';
  }

  @override
  String get purchaseBillMgmtNetCostDetailLabel => 'Net Cost';

  @override
  String get purchaseBillMgmtEditPurchaseBillTitle => 'Edit Purchase Bill';

  @override
  String get purchaseBillMgmtUpdateSubtitle => 'Update this purchase bill';

  @override
  String get purchaseBillMgmtCreateSubtitle =>
      'Create a new purchase bill for your supplier';

  @override
  String get purchaseBillMgmtSaveDraftButton => 'Save Draft';

  @override
  String get purchaseBillMgmtSavePurchaseBillButton => 'Save Purchase Bill';

  @override
  String get purchaseBillMgmtSelectSupplierFromListMessage =>
      'Select a supplier from the list';

  @override
  String get purchaseBillMgmtSearchSupplierHint => 'Search supplier';

  @override
  String get purchaseBillMgmtColItem => 'Item';

  @override
  String get purchaseBillMgmtColCost => 'Cost';

  @override
  String get purchaseBillMgmtColTaxPercent => 'Tax %';

  @override
  String get purchaseBillMgmtPaymentRecordedMessage => 'Payment recorded.';

  @override
  String get invoiceSettingsMetadataColumnsGridClassicNote =>
      'Note: Metadata columns print on A4 PDF templates only (not A5/A6 or thermal receipts).';

  @override
  String get invoiceSettingsCustomFieldsPageSupportNote =>
      'Custom fields print on every PDF template except thermal receipts.';

  @override
  String get docTypeCreditNote => 'Credit Note';

  @override
  String get docTypeDebitNote => 'Debit Note';

  @override
  String returnScreenTitleReturnItems(String number) {
    return 'Return Items — $number';
  }

  @override
  String returnScreenTitleSalesReturn(String number) {
    return 'Credit Note (Sales Return) — $number';
  }

  @override
  String returnSelectedCount(int count, String amount) {
    return '$count items · $amount';
  }

  @override
  String get returnSearchHint => 'Search product or HSN';

  @override
  String get returnAllButton => 'Return all';

  @override
  String get returnOnlySelectedChip => 'Only selected';

  @override
  String get returnColProduct => 'Product';

  @override
  String get returnColSold => 'Sold';

  @override
  String get returnColReturned => 'Returned';

  @override
  String get returnColLeft => 'Left';

  @override
  String get returnColToStock => 'To stock';

  @override
  String get returnDetailsSection => 'Totals, reason & settlement';

  @override
  String get returnDiscardTitle => 'Discard this return?';

  @override
  String get returnDiscardBody => 'The quantities you entered will be lost.';

  @override
  String get returnVoidNoteTooltip => 'Void this note';

  @override
  String returnCustomerLabel(String name) {
    return 'Customer: $name';
  }

  @override
  String returnLineSold(String qty) {
    return 'Sold $qty';
  }

  @override
  String returnLineReturned(String qty) {
    return 'returned $qty';
  }

  @override
  String returnLineLeft(String qty) {
    return 'left $qty';
  }

  @override
  String get returnFieldReturn => 'Return';

  @override
  String get returnToStockTooltip => 'Return to stock';

  @override
  String get returnSubtotalLabel => 'Return subtotal';

  @override
  String get returnTotalLabel => 'Credit note total';

  @override
  String get returnReasonLabel => 'Reason';

  @override
  String get returnReasonNoteLabel => 'Reason note (optional)';

  @override
  String get returnReasonDamaged => 'Damaged / defective';

  @override
  String get returnReasonWrongItem => 'Wrong item delivered';

  @override
  String get returnReasonNotRequired => 'Not required';

  @override
  String get returnReasonQualityIssue => 'Quality issue';

  @override
  String get returnReasonOther => 'Other';

  @override
  String get returnReasonPriceRevision => 'Price revision';

  @override
  String get returnReasonGoodsReturned => 'Goods returned';

  @override
  String get returnReasonBillingCorrection => 'Billing correction';

  @override
  String get returnReasonGoodwill => 'Goodwill / discount';

  @override
  String get returnSettlementLabel => 'Settlement';

  @override
  String returnSettlementReduceInvoice(String amount) {
    return 'Reduce invoice balance (owes $amount)';
  }

  @override
  String get returnSettlementRefundNow => 'Refund now';

  @override
  String get returnSettlementRefundCash => 'Refund now (cash)';

  @override
  String get returnSettlementKeepCredit => 'Keep as customer credit';

  @override
  String get returnRefundMethodLabel => 'Refund method';

  @override
  String get returnValidationNoQty => 'Enter a quantity for at least one line.';

  @override
  String returnValidationMaxQty(String product, String qty) {
    return '$product: cannot return more than $qty.';
  }

  @override
  String returnCreatedMessage(String amount) {
    return 'Credit note created for $amount.';
  }

  @override
  String returnCreateError(String error) {
    return 'Could not create credit note: $error';
  }

  @override
  String get returnPrintVoucher => 'Refund voucher';

  @override
  String get returnsBannerTitle => 'New: Product returns';

  @override
  String get returnsBannerSubtitle =>
      'Use “Return Items” in an invoice\'s menu to take goods back, refund the customer or keep it as credit. Advanced Credit / Debit Notes can be turned on in Settings → Accessibility.';

  @override
  String get returnNotePdfTooltip => 'Note PDF';

  @override
  String get actionPrintRefundVoucher => 'રિફંડ વાઉચર';

  @override
  String get returnNoRefundsMessage =>
      'No refunds recorded for this credit note';

  @override
  String get returnPickRefundTitle => 'Refund vouchers';

  @override
  String get returnCreateButton => 'Create';

  @override
  String get returnAgainstInvoiceLabel => 'Against invoice # (optional)';

  @override
  String get returnAgainstReceiptLabel => 'Against receipt #';

  @override
  String returnApplyCreditAction(String amount) {
    return 'Apply $amount credit';
  }

  @override
  String get returnCreditAppliedMessage => 'Customer credit applied.';

  @override
  String get returnNotesSectionTitle => 'Credit / Debit Notes';

  @override
  String returnCreditFromNote(String note, String amount) {
    return 'From Credit Note #$note: $amount';
  }

  @override
  String returnCreditFromNoteAgainst(
      String note, String invoice, String amount) {
    return 'From Credit Note #$note (against #$invoice): $amount';
  }

  @override
  String returnAgainstInvoiceShort(String number) {
    return 'Against #$number';
  }

  @override
  String returnAgainstInvoiceNotFound(String number) {
    return 'Invoice #$number not found for this customer';
  }

  @override
  String get returnPickInvoiceTitle => 'Select invoice';

  @override
  String get returnPickInvoiceSearchHint => 'Search invoice number';

  @override
  String get returnPickInvoiceEmpty => 'No invoices for this customer';

  @override
  String get returnSelectCustomerFirst => 'Select a customer first';

  @override
  String get productFormDuplicateTitle => 'Product already exists';

  @override
  String productFormDuplicateMessage(String name) {
    return 'A product named \"$name\" already exists. Create another one anyway?';
  }

  @override
  String get productFormCreateAnywayButton => 'Create anyway';

  @override
  String get productFormNewProductButton => 'New product';

  @override
  String get productFormPurchaseStockHelper =>
      'Opening stock. Finalizing this purchase bill adds the purchased quantity on top.';

  @override
  String get invoiceDraftBadge => 'DRAFT';

  @override
  String get createInvoiceStockShortTitle => 'Not enough stock';

  @override
  String get createInvoiceStockShortMessage =>
      'Some items have less stock than this invoice needs:';

  @override
  String createInvoiceStockShortLine(
      String product, String available, String needed, String short) {
    return '$product: in stock $available, on invoice $needed (short by $short)';
  }

  @override
  String get createInvoiceStockShortFooter =>
      'If you save, stock will go below zero.';

  @override
  String get createInvoiceGoBackButton => 'Go back';

  @override
  String get createInvoiceSaveAnywayButton => 'Save anyway';

  @override
  String get createInvoiceSaveDraftButton => 'Save Draft';

  @override
  String get createInvoiceDraftSavedMessage => 'Draft saved';

  @override
  String createInvoiceFinalizeButton(String type) {
    return 'Finalize $type';
  }

  @override
  String createInvoiceFinalizedMessage(String type, String number) {
    return 'Finalized — $type #$number';
  }

  @override
  String get createInvoiceDraftPrintTooltip =>
      'Finalize the draft to get an invoice number before printing';

  @override
  String get createInvoiceLockedByCreditNotes =>
      'This invoice has credit notes, so customer, items, extra costs, discount and tax are locked. Void the credit notes to change them.';

  @override
  String returnNothingLeft(String number) {
    return 'Everything on invoice #$number has already been returned.';
  }

  @override
  String invoiceMgmtDebitNoteRestoreBlocked(String number) {
    return 'Invoice #$number is declined or in trash, so this note can\'t be restored.';
  }

  @override
  String invoiceMgmtHasCreditNotesMessage(String number) {
    return 'Invoice #$number has credit or debit notes. Void its credit notes and trash its debit notes first.';
  }

  @override
  String invoiceMgmtDeclineHasCreditNotesMessage(String number) {
    return 'Invoice #$number has credit or debit notes. Void its credit notes and trash its debit notes before declining.';
  }

  @override
  String invoiceMgmtHasDraftNotesMessage(String number) {
    return 'Invoice #$number has a draft credit or debit note. Finalize or trash it from the Credit Notes / Debit Notes tab first.';
  }

  @override
  String get createInvoiceFinalizeDateTitle => 'Use today\'s date?';

  @override
  String createInvoiceFinalizeDateMessage(String date) {
    return 'This draft is dated $date. Invoice numbers should follow date order, so finalizing usually takes today\'s date.';
  }

  @override
  String createInvoiceFinalizeKeepDateButton(String date) {
    return 'Keep $date';
  }

  @override
  String get createInvoiceFinalizeUseTodayButton => 'Use today';

  @override
  String get returnGstAgainstInvoiceWarning =>
      'GST: a note for a registered customer should reference the original invoice';

  @override
  String returnAgainstInvoiceFull(String number) {
    return 'Against Invoice #$number';
  }

  @override
  String returnAgainstReceiptFull(String number) {
    return 'Against Receipt #$number';
  }

  @override
  String get returnCopyInvoiceNumberTooltip => 'Copy invoice number';

  @override
  String get returnInvoiceNumberCopiedMessage => 'Invoice number copied';

  @override
  String get returnCopyNoteNumberTooltip => 'Copy note number';

  @override
  String get returnNoteNumberCopiedMessage => 'Note number copied';

  @override
  String returnBadgeCreditNote(String amount) {
    return 'CN −$amount';
  }

  @override
  String returnBadgeDebitNote(String amount) {
    return 'DN +$amount';
  }

  @override
  String get returnSettledCustomerCredit => 'Kept as customer credit';

  @override
  String get returnSettledRefund => 'Refunded';

  @override
  String get returnSettledReduceInvoice => 'Reduced this invoice\'s balance';

  @override
  String get returnApplyCreditToInvoiceLabel =>
      'Apply customer credit to this invoice';

  @override
  String returnCreditAvailableLabel(String amount) {
    return 'Credit available: $amount';
  }

  @override
  String get returnApplyCustomerCreditAction => 'Apply customer credit';

  @override
  String get returnNoCustomerCreditMessage =>
      'This customer has no credit available.';

  @override
  String returnApplyCreditConfirmBody(String amount, String number) {
    return 'Apply $amount of this customer\'s credit to $number?';
  }

  @override
  String returnCreditApplyErrorMessage(String error) {
    return 'Could not apply credit: $error';
  }

  @override
  String refundDialogTitle(String number) {
    return 'Refund — $number';
  }

  @override
  String refundAvailableCredit(String amount) {
    return 'Available credit: $amount';
  }

  @override
  String get refundAmountLabel => 'Amount';

  @override
  String get refundMethodLabel => 'Method';

  @override
  String get refundNotesLabel => 'Notes (optional)';

  @override
  String get refundRecordButton => 'Record';

  @override
  String refundValidationRange(String max) {
    return 'Enter an amount between 0 and $max.';
  }

  @override
  String refundRecordedMessage(String amount) {
    return 'Refund of $amount recorded.';
  }

  @override
  String refundRecordError(String error) {
    return 'Could not record refund: $error';
  }

  @override
  String get returnsSettingTitle => 'Credit / Debit Notes (advanced)';

  @override
  String get returnsSettingSubtitle =>
      'Adds Credit Notes and Debit Notes screens, debit notes, standalone notes and number prefixes. Returns are always available from the invoice menu.';

  @override
  String get creditNotePrefixLabel => 'Credit note prefix';

  @override
  String get debitNotePrefixLabel => 'Debit note prefix';

  @override
  String get quotationPrefixLabel => 'Quotation prefix';

  @override
  String get receiptPrefixLabel => 'Receipt prefix';

  @override
  String get prefixSameAsInvoiceHelper =>
      'Leave empty to use the invoice prefix';

  @override
  String get actionReturnItems => 'માલ પરત';

  @override
  String get actionCreateDebitNote => 'ડેબિટ નોટ બનાવો';

  @override
  String get actionCreateCreditNoteSalesReturn =>
      'ક્રેડિટ નોટ બનાવો (વેચાણ પરત)';

  @override
  String get actionRefund => 'રિફંડ';

  @override
  String get actionCancelVoid => 'રદ / અમાન્ય કરો';

  @override
  String get voidCreditNoteTitle => 'Cancel this credit note?';

  @override
  String voidCreditNoteBody(String number) {
    return 'Reverses the restock and settlement for $number and moves it to trash. Blocked if any of its credit was already applied to an invoice or refunded.';
  }

  @override
  String get voidCreditNoteKeep => 'Keep';

  @override
  String get creditNoteCancelledMessage => 'Credit note cancelled.';

  @override
  String creditNoteCancelError(String error) {
    return 'Could not cancel: $error';
  }

  @override
  String get invoiceMgmtCancelVoidAction => 'Cancel / Void';

  @override
  String get invoiceMgmtDeclineReturnStockLabel => 'Return all items to stock';

  @override
  String get invoiceMgmtDeclineReturnStockHint =>
      'Untick if the goods didn\'t come back (damaged, used or kept).';

  @override
  String get invoiceMgmtDeclinedNoStockMessage =>
      'Sale cancelled (void). Stock unchanged.';

  @override
  String get invoiceMgmtTrashNoStockHint =>
      'Trash doesn\'t return stock. To cancel a sale, use Cancel / Void.';

  @override
  String get amountSeparatorLabel => 'Number format';

  @override
  String get amountSeparatorNoneLabel => 'No separator  (1234567.89)';

  @override
  String get amountSeparatorInternationalLabel =>
      'International  (1,234,567.89)';

  @override
  String get amountSeparatorIndianLabel => 'Indian  (12,34,567.89)';

  @override
  String get customizationQuoteBadge => 'Get a quote';

  @override
  String contactMailUnavailableMessage(String email) {
    return 'No mail app found. Write to us at $email.';
  }

  @override
  String get aboutContactTitle => 'CONTACT';

  @override
  String get aboutContactSupportLabel => 'Support';

  @override
  String get aboutContactInfoLabel => 'Info';

  @override
  String get aboutContactBusinessLabel => 'Business';

  @override
  String get aboutOpenSourceLicensesTitle => 'Open-source licenses';

  @override
  String get aboutOpenSourceLicensesSubtitle =>
      'Notices for the software and fonts CrizaVoise is built on';

  @override
  String get aboutPackageLicensesButton => 'Flutter package licenses';

  @override
  String aboutRightsReserved(int year, String maker) {
    return '© $year $maker. All rights reserved.';
  }

  @override
  String get aboutLicensesLoadError =>
      'Couldn\'t load the notices. Please reinstall CrizaVoise.';

  @override
  String get imageImportLogoHint =>
      'કોઈપણ સાઇઝ ચાલશે — અમે જાતે ગોઠવી દઈશું.\nશ્રેષ્ઠ: પારદર્શક પૃષ્ઠભૂમિવાળો ચોરસ PNG, ઓછામાં ઓછો 600 × 600 px.';

  @override
  String get imageImportSignatureHint =>
      'Any size works — we resize it for you. Best: PNG with a transparent background and dark ink, about 600 × 200 px.';

  @override
  String get imageImportWatermarkHint =>
      'Any size works — we resize it for you. Best: a light PNG with a transparent background, at least 1200 px wide.';

  @override
  String get imageImportAddedMessage => 'છબી ઉમેરાઈ ગઈ.';

  @override
  String imageImportResizedMessage(String from, String to) {
    return 'Image added — resized from $from to $to px so it prints sharp and keeps the app fast.';
  }

  @override
  String imageImportTooSmallMessage(String size, String min) {
    return 'Image added, but it is only $size px and may look blurry when printed. For best results use at least $min px.';
  }

  @override
  String get imageImportUnreadableMessage =>
      'We couldn\'t read this image. Please choose a PNG or JPG file.';

  @override
  String imageImportFileTooLargeMessage(String max) {
    return 'This file is larger than $max MB. Please choose a smaller image.';
  }

  @override
  String get customNumbersSettingTitle => 'પોતાનો ઇન્વૉઇસ નંબર';

  @override
  String get customNumbersSettingSubtitle =>
      'Invoice numbers are automatic. Allow typing your own number, for example to match a paper bill book or an existing series.';

  @override
  String get customNumbersAccessOff => 'Off';

  @override
  String get customNumbersAccessAdmins => 'Admins only';

  @override
  String get customNumbersAccessEveryone => 'Admins and staff';

  @override
  String get customNumbersSafeguards =>
      'Safeguards: numbers must be unique and use up to 16 letters, digits, \"-\" or \"/\" (GST rule). Changing the number of an existing invoice is admin-only and needs a reason and your password. Every change is recorded.';

  @override
  String get invoiceNumberEditTooltip => 'તમારો પોતાનો નંબર લખો';

  @override
  String get invoiceNumberDialogTitle => 'Invoice number';

  @override
  String invoiceNumberAutoLabel(String number) {
    return 'Automatic number: $number';
  }

  @override
  String get invoiceNumberCustomFieldLabel => 'Your number';

  @override
  String get invoiceNumberFieldHint => 'Letters, numbers, - or /';

  @override
  String get invoiceNumberUseAutoAction => 'Use automatic';

  @override
  String get invoiceNumberUseThisAction => 'Use this number';

  @override
  String get invoiceNumberManualBadge => 'હાથથી';

  @override
  String get invoiceNumberIssueEmpty => 'Enter a number.';

  @override
  String get invoiceNumberIssueInvalid =>
      'Use only letters, numbers, \"-\" or \"/\".';

  @override
  String get invoiceNumberIssueTooLong =>
      'Too long — with the prefix it must be 16 characters or fewer (GST rule).';

  @override
  String get invoiceNumberIssueDuplicate =>
      'આ નંબર પહેલેથી વપરાયેલો છે. દરેક નંબર અલગ હોવો જોઈએ.';

  @override
  String get invoiceNumberChangeAction => 'ઇન્વૉઇસ નંબર બદલો';

  @override
  String get invoiceNumberChangeWarning =>
      'Only change a number to fix a mistake or to match your paper records. The change is recorded with your name and reason.';

  @override
  String invoiceNumberCurrentLabel(String number) {
    return 'Current number: $number';
  }

  @override
  String get invoiceNumberNewLabel => 'New number';

  @override
  String get invoiceNumberReasonLabel => 'Reason (required)';

  @override
  String get invoiceNumberPasswordLabel => 'Your password';

  @override
  String get invoiceNumberReasonMissing => 'Please write a short reason.';

  @override
  String get invoiceNumberPasswordWrong => 'Wrong password.';

  @override
  String get invoiceNumberNoPermission =>
      'You don\'t have permission to change invoice numbers.';

  @override
  String invoiceNumberChangedMessage(String number) {
    return 'Invoice number changed to $number.';
  }

  @override
  String get invoiceNumberHistoryTitle => 'Change history';

  @override
  String invoiceNumberHistoryEntry(
      String oldNumber, String newNumber, String user, String date) {
    return '$oldNumber → $newNumber · $user · $date';
  }

  @override
  String get invoiceNumberHistoryNone => 'No changes yet.';

  @override
  String get termsTitle => 'શરૂ કરતા પહેલા';

  @override
  String get termsIntro =>
      'કૃપા કરીને ઉપયોગની શરતો અને ગોપનીયતા નીતિ વાંચીને સ્વીકારો. મુખ્ય વાતો, સરળ શબ્દોમાં:';

  @override
  String get termsPointYourBusiness =>
      'CrizaVoise એક સાધન છે. તમારા ઇન્વૉઇસ, રકમ, ટેક્સ (GST) અને કાયદાનું પાલન તમારી જવાબદારી છે.';

  @override
  String get termsPointCheckDocuments =>
      'ગ્રાહકને આપતા પહેલા દરેક ઇન્વૉઇસ તપાસો.';

  @override
  String get termsPointBackups =>
      'તમારો ડેટા આ જ ઉપકરણ પર રહે છે. નિયમિત બેકઅપ લો — ખોવાયેલો ડેટા અમે પાછો લાવી શકતા નથી.';

  @override
  String get termsPointNoWarranty =>
      'સોફ્ટવેર \"જેમ છે તેમ\" આપવામાં આવે છે, કોઈ ગેરંટી વિના. આર્થિક નુકસાન, ડેટા ખોવાઈ જવા, ટેક્સ દંડ કે ક્રેશ માટે Criza Labs જવાબદાર નથી.';

  @override
  String get termsPointPricing =>
      '30 દિવસ મફત, પછી નવા દસ્તાવેજ બનાવવા માટે પેઇડ લાઇસન્સ (6 મહિના, 1 વર્ષ અથવા લાઇફટાઇમ). તમારો ડેટા ક્યારેય લૉક થતો નથી: જોવું, પ્રિન્ટ અને એક્સપોર્ટ હંમેશા ચાલે છે.';

  @override
  String get termsPointPrivacy =>
      'અમે તમારો વ્યવસાય ડેટા એકત્ર કરતા નથી, જોતા નથી કે વેચતા નથી. કોઈ ટ્રેકિંગ નહીં, કોઈ જાહેરાત નહીં.';

  @override
  String get termsPointTalkFirst =>
      'કંઈ ખોટું થાય તો પહેલા info@criza.dev પર લખો અને અમને સુધારવા માટે 30 દિવસ આપો.';

  @override
  String get termsReadTerms => 'ઉપયોગની શરતો વાંચો';

  @override
  String get termsReadPrivacy => 'ગોપનીયતા નીતિ વાંચો';

  @override
  String get termsAgreeCheckbox =>
      'મેં ઉપયોગની શરતો અને ગોપનીયતા નીતિ વાંચી છે અને હું સંમત છું';

  @override
  String get termsContinueButton => 'સંમત થઈને આગળ વધો';

  @override
  String get termsOfUseTitle => 'ઉપયોગની શરતો';

  @override
  String get privacyPolicyTitle => 'ગોપનીયતા નીતિ';

  @override
  String get productQuickCodeLabel => 'ક્વિક કોડ';

  @override
  String get productQuickCodeHelper =>
      'બિલ બનાવતી વખતે આ વસ્તુ ઝડપથી શોધવાનો નાનો કોડ — જેમ કે R5 અથવા 101';

  @override
  String get productQuickCodeSuggest => 'કોડ સૂચવો';

  @override
  String get productQuickCodeInvalid => '12 સુધી અક્ષર, અંક અથવા \"-\" વાપરો.';

  @override
  String get productQuickCodeTaken => 'આ કોડ બીજી વસ્તુમાં વપરાયેલો છે.';

  @override
  String get productMgmtCsvDescQuickCode =>
      'Optional short code for fast search (letters, numbers, -; unique). Codes already used by another item are skipped.';

  @override
  String get productSearchByCodeHint => 'Name, quick code or HSN';

  @override
  String get navMore => 'વધુ';

  @override
  String get reduceMotionTitle => 'ઍનિમેશન ઘટાડો';

  @override
  String get reduceMotionSubtitle =>
      'ઍનિમેશનને સાદા ફેડ સુધી ઘટાડો. તમારા કમ્પ્યુટરની સેટિંગ પણ માન્ય છે.';

  @override
  String get whatsAppShareAction => 'WhatsApp પર મોકલો';

  @override
  String whatsAppMessage(
      String customer, String number, String amount, String company) {
    return 'નમસ્તે $customer, $company તરફથી તમારું ઇન્વૉઇસ $number, રકમ $amount. તમારા વ્યવસાય માટે આભાર!';
  }

  @override
  String whatsAppMessageUpi(String upiId) {
    return 'UPI થી ચૂકવો: $upiId';
  }

  @override
  String get whatsAppGuideTitle => 'ઇન્વૉઇસ WhatsApp પર મોકલો';

  @override
  String get whatsAppStepSaved =>
      'PDF સાચવાઈ ગઈ છે અને તેનું ફોલ્ડર ખુલ્યું છે.';

  @override
  String get whatsAppStepChatOpened =>
      'WhatsApp માં ગ્રાહકની ચેટ તૈયાર સંદેશ સાથે ખુલી છે.';

  @override
  String get whatsAppStepPickChat =>
      'WhatsApp ખુલ્યું — ગ્રાહક પસંદ કરો (ફોન નંબર સાચવેલો ન હતો).';

  @override
  String get whatsAppStepDrag => 'ફોલ્ડરમાંથી PDF ખેંચીને ચેટમાં મૂકો.';

  @override
  String get whatsAppStepSend => 'મોકલો દબાવો.';

  @override
  String get whatsAppShowFile => 'PDF ફરી બતાવો';

  @override
  String get whatsAppDone => 'થઈ ગયું';

  @override
  String get whatsAppShareFailed =>
      'ઇન્વૉઇસ મોકલવા માટે તૈયાર ન થઈ શક્યું. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get speakReadAloud => 'વાંચીને સંભળાવો';

  @override
  String get speakStop => 'સંભળાવવાનું બંધ કરો';

  @override
  String get speakRupees => 'રૂપિયા';

  @override
  String speakInvoiceIntro(String number, String customer) {
    return '$customer નું ઇન્વૉઇસ $number.';
  }

  @override
  String speakInvoiceTotal(String amount, String currency) {
    return 'કુલ $amount $currency.';
  }

  @override
  String get speakInvoicePaid => 'પૂરી ચુકવણી થઈ ગઈ છે.';

  @override
  String speakInvoicePartlyPaid(String amount) {
    return 'હજુ $amount બાકી છે.';
  }

  @override
  String speakInvoiceDue(String date) {
    return 'ચુકવણીની તારીખ $date.';
  }

  @override
  String get rupeeSymbolLabel => 'નવા દસ્તાવેજો પર રૂપિયાનું ચિહ્ન';

  @override
  String get rupeeSymbolHelp =>
      'જૂના ઇન્વૉઇસનું ચિહ્ન બદલાતું નથી. થર્મલ રસીદ પર હંમેશા \"Rs.\" છપાય છે કારણ કે રસીદ પ્રિન્ટરમાં ₹ ચિહ્ન નથી.';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionContinue => 'Continue';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authPasswordTooShort =>
      'Use at least 8 characters for the password.';

  @override
  String get authPasswordIsUsername =>
      'The password can\'t be the same as the username.';

  @override
  String get authPasswordsDontMatch => 'The two passwords don\'t match.';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authUsernameHelp =>
      'You\'ll type this to sign in. Letters, numbers and . _ - @ (3–32 characters).';

  @override
  String get authUsernameRule =>
      'Use 3–32 letters, numbers or . _ - @ for the username (no spaces).';

  @override
  String get authUsernameTaken =>
      'That username is already used in this company.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHelp =>
      'At least 8 characters. A short sentence is easy to remember and hard to guess.';

  @override
  String get authConfirmPasswordLabel => 'Type the password again';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountIntro =>
      'Choose the username and password you\'ll use to open CrizaVoise. You\'ll be the admin of this company.';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get createAccountPrivacyNote =>
      'Your account stays on this computer. Nothing is sent online.';

  @override
  String get recoveryCodeTitle => 'Recovery code';

  @override
  String get recoveryCodeIntro =>
      'If you ever forget your password, this code lets you set a new one. It\'s shown only now, so keep it somewhere safe.';

  @override
  String get recoveryCodeCopied => 'Recovery code copied.';

  @override
  String get recoveryCodeSave => 'Save as file';

  @override
  String recoveryCodeSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get recoveryCodeFileHelp =>
      'Keep this file private. On the sign-in screen choose \"Forgot password?\" and enter this code to set a new password. Each code works once; a new one is shown after use.';

  @override
  String get recoveryCodeTipWrite =>
      'Write it down, or save the file on a pen drive or phone.';

  @override
  String get recoveryCodeTipPrivate =>
      'Anyone with this code can reset your password, so keep it private.';

  @override
  String get recoveryCodeTipOnce =>
      'Each code works once. After using it you\'ll get a new one.';

  @override
  String get recoveryCodeConfirm => 'I\'ve saved my recovery code';

  @override
  String get recoveryCodeLater => 'Later';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotIntro =>
      'No problem. Choose how you\'d like to get back in.';

  @override
  String forgotIntroCompany(String company) {
    return 'No problem. Choose how you\'d like to get back in to $company.';
  }

  @override
  String get forgotUseRecoveryCode => 'Use my recovery code';

  @override
  String get forgotUseRecoveryCodeHelp =>
      'The code you saved when you created your account.';

  @override
  String get forgotAskSupport => 'Get a code from Criza Labs';

  @override
  String get forgotAskSupportHelp =>
      'If you lost your recovery code. We\'ll check it\'s you first.';

  @override
  String get forgotAskAdmin =>
      'Not the admin? Ask your admin to reset your password in Settings → Users.';

  @override
  String get forgotBackToLogin => 'Back to sign in';

  @override
  String get forgotRecoveryCodeIntro =>
      'Enter your username and recovery code. Spaces, dashes and capitals don\'t matter.';

  @override
  String get forgotSupportIntro =>
      'Email us this installation ID. After we confirm you own this business, we\'ll send a one-time code that works for about 3 days on this computer only.';

  @override
  String get forgotEmailSupport => 'Email support';

  @override
  String get forgotSupportCodeLabel => 'Code from Criza Labs';

  @override
  String get forgotVerify => 'Check code';

  @override
  String get forgotEnterUsernameAndCode => 'Enter your username and the code.';

  @override
  String get forgotCodeInvalid =>
      'That username and code don\'t match, or the code has expired.';

  @override
  String get forgotNewPasswordTitle => 'Choose a new password';

  @override
  String forgotNewPasswordFor(String username) {
    return 'For $username';
  }

  @override
  String get forgotSetPassword => 'Save new password';

  @override
  String get forgotPasswordDone =>
      'Password changed. Sign in with your new password.';

  @override
  String get forgotInstallationIdLabel => 'Installation ID';

  @override
  String get forgotInstallationIdCopied => 'Installation ID copied.';

  @override
  String get loginSetupTitle => 'Welcome to CrizaVoise';

  @override
  String get loginSetupBody =>
      'First, create the account you\'ll sign in with. It takes a minute.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginInvalidCredentials => 'Wrong username or password.';

  @override
  String get licenseTitle => 'Licence';

  @override
  String get licensePlanSixMonths => '6 months';

  @override
  String get licensePlanOneYear => '1 year';

  @override
  String get licensePlanLifetime => 'Lifetime';

  @override
  String get licensePlanSixMonthsHelp => 'Try it for a season.';

  @override
  String get licensePlanOneYearHelp => 'Best for most shops.';

  @override
  String get licensePlanLifetimeHelp => 'Pay once, use for good.';

  @override
  String get licenseActivated =>
      'Licence activated. Thank you for supporting CrizaVoise!';

  @override
  String get licenseErrorInvalid =>
      'This key isn\'t valid. Check that you copied all of it, starting with CV1.';

  @override
  String get licenseErrorOtherDevice =>
      'This key is for a different computer. Send us the device code shown above.';

  @override
  String get licenseErrorExpired =>
      'This key has already expired. Contact us to renew.';

  @override
  String get licenseRemove => 'Remove licence from this computer';

  @override
  String get licenseRemoveConfirm =>
      'Remove the licence from this computer? Your data isn\'t touched, and you can enter the same key again later.';

  @override
  String get licenseClockWrong =>
      'Your computer\'s date looks earlier than before. Please set the correct date and time.';

  @override
  String get licenseDeviceCodeLabel => 'This computer\'s device code';

  @override
  String get licenseDeviceCodeHelp =>
      'Send this code when you buy or renew. A licence works on this computer.';

  @override
  String get licenseDeviceCodeCopied => 'Device code copied.';

  @override
  String get licensePlansTitle => 'Plans';

  @override
  String get licensePlansHelp =>
      'Every plan includes everything in CrizaVoise.';

  @override
  String get licenseEnterKeyTitle => 'Enter licence key';

  @override
  String get licenseEnterKeyLabel => 'Licence key';

  @override
  String get licenseEnterKeyHint =>
      'Paste the key you received (it starts with CV1.)';

  @override
  String get licenseActivate => 'Activate';

  @override
  String get licenseBuy => 'Buy or renew';

  @override
  String licenseNoMailApp(String email) {
    return 'No email app found. Write to $email with your device code.';
  }

  @override
  String licenseStatusTrial(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Free trial: $days days left',
      one: 'Free trial: 1 day left',
    );
    return '$_temp0';
  }

  @override
  String get licenseTrialBody =>
      'Everything is unlocked during the 30-day trial. When it ends your data stays safe: you can still view, print, export and back up. Creating new documents then needs a licence.';

  @override
  String get licenseStatusTrialEnded => 'Your free trial has ended';

  @override
  String get licenseEndedBody =>
      'Your data is safe. You can still view, print, share, export and back up everything. To create and save documents, activate a licence.';

  @override
  String get licenseStatusLicensed => 'Licensed';

  @override
  String get licenseNeverExpires => 'Lifetime licence: it never expires.';

  @override
  String licenseValidUntil(String date) {
    return 'Valid until $date.';
  }

  @override
  String get licenseStatusExpired => 'Your licence has expired';

  @override
  String get licenseLicensedTo => 'Licensed to';

  @override
  String get licensePlanLabel => 'Plan';

  @override
  String get licenseNumberLabel => 'Licence number';

  @override
  String get licenseIssuedLabel => 'Issued';

  @override
  String licenseBannerTrial(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left in your free trial.',
      one: '1 day left in your free trial.',
    );
    return '$_temp0';
  }

  @override
  String licenseBannerExpiring(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Your licence ends in $days days.',
      one: 'Your licence ends tomorrow.',
    );
    return '$_temp0';
  }

  @override
  String get licenseBannerEnded =>
      'View-only: you can still view, print and export. Activate a licence to create new documents.';

  @override
  String get licenseGateTitle => 'Activate CrizaVoise to save';

  @override
  String get licenseGateBody =>
      'Your free trial or licence has ended. Your data is safe, and you can still view, print, export and back up. To save documents, activate a licence.';

  @override
  String get licenseGateAction => 'Activate licence';

  @override
  String get quickActionNewInvoice => 'નવું ઇન્વૉઇસ';

  @override
  String get quickActionNewQuotation => 'નવું ક્વોટેશન';

  @override
  String get quickActionNewReceipt => 'નવી રસીદ';

  @override
  String get quickActionInvoices => 'ઇન્વૉઇસ શોધો';

  @override
  String get quickActionCustomers => 'ગ્રાહકો';

  @override
  String get quickActionProducts => 'ઉત્પાદનો અને સ્ટોક';
}
