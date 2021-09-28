-- 1
SELECT p.FullName, p.PhoneNumber, p.FaxNumber, c.PhoneNumber [CompanyPhoneNumber], c.FaxNumber [CompanyFaxNumber]
FROM WideWorldImporters.Application.People p LEFT JOIN WideWorldImporters.Sales.Customers c ON p.PersonID = c.PrimaryContactPersonID OR p.PersonID = c.AlternateContactPersonID

-- 2
SELECT c.CustomerID
FROM WideWorldImporters.Application.People p JOIN WideWorldImporters.Sales.Customers c ON p.PersonID = c.PrimaryContactPersonID
WHERE p.PhoneNumber = c.PhoneNumber

-- 3
SELECT c.CustomerID
FROM WideWorldImporters.Sales.Customers c JOIN WideWorldImporters.Sales.Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate < '2016-01-01'
EXCEPT
SELECT c.CustomerID
FROM WideWorldImporters.Sales.Customers c JOIN WideWorldImporters.Sales.Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2016-01-01'

-- 4
SELECT s.StockItemID, SUM(pol.OrderedOuters*s.QuantityPerOuter) [Quantity]
FROM WideWorldImporters.Warehouse.StockItems s JOIN WideWorldImporters.Purchasing.PurchaseOrderLines pol ON s.StockItemID = pol.StockItemID 
	JOIN WideWorldImporters.Purchasing.PurchaseOrders po ON pol.PurchaseOrderID = po.PurchaseOrderID
WHERE YEAR(po.OrderDate) = 2013
GROUP BY s.StockItemID
ORDER BY s.StockItemID

-- 5
SELECT DISTINCT si.StockItemID, ol.Description
FROM WideWorldImporters.Warehouse.StockItems si LEFT JOIN WideWorldImporters.Sales.OrderLines ol ON si.StockItemID = ol.StockItemID
WHERE LEN(ol.Description) >= 10

-- 6
SELECT si.StockItemID
FROM WideWorldImporters.Warehouse.StockItems si
EXCEPT
SELECT si.StockItemID
FROM WideWorldImporters.Sales.OrderLines ol JOIN WideWorldImporters.Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
	JOIN WideWorldImporters.Sales.Orders o ON ol.OrderID = o.OrderID
	JOIN WideWorldImporters.Sales.Customers cus ON o.CustomerID = cus.CustomerID
	JOIN WideWorldImporters.Application.Cities c ON cus.DeliveryCityID = c.CityID
	JOIN WideWorldImporters.Application.StateProvinces sp ON c.StateProvinceID = sp.StateProvinceID
WHERE sp.StateProvinceName IN ('Alabama', 'Georgia') AND YEAR(o.OrderDate) = 2014

-- 7
SELECT sp.StateProvinceID, sp.StateProvinceName, AVG(DATEDIFF(day, o.OrderDate, i.ConfirmedDeliveryTime)) [AvgProcessingDate]
FROM WideWorldImporters.Sales.Orders o JOIN WideWorldImporters.Sales.Invoices i ON o.OrderID = i.OrderID
	JOIN WideWorldImporters.Sales.Customers cus ON o.CustomerID = cus.CustomerID
	JOIN WideWorldImporters.Application.Cities c ON cus.DeliveryCityID = c.CityID
	JOIN WideWorldImporters.Application.StateProvinces sp ON c.StateProvinceID = sp.StateProvinceID
GROUP BY sp.StateProvinceID, sp.StateProvinceName
ORDER BY sp.StateProvinceID

-- 8
SELECT sp.StateProvinceID, sp.StateProvinceName, MONTH(o.OrderDate) [MONTH], AVG(DATEDIFF(day, o.OrderDate, i.ConfirmedDeliveryTime)) [AvgProcessingDate]
FROM WideWorldImporters.Sales.Orders o JOIN WideWorldImporters.Sales.Invoices i ON o.OrderID = i.OrderID
	JOIN WideWorldImporters.Sales.Customers cus ON o.CustomerID = cus.CustomerID
	JOIN WideWorldImporters.Application.Cities c ON cus.DeliveryCityID = c.CityID
	JOIN WideWorldImporters.Application.StateProvinces sp ON c.StateProvinceID = sp.StateProvinceID
GROUP BY sp.StateProvinceID, sp.StateProvinceName, MONTH(o.OrderDate)
ORDER BY sp.StateProvinceID, MONTH

-- 9
SELECT t1.StockItemID, t1.SoldQuantity, t2.PurchaseQuantity
FROM
(SELECT DISTINCT ol.StockItemID, SUM(ol.Quantity) OVER(PARTITION BY ol.StockItemID) [SoldQuantity] 
FROM WideWorldImporters.Sales.OrderLines ol JOIN WideWorldImporters.Sales.Orders o ON ol.OrderID = o.OrderID
	JOIN WideWorldImporters.Warehouse.StockItems s ON ol.StockItemID = s.StockItemID
WHERE YEAR(o.OrderDate) = 2015) [t1] JOIN
(SELECT DISTINCT pol.StockItemID, SUM(pol.OrderedOuters*s.QuantityPerOuter) OVER(PARTITION BY pol.StockItemID) [PurchaseQuantity] 
FROM WideWorldImporters.Purchasing.PurchaseOrderLines pol JOIN WideWorldImporters.Purchasing.PurchaseOrders po ON pol.PurchaseOrderID = po.PurchaseOrderID
	JOIN WideWorldImporters.Warehouse.StockItems s ON pol.StockItemID = s.StockItemID
WHERE YEAR(po.OrderDate) = 2015) [t2] ON t1.StockItemID = t2.StockItemID
WHERE t2.PurchaseQuantity > t1.SoldQuantity
ORDER BY t1.StockItemID

-- 10
SELECT c.CustomerID, c.PhoneNumber, p.FullName, SUM(ol.Quantity) [SoldQuantity]
FROM WideWorldImporters.Sales.Customers c JOIN WideWorldImporters.Application.People p ON c.PrimaryContactPersonID = p.PersonID
	JOIN WideWorldImporters.Sales.Orders o ON c.CustomerID = o.CustomerID
	JOIN WideWorldImporters.Sales.OrderLines ol ON o.OrderID = ol.OrderID
	JOIN WideWorldImporters.Warehouse.StockItems si ON  ol.StockItemID = si.StockItemID
WHERE si.StockItemName LIKE '%mug%' AND YEAR(o.OrderDate) = 2016
GROUP BY c.CustomerID, c.PhoneNumber, p.FullName
HAVING SUM(ol.Quantity) <= 10
ORDER BY c.CustomerID

-- 11
SELECT c.CityID
FROM WideWorldImporters.Application.Cities c
WHERE ValidFrom >= '2015-01-01'

-- 12
SELECT si.StockItemName, CONCAT(cus.DeliveryAddressLine1, ' ', cus.DeliveryAddressLine2) [Address], sp.StateProvinceName, c.CityName, cou.CountryName, cus.CustomerName, cus.PhoneNumber, p.FullName [ContactPersonName], ol.Quantity
FROM WideWorldImporters.Sales.Orders o JOIN WideWorldImporters.Sales.Customers cus ON o.CustomerID = cus.CustomerID
	JOIN WideWorldImporters.Sales.OrderLines ol ON o.OrderID = ol.OrderID
	JOIN WideWorldImporters.Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
	JOIN WideWorldImporters.Application.Cities c ON cus.DeliveryCityID = c.CityID
	JOIN WideWorldImporters.Application.StateProvinces sp ON c.StateProvinceID = sp.StateProvinceID
	JOIN WideWorldImporters.Application.Countries cou ON sp.CountryID = cou.CountryID
	JOIN WideWorldImporters.Application.People p ON cus.PrimaryContactPersonID = p.PersonID
WHERE o.OrderDate = '2014-07-01'

-- 13
SELECT t1.StockGroupID, t1.PurchaseQuantity, t2.SoldQuantity, t1.PurchaseQuantity - t2.SoldQuantity [RemainingQuantity]
FROM (SELECT sisg.StockGroupID, SUM(po.OrderedOuters*si.QuantityPerOuter) [PurchaseQuantity]
FROM WideWorldImporters.Warehouse.StockItemStockGroups sisg JOIN WideWorldImporters.Warehouse.StockItems si ON sisg.StockItemID  = si.StockItemID
	JOIN WideWorldImporters.Purchasing.PurchaseOrderLines po ON sisg.StockItemID = po.StockItemID
GROUP BY sisg.StockGroupID) [t1] JOIN
(SELECT sisg.StockGroupID, SUM(ol.Quantity) [SoldQuantity]
FROM WideWorldImporters.Warehouse.StockItemStockGroups sisg
	JOIN WideWorldImporters.Sales.OrderLines ol ON sisg.StockItemID = ol.StockItemID
GROUP BY sisg.StockGroupID) [t2] ON t1.StockGroupID = t2.StockGroupID
ORDER BY t1.StockGroupID

-- 14
SELECT c.CityID, ISNULL(CAST(t2.StockItemID AS varchar(20)), 'No Sales') [StockItemID]
FROM WideWorldImporters.Application.Cities c 
LEFT JOIN
(SELECT t1.DeliveryCityID, t1.StockItemID
FROM (SELECT cus.DeliveryCityID, ol.StockItemID, ROW_NUMBER() OVER(PARTITION BY cus.DeliveryCityID ORDER BY COUNT(ol.StockItemID) DESC) [ItemRank]
FROM WideWorldImporters.Sales.Customers cus JOIN WideWorldImporters.Sales.Orders o ON cus.CustomerID = o.CustomerID
	JOIN WideWorldImporters.Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE YEAR(o.OrderDate) = 2016 
GROUP BY cus.DeliveryCityID, ol.StockItemID) [t1]
WHERE t1.ItemRank = 1) [t2] ON c.CityID = t2.DeliveryCityID

-- 15
SELECT OrderID, COUNT(Event)
FROM WideWorldImporters.Sales.Invoices i
OUTER APPLY OPENJSON(i.ReturnedDeliveryData) WITH (
	Events nvarchar(max) '$.Events' AS JSON
) t1
OUTER APPLY OPENJSON(t1.Events) WITH (
   Event nvarchar(max) '$.Event'
) t2
WHERE Event = 'DeliveryAttempt'
GROUP BY OrderID
HAVING COUNT(Event) > 1
ORDER BY OrderID

-- 16
SELECT si.StockItemID
FROM WideWorldImporters.Warehouse.StockItems si
OUTER APPLY OPENJSON(si.CustomFields) WITH (
	CountryOfManufacture nvarchar(max) '$.CountryOfManufacture'
) t1
WHERE t1.CountryOfManufacture = 'China'

-- 17
SELECT t1.CountryOfManufacture, SUM(Quantity) [SoldQuantity]
FROM WideWorldImporters.Warehouse.StockItems si
OUTER APPLY OPENJSON(si.CustomFields) WITH (
	CountryOfManufacture nvarchar(max) '$.CountryOfManufacture'
) t1 JOIN WideWorldImporters.Sales.OrderLines ol ON si.StockItemID = ol.StockItemID
	JOIN WideWorldImporters.Sales.Orders o ON ol.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 2015
GROUP BY t1.CountryOfManufacture

-- 18
USE WideWorldImporters
GO
CREATE VIEW StockGroupSoldQuantityByYear
AS
	SELECT sisg.StockGroupID, SUM(CASE WHEN YEAR(o.OrderDate) <= 2013 THEN ol.Quantity ELSE 0 END) [2013],
		SUM(CASE WHEN YEAR(o.OrderDate) <= 2014 THEN ol.Quantity ELSE 0 END) [2014], 
		SUM(CASE WHEN YEAR(o.OrderDate) <= 2015 THEN ol.Quantity ELSE 0 END) [2015],
		SUM(CASE WHEN YEAR(o.OrderDate) <= 2016 THEN ol.Quantity ELSE 0 END) [2016],
		SUM(CASE WHEN YEAR(o.OrderDate) <= 2017 THEN ol.Quantity ELSE 0 END) [2017]
	FROM WideWorldImporters.Sales.OrderLines ol JOIN WideWorldImporters.Warehouse.StockItemStockGroups sisg ON ol.StockItemID = sisg.StockItemID
		JOIN WideWorldImporters.Sales.Orders o ON ol.OrderID = o.OrderID
	GROUP BY sisg.StockGroupID
GO

-- 19
USE WideWorldImporters
GO
CREATE VIEW SoldQuantityByYearByStockGroup
AS 
	SELECT [1], [2], [3], [4], ISNULL([5],0) [5], [6], [7], [8], [9], [10]
	FROM
	(
		SELECT StockGroupID, Year, Value
		FROM dbo.StockGroupSoldQuantityByYear
		UNPIVOT
		(
			Value
			FOR Year in ([2013], [2014], [2015], [2016], [2017])
		) unpiv
	) [sourcetable]
	PIVOT
	(
		MAX(Value)
		for StockGroupID in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10])
	) [pivottable]
GO

-- 20
USE WideWorldImporters
GO
CREATE FUNCTION dbo.OrderTotal(@OrderID int)
RETURNS TABLE
AS
RETURN
(
SELECT SUM(il.ExtendedPrice) [Total]
FROM WideWorldImporters.Sales.Invoices i JOIN WideWorldImporters.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
WHERE i.OrderID = @OrderID
)

SELECT * 
FROM WideWorldImporters.Sales.Invoices i
CROSS APPLY dbo.OrderTotal([OrderID]);

-- 21
USE WideWorldImporters
GO
CREATE SCHEMA ods
GO
CREATE TABLE ods.Orders (
   OrderID INT PRIMARY KEY,
	OrderDate DATE,
	OrderTotal decimal(18,2),
	CustomerID INT REFERENCES Sales.Customers(CustomerID)
)
GO

IF OBJECT_ID ( 'dbo.GetOrderDetailsByDate', 'P' ) IS NOT NULL
    DROP PROCEDURE dbo.GetOrderDetailsByDate;
GO
CREATE PROCEDURE dbo.GetOrderDetailsByDate
@OrderDate date
AS
   SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO ods.Orders 
			SELECT t1.orderID, o.OrderDate, t1.Total, o.CustomerID
			FROM
			(SELECT i.orderID, SUM(il.ExtendedPrice) [Total]
			FROM WideWorldImporters.Sales.Invoices i JOIN WideWorldImporters.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
				JOIN WideWorldImporters.Sales.Orders o ON i.OrderID = o.OrderID
			WHERE o.OrderDate = @OrderDate
			GROUP BY i.orderID) t1 
			JOIN WideWorldImporters.Sales.Orders o ON t1.OrderID = o.OrderID
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT;
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
	END CATCH
GO

EXEC dbo.GetOrderDetailsByDate @OrderDate = '2013-01-01'
EXEC dbo.GetOrderDetailsByDate @OrderDate = '2013-01-02'
EXEC dbo.GetOrderDetailsByDate @OrderDate = '2013-01-03'
EXEC dbo.GetOrderDetailsByDate @OrderDate = '2013-01-04'
EXEC dbo.GetOrderDetailsByDate @OrderDate = '2013-01-05'
GO

-- 22
USE WideWorldImporters
GO
SELECT t1.StockItemID, t1.StockItemName, t1.SupplierID, t1.ColorID, t1.UnitPackageID, t1.OuterPackageID, t1.Brand,
	t1.Size, t1.LeadTimeDays, t1.QuantityPerOuter, t1.IsChillerStock, t1.Barcode, t1.TaxRate, t1.UnitPrice, t1.RecommendedRetailPrice,
	t1.TypicalWeightPerUnit, t1.MarketingComments, t1.InternalComments, t1.CountryOfManufacture, t1.Range, t1.Shelflife
INTO ods.StockItem
FROM
(SELECT si.*, JSON_VALUE(si.CustomFields, '$.CountryOfManufacture') [CountryOfManufacture], 
	JSON_VALUE(si.CustomFields, '$.Range') [Range], JSON_VALUE(si.CustomFields, '$.ShelfLife') [ShelfLife] 
FROM WideWorldImporters.Warehouse.StockItems si) [t1]
GO

-- 23
USE WideWorldImporters
GO

IF OBJECT_ID ( 'dbo.GetNextSevenDaysOrderDetails', 'P' ) IS NOT NULL
    DROP PROCEDURE dbo.GetNextSevenDaysOrderDetails;
GO

CREATE PROCEDURE dbo.GetNextSevenDaysOrderDetails
@OrderDate date
AS
   SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE FROM ods.Orders
			WHERE OrderDate < @OrderDate

			INSERT INTO ods.Orders
			SELECT t1.orderID, o.OrderDate, t1.Total, o.CustomerID
			FROM
			(SELECT i.orderID, SUM(il.ExtendedPrice) [Total]
			FROM WideWorldImporters.Sales.Invoices i JOIN WideWorldImporters.Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
				JOIN WideWorldImporters.Sales.Orders o ON i.OrderID = o.OrderID
			WHERE o.OrderDate BETWEEN @OrderDate AND DATEADD(day, 7, @OrderDate) 
			GROUP BY i.orderID) t1 
			JOIN WideWorldImporters.Sales.Orders o ON t1.OrderID = o.OrderID
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT;
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY();
		RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
	END CATCH
GO

EXEC dbo.GetNextSevenDaysOrderDetails @OrderDate = '2013-01-06'
GO

-- 24
DECLARE @json NVARCHAR(MAX) = 
'{"PurchaseOrders":[{"StockItemName":"Panzer Video Game", "Supplier":"7", "UnitPackageId":"1",
"OuterPackageId":"6", "Brand":"EA Sports", "LeadTimeDays":"5", "QuantityPerOuter":"1", "TaxRate":"6", "UnitPrice":"59.99", 
"RecommendedRetailPrice":"69.99", "TypicalWeightPerUnit":"0.5", "CountryOfManufacture":"Canada", "Range":"Adult", "OrderDate":"2018-01-01", 
"DeliveryMethod":"Post", "ExpectedDeliveryDate":"2018-02-02", "SupplierReference":"WWI2308"}, {"StockItemName":"Panzer Video Game 2", "Supplier":"5", 
"UnitPackageId":"1", "OuterPackageId":"7", "Brand":"EA Sports", "LeadTimeDays":"5", "QuantityPerOuter":"1", "TaxRate":"6", "UnitPrice":"59.99", 
"RecommendedRetailPrice":"69.99", "TypicalWeightPerUnit":"0.5", "CountryOfManufacture":"Canada", "Range":"Adult", "OrderDate":"2018-01-25", 
"DeliveryMethod":"Post", "ExpectedDeliveryDate":"2018-02-02", "SupplierReference":"269622390"}]}'

IF OBJECT_ID(N'tempdb..#JsonTempTable') IS NOT NULL
BEGIN
DROP TABLE #JsonTempTable
END

SELECT *
INTO #JsonTempTable
FROM OPENJSON(@json)
	WITH (PurchaseOrders nvarchar(max) '$.PurchaseOrders' AS JSON) as [t1]
CROSS APPLY OPENJSON(t1.PurchaseOrders)
	WITH (StockItemName nvarchar(100), Supplier int, UnitPackageId int, OuterPackageId nvarchar(50), Brand nvarchar(50), LeadTimeDays int,
	QuantityPerOuter int, TaxRate decimal(18,3), UnitPrice decimal(18,2), RecommendedRetailPrice decimal(18,2), TypicalWeightPerUnit decimal(18,3),
	CountryOfManufacture nvarchar(100), Range nvarchar(100), OrderDate date, DeliveryMethod nvarchar(50), ExpectedDeliveryDate date,
	SupplierReference nvarchar(20)) as [t2]

INSERT INTO WideWorldImporters.Warehouse.StockItems(StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID, Brand, Size, 
	LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, MarketingComments, 
	InternalComments, Photo, CustomFields, LastEditedBy)
SELECT StockItemName, Supplier [SupplierID], NULL [ColorID], UnitPackageId [UnitPackageID], OuterPackageId [OuterPackageID],
	Brand, NULL [Size], LeadTimeDays, QuantityPerOuter, 0 [IsChillerStock], NULL [Barcode], TaxRate, UnitPrice,
	RecommendedRetailPrice, TypicalWeightPerUnit, NULL [MarketingComments], NULL [InternalComments], NULL [Photo],
	CONCAT('{ "CountryOfManufacture": "', CountryOfManufacture, '", "Tags": [], "Range": "', Range, '" }') [CustomFields], 1 [LastEditedBy]
FROM
(SELECT *, ROW_NUMBER() OVER(ORDER BY OrderDate) [RowNum]
FROM #JsonTempTable) [t1] 

INSERT INTO WideWorldImporters.Purchasing.PurchaseOrders(SupplierID, OrderDate, DeliveryMethodID, ContactPersonID, ExpectedDeliveryDate, SupplierReference, 
	IsOrderFinalized, Comments, InternalComments, LastEditedBy, LastEditedWhen)
SELECT Supplier [SupplierID], OrderDate, dm.DeliveryMethodID [DeliveryMethodID], 1 [ContactPersonID], ExpectedDeliveryDate, SupplierReference, 
	1 [IsOrderFinalized], NULL [Comments], NULL [InternalComments], 1 [LastEditedBy], GETDATE() [LastEditedWhen]
FROM
(SELECT *, ROW_NUMBER() OVER(ORDER BY OrderDate) [RowNum]
FROM #JsonTempTable) [t1] JOIN WideWorldImporters.Application.DeliveryMethods dm ON t1.DeliveryMethod = dm.DeliveryMethodName COLLATE database_default

INSERT INTO WideWorldImporters.Purchasing.PurchaseOrderLines
SELECT RowNum+(SELECT MAX(PurchaseOrderLineID) FROM WideWorldImporters.Purchasing.PurchaseOrderLines) [PurchaseOrderLineID], 
	RowNum+(SELECT MAX(PurchaseOrderID) FROM WideWorldImporters.Purchasing.PurchaseOrders)-(SELECT COUNT(*) FROM #JsonTempTable) [PurchaseOrderID],
	RowNum+(SELECT MAX(StockItemID) FROM WideWorldImporters.Warehouse.StockItems)-(SELECT COUNT(*) FROM #JsonTempTable) [StockItemID], 
	1 [OrderedOuters], '' [Description], 1 [ReceivedOuters], UnitPackageId [PackageTypeID], 
	UnitPrice [ExpectedUnitPricePerOuter], NULL [LastReceiptDate], 1 [IsOrderLineFinalized], 1 [LastEditedBy], GETDATE() [LastEditedWhen]
FROM
(SELECT *, ROW_NUMBER() OVER(ORDER BY OrderDate) [RowNum]
FROM #JsonTempTable) [t1]

--SELECT * FROM WideWorldImporters.Warehouse.StockItems
--SELECT * FROM WideWorldImporters.Purchasing.PurchaseOrders
--SELECT * FROM WideWorldImporters.Purchasing.PurchaseOrderLines

--DELETE FROM WideWorldImporters.Purchasing.PurchaseOrderLines
--WHERE PurchaseOrderLineID > 8367
--DELETE FROM WideWorldImporters.Purchasing.PurchaseOrders
--WHERE PurchaseOrderID > 2074
--DELETE FROM WideWorldImporters.Warehouse.StockItems
--WHERE StockItemID > 227

-- 25
USE WideWorldImporters
GO

CREATE VIEW SoldQuantityByYearByStockGroupJSON
AS 
	WITH cte1([json]) AS
	(SELECT [1], [2], [3], [4], ISNULL([5],0) [5], [6], [7], [8], [9], [10]
	FROM
	(
		SELECT StockGroupID, Year, Value
		FROM dbo.StockGroupSoldQuantityByYear
		UNPIVOT
		(
			Value
			FOR Year in ([2013], [2014], [2015], [2016], [2017])
		) unpiv
	) [sourcetable]
	PIVOT
	(
		MAX(Value)
		for StockGroupID in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10])
	) [pivottable]
	FOR JSON PATH, ROOT('Years'))

	SELECT *
	FROM cte1
GO

-- 26
CREATE VIEW SoldQuantityByYearByStockGroupXML
AS 
	WITH cte1([xml]) AS
	(SELECT [1] AS [_1], [2] AS [_2], [3] AS [_3], [4] AS [_4], ISNULL([5],0) AS [_5], [6] AS [_6], [7] AS [_7], [8] AS [_8], [9] AS [_9], [10] AS [_10]
	FROM
	(
		SELECT StockGroupID, Year, Value
		FROM dbo.StockGroupSoldQuantityByYear
		UNPIVOT
		(
			Value
			FOR Year in ([2013], [2014], [2015], [2016], [2017])
		) unpiv
	) [sourcetable]
	PIVOT
	(
		MAX(Value)
		for StockGroupID in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10])
	) [pivottable]
	FOR XML PATH('Year'))

	SELECT *
	FROM cte1
GO

-- 27
CREATE TABLE ods.ConfirmedDeliveryJson  (
    id INT PRIMARY KEY IDENTITY,
	date DATE,
	value nvarchar(max)
)
GO

IF OBJECT_ID ( 'dbo.GetInvoiceJSON', 'P' ) IS NOT NULL
    DROP PROCEDURE dbo.GetInvoiceJSON;
GO

CREATE PROCEDURE dbo.GetInvoiceJSON
@InvoiceDate date
AS
	WITH cte1([value]) AS
	(SELECT *
	FROM WideWorldImporters.Sales.Invoices i JOIN WideWorldImporters.Sales.InvoiceLines InvoiceLine ON i.InvoiceID = InvoiceLine.InvoiceID
	WHERE i.InvoiceDate = @InvoiceDate
	FOR JSON AUTO) 

	INSERT INTO ods.ConfirmedDeliveryJson(date, value)
	SELECT @InvoiceDate [date], cte1.value
	FROM cte1
GO

DECLARE @date DATE
DECLARE cur CURSOR LOCAL FOR
    SELECT DISTINCT InvoiceDate FROM WideWorldImporters.Sales.Invoices WHERE CustomerID = 1
OPEN cur
FETCH NEXT FROM cur INTO @date
WHILE @@FETCH_STATUS = 0 
BEGIN
    EXEC dbo.GetInvoiceJSON @date
    FETCH NEXT FROM cur INTO @date
END
CLOSE cur
DEALLOCATE cur

SELECT * FROM ods.ConfirmedDeliveryJson