import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static String of(BuildContext context, String key) {
    return _localizedValues[Localizations.localeOf(context).languageCode]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'add': 'Add',
      'currency': 'Currency',
      'reports': 'Reports',
      'total': 'Total',
      'events': 'Events',
      'rate': 'Rate',
      'quantity': 'Quantity',
      'select': 'Select',
      'main': 'Main',
      'cash': 'Cash',
      'users': 'Users',
      'clear': 'Clear',
      'trans': 'Transactions',
      'type': 'Type',
      'filter': 'Filter',
      'filterType': 'Filter by Type',
      'date': 'Date',
      'apply': 'Apply',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit Transaction',
      'soms': 'Soms left: ',
      'profitTot': 'Total profit: ',
      'sold': 'SOLD',
      'bought': 'BOUGHT',
      'curStat': 'Currency Statistics',
      'password': 'Password',
      'passrep': 'Confirm Password',
      'change': 'Change Password',
      'newPass': 'New Password',
      'forgot': 'Forgot your password?',
      'submit': 'Submit',
      'enterVal': 'Enter Currency',
      'deleteAll': 'Delete all data?',
      'yes': 'Yes',
      'no': 'No',
      'login': 'Login',
      'username': 'Username',

      // Add more translations here
    },
    'ru': {
      'add': 'Добавить',
      'currency': 'Валюта',
      'reports': 'Отчеты',
      'total': 'Общий',
      'events': 'События',
      'rate': 'Курс',
      'quantity': 'Кол-во',
      'select': 'Выберите',
      'main': 'Главная',
      'cash': 'Касса',
      'users': 'Пользователи',
      'clear': 'Очистить',
      'trans': 'Транзакции',
      'type': 'Тип',
      'filter': 'Фильтрация',
      'filterType': 'Фильтр по типу',
      'date': 'Дата',
      'apply': 'Применить',
      'cancel': 'Отменить',
      'save': 'Сохранить',
      'edit': 'Изменить Транзакцию',
      'soms': 'Сом осталось: ',
      'profitTot': 'Общая прибыль: ',
      'bought': 'КУПЛЕНО',
      'sold': 'ПРОДАНО',
      'curStat': 'Статистика Валют',
      'password': 'Пароль',
      'passrep': 'Подтвердить пароль',
      'change': 'Изменить пароль',
      'newPass': 'Новый пароль',
      'forgot': 'Забыли свой пароль?',
      'submit': 'Подтвердить',
      'enterVal': 'Введите валюту',
      'deleteAll': 'Удалить все данные?',
      'yes': 'Да',
      'no': 'Нет',
      'login': 'Вход',
      'username': 'Имя пользователя',
      // Add more translations here
    },
  };
}