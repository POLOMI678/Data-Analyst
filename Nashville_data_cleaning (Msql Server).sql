
Select * from PortfolioProject.dbo.NashvilleHousing

--1)Standarize date format

Select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--Don't work most of the times
Update NashvilleHousing 
SET SaleDate = CONVERT(date, SaleDate)
-------------

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;
--x--
Update NashvilleHousing 
SET SaleDateConverted = CONVERT(date, SaleDate)
--x--

--2)Populate property address data

Select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is NULL

Select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--population/filling the address from b to a i.e original base address to null values

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isNull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--For join and update dont use base name i.e. NashvilleHousing instead use the alias like 'a'

Update a
SET PropertyAddress = isNull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--Breaking down address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing

--The comma is a number, so to remove that we add -1 i.e. going 1 step back from the current place

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
From PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--x--
Update PortfolioProject.dbo.NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
--x--

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
Add PropertySplitCity nvarchar(255);
--x--
Update PortfolioProject.dbo.NashvilleHousing 
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 
--x--

Select *
From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitAddress  =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitCity  =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitState  =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
  DROP COLUMN SalesDateSplitCity;

--Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

------------------------------------------------------------------------

--Remove Duplicates----
--Check first
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
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

--Apply
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--From above query we came to know that there are 104 rows duplicates.
--Now we delete them

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1

------------------------------------------------------------
--Delete Unused columns
Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDateSplitAddress, SaleDateSplitCity

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate