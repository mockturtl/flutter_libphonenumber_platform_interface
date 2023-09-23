import 'package:flutter_libphonenumber_platform_interface/src/types/country_manager.dart';
import 'package:flutter_libphonenumber_platform_interface/src/types/country_with_phone_code.dart';
import 'package:flutter_libphonenumber_platform_interface/src/types/input_formatter.dart';
import 'package:flutter_libphonenumber_platform_interface/src/types/phone_mask.dart';
import 'package:flutter_libphonenumber_platform_interface/src/types/phone_number_format.dart';
import 'package:flutter_libphonenumber_platform_interface/src/types/phone_number_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneMask', () {
    test('UK mobile international', () {
      final mask = PhoneMask(
        const CountryWithPhoneCode.gb().getPhoneMask(
          format: PhoneNumberFormat.international,
          type: PhoneNumberType.mobile,
        ),
      );
      expect(mask.apply('+447752555555'), '+44 7752 555555');
    });

    test('Italian mobile international', () {
      final mask = PhoneMask('+00 000 000 0000');
      expect(mask.apply('+393937224790'), '+39 393 722 4790');
    });

    test('Austrian 11 character number', () {
      final mask = PhoneMask('+00 000 000 0000');
      expect(mask.apply('+393937224790'), '+39 393 722 4790');
    });

    group('getCountryDataByPhone', () {
      test('US number', () async {
        await CountryManager().loadCountries(
          phoneCodesMap: {},
          overrides: {'US': const CountryWithPhoneCode.us()},
        );

        final res = CountryWithPhoneCode.getCountryDataByPhone('+14194444444');
        expect(res?.countryCode, 'US');
      });
    });
  });

  group('getPhoneMask', () {
    late CountryWithPhoneCode subj;
    late PhoneNumberFormat fmt;
    group('intl format', () {
      setUp(() {
        subj = CountryWithPhoneCode.us();
        fmt = PhoneNumberFormat.international;
      });

      test('with removeCountryCodeFromMask=false', () async {
        final res = subj.getPhoneMask(
            format: fmt,
            type: PhoneNumberType.mobile,
            removeCountryCodeFromMask: false);

        expect(res, '+0 000-000-0000',
            reason: 'mask should contain country code in it');
      });

      test('with removeCountryCodeFromMask=true', () async {
        final res = subj.getPhoneMask(
            format: fmt,
            type: PhoneNumberType.mobile,
            removeCountryCodeFromMask: true);

        expect(res, '000-000-0000',
            reason: 'mask should not contain country code in it');
      });
    });

    group('national format', () {
      setUp(() => fmt = PhoneNumberFormat.national);

      test('ignores removeCountryCodeFromMask', () async {
        for (var flag in {true, false}) {
          final res = subj.getPhoneMask(
              format: fmt,
              type: PhoneNumberType.mobile,
              removeCountryCodeFromMask: flag);

          expect(res, '(000) 000-0000',
              reason: 'mask should not contain country code in it');
        }
      });
    });
  });

  group('LibPhonenumberTextFormatter', () {
    test('with inputContainsCountryCode=true', () {
      final formatter = LibPhonenumberTextFormatter(
        country: const CountryWithPhoneCode.us(),
        inputContainsCountryCode: true,
      );

      final formatResult = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '+14194444444'),
      );

      expect(
        formatResult.text,
        '+1 419-444-4444',
        reason:
            'formatting with a country code should apply the mask with the country code in it',
      );
    });

    test('with inputContainsCountryCode=false', () {
      final formatter = LibPhonenumberTextFormatter(
        country: const CountryWithPhoneCode.us(),
        inputContainsCountryCode: false,
      );

      final formatResult = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '4194444444'),
      );

      expect(
        formatResult.text,
        '419-444-4444',
        reason:
            'formatting with a country code should apply the mask with the country code in it',
      );
    });
  });
}
