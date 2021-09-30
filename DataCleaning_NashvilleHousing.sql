-- Data Cleaning By Using Queries (through Microsoft SQL Server Management Studio)


-- ## convert the date-time to date only.
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..nashville_housing
-- OR
SELECT SaleDate, CAST(SaleDate AS Date)
FROM PortfolioProject..nashville_housing


ALTER TABLE nashville_housing
ADD SaleDateConverted Date

UPDATE PortfolioProject..nashville_housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


-- Delete manually and rename the SaleDateConverted to SaleDate in Object Explorer

SELECT *
FROM nashville_housing


-- ## Populate the Property Address Data
SELECT a.UniqueID, a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- return a if NOT null, return b is a is null
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <>b.[UniqueID ]
WHERE  a.PropertyAddress is null
-- ORDER BY ParcelID

Update a --alias
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <>b.[UniqueID ]
WHERE  a.PropertyAddress is null

SELECT *
FROM  PortfolioProject..nashville_housing 
WHERE PropertyAddress is null

-- ## Breaking Property Address into (Address, City, State)
-- Sparate the State out
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1)) AS PropertyAddressSplitAddress--, CHARINDEX(',', PropertyAddress)
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS State
FROM PortfolioProject..nashville_housing 


ALTER TABLE PortfolioProject..nashville_housing 
ADD PropertyAddressSplitAddress NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET PropertyAddressSplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1))

ALTER TABLE PortfolioProject..nashville_housing 
ADD PropertyAddressSplitCity NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET PropertyAddressSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..nashville_housing


-- ## Breaking Owner Address into (Address, City, State)
SELECT OwnerAddress
FROM PortfolioProject..nashville_housing

SELECT
	OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress,',','.'),1) -- State
	,PARSENAME(REPLACE(OwnerAddress,',','.'),2) -- City
	,PARSENAME(REPLACE(OwnerAddress,',','.'),3) -- Address
FROM PortfolioProject..nashville_housing


ALTER TABLE PortfolioProject..nashville_housing 
ADD OwnerAddressSplitState NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) -- State

ALTER TABLE PortfolioProject..nashville_housing 
ADD OwnerAddressSplitCity NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET OwnerAddressSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) -- City

ALTER TABLE PortfolioProject..nashville_housing 
ADD OwnerAddressSplitAddress NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET OwnerAddressSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) -- Address


-- Change Y and N in SoldAs Vacant
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY SoldAsVacant
-- There contains N, No, Y , Yes

SELECT SoldAsVacant
 , CASE 
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..nashville_housing

Update PortfolioProject..nashville_housing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END


-- #Remove Duplicate
SELECT *
FROM PortfolioProject..nashville_housing

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER
	(PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
					UniqueID
				) rownum
FROM PortfolioProject..nashville_housing
-- ORDER BY rownum DESC 
)

SELECT *
FROM RowNumCTE
WHERE rownum>1
ORDER BY PropertyAddress


DELETE 
FROM RowNumCTE
WHERE rownum>1


-- # Delete Unused Colunm
SELECT * 
FROM PortfolioProject..nashville_housing

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress