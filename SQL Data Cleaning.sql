-- Data Cleaning in SQL Queries

USE [My Project Database]

SELECT * FROM NashvileHousing


-- Standardize Data Format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM NashvileHousing

UPDATE NashvileHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvileHousing
ADD SaleDateConverted DATE;

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


-- Populate Property Address Data

SELECT * FROM NashvileHousing
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvileHousing A
JOIN NashvileHousing B
    ON A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

/*SELECT A.[UniqueID ], A.ParcelID, A.PropertyAddress, B.[UniqueID ], B.ParcelID, B.PropertyAddress
FROM NashvileHousing A
JOIN NashvileHousing B
    ON A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
*/

UPDATE A 
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvileHousing A
JOIN NashvileHousing B 
    ON A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


-- Breaking  out ADDRESS into individual Columns (Address, City, State)

SELECT PropertyAddress FROM NashvileHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX((','), PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,  LEN(PropertyAddress))

SELECT * FROM NashvileHousing

SELECT OwnerAddress FROM NashvileHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvileHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvileHousing


-------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM NashvileHousing


UPDATE NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END


-------------------------------------------------------------------------------------------

-- Remove DUPLICATES

WITH RowNumCTE AS(
    SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,

                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                                ORDER BY
                                        UniqueID
            )                           ROW_NUM

FROM NashvileHousing

)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * FROM NashvileHousing


--------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * FROM NashvileHousing

ALTER TABLE NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------


