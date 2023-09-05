--Cleaning data in SQL Queries

Select *
From Portfolioproject.dbo.NashvilleHousing

---------------------------------------------------------

--Standardized Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Portfolioproject.dbo.NashvilleHousing

Update Portfolioproject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update Portfolioproject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------

--Populated Property Address Data

Select *
From Portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual Couloumns(Address,City,State)

Select PropertyAddress
From Portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address
From Portfolioproject.dbo.NashvilleHousing

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


Select *
From Portfolioproject.dbo.NashvilleHousing

Select OwnerAddress
From Portfolioproject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Portfolioproject.dbo.NashvilleHousing

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From Portfolioproject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolioproject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From Portfolioproject.dbo.NashvilleHousing

Update Portfolioproject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From Portfolioproject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------

--Remove Duplication

WITH RowNumCTE AS (
Select *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
					 )row_num
From Portfolioproject.dbo.NashvilleHousing
--order by ParcelID
)
Select*
From RowNumCTE
WHERE row_num >1
Order by PropertyAddress

-----------------------------------------------------------------------------

--Delete unused Coloumns

Select *
From Portfolioproject.dbo.NashvilleHousing

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate