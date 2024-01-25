/*

Cleaning Data in SQL Queries

*/


Select *
From SQLPersonalProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From SQLPersonalProject.dbo.NashvilleHousing


Update SQLPersonalProject.dbo.NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
Add SaleDateConverted Date;


Update SQLPersonalProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


Select *
From SQLPersonalProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLPersonalProject.dbo.NashvilleHousing a
JOIN SQLPersonalProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLPersonalProject.dbo.NashvilleHousing a
JOIN SQLPersonalProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From SQLPersonalProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,  LEN(PropertyAddress)) as Address

From SQLPersonalProject.dbo.NashvilleHousing


ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update SQLPersonalProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update SQLPersonalProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,  LEN(PropertyAddress))



Select *
From SQLPersonalProject.dbo.NashvilleHousing




Select OwnerAddress
From SQLPersonalProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLPersonalProject.dbo.NashvilleHousing



ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update SQLPersonalProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update SQLPersonalProject.dbo.NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update SQLPersonalProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From SQLPersonalProject.dbo.NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to 'Sold' and 'Vacant' 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From SQLPersonalProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
-- Case statement
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From SQLPersonalProject.dbo.NashvilleHousing


Update SQLPersonalProject.dbo.NashvilleHousing
SET SoldAsVacant  = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Assuming we do not need duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQLPersonalProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From SQLPersonalProject.dbo.NashvilleHousing




-------------------------------------------------------------------------------------------------------------------------

-- Remove Unused Columns

Select *
From SQLPersonalProject.dbo.NashvilleHousing


ALTER TABLE SQLPersonalProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate