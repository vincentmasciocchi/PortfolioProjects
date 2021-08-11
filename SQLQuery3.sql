SELECT * FROM Nashville_Housing;

-- Change Date Format

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate;

SELECT * FROM Nashville_Housing;

-- Populate Property Address Data

Select *
FROM Nashville_Housing
WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

SELECT * 
FROM Nashville_Housing
WHERE PropertyAddress is null;

-- Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddres
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
Add StreetAddress NVARCHAR(255);

ALTER TABLE Nashville_Housing
Add City NVARCHAR(255);

ALTER TABLE Nashville_Housing
Add OwnerStreetAddress NVARCHAR(255);

ALTER TABLE Nashville_Housing
Add OwnerCity NVARCHAR(255);

ALTER TABLE Nashville_Housing
Add OwnerState NVARCHAR(255);

Update Nashville_Housing
Set StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

Update Nashville_Housing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress));

Update Nashville_Housing
Set OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

Update Nashville_Housing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

Update Nashville_Housing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM Nashville_Housing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2 DESC;

Update Nashville_Housing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						ELSE SoldAsVacant
				   End;

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() 
OVER(PARTITION BY 
	ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDateConverted, 
	LegalReference
	ORDER BY UniqueID) row_num
FROM Nashville_Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Delete Unused Columns

Select * 
From Nashville_Housing;

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress