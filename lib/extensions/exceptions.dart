import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/bases/exceptions.dart';
import 'package:flutter_core/localizations/localizations.dart';

extension MultiLanguageException on Exception {
  Exception parseMultiLanguage(BuildContext context) {
    final appLocalization = CoreLocalizations.of(context);

    Exception returnException =
        CommonException("Error! An error occurred.", rootCause: this);
    if (appLocalization != null) {
      try {
        returnException = CommonException('${appLocalization.commonException}',
            rootCause: this);
        throw (this);
      } on DioException {
        final DioException dioError = this as DioException;
        switch (dioError.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.badCertificate:
          case DioExceptionType.connectionError:
          case DioExceptionType.sendTimeout:
            returnException =
                CoreTimeoutException('${appLocalization.timeoutException}');
            break;
          case DioExceptionType.badResponse:
            returnException = CoreTimeoutException(
                '${appLocalization.noSuchMethodException}');
            break;
          case DioExceptionType.cancel:
            returnException = CancelRequestException(
                appLocalization.cancelRequestException,
                reason: dioError.error.toString());
            break;
          //bo qua neu khong xac dinh duoc exception duoc giau trong DioError
          case DioExceptionType.unknown:
            final rootException = dioError.error;
            if (rootException is Exception) {
              return rootException.parseMultiLanguage(context);
            }
        }
      } on SocketException {
        returnException =
            CoreSocketException('${appLocalization.socketException}');
      } on TimeoutException {
        returnException =
            CoreTimeoutException('${appLocalization.timeoutException}');
      } on AuthorizationException {
        returnException =
            AuthorizationException('${appLocalization.authorizationException}');
      } on NotFoundException {
        returnException =
            NotFoundException('${appLocalization.notFoundException}');
      } on UnsupportedLanguageException {
        UnsupportedLanguageException ex = this as UnsupportedLanguageException;
        String languageName = ex.language?.name ?? '';
        returnException = UnsupportedLanguageException(
            '${appLocalization.unsupportedLanguageException(languageName)}',
            ex.language);
      } on NotEnabledBioSecurityException {
        returnException = NotEnabledBioSecurityException(
            appLocalization.bioSecurityNotEnabled);
      } on ImplicitServerResponseError {
        returnException =
            ServerResponseError('${appLocalization.commonException}');
      } on ServerResponseError {
        //bo qua neu la message tu server
      } on Exception {
        returnException = CommonException('${appLocalization.commonException}',
            rootCause: this);
      } on NoSuchMethodError {
        returnException = CommonException(
            '${appLocalization.noSuchMethodException}',
            rootCause: this);
      }
    }
    return returnException;
  }
}
