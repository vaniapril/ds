# 1) Финансовый калькулятор:
Проект выполнен на языке java с использованием библиотек swing и BigDecimal.

Шаги проекта расположены в папках:

* /Lab1/step1/
* /Lab1/step2/
* /Lab1/step3/

В корнях папок расположены исполняемые jar-файлы (для 3-го шага прикреплен исполняемый exe-файл), в папках «main» находятся исходные коды каждого шага.

# 2) Модуль справочников:
## Шаг 1:
Справочник "Сеть ресторанов":
* Название сети
* Дата основания
* Основатели
* Доход (млрд.)
* Количество ресторанов в Беларуси

Справочник "Ресторан":
* Адрес
* Сеть (Значение справочника "Сеть ресторанов")
* Дата открытия
* Оценка
* Количество оценок

## Шаг 2:
В проекте использовалась база данные SQLite.

Схема БД:
* Таблица "dictionaries" - хранит данные о справочнике (название, текущее состояние(удален или нет))
* Таблица "fields" - хранит данные о полях справочника (название, тип)
* Таблица "dictionaries_id" - вспомогательная таблица для работы сохранения истории изменений (общий для всех версий записи id, текущее состояние)
* Таблицы "dictionaries_{id}" - где {id} - номер справочника, создается под каждый справочник, хранит все записи данного справочника вместе со вспомогатлеьными поля
ми (общий id, версия)

### Пример заполнения данных
Данные без лишнего кода:

    dictionaries:
    [1, "Сеть", 1]
    [2, "Рестораны", 1]
    
    fields:
    [1,"Название", TEXT, 1]
    [2,"Дата основания", DATE, 1]
    [3,"Основатели", TEXT, 1]
    [4,"Доход (млрд.)", REAL, 1]
    [5,"Количество ресторанов в Беларуси", INTEGER, 1]
    [6,"Адрес", TEXT, 2]);
    [7,"Сеть", 1, 2]);
    [8,"Дата открытия", DATE, 2]);
    [9,"Оценка", REAL, 2]);
    [10,"Количество оценок", INTEGER, 2]);
  
    dictionaries_1:
    [1,1,1,'KFC',Utils.toDate('24.09.1952'),'Полковник Сандерс', 17.9, 52]);
    [2,2,1,'McDonald’s',Utils.toDate('15.05.1940'),'Дик и Мак Макдоналды', 4.73, 25]);
    [3,3,1,'Burger King',Utils.toDate('28.07.1954'),'Джеймс Маклэмор и Дэвид Эджертон', 0.117, 41]);

    dictionaries_2:
    [1,4,1,'Минск, ТЦ Столица, проспект Независимости 3', 1,Utils.toDate('17.09.2015'), 4.7, 373]);
    [2,5,1,'Минск, ул. Кирова 1', 1,Utils.toDate('24.07.2013'), 4.2, 5974]);
    [3,6,1,'Минск, ул. Кирова 1', 2,Utils.toDate('03.11.2012'), 4.3, 8753]);
    [4,7,1,'Минск, ул. Бобруйская 6', 2,Utils.toDate('08.09.2013'), 3.9, 7079]);
    [5,8,1,'Минск, Привокзальная пл. 7', 3,Utils.toDate('02.10.2017'), 3.7, 766]);
    [6,9,1,'Минск, пл. Свободы 17', 3,Utils.toDate('27.02.2014'), 3.8, 4339]);

Код создания и заполнения справочников из приложения:

    database.rawQuery('INSERT INTO dictionaries(id, title, state) VALUES(?,?,?)',
        [1, "Сеть", 1]);

    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [1,"Название", TEXT, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', 
        [2,"Дата основания", DATE, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [3,"Основатели", TEXT, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)', 
        [4,"Доход (млрд.)", REAL, 1]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [5,"Количество ресторанов в Беларуси", INTEGER, 1]);

    database.rawQuery('CREATE TABLE dictionaries_1 ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'main_id INTEGER,'
        'version INTEGER,'
        'field_1 TEXT,'
        'field_2 INTEGER,'
        'field_3 TEXT,'
        'field_4 REAL,'
        'field_5 INTEGER)');

    database.rawQuery('INSERT INTO dictionaries(id, title, state) VALUES(?,?,?)', 
        [2, "Рестораны", 1]);

    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [6,"Адрес", TEXT, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [7,"Сеть", 1, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [8,"Дата открытия", DATE, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [9,"Оценка", REAL, 2]);
    database.rawQuery('INSERT INTO fields(id, title, type, dictionary_id) VALUES(?,?,?,?)',
        [10,"Количество оценок", INTEGER, 2]);

    database.rawQuery('CREATE TABLE dictionaries_2 ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'main_id INTEGER,'
        'version INTEGER,'
        'field_6 TEXT,'
        'field_7 INTEGER,'
        'field_8 INTEGER,'
        'field_9 REAL,'
        'field_10 INTEGER)');

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [1,1,1]);
    database.rawQuery('INSERT INTO dictionaries_1(id, main_id, version, field_1, field_2, field_3, field_4, field_5) VALUES(?,?,?,?,?,?,?,?)',
        [1,1,1,'KFC',Utils.toDate('24.09.1952'),'Полковник Сандерс', 17.9, 52]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [2,1,1]);
    database.rawQuery('INSERT INTO dictionaries_1(id, main_id, version, field_1, field_2, field_3, field_4, field_5) VALUES(?,?,?,?,?,?,?,?)',
        [2,2,1,'McDonald’s',Utils.toDate('15.05.1940'),'Дик и Мак Макдоналды', 4.73, 25]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [3,1,1]);
    database.rawQuery('INSERT INTO dictionaries_1(id, main_id, version, field_1, field_2, field_3, field_4, field_5) VALUES(?,?,?,?,?,?,?,?)',
        [3,3,1,'Burger King',Utils.toDate('28.07.1954'),'Джеймс Маклэмор и Дэвид Эджертон', 0.117, 41]);


    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [4,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [1,4,1,'Минск, ТЦ Столица, проспект Независимости 3', 1,Utils.toDate('17.09.2015'), 4.7, 373]);
    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [5,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [2,5,1,'Минск, ул. Кирова 1', 1,Utils.toDate('24.07.2013'), 4.2, 5974]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [6,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [3,6,1,'Минск, ул. Кирова 1', 2,Utils.toDate('03.11.2012'), 4.3, 8753]);
    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [7,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [4,7,1,'Минск, ул. Бобруйская 6', 2,Utils.toDate('08.09.2013'), 3.9, 7079]);

    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [8,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [5,8,1,'Минск, Привокзальная пл. 7', 3,Utils.toDate('02.10.2017'), 3.7, 766]);
    database.rawQuery('INSERT INTO dictionaries_ids(id, dictionary_id, state) VALUES(?,?,?)',
        [9,1,1]);
    database.rawQuery('INSERT INTO dictionaries_2(id, main_id, version, field_6, field_7, field_8, field_9, field_10) VALUES(?,?,?,?,?,?,?,?)',
        [6,9,1,'Минск, пл. Свободы 17', 3,Utils.toDate('27.02.2014'), 3.8, 4339]);

## Шаг 3:
Приложение было разработано на фреймворке Flutter с использованием языка программирования Dart как мобильное android-приложение. Проект расположен в папке:

* /Lab2/

В корне папки расположен скомпилированный apk-файл, исходный код расположен в папке "lib".

### Описание работы приложения:
Экран "Cправочники" позволяет:
* Выбрать справочник и перейти на экран "Справочник"
* Удалить справочник
* Перейти на экран "Новый справочник"
* Включить функцию "показывать поля" (Позволяет увидеть сразу все под-поля вложенных справочников)
* Посмотреть информацию о приложении

Экран "Новый справочник":
* Ввести название справочника
* Добавлять и удалять поля, менять их тип и название
* После введения всех названий позволяет создать новый справочник

Экран "Справочник" (В заголовке отображается название справочника):
* Просматривать записи справочника в виде таблицы
* Выбрать запись и перейти на экран "Изменить"
* Удалить запись
* Перейти на экран "Создать"
* Сгенерировать случайную запись (Если это возможно)

Экран "Изменить":
* Изменение полей существующей записи
* Если изменения над записью уже производились, позволяет перемещаться по версиям записи
* После изменнения позволяет сохранить обновленную запись

Экран "Создать":
* Заполнение полей новой записи
* После заполнения всех полей позволяет создать новую запись




