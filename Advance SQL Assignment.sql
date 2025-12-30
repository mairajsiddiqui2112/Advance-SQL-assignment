-- Advanced SQL Assessment Solutions

-- Step 1: Create the Database
CREATE DATABASE IF NOT EXISTS ProductManagement;
USE ProductManagement;

-- Step 2: Create the Products Table
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Create the ProductArchive Table
CREATE TABLE IF NOT EXISTS ProductArchive (
    ArchiveID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    DeletedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Insert Sample Data into Products
INSERT INTO Products (ProductName, Category, Price, Stock) VALUES
('Laptop', 'Electronics', 899.99, 15),
('Mouse', 'Electronics', 25.99, 50),
('Keyboard', 'Electronics', 45.99, 30),
('Office Chair', 'Furniture', 199.99, 20),
('Desk', 'Furniture', 349.99, 10),
('Monitor', 'Electronics', 299.99, 25),
('Bookshelf', 'Furniture', 129.99, 15),
('Headphones', 'Electronics', 79.99, 40),
('Table Lamp', 'Furniture', 34.99, 35);

-- ============================================
-- Q6: CTE to Calculate Total Revenue by Product
-- Revenue > 3000
-- ============================================

WITH ProductRevenue AS (
    SELECT 
        ProductID,
        ProductName,
        Category,
        Price,
        Quantity,
        (Price * Quantity) AS Revenue
    FROM 
        Products
)
SELECT 
    ProductID,
    ProductName,
    Category,
    Price,
    Quantity,
    Revenue
FROM 
    ProductRevenue
WHERE 
    Revenue > 3000
ORDER BY 
    Revenue DESC;

-- ============================================
-- Q7: Create View - vw_CategorySummary
-- Shows: Category, TotalProducts, AveragePrice
-- ============================================

CREATE OR REPLACE VIEW vw_CategorySummary AS
SELECT 
    Category,
    COUNT(*) AS TotalProducts,
    ROUND(AVG(Price), 2) AS AveragePrice
FROM 
    Products
GROUP BY 
    Category;

-- Test Q7: View the category summary
SELECT * FROM vw_CategorySummary;

-- ============================================
-- Q8: Create Updatable View and Update Price
-- ============================================

CREATE OR REPLACE VIEW vw_ProductPricing AS
SELECT 
    ProductID,
    ProductName,
    Price
FROM 
    Products;

-- Test Q8: View the data before update
SELECT * FROM vw_ProductPricing WHERE ProductID = 1;

-- Update the price of ProductID = 1 using the view
UPDATE vw_ProductPricing
SET Price = 949.99
WHERE ProductID = 1;

-- Verify the update
SELECT * FROM vw_ProductPricing WHERE ProductID = 1;

-- Verify in the original table
SELECT * FROM Products WHERE ProductID = 1;

-- ============================================
-- Q9: Stored Procedure - Get Products by Category
-- ============================================

DROP PROCEDURE IF EXISTS GetProductsByCategory;

DELIMITER $$

CREATE PROCEDURE GetProductsByCategory(
    IN categoryName VARCHAR(50)
)
BEGIN
    SELECT 
        ProductID,
        ProductName,
        Category,
        Price,
        Quantity,
        Stock,
        CreatedAt
    FROM 
        Products
    WHERE 
        Category = categoryName
    ORDER BY 
        ProductName;
END$$

DELIMITER ;

-- Test Q9: Call the stored procedure
CALL GetProductsByCategory('Electronics');
CALL GetProductsByCategory('Furniture');

-- ============================================
-- Q10: AFTER DELETE Trigger - Archive Deleted Products
-- ============================================

DROP TRIGGER IF EXISTS ArchiveDeletedProduct;

DELIMITER $$

CREATE TRIGGER ArchiveDeletedProduct
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchive (
        ProductID,
        ProductName,
        Category,
        Price,
        DeletedAt
    )
    VALUES (
        OLD.ProductID,
        OLD.ProductName,
        OLD.Category,
        OLD.Price,
        CURRENT_TIMESTAMP
    );
END$$

DELIMITER ;

-- Test Q10: Delete a product to test the trigger
DELETE FROM Products WHERE ProductID = 11;

-- Verify the archive contains the deleted product
SELECT * FROM ProductArchive;

-- ============================================
-- Additional Verification Queries
-- ============================================

-- View all products
SELECT * FROM Products ORDER BY ProductID;

-- View all archived products
SELECT * FROM ProductArchive ORDER BY DeletedAt DESC;
