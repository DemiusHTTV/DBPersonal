# Анализ базы данных Front

## 1. Закупки

### Front.dbo.bm_StorageOperations
- id: идентификатор операции
- productid: идентификатор товара
- vendorid: идентификатор поставщика
- documentid: идентификатор документа
- operationid: тип операции
- storageid: идентификатор склада
- period: период операции
- dateadd: дата операции
- count: количество товара
- amount: сумма операции

### Front.dbo.product
- id: идентификатор товара
- description: название или описание товара
- productid: код товара

### Front.dbo.vendors
- id: идентификатор поставщика
- firstname: название или имя поставщика

### Front.dbo.bm_JournalBarnetDocs
- id: идентификатор документа
- period: дата или период документа
- personid: идентификатор сотрудника
- isuse: признак использования документа
- amount: сумма документа

## 2. Продажи

### Front.dbo.journal
- id: код товара
- dater: дата продажи
- quantity: количество проданного товара
- amount: сумма продажи

### Front.dbo.product
- id: идентификатор товара
- productid: код товара
- description: название или описание товара

### Front.dbo.clients
- id: идентификатор клиента
- firstname: имя или название клиента

### Front.dbo.pricelist
- id: идентификатор записи
- productid: идентификатор товара
- price: цена товара

## 3. Поставщики

### Front.dbo.vendors
- id: идентификатор поставщика
- firstname: название или имя поставщика

### Front.dbo.vendorgroup
- id: идентификатор группы поставщиков
- description: название группы поставщиков

### Front.dbo.bm_StorageOperations
- id: идентификатор операции
- productid: идентификатор товара
- vendorid: идентификатор поставщика
- documentid: идентификатор документа
- operationid: тип операции
- storageid: идентификатор склада
- period: период операции
- count: количество товара
- amount: сумма операции

### Front.dbo.bm_JournalBarnetDocs
- id: идентификатор документа
- period: дата или период документа
- personid: идентификатор сотрудника
- isuse: признак использования документа
- amount: сумма документа

### Front.dbo.product
- id: идентификатор товара
- description: название или описание товара
- productid: код товара

### Front.dbo.pricelist
- id: идентификатор записи
- productid: идентификатор товара
- price: цена товара

## 4. Персонал

### Front.dbo.personnel
- personid: идентификатор сотрудника
- firstname: имя сотрудника
- lastname: фамилия сотрудника

### Front.dbo.bm_JournalBarnetDocs
- id: идентификатор документа
- period: дата или период документа
- personid: идентификатор сотрудника
- isuse: признак использования документа
- amount: сумма документа

### Front.dbo.bm_PersonnelSecurity
- personid: идентификатор сотрудника
- securityid: идентификатор права или настройки безопасности

### Front.dbo.userinformation
- userid: идентификатор пользователя
- personid: идентификатор сотрудника

### Front.dbo.bm_WorkHours
- personid: идентификатор сотрудника
- date: дата
- hours: количество рабочих часов

## 5. Остатки и движение товаров

### Front.dbo.bm_StorageOperations
- id: идентификатор операции
- productid: идентификатор товара
- storageid: идентификатор склада
- operationid: тип операции
- dateadd: дата операции
- count: количество товара
- amount: сумма операции

### Front.dbo.product
- id: идентификатор товара
- description: название или описание товара
- productid: код товара

### Front.dbo.storages
- id: идентификатор склада
- description: название склада

### Front.dbo.bm_StorageOperationsType
- id: идентификатор типа операции
- description: название типа операции

### Front.dbo.storagesonhand
- id: идентификатор записи
- storageid: идентификатор склада
- productid: идентификатор товара
- quantity: количество товара

### Front.dbo.stock
- id: идентификатор записи
- productid: идентификатор товара
- quantity: количество товара

### Front.dbo.onhand
- id: идентификатор записи
- productid: идентификатор товара
- quantity: количество товара

### Front.dbo.storeroom
- id: идентификатор складского помещения
- description: название складского помещения
